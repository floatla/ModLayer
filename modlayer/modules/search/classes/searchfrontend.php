<?php
class SearchFrontend
{
	
	public static function RenderSearch()
	{
		$query        = Util::getvalue('q');
		$currentPage  = Util::getvalue('page', 1);
		$cid          = Util::getvalue('cid');
		$tid          = Util::getvalue('tid');

		$categories = [];
		$tags       = [];
		
		if($cid){
			$categories = explode(',', ltrim($cid, ','));
		}

		if($tid){
			$tags = explode(',', ltrim($tid, ','));
		}

		if(get_magic_quotes_gpc()){
			$query = stripslashes($query);
		}

		$skin = new Skin();

		// if($query != '' && strlen($query) >= 3)
		// {
			$query = str_replace('""', '', $query);
			$query = str_replace("''", "", $query);
			
			// $search = Search::GetResult($query, $currentPage);
			$search = Search::FetchResults([
				'query'       => $query,
				'categories'  => $categories,
				'tags'        => $tags,
				'currentPage' => $currentPage,
			]);
			$skin->setcontent($search, null, 'search');
			$skin->setparam('query', htmlentities($query));
		// }
		// else
		// {
		// 	$skin->setparam('message', Configuration::Translate('backend_messages/query_too_short'));
		// }

		// Util::debug($search);
		// die;

		$categories['tag'] = 'category_id';
		$tags['tag'] = 'tag_id';

		$skin->setcontent($categories, null, 'categories');
		$skin->setcontent($tags, null, 'tags');
		$skin->add('search/result.xsl');
		$skin->display();
	}
	
}
?>