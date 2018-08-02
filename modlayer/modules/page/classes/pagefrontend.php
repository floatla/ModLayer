<?php
Class PageFrontend {
	
	/* FRONTEND METHODS*/

	public static function RenderDefault(){ die; }


	/* 
		Landing que recibe clicks desde facebook en el link de "via XXX" 
		Se redirecciona a la fanpage de la app o al raiz
	*/
	public static function FrontFacebookRedirect()
	{
		$skin = new Skin();
		$xml  = $skin->GetXML();

		$dom = new XMLDom();
		$dom->loadXML($xml);

		$fanpage = $dom->query('/xml/configuration/skin/accounts/facebook/fanpage');
		if($fanpage){
			Util::redirect($fanpage->item(0)->nodeValue);
		}else{
			Util::redirect('/');
		}
		
	}

	public static function RenderItem()
	{
		$id = Util::getvalue('id');

		$element = new Page();
		$item = $element->item($id);
		
		$item = $item->LoadFromXML();
		
		if($item)
		{
			$Skin = Skin::Load();
			$skin->setcontent($item, '/xml/*', null);
			$skin->add('page/page.xsl');
			$skin->display();
		}

		Frontend::RenderNotFound();
	}




	
}
?>