<?php
Class FileUpload
{
	public $path;
	private $params;
	private $accept = array();
	private $type;
	private $status;
	

	public $target;
	public $tempFile;

	public function __construct($params = false)
	{
		$this->params = array(
			'module'       => 'multimedia',
			'folderoption' => 'target',
			'type_id'      => false,
			'user_id'      => 0,
			'user_type'    => '',
			'internalCall' => false,
		);

		if(empty($params)) $params = array();
		$this->params = Util::extend(
			$this->params,
			$params
		);


		if(!$this->params['internalCall']) {
			if(!$user = Admin::Logged())
				throw new Exception("You need to be authenticated on the system.", 1);
		}
		if( $_SERVER['REQUEST_METHOD'] == 'OPTIONS' ) {
			throw new Exception("OPTIONS method not permitted.", 1);
		}

		if( strtoupper($_SERVER['REQUEST_METHOD']) != 'POST' ) {
			throw new Exception("Upload is only allowed via POST.", 1);
		}
	}

	/**
	 * Retrieve File List
	 * @return array
	 */
	public function getFiles(){
		$files = array();

		// http://www.php.net/manual/ru/reserved.variables.files.php#106558
		foreach($_FILES as $firstNameKey => $arFileDescriptions ){
			foreach( $arFileDescriptions as $fileDescriptionParam => $mixedValue ){
				$this->rRestructuringFilesArray($files, $firstNameKey, $_FILES[$firstNameKey][$fileDescriptionParam], $fileDescriptionParam);
			}
		}
		$this->determineMimeType($files);

		if(empty($files))
			return false;

		$this->tempFile = $files['file'];
		return	$this->tempFile;
	}


	private function rRestructuringFilesArray(&$arrayForFill, $currentKey, $currentMixedValue, $fileDescriptionParam){
		if( is_array($currentMixedValue) ){
			foreach( $currentMixedValue as $nameKey => $mixedValue ){
				$this->rRestructuringFilesArray(
					$arrayForFill[$currentKey],
					$nameKey,
					$mixedValue,
					$fileDescriptionParam
				);
			}
		} else {
			$arrayForFill[$currentKey][$fileDescriptionParam] = $currentMixedValue;
		}
	}


	private function determineMimeType(&$file){
		if( function_exists('mime_content_type') ){
			if( isset($file['tmp_name']) && is_string($file['tmp_name']) ){
				if( $file['type'] == 'application/octet-stream' ){
					$mime = mime_content_type($file['tmp_name']);
					if( !empty($mime) ){
						$file['type'] = $mime;
					}
				}
			}
			else if( is_array($file) ){
				foreach( $file as &$entry ){
					$this->determineMimeType($entry);
				}
			}
		}
	}
	/**
	*	Run inicaliza el proceso de copiado
	*	del archivo subido
	*/
	public function Deposit()
	{
		$origin     = $this->tempFile['tmp_name'];
		$tmpNameArr = explode(DIRECTORY_SEPARATOR, $this->tempFile['tmp_name']);
		$tmpName    = $tmpNameArr[count($tmpNameArr) - 1];
		
		$this->target = $this->path . DIRECTORY_SEPARATOR . $tmpName;

		@rename($origin, $this->target);
		@chmod($target, 0775);
	}
	
	/**
	*	Accept recibe cada tipe (mime/type) permitidos en esta instancia
	*	de upload
	*/
	public function Accept($type)
	{
		$this->accept[] = $type;
	}

	/**
	*	MaxSize setea el peso maximo permitido en MB (con un espacio)
	*	Ej. 4 MB 
	*/
	public function MaxSize($size)
	{
		$this->maxsize = $size;
	}

	/**
	*	setTarget setea la ruta del archivo subido
	*	Si no recibe ninguna ruta, se usa la logica del sistema desde la configuracion
	*/
	public function setTarget($path)
	{
		$this->path = $path;
	}

	/**
	*	isAccepted valida el tipo (mime/type) del archivo subido
	*	contra los permitidos en esta instancia
	*/
	public function isAccepted()
	{
		if(!in_array($this->tempFile['type'], $this->accept))
		{
			throw new Exception("El tipo de archivo <b>".$this->tempFile['type']."</b> de ".$this->tempFile['name']." no es válida", 1);
		}
	}

	/**
	*	checkSize valida el peso del archivo subido
	*	contra el permitido en esta instancia
	*/
	private function checkSize()
	{
		$max   = str_replace(' MB', '', $this->maxsize);
		$limit = ceil($this->tempFile['size'] / 1000) / 1000;

		if($limit > $max)
		{
			throw new Exception("El peso del archivo ".$this->tempFile['name']." ($limit MB) es superior al permitido ($max MB)", 1);
		}
	}

	public function FilePath($id, $json = false)
	{
		$option = ($json) ? 'json' : 'xml'; 
		$options = array(
			'module'       => 'element',
			'folderoption' => $option,
		);

		$path   = PathManager::GetContentTargetPath($options);
		$folder = PathManager::GetDirectoryFromId($path, $id);
		return $folder.'/'.$id.'.'.$option;
	}

	/**
	*	GetName retorna la extension para el tipo de archivo
	*	que se esta subiendo
	*/
	public function GetName()
	{
		return $this->tempFile['name'];
	}

	/**
	*	GetExtension retorna la extension para el tipo de archivo
	*	que se esta subiendo
	*/
	public function GetExtension()
	{
		$explode = explode('.', $this->tempFile['name']);
		return strtolower($explode[count($explode)-1]);
	}

	/**
	*	Status retorna un array con los datos del upload
	*/
	public function Status()
	{
		return array(
			'status'	=> $this->status,
			'target'	=> $this->path,
			'type_id'	=> $this->params['type_id'],
			'extension' => $this->GetExtension(),
			'name'      => $this->GetName(),
		);
	}

	/**
	*	Move sirve para mover el archivo subido a otro directorio
	*/
	public function Move($targetFile)
	{
		$origin = $this->target;
		@rename($origin, $targetFile);
		@chmod($targetFile, 0775);
	}
}
?>