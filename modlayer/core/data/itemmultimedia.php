<?php
Class ItemMultimedia
{
	// private $params = array(); // Class params
	private $dbtable;

	public function __construct($params = false)
	{
		$this->params = array(
			'debug'			=> false,
			'onePerItem'	=> false,
			'module'	    => false,
			'applyFormat'   => true,
		);
		if(empty($params)) $params = array();

		$this->params = Util::extend(
			$this->params,
			$params
		);

		$this->dbtable = MultimediaModel::$RelationTable;

	}

	/**
	*	prepareQuery instancia un objeto query y setea los parámetros
	*	para la consulta
	*	@return Query
	*/
	private function prepareQuery()
	{
		// Util::debug($this->params);
		// $x = debug_backtrace();
		// $arr = array();
		// foreach($x as $line)
		// {
		// 	$arr[] = array(
		// 		'file' => $line['file'],
		// 		'function' => $line['function'],
		// 	);
		// }
		// Util::debug($arr);
		// // die;
		if($this->params['module'] === false){
			throw new Exception("No se recibió el parámetro módulo para pedir multimedias.", 1);
		}

		$fields = array(
					'mo.rel_id',
					'mo.object_id',
					'mo.relation_order',
					'm.*',
				);

		$query = new Query();
		$query->fields($fields);
		$query->table( $this->dbtable . ' as mo
			inner join multimedia m on m.multimedia_id = mo.multimedia_id 
		');
		$query->orderby('mo.relation_order');
		$query->order('ASC');

		$query->filter('mo.module = :module');
		$query->param(':module', $this->params['module'], 'string');

		if($this->params['debug'])
		{
			$query->debug();
			$query->debugSQL();
		}
		return $query;
	}

	/**
	*	Get obtiene los multimedias de un item y los ordena en un array por tipo
	*	@return void
	*/
	public function Get($id, $moduleConf)
	{
		$options = Configuration::Query("/module/options/group[@name='multimedias']/option", $moduleConf);
		$name    = Configuration::Query("@name", $moduleConf);

		if(!$options) return false;

		$types   = array();
		foreach($options as $type)
		{
			$multimediaConf = Configuration::GetModuleConfiguration($type->getAttribute('name'));
			if(!$multimediaConf){
				$msg =  "El módulo <b><i>" . $name->item(0)->nodeValue . '</i></b>';
				$msg .= " tiene configurado el multimedia <b><i>" . $type->getAttribute('name'). '</i></b>';
				$msg .= " que no está disponible. <br/> Verificar la configuración del módulo <b><i>" . $name->item(0)->nodeValue . "</i></b>";
				throw new Exception($msg, 1);
			}

			$type_id = $multimediaConf->getAttribute('multimedia_typeid');
			$parent  = $multimediaConf->getAttribute('parent_name');
			$tag     = $multimediaConf->getAttribute('name');
			$model   = $multimediaConf->getAttribute('model');
			$types[$type_id] = array(
				'model'		=> $model,
				'parent'	=> $parent,
				'tag'		=> $tag
			);
		}


		$query = $this->prepareQuery();

		$query->filter('mo.object_id = :id');
		$query->param(':id', $id, 'int');
		
		
		$Items = $query->select();

		
		if($Items)
		{
			/*
				Agrupamos los multimedias por tipo para mantener 
				el formato de siempre en los xmls
			*/
			$multimedias = array();

			foreach($Items as $RawItem)
			{
				$type_id  = $RawItem['multimedia_typeid'];
				if(isset($types[$type_id]))
				{
					$parent     = $types[$type_id]['parent'];
					$tag        = $types[$type_id]['tag'];
					$model      = $types[$type_id]['model'];

					$multimedia = $RawItem;
					$custom     = unserialize($multimedia['custom_data']);
					if($custom)
						$multimedia = array_merge($multimedia, $custom);
					unset($multimedia['custom_data']);
					unset($multimedia['object_id']);

					$multimedias[$parent][] = $multimedia;
					$multimedias[$parent]['tag'] = $tag;
				}
			}

			/*
				Si se pide se aplica el formato para XML
			*/
			if($this->params['applyFormat'])
			{
				// Util::debug($multimedias);
				$formated = array();
				foreach($multimedias as $parent=>$array)
				{
					$thisTag = $array['tag'];
					unset($array['tag']);

					// Util::debug($types);
					// Util::debug($parent);
					foreach($types as $type)
					{
						if($type['parent'] == $parent){
							$model = $type['model'];
						}
					}

					$reflection = new ReflectionClass($model);
					

					$array = call_user_func_array(
						array(
							'Model', 
							'parseFieldsFromObjects'), 
						array(
							$array,
							$reflection->getStaticPropertyValue('table'),
							$reflection->getStaticPropertyValue('tables'), 
							$reflection->getStaticPropertyValue('multimediaFields')
						)
					);
					$formated[$parent] = $array;
					$formated[$parent]['tag'] = $thisTag;
					$formated[$parent]['data-type-att'] = 'list';
				}
				// Util::debug($formated);
				// die;
				return $formated;
			}
			// Util::debug($multimedias);
			// die;
			return $multimedias;
		}
		return false;
	}


	/**
	*	GetByGroup obtiene las imágenes solamente de items en un listado 
	*	@return void
	*/
	public function GetByGroup($ids)
	{
		if(!empty($ids))
		{
			$query = $this->prepareQuery();
			$query->fields(array('mo.object_id'));
			$query->filter('mo.object_id in (' . $ids . ')');
			$query->filter('mo.multimedia_typeid = 1');

			$response = $query->select();

			/*
				La query trae todas las imágenes de cada item ordenadas.
				Si piden una sola imagen, acotamos el array a una por item
			*/
			if($this->params['onePerItem'] !== false)
			{
				$result  = array(); $last_id = 0;
				foreach($response as $image)
				{
					if($image['object_id'] != $last_id)
					{
						$result[] = $image;
						$last_id  = $image['object_id'];
					}
				}
				$response = $result;
			}
			return $response;
		}
		return false;
	}

	/**
	*	GetbyType obtiene los multimedias de un item por tipo
	*	@return void
	*/
	public function GetbyType($id, $multimedia_typeid)
	{
		$query = $this->prepareQuery();

		$query->filter('mo.object_id = :id');
		$query->param(':id', $id, 'int');

		$query->filter('mo.multimedia_typeid = :type_id');
		$query->param(':type_id', $multimedia_typeid, 'int');
		
		// $query->debug();
		// $query->debugSQL();

		return $query->select();

	}

	/**
	*	Set relaciona un multimedia con un item
	*	@return void
	*/
	public function Set($id, $multimedia_id, $module=false)
	{
		$multimedia = new Multimedia();
		$type_id    = $multimedia->gettype($multimedia_id);

		if(!$module)
			$module = parent::getmodule($id);

		$fields = array(
			'object_id'     => $id,
			'multimedia_id' => $multimedia_id,
			'module'        => $module,
			'multimedia_typeid' => $type_id
		);

		$query = new Query(
			array(
				'table'  => $this->dbtable,
				'fields' => $fields
			)
		);
		return $query->insert();

	}

	/**
	*	unlink relaciona un multimedia con un item
	*	@return void
	*/
	public function unlink($item_id, $module, $multimedia_id=false)
	{
		$query = new Query();
		$query->table($this->dbtable);
		$query->filter('object_id = :id');
		$query->filter('module = :module');
		$query->param(':id', $item_id, 'int');
		$query->param(':module', $module, 'string');
		
		if($multimedia_id){
			$query->filter('multimedia_id = :multimedia_id');
			$query->param(':multimedia_id', $multimedia_id, 'int');
		}

		// $query->debug();
		// $query->debugSQL();
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
		$query->filter('object_id in ('.$ids.')');
		$query->filter('module = :module');
		$query->param(':module', $module, 'string');

		return $query->delete();
	}

	/**
	*	UnlinkMultimedia elimina todas las relaciones de un multimedia_id.
	*	Se utiliza cuando se elimina una imagen.
	*	@return void
	*/
	public function UnlinkMultimedia($multimedia_id)
	{
		$query = new Query();
		$query->table($this->dbtable);
		
		$query->filter('multimedia_id = :multimedia_id');
		$query->param(':multimedia_id', $multimedia_id, 'int');

		return $query->delete();
	}

	/**
	*	SetOrder cambia el orden de los multimedias en un item
	*	@param $item_id : id del item
	*	@param $order : array de ids de los multimedias. El índice del array es el orden de cada uno
	*	@return void
	*/
	public function SetOrder($item_id, $order)
	{	
		$ids = implode(',', $order);
		$sql = 'UPDATE ' . $this->dbtable . ' SET relation_order = CASE multimedia_id ';
		foreach($order as $order => $multimedia_id)
		{
			$sql .= 'WHEN ' . $multimedia_id . ' THEN ' . $order . ' ';
		}
		$sql .= 'END ';
		$sql .= 'WHERE multimedia_id in ('.$ids.') AND object_id = ' . $item_id;

		$query = new Query();
		$query->execute($sql);

		return true;

	}

	/**
	*	SetByGroup setea varios multimedias a un item
	*	@return void
	*/
	public function SetGroup($item_id, $multimedias, $module, $multimedia_typeid)
	{
		// Sentencia
		$sql = 'INSERT INTO '. $this->dbtable .' (object_id, multimedia_id, module, multimedia_typeid) VALUES ';
		
		// Iteramos las categorías
		foreach($multimedias as $multimedia_id)
		{
			$sql .= "(".$item_id.", ".$multimedia_id.", '".$module."', ".$multimedia_typeid."), ";
		}
		$sql = rtrim($sql, ', ');

		$query = new Query();
		$query->execute($sql);

	}


	public function FetchRecords($id)
	{
		$query = new Query();
		$query->table($this->dbtable);
		$query->filter('multimedia_id = :id');
		$query->param(':id', $id, 'int');

		$r = $query->select();
		return (isset($r[0])) ? $r : false;
	}
}
?>