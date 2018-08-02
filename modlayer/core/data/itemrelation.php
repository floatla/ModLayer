<?php
Class ItemRelation
{

	private $params = array();
	private $dbtable;
	private $ordeby;
	private $direction;


	public function __construct($params = false)
	{
		$this->params = array(
			'debug'					=> false,
			'relationMultimedias'	=> false,
			'relationCategories'	=> false,
			'module'                => false,
		);
		if(empty($params)) $params = array();

		$this->params = Util::extend(
			$this->params,
			$params
		);

		$this->dbtable   = 'module_relation';
		$this->sortField = 'relation_order';
		$this->order     = 'ASC';
	}

	/**
	*	Get retorna las relaciones para un item según la configuración del 
	*	módulo al que pertenece. Agrupando los distintos tipos.
	*	@return array $items
	*/
	public function Get($id, $modConf)
	{

		$options = Configuration::Query("/module/options/group[@name='relations']/option", $modConf);
		$name    = Configuration::Query("@name", $modConf);


		$types      = array();
		if ($options){
			foreach($options as $relationType)
			{
				$relationConf = Configuration::GetModuleConfiguration($relationType->getAttribute('name'));
				if(!$relationConf){
					$msg =  "El modulo <b><i>" . $name->item(0)->nodeValue . '</i></b>';
					$msg .= " tiene configurado una relación con <b><i>" . $relationType->getAttribute('name'). '</i></b>';
					$msg .= " que no está disponible. <br/> Verificar la configuración del módulo <b><i>" . $name->item(0)->nodeValue . "</i></b>";
					throw new Exception($msg, 1);
				}

				$type_id = $relationType->getAttribute('type_id');
				$parent  = $relationConf->getAttribute('parent_name');
				$tag     = $relationConf->getAttribute('name');
				$types[$tag] = array(
					'parent'	=> $parent,
					'tag'		=> $tag
				);
			}

			$query = new Query();

			$query->fields(array('*'));
			$query->table($this->dbtable . ' as obr');

			$query->filter('(obr.object_id = :id and obr.object_module = :module) OR (obr.relation_id = :id and obr.relation_module = :module)');
			$query->param(':id', $id, 'int');
			$query->param(':module', $name->item(0)->nodeValue, 'string');
			$query->orderby($this->sortField);
			$query->order($this->order);
			
			if($this->params['debug']) {
				$query->debug();
				$query->debugSQL();
			}

			$Items = $query->select();
		
			if($Items)
			{
				$relations = array();
				$colector  = array();
				foreach($Items as $relation)
				{
					$module  = ($relation['object_id'] == $id && $relation['object_module'] == $name->item(0)->nodeValue) 
						? $relation['relation_module'] 
						: $relation['object_module'];

					$item = array(
						'item_id' => ($relation['object_id'] == $id) 
										? $relation['relation_id'] 
										: $relation['object_id'],
						'order'   => ($relation['object_id'] == $id) 
										? $relation['object_order'] 
										: $relation['relation_order'],
						'date'    => $relation['relation_date'],
						'rel_id'  => $relation['rel_id'],
					);

					if(empty($colector[$module]))
						$colector[$module] = array();
					
					$colector[$module][$item['item_id']] = $item;
				}

				foreach($colector as $module => $relation)
				{
					if(!empty($types[$module]))
					{
						$ids = implode(',',array_keys($relation));
						$obj = new $module();
						$collection = $obj->Collection();

						if (!method_exists($collection, 'ListRelations'))
						{
							throw new Exception("El modulo $module no tiene definido el metodo ListRelations para obtener relaciones.", 1);
							die;
						}

						/*
							ListRelations
						*/
						$list = $collection->ListRelations($ids, $relation);

						$parent   = $types[$module]['parent'];
						$tag      = $types[$module]['tag'];

						$relations[$parent] = $list;
						$relations[$parent]['tag'] = $tag;
					}
				}

				// Util::debug($relations);
				// die;
				return $relations;
			}
		}
		return false;
	}

	/**
	*	Get retorna las relaciones para un item según la configuración del 
	*	módulo al que pertenece. Agrupando los distintos tipos.
	*	@return array $items
	*/
	public function GetByType($id, $module, $relation_module)
	{
		$query = new Query();

		$query->fields(
			array(
				'(
				SELECT CASE
					WHEN obr.object_id = :id THEN obr.relation_id
					ELSE obr.object_id
				END
				) as "id",
				(
				SELECT CASE
					WHEN obr.object_id = :id THEN obr.object_order
					ELSE obr.relation_order
				END
				) as "order",
				(
				SELECT CASE
					WHEN obr.object_id = :id THEN obr.relation_module
					ELSE obr.object_module
				END
				) as "module",
				obr.*'
			)
		);
		$query->table($this->dbtable. ' obr');
		$query->filter('(obr.object_id = :id AND obr.object_module = :module AND obr.relation_module = :relation_module) OR (obr.relation_id = :id AND obr.relation_module = :module AND obr.object_module = :relation_module)');
		$query->param(':id', $id, 'int');
		$query->param(':module', $module, 'string');
		$query->param(':relation_module', $relation_module, 'string');
		$query->orderby($this->sortField);
		$query->order($this->order);
		
		if($this->params['debug'])
		{
			$query->debug();
			$query->debugSQL();
		}

		$items = $query->select();

		$relations = array();
		if($items)
		{
			$colector  = array();
			foreach($items as $relation)
			{
				$module  = $relation['module'];
				$item = array(
					'item_id' => $relation['id'],
					'order'   => $relation['order'],
					'date'    => $relation['relation_date'],
					'rel_id'  => $relation['rel_id'],
				);

				if(empty($colector[$module]))
					$colector[$module] = array();
				
				$colector[$module][$item['item_id']] = $item;
			}

			foreach($colector as $module => $relation)
			{
				$ids = implode(',',array_keys($relation));

				$obj = new $module();
				$collection = $obj->collection();

				if (!method_exists($collection, 'ListRelations'))
				{
					throw new Exception("El módulo $module no tiene definido el método ListRelations para Listar relaciones.", 1);
					die;
				}

				/*
					El módulo que se pretende instanciar
					debe tener el método ListRelations al cual se piden los elementos
				*/
				$list = $collection->ListRelations($ids, $relation);

				foreach($list as $key=>$item)
				{
					if(is_numeric($key))
						unset($list[$key]['content-xml']);
				}

				$relations = $list;
				$relations['tag'] = 'object';
			}

			return $relations;
		}
		
		return false;
	}

	/**
	*	SetByGroup setea relaciones a un elemento
	*	@return void
	*/
	public function Set($item_id, $item_module, $relation, $relation_module)
	{
		// Sentencia
		$sql = 'INSERT INTO '. $this->dbtable .' (object_id, object_module, relation_id, relation_module, relation_date) VALUES ';

		// Iteramos las relaciones
		if(is_array($relation))
		{
			foreach($relation as $element)
			{
				// $relation_module = parent::getmodule($element);
				$sql .= '(' . $item_id . ', "' . $item_module. '", ' . $element. ', "' . $relation_module. '", "' . date('Y-m-d H:i:s') . '"), ';
			}
			$sql = rtrim($sql, ', ');
		}
		else
		{
			$sql .= '(' . $item_id . ', "' . $item_module. '", ' . $relation. ', "' . $relation_module. '", "' . date('Y-m-d H:i:s') . '")';
		}
		
		$query = new Query();
		$query->execute($sql);
	

		// Actualizamos el estado del elemento relacionado
		$tmp  = new $item_module();
		$item = $tmp->item($item_id);
		$item->touch();
	}

	/**
	*	Unlink elimina relaciones de un item_id
	*	@param $id : id del item
	*	@param $module : módulo del item
	*	@param $relation_id : id de la relación para eliminar solo un registro
	*	@return void
	*/
	public function unlink($id, $module, $relation_id=false)
	{
		$query = new Query();
		$query->table($this->dbtable);

		if($relation_id) {
			$query->filter('(object_id = :id AND object_module = :module AND relation_id = :relation_id)');
			$query->filter('(object_id = :relation_id AND relation_module = :module AND relation_id = :id)');
			$query->param(':id', $id, 'int');
			$query->param(':module', $module, 'string');
			$query->param(':relation_id', $relation_id, 'int');
		}
		else
		{
			$query->filter('(object_id = :id AND object_module = :module)');
			$query->filter('(relation_id = :id AND relation_module = :module)');
			$query->param(':id', $id, 'int');
			$query->param(':module', $module, 'string');	
		}
		$query->exclusive(false);

		if($this->params['debug']){
			$query->debug();
			$query->debugSQL();
		}

		$query->delete();

	}

	/**
	*	unlinkCollection elimina relaciones de multimedias con items de un listado
	*	@return void
	*/
	public function unlinkCollection($ids, $module)
	{
		$query = new Query();
		$query->table($this->dbtable);

		$query->filter('(object_id in ('.$ids.') AND object_module = :module)');
		$query->filter('(relation_id in ('.$ids.') AND relation_module = :module)');
		$query->param(':module', $module, 'string');	

		$query->exclusive(false);

		if($this->params['debug']){
			$query->debug();
			$query->debugSQL();
		}
		return $query->delete();
	}

	/**
	*	SetOrder setea el orden de las relaciones en un item
	*	@return void
	*/
	public function SetOrder($id, $module, $order)
	{
		$ids = implode(',', $order);

		$sql = '
		UPDATE 
			' . $this->dbtable . '
		SET 
			object_order = CASE relation_id 
		';
		foreach($order as $pos => $item_id) {
			$sql .= 'WHEN ' . $item_id . ' THEN ' . $pos . " ";
		}

		$sql .= '
			END,
			relation_order = CASE object_id
		';

		foreach($order as $pos => $item_id){
			$sql .= 'WHEN ' . $item_id . ' THEN ' . $pos . ' ';
		}

		$sql .= '
			END
		WHERE 
			(object_id = '.$id.' AND object_module = "'.$module.'")
			OR
			(relation_id = '.$id.' AND relation_module = "'.$module.'")
		';

		$bindParams = array(
			array(
				'name' => ':id',
				'value' => $id,
			),
			array(
				'name' => ':module',
				'value' => $module,
			),
		);
		// Util::debug($sql);
		// Util::debug($bindParams);
		// die;
		$query = new Query();
		$query->execute($sql, $bindParams);

		return true;
	}


}
?>