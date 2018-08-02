<?php
class Category
{
	public $content;
	public $xmlContent;
	private $dbtable;
	private $structure;
	private $relationTable;
	private $id;
	private $params  = array();
	
	/**
	*	Al inicializar la clase se setean algunos valores
	*	que se utilizan internamente.
	*	@param $id (optional) id del show
	*	@param $params (optional) parámetros para usar en los métodos
	*	@return void
	*/
	public function __construct($id = false, $params = false)
	{
		
		$this->id = $id;
		$this->structure = CategoryModel::$tables;
		$this->dbtable   = CategoryModel::$table;
		$this->relationTable = CategoryModel::$relationTable;
		$this->params = array(
			'tag'       => 'category',
			'user_type' => 'backend',
			'module'	=> 'category',
			'debug'			=> false,
			'internalCall'	=> false,
		);
		$this->params = Util::extend(
			$this->params,
			$params
		);
	}

	/**
	*	Collection es una instancia de la clase CategoryCollection
	*	que se encarga de manipular listados
	*	@param $params (optional) parametrización de la clase
	*	@return Collection object
	*/
	public function Collection($params = false)
	{
		if(empty($params)) $params = array();
		$this->params = Util::extend(
			$this->params,
			$params
		);

		return new CategoryCollection($this->params);
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
		if(empty($params)) $params = array();
		$this->params = Util::extend(
			$this->params,
			$params
		);

		if(!$id)
			$id = $this->id;

		return new CategoryItem($id, $this->params);
	}


	public function Add($dto)
	{
		$fields = array();
		$fields = CategoryModel::parseInputFields($this->structure, $dto, $this->dbtable, true);

		$query = new Query(
			array(
				'fields' => $fields,
				'table'  => $this->dbtable
			)
		);
		Cache::SoftClear($this->params['module']);
		return $query->insert();
	}

	public function Edit($data)
	{
		if(is_array($data))
		{
			$fields = array();
			$fields = CategoryModel::parseInputFields($this->structure, $data, $this->dbtable, $verbose=false);

			$query = new Query(			
				array(
					'fields' => $fields,
					'table'  => $this->dbtable,
				)
			);
			$query->filter('category_id = :category_id');
			$query->param(':category_id', $fields['category_id'], 'int');

			$return = $query->update();

			if(!empty($data['category_parent']))
			{
				$query->fields(array('category_parentid' => $data['category_parent']), $sum=false);
				$query->table($this->relationTable);
				$query->clear();
				$query->filter('category_id = :category_id');
				$query->param(':category_id', $fields['category_id'], 'int');

				$query->update();
			}

			Cache::SoftClear($this->params['module']);
			return $return;
		}
		else
		{
			return false;
		}
	}

	public function Delete($id)
	{
		$item = $this->item($id);
		$childs = $item->GetTree();
		foreach($childs as $key=>$category)
		{
			if(is_numeric($key))
			{
				$this->Delete($category['category_id-att']);
			}
		}
		
		// Delete from parent
		$parent = new Query(
			array(
				'table'  => $this->dbtable,
				'fields' => array('category_parent' => 1),
			)
		);
		$parent->filter('category_parent = :id');
		$parent->param(':id', $id, 'int');
		$parent->update();

		// Delete category
		$category = new Query(
			array(
				'table' => $this->dbtable,
			)
		);
		$category->filter('category_id = :id');
		$category->param(':id', $id, 'int');
		return $category->delete();
	}

	/**
	*	GetItemCategories pide las categorías de un item al módulo activo
	*	Espera un array de ids de las categorías
	*	@param $module : nombre del módulo 
	*	@param $item_id : id del item a categorizar 
	*	@param $category_parent : id de categoría parent en el árbol de categorías
	*	@return $list array
	*/
	public static function GetItemCategories($module, $item_id, $category_parent)
	{
		$el   = new $module();
		$item = $el->item($item_id);  
		$list = $item->GetCategories($category_parent);
		$list['tag'] = 'category';
		return $list;
	
	}


	/* Imágenes de categorías */
	
	public function SetImage($catId, $imgId, $type)
	{
		$fields = array('image_id' => $imgId, 'image_type' => $type);
		$fields = CategoryModel::parseInputFields(CategoryModel::$tables, $fields, CategoryModel::$table, $verbose=false);


		$query = new Query(			
			array(
				'fields' => $fields,
				'table'  => CategoryModel::$table
			)
		);
		$query->filter('category_id = :category_id');
		$query->param(':category_id', $catId, 'int');


		Cache::SoftClear($this->params['module']);
		return $query->update();
	}


