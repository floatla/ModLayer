<?php
Class Query {
	
	private $query     = array('filters'=>array(), 'params'=>array());
	private $db        = null;
	private $fields    = array();
	private $sql       = '';
	private $debug     = false;
	private $debugSQL  = false;
	private $conn = false;
	static  $queryStr;

	public function __construct($params=false, $_connection=false)
	{
		if($_connection)
			$this->conn = $_connection;

		if(is_array($params)) array_walk($params, array('Query', 'load'));
	}

	public function load($value, $key)
	{
		if(method_exists("Query", $key))
		{
			call_user_func_array(array('Query', $key), array($value));
		}else
		{
			throw new Exception("Method <em>$key</em> does not exist in Query Class. Check your parameters.", 1);
		}
	}

	public function __call($method, $args)
	{
		if(method_exists("Query", $method))
		{
			call_user_func_array(array('Query', $method), $args);
		}else
		{
			throw new Exception("Method <em>$method</em> does not exist in Query Class. Check your parameters.", 1);
		}
	}


	public function table($table)
	{
		$this->query['table'] = $table;
	}

	public function fields($fields, $sum=true)
	{
		if(!$sum) $this->query['fields'] = array();
		foreach($fields as $key=>$value)
		{
			$this->query['fields'][$key] = $value;
		}
	}

	public function getFields(){
		return $this->query['fields'];
	}

	public function limit($limit=10, $currentPage=1)
	{
		if(!is_numeric($currentPage)) throw new Exception("currentPage is not a integer", 1);
		$currentPage = (int)$currentPage;

		if(!is_numeric($limit)) throw new Exception("limit is not a integer", 1);
		$limit = (int)$limit;

		$offset = ($currentPage-1) * $limit;
		$this->query['limit'] = $offset . ', ' . $limit;
		if($limit == -1){unset($this->query['limit']);}
	}

	public function orderby($orderby)
	{
		$this->query['orderby'] = $orderby;
	}

	public function order($order)
	{
		$this->query['order'] = $order;
	}

	public function groupby($string)
	{
		$this->query['groupby'] = $string;
	}

	public function filter($string)
	{
		array_push($this->query['filters'], $string);
	}

	public function param($name, $value, $type)
	{

		switch($type)
		{
			case 'int':
				$dataType = PDO::PARAM_INT;
				break;
			case 'bool':
				$dataType = PDO::PARAM_BOOL;
				break;
			default: // string
				$dataType = PDO::PARAM_STR;
				break;
		}
		array_push($this->query['params'], array('name'=>$name, 'value'=>$value, 'datatype'=>$dataType));
	}

	// Clear filters and params
	public function clear()
	{
		$this->query['filters'] = array();
		$this->query['params']  = array();
	}

	public function exclusive($bool)
	{
		$this->query['exclusive'] = ($bool) ? true : false; 
	}

	public function exec()
	{
		throw new Exception("Query::exec is deprecated, please use Query::execute");
	}

	public function _connection($dto)
	{
		$this->conn = $dto;
	}

	public function initDB()
	{
		$this->db = new DBManager($this->conn);
	}

	public function closeDB()
	{
		$this->db = null;
	}

	public function debug()
	{
		$this->debug = true;
	}

	public function debugSQL()
	{
		$this->debugSQL = true;
	}

	public function check($fields=true)
	{
		if($fields) if(empty($this->query['fields'])) $this->query['fields'] = array('*');
		if(empty($this->query['table']))  throw new Exception("SQL table it's empty", 1);
	}

	public function select()
	{
		$this->check();
		
		$this->sql = 'SELECT ';
		$this->sql .= implode(', ', $this->query['fields']);
		$this->sql .= ' FROM ';
		$this->sql .= $this->query['table'];

		if(count($this->query['filters']) >= 1)
		{
			$this->sql .= ' WHERE ';
			if(count($this->query['filters']) == 1)
			{
				$this->sql .= implode($this->query['filters']);
			}else{
				$exclusive = (isset($this->query['exclusive']) && $this->query['exclusive'] === false) ? ' OR ' : ' AND ';
				$this->sql .= implode($exclusive, $this->query['filters']);
			}
		}

		$this->sql .= (!empty($this->query['groupby'])) ? ' GROUP BY ' . $this->query['groupby'] : '';
		$this->sql .= (!empty($this->query['orderby'])) ? ' ORDER BY ' . $this->query['orderby'] : '';
		$this->sql .= (!empty($this->query['order'])) ? ' ' . $this->query['order'] : '';
		$this->sql .= (!empty($this->query['limit'])) ? ' LIMIT ' . $this->query['limit'] : '';

		DBManager::$queryStr = $this->sql;
		if($this->debug)    Util::debug($this->query);
		if($this->debugSQL) Util::debug($this->sql);
		
		// $x = debug_backtrace();
		// Util::debug($this->sql);
		// Util::debug($x[0]['file'] . ' -> ' . $x[0]['line']);
		// Util::debug($x[1]['file'] . ' -> ' . $x[1]['line']);
		// Util::debug('==========================================================================================');

		$this->initDB();
		$stmt = $this->db->prepare($this->sql);

		// Bind params
		foreach($this->query['params'] as $param)
		{
			$stmt->bindParam($param['name'], $param['value'], $param['datatype']);	
		}
		
		$stmt->execute();
		$return = $stmt->fetchAll(PDO::FETCH_ASSOC);
		$this->closeDB();


		return $return;

	}

	public function insert($update=false)
	{
		$this->check();

		$keys = array_keys($this->query['fields']);
		array_walk($keys, function(&$v, $i){
			$v = '`' . $v . '`';
		});

		$this->sql =  'INSERT ';
		$this->sql .= 'INTO `' . $this->query['table'] . '` (';
		$this->sql .= implode($keys, ', ') . ') ';
		$this->sql .= 'VALUES (';

		foreach($this->query['fields'] as $field => $value)
		{
			if (!(is_int($value)) && $value != 'now()'){
				$this->sql .= ":" . $field . ", ";
			}
			elseif($value==='now()'){
				$this->sql .= 'now(), ';
			}else{
				$this->sql .= $value . ', ';
			}
		}
		$this->sql = rtrim($this->sql, ', ');
		$this->sql .= ')';

		if($update)
		{
			$this->sql .= ' ON DUPLICATE KEY UPDATE ';			
			foreach($this->query['fields'] as $field => $value)
			{
				$this->sql .= $field . '=';
				if (!(is_int($value)) && $value != 'now()'){
					$this->sql .= ":" . $field . ", ";
				}
				elseif($value==='now()'){
					$this->sql .= 'now(), ';
				}else{
					$this->sql .= $value . ', ';
				}
			}
			$this->sql = rtrim($this->sql, ', ');
		}

		DBManager::$queryStr = $this->sql;
		if($this->debug)    Util::debug($this->query);
		if($this->debugSQL) Util::debug($this->sql);

		$this->initDB();
		$stmt = $this->db->prepare($this->sql);

		// Bind params
		// Bind fields params. Important: $val by reference, because bindParam needs &$variable
		foreach($this->query['fields'] as $key => &$val) 
		{
			if (!(is_int($val)) && $val!='now()'){
				$stmt->bindParam($key, $val, PDO::PARAM_STR);
			}
		}

		// $bind = array();
		// foreach($this->query['fields'] as $param => $paramValue)
		// {
		// 	if (!(is_int($paramValue)) && $paramValue!='now()'){
		// 		$paramValue = trim($paramValue,"\'");
		// 		array_push($bind, $paramValue);
		// 	}
		// }
		// $stmt->execute($bind);

		$stmt->execute();
		$lastId = $this->db->lastInsertId();
		$this->closeDB();

		return $lastId;
	}

	public function update()
	{
		$this->check();

		$this->sql =  'UPDATE ';
		$this->sql .= '`' . $this->query['table'] . '` ';
		$this->sql .= 'SET ';

		foreach($this->query['fields'] as $field => $value)
		{
			$this->sql .= '`' . $field . '` = ';
			if (!(is_int($value)) && $value != 'now()'){
				$this->sql .= ":" . $field . ", ";
			}
			elseif($value==='now()'){
				$this->sql .= 'now(), ';
			}else{
				$this->sql .= $value . ', ';
			}
		}
		$this->sql = rtrim($this->sql, ', ');

		if(count($this->query['filters']) >= 1)
		{
			$this->sql .= ' WHERE ';
			if(count($this->query['filters']) == 1)
			{
				$this->sql .= implode($this->query['filters']);
			}else{
				$exclusive = (isset($this->query['exclusive']) && $this->query['exclusive'] === false) ? ' OR ' : ' AND ';
				$this->sql .= implode($exclusive, $this->query['filters']);
			}
		}

		DBManager::$queryStr = $this->sql;
		if($this->debug)    Util::debug($this->query);
		if($this->debugSQL) Util::debug($this->sql);

		$this->initDB();
		$stmt = $this->db->prepare($this->sql);

		// Bind fields params. Important: $val by reference, because bindParam needs &$variable
		foreach($this->query['fields'] as $key => &$val) 
		{
			if (!(is_int($val)) && $val!='now()'){
				$stmt->bindParam($key, $val, PDO::PARAM_STR);
			}
		}

		// Bind filter params
		foreach($this->query['params'] as $param)
		{
			$stmt->bindParam($param['name'], $param['value'], $param['datatype']);
		}
		
		$return = $stmt->execute();
		$this->closeDB();
		return $return;
	}

	public function delete()
	{
		$this->check($fields=false);

		// Delete if there're filters (don't empty table)
		if(count($this->query['filters']) >= 1)
		{
			$this->sql =  'DELETE FROM ';
			$this->sql .= $this->query['table'] . ' ';
		
			$this->sql .= 'WHERE ';
			if(count($this->query['filters']) == 1)
			{
				$this->sql .= implode($this->query['filters']);
			}else{
				$exclusive = (isset($this->query['exclusive']) && $this->query['exclusive'] === false) ? ' OR ' : ' AND ';
				$this->sql .= implode($exclusive, $this->query['filters']);
			}

			DBManager::$queryStr = $this->sql;
			if($this->debug)    Util::debug($this->query);
			if($this->debugSQL) Util::debug($this->sql);

			$this->initDB();
			$stmt = $this->db->prepare($this->sql);

			// Bind filter params
			foreach($this->query['params'] as $param)
			{
				$stmt->bindParam($param['name'], $param['value'], $param['datatype']);
			}

			$return = $stmt->execute();
			$this->closeDB();
			return $return;
		}
	}

	/**
	* Execute a custom sql statement
	* return void
	*/
	public function execute($sql, $bindParams=false)
	{
		$this->initDB();
		$stmt = $this->db->prepare($sql);
		
		if($bindParams !== false){
			foreach($bindParams as $param)
			{
				$stmt->bindParam($param['name'], $param['value']);
			}
		}

		DBManager::$queryStr = $this->sql;
			if($this->debug)    Util::debug($sql);
			if($this->debugSQL) Util::debug($bindParams);

		$stmt->execute();
		$this->lastID = $this->db->lastInsertId();
		$this->closeDB();
		return $stmt->rowCount();
	}

	/**
	* Run a custom sql statement
	* return array
	*/
	public function run($sql, $bindParams=false)
	{
		DBManager::$queryStr = $this->sql;

		$this->initDB();
		$stmt = $this->db->prepare($sql);

		if($bindParams !== false){
			foreach($bindParams as $param)
			{
				$stmt->bindParam($param['name'], $param['value']);
			}
		}

		DBManager::$queryStr = $this->sql;
		if($this->debug)    Util::debug($sql);
		if($this->debugSQL) Util::debug($bindParams);

		$stmt->execute();
		$return = $stmt->fetchAll(PDO::FETCH_ASSOC);
		$this->closeDB();
		return $return;
	}

	public function lastID()
	{
		return $this->lastID;
	}
}
?>