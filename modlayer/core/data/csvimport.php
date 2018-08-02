<?php
Class CsvImport
{
	private $fp;
	private $header;
	private $delimiter = ',';
	private $shows = array();

	/**
	*	Al inicializar la clase, se lee el archivo CSV a importar
	*	y se carga en la variable $this->fp. Removiendo las comillas dobles de todos los campos.
	*	Separando cada registro por los saltos de línea.
	*	@param $file_name : string con la ruta del archivo
	*	@return void
	*/
	public function __construct($file_name, $delimiter=false)
	{
		if($delimiter) $this->delimiter = $delimiter;

		$string = file_get_contents($file_name);
		$string = str_replace('"', '', $string);

		$this->fp = explode("\n", $string);
		
		// La primera línea es el header
		$this->header = $this->fp[0];
		unset($this->fp[0]);

		$this->format();
	}

	public function __destruct()
	{
		if($this->fp) {
			$this->fp = array();
		}
	}


	/**
	*	Format parsea la variable $this->fp y crea un array mas legible con los datos del programa
	*	
	*	@return void
	*/
	public function Format()
	{
		
		$header = explode($this->delimiter, $this->header);
		array_walk($header, function(&$v, $i){
			$v = strtolower($v);
			$v = str_replace("Ñ", 'n', $v);
			$v = str_replace(" / ", '_', $v);
			$v = str_replace("\r", '', $v);
			$v = str_replace("\n", '', $v);
		});
		
		foreach($this->fp as $i=>$str)
		{
			if(!$this->EmptyLine($str))
			{
				$fields = explode($this->delimiter, $str);
				$rowData = array();
				foreach($header as $index=>$name)
				{
					$rowData[$name] = $fields[$index];
					$this->fp[$i] = $rowData;
				}
			}
			else{
				$rowData = array('separador' => 1);
				$this->fp[$i] = $rowData;
				// unset($this->fp[$i]);
			}
		}
	}

	private function EmptyLine($str)
	{
		$str = str_replace($this->delimiter, '', $str);
		$str = preg_replace("/\s/", "", $str);
		return empty($str);
	}

	/**
	*	Get retorna la variable $fp con los datos de los programas
	*	@return array
	*/
	public function Get()
	{
		return $this->fp;
	}

}
?>