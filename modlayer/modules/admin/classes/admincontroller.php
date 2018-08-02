<?php
class AdminController extends Backend
{
	
	private static $message = false;
	private static $email   = false;
	private static $next    = false;
	public static $module   = false;

	public static function PackUsers()
	{
		Admin::pack();
		$default = Configuration::Query('/configuration/accessLevel');
		Application::Route(
			array(
				'module' => $default->item(0)->getAttribute('defaultModule'),
			)
		);
	}

	/*
		Usuarios
	*/
	public static function __callStatic($name, $arguments)
    {
    	$module = Application::GetModule();

		if(!is_callable(array('AdminUserController', $name))){
			$text = Configuration::Translate('system_wide/method_not_implemented');
			throw new Exception(sprintf($text, $name, $module));
		}

        // Note: value of $name is case sensitive.
        AdminUserController::$name($arguments);
    }

	public static function RenderDefault(){
		$text = Configuration::Translate('system_wide/method_not_implemented');
		throw new Exception(sprintf($text, 'RenderDefault', Application::GetModule()));
	}
	public static function RenderAdd(){
		$text = Configuration::Translate('system_wide/method_not_implemented');
		throw new Exception(sprintf($text, 'RenderAdd', Application::GetModule()));
	}
	public static function RenderEdit(){
		$text = Configuration::Translate('system_wide/method_not_implemented');
		throw new Exception(sprintf($text, 'RenderEdit', Application::GetModule()));
	}



	/**
	*	BackReturn maneja las vistas al volver a la página anterior
	*	manteniendo los filtros de los listados
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
	*	ModLanguage imprime el xml de lenguage de un módulo
	*	@return void.
	**/
	public static function LangForJS()
	{
		parent::loadAdminInterface();
		parent::$template->add('core/language.xsl');
		parent::$template->setHeader('Content-type: text/xml');

		$module = Util::GetParam('module');
		Application::SetModule($module);
		$file   = Configuration::GetModuleLanguagePath();

		if($file)
			parent::$template->setcontent($file, '/mod_language', null);

		parent::$template->display();
	}


	/* Configuración */
	public static function RenderPreferences()
	{
		parent::loadAdminInterface();
		
		$configuration = Configuration::GetConfigFile();
		$levels = new AdminLevels();
		self::$template->setcontent($configuration, null, null);
		self::$template->setcontent($levels->GetList(), null, 'levels');
		self::$template->add('conf/conf.system.xsl');
		self::$template->display();
	}
	

	public static function BackPreferencesSave()
	{
		//sleep(4);
		$data = $_POST;

		$ajaxCall = Util::getvalue('ajaxcall');

		Application::validateToken();
		unset($data['modToken']);
		if(!empty($data['ajaxcall'])) unset($data['ajaxcall']);

		$configFile = Configuration::GetConfigFile();

		$dom = new DOMDocument("1.0", "UTF-8");
		$dom->formatOutput = true;
		$dom->load($configFile);

		foreach($data as $xpath => $value)
		{
			XMLDoc::UpdateXmlFragment($dom, $xpath, $value);
		}
		$dom->save($configFile);

		if($ajaxCall){
			Util::OutputJson(array(
				'code' => 200,
				'message' => 'Ok'
			));
		}else{
			Application::Route(array(
				'module' => 'admin',
				'list_url' => 'preferences'
			));	
		}
		
	}

	public static function RenderModulePreferences()
	{
		$name = Util::getvalue('name');

		parent::loadAdminInterface();
		
		if(!empty($name))
		{
			$cat = new Category();
			$col = $cat->collection();
			$xml = Configuration::GetModuleConfiguration($name);
			self::$template->setparam('module', $name);
			$category      = new Category();
			$catCollection = $category->collection();
			self::$template->setcontent($catCollection->Get(), null, "categories");
			self::$template->setcontent($xml, null, null);
		}

		$modules = Configuration::Query('/configuration/modules');
		self::$template->setcontent($modules, null, null);
		
		$levels = new AdminLevels();
		self::$template->setcontent($levels->GetList(), null, 'levels');
		self::$template->add('conf/conf.module.xsl');
		self::$template->display();
	}

