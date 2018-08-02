<?php
class MenuController extends Backend
{
	
	public static function RenderDefault()
	{
		parent::loadAdminInterface();
		parent::$template->setcontent(Menu::getList(), null, 'menus');
		parent::$template->add("list.xsl");
		parent::$template->display();
	}


	public static function BackEdit()
	{
		$dto = $_POST;
		try
		{
			Menu::edit($dto);
			$array = Menu::GetById($dto['menu_id']);
			Util::ClearArray($array);

			$response = array(
				'code' => 200,
				'message' => 'Ok',
				'menu' => $array,
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
		if(!isset($dto['menu_name']))
		{
			$response = array(
				'code' => 500,
				'message' => "No se recibio ningun titulo para crear la categoria",
			);
			Util::OutputJson($response);
		}
		try
		{
			$id = Menu::Add($dto);
			$array = Menu::GetById($id);
			Util::ClearArray($array);

			$response = array(
				'code' => 200,
				'message' => 'Ok',
				'menu' => $array,
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
			Menu::remove($id);
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
		parent::$template->setcontent(Menu::Search($query), null, 'menus');
		parent::$template->setparam('query',$query);
		parent::$template->add("list.xsl");
		parent::$template->display();
	}
	
	public static function BackUpdateOrder()
	{
		$menu_id = Util::getvalue('menu_id');
		$json        = json_decode(Util::getvalue('json'));
		try
		{
			foreach($json as $menu)
			{
				if(!empty($menu->item_id))
				{
					$menu = array(
						'menu_id'     => $menu->item_id,
						'menu_parent' => ($menu->parent_id != '') ? $menu->parent_id : 0,
						'menu_order'  => $menu->order,
					);
					$result = Menu::Edit($menu);
				}
			}
			Cache::EmptyFolder('menu');
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

	public static function BackAjaxMenu()
	{
		$id = Util::getvalue('id');
		$menu = Menu::GetById($id);

		if($menu)
		{
			Util::ClearArray($menu);
			$json = array(
				'code'     => 200,
				'message'  => 'Ok',
				'menu' => $menu,
			);	
		}
		else
		{
			$json = array(
				'code'    => 500,
				'message' => 'Categoría no valida.'
			);
		}

		Util::OutputJson($json);
		die;
	}

}	
?>