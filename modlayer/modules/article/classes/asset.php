<?php
Class Asset {
	
	private $dbtable;
	private $structure;
	private $articleId;
	private $uid;
	private $data;

	public function __construct()
	{
		$this->uid       = strtotime('now');
		$this->dbtable   = 'article_assets';
		$this->structure = ArticleModel::$tables;
	}

	Public function GetUid()
	{
		return $this->uid;
	}

	Public function SetArticle($id)
	{
		$this->articleId = $id;
	}

	Public function Set($data)
	{
		$this->data = $data;
	}

	Public function Save()
	{
		$query = new Query();
		$query->table($this->dbtable);
		$query->fields(
			array(
				'uid'        => $this->uid,
				'article_id' => $this->articleId,
				'asset'      => $this->data,
			)
		);
		return $query->insert();
	}

	Public function Get()
	{
		$query = new Query();
		$query->table($this->dbtable);
		$query->filter('article_id = :id');
		$query->param(':id', $this->articleId, 'int');

		$r = $query->select();
		return (!empty($r)) ? $r : false;
	}

	Public function GetGroup($ids)
	{
		$query = new Query();
		$query->table($this->dbtable);
		$query->filter('article_id = :id');
		$query->param(':id', $this->articleId, 'int');

		$query->filter('uid in ('.$ids.')');
		
		$r = $query->select();
		return (!empty($r)) ? $r : false;
	}



}

?>