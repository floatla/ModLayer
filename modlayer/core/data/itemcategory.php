<?php
Class ItemCategory 
{
	private $params = array();
	private $dbtable;


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

		$this->dbtable = CategoryModel::$relationTable;
	}

	/**
	*	prepareQuery instancia un objeto query y setea los parámetros
	*	para la consulta
	*	@return Query
	*/
	private function prepareQuery()
	{
		/*
			Los módulos permiten por configuración agregar distintas partes del árbol de categoría.
			Se piden las categorías agrupadas por cada parte del árbol en configuración.
		*/
		$query = new Query();
		$query->fields(
			array(
				'oc.item_id',
				'c.*',
				'oc.category_order as "order"',
				'p.category_name as "parent_name"'
			)
		);
		$query->table('
			'.$this->dbtable.' as oc
			inner join category c on oc.category_id = c.category_id 
			inner join category p on p.category_id = c.category_parent
		');
		$query->orderby('oc.item_id, oc.category_order');
		$query->order('ASC');

		if($this->params['debug'])
		{
			$query->debug();
			$query->debugSQL();
		}
		return $query;
	}


	/**
	*	Get obtiene las categorías de un item 
	*	@return void
	*/
	public function Get($id, $module)
	{
		/*
			Los módulos permiten por configuración agregar distintas partes del árbol de categoría.
			Se piden las categorías agrupadas por cada parte del árbol en configuración.
		*/
		$modConf = Configuration::GetModuleConfiguration($module);
		$options = Configuration::Query("/module/options/group[@name='categories']/option[@type='parent']", $modConf);

		if($options)
		{
			$categories = array();
			$query = new Query();
			foreach($options as $option)
			{
				$tree_parent = $option->getAttribute('value');
				$sql = $this->GetSQL($id, $tree_parent, $module);

				$list = $query->run($sql);
				$list['tag'] = 'category';
				$list['parent_id-att'] = $tree_parent;
				$list['name-att'] = $option->getAttribute('label');

				$categories[] = $list;
			}

			$categories['tag'] = 'group';
			return $categories;
		}
		return false;
	}

	/**
	*	Set agrega una categoría a un item de un item 
	*	@param $id del item
	*	@param $module nombre del módulo del item
	*	@return void
	*/
	public function Set($id, $module, $categories)
	{
		$this->SetByGroup(array($id), $categories, $module);
	}
	
	/**
	*	GetByGroup obtiene las categorías de items en un listado 
	*	@return void
	*/
	public function GetByGroup($ids, $module, $tree_parent)
	{
		if(!empty($ids))
		{
			$sql   = $this->GetSQL($ids, $tree_parent, $module);
			$query = new Query();
			return $query->run($sql);
		}
		return false;
	}


	/**
	*	SetByGroup setea categorías a un grupo de items en un listado 
	*	@return void
	*/
	public function SetByGroup($items, $categories, $module)
	{
		$excludeList = $this->GetByGroup( implode( ',', $items), $module, 1);

		// Sentencia
		$sql = 'INSERT INTO '.$this->dbtable.' (item_id, module, category_id, category_parentid) VALUES ';
		$isEmpty = true;

		/*
			Se agregan las categorías a los elementos seleccionados
			solo si no existe
		*/
		// Iteramos las categorías
		if ($categories) {
			foreach($categories as $category_id)
			{
				// Iteramos los elementos
				foreach($items as $item_id)
				{
					$hasCategory = false;

					// Iteramos el listado de categorías asignadas
					// para no repetir categorías en elementos
					foreach($excludeList as $exclude)
					{
						if($exclude['item_id'] == $item_id && $exclude['category_id'] == $category_id) {
							$hasCategory = true;
						}
					}
					if(!$hasCategory) {
						$isEmpty = false;
						$sql .= '('.$item_id.', "'.$module.'", '.$category_id.', (select category_parent from category where category_id = '.$category_id.')), ';

						// Actualizamos el estado
						$tmp  = new $module();
						if(method_exists($tmp, 'item')){
							$item = $tmp->item($item_id, $this->params);
							$item->touch();
						}
					}
				}
			}
			$sql = rtrim($sql, ', ');

			if(!$isEmpty){
				$query = new Query();
				return $query->execute($sql);
			}
		}
		return false;

		// La query que se termina formando tiene este formato:
		// insert into object_category (item_id, category_id, category_parentid) values
		// (379, 13, (select category_parent from category where category_id = 13)),
		// (379, 10, (select category_parent from category where category_id = 10))
	}

	/**
	*	SetOrder setea el orden de las categorías en un item
	*	@return void
	*/
	public function SetOrder($id, $order)
	{
		$ids = implode(',', $order);
		$sql = 'UPDATE '.$this->dbtable.' SET category_order = CASE category_id ';
		foreach($order as $order => $category_id)
		{
			$sql .= 'WHEN ' . $category_id . ' THEN ' . $order . ' ';
		}
		$sql .= 'END ';
		$sql .= 'WHERE category_id in ('.$ids.') AND item_id = ' . $id;

		$query = new Query();
		$query->execute($sql);

		return true;
	}

	/**
	*	Unlink relimina todos los registros para un item_id
	*	@param $item_id : id del elemento
	*	@param $module : módulo al que pertenece el elemento
	*	@param $category_id : (opcional) id de categoría para eliminar solo un registro
	*	@return boolean
	*/
	public function UnLink($item_id, $module, $category_id=false)
	{
		$query = new Query();
		$query->table($this->dbtable);
		$query->filter('item_id = :id AND module = :module');

		$query->param(':id', $item_id, 'int');
		$query->param(':module', $module, 'string');

		if($category_id) {
			$query->filter('category_id = :category_id');
			$query->param(':category_id', $category_id, 'int');
		}

		if($this->params['debug']) {
			$query->debug();
			$query->debugSQL();
		}

		return $query->delete();
	}

	/**
	*	unlinkCollection elimina relaciones de multimedias con items de un listado
	*	@return void
	*/
	public function unlinkCollection($ids, $module)
	{
		$query = new Query();
		$query->table($this->dbtable);
		$query->filter('item_id in ('.$ids.')');
		$query->filter('module = :module');
		$query->param(':module', $module, 'string');

		return $query->delete();
	}


	private function GetSQL($ids, $tree_parent, $module)
	{
		$sql = '
			select 
				c.category_id, 
				c.category_name, 
				c.category_parent,
				oc.category_order,
				oc.item_id,
				(
					select category_name from category where category_id = c.category_parent
				) as parent_name
			from 
				category c
				inner join '.$this->dbtable.' oc on c.category_id=oc.category_id
			where
				oc.item_id in ('.$ids.')
				and 
				oc.module="'.$module.'"
				and
				c.category_id in (
						select 
							a.category_id
						from 
							category a
						where 
							a.category_id='.$tree_parent.'
					union
						select 
							b.category_id
						from
							category b
						where 
							b.category_parent='.$tree_parent.'
					union
						select 
							c.category_id
						from
							category c
							inner join category b on c.category_parent=b.category_id
						where 
							b.category_parent='.$tree_parent.'
					union
						select 
							d.category_id
						from
							category d
							inner join category c on d.category_parent=c.category_id
							inner join category b on c.category_parent=b.category_id
						where 
							b.category_parent='.$tree_parent.'
					union
						select 
							e.category_id
						from
							category e
							inner join category d on e.category_parent=d.category_id
							inner join category c on d.category_parent=c.category_id
							inner join category b on c.category_parent=b.category_id
						where 
							b.category_parent='.$tree_parent.'
				)
			order by
				oc.category_order
		';
		return $sql;
	}

	
	


}
?>