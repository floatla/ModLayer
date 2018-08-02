<?php
Class FileCollection extends Collection
{
	protected $structure;
	protected $dbtable;
	protected $relationTable;
	protected $params = array();
	protected $customField = 'custom_data'; 	// name of encasulapted field

	public function __construct($params)
	{
		parent::__construct($params);
		$this->structure = MultimediaModel::$tables;
		$this->dbtable   = MultimediaModel::$table;
		$this->relationTable = MultimediaModel::$RelationTable;
		$this->setModuleVars();
		// $this->setParam('debug', true);
	}

	/**
	*	setModuleVars inicializa variables y parametros para las queries
	*	campos para queries y busqueda
	*	@return void
	*/
	private function setModuleVars()
	{
		$searchFields = array('multimedia_title', 'multimedia_content', 'custom_data');
		/* Campos para busquedas */
		$this->setSearchFields(
			array(
				'multimedia_title', 
				'multimedia_content', 
				'custom_data'
			)
		);

		/* Primary Key de la tabla */
		$this->setPrimaryKey('multimedia_id');

		/* Campo para ordenar */
		$this->setParam('sort', 'created_at');

		/* Traer datos de usuarios */
		$this->setParam('metadata', true);

		/* Campo para rango de fecha : inicio / fin */
		$this->setDateFields('created_at', 'created_at');

		/* Agregar filtro en todas las queries */
		$this->addQueryFilter('multimedia.multimedia_typeid = :typeid', ':typeid', $this->params['type_id'], 'int');

	}

	private function CollectionConf()
	{
		$type_id  = $this->params['type_id'];
		return Configuration::Query("/configuration/modules/module[@multimedia_typeid = '". $type_id ."']")->item(0);
	}

	/**
	*	applyFormat aplica el formato del modelo a los items
	*	Segun parametrizacion de la clase
	*	@return void
	*/
	public function applyFormat()
	{
		if($this->params['applyFormat'])
		{
			$conf = $this->CollectionConf();
			$reflection = new ReflectionClass($conf->getAttribute('model'));

			$this->list = call_user_func_array(
				array(
					'Model', 
					'parseFieldsFromObjects'
				), 
				array(
					$this->list,
					$reflection->getStaticPropertyValue('table'),
					$reflection->getStaticPropertyValue('tables'),
					$reflection->getStaticPropertyValue('multimediaFields'),
					$verbose=true
				)
			);
			// $this->collectionInfo();
		}
		
		array_walk($this->list, function(&$value, $key){
			if(isset($value[$this->customField]) && !empty($value[$this->customField]))
			{
				$customFields = unserialize($value[$this->customField]);
				unset($value[$this->customField]);
				$value = array_merge($value, $customFields);
			}
		});
	}


	/**
	*	Trash realiza un borrado logico de elementos
	*	@return true datatype boolean
	*/
	public function Trash($ids)
	{
		$sql   = 'SELECT * FROM multimedia where multimedia_id in ('.$ids.')';
		$query = new Query();
		$resp  = $query->run($sql);

		$this->list = (isset($resp[0])) ? $resp : false;

		$sql   = 'DELETE from '.$this->relationTable.' where multimedia_id in ('.$ids.')';
		$query->execute($sql);

		$this->DeleteFiles();
		parent::Trash($ids);
	}

	private function DeleteFiles()
	{

		if($this->list)
		{
			/* Ruta del archivo segun configuracion y ID */
	        $options = array(
				'module'       => $this->params['module'],
				'folderoption' => 'target',
			);

			$path   = PathManager::GetContentTargetPath($options);
			
			foreach ($this->list as $key => $item)
			{
				$folder = PathManager::GetDirectoryFromId($path, $item['multimedia_id']);
				$file   = Util::DirectorySeparator($folder.'/'.$item['multimedia_id'].'.'.$item['multimedia_source']);
		        unlink($file);	
			}
			
		}
	}

	public function setUser($userId)
	{
		/* Agregar filtro en todas las queries */
		$this->addQueryFilter('multimedia.creation_userid = :userid', ':userid', $userId, 'int');
		$this->addQueryFilter('multimedia.creation_usertype = :usertype', ':usertype', 'frontend', 'string');
	}
}
?>