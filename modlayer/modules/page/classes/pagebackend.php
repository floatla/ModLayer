<?php
class PageBackend extends ElementController
{
	

	/**
	* BackEdit extiende el método de element controller para agregar la regla de rewrite
	* @return void.
	**/
	public static function BackEdit()
	{
		if(!empty($_POST['page_url']))
		{
			$method = 'RenderItem';
			$args   = 'id=' . $_POST['page_id'];
			$match  = $_POST['page_url'];
			$id     = $_POST['page_id'];

			Application::RewriteRule($match, $method, $args, $id);
		}
		/*
			El parent procesa los datos
		*/
		parent::BackEdit();
	}

	/**
	*	BackDelete extiende el método de element controller para eliminar la regla de rewrite
	*	@return void
	*/
	public static function BackDelete()
	{
		$id = Util::getvalue('item_id');
		Application::DeleteRewriteRule($id);

		/*
			El parent procesa los datos
		*/
		parent::BackDelete();
	}

}
?>