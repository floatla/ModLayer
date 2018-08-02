<?php
class MultimediaBackend extends AdminController
{
	/**
	* RenderDefault muestra el listado de multimeidas del modulo activo
	* @return void
	**/
	public static function RenderDefault()
	{
		$module = Application::GetModule();
		$query  = Util::getvalue('q');

		$element    = new $module();
		$collection = $element->Collection(
			// array('debug' => true)
		);

		parent::loadAdminInterface($base=false, $internalCall=false, $module);
		parent::$template->setcontent(
			$collection->Get(), 
			null, 
			'collection'
		);

		self::$template->setcontent(
			$collection->CategoryFilters(), 
			null, 
			'filter'
		);
		parent::$template->setparam(
			$collection->getFilters()
		);

		parent::$template->add("list.xsl");
		parent::$template->display();
	}

	/**
	* RenderAdd muestra pantalla el upload del modulo activo
	* @return void
	**/
	public static function RenderAdd($message=false, $module=false)
	{
		$module = (!$module) ? Application::GetModule() : $module;

		if($message) 
			$message = str_replace('rewrite_args', '', $message);

		parent::loadAdminInterface($base=false, $internalCall=false, $module);
		self::$template->setparam(Util::FileUploadMaxSize());
		self::$template->setparam("message", $message);
		self::$template->add("add.xsl");
		self::$template->display();
	}

	/**
	* RenderEdit muestra en pantalla el editor del modulo activo
	* @return void
	**/
	public static function RenderEdit()
	{
		$id      = Util::getvalue('id');
		$module  = Application::GetModule();
		$element = new $module();
		$item    = $element->item($id, array('metadata' => true, 'getTags' => true));

		$item->LoadFromDB();

		if(!$item->Exists()) // No llamar a content()! para que no pida cateogrias y relaciones!
			Application::Route(
				array(
					'module' => $module
				)
			);

		parent::loadAdminInterface($base=false, $internalCall=false, $module);
		self::$template->setcontent(
			$item->Get(), 
			null, 
			$module
		);

		self::$template->setcontent(
			$item->WhoisUsingit(), 
			null, 
			'who_is_using'
		);		

		self::$template->add("edit.xsl");
		self::$template->display();
	}

	/**
	* BackEdit guarda los cambios de un multimedia
	* @return void.
	**/
	public static function BackEdit()
	{
		$ajax = Util::PostParam('ajaxEnabled');
		$back = Util::PostParam('back');

		unset($_POST['ajaxEnabled']);
		unset($_POST['back']);


		$module  = Application::GetModule();
		$element = new $module();
		$id      = $element->Edit($_POST); // Retorna el ID del elemento editado, o falso si no existe

		$display = array(
			'back'    => ($back == 1) ? 1 : 0,
			'item_id' => ($id) ? $id : false,
			'module'  => $module,
		);
		
		if(!$ajax) {
			Application::Route($display);
		}

		Util::OutputJson(
			array(
				'code' => 200,
				'message' => 'ok',
				'url' => Application::RouteUrl($display),
			)
		);
	}

	/**
	*	RenderSearch muestra un listado filtrado por una query de busqueda
	*	Se muestra el listado por default, la clase collection realiza la búsqueda automáticamente
	*	@return void.
	**/
	public static function RenderSearch()
	{
		self::RenderDefault();
	}

	/**
	*	BackReturn maneja las vistas al volver a la pagina anterior
	*	mateniendo los filtros de los listados
	*	@return void.
	**/
	public static function BackReturn()
	{
		$module  = Application::GetModule();
		Application::Route(
			array(
				'module' => $module
			)
		);
	}

	/**
	*	DisplayModalCollection muestra la ventana para relacionar multimedias
	*	en el contenido de cualquier modulo
	* @return void.
	**/
	public static function DisplayCollectionModal()
	{
		$item_id = Util::getvalue('item_id');
		$query   = Util::getvalue('q');
		$module  = Util::getvalue('module');
		
		$mModule  = Application::GetModule();


		$multimedia = new $mModule();
		$collection = $multimedia->Collection(array('pageSize' => 16));

		/*
			Pedimos al modulo los multimedias ya relacionados
			El modulo pidiendo multimedias debe contener un metodo GetItemMultimedias($item_id, $multimedia_typeid) 
			donde $type_id es el tipo id del multmeida
		*/
		$mod = new $module();
		$modItem = $mod->item($item_id);

		$filterItems = $modItem->GetMultimedias();

		parent::loadAdminInterface($base='modal.list.xsl');
		parent::$template->setcontent(
			$filterItems, 
			null, 
			'item'
		);
		parent::$template->setcontent(
			$collection->Get(), 
			null, 
			'collection'
		);

		self::$template->setcontent(
			$collection->CategoryFilters(), 
			null, 
			'filter'
		);

		$filters = $collection->getFilters();
		$filters['item_id'] = $item_id;
		$filters['module']  = $module;

		parent::$template->setparam($filters);
		parent::$template->setparam('request_uri', $_SERVER['REQUEST_URI']);
		parent::$template->setparam(Util::FileUploadMaxSize());
		parent::$template->display();
	}
}
?>