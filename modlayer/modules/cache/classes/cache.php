<?php
class Cache 
{

	public static function setKey($key, $data, $expires, $folder=false)
	{
		$dir = self::getDir($folder);
		$key = str_replace('/','-',$key);

		$file = $dir.'/'.$key.'.cache';
		$fileexp = $dir.'/'.$key.'.ttl';

		/* 
			Guardo un archivo con la expiracion y otro con los datos
		*/
		$fp = fopen($fileexp, 'w');
		fwrite($fp, $expires);
		fclose($fp);

		$fp = fopen($file, 'w');
		fwrite($fp, serialize($data));
		fclose($fp);
		@chmod ($file, 0777);
		@chmod ($fileexp, 0777);

	}

	public static function getKey($key, $folder=false)
	{
		$mod = Configuration::GetModuleConfiguration(basename(dirname(dirname(__FILE__))));
		
		/*
			Si se esta visualizando el admin,
			retornamos siempre falso, para que haga 
			la consulta
		*/

		if(Application::isFrontEnd() === false):
			return false;
		endif;

		/* 
			El path completo a la carpeta
		*/
		$dir   = self::getDir($folder);

		/*
			Precalentamiento de cache
			Permite disparar la generacion del cache
			mientras se sigue sirviendo el archivo cacheado
		*/

		if($folder)
		{
			$tmpfile = $dir.'/'.$key.'.tmp';
			if(file_exists($tmpfile))
			{
				unlink($tmpfile);
				return false;
			}
		}

		$key = str_replace('/','-',$key);

		/* Archivo del cache a buscar */
		$file    = $dir.'/'.$key.'.cache';
		$fileexp = $dir.'/'.$key.'.ttl';


		if(file_exists($fileexp))
		{
			$expires = file_get_contents($fileexp) * 1;
			/* Busco el archivo y me fijo si ya expiro */
			if(file_exists($file) && time() < filemtime($file) + $expires)
			{
				$content = unserialize(file_get_contents($file));
				return $content;
			}else{
				/* Si el archivo no existe retorna falso. No deberia llegar acá nunca, si no existe el key ya retornó falso */
				return false;
			}
		}else{
			return false;
		}
	}

	public static function SoftClear($folder)
	{
		$keys = self::getKeyList($folder);
		$dir  = self::getDir($folder);

		if($keys)
		{
			foreach($keys as $i=>$item)
			{
				if(is_numeric($i))
				{
					$tmpfile = $dir . '/' . $item['name-att'] . '.tmp';
					$json    = json_encode($item);
					$fp      = fopen($tmpfile, 'w');
					fwrite($fp, $json);
					fclose($fp);
				}
			}
		}
	}

	public static function EmptyFolder($folder)
	{
		$cacheDir = self::getDir($folder);
		return self::recursive_remove_directory($cacheDir, $empty=true);
	}
	
	public static function deleteKey($key, $folder=false)
	{

		$dir = self::getDir($folder);
		$file = $dir.'/'.$key.'.cache';
		$fileexp = $dir.'/'.$key.'.ttl';
		if(file_exists($file)):
			unlink($file);
		endif;
		if(file_exists($fileexp)):
			unlink($fileexp);
		endif;
		return true;

	}

	public static function deleteAllKeys($folder)
	{
		$cacheDir = self::getDir($folder);
		return self::recursive_remove_directory($cacheDir);
	}


	private static function getDir($folder=false)
	{
		/* Tomo la configuracion del xml */
		$options = array(
			'module' => 'cache',
			'folderoption' => 'target'
		);

		$realPath = PathManager::GetContentTargetPath($options);

		if($folder){
			$path = $realPath.'/'.$folder;
			if (!is_dir($path)){mkdir($path, 0777);}
			return $path;
		}else{
			return $realPath;	
		}
	}


	/* Metodos para administrar cache desde el back */
	
	public static function getKeyList($folder=false)
	{
	
		$conf      = Configuration::Query("/configuration/modules/module[@name='cache']/options/group[@name='repository']/option[@name='target']/@value");
		$directory = PathManager::GetApplicationPath() . '/' . $conf->item(0)->nodeValue;


		if($folder){
			$directory = $directory . '/' . $folder;			
		}

		$return = array();

		//$dir = self::getDir($folder);
		if(is_dir($directory))
		{
			$handle = opendir($directory);
			$count = 0;
			$files = array();
			while (FALSE !== ($item = readdir($handle)))
			{

				if($item != '.' && $item != '..')
				{
					if(is_dir($directory .'/'.$item))
					{
						$file = array();
						$file['name-att']    = $item;
						$file['type-att']    = 'folder';
						$file['files']    = scandir($directory .'/'.$item);
						array_push($files,$file);
						$count++;
					}
					else
					{
						$file = explode('.', $item);
						$extension = $file[count($file)-1];
						array_pop($file);
						$file = implode('', $file);

						if($file != '') // fix mac problem with .DS_Store
						{
							$expires = file_get_contents($directory.'/'.$file.'.ttl');

							$fileexpires = date('Y-m-d H:i:s', filemtime($directory.'/'.$item) + $expires);
							// echo $fileexpires;
							// die;
							// $path = $directory.'/'.$item;
							// if the new path is a directory
							if($extension != 'ttl')
							{
								$subitem = array();
								$subitem['name-att']    = $file;
								$subitem['type-att']    = 'file';
								$subitem['expires-att'] = $fileexpires;
								array_push($files,$subitem);
								$count++;
							}
						}
					}
					
				}
			}
			// close the directory
			closedir($handle);

			if($count==0):
				$arr = array('cache'=>'null');
				return $arr;
			else:
				$files['tag'] = 'item';
				return $files;
			endif;
		}
		else
		{
			return false;
		}

	}





	// to use this function to totally remove a directory, write:
	// recursive_remove_directory('path/to/directory/to/delete');

	// to use this function to empty a directory, write:
	// recursive_remove_directory('path/to/full_directory',TRUE);

	private static function recursive_remove_directory($directory, $empty=FALSE)
	{
		// if the path has a slash at the end we remove it here
		if(substr($directory,-1) == '/')
		{
			$directory = substr($directory,0,-1);
		}

		// if the path is not valid or is not a directory ...
		if(!file_exists($directory) || !is_dir($directory))
		{
			// ... we return false and exit the function
			return FALSE;

		// ... if the path is not readable
		}
		elseif(!is_readable($directory))
		{
			// ... we return false and exit the function
			return FALSE;

		// ... else if the path is readable
		}else{

			// we open the directory
			$handle = opendir($directory);

			// and scan through the items inside
			while (FALSE !== ($item = readdir($handle)))
			{
				// if the filepointer is not the current directory
				// or the parent directory
				if($item != '.' && $item != '..')
				{
					// we build the new path to delete
					$path = $directory.'/'.$item;

					// if the new path is a directory
					if(is_dir($path)) 
					{
						// we call this function with the new path
						self::recursive_remove_directory($path);

					// if the new path is a file
					}else{
						// we remove the file
						unlink($path);
					}
				}
			}
			// close the directory
			closedir($handle);

			// if the option to empty is not set to true
			if($empty == FALSE)
			{
				// try to delete the now empty directory
				if(!rmdir($directory))
				{
					// return false if not possible
					return FALSE;
				}
			}
			// return success
			return TRUE;
		}
	}



}
?>