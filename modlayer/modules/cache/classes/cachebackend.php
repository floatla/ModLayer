<?php
class CacheBackend extends Backend
{


	public static function RenderDefault()
	{
		//self::cache_list(); // El filtro es el nombre de la carpeta

		$filter = Util::getvalue('filter');
		// echo $filter;
		// die;
		parent::loadAdminInterface();
		self::$template->setcontent(Cache::getKeyList($folder=$filter), null, 'cache');
		self::$template->setparam('filter', $filter);
		self::$template->add("list.xsl");
		self::$template->display();
	}
	

	/* Metodos llamados por ajax */
	public static function BackDeleteFile()
	{
		try 
		{
			$filter = Util::getvalue('filter');
			$name   = Util::getvalue('name');
		
			$del = Cache::deleteKey($name, $folder=$filter);
			$response = array(
				'code' => 200,
				'message' => 'ok'
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($response);
	}

	public static function BackDeleteFolder()
	{
		try 
		{
			$filter = Util::getvalue('filter');
			$del    = Cache::deleteAllKeys($filter);
			$response = array(
				'code' => 200,
				'message' => 'ok'
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($response);
	}

}
?>