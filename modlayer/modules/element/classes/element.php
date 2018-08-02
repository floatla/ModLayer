<?php
Class Element 
{
	var $params;

	public function __construct($params = false)
	{
		$this->params = array(
			'model'			=> 'ObjectModel',
			'module'		=> 'object',
			'table'			=> ElementModel::$table,
			'tag'			=> 'object',
			'user_type'		=> 'backend',
			'verbose'		=> true,
			'internalCall'	=> false,
		);
		
		if(empty($params)) $params = array();
		$this->params = Util::extend(
			$this->params,
			$params
		);
		
	}

	/**
	*	Collection es una instancia de la clase collection
	*	que se encarga de manipular listados
	*	@param $params (optinal) parametrización de la clase
	*	@return Collection object
	*/
	public function Collection($params = false)
	{
		if(empty($params)) $params = array();
		$this->params = Util::extend(
			$this->params,
			$params
		);

		if(Application::isFrontend())
		{
			$this->params['metadata'] = false;
			$this->params['setSession'] = false;
		}
		return new ElementCollection($this->params);
	}

	/**
	*	Item es una instancia de la clase Item
	*	que se encarga de manipular un elemento
	*	@param $id (required) : id del elemento
	*	@param $params (optinal) : parametrización de la clase
	*	@return Item object
	*/
	public function Item($id = false, $params = false)
	{
		// if(!$id) return false;

		if(empty($params)) $params = array();
		$this->params = Util::extend(
			$this->params,
			$params
		);

		return new ElementItem($id, $this->params);
	}

	/**
	*	Add inserta un nuevo elemento vacio 
	*	@return $id : element id
	*/
	public function Add($dto)
	{
		/* Para todas la interacciones con la base validamos el token */
		if($this->params['internalCall'] === false) {
			Application::validateToken();	
		}

		/* Lo instanciamos y lo cargamos */
		$item = $this->item();

		return $item->Add($dto);
	}

	/**
	*	Edit : edita un elemento en la base de datos
	*	@return 1
	*/
	public function Edit($dto)
	{
		/*
			Para todas la interacciones con la base validamos el token
		*/
		if($this->params['internalCall'] === false)
		{
			Application::validateToken();
		}

		if(isset($dto['creation_time'])) {
			$dto['created_at'] .= ' '. $dto['creation_time'];
			unset($dto['creation_time']);
		}

		/* Obtenemos el primary key del modulo para instanciar un Item */
		$module     = Configuration::GetModuleConfiguration($this->params['module']);
		$model      = $module->getAttribute('model');
		$reflection = new ReflectionClass($model);

		$primayKey = Model::parsePrimaryKey(
			$reflection->getStaticPropertyValue('tables'), 
			$reflection->getStaticPropertyValue('table')
		);

		/*
			Lo instanciamos y lo cargamos de la base 
			para validar que exista
		*/
		$item = $this->Item($dto[$primayKey]);

		return 
			(!$item->Exists()) 
			? false 
			: $item->Edit($dto);
	}


	/**
	*	New inserta un nuevo elemento vacío en la base de datos
	*	@return $id : element id
	*/
	public function NewItem()
	{
		/*
			Agregamos los datos del usuario modificando el elemento
		*/
		$user = Admin::Logged();
		$dto = array();
		$dto['created_at']     = date('Y-m-d H:i:s');
		$dto['created_by']   = $user['user_id'];
		$dto['created_type'] = $this->params['user_type'];
		$dto['module'] = $this->params['module'];

		/* Crear contenido vacio */
		$item = $this->Item();
		return $item->Add($dto);
	}
	
	/**
	*	@Deprecated : usar getmodule para obtener el tipo, no usar mas type_id
	*	gettype : obtiene de la base el tipo_id del elemento solicitado 
	*	@return $type_id
	*/
	public function GetModule($id)
	{
		$query = new Query(
			array(
				'table' => ElementModel::$table,
			)
		);
		$query->filter('item_id = :item_id');
		$query->param(':item_id', $id, 'int');

		$result = $query->select();

		return (!empty($result[0])) ? $result[0]['module'] : false;
	}
	
	/**
	*	FilePath : retorna la ruta del xml o json para un contenido por ID
	*	@param $id del elemento
	*	@param $json : flag para retornar la extension json. xml por default
	*	@return $path
	*/
	public function FilePath($id, $json = false)
	{
		$option = ($json) ? 'json' : 'xml'; 
		$options = array(
			'module'       => 'element',
			'folderoption' => $option,
		);

		$path   = PathManager::GetContentTargetPath($options);
		$folder = PathManager::GetDirectoryFromId($path, $id);
		return $folder.'/'.$id.'.'.$option;
	}

	/**
	*	Childs : retorna una lista de elementos "hijos" de otro elemento
	*	sin formato.
	*	@return $array
	*/
	public function Children($id, $state=false)
	{
		$collection = $this->collection();
		$childs = $collection->hasChildren($id, $state);

		if($childs)
			return $childs;

		return false;
	}


	/**
	*	inDB retorna el contenido existe en la db
	*	@return bool
	*/
	public function inDB($title)
	{
		$query = new Query();
		$query->table(ElementModel::$table);

		$query->filter('title = :title');
		$query->filter('module = :module');

		$query->param(':title',$title,'string');
		$query->param(':module', $this->params['module'], 'int');

		$result = $query->select();
		return (isset($result[0])) ? true : false;
	}

	/*
		Cuando se estable una relacion, se llama a este metodo del modulo que se esta relacionando
		para notificar un cambio
	*/
	// public function updateStatus($id)
	// {
	// 	$item = $this->item($id, $this->params);
	// 	$item->touch();
	// }


	/*
		Exchange integration
	*/

	public function ItemExchangeOut($id)
	{
		$ex = new ElementExchange($this->params);
		return $ex->ItemExchangeOut($id);
	}

	public function ItemExchangeIn(XMLDom $xml)
	{
		$ex = new ElementExchange($this->params);
		return $ex->ItemExchangeIn($xml);
	}


	/*/ Publicacion Diferida /*/
	
	/*
	* Gets elements for deferred publication
	*/
	public function GetElementsForDP()
	{
		//DB Query
		$params = array(
			'fields'	=> array('item_id', 'state', 'module', 'deferred_publication'),
			'table'		=> ElementModel::$table
		);

		$query = new Query($params);
		$query->filter('state = 4 and deferred_publication != "0000-00-00 00:00:00"');
		// $query->filter('state in (0,3)');

		$elements = $query->select();

		return (!empty($elements)) ? $elements : false;
	}

	/* 
		Respuestas de sugerencias en ajax 
	*/
	public function Suggestions($query, $response)
	{
		$data  = $this->Suggest($query);


		if($data) {
			foreach($data as $key=>$item) 
			{
				$conf  = Configuration::GetModuleConfiguration($item['module']);
				$title = Configuration::Query('/module/@title', $conf)->item(0)->nodeValue;

				$this->params['onePerItem']  = true;
				$this->params['applyFormat'] = true;
				$this->params['module'] = $item['module'];
				// $this->params['debug']  = true;

		        $im  = new ItemMultimedia($this->params);
		        $img = $im->Get($item['item_id'], $conf);
		        $image = false;
		        if($img && isset($img['images'])){
		        	$image = $img;
		        	Util::ClearArray($image['images'][0]);
		        }
		        
		        // Util::Debug($image);
		        // die;
				$sub = array(
					// 'group' => 'Filtro de ' . $item['category_name'],
					'id'   => $item['item_id'],
					'cast' => $title,
					'type'   => $item['module'],
					'slug' => Util::Sanitize($item['title']),
					'image_id'   => ($image) ? $image['images'][0]['image_id'] : false,
					'image_type' => ($image) ? $image['images'][0]['type'] : false,
				);
				$push = array(
					'value' => $item['title'], 
					'data'  => $sub,
				);
				array_push($response['suggestions'], $push);
			}
		}

		return $response;
	}

	/**
	 * buscar si hay sugerencias por titulo
	 */
	public function Suggest($str)
	{
		$query = new Query();
		$query->table($this->dbtable);

		$query->filter("title like :query AND state in (1,3)");
		$query->param(':query', '%'. $str . '%', 'string');
		$query->orderby('module');
		$query->order('DESC');

		// $query->debug();
		// $query->debugSQL();

		$result = $query->select();
		if(isset($result[0])){
			return $result;
		}
		return false;
	}

	

	/* Busquedas de front con Filtros de Tags y Categorias */
	public function SearchFiltered($dto)
	{
		// Util::debug($dto);
		// die;

		$dto['query'] = str_replace("'", "", $dto['query']);

		/* Campos que se piden */
		$fields = "el.item_id,
			el.title, 
			el.summary,
			el.created_at,
			(select m.multimedia_id from multimedia m inner join multimedia_module mr on m.multimedia_id = mr.multimedia_id and mr.module = '".$dto['module']."'
			where mr.object_id = el.item_id order by relation_order desc limit 1) as image_id,
			(select m.multimedia_source from multimedia m inner join multimedia_module mr on m.multimedia_id = mr.multimedia_id
			where mr.object_id = el.item_id order by relation_order desc limit 1) as image_type,
			(select c.category_name from category c inner join category_relation cr on c.category_id = cr.category_id and cr.module = '".$dto['module']."'
			where cr.item_id = el.item_id order by c.category_order desc limit 1) as category,
			MATCH (title, summary, content, el.custom_data) AGAINST ('".$dto['query']."') as score";

		/* tabla que se consulta */
		$table  = "element el ";

		/* Filtros que se aplican */
		$filters = "el.module = '". $dto['module'] ."' ";
		if(!empty($dto['query'])) {
			$filters .= "AND MATCH (title, summary, content, el.custom_data) AGAINST ('".$dto['query']."') ";
		}

		/* Si tiene filtros de categorias */
		if(!empty($dto['categories'])) {
			$list   = $dto['categories'];
			$catTbl = CategoryModel::$relationTable;
			$filter = '';
			
			for($i=0; $i<count($list); $i++)
			{
				$filter = 'AND EXISTS (select 1 from '.$catTbl.' AS cat'.$i;
				$filter .= ' WHERE el.item_id  = cat'.$i.'.item_id'; 
				$filter .= ' AND (cat'.$i.'.category_id = '.$list[$i].')';
				$filter .= ' AND cat'.$i.'.module = "' . $dto['module'] . '")';

				$filters .= $filter;
			}
		}


		$sql = "
		SELECT 
			$fields
		FROM
			$table
		WHERE
			$filters
		-- GROUP BY el.item_id
		ORDER BY score DESC;";

		// Util::Debug($sql);
		// die;
		$query = new Query();
		$items = $query->run($sql);
		$items['tag'] = "item";
		$response = array(
			'items'      => $items,
			// 'categories' => $this->CountCategoriesForSearch($dto['query'], $dto['catFilters'], $dto['module']),
			// 'tags'       => $this->CountTagsForSearch($dto['query'], $dto['tagFilters'], $dto['module']),
		);

		return $response;
	}

}
?>