	public static function BackPreferencesModuleSave()
	{
		// sleep(5);
		$data = $_POST;
		$ajaxCall = Util::getvalue('ajaxcall');

		Application::validateToken();
		unset($data['modToken']);
		if(!empty($data['ajaxcall'])) unset($data['ajaxcall']);

		$configFile = PathManager::GetModulesPath() . '/' . $data['module'] . '/module.configuration.xml';

		$module = $data['module'];
		$dom = new XMLDom();
		$dom->formatOutput = true;
		$dom->load($configFile);

		// Groups Nodes
		foreach($data['group'] as $name => $option)
		{
			$group = "/module/options/group[@name='".$name."']";
			// Util::debug($group);
			// Util::debug($option);
			foreach($option as $index=>$values)
			{
				if(is_numeric($index))
				{
					// Util::debug($values);
					// Util::debug('----');
					$item = $group . '/option['.$index.']';
					$exists = $dom->query($item);

					// Si existe la opcion se edita
					if($exists)
					{
						foreach($values as $node=>$value)
						{
							$xpath = $item . '/' . $node;
							XMLDoc::UpdateXmlFragment($dom, $xpath, $value);
						}
					}
					// Si no existe la opción se agrega
					else
					{
						$tempGroup  = $dom->query($group)->item(0);
						$tempOption = $dom->createElement('option');
						foreach($values as $node=>$value)
						{
							if(strpos($node, '@') !== false){
								$node = str_replace('@', '', $node);
								$tempOption->setAttribute($node, $value);
							}
							else{
								$tempNode = $dom->createElement($node, $value);
								$tempOption->appendChild($tempNode);
							}
							$tempGroup->appendChild($tempOption);
						}
					}
				}
				else
				{
					$xpath = $group . '/'.$index;
					$exists = $dom->query($xpath);
					if($exists)
						XMLDoc::UpdateXmlFragment($dom, $xpath, $values);

				}
			}
		}

		// Rewrite Rules
		// Util::debug($data['rewrite']);
		// die;
		if(!empty($data['rewrite']))
		{
			foreach($data['rewrite'] as $side => $rules)
			{
				if($side == 'backend')
				{
					$side = "/module/rewrite/backend";	
				}else{
					$side = "/module/rewrite/frontend";	
				}
				
				
				foreach($rules as $index=>$values)
				{
					
					$rule = $side . '/rule['.$index.']';
					$exists = $dom->query($rule);
					if($exists)
					{
						foreach($values as $node=>$value)
						{
							$xpath = $rule . '/' . $node;
							$value = str_replace('\\\\', "\\", $value);
							XMLDoc::UpdateXmlFragment($dom, $xpath, $value);
						}
					}
					else
					{
						$tempGroup  = $dom->query($side)->item(0);
						$tempOption = $dom->createElement('rule');
						foreach($values as $node=>$value)
						{
							// En las reglas son todos atributos
							$node = str_replace('@', '', $node);
							$tempOption->setAttribute($node, $value);
							$tempGroup->appendChild($tempOption);
						}
					}
				}
			}
			unset($data['rewrite']);
		}

		unset($data['group']);
		unset($data['module']);
		
		// Nodos sueltos con el xpath completo
		foreach($data as $xpath => $value)
		{
			XMLDoc::UpdateXmlFragment($dom, $xpath, $value);
		}
		// die;

		$dom->save($configFile);

		if($ajaxCall)
		{
			// echo "1";
			$json = array(
				'code' => 200,
				'message' => 'ok'
			);
			Util::OutputJson($json);
		}
		else
		{
			Application::Route(array(
				'module' => 'admin',
				'list_url' => 'preferences/module/'.$module
			));	
		}
		
	}

