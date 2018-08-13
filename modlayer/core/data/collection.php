<?php

/**
 * Collection
 * @author Bernardo Claudio Romano Cherñac <cromano@float.la>
 */
Abstract Class Collection {

	protected $structure;
	protected $dbtable;
	protected $params         = array();
	protected $tag;
	protected $list;
	protected $primaryKey     = 'id';
	protected $fields         = array('*');
	protected $searchFields   = array();
	protected $rangeStart     = 'date_from';
	protected $rangeEnd       = 'date_to';
	protected $excludeFields  = array('content');
	protected $queryCollector = array();
	protected $pageSize       = 10;
	protected $sort           = false;
	protected $order          = false;
	protected $tableFilters   = '';
	public    $stateField     = false;
	public    $cacheTTL       = 3600*12;

	/**
	 * __construct Constructor de la clase Collection
	 * @param $params
	 */
	public function __construct($params) {

		$filters = $this->Filters();
		$this->params = array(
			'currentPage'	=> $filters['currentPage'],
			'pageSize'		=> $filters['pageSize'],
			'sort'          => $filters['sort'],
			'order'         => $filters['order'],
			'startdate'     => $filters['startdate'],
			'enddate'       => $filters['enddate'],
			'state'         => $filters['state'],
			'metadata'		=> false,
			'fields'		=> false,
			'setSession'    => true,
			'query'         => $filters['query'],
			'inCategory'    => $filters['categories'],
			'inTag'			=> $filters['tags'],
			'getCategories' => true,
			'getTags'       => false,
			'getImages'     => true,
			'applyFormat'   => true,
			'internalCall'	=> false,
			'debug'         => false,
			'count'         => true,
		);

		if(empty($params)) $params = array();

		$this->params = Util::extend(
			$this->params,
			$params
		);
	}

	/**
	*	getFilters permite obtener desde afuera los parámetros obtenidos
	*	y validados para utilizar en otras clases
	*	@return array
	*/
	public function getFilters()
	{
		return $this->filters;
	}

	/**
	*	setPrimaryKey define el nombre del primary key de la tabla
	*	@param $key
	*	@return void
	*/
	public function setPrimaryKey($key)
	{
		$this->primaryKey = $key;
	}

	/**
	*	getPrimaryKey retorna el primary key de la tabla
	*	@return $key
	*/
	public function getPrimaryKey()
	{
		return $this->primaryKey;
	}

	/**
	*	setFields define los campos de la tabla en una query
	*	@param $fields
	*	@return void
	*/
	public function setFields($fields)
	{
		$this->fields = $fields;
	}

	/**
	*	setSearchFields define los campos de la tabla en una query
	*	@param $fields
	*	@return void
	*/
	public function setSearchFields($fields)
	{
		$this->searchFields = $fields;
	}

	/**
	*	setExcludeFields define los campos de la tabla en una query
	*	@param $fields
	*	@return void
	*/
	public function setExcludeFields($fields)
	{
		$this->excludeFields = $fields;
	}

	/**
	*	setStateField define el campo estado del registro
	*	@param $name
	*	@return void
	*/
	public function setStateField($name)
	{
		$this->stateField = $name;
	}

	/**
	*	setFilter setea el nombre de los campos para rangos de fecha
	*	@param $start : string nombre del campo fecha de inicio
	*	@param $end : string nombre del campo fecha de fin
	*	@return void
	*/
	public function setDateFields($start, $end)
	{
		$this->rangeStart = $start;
		$this->rangeEnd   = $end;
	}

	/**
	 * addQueryFilter
	 * @param $pattern
	 * @param $param
	 * @param $value
	 * @param $type
	 * @return void
	 */
	public function addQueryFilter($pattern, $param, $value, $type)
	{
		$this->queryCollector[] = array(
			'pattern' => $pattern,
			'param'   => $param,
			'value'   => $value,
			'type'    => $type,
		);
	}

	/**
	*	setParam fuerza un parámetro en las
	*	opciones de la clase. Los parámetros se inicializan con la clase (vengan de afuera o no),
	*	Así aunque se defina un parámetro con este método justo despues de instanciar la clase
	*	se pisa de todas formas.
	*	@param $name
	*	@param $value
	*	@return void
	*/
	public function setParam($name, $value)
	{
		$this->params[$name] = $value;
	}

	/**
	*	applyFormat aplica el formato del modelo a los items
	*	Según parametrización de la clase
	*	@return void
	*/
	public function applyFormat()
	{
		if($this->params['applyFormat'])
			Model::FormatArray($this->list, $this->dbtable, $this->structure);
	}

	/**
	*	setSession guarda en session los datos de los filtros 
	*	para el módulo activo
	*	@return void
	*/
	private function setSession()
	{
		if($this->params['setSession'])
		{
			$session = array();
			$session['currentPage'] = $this->params['currentPage'];
			$session['pageSize']    = $this->params['pageSize'];
			$session['sort']        = $this->params['sort'];
			$session['order']       = $this->params['order'];
			$session['state']       = $this->params['state'];
			$session['startdate']   = $this->params['startdate'];
			$session['enddate']     = $this->params['enddate'];
			$session['categories']  = $this->params['inCategory'];

			Session::Set(Application::GetModule(), $session);
		}
	}

	/**
	*	Filters obtiene los valores (en caso que sean provistos) de los parámetros 
	*	para filtrar listados, sino setea valores por defecto.
	*	Los parámetros que se retornan son:
	*	@return array = (
	*		q 			: string para búsqueda
	*		currentPage : nro de página (paginado)
	*		pageSize 	: cantidad de items por página (paginado)
	*		state 		: estado del item (paginado)
	*		sort 		: filtro de ordenamiento 
	*		order 		: ASC / DESC orden del filtro de ordenamiento
	*		categories 	: filtrar por categorías
	*		startdate 	: inicio del rango de fechas
	*		enddate 	: fin del rango de fechas
	*	)
	*
	*/
	protected function Filters()
	{
		$query = Util::getvalue('q');
		$query = Encoding::toUTF8($query);

		// query, currentPage & state
		$this->filters = array(
			'currentPage' => (is_numeric(Util::getvalue('page'))) ? (int)Util::getvalue('page') : 1,
			'state'       => Util::getvalue('state'),
			'query'       => $query,
		);

		/*
			Estos tres parámetros los obtenemos de la session para mantener los valores
			por separado para cada módulo
		*/
		$moduleVar = (!Application::isFrontend()) ? Session::Get(Application::GetModule()) : false;

		$sort      = (isset($moduleVar['sort']))     ? $moduleVar['sort'] : $this->sort;
		$order     = (isset($moduleVar['order']))    ? $moduleVar['order'] : $this->order;
		$pageSize  = (isset($moduleVar['pageSize'])) ? $moduleVar['pageSize'] : $this->pageSize;

		// pageSize
		$this->filters['pageSize'] = Util::getvalue('pageSize', $pageSize);
		if(!is_numeric($this->filters['pageSize'])) $this->filters['pageSize'] = $this->pageSize;

		// Ordenar
		$sortParam = Util::getvalue('sort', $sort);
		switch($sortParam)
		{
			case "title":
				$sortParam = "title";
				break;
			case "id":
				$sortParam = "id";
				break;
			case "date":
			case $this->rangeStart:
				$sortParam = $this->rangeStart;
				break;
			default:
				$sortParam = $this->rangeStart;
				break;
		}
		$this->filters['sort'] = $sortParam;

		$orderParam = Util::getvalue('order', $order);
		$this->filters['order'] = ($orderParam == 'asc') ? 'asc' : 'desc';

		// categories
		$categories  = Util::getvalue('categories');

		if(is_array($categories))
		{
			array_walk($categories, 
				function(&$value, $key){
					$value = (is_numeric($value)) ? (int)$value : '';
				}
			);
			$categoryFilter = implode(',', array_filter($categories));
		}
		if(is_string($categories) || !$categories)
		{
			$categoryFilter = $categories;
		}
		$this->filters['categories'] = $categoryFilter;

		// Filtro de Fechas 
		$this->filters['startdate']  = false;
		$this->filters['enddate']    = false;

		$start     = Util::getvalue('startdate');
		$end       = Util::getvalue('enddate');
		$startdate = DateTime::createFromFormat('Y-m-d', $start);
		$enddate   = DateTime::createFromFormat('Y-m-d', $end);

		// Solo se toma la fecha si esta correctamente formada
		if(gettype($startdate) == 'object')
			$this->filters['startdate'] = $start;

		if(gettype($enddate) == 'object')
			$this->filters['enddate'] = $end;

		// Tags
		$tags  = Util::getvalue('tags');
		if(is_array($tags))
		{
			array_walk($tags, function(&$value, $key){
					$value = (is_numeric($value)) ? (int)$value : '';
				}
			);
			$tagFilter = implode(',', array_filter($tags));
		}
		if(is_string($tags) || !$tags)
		{
			$tagFilter = $tags;
		}
		$this->filters['tags'] = $tagFilter;

		return $this->filters;
	}

	

	/**
	*	UserMetadata Agrega los datos del los usuarios para 
	*	cada item del listado
	*	@return void
	*/
	private function UserMetadata()
	{

		foreach($this->list as $key=>$element)
		{
			$created_by    = (isset($element['created_by'])) 
							? $element['created_by'] 
							: false;
							
			$created_type  = (isset($element['created_type'])) ? $element['created_type'] : 'backend';
			$published_by  = (isset($element['published_by'])) ? $element['published_by'] : '';

			if($created_by != 0 && ($created_type == 'backend' || $created_type == 'system'))
			{
				if($created_by == '-1'){
					$text = Configuration::Translate('system_wide/created_by_system');
					$this->list[$key]['createdby'] = $text;
				}
				else{
					$ownerUser = Admin::unpack($created_by);
					$this->list[$key]['createdby'] = $ownerUser['name'].' '.$ownerUser['lastname'];
				}
			}
			
			if($created_by != 0 && $created_type == 'frontend')
			{
				$user = new User($created_by);
                $ownerUser = $user->Get();
				$this->list[$key]['createdby'] = $ownerUser['first_name'].' '.$ownerUser['last_name'];
                $this->list[$key]['user'] = $ownerUser;
			}

			$updated_by   = $element['updated_by'];
			$updated_type = (isset($element['updated_type'])) ? $element['updated_type'] : 'backend';

			if($updated_by != 0 && $updated_type == 'backend')
			{
				$editedUser = Admin::unpack($updated_by);
				$this->list[$key]['modifiedby'] = $editedUser['name'].' '.$editedUser['lastname'];;
			}

			if(!empty($element['published_by']))
			{
				if($published_by != 0 && $published_by == '-1'){
					$text = Configuration::Translate('system_wide/published_by_system');
					$this->list[$key]['publishedby'] = $text;
				}

				if($published_by > 0) {
					$publishUser = Admin::unpack($element['published_by']);
					$this->list[$key]['publishedby'] = $publishUser['name'].' '.$publishUser['lastname'];;
				}
			}
		}
	}

	/**
	*	Get retorna los items de un listado 
	*	según los parámetros cargados previamente
	*	@return array
	*/
	public function Get()
	{
		$query = $this->prepareQuery();

		if(!empty($this->params['inCategory']))
			$this->FilterByCategories($query);

		if(!empty($this->params['inTag']))
			$this->FilterByTags($query);

		$this->QueryItems($query);

		return $this->list;
	}

	/**
	*	QueryItems realiza una query a la base, 
	*	con todos los filtros ya cargados
	*	@param $query : instancia de la clase Query
	*	@return void
	*/
	private function QueryItems(Query $query)
	{
		$query->table($this->dbtable .' as ' . $this->dbtable .' ' . $this->tableFilters);
		$this->list = $query->select();
		$size = 0;

		if($this->params['count']){
			$this->QueryTotal($query);
			$total = $query->select();
			$size  = $total[0]['total'];
		}

		if(!empty($this->list))
		{
			$this->Polish();
			if($this->params['metadata'] && !Application::isFrontend())
				$this->UserMetadata();

			$this->Categories();
			$this->Tags();
			$this->Images();
			$this->applyFormat();
			$this->setSession();
		}

		$this->list['name-att']        = $this->params['module'];
		$this->list['total-att']       = $size;
		$this->list['pageSize-att']    = $this->params['pageSize'];
		$this->list['currentPage-att'] = $this->params['currentPage'];
		$this->list['tag']             = $this->params['tag'];
	}

	public function QueryTotal(Query $query)
	{
		$query->fields(array('count(DISTINCT(' . $this->dbtable . '.' . $this->primaryKey . ')) as total'), $sum=false);
		$query->limit(-1);
	}

	/**
	*	Polish sirve para eliminar algunos campos específicos.
	*	Aunque se pueden definir que campos se desean pedir, a veces es mas fácil 
	*	no definir campos para pedir todos y solo excluir uno. Para eso sirve este método.
	*	La variable excludeFields es un array con los nombres de campos.
	*	@return void
	*/
	private function Polish()
	{
		if(!empty($this->excludeFields)) {
			foreach($this->excludeFields as $fieldName) {
				foreach($this->list as $key=>$item) {
					unset($this->list[$key][$fieldName]);
				}
			}
		}
	}

	/**
	*	QueryCategories setea el "table" del objeto query, 
	*	@param $query : Query object (instancia de la clase Query)
	*	@return Query object
	*/
	public function FilterByCategories(Query $query)
	{
		$catTbl = CategoryModel::$relationTable;
		$list   = explode(',', $this->params['inCategory']);
		$filter = '';
		for($i=0; $i<count($list); $i++)
		{
			$filter = 'EXISTS (select 1 from '.$catTbl.' AS cat'.$i;
			$filter .= ' WHERE '.$this->dbtable.'.'.$this->primaryKey.' = cat'.$i.'.item_id'; 
			$filter .= ' AND (cat'.$i.'.category_id = '.$list[$i].' OR cat'.$i.'.category_parentid = '.$list[$i].')';
			$filter .= ' AND cat'.$i.'.module = "' . $this->params['module'] . '")';
			$query->filter($filter);
		}

		// $this->tableFilters .= $filter;
		// $query->table($this->dbtable .' as ' . $this->dbtable .' ' . $filter);
		
		return $query;
	}

	/**
	*	QueryCategories realiza una query a la base, 
	*	con todos los filtros ya cargados pero sobre una (o un listado) de categorías
	*	@param $query : instancia de la clase Query
	*	@return Query
	*/
	public function FilterByTags(Query $query)
	{
		$tagTbl = TagModel::$relation;
		$list   = explode(',', $this->params['inTag']);
		$filter = '';
		for($i=0; $i<count($list); $i++)
		{
			$filter = 'EXISTS (select 1 from '.$tagTbl.' AS tag'.$i;
			$filter .= ' WHERE '.$this->dbtable.'.'.$this->primaryKey.' = tag'.$i.'.item_id'; 
			$filter .= ' AND tag'.$i.'.tag_id = '.$list[$i];
			$filter .= ' AND tag'.$i.'.module = "' . $this->params['module'] . '")';
			$query->filter($filter);
		}

		// for($i=0; $i<count($list); $i++)
		// {
		// 	$filter .= ' INNER JOIN '.$tagTbl.' AS tag'.$i.' ON '.$this->dbtable.'.'.$this->primaryKey.' = tag'.$i.'.item_id';
		// 	$filter .= ' AND tag'.$i.'.tag_id = '.$list[$i];
		// 	$filter .= ' AND tag'.$i.'.module = "' . $this->params['module'] . '"';
		// }
		// $this->tableFilters .= $filter;
		// $query->table($this->dbtable .' as ' . $this->dbtable .' ' . $filter);
		
		return $query;
	}


	/**
	*	prepareQuery inicializa una instancia de Query
	*	y setea los filtros según los datos colectados previamente
	*	@return $query objecto Query inicializado
	*/
	private function prepareQuery()
	{

		$query = new Query();
		$query->fields($this->fields);

		$query->limit(
			$this->params['pageSize'], 
			$this->params['currentPage']
		);
		$query->orderby(
			$this->params['sort']
		);
		$query->order(
			$this->params['order']
		);

		/* Agregar filtros */
		$this->injectQuery($query);

		if($this->params['startdate'])
		{
			$query->filter($this->rangeStart . ' >= :startdate');
			$query->param(':startdate', $this->params['startdate'] . ' 00:00:00', 'string');
		}

		if($this->params['enddate']){
			$query->filter($this->rangeEnd . ' <= :enddate');
			$query->param(':enddate', $this->params['enddate'] . ' 23:59:59', 'string');
		}

		if($this->params['state'] !== false)
		{
			$list  = array_filter(explode(',', $this->params['state']), 'ctype_digit'); // only numbers
			$stateStr = implode(',', $list); 
			if($stateStr != '')
				$query->filter($this->stateField . ' in ('.$stateStr.')');
		}

		if($this->params['debug'])
		{
			$query->debug();
			$query->debugSQL();
		}

		$query->exclusive(true);

		if($this->params['query'])
		{
			if(count($this->searchFields) == 0)
				throw new Exception("No se definieron campos para la busqueda", 1);

			array_walk($this->searchFields, function(&$value, $index){
				$value = $value . ' like :query';
			});
			$search = implode(' or ', $this->searchFields);

			$query->filter('(' . $search . ')'); // or TR.tag_name like :query
			$query->param(':query',  '%'.$this->params['query'].'%', 'string');

			// $tagTbl = TagModel::$relation;
			// $this->tableFilters .= ' LEFT JOIN ' . $tagTbl . ' TR ';
			// $this->tableFilters .= ' on (' . $this->dbtable . '.' . $this->primaryKey .' = TR.item_id AND TR.module = "' . $this->params['module'] . '")';
		}

		$query->table($this->dbtable);

		return $query;
	}

	/**
	*	injectQuery carga los elementos de la base con los ids cargados en el listado
	*	@param $query : Instancia de la clase Query
	*	@return void
	*/
	private function injectQuery(Query $query)
	{
		foreach($this->queryCollector as $i=>$filter){
			$query->filter($filter['pattern']);
			if(!empty($filter['param']) && !empty($filter['value']))
				$query->param($filter['param'], $filter['value'], $filter['type']);	
		}
	}

	/**
	*	QueryItems carga los elementos de la base con los ids cargados en el listado
	*	@param $array
	*	@return array
	*/
	public function	QueryList($array)
	{
		if(is_array($array))
		{
			$ids    = '';
			foreach($array as $key=>$id) {
				$ids .= $id . ', ';
			}
			$ids    = rtrim($ids, ', ');
		}
		else
		{
			$ids = $array;
		}
		$fields = array('*');

		// Si se piden algunos campos
		if($this->params['fields'])
		{
			array_walk($this->params['fields'], function(&$value, $key){
				$value = $this->dbtable . '.' . $value;
			});
			$fields = $this->params['fields'];	
		}

		$query = new Query();
		$query->table($this->dbtable);
		$query->fields($fields);
		$query->filter($this->primaryKey . ' in ('.$ids.')');

		$query->orderby(
			$this->params['sort']
		);
		$query->order(
			$this->params['order']
		);
		
		$this->list = $query->select();

		return $this->list;
	}

	/**
	*	CategoryFilters retorna un array con las categorías del módulo
	*	activo para filtrar un listado
	*	@param $module
	*	@return array
	*/
	public function CategoryFilters($module=false)
	{

		$mod      = ($module) ? $module : Application::GetModule();
		$response = array();
		$conf     = Configuration::GetModuleConfiguration($mod);
		$options  = Configuration::Query("/module/options/group[@name='categories']/option", $conf);

		if($options)
		{
			foreach($options as $confOpt)
			{
				$cat       = new Category();
				$parent_id = $confOpt->getAttribute('value');
				$catItem   = $cat->item($parent_id);
				$list      = $catItem->GetTree();
				$label     = $confOpt->getAttribute('label');
				$list['name-att'] = Configuration::EvalTranslate($confOpt->getAttribute('label'));
				array_push($response, $list);
			}
			$response['tag'] = 'group';
		}

		$states = Configuration::Query("/module/options/group[@name='item-states']/option", $conf);

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

	/**
	*	Categories obtiene las categorías de un listado
	*	y las agrega en cada elemento del listado
	*	@return void
	*/
	public function Categories()
	{
		if($this->params['getCategories'])
		{
			$ids = '';
			foreach($this->list as $key=>$item)
			{
				$ids .= $item[$this->primaryKey] . ', ';
			}
			$ids = rtrim($ids, ', ');

			$module = (isset($this->params['module'])) ? $this->params['module'] : Application::GetModule();
			$group = Configuration::QueryGroup('categories', $module);

			if($group){
				$groups = array();
				foreach($group as $option){
					if($option->getAttribute('type') == 'parent') {

						$itemCategory = new itemCategory($this->params);
						$categories   = $itemCategory->GetByGroup(
							$ids,
							$module,
							$option->getAttribute('value')
						);

						if($categories) {
						
							foreach($this->list as $key=>$item)
							{
								$group = array(
									'label-att' => $option->getAttribute('label'),
									'id-att'   => $option->getAttribute('value'),
									'tag'      => 'category',
								);
								foreach($categories as $category)
								{
									if($item[$this->primaryKey] == $category['item_id'])
									{
										array_push($group, $category);
									}
								}

								if($this->params['applyFormat'])
									Model::FormatArray($group, CategoryModel::$table, CategoryModel::$tables);

								$this->list[$key]['categories'][] = $group;
								$this->list[$key]['categories']['tag'] = 'group';
							}
						}
					}
				}
			}
		}
	}

	/**
	*	Tags obtiene los tags de items en un listado
	*	@return void
	*/
	public function Tags()
	{
		if($this->params['getTags'])
		{
			$ids = '';
			foreach($this->list as $key=>$item)
			{
				$ids .= $item[$this->primaryKey] . ', ';
			}
			$ids = rtrim($ids, ', ');

			$tag  = new tag();
			$tcol = $tag->Collection();

			$tags = $tcol->QueryIds($ids, $this->params['module']);

			if($tags)
			{
				
				foreach($this->list as $key=>$item)
				{
					$group = array('tag' => 'tag');
					foreach($tags as $tagValue)
					{
						if($item[$this->primaryKey] == $tagValue['item_id'])
						{
							$group[] = $tagValue;
						}
					}
					if($this->params['applyFormat'])
						Model::FormatArray($group, TagModel::$table, TagModel::$tables);
					$this->list[$key]['tags'] = $group;
				}
			}
		}
	}

	/**
	*	Images obtiene las imágenes de los items en un listado
	*	Solo se pide una imagen por item.
	*	@return void
	*/
	protected function Images()
	{
		if($this->params['getImages'])
		{
			$ids = '';
			foreach($this->list as $key=>$item)
			{
				$ids .= $item[$this->primaryKey] . ', ';
			}
			$ids = rtrim($ids, ', ');

			$itemMultimedia = new ItemMultimedia(
				array(
					'onePerItem' => 1, 
					'module'     => (isset($this->params['module'])) ? $this->params['module'] : Application::GetModule(),
				)
			);
			$multimedias = $itemMultimedia->GetByGroup($ids);

			foreach($this->list as $key=>$item)
			{
				$itemimages = array(); 
				foreach($multimedias as $image)
				{
					if($item[$this->primaryKey] == $image['object_id'])
					{
						unset($image['object_id']);
						$itemimages[] = $image;
					}
				}

				if($this->params['applyFormat'])
					$itemimages = Model::parseFieldsFromObjects($itemimages, ImageModel::$table, ImageModel::$tables, ImageModel::$multimediaFields);
				$this->list[$key]['multimedias']['images'] = $itemimages;
				$this->list[$key]['multimedias']['images']['tag'] = 'image';
			}
		}
	}

	/**
	*	Trash realiza un borrado lógico de elementos
	*	@return true datatype boolean
	*/
	public function Trash($ids)
	{

		/* Eliminar categorías */
		$ic = new ItemCategory();
		$ic->unlinkCollection($ids, $this->params['module']);

		/* Eliminar Multimedias */
		$im = new ItemMultimedia();
		$im->unlinkCollection($ids, $this->params['module']);

		/* Eliminar relaciones */
		$ir = new ItemRelation();
		$ir->unlinkCollection($ids, $this->params['module']);

		$query = $this->prepareQuery();

		/* Agregar filtro */
		$query->filter($this->primaryKey . ' in (' .$ids. ')');
		return $query->delete();
		
	}


	/**
	*	ListRelations es llamado desde ItemRelation para obtener un listado 
	*	de items en un conjunto de ids.
	*	@param $ids : string con los ids de los items solicitados
	*	@param $relation : array con los datos de cada relación con los datos: item_id, order, relation_date
	*	@return array
	*/
	public function ListRelations($ids, $relation=false)
	{
		$ids = explode(',', $ids);
		$this->QueryList($ids);

		foreach($this->list as $key=>$item)
		{
			if(is_numeric($key))
			{
				$im = new itemmultimedia($this->params);
				$this->list[$key]['multimedias'] = $im->Get(
					$item[$this->primaryKey], 
					Configuration::GetModuleConfiguration($this->params['module'])
				);

				$ic = new ItemCategory($this->params);
				$group = $ic->Get( $item[$this->primaryKey],  $this->params['module'] );
				// if($this->params['applyFormat'])
				// 	Model::FormatArray($group, CategoryModel::$table, CategoryModel::$tables);
				$this->list[$key]['categories'] = $group;

				if($relation && !empty($relation[$item[$this->primaryKey]])) {
					$this->list[$key]['relation_order'] = $relation[$item[$this->primaryKey]]['order'];
					$this->list[$key]['relation_date'] = $relation[$item[$this->primaryKey]]['date'];
					$this->list[$key]['rel_id'] = $relation[$item[$this->primaryKey]]['rel_id'];
				}
				unset($this->list[$key]['content-xml']);
				unset($this->list[$key]['content']);
			}
		}

		$this->applyFormat();
		return $this->list;
	}


	
	/**
	*	SetCategories implementa el método SetByGroup de la clase ItemCategory
	*	@param $items : array con los items id
	*	@param $categories : array con las categorías
	*	@return ItemCategory
	*/
	public function SetCategories(array $items, array $categories)
	{
		$ic = new ItemCategory($this->params);
		return $ic->SetByGroup($items, $categories, $this->params['module']);
	}


	/**
	*	touch modifica el estado de elementos en un listado
	*	es usado para relaciones, cuando se relacionan muchos items de una sola vez.
	*	Solo actualiza el estado de items que estan publicados
	*	@param $items : array con los items
	*	@return void
	*/
	public function touch($items)
	{
		if($this->stateField)
		{
			$ids = '';
			foreach($items as $key=>$id) { $ids .= $id . ', '; }
			$ids = rtrim($ids, ', ');

			$query = new Query();
			$query->table($this->dbtable);
			$query->fields(array($this->stateField => 3));
			$query->filter($this->primaryKey . ' in ('.$ids.')');
			$query->filter($this->stateField . ' = 1');

			if($this->params['debug'])
			{
				$query->debug();
				$query->debugSQL();
			}

			$query->update();
		}
	}




	/*/ Colecciones para home /*/

	/**
	*	GetForHome retorna un listado de elementos para mostrar en el editor de home
	*	@param $dto : array con los filtros del listado
	*	@return $list : array con los items
	*/
	public function HomeList($dto)
	{

		$module = $dto['module'];
		$this->setParam('pageSize', $dto['pageSize']);
		$this->setParam('currentPage', $dto['currentPage']);
		$this->setParam('categories', $dto['categories']);
		$this->setParam('query', $dto['query']);
		
		$items = $this->Get();


		if(isset($items[0]))
		{
			$response = array(
				'pageSize'    => $items['pageSize-att'], 
				'total'       => $items['total-att'],
				'currentPage' => $items['currentPage-att'],
			);
			/*
				Formatear el array según el formato esperado por home
			*/
			$items = Util::arrayNumeric($items);
			Util::ClearArray($items);

			
			foreach($items as $item)
			{
				$url = ($module == 'promo' && isset($item['url'])) 
						? $item['url'] 
						: '/' . $item['id'] . '-' . Util::Sanitize($item['title']);

				$local = array(
					'item_id'	=> $item['id'],
					'title'		=> $item['title'],
					'summary'	=> $item['summary'],
					'state'		=> (isset($item['state'])) ? $item['state'] : false,
					'url'		=> $url,
					'image_id'	=> (!empty($item['multimedias']['images'][0])) ? $item['multimedias']['images'][0]['image_id'] : 0,
					'image_type'=> (!empty($item['multimedias']['images'][0])) ? $item['multimedias']['images'][0]['type'] : '',
				);
				if(!empty($item['header'])) $local['header'] = $item['header'];
				if(!empty($item['categories'][0][0])){
					$local['category_id']    = $item['categories'][0][0]['category_id'];
					$local['category_title'] = $item['categories'][0][0]['name'];
				}
				$response[] = $local;
			}

			return $response;
		}
		return false;
	}

	/**
	 * LoadFromCache
	 * @return array
	 */
	public function LoadFromCache()
	{
		$folder  = $this->params['module'];
		
		$filters = array(
			'pageSize' => $this->params['pageSize'],
			'currentPage' => $this->params['currentPage'],
			'inCategory' => $this->params['inCategory'],
			'inTag' => $this->params['inTag'],
			'getCategories' => $this->params['getCategories'],
			'getImages' => $this->params['getImages'],
			'sort' => $this->params['sort'],
			'order' => $this->params['order'],
		);

		if($this->stateField)
			$filters['state'] = $this->params['state'];

		ksort($filters);
		$key = 'list-' . http_build_query($filters, '', '-');
		$key = sha1($key);

		// Response from cache
		$response = Cache::GetKey($key, $folder);

		if($response)
			return $response;

		$response = $this->Get();
		Cache::setKey($key, $response, $this->cacheTTL, $folder);

		return $response;
	}
}
?>