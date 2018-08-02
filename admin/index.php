<?php
	/* Inicializar App */
	require_once ("../modlayer/load.php");

	/* Obtener usuario logueado */
	$user = Admin::Logged();

	if($user){
		$access  = $user['access'];
		$default = Configuration::query("/configuration/accessLevel/user[@rol='".$access."']");
		if(!$default){
			echo 'El sistema no tiene definido un módulo default para el acceso "' . $access .'"';
			die;
		}
	}else{
		$default = Configuration::query("/configuration/accessLevel");
	}

	/* Iniciar flujo interno */
	Application::BackendHandler(
		$params = array(
			'module' => Util::getvalue( 'm', $default->item(0)->getAttribute('defaultModule') ),
			'action' => Util::getvalue( 'action', 'RenderDefault' )
		)
	);
?>