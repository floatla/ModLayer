<?php
Class EventLog 
{
	protected $module = '';
	protected $path;

	public function __construct()
	{
		$this->path = PathManager::GetApplicationPath() . '/content/logs/';
		$directory  = PathManager::GetApplicationPath();
		$temp      = explode('/', '/content/logs/');
		foreach($temp as $folder){
			$path = $directory .'/'.$folder;
			$path = Util::DirectorySeparator($path);
			if(!is_dir($path)){
				mkdir($path);
				@chmod($path, 0775);
			}
			$directory = $path;
		}
	}

	public function SetModule($name)
	{
		$this->module = $name;
	}

	public function LogFile()
	{
		$file = $this->path . 'events.';
		if(!empty($this->module))
			$file .= $this->module . '.';

		$file .= date('Ymd') . '.log';
		return $file;
	}

	public function Log($line)
	{
		$file   = $this->LogFile();


		$fp = fopen($file, 'a');
		fwrite($fp, $line . "\n");
		fclose($fp);
	}

	public function ReadLog()
	{
		$file = $this->LogFile();
		if(file_exists($file))
			return file_get_contents($file);
		else
			return false;
	}

	public function clearLog()
	{
		$file = $this->LogFile();
		@unlink($file);
	}


}
?>