<?php
class Menu
{

	protected static $cacheFolder = 'menu';
	
	// Get Entities and relateds
	public static function GetList($parentId='0')
	{
		$cacheKey = 'menu_parent_'.$parentId;
		$expires  = '86400'; // 1 día
		
		if(!($return = Cache::getKey($cacheKey, self::$cacheFolder))):

			$fields = array('*');
			$fields = Model::parseFields(MenuModel::$tables, $fields, MenuModel::$table);
			$query  = new Query(
				array(
					'fields'=>$fields,
					'table'=>MenuModel::$table,
				)
			);
			$query->orderby('menu_id');
			$query->order('DESC');
			
			$query->filter('menu_parent = :parent_id');
			$query->param(':parent_id', $parentId, 'int');

			$return = $query->select();

			foreach($return as $key=>$value){
				$subMenus = self::getList($value["menu_id-att"]);
				if(is_array($subMenus) && count($subMenus)>1){
					$return[$key]["menus"] = $subMenus;
				}
			}
			$return['tag'] = 'menu';

			Cache::setKey($cacheKey, $return, $expires, self::$cacheFolder);
		endif;

		return $return;
	}

	// Get by id
	public static function getById($id=false)
	{
		if($id)
		{
			$fields = array('*');
			$fields = MenuModel::getFields($fields, MenuModel::$table);

			$query = new Query(
				array(
					'table'  => MenuModel::$table,
					'fields' => $fields
				)
			);
			$query->filter('menu_id = :id');
			$query->param(':id', $id, 'int');
			
			$r = $query->select();

			if(isset($r[0])):
				$menu = $r[0];
				return $menu;
			else:
				return false;
			endif;
		}
	}

	// Get by url
	public static function getByUrl($url=false){
		if($url){
			$fields = array('*');
			$fields = MenuModel::getFields($fields, MenuModel::$table);

			$query = new Query(
				array(
					'table'  => MenuModel::$table,
					'fields' => $fields
				)
			);
			$query->filter('menu_url = :url');
			$query->param(':url', $url, 'string');
			
			$r = $query->select();

			if(!empty($r)){
				$menu = $r[0];
				return $menu;
			}else {
				return false;
			}
		} else {
			return false;
		}
	}

	// Create
	public static function Add($dto){
		$fields = array();
		$fields = MenuModel::parseInputFields(MenuModel::$tables, $dto, MenuModel::$table, $verbose=true);

		$query = new Query(
			array(
				'table'  => MenuModel::$table,
				'fields' => $fields
			)
		);
		return $query->insert();
	}

	// Update
	public static function edit($data=array())
	{
		if(is_array($data))
		{
			$fields = array();
			$fields = MenuModel::parseInputFields(MenuModel::$tables, $data, MenuModel::$table, $verbose=true);

			$query = new Query(
				array(
					'table'  => MenuModel::$table,
					'fields' => $fields
				)
			);
			$query->filter('menu_id = :id');
			$query->param(':id', $fields['menu_id'], 'int');
			
			$return = $query->update();
			return $return[0];
		}
		else
		{
			return false;
		}

	}

	// Delete
	public static function remove($id=false){
		if($id)
		{
			$query = new Query(
				array(
					'table'  => MenuModel::$table,
				)
			);
			$query->filter('menu_id = :id');
			$query->param(':id', $id, 'int');
			return $query->delete();
		}
		else
		{
			return false;
		}
	}

	// Search
	public static function Search($queryStr)
	{
		$fields = array('*');
		$fields = MenuModel::getFields($fields, MenuModel::$table);

		$query = new Query(
			array(
				'table'  => MenuModel::$table,
				'fields' => $fields
			)
		);
		$query->filter("menu_name like :query");
		$query->param(':query', '%'.$queryStr.'%', 'string');

		$return = $query->select();
		$return['tag'] = 'menu';
		return $return;
		
	}


	public static function FetchTree($dto)
	{
		$parent = Util::getvalue('parent_id');


		$key = 'menu_parent_'.$parent;
		$exp = '86400' * 10; // 10 días
		$dir = 'menu';

		// Response from cache
		$response = Cache::GetKey($key, $dir);

		if($response)
			return $response;

		$response = self::GetList($parent);
		Cache::setKey($key, $response, $exp, $dir);

		return $response;
	}
}

?>