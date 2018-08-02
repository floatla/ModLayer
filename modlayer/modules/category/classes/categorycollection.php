<?php
Class CategoryCollection extends Collection
{
	protected $structure;
	protected $dbtable;
	protected $params = array();
	private $parent_id = 0;

	public function __construct($params)
	{
		parent::__construct($params);
		$this->structure = CategoryModel::$tables;
		$this->dbtable	 = CategoryModel::$table;

		$this->setModuleVars();
	}

	/**
	*	setModuleVars inicializa variables y parámetros para las queries
	*	campos para queries y búsqueda
	*	@return void
	*/
	private function setModuleVars()
	{
		/* Campos para búsquedas */
		$this->setSearchFields(
			array(
				'category_name',
				'category_description',
				'category_url'
			)
		);

		$this->setPrimaryKey('category_id');


		/* Campo para ordenar */
		$this->setParam('sort', 'category_order');
		$this->setParam('order', 'ASC');
		$this->setParam('getCategories', false);
		$this->setParam('getImages', false);
	}

	public function SetParent($id)
	{
		$this->parent_id = $id;
	}

	public function Get()
	{
		$this->addQueryFilter('category.category_parent = '.$this->parent_id, null, null, null);
		$localData = $tempList = parent::Get();
		
		Util::clearArray($tempList);
		$tempList = Util::ArrayNumeric($tempList);

		$cat = new Category();
		foreach($tempList as $index=>$category)
		{
			$item = $cat->item($category['category_id']);
			$tree = $item->GetTree();

			if(isset($tree['name'])){
				$localData[$index] = $tree;
			}
		}
		// Util::debug($tempList);
		// die;

		return $localData;
	}
}

?>