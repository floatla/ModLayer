<?php
class Model{
	
	static $tag = 'object';

	public static function getTag(){
		return self::$tag;
	}

	public static function parseFields($structure, $fields, $table)
	{
		self::table_exists($structure, $table);

		if(is_array($fields) && count($fields)):
			if(count($fields)==1 && $fields[0]=='*')
			{
				$fields = array();
				foreach($structure[$table]['fields'] as $name=>$arr){
					array_push($fields, $name);
				}
			}
			$colector = array();

			foreach($fields as $pos=>$name)
			{
				switch ($structure[$table]['fields'][$name]['xml'])
				{
					case "attribute":
						$data = $table.'.'.$name.' as "' . $structure[$table]['fields'][$name]['alias'].'-att"';
						break;
					case "nodes":
						$data = $table.'.'.$name.' as "' . $structure[$table]['fields'][$name]['alias'].'-xml"';
						break;
					default:
						$data = $table.'.'.$name.' as "' . $structure[$table]['fields'][$name]['alias'].'"';
						break;
				}
				array_push($colector,$data);
			}
			return $colector;
		endif;
	}

	public static function parseCustomField($structure, $field, $table){
		self::table_exists($structure, $table);
		foreach($structure[$table]['fields'] as $name=>$arr):
			if($name == $field):
				$data = ($structure[$table]['fields'][$name]['xml']=='attribute') ? $structure[$table]['fields'][$name]['alias'].'-att' : $structure[$table]['fields'][$name]['alias'];
			endif;
		endforeach;
		return $data;
	}

	public static function parsePrimaryKeyAlias($structure, $table){
		self::table_exists($structure, $table);
		$key = $structure[$table]['primary_key'];
		if($structure[$table]["fields"][$structure[$table]["primary_key"]]['xml']=='attribute'){
			return $structure[$table]["fields"][$key]["alias"].'-att';
		}
		else{
			return $key;
		}
	}

	public static function parsePrimaryKey($structure, $table){
		self::table_exists($structure, $table);
		if(!empty($structure[$table]['primary_key'])):
			return $structure[$table]['primary_key'];
		else:
			return false;
		endif;
	}

	public static function parseInputFields($structure, $fields, $table, $verbose=false, $customField=false)
	{
		if(!empty($fields['back'])) unset($fields['back']);
		if(!empty($fields['modToken'])) unset($fields['modToken']);
		$returnFields = array();

		// Si la tabla solicitada existe
		if(array_key_exists($table, $structure))
		{
			/*
				Recorremos todos los campos del listado recibido
				y solo validamos los que pertenecen a la tabla
				solicitada
			*/
			foreach($fields as $key=>$value)
			{
				if(array_key_exists($key, $structure[$table]['fields'])) {
					if(!$customField){
						$returnFields[$key] = self::validateField($structure, $key, $value, $table);
					}
					else {
						$returnFields[$key] = self::validateCustomField($structure, $key, $value, $table);
					}
				}
				else {
					if($verbose) {
						$text = Configuration::Translate('model_exceptions/missing_field');
						throw new Exception(sprintf($text, $key), 1);
					}
				}
			}

			return $returnFields;
		}
		else
		{
			$text = Configuration::Translate('model_exceptions/missing_table');
			throw new Exception(sprintf($text, $table), 1);
			return false;
		}
	}

