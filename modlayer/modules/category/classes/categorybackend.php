<?php
Class CategoryBackend extends Backend
{


	public static function RenderDefault()
	{
		$category   = new Category();
		$collection = $category->collection();

		parent::loadAdminInterface();
		parent::$template->setcontent(
			$collection->Get(), 
			null, 
			'categories'
		);
		
		parent::$template->add("list.xsl");
		parent::$template->display();
	}


	public static function BackEdit()
	{
		$dto = $_POST;
		try
		{
			$category = new Category();
			$category->Edit($dto);
			$item  = $category->item($dto['category_id']);
			$array = $item->Get();
			Util::ClearArray($array);

			$response = array(
				'code' => 200,
				'message' => 'Ok',
				'category' => $array,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($response);

	}

	public static function BackAdd()
	{
		$dto = $_POST;
		if(!isset($dto['category_name']))
		{
			$response = array(
				'code' => 500,
				'message' => "No se recibió ningún título para crear la categoría",
			);
			Util::OutputJson($response);
		}
		try
		{
			$category = new Category();
			$id       = $category->Add($dto);
			$item     = $category->item($id);
			$array    = $item->Get();
			
			Util::ClearArray($array);

			$response = array(
				'code' => 200,
				'message' => 'Ok',
				'category' => $array,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}
		Util::OutputJson($response);
	}

	public static function BackAjaxDelete()
	{
		$id = Util::getvalue('id');
		try
		{
			$category = new Category();
			$category->Delete($id);

			// Category::remove($id);
			$response = array(
				'code' => 200,
				'message' => 'Ok',
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}
		Util::OutputJson($response);
		
	}

	public static function BackReturn()
	{
		$display['module']  = 'category';
		Application::Route($display);
	}
	
	public static function RenderSearch()
	{
		$query = Util::getvalue('q', false);
		parent::loadAdminInterface();
		self::$template->setcontent(Category::Search($query), null, 'categories');
		self::$template->setparam('query',$query);
		self::$template->add("list.xsl");
		self::$template->display();
	}
	
	public static function BackUpdateOrder()
	{
		$category_id = Util::getvalue('category_id');
		$json        = json_decode(Util::getvalue('json'));
		try
		{
			$cat = new Category();
			foreach($json as $category)
			{
				if(!empty($category->item_id))
				{
					$category = array(
						'category_id'     => $category->item_id,
						'category_parent' => ($category->parent_id != '') ? $category->parent_id : 0,
						'category_order'  => $category->order,
					);

					$result = $cat->Edit($category);
					
				}
			}

			$json = array(
				'code' => 200,
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

	public static function BackAjaxCategory()
	{
		$id = Util::getvalue('id');
		$category = new Category();
		$item     = $category->item($id);
		$data     = $item->Get();

		if($data)
		{
			Util::ClearArray($data);
			$json = array(
				'code'     => 200,
				'message'  => 'Ok',
				'category' => $data,
			);	
		}
		else
		{
			$json = array(
				'code'    => 500,
				'message' => 'Categoría no válida.'
			);
		}

		Util::OutputJson($json);
		die;
	}


	/*/ Categorías para Módulos  /*/

	/**
	*	RenderItemCategories muestra una parte del árbol de categorías 
	*	para categorizar un item
	*	@return void
	*/
	public static function RenderModalCollection()
	{
		$module     = Util::getvalue('module');
		$list       = Util::getvalue('list');
		$arr        = explode(',', $list);
		$arr['tag'] = 'id';
		$categories = Configuration::Query("/configuration/modules/module[@name='".$module."']/options/group[@name='categories']/option");

		parent::loadAdminInterface($base='panel.collection.xsl');
		
		parent::$template->setcontent($arr, null, 'ids');

		$container = array();
		if($categories)
		{
			foreach($categories as $category){
				if($category->getAttribute('type') == 'parent')
				{
					$parent_id = $category->getAttribute('value');
					$cat = new Category();
					$catItem = $cat->item($parent_id);
					$list = $catItem->GetTree();
					array_push($container, $list);
				}
			}
			$container['tag'] = 'group';
			self::$template->setcontent($container, null, 'categories');
		}
		self::$template->setparam('active_module', $module);
		self::$template->display();

		// Util::OutputJson(
		// 	array(
		// 		'code' => 200,
		// 		'html' => self::$template->returnDisplay()
		// 	)
		// );
	}

	/**
	*	RenderItemCategories muestra una parte del árbol de categorías 
	*	para categorizar un item
	*	@return void
	*/
	public static function RenderModalItem()
	{
		$id              = Util::getvalue('item_id');
		$category_parent = Util::getvalue('category_parent');
		$module          = Util::getvalue('module');
		
		parent::loadAdminInterface($base='modal.list.xsl');

		$list = Category::GetItemCategories($module, $id, $category_parent);
		
		parent::$template->setcontent($list, null, 'item');

		$container = array();
		$category  = new Category();
		$catItem   = $category->item($category_parent);
		$list      = $catItem->GetTree($category_parent);
		array_push($container, $list);
		$container['tag'] = 'group';

		parent::$template->setcontent($container, null, 'categories');
		parent::$template->setparam(
			array(
				'item_id' => $id,
				'category_parent' => $category_parent,
				'active_module' => $module
			)
		);
		parent::$template->display();
	}

	/**
	*	RenderCategoryOrder muestra las categorías de un item para odenarlas
	*	@return void
	*/
	public static function RenderCategoryOrder()
	{
		$id              = Util::getvalue('item_id');
		$category_parent = Util::getvalue('category_parent');
		$module          = Util::getvalue('module');
		
		$list = Category::GetItemCategories($module, $id, $category_parent);
		$list['tag'] = 'category';

		parent::loadAdminInterface($base='modal.order.xsl');
		parent::$template->setcontent($list, null, 'item');
		parent::$template->setparam(
			array(
				'item_id' => $id,
				'category_parent' => $category_parent,
				'active_module' => $module
			)
		);

		parent::$template->display();

	}



	/***  MULTIMEDIAS ***/

	/**
	*	GetItemMultimedias es llamado internamente por los módulos de multimedias
	*	para obtener los multimedias de un item y mostrarlos como relacionados en un modal
	*	@return void
	*/
	public static function GetItemMultimedias($dto)
	{
		return false;
		// $itemMultimedia = new itemMultimedia($dto);
		// return $itemMultimedia->GetByType($dto['item_id'], $dto['multimedia_typeid']);
	}

	/**
	*	BackSetMultimedia relaciona un multimedia a un item
	*	@return void
	*/
	public static function BackSetMultimedia()
	{
		$item_id           = Util::getvalue('item_id');
		$multimedia_id     = Util::getvalue('multimedia_id');
		// $multimedia_type   = Util::getvalue('multimedia_typeid');

		try
		{

			$image = new Image();
			$item = $image->item($multimedia_id);
			$photo = $item->Get();

			$type = $photo['type-att'];

			$cat = new Category();
			$cat->SetImage($item_id, $multimedia_id, $type);

			$response = array(
				'code'				=> 200,
				'message'			=> 'Ok',
				'id'				=> $item_id,
				'multimedia_id'		=> $multimedia_id,
				'multimedia_type'   => $type,
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
		$item_id = Util::getvalue('item_id');
		try
		{
			$cat = new Category();
			$cat->SetImage($item_id, 0, '');

			$json = array(
				'code' => 200,
				'message' => 'ok',
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


	public static function BackSuggestAutocomplete()
	{
		$query     = Util::getvalue('query');
		$parent_id = Util::getvalue('parent_id');

		$response = array(
			'query' => $query,
			'suggestions' => array()
		);

		$category = new Category();
		$data  = $category->Suggest($query, $parent_id);
		if($data) 
		{
			foreach($data as $key=>$category) {

				$parent = (!empty($category['parent1_name'])) ? $category['parent1_name'] : '';
				// $parent .= (!empty($category['parent2_name'])) ? ' - ' . $category['parent2_name'] : '';
				$sub = array(
					'id' => $category['category_id'],
					'parent_id'   => $category['parent1_id'],
					'parent_name' => $category['parent1_name'],
				);
				$push = array(
					'value' => $category['category_name'], 
					'data'  => $sub,
				);
				array_push($response['suggestions'], $push);
			}
		}
		Util::OutputJson($response);
	}

	public static function AjaxSetCategory()
	{
		$dto = array(
			'item_id' => Util::getvalue('item_id'),
			'module'  => Util::getvalue('module'),
			'category_id' => Util::getvalue('category_id'),
			'parent_id' => Util::getvalue('parent_id'),
		);


		try
		{
			$cat = new Category($dto['category_id']);
			$rowCount = $cat->Set($dto);

			$json = array(
				'code' => ($rowCount == 1) ? 200 : 416,
				'message' => ($rowCount == 1) ? 'Ok' : 'Ya se asignó esta Categoría.',
			);

			// Touch del item, para indicar que hubo un cambio
			$module = new $dto['module']();
			$Item   = $module->Item($dto['item_id']);
			$Item->touch();
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
}
?>