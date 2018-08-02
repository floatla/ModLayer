<?php
class ClipBackend extends ElementController 
{
	public static function RenderPreview()
	{
		$id     = Util::getvalue('id');
		$ytplay = Util::getvalue('ytplay');

		$element = new Clip();
		$item = $element->item($id);
		$data = $item->Get();

		if(!$data)
			Application::Route(
				array(
					'module' => 'clip'
				)
			);

		parent::loadAdminInterface($base='modal.preview.xsl');
		parent::$template->setcontent(
			$data, 
			null, 
			'clip'
		);
		
		$modVid = Configuration::GetModuleConfiguration('video');
		if($modVid)
			parent::$template->setcontext($modVid, null,'video_configuration');

		parent::$template->setparam('ytplay', $ytplay);
		parent::$template->display();
	}

	public static function RenderEmbedModal()
	{
		$item_id = Util::getvalue('item_id');
		$module  = Util::getvalue('module');

		if($item_id)
		{
			$el   = new $module();
			$item = $el->item($item_id);
			$relations = $item->GetRelations();

			parent::loadAdminInterface($base='modal.embed.xsl');
			parent::$template->setcontent($relations, null, 'relations');
			parent::$template->setparam('item_id', $item_id);
			parent::$template->setparam('module', $module);
			parent::$template->display();
		}
	}

	public static function RenderYoutube()
	{
		$pageToken = Util::getvalue('pageToken');
		$query     = Util::getvalue('term');

		$yt = new Youtube();
		$service = $yt->getService();

		$options = array(
			// 'channelId' => 'UCjy3d0jZMJKUVi836J1Nq5w',
			'maxResults' => 12,
			
		);

		

		if($pageToken)
			$options['pageToken'] = $pageToken;

		if($query)
			$options['q'] = $query;

		try
		{
			$searchResponse = $service->search->listSearch('id,snippet', $options);
		
			$clip = new Clip();

			$response = array(
				'currentPage-att' => Util::getvalue('page', 1),
				'pageSize-att' => $searchResponse['pageInfo']['resultsPerPage'],
				'total-att'    => $searchResponse['pageInfo']['totalResults'],
				'tag'          => 'item',
				'nextPageToken-att' => $searchResponse['nextPageToken'],
				'prevPageToken-att' => $searchResponse['prevPageToken'],
			);

			
			foreach ($searchResponse['items'] as $searchResult) {
				$item = array(
					'title' => $searchResult['snippet']['title'],
					'id'    => $searchResult['id']['videoId'],
					'description' => $searchResult['snippet']['description'],
					'image' => $searchResult['snippet']['thumbnails']['medium']['url'],
					'imported' => ($clip->inDB($searchResult['snippet']['title'])) ? 1 : 0,
				);
				
				
				$response[] = $item;
			}

			parent::loadAdminInterface();
			parent::$template->setcontent($response, null, 'collection');
			parent::$template->add('youtube.xsl');
			if($query)
				parent::$template->setparam('term', $query);
			parent::$template->display();

		}
		catch(Exception $e){
			echo $e->getMessage();
		}
	}
	
	public static function ImportYoutube()
	{
		$youtube_id = Util::getvalue('id');

		try{

			$clip = new Clip();

			$data    = $clip->YoutubeFetch($youtube_id);
			$clip_id = $clip->Add($data, true);
			
		
			$json = array(
				'code' => 200,
				'message' => 'ok',
				'clip' => $clip_id, 
			);

		}
		catch(Exception $e){
			// echo $e->getMessage();
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($json);
	}

	public static function ImportClip()
	{
		$dto = array(
			'clip_id' => Util::getvalue('clip_id'),
			'clip_youtube' => Util::getvalue('url'),
			'clip_title' => '',
		);

		try{

			$clip = new Clip();
			$clip_id = $clip->Edit($dto);
			
		
			$json = array(
				'code' => 200,
				'message' => 'ok',
				'clip' => $clip_id,
			);

		}
		catch(Exception $e){
			// echo $e->getMessage();
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($json);
	}
}
?>