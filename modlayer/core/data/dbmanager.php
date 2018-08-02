<?php
class DBManager extends PDO
{

	public $db;
	public $debug = false;
	public static $queryStr;

	/**
	*	Extends PDO functionality
	*/
	public function __construct($_connection=false)
	{
		$attrs = array(
			PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
		);
		$conn  = ($_connection) ? $_connection : Configuration::GetDatabaseConnection();

		parent::__construct($conn['dns'], $conn['user'], $conn['pass'], $attrs );
		$this->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

		$cfTimeZone = Configuration::Query('/configuration/database/timezone');
		$dbTimeZone = ($cfTimeZone) ? $cfTimeZone->item(0)->nodeValue : '-3:00';
		
		// Set DB TimeZone
		$this->query("SET time_zone = '".$dbTimeZone."'");
	}
	
	/**
	*	Extends PDO functionality
	*/
	public function __call($name, $arguments)
	{
		if(method_exists("PDO", $name))
		{
			call_user_func_array(array('PDO', $name), array($arguments));
		}else
		{
			throw new Exception("Method <em>$name</em> does not exists in DBManager Class. Check your parameters.", 1);
		}
	}

}

?>