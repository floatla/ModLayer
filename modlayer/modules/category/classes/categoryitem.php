<?php
Class CategoryItem extends Item
{
	public function __construct($id, $params = false)
	{
		parent::__construct($params);

		$this->id = $id;
		$this->dbtable   = CategoryModel::$table;
		$this->structure = CategoryModel::$tables;

		$this->setParam('module', 'category');
		$this->setParam('getMultimedias', false);
		$this->setParam('getRelations', false);
		$this->setPrimaryKey('category_id');

		// $this->setParam('debug', true);
	}

	/**
	 * FetchByName loads a category from its name
	 *
	 * @return array : category data
	 * @author CR
	 **/
	public function FetchByName($name)
	{
		try
		{
			$this->addQueryFilter(
				"(LOWER(category.category_name) = :name) OR (category.category_name = LOWER(REPLACE(:name, '-', ' ')) OR category.category_name = LOWER(REPLACE(:name, ' ', '-')))",
				':name',
				strtolower($name), 
				'string'
			);
			
			return parent::Get();
		}
		catch(Exception $e){
			return false;
		}
	}

	public function GetFromCache($mixed, $tree=false, $levels=4)
	{
		$folder  = $this->params['module'];
		$expires = (3600*24)*7;
		$filters = array(
			'term' => $mixed,
			'tree' => $tree,
			'levels' => $levels
		);

		$key = 'item-' . http_build_query($filters, '', '-');
		$key = sha1($key);

		// Response from cache
		$response = Cache::GetKey($key, $folder);

		if($response)
			return $response;

		if(is_numeric($mixed))
		{
			$response = ($tree) ? $this->GetTree($levels) : parent::Get();
			Cache::setKey($key, $response, $expires, $folder);
			return $response;
		}

		if(is_string($mixed))
		{
			$response = $this->FetchByName($mixed);
			Cache::setKey($key, $response, $expires, $folder);
			return $response;
		}

		return false;
	}

	public function GetTreeFromCache($levels=3)
	{
		if($levels == 1 || $levels == 0)
			$levels = 2;

		$folder  = $this->params['module'];
		$expires = (3600*24)*7;
		$filters = array(
			'id' => $this->id,
			'levels' => $levels,
		);

		$key = 'item-' . http_build_query($filters, '', '-');
		$key = sha1($key);

		// Response from cache
		$response = Cache::GetKey($key, $folder);

		if($response)
			return $response;

		$response = $this->GetTree($levels);
		Cache::setKey($key, $response, $expires, $folder);
		return $response;
	}

	
	/**
	*	GetTree obtiene con una sola query a la base todas las categorías 
	*	que forman parte del árbol a partir del $parent_id con una profundidad de 4 niveles.
	*	La respuesta se parsea y con php se genera la estructura de árbol correspondiente. 
	*	@return array 
	*/
	public function GetTree($levels = 6)
	{
		$parent = $this->id;

		$fields = Model::parseFields($this->structure, array('*'), $this->dbtable);
		$str    = '';

		for($i = 0; $i < $levels; $i++) {
			if($i == 0){
				$field_prefix = 'parent_';
			}else{
				$field_prefix = 'child'.$i.'_';
			}

			foreach ($fields as $key => $value) {
				$localStr = $value;
				$localStr = str_replace('category.', 'c'.($i+1).'.', $localStr) . ", \n";	
				$localStr = str_replace('category_id as "category_id-att"', 'category_id as '.$field_prefix.'id', $localStr);
				$localStr = str_replace('category_name as "name"', 'category_name as '.$field_prefix.'name', $localStr);
				$localStr = str_replace('category_description as "description"', 'category_description as '.$field_prefix.'description', $localStr);
				$localStr = str_replace('category_order as "order-att"', 'category_order as '.$field_prefix.'order', $localStr);
				$localStr = str_replace('category_parent as "parent-att"', 'category_parent as '.$field_prefix.'parent', $localStr);
				$localStr = str_replace('category_url as "url-att"', 'category_url as '.$field_prefix.'url', $localStr);
				$localStr = str_replace('image_id as "image_id-att"', 'image_id as '.$field_prefix.'image_id', $localStr);
				$localStr = str_replace('image_type as "image_type-att"', 'image_type as '.$field_prefix.'image_type', $localStr);
				$str .= $localStr;
			}
		}
		$str = rtrim($str, ", \n");

		// Util::debug($str);
		// die;
		$tableStr = '';
		$orderStr = 'child1_name, ';
		for($i = 1; $i < ($levels + 1); $i++) {
			if($i == 1){
				$tableStr = "category c" .$i."\n";
			}else{
				$tableStr .= "left join \ncategory c".$i." on c".$i.".category_parent=c".($i - 1).".category_id \n";
			}
			$orderStr .= "c".$i.".category_order";
			if($i + 1 < $levels + 1) {
				$orderStr .= ",\n";
			}
		}
		// Util::debug($tableStr);
		// Util::debug($orderStr);
		// die;
		$sql = "SELECT 
					$str
				FROM 
					$tableStr
				WHERE 
					c1.category_id = $parent
				ORDER BY
					$orderStr
				ASC
				";

		$query = new Query();


		if($this->params['debug']){
			$query->debug();
			$query->debugSQL();
		}
		$response = $query->run($sql);

		// Util::debug($response);
		// die;

		// Armar el array para devolver
		$parent_name = '';
		$parent_id   = 0;
		$array  = array();
		$change = '';

		if(count($response))
		{
			foreach($response as $key=>$category)
			{
				foreach($category as $index=>$value)
                {
					if(strpos($index, 'parent_') !== false)
	                {
	                	$parent_id = $category['parent_id'];
	                    $rootItem = array(
	                        'category_id-att' => $category['parent_id'],
							'name'            => $category['parent_name'],
							'description'     => $category['parent_description'],
							'order-att'       => $category['parent_order'],
							'image_id-att'    => $category['parent_image_id'],
							'image_type-att'  => $category['parent_image_type'],
	                    );
	                    $childs = $this->Children($response, $level=0, $category['parent_id']);
	                    if(!empty($childs))
	                        $rootItem['categories'] = $childs;

	                    $array[$parent_id] = $rootItem;
	                }
	            }
			}
		}
		return isset($array[$parent_id]) ? $array[$parent_id] : false;
	}

	public function Children($catList, $level, $id)
	{
		$current = 'child'.$level;
		$child   = 'child'.($level+1);
		$list    = array();
		$name    = '';

		foreach($catList as $key => $catChild)
		{
			if(isset($catChild[$child.'_id'])){
				if($catChild[$child.'_parent'] == $id && $name != $catChild[$child.'_name'])
				{
					$name = $catChild[$child.'_name'];
					$local =  array(
						'category_id-att' => $catChild[$child.'_id'],
						'name'            => $catChild[$child.'_name'],
						'description'     => $catChild[$child.'_description'],
						'order-att'       => $catChild[$child.'_order'],
						'image_id-att'    => $catChild[$child.'_image_id'],
						'image_type-att'  => $catChild[$child.'_image_type'],
						'parent-att'      => $catChild[$child.'_parent'],
						'level'           => $level+1,
					);
					$subtree = $this->Children($catList, $level+1, $catChild[$child.'_id']);
					if(!empty($subtree))
						$local['categories'] = $subtree;

					$list[] = $local;
				}
			}
		}

		if(count($list) > 0)
		{
			$list['tag'] = 'category';
		}
		return $list;
	}
}
?>