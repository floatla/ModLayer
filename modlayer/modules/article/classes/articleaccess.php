<?php
Class ArticleAccess {

	/*
	*	Publish valida el nivel de acceso de los usuarios al publicar una nota
	*/
	Public static function Publish()
	{
		$user = Admin::Logged();
		// Util::debug($user);

		if($user['access'] != 'administrator' && $user['access'] != 'editor')
		{
			$response = array(
				'code'    => 405,
				'message' => Configuration::Translate('backend_messages/publish_not_allowed'),
			);
			Util::OutputJson($response);
		}
	}
	
	Public static function EventList()
	{
		// Manejar lo que se necesite antes de mostrar un listado
	}

	Public static function EventAdd()
	{
		// Manejar lo que se necesite antes de mostrar un listado
		// echo "Evento Article.Add: Validar si el usuario puede agregar notas";
		// die;
	}
	
}
?>