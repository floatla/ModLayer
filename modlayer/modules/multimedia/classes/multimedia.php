<?php
class Multimedia
{
	var $params;
	public $type_id;
	public $type;

	public function __construct($params = false)
	{
		$this->params = array(
			'tag'			=> 'multimedia',
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

		return new FileCollection($this->params);
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

		return new FileItem($id, $this->params);
	}

	/**
	*	Add inserta un nuevo elemento en la base de datos
	*	@return $id : element id
	*/
	public function Add($dto)
	{
		/*
			Para todas la interacciones con la base validamos el token
		*/
		if($this->params['internalCall'] === false)
		{
			Application::validateToken();	
		}

		/*
			Agregamos los datos del usuario modificando el elemento
		*/
		$user = Admin::Logged();
		$dto['created_at']     = date('Y-m-d H:i:s');
		$dto['created_by']   = (!empty($dto['created_by'])) ? $dto['created_by'] : $user['user_id'];
		$dto['created_type'] = (!empty($dto['created_type'])) ? $dto['created_type'] : $this->params['user_type'];


		/*
			Lo instanciamos y lo cargamos 
		*/
		$item = $this->item(false);

		/*
			Obtenemos el primary key del modulo para instanciar un Item
		*/
		$module = $this->ConfByType($this->params['type_id']);
		$model  = $module->getAttribute('model');

		$reflection = new ReflectionClass($model);
		
		/*
			Convertimos el array de datos al formato Element
		*/
		$element = call_user_func_array(
			array(
				'Model', 
				'inputObjectFields')
			, 
			array(
				array(
					'fields'        => $dto,
					'table'         => $reflection->getStaticPropertyValue('table'),
					'tables'        => $reflection->getStaticPropertyValue('tables'),
					'objectFields'  => $reflection->getStaticPropertyValue('multimediaFields'),
					'verbose'       => $this->params['verbose']
				)
			)
		);

		$element['multimedia_typeid'] = $this->params['type_id'];

		// Seteamos el contenido
		$item->Set($element);

		// Guardamos el item
		return $item->Save();
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

		/*
			Agregamos los datos del usuario modificando el elemento
		*/
		$user = Admin::Logged();
		$dto['updated_at']     = date('Y-m-d H:i:s');
		$dto['updated_by']   = (!empty($dto['user_id'])) ? $dto['user_id'] : $user['user_id'];
		$dto['updated_type'] = (!empty($dto['user_type'])) ? $dto['user_type'] : $this->params['user_type'];


		/*
			Obtenemos el primary key del modulo para instanciar un Item
		*/
		$module = $this->ConfByType($this->params['type_id']);
		$model  = $module->getAttribute('model');

		$reflection = new ReflectionClass($model);

		$primayKey = call_user_func_array(
				array(
					'Model', 
					'parsePrimaryKey'), 
				array(
					$reflection->getStaticPropertyValue('tables'), 
					$reflection->getStaticPropertyValue('table')
				)
		);

		/*
			Lo instanciamos y lo cargamos de la base 
			para validar que exista
		*/
		$item = new FileItem(
			$dto[$primayKey], 
			$this->params
		);


		if(!$item->Exists()) return false;

		/*
			Convertimos el array de datos al formato Element
		*/
		$element = call_user_func_array(
			array(
				'Model', 
				'inputObjectFields')
			, 
			array(
				array(
					'fields'        => $dto,
					'table'         => $reflection->getStaticPropertyValue('table'),
					'tables'        => $reflection->getStaticPropertyValue('tables'),
					'objectFields'  => $reflection->getStaticPropertyValue('multimediaFields'),
					'verbose'       => $this->params['verbose']
				)
			)
		);
		
		// Seteamos el contenido
		$item->Set($element);

		// Antes de guardar avisamos al modulo
		$item->touch();

		// Guardamos el item
		return $item->save();
	}

	/**
	*	gettype : obtiene de la base el tipo_id del elemento solicitado 
	*	@return $type_id
	*/
	public function gettype($id)
	{
		$query = new Query(
			array(
				'table' => MultimediaModel::$table,
			)
		);
		$query->filter('multimedia_id = :multimedia_id');
		$query->param(':multimedia_id', $id, 'int');

		$result = $query->select();

		return (!empty($result[0])) ? $result[0]['multimedia_typeid'] : false;
	}

	public function ConfByType($type_id)
	{
		return Configuration::Query("/configuration/modules/module[@multimedia_typeid = '". $type_id ."']")->item(0);
	}

	public function GetTypeId()
	{
		return $this->type_id;
	}


	// public function FilePath($id, $json = false)
	// {
	// 	$option = ($json) ? 'json' : 'xml'; 
	// 	$options = array(
	// 		'module'       => 'element',
	// 		'folderoption' => $option,
	// 	);

	// 	$path   = PathManager::GetContentTargetPath($options);
	// 	$folder = PathManager::GetDirectoryFromId($path, $id);
	// 	return $folder.'/'.$id.'.'.$option;
	// }


	public function GetModuleMultimedias($module, $item_id)
	{
		$el = new $module();
		$item = $el->item($item_id);

		// $dto = array(
		// 	'item_id' => $item_id,
		// 	'multimedia_typeid' => $this->type_id,
		// 	'module' => $module,
		// );


		$filterItems = $item->GetMultimedias();

		return $filterItems;
	}

	/* Upload */
	public function Upload()
	{
	
		$module  = $this->ConfByType($this->params['type_id']);
		$this->params['module'] = $module->getAttribute('name');
		
		$upload = new FileUpload($this->params);
		$data	= $upload->getFiles(); // Retrieve File List

		if(empty($data)){
			return false;
		}

		$types   = Configuration::Query("/module/options/group[@name='accept']/option[@name='mime-type']", $module);
		foreach($types as $type){
			$upload->Accept($type->getAttribute('value'));
		}

		/* Validar si el archivo es aceptado segun configuración */
		$upload->isAccepted();

		/*
			El archivo se sube a una carpeta por default
			Cada modulo puede moverlo donde lo necesite
		*/
		$options = array(
			'module'       => 'multimedia',
			'folderoption' => 'target',
		);
		$path = PathManager::GetContentTargetPath($options);

		$upload->setTarget($path);
		$upload->Deposit();

		return $upload;
	}

	/**
	*	GetItemCategories retorna las categorias de un item
	*	es llamado por category para el modal de categorizacion de un item. Para mostrar deshabilitadas
	*	las categorias ya relacionadas
	*	@return void
	*/
	// public function GetItemCategories($dto)
	// {
	// 	$id              = $dto['item_id'];
	// 	$category_parent = $dto['category_parent'];
		
	// 	$class = new FileCategory();
	// 	$categories = $class->Get($id);

	// 	if(!$categories) return false;

	// 	$ids = array();
	// 	foreach($categories as $category)
	// 	{
	// 		$ids[] = $category['category_id'];
	// 	}
	// 	return $ids;
	// }

	public function GetMimeType()
	{
		return $this->type;
	}

	// Load a file 
	public function load($file)
	{
		if (!file_exists($file))
    		throw new Exception("No existe el arcivo $file.", 1);

    	$finfo = finfo_open(FILEINFO_MIME_TYPE); // devuelve el tipo mime de su extensión
		
		$this->type = finfo_file($finfo, $file);
	}

	public function Extension()
	{
		$module = $this->params['module'];

		return Configuration::Query("/configuration/modules/module[@name='".$module."']/options/group[@name='accept']/option[@value='".$this->type."']/@ext")->item(0)->nodeValue;
	}
}
?>