	/*
		validateFields retorna el campo validado
		El llamado a este método se hace una vez validado el campo y la tabla
		Si no se corresponde con el tipo de datos arroja una excepcion
	*/
	public static function validateField($structure, $key, $value, $table)
	{
		// Tipo de dato
		$type    = $structure[$table]['fields'][$key]['type'];
		$null    = $structure[$table]['fields'][$key]['null'];
		$default = $structure[$table]['fields'][$key]['default'];
		
		// Si el tipo de datos contiene el largo lo separamos
		$pos = strpos($type,'(');
		if($pos === false):
			$typeName = $type;
			$length   = 0;
		else:
			$typeName = substr($type, 0, strpos($type,'('));
			$length   = substr($type, (strpos($type,'(') + 1), -1);
		endif;

		// Si el tipo de dato no es válido para el campo, retornamos falso
		$text = Configuration::Translate('model_exceptions/invalid_field');
		switch($typeName){
			case "int":
				// strlen funciona bien para contar la cantidad de caracteres aunque sean números
				if(is_numeric($value) && strlen($value)<=$length)
					return $value;
				elseif($null == 'NULL')
					return $default;

				// Si no valido el tipo y largo retornamos falso
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "tinyint":
				// strlen funciona bien para contar la cantidad de caracteres aunque sean números
				if(is_numeric($value) && strlen($value)<=$length)
					return $value;

				// Si no valido el tipo y largo retornamos falso
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "varchar":
				if(is_string($value) && strlen($value)<=$length) {
					if($null == 'NOT NULL' && strlen($value)!=0)
						return $value;
					elseif($null == 'NULL')
						return $value;
				}
				if(empty($value) && $null == 'NULL')
					return '';
				
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			/* 
				IMPORTANTE!
				El tipo url no es válido de MySQL, es un varchar
				Utilizamos este tipo para generar url amistosas
				reemplazando espacios y caracteres raros
			*/
			case "url":
				if(is_string($value) && strlen($value)<=$length) {
					if($null == 'NOT NULL' && strlen($value)!=0)
						return Util::Sanitize($value);
					elseif($null == 'NULL')
						return Util::Sanitize($value);
				}
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "text":
				if(is_string($value)) {
					if($null == 'NOT NULL' && strlen($value)!=0)
						return Util::StringToXML($value);
					elseif($null == 'NULL')
						return $value;
				}
				if(empty($value) && $null == 'NULL')
					return '';

				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "array":
				return serialize($value);
			break;
			case "password":
				return Admin::encrypt($value);
			case "datetime":
			case "date":
			case "time":
			case "decimal":
			default:
				return $value;
			break;
			// Agregar mas tipos, solo dejo los que mas usamos
		}
	}
	
	
	/*
		validateFields retorna el campo validado
		El llamado a este método se hace una vez validado el campo y la tabla
		Si no se corresponde con el tipo de datos arroja una excepción
	*/
	public static function validateCustomField($structure, $key, $value, $table)
	{
		// Tipo de dato
		$type    = $structure[$table]['fields'][$key]['type'];
		$null    = $structure[$table]['fields'][$key]['null'];
		$default = $structure[$table]['fields'][$key]['default'];
		
		// Si el tipo de datos contiene el largo lo separamos
		$pos = strpos($type,'(');
		if($pos === false):
			$typeName = $type;
			$length   = 0;
		else:
			$typeName = substr($type, 0, strpos($type,'('));
			$length   = substr($type, (strpos($type,'(') + 1), -1);
		endif;

		// Si el tipo de dato no es válido para el campo, retornamos falso
		$text = Configuration::Translate('model_exceptions/invalid_field');
		switch($typeName){
			case "int":
				// strlen funciona bien para contar la cantidad de caracteres aunque sean numeros
				if(is_numeric($value) && strlen($value)<=$length): 
					return $value;
				elseif($null == 'NULL'):
					return $default;
				endif;
				// Si no valido el tipo y largo retornamos falso
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "tinyint":
				// strlen funciona bien para contar la cantidad de caracteres aunque sean números
				if(is_numeric($value) && strlen($value)<=$length): 
					return $value;
				endif;
				// Si no valido el tipo y largo retornamos falso
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "varchar":
				if(is_string($value) && strlen($value)<=$length):
					if($null == 'NOT NULL' && strlen($value)!=0):
						return $value;
					elseif($null == 'NULL'):
						return $value;
					endif;
				endif;
				if(strlen($value) == 0 && $null == 'NULL'){
					return $value;
				}
				throw new Exception(sprintf($text, $key, $type));
				return false;
			break;
			/* 
				IMPORTANTE!
				El tipo url no es válido de MySQL, es un varchar
				Utilizamos este tipo para generar url amistosas
				reemplazando espacios y caracteres raros
			*/
			case "url":
				if(is_string($value) && strlen($value)<=$length):
					if($null == 'NOT NULL' && strlen($value)!=0):
						return Util::Sanitize(utf8_encode($value));
					elseif($null == 'NULL'):
						return Util::Sanitize(utf8_encode($value));
					endif;
				endif;
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "text":
				if(is_string($value)):
					if($null == 'NOT NULL' && strlen($value)!=0):
						return $value;
					elseif($null == 'NULL'):
						return $value;
					endif;
				endif;
				throw new Exception(sprintf($text, $key, $type), 1);
				return false;
			break;
			case "array":
				return serialize($value);
			break;
			case "datetime":
				return $value;
			break;
			case "date":
				return $value;
			break;
			case "time":
				return $value;
			break;
			default:
				return false;
			break;
			// Agregar mas tipos, solo dejo los que más usamos
		}
	}
	
