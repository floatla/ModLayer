<?php
Class ElementCollection extends Collection
{

	protected $structure;
	protected $dbtable;
	protected $params = array();
	protected $customField = 'custom_data'; // name of encasulapted field

	public function __construct($params)
	{
		parent::__construct($params);
		$this->structure = ElementModel::$tables;
		$this->dbtable   = ElementModel::$table;
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
		/* Campos para busquedas */
		$this->setSearchFields(
			array(
				'title', 
				'summary', 
				'content', 
				'custom_data'
			)
		);

		/* Primary Key de la tabla */
		$this->setPrimaryKey('item_id');

		/* Estado de la tabla */
		$this->setStateField('state');

		/* Campo para ordenar */
		$this->setParam('sort', 'created_at');

		/* Traer datos de usuarios */
		$this->setParam('metadata', true);

		/* Campo para rango de fecha : inicio / fin */
		$this->setDateFields('created_at', 'created_at');

		/* Agregar filtro en todas las queries */
		$this->addQueryFilter($this->dbtable . '.module = :module', ':module', $this->params['module'], 'string');

		/* Campos que se piden en todas las queries */
		$this->setFields(array('*', '(
			select
				o.title
			from
				'.$this->dbtable .' o
			where
				o.item_id = '.$this->dbtable.'.parent_id
			) as parent_title,
			(
			select
				o.module
			from
				'.$this->dbtable.' o
			where
				o.item_id = '.$this->dbtable.'.parent_id
			) as parent_module
		'));
	}

	/**
	*	applyFormat parsea el listado de elementos obtenidos de una query
	*	y aplica el formato segun el modelo del modulo
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
					$reflection->getStaticPropertyValue('objectFields'),
					$verbose=true
				)
			);
		}
		
		array_walk($this->list, function(&$value, $key){
			if(isset($value[$this->customField]))
			{
				$customFields = unserialize($value[$this->customField]);
				unset($value[$this->customField]);
				if(is_array($customFields))
					$value = array_merge($value, $customFields);
			}
		});
	}

	/**
	*	CollectioConf retorna la configuracion del 
	*	modulo que está manejando el listado
	*	@return DOMElement object
	*/
	private function CollectionConf()
	{
		$module  = $this->params['module'];
		return Configuration::Query("/configuration/modules/module[@name = '". $module ."']")->item(0);
	}


	/**
	*	hasChildren busca en la configuracion del modulo (que se esta visualizando) 
	*	si tiene que buscar elementos hijos
	*	@return bool (false por default) / array con el listado si hay datos
	*/
	public function hasChildren($id, $state)
	{
		$conf   = $this->CollectionConf();
		$option = Configuration::Query("/module/options/group[@name='element_child']/option", $conf);

		if($option)
		{
			$contentList = array('tag' => 'collection');

			foreach($option as $childConf)
			{
				$thisMod  = $childConf->getAttribute('name');

				$this->setParam('module', $thisMod);

				$t  = new $thisMod();
				$tc = $t->collection();
				$tc->setParam('pageSize', $childConf->getAttribute('pageSize'));

				$tempData = $tc->GetChildren($id, $state);
				
				$tempData['name-att'] = $childConf->getAttribute('name');
				$tempData['label-att'] = $childConf->getAttribute('label');
				$contentList[] = $tempData;
			}
			return $contentList;
		}
		return false;
	}

	/**
	*	GetChildren retorna los registros con el parent_id = al id recibido por parametro
	*	@return bool (false por default) / array con el listado si hay datos
	*/
	public function GetChildren($id, $state)
	{
		$module = $this->params['module'];
		$this->addQueryFilter($this->dbtable . '.module = :module', ':module', $module, 'string');
		$this->addQueryFilter($this->dbtable . '.parent_id = :parent_id', ':parent_id', $id, 'int');

		if($state) {
			$list  = array_filter(explode(',', $state), 'ctype_digit'); // only numbers
			$stateStr = implode(',', $list);
			$this->addQueryFilter($this->dbtable . '.state in (' .$stateStr. ')', '', '', 'string');
		}
		return $this->Get();
	}

	/**
	*	Trash sobreescribe el metodo de Collection para realizar un borrado logico
	*	@return boolean
	*/
	public function Trash($ids)
	{
		$query = new Query();

		$sql2 = 'UPDATE '.$this->dbtable.' SET parent_id = 0 WHERE parent_id in ('.$ids.')';
		$query->execute($sql2);

		// $sql = 'INSERT INTO object_deleted (SELECT * FROM object where object_id in ('.$ids.'))';
		// $query->execute($sql);

		parent::Trash($ids);
	}

	/**
	*	CategoryFilters sobreescribe el metodo de collection para
	*	agregar los estados definidos en element (para los modulos que extienden de element)
	*	@return void
	*/
	public function CategoryFilters($module=false)
	{
		$response = parent::CategoryFilters($module);

		$conf     = Configuration::GetModuleConfiguration('element');
		$states   = Configuration::Query("/module/options/group[@name='item-states']/option", $conf);

		if($states)
		{
			$sList = [];
			foreach($states as $state)
			{
				$temp = array(
					'label' => $state->getAttribute('label'),
					'value' => $state->getAttribute('value'),
					'published' => $state->getAttribute('published'),
				);
				array_push($sList, $temp);
			}
			$sList['tag'] = 'state';
			$response['states'] = $sList;
		}

		return $response;
	}


	
}
?>