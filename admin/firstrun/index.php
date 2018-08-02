<?php

	// Inicializar el framework
	require_once (dirname(dirname(dirname(__FILE__))) . "/modlayer/load.php");

	$data = $_POST;

	
	//  Process data
	if(!empty($data['database_name']))
	{
		
		$app_name   = $data['app_name'];
		$app_url    = $data['app_url'];
		$db_name    = $data['database_name'];
		$db_host    = $data['database_host'];
		$db_user    = $data['database_user'];
		$db_pass    = $data['database_pass'];
		$adminpath  = $data['adminpath'];


		$configFile = Configuration::GetConfigFile();

		$dom = new DOMDocument("1.0", "UTF-8");
		$dom->formatOutput = true;
		$dom->load($configFile);

		// App Name
		replaceNode($dom, 'applicationID', $app_name);

		// Admin Path
		replaceNode($dom, 'adminpath', $adminpath);

		// Domain
		replaceNode($dom, 'domain', $app_url);
		replaceNode($dom, 'assets_domain', $app_url);
		replaceNode($dom, 'content_domain', $app_url);

		// Database name
		replaceNode($dom, 'dbname', $db_name);

		// Database host
		replaceNode($dom, 'host', $db_host);

		// Database user
		replaceNode($dom, 'user', $db_user);

		// Database pass
		replaceNode($dom, 'pass', $db_pass);

		// Save Configuration
		$dom->save($configFile);

		// Create Tables
		createTables();

		// Create User Roles
		$roles     = Configuration::Query("/configuration/accessLevel/user");
		$levels    = new AdminLevels();
		$adminUser = new AdminUser();

		foreach($roles as $user)
		{
			$dto = array(
				'user_level_id'   => $user->getAttribute('weight'),
				'user_level_name' => $user->getAttribute('rol'),
			);
			$levels->AddAccessLevel($dto);
		}

		// Create User Admin
		$user = array(
			'username'      => $data['username'],
			'user_password' => $data['user_password'],
			'user_name'     => $data['user_name'],
			'user_lastname' => $data['user_lastname'],
			'user_email'    => $data['user_email'],
			'access_level'  => 1,
		);
		$user_id = $adminUser->Add($user);
		
		displayPage($step=2);
		
	}
	else
	{
		displayPage();
	}





	/* Functions */
	function replaceNode($dom, $node, $value)
	{
		$old = $dom->getElementsByTagName($node)->item(0);
		$new = $dom->createElement($node, $value);
		$old->parentNode->replaceChild($new, $old);
	}

	function createTables()
	{
		// Crear las tablas solo para los modules instalados y activos
		$modules  = Configuration::Query('/configuration/modules/module');
		foreach($modules as $module)
		{
			if($module->getAttribute('model'))
			{
				$model           = $module->getAttribute('model');
				$modelReflection = new ReflectionClass($model);
				$tables          = $modelReflection->getStaticPropertyValue('tables');
				Model::parsecreateTable($tables);
			}
		}
	}

	function displayPage($step=1)
	{
		$template  = new Templates();
		$dir       = PathManager::GetApplicationPath();
		$module    = Configuration::GetModuleConfiguration('admin');
		$adminPath = substr(PathManager::GetFrameworkDir(),0,strlen(PathManager::GetFrameworkDir())).$module->getAttribute('path');
		$sysNodes  = Configuration::Query("/configuration/*[not(*) or name() = 'database']");

		
		//PageUrl
		$request = $_SERVER["REQUEST_URI"];
		if(strpos($request,'?')){$request = substr($request,0,strpos($request,'?'));}

		$domain  = (isset($_SERVER['HTTP_HOST'])) ? $_SERVER['HTTP_HOST'] : $_SERVER['SERVER_NAME'];

		$template->setparam(
			"page_url",
			$request
		);
		$template->setparam(
			"domain",
			$domain
		);
		
		$template->setconfig(
			$sysNodes,
			null,
			'system'
		);
		$template->setparam(
			'adminPath', 
			$adminPath
		);
		$template->setparam(
			'step', 
			$step
		);
		$template->setBaseStylesheet(
			$dir.'/admin/firstrun/install.xsl'
		);
		$template->display();
	}
?>