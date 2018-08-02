<?php

/**
 * Item
 * Nov. 2015
 * @author Bernardo Claudio Romano Cherñac <cromano@float.la>
 */
Abstract Class Item {

    protected $id = false;
    protected $primaryKey = 'id';
    protected $fields = array('*');
    protected $dbtable;
    protected $structure;
    protected $params = array();
    protected $queryCollector = array();
    protected $data;
    protected $stateField = false;


    /**
     * __construct constructor de la clase Item
     * @param $params
     */
    public function __construct($params = false)
    {
        $this->params = array(
            'module'          => 'not-set',
            'state'           => false,
            'childrenlimit'   => 10,
            'fields'          => false,
            'debug'           => false,
            'getMultimedias'  => true,
            'metadata'        => false,
            'getCategories'   => true,
            'getTags'         => false,
            'getRoles'        => false,
            'getRelations'    => true,
            'getParent'       => true,
            'verbose'         => true,
            'applyFormat'     => true,
            'internalCall'    => false,
        );

        if(empty($params)) $params = array();

        $this->params = Util::extend(
            $this->params,
            $params
        );
    }

    /**
     * __destruct Destructor de la clase Item
     * @return void
     */
    public function __destruct()
    {
        $this->fields = array();
        $this->data   = array();
    }

    /**
     * setPrimaryKey
     * @param $key
     * @return void
     */
    public function setPrimaryKey($key)
    {
        $this->primaryKey = $key;
    }

    /**
     * getPrimaryKey
     * @return $key
     */
    public function getPrimaryKey()
    {
        return $this->primaryKey;
    }

    /**
    * GetID
    * @param $id integer
    */
    public function GetID()
    {
        return $this->id;
    }

    /**
    * setFields define los campos de la tabla en una query
    * @param $fields
    * @return void
    */
    public function setFields($fields)
    {
        $this->fields = $fields;
    }

    /**
    * setStateField define el campo estado del registro
    * @param $name
    * @return void
    */
    public function setStateField($name)
    {
        $this->stateField = $name;
    }

    /**
     * addQueryFilter
     * @param $pattern
     * @param $param
     * @param $value
     * @param $type
     * @return void
     */
    public function addQueryFilter($pattern, $param, $value, $type)
    {
        $this->queryCollector[] = array(
            'pattern' => $pattern,
            'param'   => $param,
            'value'   => $value,
            'type'    => $type,
        );
    }

    /**
     * set
     * @param array $dto
     * @return void
     */
    public function set($dto)
    {
        foreach ($dto as $name => $value)
            $this->setProperty($name, $value);
    }

    /**
     * setProperty
     * @param string $name
     * @param string $value
     * @return void
     */
    public function setProperty($name, $value)
    {
        $this->data[$name] = $value;
    }

    /**
     * getProperty
     * @param string $name
     * @return string
     */
    public function getProperty($name)
    {
        if (!isset($this->data[$name]))
            throw new Exception("Modulo " . $this->params['module'] . ": La propiedad $name no existe", 1);

        return $this->data[$name];
    }

    /**
    * setParam fuerza un parámetro en las
    * opciones de la clase. Los parámetros se inicializan con la clase (vengan de afuera o no),
    * Así aunque se defina un parámetro con este método justo despues de instanciar la clase
    * se pisa de todas formas.
    * @param $name
    * @param $value
    * @return void
    */
    public function setParam($name, $value)
    {
        $this->params[$name] = $value;
    }

    /**
    * applyFormat aplica el formato del modelo a los items
    * Según parametrización de la clase
    * @return void
    */
    public function applyFormat()
    {
        if($this->params['applyFormat'])
        {
            Model::FormatArray($this->data, $this->dbtable, $this->structure);
        }
    }

    /**
    * Save Guarda los datos en la base 
    * @return int
    */
    public function Save()
    {
        $this->data = Model::parseInputFields($this->structure, $this->data, $this->dbtable, $this->params['verbose']);
        $this->setFields($this->data);

        if($this->id === false) 
            return $this->insert();

        $query = $this->prepareQuery();

        $query->update();

        $this->updateState();
        return $this->id;
    }

    /**
     * updateState
     * @return void 
     */
    private function updateState()
    {
        if($this->stateField && empty($this->data[$this->stateField]))
        {
            $sql = 'UPDATE ' . $this->dbtable . ' SET ';
            $sql .= $this->stateField . ' =  CASE WHEN '. $this->stateField .' = 1 THEN 3 ELSE '. $this->stateField .' END';
            $sql .= ' WHERE ' . $this->primaryKey . ' = ' . $this->id;

            $query = new Query();
            $query->execute($sql);
        }
    }

    /**
    * Insert crea un nuevo registro con el elemento cargado
    * @return int
    */
    public function Insert()
    {
        $this->data = Model::parseInputFields($this->structure, $this->data, $this->dbtable, $this->params['verbose']);
        $query  = new Query(
            array(
                'fields'  => $this->data,
                'table'   => $this->dbtable,
            )
        );
        $this->injectQuery($query);
        $this->id = $query->insert(true);
        return $this->id;
    }


    /**
    * prepareQuery inicializa un objeto query con los parámetros
    * @return Query object $query
    */
    public function prepareQuery()
    {
        $query = new Query();
        $query->table($this->dbtable);
        $query->fields($this->fields);

        $this->injectQuery($query);

        if(empty($this->queryCollector))
        {
            $query->filter($this->primaryKey . ' = :id');
            $query->param(':id', $this->id, 'int');
        }

        return $query;
    }

    /**
    *   injectQuery carga los elementos de la base con los ids cargados en el listado
    *   @param $query : Instancia de la clase Query
    *   @return void
    */
    private function injectQuery(Query $query)
    {
        foreach($this->queryCollector as $i=>$filter){
            $query->filter($filter['pattern']);
            if(!empty($filter['param']) && !empty($filter['value']))
                $query->param($filter['param'], $filter['value'], $filter['type']); 
        }
    }

    /**
    * exists carga el item desde la base y si existe retorna true, sino false
    * @return boolean
    */
    public function Exists()
    {
        if(!empty($this->data)){
            return true;
        }

        $this->LoadFromDB();
        return (!empty($this->data)) ? true : false;
    }

    /**
    * LoadFromDB realiza la query a la base para cargar el item
    * @return array
    */
    public function LoadFromDB()
    {
        $query = $this->prepareQuery();

        if($this->params['debug'])
        {
            $query->debug();
            $query->debugSQL();
        }
        $data  = $query->select();

        if(isset($data[0]))
            $this->data = $data[0];
    }

    /**
    * Get devuelve los datos del item
    * @return array
    */
    public function Get()
    {
        /*
            El método Exists() que valida si el producto existe, carga los datos
            del producto en la variable $this->data 
        */
        if(empty($this->data) && !$this->Exists())
        {
            throw new Exception("El " . $this->params['module'] . " id: " . $this->id . " no existe", 1);
            return false;
        }

        $this->applyFormat();
        $this->Categories();
        $this->Tags();
        $this->Relations();
        $this->Multimedias();
        $this->UserMetadata();
        $this->Roles();
        

        return $this->data;
    }

    /**
    * Trash elimina un elemento
    * @return boolean
    */
    public function Trash()
    {
        /*
            Unlink se implementa en cada módulo y debería eliminar cualquier relación
            o xml físico que exista para el elemento
        */
        $this->Unlink();

        $query = $this->prepareQuery();
        return $query->delete();
    }


    /**
    * Unlink es llamado antes de eliminar un elemento con el objetivo 
    * de eliminar todos los vínculos que tenga este item con categorías, relaciones
    * o multimedias. O eliminar archivo XML (si se publicara), etc. 
    * Por defecto se intenta eliminar categorías y relaciones. Cada módulo deberá implementar 
    * este método según sus datos.
    * @return boolean
    */
    public function Unlink()
    {
        /* Eliminar categorías */
        $ic = new ItemCategory();
        $ic->UnLink($this->id, $this->params['module']);

        /* Eliminar relaciones */
        $ir = new ItemRelation();
        $ir->UnLink($this->id, $this->params['module']);

        /* Eliminar Multimedias */
        $ir = new ItemMultimedia();
        $ir->UnLink($this->id, $this->params['module']);
    }

    /*
    *   touch actualiza el estado de un item y se utiliza cuando se realiza algún cambio a un item publicado
    *   que no impacta directamente en el registro de la base
    *   como agregar o eliminar una categoría o relación
    */
    public function touch()
    {
        if($this->stateField)
        {
            $this->setFields( array($this->stateField => 3) );

            $query = $this->prepareQuery();
            $query->filter($this->stateField . ' = 1');
            // $query->debug();
            // $query->debugSQL();
            $query->update();
        }
    }

    /**
    *   Categories obtiene las categorías del item y las inyecta en $this->data
    *   @return void
    */
    private function Categories()
    {
        if($this->params['getCategories'])
        {
            $ic = new itemCategory($this->params);
            $categories = $ic->Get($this->id, $this->params['module']);

            if($categories)
            {
                if($this->params['applyFormat'])
                    Model::FormatArray($categories, CategoryModel::$table, CategoryModel::$tables);

                $this->data['categories'] = $categories;
            }
        }
    }

    /**
    *   Categories obtiene las categorías del item y las inyecta en $this->data
    *   @return void
    */
    private function Tags()
    {
        if($this->params['getTags'])
        {
            $tag  = new Tag($this->params);
            $tags = $tag->GetRelations($this->id, $this->params['module']);

            if($tags)
            {
                if($this->params['applyFormat'])
                    Model::FormatArray($tags, TagModel::$table, TagModel::$tables);

                $tags['tag'] = 'tag';
                $this->data['tags'] = $tags;
            }
        }
    }

    /**
    *   GetCategories retorna las categorías de un item
    *   es llamado por category para el modal de categorización de un item. Para mostrar deshabilitadas
    *   las categorías ya relacionadas
    *   @return void
    */
    public function GetCategories($category_parent)
    {
        
        $ic = new itemCategory();
        $categories = $ic->Get($this->id, $this->params['module']);

        if(!$categories) return false;

        Util::ClearArray($categories);
        $categories = Util::arrayNumeric($categories);

        $ids = array();
        foreach($categories as $group)
        {
            if($group['parent_id'] == $category_parent)
            {
                $list = Util::arrayNumeric($group);
                return $list;
            }
        }
        return false;
    }

    /**
    *   SetCategories implementa el método SetByGroup de la clase ItemCategory
    *   @param $ids : array con los items id
    *   @param $categories : array con las categorías
    **/
    public function SetCategories(array $categories)
    {
        $ic = new itemCategory($this->params);
        return $ic->Set($this->id, $this->params['module'], $categories);
    }

    /**
    *   Multimedias obtiene internamente los multimedias los inyecta en $this->data
    *   @return void
    */
    public function Multimedias()
    {
        if($this->params['getMultimedias'])
        {
            $this->data['multimedias'] = $this->GetMultimedias();
        }
    }

    /**
    *   GetMultimedias obtiene los multimedias del item
    *   @return array
    */
    public function GetMultimedias()
    {
        $conf = Configuration::GetModuleConfiguration($this->params['module']);
        $im   = new ItemMultimedia($this->params);
        return $im->Get($this->id, $conf);
    }

    /**
    *   SetMultimedia agrega un multimedia a un item
    *   @return void
    */
    public function SetMultimedia($multimedia_id)
    {
        $im = new ItemMultimedia($this->params);
        $im->Set($this->id, $multimedia_id, $this->params['module']);
    }

    /**
    *   UnSetMultimedia agrega un multimedia a un item
    *   @return void
    */
    public function UnSetMultimedia($multimedia_id)
    {
        $im = new itemMultimedia($this->params);
        $im->unlink($this->id, $this->params['module'], $multimedia_id);
    }

    /**
    *   Relations obtiene las relaciones del item y las inyecta en $this->data
    *   @return void
    */
    private function Relations()
    {
        if($this->params['getRelations'])
        {
            $this->data['relations'] = $this->GetRelations();
        }
    }

    /**
    *   GetRelations retorn las relaciones del item
    *   @return void
    */
    public function GetRelations()
    {
        $conf = Configuration::GetModuleConfiguration($this->params['module']);
        $ir = new itemRelation($this->params);
        return $ir->Get($this->id, $conf);
    }

    /**
    *   Relations obtiene las relaciones del item y las inyecta en $this->data
    *   @return void
    */
    public function SetRelations(Array $ids, $foreignModule)
    {
        $ir = new itemRelation($this->params);
        $ir->Set($this->id, $this->params['module'], $ids, $foreignModule);
    }

    /**
    *   Relations obtiene las relaciones del item y las inyecta en $this->data
    *   @return void
    */
    public function UnSetRelation($relation_id)
    {
        $ir = new itemRelation();
        $ir->unlink($this->id, $this->params['module'], $relation_id);
    }

    /**
    *   Multimedias obtiene internamente los multimedias los inyecta en $this->data
    *   @return void
    */
    public function Roles()
    {
        if($this->params['getRoles'])
        {
            $this->data['featuring']   = $this->Featuring();
            $this->data['featured_in'] = $this->FeaturedIn();
        }
    }

    /**
    *   Featuring obtiene los roles de otros elementos en este item
    *   @return array
    */
    public function Featuring()
    {
        // $conf = Configuration::GetModuleConfiguration($this->params['module']);
        $im   = new Role($this->params);
        return $im->Get($this->id);
    }

    /**
    *   FeaturedIn obtiene los roles de este item en otros elementos
    *   @return array
    */
    public function FeaturedIn()
    {
        // $conf = Configuration::GetModuleConfiguration($this->params['module']);
        $im   = new Role($this->params);
        return $im->FeaturedIn($this->id, $this->params['module']);
    }

    

    public function UserModification()
    {
        $user = Admin::Logged();
        $dto  = array();
        $this->data['updated_at']     = date('Y-m-d H:i:s');
        $this->data['updated_by']   = $user['user_id'];
        $this->data['updated_type'] = $this->params['user_type'];
    }

    public function UserPublication()
    {
        if(isset($this->data['published_at']))
        {
            $user = Admin::Logged();
            $dto  = array();
            $this->data['published_at']   = date('Y-m-d H:i:s');
            $this->data['published_by']   = (isset($user['user_id'])) ? $user['user_id'] : '-1';
        }
    }

    /**
    *   LoadFromXML retorna la ruta del xml publicado
    */
    public function LoadFromXML()
    {
        /* Ruta del archivo según configuración y ID */
        $file = PathManager::FilePath($this->id, $this->params['module']);

        if(file_exists($file))
        {
            return $file;
        }
        return false;
    }

    /**
    *   SaveXML genera xml del item publicado
    *   @return void
    */
    public function SaveXML()
    {
        /*
            Generar XML del elemento
        */
        $doc = new XMLDoc();
        $doc->newXML('xml');
        
        /* Obtenemos el nombre del módulo */
        $name = $this->params['module'];
        
        /* El elemento se publica dentro del tag <$nombreModulo> en el xml*/
        $tmp = array( $name => $this->Get() );

        /* Generar XML del elemento Cargado */
        $doc->generateCustomXml($tmp);

        /* Ruta del archivo según configuración y ID */
        $file = PathManager::FilePath($this->id, $this->params['module']);

        return $this->PublishXML($doc, $file);
        // return $doc->save($file);
    }

    /**
    *   PublishXML guarda un xml
    *   @param $doc -> XMLDoc object, (Required) objeto con el xml
    *   @param $file -> String (Required) ruta del archivo de destino
    *   @param $parse -> Bool (Optional) parsear el xml antes de publicar, default true
    *   @return void
    */
    public function PublishXML(XMLDoc $doc, $file, $parse=true)
    {
        if($parse)
        {
            $temp = new XMLDoc();
            $conf = Configuration::Query('/configuration/*[not(*)]');
            $temp->addXml('config', $conf, null, null);
            $temp->addXml('content', $doc->saveXML(), '/xml/*', null);

            $xslPath   = file_get_contents(PathManager::GetModuleAdminPath() . 'ui/xsl/content/publish.xsl');
            $transform = $temp->XMLTransform($temp->saveXML(),$xslPath,array());
            
            $xmlT = new XMLDom();
            $xmlT->loadXML($transform);
            return $xmlT->save($file);
        }
        else
        {
            return $doc->save($file);    
        }

        
    }    

    /**
    *   DeleteXML elimina físicamente el xml del item publicado
    *   @return void
    */
    public  function DeleteXML()
    {
        /* Ruta del archivo según configuración y ID */
        $file = PathManager::FilePath($this->id, $this->params['module']);

        return @unlink($file);
    }

    /**
    *   UpdateXML se utiliza para actualizar el archivo xml
    *   de un item publicado. Se debe implementar en cada módulo
    *   @return void
    */
    public function UpdateXML(){}

    /**
    *   PublicationCallback es llamado desde el módulo cuando se publica una home
    *   por cada item instanciado. 
    *   Espera como respuesta un array con el formato:
    *   array(
    *       'message' : (requerido) Texto a mostrar en pantalla al usuario
    *       'content' : (opcional) Cualquier contenido extra que querramos publicar y será insertado en el xml del item
    *   )
    */
    public function PublicationCallback()
    {
        $response = array();

        if($this->stateField)
        {
            $this->LoadFromDB();
            $state = $this->getProperty($this->stateField);
            if($state == 1)
            {
                $response['message'] = 'El item id '.$this->id.' ya estaba publicado.';
            }
            else
            {
                $this->SetProperty($this->stateField, 1);
                $this->UserPublication();

                $this->Save();
                $this->SaveXML();
                $response['message'] = 'Publicando item id '.$this->id.' ...';    
            }
        }

        $response['content'] = $this->Get();

        return $response;
        
    }

    /**
    *   loadMetadata Agregar los datos de los usuarios para 
    *   cada item del listado
    *   @return array
    */
    private function UserMetadata()
    {
        if ($this->params['metadata'])
        {
            
            $element = $this->data;
            $created_by    = (isset($element['created_by'])) ? $element['created_by'] : $element['created_by-att'];
            $created_type  = (isset($element['created_type'])) ? $element['created_type'] : 'backend';
            $published_by  = (isset($element['published_by'])) ? $element['published_by'] : '';

            if($created_by != 0 && ($created_type == 'backend' || $created_type == 'system'))
            {
                if($created_by == '-1'){
                    // $this->data['createdby'] = 'Importación automática';
                    $this->data['createdby'] = Configuration::Translate('item_editor/auto_import');

                }
                else{
                    $ownerUser = Admin::unpack($created_by);
                    $this->data['createdby'] = $ownerUser['name'].' '.$ownerUser['lastname'];
                }
            }
            
            if($created_by != 0 && $created_type == 'frontend')
            {
                $user = new User($created_by);
                $ownerUser = $user->Get();
                $this->data['createdby'] = $ownerUser['first_name'].' '.$ownerUser['last_name'];
                $this->data['user'] = $ownerUser;
            }

            $updated_by   = (isset($element['updated_by'])) ? $element['updated_by'] : $element['updated_by-att'];
            $updated_type = (isset($element['updated_type'])) ? $element['updated_type'] : 'backend';

            if($updated_by != 0 && $updated_type == 'backend')
            {
                $editedUser = Admin::unpack($updated_by);
                $this->data['modifiedby'] = $editedUser['name'].' '.$editedUser['lastname'];;
            }

            if($updated_by != 0 && $updated_type == 'frontend')
            {
                $user = new User($updated_by);
                $ownerUser = $user->Get();
                $this->data['modifiedby'] = $ownerUser['first_name'].' '.$ownerUser['last_name'];
                $this->data['user'] = $ownerUser;
            }

            if(!empty($element['published_by']))
            {
                if($published_by != 0):
                    $publishUser = Admin::unpack($element['published_by']);
                    $this->data['publishedby'] = $publishUser['name'].' '.$publishUser['lastname'];;
                endif;
            }

            if(!empty($element['published_by']))
            {
                if($published_by != 0 && $published_by == '-1'){
                    $text = Configuration::Translate('system_wide/published_by_system');
                    $this->data['publishedby'] = $text;
                }

                if($published_by > 0) {
                    $publishUser = Admin::unpack($element['published_by']);
                    $this->data['publishedby'] = $publishUser['name'].' '.$publishUser['lastname'];;
                }
            }
        }
    }


    /*/
    Publicar Item
    /*/
    public function Publish()
    {
        try
        {
            // Solo se cargan los datos del registro para poder 
            // carmbiar el estado
            $this->LoadFromDB();
            $this->UserPublication();
        
            $this->setProperty('state', 1);

            // Guardar en la base
            $this->Save();

            // Eliminar los datos para luego cargar la data completa
            // para publicar
            $this->__destruct();

            $this->SaveXML();

            /* Is ElasticSearch is available ? */
            $elasticSearch = false;
            try{
                if(class_exists("ElasticSearch", true)){
                    $elasticSearch = true;
                }
            }
            catch(Exception $e){
                // La clase no se puede cargar
            }

            if ($elasticSearch !== false)
            {
                $ES_element = $this->Get();

                $this->ClearRecursive($ES_element);

                $response = ElasticSearch::Put($this->params['module'], $this->id, $ES_element);
                // Util::debug($response);
                // die;
            }

            return true;
        }
        catch(Exception $e){
            echo $e->getMessage();
        }
    }

    /*
    * Save Item after deferred publication (by system)
    */
    public function SaveAfterDP()
    {
        $query = new Query();
        $query->table($this->dbtable);
        $query->fields(
            array(
                'deferred_publication' => '0000-00-00 00:00:00',
                'published_by' => '-1'
            )
        );
        $query->filter($this->primaryKey . ' = :id');
        $query->param(':id', $this->id, 'int');
        // $query->debug();
        // $query->debugSQL();
        return $query->update();
       
    }


    /**
    *   Limpia la estructura de un elemento a un formato 
    *   acorde al mapeo de ElasticSearch
    */
    public function ClearRecursive(&$input)
    {
        foreach ($input as $key => $value)
        {
            if (is_array($input[$key]))
            {
                switch($key)
                {
                    case $key == "relations":
                    case $key == "featuring":
                    case $key == "featured_in":
                        unset($input[$key]);
                        break;
                    case $key == "multimedias":
                        if(isset($input[$key]['images'][0]))
                        {
                            Util::ClearArray($input[$key]['images'][0]);
                            $input['image_id']   = $input[$key]['images'][0]['image_id'];
                            $input['image_type'] = $input[$key]['images'][0]['type'];
                        }
                        unset($input[$key]);
                        break;
                    case $key == "categories":
                        $terms = array();
                        $input[$key] = Util::arrayNumeric($input[$key]);

                        if(!empty($input[$key][0][0]))
                        {
                            foreach($input[$key] as $group)
                            {
                                $group = Util::arrayNumeric($group);
                                foreach($group as $index=>$category)
                                {
                                    if(is_array($category))
                                    {
                                        $name  = (isset($category['name'])) ? $category['name'] : $category['category_name'];
                                        $catID = (isset($category['category_id-att'])) ? $category['category_id-att'] : $category['category_id'];
                                        $terms[] = array('name' => $name, 'category_id' => $catID);
                                        // Util::debug(var_dump($category));
                                    }
                                }
                            }
                            $input[$key] = $terms;
                        }
                        else
                        {
                            unset($input[$key]);
                        }
                        break;
                    case $key == "tags":
                        $terms = array();
                        $input[$key] = Util::arrayNumeric($input[$key]);

                        if(!empty($input[$key][0]))
                        {
                            foreach($input[$key] as $tag)
                            {
                                Util::ClearArray($tag);
                                $name    = $tag['tag_name'];
                                $tagID   = $tag['tag_id'];
                                $terms[] = array('name' => $name, 'tag_id' => $tagID);
                            }
                            $input[$key] = $terms;
                        }
                        else
                        {
                            unset($input[$key]);
                        }
                        break;
                    default:
                        self::ClearRecursive($input[$key]);
                        break;
                }
            }
            else
            {
                switch($key)
                {
                    //* Repetimos los keys de arriba porque si vienen vacios no son arrays
                    case $key == "relations":
                    case $key == "tags":
                    case $key == "featuring":
                    case $key == "featured_in":
                        unset($input[$key]);
                        break;
                    case "created_at":
                    case "updated_at":
                    case "published_at":
                        if($value == '0000-00-00 00:00:00') {
                            $value = '1979-12-17 07:00:00';
                        }
                        // $input[$key] = str_replace(' ', 'T', $value);
                        $input[$key] = $value;
                        break;
                    case "categories":
                        unset($input[$key]);
                        break;
                }
                
                $value = str_replace("\n", '', $value);
                $value = str_replace("\r", '', $value);
                $value = str_replace("\n\r", '', $value);

                $saved_value = $value;
                $saved_key   = $key;
                Util::ClearKeys($value, $key);

                if($value !== $saved_value || $saved_key !== $key):
                    unset($input[$saved_key]);
                    $input[$key] = strip_tags($value);
                endif;
            }
        }

        // Added for geo location
        if(!empty($input['latitud']) && !empty($input['longitud'])){
            $input['pin'] = array('location' => array('lat' => $input['latitud'], 'lon' => $input['longitud']));
            unset($input['latitud']);
            unset($input['longitud']);
        }
    }


    public function LoadFromCache()
    {
        $folder  = $this->params['module'];
        $expires = 3600*12;
        $filters = array(
            'getMultimedias'  => $this->params['getMultimedias'],
            'metadata'        => $this->params['metadata'],
            'getCategories'   => $this->params['getCategories'],
            'getTags'         => $this->params['getTags'],
            'getRoles'        => $this->params['getRoles'],
            'getRelations'    => $this->params['getRelations'],
        );

        ksort($filters);
        $key = 'item-' . $this->id . '-' . http_build_query($filters, '', '-');
        $key = sha1($key);

        // Response from cache
        $response = Cache::GetKey($key, $folder);

        if($response)
            return $response;

        $response = $this->Get();
        Cache::setKey($key, $response, $expires, $folder);

        return $response;
    }
}
?>