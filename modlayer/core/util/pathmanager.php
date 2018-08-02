<?php
final class PathManager
{
	private static $_Paths = array();
	private static $_ApplicationPath;
	private static $_TemporaryPath = null;
	

	public static function GetFrameworkPath()
	{
		return self::$_ApplicationPath . '/modlayer';
	}
	
	public static function AddClassPath($path)
	{
		array_unshift(self::$_Paths, $path);
	}

	public static function Apply()
	{
		set_include_path(implode(PATH_SEPARATOR, self::$_Paths));
	}

	public static function GetModuleAdminPath()
	{
		// retorno el path del modulo admin
		return self::GetModulesPath().'/admin/';
	}

	public static function GetApplicationPath()
	{
		return self::$_ApplicationPath;
	}
	
	public static function GetApplicationDir()
	{
		$fullpath = self::GetApplicationPath();
		$docroot  = rtrim($_SERVER['DOCUMENT_ROOT'], '/');
		$start    = strlen($docroot);
		$dir      = substr($fullpath, $start, strlen($fullpath)-$start);
		return $dir.'/';
	}
	
	public static function SetApplicationPath($path)
	{
		self::$_ApplicationPath = realpath($path);
	}

	public static function GetFrameworkDir()
	{
		$fullpath = self::GetFrameworkPath();
		$docroot  = rtrim($_SERVER['DOCUMENT_ROOT'], '/');
		$start    = strlen($docroot) + 1;
		$dir      = substr($fullpath, $start, strlen($fullpath)-$start);
		return '/'.$dir;
	}

	public static function GetModulesPath()
	{
		return self::GetFrameworkPath() . '/modules';
	}
	
	public static function GetModulePath()
	{
		/*
			Para retornar el nombre del modulo necesitamos movernos 2 lugares en el array
			porque pasa por la clase controller
		*/
		$x = debug_backtrace();
		
		if(isset($x[1]['file'])):
			return dirname(dirname($x[1]['file']));
		else:
			return dirname(dirname($x[0]['file']));
		endif;
	}


	/**
	* Manejo de paths para contenido generado
	*/
	public static function GetContentTargetPath($options = array(), $module=false)
	{
		$folders = Configuration::Query("/configuration/modules/module[@name='".$options['module']."']/options/group[@name='repository']/option[@name='".$options['folderoption']."']");
		if($folders)
		{
			$temp      = explode('/', $folders->item(0)->getAttribute('value'));
			$temp      = str_replace('{$module}', ($module) ? $module : Application::GetModule(), $temp);
			$directory = self::GetApplicationPath();
			foreach($temp as $folder){
				$path = $directory.'/'.$folder;
				$path = Util::DirectorySeparator($path);
				if(!is_dir($path)){
					mkdir($path);
					@chmod($path, 0775);
				}
				$directory = $path;
			}
			return $directory;
		}
		else
		{
			return false;
		}
	}

	public static function GetDirectoryFromId($directory, $id)
	{
		if(!is_writable($directory))
			throw new Exception("Can not create directory '" . $directory . "'. Check Permissions?" , 1);

		$folder = $directory.'/'. substr($id, - 1);
		$folder = Util::DirectorySeparator($folder);
		
		if (!is_dir($folder))
			mkdir($folder, 0777);

		return $folder;
	}

	public static function GetAdminDir()
	{
		$adminPath = Configuration::Query('/configuration/adminpath');
        $subdir    = Configuration::Query('/configuration/domain/@subdir');

        $path  = ($subdir) ? $subdir->item(0)->nodeValue . $adminPath->item(0)->nodeValue : $adminPath->item(0)->nodeValue;
        $url   = Util::DirectorySeparator($path);

        return $url;
	}

	/**
	*	FilePath : retorna la ruta del xml o json para un contenido por ID
	*	@param $id del elemento
	*	@param $json : flag para retornar la extension json. xml por default
	*	@return $path
	*/
	public static function FilePath($id, $module, $json = false)
	{
		$option = ($json) ? 'json' : 'xml'; 
		$options = array(
			'module'       => $module,
			'folderoption' => $option,
		);

		$path   = PathManager::GetContentTargetPath($options, $module);
		if(!$path)
			throw new Exception("Repository directory not defined for module " . $module, 1);
		
		$folder = PathManager::GetDirectoryFromId($path, $id);
		return Util::DirectorySeparator($folder.'/'.$id.'.'.$option);
	}
}
?>