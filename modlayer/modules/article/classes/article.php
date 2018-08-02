<?php
class Article extends Element
{
	public function __construct($params = false)
	{
		
		$options = array(
			'module' => 'article',
			'tag'    => ArticleModel::$tag, // Solo se usa para el item
		);

		if(empty($params)) $params = array();

		$options = Util::extend(
			$options,
			$params
		);

		parent::__construct($options);
	}

	/**
	*	Sobre escribimos Item para retornar un objeto
	*	ArticleItem
	*	@param $id (required) : id del elemento
	*	@param $params (optional) : parametrización de la clase
	*	@return Item object
	*/
	public function Item($id = false, $params = false)
	{
		if(empty($params)) $params = array();

		$thisParams = array(
			'getTags' => true,
			'getRoles' => true,
		);
		$params = array_merge($thisParams, $params);
		
		$this->params = Util::extend(
			$this->params,
			$params
		);
		return new ArticleItem($id, $this->params);
	}

	/**
	*	Collection es una instancia de la clase collection
	*	que se encarga de manipular listados
	*	@param $params (optinal) parametrización de la clase
	*	@return Collection object
	*/
	public function Collection($params = false)
	{
		if(empty($params)) $params = array();
		$thisParams = array(
			'getTags' => true,
		);
		$params = array_merge($thisParams, $params);

		$this->params = Util::extend(
			$this->params,
			$params
		);
		
		if(Application::isFrontend())
		{
			$this->params['metadata'] = false;
			$this->params['setSession'] = false;
		}
		return new ElementCollection($this->params);
	}

	/**
	* Search es llamado desde el módulo Search para realizar búsquedas en el frontend
	*/
	public function Search($query, $currentPage)
	{
		$collection = $this->Collection(
			array(
				'q' => $query,
				'currentPage' => $currentPage,
				'state' => 1,
				'pageSize' => 10,
				// 'debug' => true,
			)
		);

		$collection->Search();
		return $collection->GetItems();
	}

	public function autoSave($dto)
	{
		$opt = array(
			'module'       => 'article',
			'folderoption' => 'target'
		);
		$dir  = PathManager::GetContentTargetPath($opt);
		$file = $dir .'/'.$dto['article_id'].'.json';

		file_put_contents($file, json_encode($dto)); 

	}

	public function autoSaveGet($id)
	{
		$opt = array(
			'module'       => 'article',
			'folderoption' => 'target'
		);
		$dir  = PathManager::GetContentTargetPath($opt);
		$file = $dir .'/'.$id.'.json';

		if(file_exists($file))
		{
			return file_get_contents($file);
		}
		else
		{
			return false;
		}

	}

	public function FlushAutoSave($id)
	{
		$opt = array(
			'module'       => 'article',
			'folderoption' => 'target'
		);
		$dir  = PathManager::GetContentTargetPath($opt);
		$file = $dir .'/'.$id.'.json';

		if(file_exists($file))
		{
			unlink($file);
		}
	}


	public function AddAsset($id, $asset)
	{

	}

	public static function GetByTag()
	{
		$tag_id = Util::getvalue('tag_id');

		if(!empty($category_id))
		{
			$a = new Article();
			$c = $a->Collection(
				array('inTag' => $tag_id)
			);

			return $c->LoadFromCache();
		}
		return false;
	}

	public static function GetByCategory()
	{
		$category_id = Util::getvalue('category_id');

		if(!empty($category_id))
		{
			$a = new Article();
			$c = $a->Collection(
				array('inCategory' => $category_id)
			);
			return $c->LoadFromCache();
		}
		return false;
	}


}
?>