	/**
	 * Search a category by name
	 * @param string $name
	 * @return array category
	 */
	public function Suggest($str, $parent_id)
	{
		$query = new Query();
		$query->fields(array(
			'c1.category_id',
			'c1.category_name',
			'c2.category_id as parent1_id',
			'c2.category_name as parent1_name',
			'c3.category_id as parent2_id',
			'c3.category_name as parent2_name',
		));
		$query->table('
			category c1
			left join category c2 on c1.category_parent = c2.category_id
			left join category c3 on c2.category_parent = c3.category_id
		');

		$query->filter("(c1.category_name like :query or c2.category_name like :query or c3.category_name like :query)");
		$query->param(':query', '%'. $str . '%', 'string');

		// $query->filter("c1.category_parent = :parent_id");
		// $query->param(':parent_id', $parent_id, 'int');		

		$query->groupby('c1.category_id');

		// $query->debug();
		// $query->debugSQL();

		$result = $query->select();
		if(isset($result[0]))
		{
			$list = $result;

			foreach ($result as $key => $category) {
				$item = $this->Item($category['category_id']);
				$data = $item->GetTreeFromCache();
				$result[$key]['categories'] = Util::ArrayNumeric($data);
			}

		
			// $this->ParseArrayForSuggestion($result);
			// Util::debug($result);
			// die;
			return $result;
		}
		return false;
	}

	public function ParseArrayForSuggestion(&$result)
	{
		foreach($result as $key => $category) 
		{
			$this->ParseCategory($category, $key, $result);
		}
	}

	private function ParseCategory($category, $key, &$result)
	{
		if(isset($category['categories'][0]))
		{
			$list = Util::ArrayNumeric($category['categories']);
			foreach($list as $subcategory)
			{
				$temp = array(
					'category_id'   => $subcategory['category_id-att'],
					'category_name' => $subcategory['name'],
					'parent1_id'   => $category['category_id'],
					'parent1_name' => $category['category_name'],
				);
				$result[] = $temp;

				if(isset($subcategory['categories'][0])){
					$temp['categories'] = $subcategory['categories'];
					$this->ParseCategory($temp, $key, $result);
				}
			}
			unset($result[$key]['categories']);
		}
	}
	
	/**
	 * Set the role relation with a person and another module
	 * @param int $personId
	 * @param string $personName
	 * @param int $itemId
	 * @param string $moduleRelation
	 * @return void
	 */
	public function Set($dto)
	{
		$this->Test($dto);

		$query = New Query();
		$query->table($this->dbtable);

		$date = date('Y-m-d H:i:s');		
		// Util::debug($dto);
		// die;
		$sql  = 'INSERT INTO 
					category_relation  (item_id, module, category_id, category_parentid)
				SELECT * FROM
					(SELECT 
						'.$dto['item_id'].' as item_id,
						"'.$dto['module'].'" as module,
						'.$dto['category_id'].' as category_id,
						(SELECT category_parent FROM category WHERE category_id = '.$dto['category_id'].')
					) as tmp 
				WHERE NOT EXISTS
				(
					SELECT 
						* 
					FROM 
						category_relation
					WHERE 
						item_id = '. $dto['item_id'] .' 
						AND 
						category_id = '. $dto['category_id'] .'
						AND 
						module = "'. $dto['module'] .'"
				)';

		// echo $sql;
		// die;
		$query = new Query();
		return $query->execute($sql);
	}

	/**
	 * Test checks if an array has every field required
	 * @param array $arr
	 * @return void
	 */
	public function Test($arr)
	{
		if(
			!isset($arr['item_id']) ||
			!isset($arr['module']) ||
			!isset($arr['category_id'])
		)
			throw new Exception("Cannot set Category. A required field is missing.", 1);
	}

	public function FetchTree($dto)
	{
		$parent = $dto['parent_id'];
		$levels = (isset($dto['levels'])) ? $dto['levels'] : 3;

		if(is_numeric($parent))
		{
			$c    = new Category();
			$item = $c->Item($parent);
			$tree = $item->GetTreeFromCache($levels);

			return $tree;
		}
	}



}

?>