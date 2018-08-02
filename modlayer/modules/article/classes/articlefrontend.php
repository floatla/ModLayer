<?php
Class ArticleFrontend {
	
	
	public static function RenderDefault(){}


	public static function RenderCollection()
	{
		$article      = new Article();
		$categoryName = Util::getvalue('categoryName', false); 
		$categoryId   = Util::getvalue('category_id', false); 
		$tag_id       = Util::getvalue('tag_id', false); 
		$category     = false;

		if($categoryName){
			$cat  = new Category();
			$item = $cat->item();
			$category = $item->GetFromCache($categoryName);
		}

		if($categoryId){
			$cat  = new Category();
			$item = $cat->item($categoryId);
			$category = $item->GetFromCache($categoryId);
		}

		$options = array(
			'state'    => '1,3',
			'pageSize' => 10,
			'sort'     => 'created_at',
			'order'    => 'DESC',
			'inTag'    => $tag_id,
			// 'debug' => true,
		);

		if($category) { $options['inCategory'] = $category['category_id-att']; }

		// Util::debug($options);
		// die;
		$collection = $article->Collection( $options );

		$skin = Skin::Load();
		$skin->setcontent(
			$collection->LoadFromCache(),
			null, 
			'collection'
		);

		if($category){
			$skin->setcontent(
				$category,
				null, 
				'category'
			);			
		}
		$skin->add("article/list.xsl");
		$skin->display();
	}

	public static function RenderItem()
	{
		$id = Util::RuleParam('id');

		$article = new Article();
		$item = $article->item($id);
		
		$item = $item->LoadFromXML();
		
		if($item)
		{
			$skin = Skin::Load();
			$skin->setcontent($item, '/xml/*', null);
			$skin->add('article/item.xsl');
			$skin->display();
		}
		// Util::redirect('/not-found/404/?article-not-valid');
		Frontend::RenderNotFound();
	}

	public static function FrontRedirectUrl()
	{
		$id = Util::getvalue('id');
		$get = $_GET;

		$article = new Article();
		$item = $article->item($id);
		$item = $item->LoadFromXML();

		if($item)
		{
			$xml = new DOMDocument('1.0', 'UTF-8');
			$xml->load($item);

			$url = $xml->getElementsByTagName('object_url');

			if(!$url->item(0)){
				Util::redirect('/error/404/?article-not-valid');
			}

			$location = '/article/'.$id.'/'.$url->item(0)->nodeValue;
			if(!empty($get)){
				$location .= '/?';
				foreach ($get as $param => $value) {
					$location .= $param . '=' . $value . '&';
				}
			}

			header ('HTTP/1.1 301 Moved Permanently');
  			header ('Location: '.$location);
  			die;
		}
		else
		{
			Util::redirect('/error/404/?article-not-valid');
		}
	}

	public static function RenderAjaxList()
	{
		$parent_id   = Util::getvalue('parent_id');
		$currentPage = Util::getvalue('currentPage', 1);
		$pageSize     = Util::getvalue('pageSize', 5);

		$article    = new Article();
		$collection = $article->Collection(
			array(
				'parent_id'   => $parent_id,
				'currentPage' => $currentPage,
				'pageSize' => $pageSize,
				'state'    => 1,
				'sort'     => 'created_at',
				'order'    => 'DESC',
			)
		);

		$skin = Skin::load();
		$skin->setcontent($collection->GetCached(), null, 'collection');
		$skin->setparam('parent_id', $parent_id);
		$skin->add("article/list.ajax.xsl");
		$skin->display();
	}

}
?>