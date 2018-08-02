<?php
class ClipFrontend
{
	public static function FrontAjaxClip()
	{
		$id = Util::getvalue('id');

		$element = new Clip();
		$item = $element->item($id);
		
		$item = $item->LoadFromXML();
		
		if($item)
		{
			$skin = Skin::Load();
			$skin->setcontent($item, '/xml/*', null);
			$skin->add('clip/json.clip.xsl');
			$skin->display();
		}
		else
		{
			echo '{"id":"0"}';
		}
	}
}
?>