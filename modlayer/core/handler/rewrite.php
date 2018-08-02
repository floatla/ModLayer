<?php

Class Rewrite
{
	public static $url;

	public static function parseURL()
	{
		self::$url = $_SERVER['REQUEST_URI'];
		$frontendSecurity = Configuration::Query('/configuration/skins/skin[@default=1]/security');
		if($frontendSecurity){
			Application::SecureFront($frontendSecurity->item(0));
		}

		Application::setFrontend();

		$modules = Configuration::Query('/configuration/modules/module');
		foreach($modules as $module)
		{
			$rules = Configuration::query('rewrite/frontend/rule', $module);
			if($rules)
			{
				$controller = $module->getAttribute('frontend_controller');
				$name       = $module->getAttribute('name');
				$debug      = ($module->getElementsByTagName('rewrite')->item(0)->getAttribute('debug') == 1) ? 1 : 0;

				if($debug)
				{
					echo "module: ".$name."<br/>";
					echo "Controller: ".$controller."<br/>";
				}
				
				if(isset($rules->length))
				{
					foreach($rules as $rule)
					{
						self::MatchRule($rule, $controller, $name, $access_level=false, $debug);
					}
				}
				else
				{
					self::MatchRule($rules, $controller, $name, $access_level=false, $debug);
				}
			}
		}

		/*
			No rule was applied
			Load generic frontend rules
		*/
		Configuration::LoadFrontendRules();

		$rewrite = Configuration::Query('/configuration/rewrite');
		$debug   = $rewrite->item(0)->getAttribute('debug');

		$rules      = Configuration::Query('/rewrite/frontend/rule', $rewrite->item(0));
		$controller = "Frontend";
		
		foreach($rules as $rule)
		{
			$match = $rule->getAttribute('match');
			$class = ($rule->getAttribute('controller')) ? $rule->getAttribute('controller') : $controller;
			self::MatchRule($rule, $controller, $moduleName=false, $access_level=false, $debug);
		}

		$subject = $_SERVER['REQUEST_URI'];
		$domain = Configuration::Query('/configuration/domain')->item(0)->nodeValue;
		$subdir = Configuration::Query('/configuration/domain/@subdir');
		if($subdir){
			$domain  = $domain . $subdir->item(0)->nodeValue;
			$subject = str_replace('/' . $subdir->item(0)->nodeValue, '', $subject); 
		}

		// Util::redirect($domain . '/not-found/404/?'.$subject);
		Frontend::RenderNotFound();

	}


	public static function parseAdminURL()
	{
		$subject = self::$url = $_SERVER['REQUEST_URI'];

		$adminPath = Configuration::Query('/configuration/adminpath')->item(0)->nodeValue;
		$subdir    = Configuration::Query('/configuration/domain/@subdir');

		if($subdir){
			$path = $subdir->item(0)->nodeValue . $adminPath;
		}
		else{
			$path = $adminPath;
		}


		$subject    = str_replace($path, '', $subject);
		$params     = explode('/', $subject);

		$moduleName = $params[0];
		$adminPath  = str_replace('/', '', $adminPath);

		$moduleConfiguration = Configuration::Query('/configuration/modules/module');

		foreach($moduleConfiguration as $module)
		{
			$rules = Configuration::query('rewrite/backend/rule', $module);
			if($rules)
			{
				$controller = $module->getAttribute('backend_controller');
				$name       = $module->getAttribute('name');
				$debug      = ($module->getElementsByTagName('rewrite')->item(0)->nodeValue == 1)?1:0;

				if($debug){
					echo "module: ".$name."<br/>";
					echo "Controller: ".$controller."<br/>";
				}

				// $user  = Admin::Logged();
				// Util::debug($user);

				foreach($rules as $rule)
				{
					if($rule->getAttribute('access_level') != ''):
						$access_level = $rule->getAttribute('access_level');
					else:
						$access_level = false;
					endif;

					$match = $rule->getAttribute('match');
					$match = str_replace('{$adminPath}', $adminPath, $match);
					$match = str_replace('{$moduleName}', $moduleName, $match);
					$rule->setAttribute('match', $match);
					self::MatchRule($rule, $controller, $name, $access_level, $debug);
				}
				
			}
			else{
				//echo 'no rules<br/>';
			}
		}

		// Si la regla no existe en el modulo, me fijo si es generica
		$Configuration = Configuration::Query('/configuration/adminpath');
		
		if($adminPath == str_replace('/', '', $Configuration->item(0)->nodeValue)){
			$module =  Configuration::Query('/configuration/modules/module[@name = "'.$moduleName.'"]');
			
			if(!$module)
			{
				//echo 'module not exists';
				//die;
			}
			elseif($module->item(0)->getAttribute('active') == 1)
			{
				//echo $module->item(0)->getAttribute('active');
				$conf  = Configuration::Query('/configuration/rewrite');
				$debug = $conf->item(0)->getAttribute('debug');

				$rules = Configuration::Query('/rewrite/backend/rule', $conf->item(0));
				$controller = $module->item(0)->getAttribute('backend_controller');
				
				foreach($rules as $rule)
				{
					//echo $rule->getAttribute('match'),'<br/>';
					$match = $rule->getAttribute('match');
					$match = str_replace('{$adminPath}', $adminPath, $match);
					$match = str_replace('{$moduleName}', $moduleName, $match);
					$rule->setAttribute('match', $match);
					self::MatchRule($rule, $controller, $moduleName, $access_level=false, $debug);
				}
			}
		}
		
		


	}
	
	
	public static function MatchRule($rule, $controller, $module, $access_level=false, $debug)
	{
		// $subject   = $_SERVER['REQUEST_URI'];
		$subject   = self::$url;
		$rulematch = $rule->getAttribute('match');
		
		// echo $rulematch . ' -> ';
		/* Check if the app is running in a subdir */
		$subdir = Configuration::Query('/configuration/domain/@subdir');

		if($subdir)
		{
			$rulematch = str_replace('^', '', $rulematch);
			$rulematch = '^\\' . $subdir->item(0)->nodeValue . $rulematch;
		}
		else
		{
			$rulematch = '^' . $rulematch;	
		}
		
		// echo $rulematch . '<br/>';

		$pattern = '#'.$rulematch.'#';
		$replace = ($rule->getAttribute('args')!='') ? $rule->getAttribute('args') : false;
		$method  = $rule->getAttribute('apply');

		if(preg_match($pattern, $subject, $matches))
		{
			$controllerClass = $rule->getAttribute('controller');
			if(!empty($controllerClass)){
				$controller = $controllerClass;
			}
			
			if($debug)
			{
				Util::debug($rulematch);
				Util::debug($rule->getAttribute('args'));
				Util::debug($rule->getAttribute('apply'));
				echo preg_replace($pattern, $replace, $subject);
			}

			if($access_level)
			{
				if($user = Admin::Logged())
				{
					$user_access   = $user['access'];
					$rule_access   = $rule->getAttribute('access_level');
					$rule_redirect = $rule->getAttribute('redirect');
					if(strpos($rule_access, $user_access) === false && $rule_access != 'all')
					{
						if($rule_redirect != '')
						{
							$conf = Configuration::Query('/configuration/adminpath');
							$adminFolder = $conf->item(0)->nodeValue;
							Util::redirect($adminFolder.$module.$rule_redirect);
						}
						echo "REWRITE: You dont have access to this area";
						die();
					}
				}
			}

			Application::SetModule($module);
			Application::SetMatchedRule($rule);
			Configuration::SetModuleLanguage();
			$trigger   = $rule->getAttribute('trigger');
			$event     = (Application::isFrontend()) ? 'frontend' : 'backend';
			$event    .= '.' . $module . '.' . $method;
			$namedArgs = array('rewrite_args');

			if($replace)
			{
				$args = preg_replace($pattern, $replace, $subject);
				$args = str_replace('?','',$args);
				$args = str_replace('/','',$args);
				$args = explode('&', $args);

				
				foreach($args as $argument)
				{
					$thisArg = explode('=', $argument);
					if(isset($thisArg[0]) && isset($thisArg[1])){
						$namedArgs['rewrite_args'][$thisArg[0]] = $thisArg[1];
					}
				}
			}

			// Trigger Custom Event from rewrite rule
			if(!empty($trigger)) 
				Event::trigger($trigger, $namedArgs);

			// Trigger Default Event
			Event::trigger($event, $namedArgs);

			// Handle Request
			call_user_func_array(array((string)$controller,(string)$method), $namedArgs);
			die;
		}


	}
	
}

?>