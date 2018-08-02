<?php
Class ElementItem extends Item
{
	protected $customField = 'custom_data'; // Encapsulated field name
	protected $localData = array();

	public function __construct($id, $params = false)
	{
		parent::__construct($params);

		$this->id = $id;
		$this->dbtable   = ElementModel::$table;
		$this->structure = ElementModel::$tables;

		$this->setPrimaryKey('item_id');
		$this->setStateField('state');
		
	}

	/**
	*	Get implementa el metodo Get de la clase parent y 
	*	a la data del item agrega la data del parent.
	*/
	public function Get()
	{
		$this->setFields(array('*', '(
			select
				o.module
			from
				'.$this->dbtable.' o
			where
				o.item_id = '.$this->dbtable.'.parent_id
			) as parent_module
		'));
		
		$this->localData = parent::Get();

		$this->GetParent();
		return $this->localData;
	}

	/**
	*	Add inserta un nuevo elemento en la base de datos
	*	@return $id : element id
	*/
	public function Add($dto)
	{
		/*
			Agregamos los datos del usuario modificando el elemento
		*/
		$user = Admin::Logged();
		$dto['created_at']   = (!empty($dto['created_at'])) ? $dto['created_at'] : date('Y-m-d H:i:s');
		$dto['created_by']   = (!empty($dto['created_by'])) ? $dto['created_by'] : $user['user_id'];
		$dto['created_type'] = (!empty($dto['created_type'])) ? $dto['created_type'] : $this->params['user_type'];
		$dto['module'] = $this->params['module'];

		/*
			Convertimos el array de datos al formato Element
		*/
		$module = Configuration::GetModuleConfiguration($this->params['module']);
		$model  = $module->getAttribute('model');
		$reflex = new ReflectionClass($model);

		$element = Model::inputObjectFields(
			array(
				'fields'        => $dto,
				'table'         => $reflex->getStaticPropertyValue('table'),
				'tables'        => $reflex->getStaticPropertyValue('tables'),
				'objectFields'  => $reflex->getStaticPropertyValue('objectFields'),
				'verbose'       => $this->params['verbose']
			)
		);

		// Seteamos el contenido
		$this->Set($element);

		// Guardamos el item
		return $this->id = $this->save();
	}

	/**
	*	Edit : edita un elemento en la base de datos
	*	@return 1
	*/
	public function Edit($dto)
	{
		/*
			Agregamos los datos del usuario modificando el elemento
		*/
		$user = Admin::Logged();
		$dto['updated_at']     = date('Y-m-d H:i:s');
		$dto['updated_by']   = (!empty($dto['user_id'])) ? $dto['user_id'] : $user['user_id'];
		$dto['updated_type'] = (!empty($dto['user_type'])) ? $dto['user_type'] : $this->params['user_type'];

		$deferred = (isset($dto['deferred']) && $dto['deferred'] == 1)
					? true
					: false;

		unset($dto['deferred']);

		/* Si no existe el item retornamos falso */
		if(!$this->Exists()) return false;

		/*
			Convertimos el array de datos al formato Element
		*/
		$module = Configuration::GetModuleConfiguration($this->params['module']);
		$model  = $module->getAttribute('model');
		$reflex = new ReflectionClass($model);

		$element = Model::inputObjectFields(
			array(
				'fields'        => $dto,
				'table'         => $reflex->getStaticPropertyValue('table'),
				'tables'        => $reflex->getStaticPropertyValue('tables'),
				'objectFields'  => $reflex->getStaticPropertyValue('objectFields'),
				'verbose'       => $this->params['verbose']
			)
		);

		/* Arreglar contenido y bajada xml por si viene mal formado */
		if(!empty($element['summary'])){
			$element['summary'] = preg_replace('/#x(.*);/', '', $element['summary']);
			$element['summary'] = Util::StringToXML($element['summary']);
		}
		if(!empty($element['content']) && $this->params['module'] != 'promo'){
			$element['content'] = str_replace('&amp;', '&', $element['content']);
			$element['content'] = preg_replace('/#x(.*);/', '', $element['content']);
			$element['content'] = Util::StringToXML($element['content']);
		}


		// Seteamos el contenido
		$this->Set($element);


		// Antes de guardar cambiamos el estado si está publicado
		$st = $this->getProperty('state');
		if($st == 1)
			$this->SetProperty('state', 3);

		if($deferred)
			$this->SetProperty('state', 4);

		/* Si se sacó la publicación diferida volvemos al estado que corresponde */
		if($st == 4 && !$deferred){
			$file = PathManager::FilePath($this->id, 'element');
			if(file_exists($file)){
				$this->SetProperty('state', 3);
			}else{
				$this->SetProperty('state', 0);
			}
			$this->SetProperty('deferred_publication', 0);
		}

		// Guardamos el item
		return $this->Save();
	}

	/**
	*	applyFormat aplica el formato del modelo a los items
	*	Segun parametrizacion de la clase
	*	@return void
	*/
	public function applyFormat()
	{
		if($this->params['applyFormat'])
		{
			$conf   = $this->ItemConf();
			$model  = $conf->getAttribute('model');

			$reflection = new ReflectionClass($model);

			$parsed = call_user_func_array(
				array(
					'Model', 
					'parseFieldsFromObjects'
				), 
				array(
					array($this->data), // El modelo espera un array
					$reflection->getStaticPropertyValue('table'),
					$reflection->getStaticPropertyValue('tables'),
					$reflection->getStaticPropertyValue('objectFields'),
					$verbose=true
				)
			);
			$this->data = $parsed[0];
		}
		
		if(!empty($this->data[$this->customField]))
		{
			$customFields = unserialize($this->data[$this->customField]);
			unset($this->data[$this->customField]);
			$this->data = array_merge($this->data, $customFields);
		}
	}

	/**
	*	GetParent retorna el contenido parent del elemento
	*	@return void
	*/
	public function GetParent()
	{
		if(!$this->params['getParent']) 
			return false;

		$parent_id = $this->getProperty('parent-att');

		// Util::debug($this->data);
		// die;
		if($parent_id != 0)
		{
			$moduleParent = $this->getProperty('parent_module');

			$el = new $moduleParent();
			$pItem = $el->item(
				$parent_id,
				array(
					'getMultimedias'  => true,
					'getCategories'   => true,
					'getRelations'    => false,
					'getParent'    => false,
				)
			);
			
			if(!$pItem->Exists())
				return false;
		
		
			$this->localData['parent'] = $pItem->Get();
		}
	}

	/**
    *   Reescribimos el metodo Save para manipular el mapeo de datos
    *	en el modelo de cada modulo que extiende element.
    *   @return int $id del elemento.
    */
    public function Save()
    {
        if((!isset($this->data['slug']) || $this->data['slug'] == '') && isset($this->data['title']))
			$this->data['slug'] = Util::Sanitize($this->data['title'], 250);

		unset($this->data['parent_module']);

		// Util::debug($this->data);
		// die;

		$this->data = Model::parseInputFields($this->structure, $this->data, $this->dbtable, $this->params['verbose']);
		$this->setFields($this->data);

		if($this->id === false) 
			return $this->insert();

		$query = $this->prepareQuery();
		$query->update();

		return $this->id;
    }

    
    /**
	*	LoadFromXML retorna la ruta del xml publicado
	*/
	public function LoadFromXML()
	{
		/* Ruta del archivo segun configuracion y ID */
		$file = PathManager::FilePath($this->id, $this->params['module']);

		if(file_exists($file))
		{
			/*
				Que exista el archivo no es suficiente para modulos que extienden de Element.
				Ya que el xml puede ser de otro módulo distinto al que lo está pidiendo.
				Se valida el nodo dentro del XML.
			*/

			$dom = new XMLDom();
            $dom->load($file);

            $modName = $this->params['module'];
            $node = Configuration::Query("/xml/*[name() = '".$modName."']", $dom->firstChild);
            
			if($node && $modName == $node->item(0)->nodeName)
			{
				return $file;
			}
		}
		return false;
	}


	private function ItemConf()
	{
		return Configuration::GetModuleConfiguration($this->params['module']);
	}










	/****** 
		De aca para abajo los metodos no estan verificados 
	*******/




	



	

	

	/**
	*	SaveXML genera y guarda un xml del elemento
	*	@return void
	*/
	public function SaveXML()
	{
		/*
			Generar XML del elemento
		*/
		$doc = new XMLDoc();
		$doc->newXML('xml');
		
		/* Obtenemos el nombre del modulo */
		$name = $this->params['module'];

		/* El elemento se publica dentro del tag <$nombreModulo> en el xml*/
		$tmp = array(
			$name => $this->Get(),
		);

		/* Agregar contenido vinculado (children) */
		$element = new $name();
		$tmp[$name]['children'] = $element->Children($this->id);
		
		/* Generar XML del elemento Cargado */
		$doc->generateCustomXml($tmp);
		
		/* Ruta del archivo segun configuracion y ID */
		$file = PathManager::FilePath($this->id, $this->params['module']);

		return $this->PublishXML($doc, $file);

		// return $doc->save($file);
		// // echo $doc->saveXML();
	}

	/**
    *   DeleteXML elimina fisicamente el xml del item publicado
    *   @return void
    */
    public  function DeleteXML()
    {
        /* Ruta del archivo segun configuracion y ID */
        $file = PathManager::FilePath($this->id, 'element');

        return @unlink($file);
    }

	
	/* 
	* Actualiza los xmls de las relaciones cuando se publica el xml
	* para reflejar los cambios
	*/
	public function UpdateRelations()
	{
		$content = $this->Get();

		if(!empty($content['relations']))
		{
			
			$xmldoc  = new DOMDocument('1.0', "UTF-8");
			$tempxml = new DOMDocument('1.0', "UTF-8");

			foreach($content['relations'] as $parent => $relation)
			{

				$list   = $relation;
				$module = $list['tag']; // ItemRelation usa el nombre del modulo como tag
				$list   = Util::arrayNumeric($list);

				foreach($list as $key=>$value)
				{
					// Util::debug($value);
					$id     = $value['id-att'];

					$mr = new $module();
					$mrItem = $mr->item($id);
					$mrItem->UpdateXML();
				}
			}
		}
		return true;
	}

	/**
	*	updateXML actualiza el xml de un elemento
	*	@return void
	*/
	public function updateXML()
	{
		$this->LoadFromDB();
		$status = $this->getProperty('state');
		if($status == 1)
		{
			$this->__destruct();
			$this->SaveXML();
		}
	}

	/**
	*	PublicationCallback sobre escribe el metodo de Item para modulos 
	*	que extienden de Element
	*	@return void
	*/
	public function PublicationCallback()
    {
        $response = array();

        $this->setFields(array('*', '(
			select
				o.module
			from
				'.$this->dbtable.' o
			where
				o.item_id = '.$this->dbtable.'.parent_id
			) as parent_module
		'));
		
        $this->LoadFromDB();

        $state = $this->getProperty($this->stateField);
        if($state == 1)
        {
            $response['message'] = 'El elemento id '.$this->id.' ya estaba publicado.';
        }
        else
        {
        	$this->__destruct();
        	$this->Publish();

            $response['message'] = 'Publicando elemento id '.$this->id.' ...';    
        }

        $temp = $this->Get();

        if(!empty($temp['categories']))
            $response['content']['categories'] = $temp['categories'];

        if(!empty($temp['tags']))
            $response['content']['tags'] = $temp['tags'];

        $response['content']['created_at'] = $temp['created_at-att'];
        $response['content']['published_at'] = $temp['published_at'];
        return $response;
        
    }

	
    /****** 
		Auto publicar parent
	*******/
	/*/
    	Reescribimos el metodo de publicacion para auto-publicar el parent
    /*/
    public function Publish()
    {
    	$this->setFields(array('*', '(
			select
				o.module
			from
				'.$this->dbtable.' o
			where
				o.item_id = '.$this->dbtable.'.parent_id
			) as parent_module
		'));

        try
        {
            // Solo se cargan los datos del registro para poder 
            // carmbiar el estado
            $this->LoadFromDB();

            $parent_id = $this->getProperty('parent_id');
            if($parent_id != 0){
            	$parent_module = $this->getProperty('parent_module'); 
            	unset($this->data['parent_module']);
            }

        	parent::Publish();
            
            if($parent_id != 0)
            {
            	$parentElem = new $parent_module();
            	$parentItem = $parentElem->Item($parent_id);
            	$parentItem->Publish();
            }

            return true;
        }
        catch(Exception $e){
            echo $e->getMessage();
        }
    }
	
}
?>