	/*
		@Deprecated
		autoCompleteFields retorna un array con todos los campos de un registro
		se completan los que faltan con los default de la base
	*/
	public static function autoCompleteFields($structure, $fields, $table)
	{
		$return = array();
		$tableFields = $structure[$table]['fields'];
		foreach($tableFields as $key=>$value):
			if(array_key_exists($key, $fields)):
				$return[$key] = $fields[$key];
			else:
				$return[$key] = self::validateField($structure, $key, $value['default'], $table);
			endif;
		endforeach;
		return $return;
	}
	
	

	/* CREATE TABLE */
	public static function parsecreateTable($structure)
	{
		try
		{
			//self::table_exists($structure, $table);
			$sql = '';
			foreach($structure as $tableName=>$table)
			{
				if(isset($table['virtual']) && $table['virtual'] == 1){
					continue;
				}

				if(!self::is_table($tableName))
				{
					$primary_key = self::parsePrimaryKey($structure, $tableName);
					$sql =" CREATE TABLE `".$tableName."` (" . "\n";

					foreach($table["fields"] as $key=>$value)
					{
						if(strpos($value["type"],'url')!==false){
							$type = 'varchar' . substr($value['type'], 3, 5);
						}
						elseif(strpos($value["type"],'password')!==false){
							$type = 'varchar' . substr($value['type'], 8, 5);
						}
						else{
							$type = $value['type'];
						}

						$sql .= "`".$key."` " . $type . " ";
						$sql .= $value["null"] ." ";

						if($key != $primary_key){
							$sql.= (($value["default"] !== false) ? " default '" . $value["default"] . "' " : '') . " ";
						}

						$sql.= ((isset($value["extra"])) ? $value["extra"]:"") . ", " . "\n";
					}
					if($primary_key){
						$sql.= "PRIMARY KEY (`".$primary_key."`)";
					}
					else{
						$sql = substr($sql, 0, strlen($sql)-3);
					}
			
					// Indices
					if(is_array($table['indexes']) && isset($table['indexes'][0]['index_name']))
					{
						$sql .= ", \n";
						foreach($table['indexes'] as $index)
						{
							$sql .= $index['index_type'];
							$sql .= ($index['index_type'] !== 'INDEX') ? " KEY " : "";
							$sql .= " `".$index['index_name']."` (";
							foreach($index['fields_name'] as $fieldname){
								$sql .= "`".$fieldname."`,";
							}
							$sql = substr($sql, 0, strlen($sql)-1);
							$sql .= "), \n";
						}
						$sql = substr($sql, 0, strlen($sql)-3) . " \n";
					}
					else{
						$sql .= "\n";
					}

					$sql .= ") ENGINE = MYISAM DEFAULT CHARSET=".$table['charset']."; ";
				
					Util::debug($sql);

					$query = new Query();
					$query->execute($sql);
				}
			}
		}
		catch(Exception $e)
		{
			echo $e->getMessage();
		}
	}


	public static function is_table($table){
		try
		{
			$query = new Query();
			$sql = 'SELECT * FROM ' . $table . ' LIMIT 1';

			$query->execute($sql);
			Util::debug("tabla: '".$table."' existe.<br/>");
			
			return true;
		}
		catch(Exception $e){
			// echo $e->getMessage();
			return false;
		}
	}

	public static function table_exists($structure, $table)
	{
		if(!array_key_exists($table, $structure)): 
			return false;
		else:
			return true;
		endif;
	}


	/* Nuevos métodos para uso de objetos genéricos */
	public static function parseFieldsFromObjects($objects, $table, $struture, $objectFields)
	{
		self::object_walk_recursive($objects, $table, $struture, $objectFields);

		$local = array();
		//util::debug($objects);
		//die();
		
			foreach($objects as $object){
				if(!empty($object['custom_data'])){
					
					$cus = $object['custom_data'];
					$arr = unserialize($cus);
					$arr = str_replace("<1>", "'", $arr);
					$arr = str_replace('<2>', '"', $arr);

					
					foreach($arr as $objkey=>$objvalue){
						$object[$objkey] = $objvalue;
					}
					unset($object['custom_data']);
				}
				array_push($local, $object);
			}
		return $local;
	}

