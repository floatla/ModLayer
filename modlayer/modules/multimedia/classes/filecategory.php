<?php
Class FileCategory {
	
	private $params = array(); // Class params

	public function __construct($params = false)
	{
		$this->params = array(
			'debug'			=> false,
		);
		if(empty($params)) $params = array();

		$this->params = Util::extend(
			$this->params,
			$params
		);

	}

	/**
	*	prepareQuery instancia un objeto query y setea los parametros
	*	para la consulta
	*	@return Query
	*/
	private function prepareQuery()
	{
		$query = new Query();
		$query->fields(
			array(
				'mc.multimedia_id',
				'c.*',
				'p.category_name as "parent_name"'
			)
		);
		$query->table('
			multimedia_category as mc
			left join category c on mc.category_id = c.category_id 
			inner join category p on p.category_id = c.category_parent
		');
		$query->orderby('mc.multimedia_id');
		$query->order('ASC');

		if($this->params['debug'])
		{
			$query->debug();
			$query->debugSQL();
		}
		return $query;
	}


	/**
	*	Get obtiene las categorias de un item 
	*	@return void
	*/
	public function Get($id)
	{
		$query = $this->prepareQuery();

		$query->filter('mc.multimedia_id = :id');
		$query->param(':id', $id, 'int');
		
		// $query->debugSQL();
		return $query->select();

	}


	/**
	*	GetByGroup obtiene las categorias de items en un listado 
	*	@return void
	*/
	public function GetByGroup($ids)
	{
		if(!empty($ids))
		{
			$query = $this->prepareQuery();
			$query->filter('mc.multimedia_id in (' . $ids . ')');
			return $query->select();
		}
		return false;
	}


	/**
	*	SetByGroup setea categorias a un grupo de items en un listado 
	*	@return void
	*/
	public function SetByGroup($ids, $categories)
	{
		$hasCategory = $this->GetByGroup($ids);
		foreach($categories as $catetory)
		{

		}
		Util::debug($categories);

		if(!empty($ids))
		{
			
			Util::debug($local);
			die;
			
			// return $query->select();
		}
		return false;
	}


	/**
	*	UnSet elimina la relacion de una categoria en un item
	*	@return void
	*/
	public function Unlink($item_id, $category_id=false)
	{
		$query = new Query();
		$query->table(MultimediaModel::$CategoryTable);
		$query->filter('multimedia_id = :id');
		$query->param(':id', $item_id, 'int');
		
		if($category_id){
			$query->filter('category_id = :category_id');
			$query->param(':category_id', $category_id, 'int');
		}

		return $query->delete();
	}
}
?>