	public static function ModuleGroupPropertyDelete()
	{
		$module = Util::getvalue('module'); 
		$group  = Util::getvalue('group');
		$index  = Util::getvalue('index');

		try
		{
			$configFile = PathManager::GetModulesPath() . '/' . $module . '/module.configuration.xml';
			$dom = new XMLDom();
			$dom->load($configFile);

			$node   = $dom->query("/module/options/group[@name='".$group."']/option[".$index."]");
			if($node)
			{
				$node = $node->item(0);
				$node->parentNode->removeChild($node);
				$dom->save($configFile);
			}
			

			$json = array(
				'code' => 200,
				'group' => $group,
				'index' => $index,
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($json);
	}

	public static function ModuleGroupRuleDelete()
	{
		$module = Util::getvalue('module'); 
		$group  = Util::getvalue('group');
		$index  = Util::getvalue('index');

		try
		{
			$configFile = PathManager::GetModulesPath() . '/' . $module . '/module.configuration.xml';
			$dom = new XMLDom();
			$dom->load($configFile);

			$node   = $dom->query("/module/rewrite/".$group."/rule[".$index."]");
			if($node)
			{
				$node = $node->item(0);
				$node->parentNode->removeChild($node);
				$dom->save($configFile);
			}
			

			$json = array(
				'code' => 200,
				'group' => $group,
				'index' => $index,
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($json);
	}
	






	/**
	*	BackDeleteCollection elimina un grupo de elementos en un listado
	*	@return void
	*/
	public static function BackDeleteCollection()
	{
		$ids = Util::getvalue('list');
		$arr  = explode(',', $ids);

		if(!is_array($arr) && empty($arr)){
			$response = array(
				'code'    => 500,
				'message' => Configuration::Translate('backend_messages/list_not_found'),
			);
			Util::OutputJson($response);
		}
		
		$module = Application::GetModule();

		$hasHome = false;
		try{
			if(class_exists("Instance", true)){
				$hasHome = true;
			}
		}
		catch(Exception $e){/* La clase no se puede cargar */}

		if ($hasHome !== false)
		{
			$hasInstance = Instance::isTaken($ids, $module);
			if($hasInstance)
			{
				$json = array(
					'code'    => 500,
					'message' => sprintf(
						Configuration::Translate('backend_messages/delete_home_instance'),
						$hasInstance['object_title'],
						$hasInstance['title']
					),
				);
				Util::OutputJson($json);
				die;
			}
		}

		try
		{
			$element    = new $module();
			$collection = $element->Collection(
				// array('debug' => true)
			);

			$collection->Trash($ids);

			$response = array(
				'code'     => 200,
				'message'  => 'ok',
				'elements' => $arr, 
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code'    => 500,
				'message' => $e->getMessage()
			);
			
		}
		Util::OutputJson($response);
	}
	


	/******* CATEGORIES ********/


	/**
	*	Setea las categorías en un grupo de elementos
	*	de un listado
	*/
	public static function BackSetCategories()
	{
		$items      = Util::getvalue('elements');
		$categories = Util::getvalue('categories');
		$module     = Application::GetModule();

		if(!is_array($items))
		{
			$response = array(
				'code'    => 500,
				'message' => Configuration::Translate('backend_messages/list_not_found'),
			);
			Util::OutputJson($response);
		}

		if(!$categories)
		{
			$response = array(
				'code'    => 200,
				'message' => 'Ok. Sin categorías.',
			);
			Util::OutputJson($response);	
		}
		
		try
		{
			$element    = new $module();
			$collection = $element->Collection();
			$collection->SetCategories($items, $categories);

			$collection->touch($items);

			$response = array(
				'code'    => 200,
				'message' => 'ok',
				'ids'     => $items, 
			);

		}
		catch(Exception $e)
		{
			$response = array(
				'code'    => 500,
				'message' => $e->getMessage()
			);
			
		}
		Util::OutputJson($response);
	}

	/**
	*	BackRefreshCategories actualiza en pantalla el listado de categorías en un item
	*	@return void
	*/
	public static function BackRefreshCategories()
	{
		$id              = Util::getvalue('object_id');
		$category_parent = Util::getvalue('category_parent');
		$module          = Application::GetModule();
		try
		{
			$class          = new itemCategory();
			$itemCategories = $class->Get($id, $module);
			// $itemCategories['tag'] = 'category';

			parent::loadAdminInterface($base='ajax.xsl', false, 'admin');
			parent::$template->setcontent($itemCategories, null, 'item');
			parent::$template->setparam('call', 'categories');
			parent::$template->setparam('item_id', $id);
			parent::$template->setparam('category_parent', $category_parent);
			$html = parent::$template->returnDisplay();
			// parent::$template->displayXML();

			$json = array(
				'code' => 200,
				'message' => 'Ok',
				'id' => $id,
				'category_parent' => $category_parent,
				'html' => $html,
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($json);
	}

	/**
	*	BackSetCategoriesOrder guarda el orden de un listado de categorías en un item
	*	@return void
	*/
	public static function BackSetCategoriesOrder()
	{
		$id    = Util::getvalue('item_id');
		$order = Util::getvalue('order');

		try
		{
			if(!empty($order))
			{
				$class = new itemCategory();
				$class->setOrder($id, $order);
			}

			$json = array(
				'code'    => 200,
				'message' => 'Ok',
				'id'      => $id,
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code'    => 500,
				'message' => $e->getMessage(),
			);
		}


		Util::OutputJson($json);	

	}

	/**
	*	BackUnlinkCategory elimina la relación de una categoría en un item
	*	@return void
	*/
	public static function BackUnlinkCategory()
	{
		try
		{
			$id          = Util::getvalue('item_id');
			$category_id = Util::getvalue('category_id');
			$module      = Application::GetModule();

			$class = new itemCategory();
			$class->UnLink($id, $module, $category_id);

			$json = array(
				'code' => 200,
				'message' => 'ok',
				'category_id' => $category_id,
				'id' => $id,
			);

			// Touch del item, para indicar que hubo un cambio
			$mod  = new $module();
			$Item = $mod->Item($id);
			$Item->touch();
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}
		Util::OutputJson($json);
	}


	

	

	/******* RELATIONS ********/

	/**
	*	RenderItemRelations muestra un listado de elementos para relacionar
	*	Según los parámetros recibidos
	*	@return void
	*/
	public static function RenderItemRelations()
	{
		$id              = Util::getvalue('item_id');
		$relation_module = Util::getvalue('module');
		$query           = Util::getvalue('q');
		
		if(empty($relation_module)) throw new Exception(Configuration::Translate('backend_messages/collection_module_not_available'), 1);
		

		// Obtenemos las relaciones que ya tiene el elemento
		$thisConf     = Configuration::GetModuleConfiguration($relation_module);
		$ir = new itemRelation(
			// array('debug' => true)
		);
		$relations = $ir->Get($id, $thisConf);

		$module = Application::GetModule();
		

		$element = new $module();
		$collection = $element->Collection(array('pageSize' => 20));

		parent::loadAdminInterface($base='content/panel.relations.xsl', false, 'admin');

		parent::$template->setcontent(
			$relations, 
			null, 
			'relations'
		);
		parent::$template->setcontent(
			$collection->Get(), 
			null, 
			'collection'
		);
		parent::$template->setcontent(
			$collection->CategoryFilters(), 
			null, 
			'filter'
		);

		parent::$template->setparam(
			$collection->getFilters()
		);
		parent::$template->setparam(
			array(
				'item_id' => $id,
				// 'type_id' => $type_id,
				'active_module' => $module,
				'relation_module' => $relation_module,
			)
		);

		parent::$template->display();
	}

	public static function BackSetRelations()
	{
		$id             = Util::getvalue('item_id');			// Id que va a recibir la relación
		$foreignModule  = Util::getvalue('relation_module');	// Módulo del id que recibe la relación
		$elements       = Util::getvalue('elements');			// Array de ids a relacionar (del módulo que se está invocando)

		if(!is_array($elements))
		{
			$response = array(
				'code'    => 500,
				'message' => Configuration::Translate('backend_messages/list_not_found'),
			);
			Util::OutputJson($response);
		}
		

		try
		{
			$current = Application::GetModule();
			$modConf = Configuration::GetModuleConfiguration($foreignModule);
			$option  = Configuration::Query("/module/options/group[@name='relations']/option[@name='".$foreignModule."']", $modConf);

			/* 
				Si el módulo que recibe la relación pide un callback
			*/
			if($option)
			{
				$class  = $option->item(0)->getAttribute('callback_class');
				$method = $option->item(0)->getAttribute('callback_method');
				
				if(!empty($class) && !empty($method))
				{
					$dto = array(
						'id'       => $id,
						'module'   => $foreignModule,
						'elements' => $elements,
						'foreign'  => $current,
					);
					call_user_func_array(array((string)$class,(string)$method), array($dto));
				}
			}

			/*
				Instancia del módulo externo (al que pertenece el id que recibe las relaciones)
			*/
			$mod  = new $foreignModule();
			$item = $mod->item($id);
			$item->SetRelations($elements, $current);
			
			$thisMod = new $current();
			$collection = $thisMod->collection();
			$collection->touch($elements);


			$response = array(
				'code'    => 200,
				'message' => 'ok',
				'id'      => $id, 
				'module' => $current, 
			);

		}
		catch(Exception $e)
		{
			$response = array(
				'code'    => 500,
				'message' => $e->getMessage()
			);
			
		}
		Util::OutputJson($response);
	}

	/**
	*	BackUnlinkRelation elimina la relación de una categoría en un item
	*	@return void
	*/
	public static function BackUnlinkRelation()
	{
 
		try
		{
			$id              = Util::getvalue('item_id');
			$module          = Util::getvalue('module');
			$relation_id     = Util::getvalue('relation_id');
			$relation_module = Util::getvalue('relation_module');

			$obj = new $module();
			$item = $obj->item($id);

			$item->UnSetRelation($relation_id);

			$mod = new $relation_module();
			$ir  = $mod->item($relation_id);
			$ir->touch();

			/* 
				Si la relación que se está eliminando tiene un xml publicado,
				actualizamos ese xml. El método updateRelationsXML válida si 
				el elemento está publicado.
			*/
			// $relation = new $module();
			// $relation->updateRelationsXML($id);

			$json = array(
				'code' => 200,
				'message' => 'ok',
				'relation_id' => $relation_id,
				'id' => $id,
				'relation_module' => $module
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}
		Util::OutputJson($json);
	}	

	/**
	*	BackRefreshRelations actualiza en pantalla el listado de relaciones en un item
	*	@return void
	*/
	public static function BackRefreshRelations()
	{
		$id              = Util::getvalue('item_id'); // id del contenido al que se están refrescando las relaciones
		$relation_module = Util::getvalue('relation_module'); // módulo del contenido relacionado a refrescar

		try
		{
			$module       = Application::GetModule();

			$class        = new itemRelation();
			$itemRelation = $class->GetByType($id, $relation_module, $module);

			$html = null;
			$count = 0;
			if($itemRelation){
				$itemRelation = Util::arrayNumeric($itemRelation);
				$count        = count($itemRelation);
				$itemRelation['tag'] = 'object';

				// Util::Debug($itemRelation);
				// die;
				parent::loadAdminInterface($base='content/ajax.xsl', false, 'admin');
				parent::$template->setcontent(
					$itemRelation, 
					null, 
					'item'
				);
				parent::$template->setparam(
					array(
						'call'    => 'relations',
						'item_id' => $id,
						// 'type_id' => $type_id,
						'module' => $module
					)
				);

				// parent::$template->displayXML();
				$html = parent::$template->returnDisplay();
			}

			$json = array(
				'code'		=> 200,
				'message'	=> 'Ok',
				'id'		=> $id,
				'count'		=> $count,
				'html'		=> $html,
				'module' => $module
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($json);
	}

	/**
	*	BackOrderRelations guarda en la base el orden de las relaciones 
	*	Se utiliza para relaciones de contenido, multimedias y categorías
	*	@return void
	*/
	public static function BackSetOrder()
	{
		$item_id         = Util::getvalue('item_id');
		$relationModule  = Util::getvalue('relationModule');
		$module          = Application::GetModule();
		$list            = Util::getvalue('list');
		$order           = json_decode($list);
		
		try{
			/*
				Para multimedias necesitamos usar otra clase.
			*/
			$multimedias = array('image', 'document', 'audio', 'video');
			
			if(in_array($relationModule, $multimedias))
			{
				$class = new itemMultimedia();
				$class->SetOrder($item_id, $order);
			}
			elseif($relationModule == 'category')
			{
				$class = new itemCategory();
				$class->setOrder($item_id, $order);
			}
			elseif($relationModule == 'role')
			{
				$class = new Role();
				$class->setOrder($order, $item_id, $module);
			}
			else
			{
				$class = new itemRelation();
				$class->setOrder($item_id, $module, $order);
			}
			$response = array(
				'code' => 200,
				'message' => 'ok',
			);
		}
		catch(Exception $e){
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}
		Util::OutputJson($response);
	}

	/**
	*	BackDelete elimina un elemento de un módulo
	*	@return void
	*/
	public static function BackDelete()
	{
		$id      = Util::getvalue('item_id');
		$module  = Application::GetModule();

		$hasHome = false;
		try{
			if(class_exists("Instance", true)){
				$hasHome = true;
			}
		}
		catch(Exception $e){/* La clase no se puede cargar */}

		if ($hasHome !== false)
		{
			$hasInstance = Instance::isTaken($id, $module);
			if($hasInstance)
			{
				$json = array(
					'code'    => 500,
					'message' => sprintf(
						Configuration::Translate('backend_messages/delete_home_instance'),
						$hasInstance['object_title'],
						$hasInstance['title']
					),
				);
				Util::OutputJson($json);
				die;
			}
		}

		try{
			$element = new $module();
			$item = $element->item($id);

			$item->Trash();

			// self::ClearList($module);

			$json = array(
				'code'    => 200,
				'message' => 'Ok',
			);

		}
		catch(Exception $e)
		{
			$json = array(
				'code'    => 500,
				'message' => $e->getMessage(),
			);
		}
		Util::OutputJson($json);
	}




	/******* Multimedias ********/

	/**
	*	BackSetMultimedia relaciona un multimedia a un item
	*	@return void
	*/
	public static function BackSetMultimedia()
	{
		$item_id           = Util::getvalue('item_id');
		$multimedia_id     = Util::getvalue('multimedia_id');
		$multimedia_type   = Util::getvalue('multimedia_typeid');

		try
		{
			$module  = Application::GetModule();
			$element = new $module();
			$item    = $element->item($item_id);
			$item->SetMultimedia($multimedia_id);

			$response = array(
				'code'				=> 200,
				'message'			=> 'Ok',
				'id'				=> $item_id,
				'multimedia_id'		=> $multimedia_id,
				'multimedia_typeid' => $multimedia_type,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code'		=> 500,
				'message'	=> $e->getMessage(),
			);
		}

		Util::OutputJson($response);
	}

	/**
	*	BackUpdateMultimedia actualiza la vista de los multimedias
	*	@return void
	*/
	public static function BackUpdateMultimedia()
	{
		$item_id           = Util::getvalue('item_id');
		$multimedia_typeid = Util::getvalue('multimedia_typeid');
		$module            = (self::$module) ? self::$module : Application::GetModule();

		try
		{
			$mod  = Application::GetModule();
			$el   = new $mod();
			$item = $el->item($item_id);

			parent::loadAdminInterface($base='content/ajax.xsl', false, 'admin');
			parent::$template->setcontent(
				$item->Get(), 
				null, 
				'item'
			);
			parent::$template->setparam(
				array(
					'call'    => 'multimedias',
					'multimedia_typeid' => $multimedia_typeid,
					'item_id' => $item_id,
				)
			);

			// parent::$template->displayXML();
			$html = parent::$template->returnDisplay();

			$response = array(
				'code'				=> 200,
				'message'			=> 'Ok',
				'multimedia_typeid' => $multimedia_typeid,
				'html'				=> $html,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code'		=> 500,
				'message'	=> $e->getMessage(),
			);
		}

		Util::OutputJson($response);
	}
	
	/**
	*	BackUnlinkMultimedia relaciona un multimedia a un item
	*	@return void
	*/
	public static function BackUnlinkMultimedia()
	{
		$item_id           = Util::getvalue('item_id');
		$multimedia_id     = Util::getvalue('multimedia_id');

		try
		{
			$mod  = Application::GetModule();
			$el   = new $mod();
			$item = $el->item($item_id);

			$item->UnSetMultimedia($multimedia_id);

			$json = array(
				'code' => 200,
				'message' => 'ok',
				'multimedia_id' => $multimedia_id,
				'id' => $item_id,
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}
		Util::OutputJson($json);
	}

	/**
	*	BackSetMultimediaOrder cambia el orden de los multimedias en un item
	*	@return void
	*/
	public static function BackSetMultimediaOrder()
	{
		$item_id = Util::getvalue('item_id');
		$order   = Util::getvalue('order');
		$multimedia_typeid = Util::getvalue('multimedia_typeid');
		

		if(is_array($order))
		{
			$class = new itemMultimedia();
			$class->SetOrder($item_id, $order);
		}

		$response = array(
			'code' => 200,
			'message' => 'Ok',
			'item_id' => $item_id,
			'multimedia_typeid' => $multimedia_typeid
		);

		Util::OutputJson($response);
	}


	/**
	*	BackPublish publica un item en xml y actualiza el estado en la base
	*	@param id : del elemento a publicar
	*	@param internallCall : define si imprime en pantalla un json con el resultado o retorna el elemento
	*/
	public static function BackPublish($id=false, $internalCall=false)
	{
		$id = (!$id) ? Util::getvalue('item_id') : $id;
		$module = Application::GetModule();

		$el   = new $module();
		$item = $el->item($id);
		$item->Publish();

		if(!$internalCall) 
		{
			Cache::SoftClear($module);
			$response = array(
				'code' => 200,
				'message' => 'Ok',
				'id'      => $id,
			);
			Util::OutputJson($response);
		}
	}

	/**
	*	BackPublish despublica un item borrando el xml y actualizando el estado en la base
	*	@param id : del elemento a publicar
	*	@param internallCall : define si imprime en pantalla un json con el resultado o retorna el elemento
	*/
	public static function BackUnPublish()
	{
		$id = Util::getvalue('item_id');

		$module = Application::GetModule();

		$el   = new $module();
		$item = $el->item($id);

		$item->LoadFromDB();
		$item->SetProperty('state', 0);

		$item->Save();
		$item->DeleteXML();

		Cache::SoftClear($module);
		
		$response = array(
			'code' => 200,
			'message' => 'Ok',
			'id'      => $id,
		);

		Util::OutputJson($response);
	}

	/**
	*	UpdateState cambia el estado de un item
	*	@param id : del elemento
	*	@param state : nuevo estado del elemento
	*/
	public static function UpdateState()
	{
		$id           = Util::getvalue('item_id');
		$newState     = Util::getvalue('newState');
		$currentState = Util::getvalue('currentState');

		$module = Application::GetModule();

		$el   = new $module();
		$item = $el->item($id);

		$item->LoadFromDB();
		$item->SetProperty('state', $newState);

		$item->Save();

	
		$response = array(
			'code'         => 200,
			'message'      => 'Ok',
			'id'           => $id,
			'currentState' => $newState,
			'lastState'    => $currentState,			
		);

		Util::OutputJson($response);
	}
	
}
?>