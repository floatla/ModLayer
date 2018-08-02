<?php
Class ArticleBackend extends ElementController
{
	public static function RenderPreview()
	{
		$id = Util::getvalue('id');
		$article = new Article();
		
		$item = $article->item($id);		
		$data = $item->Get();

		if(!$data) Application::Route(array('module'=>'article'));

		$skin = Skin::Load();
		$skin->setcontent($data, null, 'article');
		$skin->add('article/item.xsl');
		$skin->display();
	}

	public static function BackAutosave()
	{
		$dto = $_POST;
		$article = new Article();

		try
		{		
			$article->autoSave($dto);
			$response = array(
				'code' => 200,
				'message' => 'Ok',
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

	public static function BackGetAutoSave()
	{
		$id = Util::getvalue('id');
		$article = new Article();
		$item = $article->autoSaveGet($id);

		$response = array(
			'code' => ($item) ? 200 : 302,
			'message' => 'Ok',
			'item' => ($item) ? json_decode($item) : 0,
		);
		
		Util::OutputJson($response);
	}

	public static function BackUnsetAutoSave()
	{
		$id = Util::getvalue('id');
		$article = new Article();
		$article->FlushAutoSave($id);

		$response = array(
			'code' => 200,
			'message' => 'Ok',
		);
		
		Util::OutputJson($response);
	}


	public static function DisplayAssets()
	{
		$id = Util::getvalue('item_id');

		parent::loadAdminInterface($base='modal.assets.xsl');
		parent::$template->setparam('item_id', $id);

		parent::$template->display();		
	}

	public static function AddAsset()
	{
		$data = $_POST;

		if(!empty($data['item_id']) && !empty($data['asset']))
		{
			/*
				Necesitamos que el código externo esté bien formado.
			*/
			$html = new XMLDom();
			$html->loadHTML($data['asset']);

			$nodes = $html->query('//body/*');
			$assetStr = '';
			foreach($nodes as $node)
			{
				$assetStr .= $html->saveXML($node);
			}

			$asset = new Asset();
			$asset->SetArticle($data['item_id']);
			$asset->Set($assetStr);
			$asset->Save();


			$response = array(
				'code' => 200,
				'message' => 'Ok',
				'uid' => $asset->GetUid(),
				'asset' => $data['asset'],
			);
			
			Util::OutputJson($response);
			die;


			$class = new Article(
				array(
					'getMultimedias'  => false,
		            'getCategories'   => false,
		            'getRelations'    => false,
		            'getParent'       => false,
		            'applyFormat'     => true,
		            'internalCall'    => true,
				)
			);
			$item = $class->item($data['item_id']);

			$article = $item->Get();

			$assets = false;
			if(!empty($article['external_assets'])){
				$assets = (string)$article['external_assets'];
			}


			$dom = new XMLDom();
			$dom->formatOutput = true;

			if(!$assets){
				$root = $dom->createElement('assets');
			}
			else{
				$dom->loadXML($assets);
				$root = $dom->query('/assets')->item(0);
			}
			
			// echo $data['asset'];

			$dom->appendChild($root);
			$html = new XMLDom();
			$html->loadHTML($data['asset']);

			$nodes = $html->query('//body/*');
			
			$newnode = $dom->createElement('asset');
			$newnode->setAttribute('uid', strtotime('now'));

			foreach($nodes as $node){
				$nodeImport = $dom->importNode($node, true);
				$newnode->appendChild($nodeImport);
			}
			$root->appendChild($newnode);

			$dto = array(
				'article_id' => $data['item_id'],
				'external_assets' => $dom->saveXML($dom->documentElement),
			);
			
			$id = $class->Edit($dto);

			$response = array(
				'code' => 200,
				'message' => 'Ok',
			);
			
			Util::OutputJson($response);
		}
		else
		{
			Application::Route(array('module' => 'article'));
		}
	}

	public static function AssetsByArticle()
	{
		sleep(2);
		$id   = Util::getvalue('id');
		$list = json_decode(Util::getvalue('list'));
		$ids  = implode(',', $list);

		$assetsArr = array();

		if(!empty($ids)){
			$asset = new Asset();
			$asset->SetArticle($id);

			$assetsArr = $asset->GetGroup($ids);
		}

		Util::OutputJson(
			array(
				'code' => 200,
				'message'=> 'ok',
				'assets' => $assetsArr,
			)
		);
	}
}
?>