	/* Formatea un array según el mapeo en modelo del módulo para la estructura de los xmls */
	public static function replace_keys(&$value, &$key, $table, $struture, $objectFields)
	{
		foreach($objectFields as $objectKey=>$itemKey):
			if($objectKey==$key):
				switch($struture[$table]["fields"][$itemKey]['xml']):
					case "attribute":
						$key = $struture[$table]["fields"][$itemKey]['alias'].'-att';
						break;
					case "nodes":
						$key = $struture[$table]["fields"][$itemKey]['alias'].'-xml';
						break;
					default:
						$key = $struture[$table]["fields"][$itemKey]['alias'];
						break;
				endswitch;
			endif;
		endforeach;
	}

	private static function object_walk_recursive(&$input, $table, $struture, $objectFields)
	{
		foreach ($input as $key => $value):
			if (is_array($input[$key])):
				self::object_walk_recursive($input[$key], $table, $struture, $objectFields);
			else:
				$saved_value = $value;
				$saved_key = $key;
				self::replace_keys($value, $key, $table, $struture, $objectFields);
				if($value !== $saved_value || $saved_key !== $key):
					unset($input[$saved_key]);
					$input[$key] = $value;
				endif;
			endif;
		endforeach;
		return true;
	}
	
	public static function serialize($array)
	{
		$return = array();
		foreach($array as $key=>$value):
			$newvalue = stripslashes($value);
			$newvalue = str_replace('"', '<2>', $newvalue);
			$newvalue = str_replace("'", "<1>", $newvalue);
			$return[$key] = $newvalue;
		endforeach;
		return serialize($return);
	}

	public static function inputObjectFields($options)
	{
		$defaults = array(
			'fields'        => false, 
			'table'         => false, 
			'tables'        => false,
			'object_typeid' => false, 
			'objectFields'       => false,
			'multimedia_typeid'  => false,
			'verbose'       => false
		);

		$options = Util::extend($defaults,$options);
		
		unset($options['fields']['modToken']);//remove generated security form token

		$object = array();
		$custom = array();

		foreach($options['fields'] as $key=>$value):
			if(in_array($key, $options['objectFields'])):
				$objectField = array_search($key, $options['objectFields']);
				$object[$objectField] = $value;
			else:
				$custom[$key] = $value;
			endif;
		endforeach;

		$custom = self::parseInputFields($options['tables'], $custom, $options['table'], $options['verbose'], $custom=true);

		$customArray  = array();
		foreach($custom as $customKey=>$customValue):
			$customField = self::parseCustomField($options['tables'], $customKey, $options['table']); //self::getCustomField($customKey, $table);
			$customArray[$customField] = $customValue;
		endforeach;
		
		if($options['object_typeid'] !== false):
			$object['object_typeid'] = $options['object_typeid'];
		endif;

		if($options['multimedia_typeid'] !== false):
			$object['multimedia_typeid'] = $options['multimedia_typeid'];
		endif;

		if(!empty($customArray)):
			$object['custom_data'] = self::serialize($customArray);
		endif;

		
		return $object;
	}

	public static function inputFields($tables, $fields, $table, $verbose)
	{
		return self::parseInputFields($tables, $fields, $table, $verbose, $custom=false);
	}

	/* 
		Formatea cualquier array según el en modelo del módulo para la estructura de los xmls 
	*/
	public static function FormatArray(&$input, $table, $struture)
	{
		foreach ($input as $key => $value)
		{
			if (is_array($input[$key])){
				self::FormatArray($input[$key], $table, $struture);
			}
			else
			{
				$saved_value = $value;
				$saved_key = $key;
				self::FormatKeys($value, $key, $table, $struture);
				if($value !== $saved_value || $saved_key !== $key)
				{
					unset($input[$saved_key]);
					$input[$key] = $value;
				}
			}
		}
		return true;
	}

	/* 
		Cambia los keys del array
	*/
	public static function FormatKeys(&$value, &$key, $table, $struture)
	{
		if(isset($struture[$table]["fields"][$key]))
		{
			switch($struture[$table]["fields"][$key]['xml'])
			{
				case "attribute":
					$key = $struture[$table]["fields"][$key]['alias'].'-att';
					break;
				case "nodes":
					$key = $struture[$table]["fields"][$key]['alias'].'-xml';
					break;
				default:
					$key = $struture[$table]["fields"][$key]['alias'];
					break;
			}
		}
	}

}

?>
