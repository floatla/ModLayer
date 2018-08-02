<?php
Class FileItem extends Item
{
	protected $customField = 'object_custom';
	protected $localData = array();

	public function __construct($id, $params = false)
	{
		parent::__construct($params);


		$this->id = $id;
		$this->dbtable   = MultimediaModel::$table;
		$this->structure = MultimediaModel::$tables;

		$this->setPrimaryKey('multimedia_id');
		$this->setParam('getMultimedias', false);
		$this->setParam('getRelations', false);
	}

	/**
	* Se valida no solo el ID para multimedias, sino tambien el type_id
	* Para evitar errores al retornar datos de un multimedia que no pertenece al modulo que lo
	* está pidiendo.
	* @return array
	*/
	public function Get()
	{
		try
		{
			$this->addQueryFilter('multimedia_id = :id', ':id', $this->id, 'int');
			$this->addQueryFilter('multimedia_typeid = :typeid', ':typeid', $this->params['type_id'], 'int');
			return parent::Get();
		}
		catch(Exception $e){
			// El id no existe
			if(Application::isFrontend())
				return false;

			throw new Exception( $e->getMessage() );
			
		}
	}

	/**
	*	applyFormat aplica el formato del modelo a los items
	*	Segun parametrizacion de la clase
	*	@return void
	*/
	public function applyFormat()
	{
		if($this->params['applyFormat'])
		{
			$conf   = $this->ItemConf();
			$model  = $conf->getAttribute('model');

			$reflection = new ReflectionClass($model);

			$this->data = call_user_func_array(
				array(
					'Model', 
					'parseFieldsFromObjects'
				), 
				array(
					array($this->data), // El modelo espera un array
					$reflection->getStaticPropertyValue('table'),
					$reflection->getStaticPropertyValue('tables'),
					$reflection->getStaticPropertyValue('multimediaFields'),
					$verbose=true
				)
			);
			$this->data = $this->data[0];
		}
		
		if(!empty($this->raw[$this->customField]))
		{
			$customFields = unserialize($this->data[$this->customField]);
			unset($this->data[$this->customField]);
			$this->data = array_merge($this->data, $customFields);
		}
	}


	/* 
	*	touch actualiza el estado de un item y se utiliza cuando se realiza algún cambio a un item publicado
	*	que no impacta directamente en el registro de la base
	*	como agregar o eliminar una categoría o relación
	*/
	public function touch()
	{
		if(isset($this->data['multimedia_state']) && $this->data['multimedia_state'] == 1)
		{
			$this->SetProperty('multimedia_state', 3);
			$this->Save();
		}
	}

	private function ItemConf()
	{
		$type_id  = $this->params['type_id'];
		return Configuration::Query("/configuration/modules/module[@multimedia_typeid = '". $type_id ."']")->item(0);
	}

	/**
	*	Trash sobreescribe el metodo de Item para eliminar un item
	*	Realiza un borrado logico y limpia registros que tengan el item_id como parent
	*	@return boolean
	*/
	public function Trash()
	{

		
		$sql   = 'SELECT * FROM multimedia where multimedia_id = '.$this->id;
		$query = new Query();
		$resp  = $query->run($sql);
		$this->data = (isset($resp[0])) ? $resp[0] : false;

		$im = new ItemMultimedia();
		$im->UnlinkMultimedia($this->id);

		$this->DeleteFile();
		

		parent::Trash();

	}

	/**
	*   DeleteXML elimina fisicamente el xml del item publicado
	*   @return void
	*/
	private function DeleteFile()
	{
		if($this->data)
		{
			/* Ruta del archivo segun configuracion y ID */
			$options = array(
				'module'       => $this->params['module'],
				'folderoption' => 'target',
			);

			$path   = PathManager::GetContentTargetPath($options);
			$folder = PathManager::GetDirectoryFromId($path, $this->id);
			$file   = Util::DirectorySeparator($folder.'/'.$this->id.'.'.$this->data['multimedia_source']);

			return @unlink($file);
		  }
	}

	public function WhoisUsingIt()
	{
		$im   = new ItemMultimedia();
		$list =  $im->FetchRecords($this->id);
		if($list){
			foreach($list as $k=>$item)
			{
				// Util::debug($item);
				// die;
				$module = $item['module'];
				$el     = new $module();
				$temp   = $el->item(
					$item['object_id'],
					array(
						'getMultimedias'  => false,
						'metadata'        => false,
						'getCategories'   => false,
						'getRelations'    => false,
						'getParent'       => false,
					)
				);

				if($temp->Exists())
					$list[$k]['data'] = $temp->Get(); 
			}
			$list['tag'] = 'item';
			return $list;
		}
		return false;
	}

}
?>