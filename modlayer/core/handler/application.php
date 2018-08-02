<?php
class Application {

	private static $_ApplicationID = null;
	private static $_frontend = false;
	private static $_module   = false;
	private static $_MatchedRule = false;
	public static $SecureXSLTransform = false;
	public static $SecurePHPCode = false;
	public static $SecureJsonOutput = false;
	private static $securityConf;
	private static $SecurityExceptions;
	public static $User;

	public static function Initialize($environment=false)
	{
		// Load System Configuration
		Configuration::setEnvironment($environment);
		Configuration::LoadConfiguration();

		$fwpath  = PathManager::GetFrameworkPath();
		$coreDir = $fwpath . DIRECTORY_SEPARATOR . 'core';

		PathManager::AddClassPath($coreDir);

		// Add core subdirectories 
		$handle = opendir($coreDir);
		while (false !== ($item = readdir($handle))){
			if($item != '.' && $item != '..'){
				$path = Util::DirectorySeparator($coreDir.'/'.$item);
				if(is_dir($path)){
					PathManager::AddClassPath($path);
				}
			}
		}
		closedir($handle);

		// Add modules
		$dir  = PathManager::GetModulesPath();
		$handle = opendir($dir);
		while (false !== ($item = readdir($handle))){
			if($item != '.' && $item != '..'){
				$path = $dir.'/'.$item;
				if(is_dir($path)){
					$configFile = $path . '/module.configuration.xml';
				
					if(file_exists($configFile)){
						Configuration::AddModule($configFile);
					}
				}
			}
		} // endwhile
		closedir($handle);

		$modules = Configuration::Query('/configuration/modules/*');

		foreach($modules as $module){
			if($module->getAttribute('active') == 1) {
				$directory = Util::DirectorySeparator($fwpath . $module->getAttribute('path').'/classes');
				PathManager::AddClassPath($directory);
			}
		}
		PathManager::Apply();
		Configuration::SetLanguage();
		Configuration::RegisterEvents();
	}

	public static function BackEndHandler($options)
	{
		//Check if the call is made whitin the backend
		if(!Util::isAdmin())
			die('You are not in the backend.');


		if(!Admin::Logged())
			self::GotoLogin();


		Configuration::LoadBackendRules();
		Rewrite::parseAdminURL();

				
		Application::SetModule($options['module']);
		Configuration::SetModuleLanguage();
		

		$modDir = PathManager::GetFrameworkPath () . '/modules/' . $options['module'];
		if(is_dir($modDir))
		{
			if ($options['action'])
			{
				$delimiter = strpos ( $options['action'], '|' );
				if ($delimiter === false)
				{
					$method = ($options['action'] != '') ? $options['action'] : false;
				}
				else
				{
					$params = explode('|', $options['action']);
					$method = $params [0];
					array_shift($params);
					foreach($params as $param) :
						$_POST [substr($param, 0, strpos($param, '=' ))] = substr($param, strpos($param, '=') + 1, strlen($param));
					endforeach;
				}
			}
			else
			{
				$method = $options['action'];
			}

			//Check if the user has authorization to access the request area
			self::hasAccessToMethod($options['module'], $method);

			$conf = Configuration::query('/configuration/modules/module[@name="'.$options['module'].'"]');
			$controller = $conf->item(0)->getAttribute('backend_controller');

			if (is_callable ( array (( string ) $controller, $method ) ) && $method)
			{
				$event = 'backend' . '.' . $options['module'] . '.' . $method; 
				Event::trigger($event);
				call_user_func ( array (( string ) $controller, $method ) );
			}
			else
			{
				throw new Exception("$controller has no method $method", 1);
			}
			exit;
		}

	}

	public static function GotoLogin()
	{
		if(!Application::LoginScreen())
		{
			$request = $_SERVER["REQUEST_URI"];
			if(strpos($request,'?')){ $request = substr($request,0,strpos($request,'?'));}

			$adminPath = Configuration::Query('/configuration/adminpath');
	        $subdir    = Configuration::Query('/configuration/domain/@subdir');

	        $path  = ($subdir) ? $subdir->item(0)->nodeValue . $adminPath->item(0)->nodeValue : $adminPath->item(0)->nodeValue;
	        $url   = Util::DirectorySeparator($path, true);
		
		
			if(!empty($_SERVER["QUERY_STRING"])){
				$request .= '?'.$_SERVER["QUERY_STRING"];
			}
			$request = str_replace('?', '&', $request);

			Util::redirect($url . 'login/?next='.$request);
			die;
		}
	}

	public static function hasAccessToMethod($module, $method)
	{
		if(!Application::LoginScreen())
		{
			$rule = Configuration::Query("/configuration/modules/module[@name='".$module."']/rewrite/backend/rule[@apply='".$method."']");
			if($rule)
			{
				$user = Admin::Logged();
				$user_access = $user['access'];
				$rule_access = $rule->item(0)->getAttribute('access_level');
				if($rule_access != '') {
					if(strpos($rule_access, $user_access) === false) {
						echo "You dont have access to this area";
						die();
					}
				}
			}
		}
	}

	public static function LoginScreen()
	{
		$request = (!empty($_SERVER["REQUEST_URI"])) ? $_SERVER["REQUEST_URI"] : "";
		if(strpos($request,'?')) {
			$request = substr($request,0,strpos($request,'?'));
		}

		$adminPath = Configuration::Query('/configuration/adminpath');
		$subdir    = Configuration::Query('/configuration/domain/@subdir');

		$path = ($subdir) ? $subdir->item(0)->nodeValue . $adminPath->item(0)->nodeValue : $adminPath->item(0)->nodeValue;
		$url  = Util::DirectorySeparator($path.'/login', true);

		$isLogin = strpos($request, $url);

		if( $isLogin===false )
			return false;

		return true;
	}

	public static function Route($options)
	{
		$url = self::RouteUrl($options);
		Util::redirect($url);
	}

	public static function RouteUrl($options)
	{
		$defaults = array(
			'back'       => 1,
			'module'     => Configuration::Query('/configuration/accessLevel')->item(0)->getAttribute('defaultModule'),
			'item_id'    => false,
			'url'        => false,
			'edit_url'   => 'edit',
			'list_url'   => 'list',
		);

		$options = util::extend(
			$defaults,
			$options
		);

		$pagination = array();
		$moduleVar = Session::Get($options['module']);

		if(isset($moduleVar['currentPage']) && $moduleVar['currentPage'] != '')
			array_push(
				$pagination, 
				'page='.$moduleVar['currentPage']
			);
		if(isset($moduleVar['categories']) && $moduleVar['categories'] != '')
			array_push(
				$pagination, 
				'categories[]='.$moduleVar['categories']
			);
		if(isset($moduleVar['state']))
			array_push(
				$pagination, 
				'state='.$moduleVar['state']
			);
		if(isset($moduleVar['startdate']) && $moduleVar['startdate'] != '')
			array_push(
				$pagination, 
				'startdate='.$moduleVar['startdate']
			);
		if(isset($moduleVar['enddate']) && $moduleVar['enddate'] != '')
			array_push(
				$pagination, 
				'enddate='.$moduleVar['enddate']
			);

		$queryStr = '';
		if(!empty($pagination)){
			$queryStr = '?';
			$queryStr .= implode('&', $pagination);
		}

		$adminPath = Configuration::Query('/configuration/adminpath');
		$subdir    = Configuration::Query('/configuration/domain/@subdir');

		$path = ($subdir) ? $subdir->item(0)->nodeValue . $adminPath->item(0)->nodeValue : $adminPath->item(0)->nodeValue;
		$url  = Util::DirectorySeparator($path, true);

		$url = $url . $options['module'] . '/';

		if($options['back'] == 1) 
			$url .= $options['list_url'] . '/' . $queryStr;

		if($options['item_id'] && $options['back'] != 1)
			$url .= $options['edit_url'] . '/' . $options['item_id'];
		
		if($options['url'] !== false) $url = $options['url'];

		return $url;
	}

	
	public static function generateToken()
	{
		$user       = (Application::isFrontend()) ? false : Admin::Logged();
		
		$userEmail  = ($user) ? $user['email'] : 'unknown-user';
		$userAgent  = (isset($_SERVER['HTTP_USER_AGENT'])) ? $_SERVER['HTTP_USER_AGENT'] : "unknown-useragent";
		$ip 		= (isset($_SERVER['REMOTE_ADDR'])) ? $_SERVER['REMOTE_ADDR'] : '127.0.0.1';
		$tokenStr   = $userEmail.'|'.$userAgent.'|'.$ip;

		$modToken 	= Admin::encrypt($tokenStr);

        return $modToken;
	}

	public static function validateToken()
	{
		$postToken 	= Util::PostParam('modToken');		
		$user       = (Application::isFrontend()) ? false : Admin::Logged();
		
		$userEmail  = ($user) ? $user['email'] : 'unknown-user';
		$userAgent  = (isset($_SERVER['HTTP_USER_AGENT'])) ? $_SERVER['HTTP_USER_AGENT'] : "unknown-useragent";
		$ip 		= (isset($_SERVER['REMOTE_ADDR'])) ? $_SERVER['REMOTE_ADDR'] : '127.0.0.1';

		$tokenStr   = $userEmail.'|'.$userAgent.'|'.$ip;
		$modToken 	= Admin::decrypt($postToken);

		// Util::debug(debug_backtrace());
		// Util::debug($tokenStr);
		// Util::debug($modToken);
		
		if($modToken !== $tokenStr){
			die('Token Error Ocurred. <a href="javascript:history.back();">Back</a>');
		}
	}


	public static function setFrontend()
	{
		self::$_frontend = true;
	}

	public static function isFrontend()
	{
		return self::$_frontend;
	}

	public static function SetModule($module)
	{
		self::$_module = $module;
	}

	public static function GetModule()
	{
		return self::$_module;
	}

	public static function IsActiveModule($module)
	{
		$result = Configuration::Query('/configuration/modules/module[@name="'.$module.'"]');

		return ($result) ? true : false;
	}

	public static function SetLang($lang)
	{
		$skins = Configuration::Query("/configuration/skins/skin");

		/* We should always have at least one skin */
		foreach($skins as $skin)
		{
			$skinlang = $skin->getAttribute('lang');

			/* if the parameter $lang is present */
			if($skinlang == $lang)
			{
				Session::Set('lang', $lang);
				return;
			}
		}

		echo 'No inteface defined for "' . $lang . '"';
		die;
	}


	/*
		Send Email
	*/
	public static function SendEmail($address, $html, $subject, $rtte=false)
	{
		$mail = new PHPMailer(true);
		
		try {
			$mail->Host = Configuration::Query("/configuration/smtp/smtp_host")->item(0)->nodeValue; // SMTP server
			$mail->Port = Configuration::Query("/configuration/smtp/smtp_port")->item(0)->nodeValue; // Set the SMTP port
			
			$mail->CharSet  = 'UTF-8';

			$username = Configuration::Query("/configuration/smtp/smtp_user");
			$userpass = Configuration::Query("/configuration/smtp/smtp_pass");
			if($username && $userpass){
				$mail->IsSMTP(); // telling the class to use SMTP
				$mail->SMTPAuth = true;
				$mail->Username = $username->item(0)->nodeValue;
				$mail->Password = $userpass->item(0)->nodeValue;
			}

			if(is_array($address)) {
				foreach($address as $recipient) {
					$mail->AddAddress($recipient);
				}
			}
			else {
				$mail->AddAddress($address);
			}

			$rtte = ($rtte !== false) ? $rtte . ' ' : '';
			$rtte .= Configuration::GetSenderName();

			$mail->SetFrom(Configuration::GetSender(), $rtte);
			$mail->Subject = $subject;
			// $mail->MsgHTML(utf8_decode($html));
			$mail->MsgHTML($html);
			$mail->Send();
		}
		catch (Exception $e)
		{
			// echo $e->getMessage(); // El mensaje no se pudo enviar
		}
	}

	
	/**
	*	RewriteRule actualiza o agrega una regla de rewrite en la configuracion
	*	del modulo
	*	@return void
	*/
	public static function RewriteRule($match, $method, $args, $id)
	{
		$module = Application::GetModule();
		$file   = PathManager::GetModulesPath() . '/'.$module.'/module.configuration.xml';

		$dom = new XMLDom();
		$dom->load($file);


		$xpath = "/module/rewrite/frontend/rule[@id = '".$id."']";
		$rule  = $dom->query($xpath);

		$regex = str_replace('/', '\/', $match);
		$regex = str_replace('.', '\.', $regex);
		$regex = str_replace('(\.', '(.', $regex);

		// La regla Existe
		if($rule)
		{
			$thisRule = $rule->item(0);
			$thisRule->removeAttribute('match');
			$thisRule->removeAttribute('apply');
			$thisRule->removeAttribute('args');
			
			$thisRule->setAttribute('match', $regex);
			$thisRule->setAttribute('apply', $method);
			$thisRule->setAttribute('args', $args);
		}
		else
		{
			$frontend = $dom->query('/module/rewrite/frontend')->item(0);
			$newNode  = $dom->createElement('rule');
			$newNode->setAttribute('id', $id);
			$newNode->setAttribute('auto-generated', 'true');
			$newNode->setAttribute('match', $regex);
			$newNode->setAttribute('apply', $method);
			$newNode->setAttribute('args', $args);
			$frontend->insertBefore($newNode, $frontend->firstChild);
		}
		$dom->save($file);
	}

	/**
	*	DeleteRewriteRule elimina la regla de rewrite al eliminar una home
	*	@return void
	*/
	public static function DeleteRewriteRule($id)
	{
		$module = Application::GetModule();
		$file   = PathManager::GetModulesPath() . '/'.$module.'/module.configuration.xml';

		$dom = new XMLDom();
		$dom->load($file);

		$xpath = "/module/rewrite/frontend/rule[@id = '".$id."']";
		$rule  = $dom->query($xpath);

		// La regla Existe
		if($rule)
		{
			$thisRule = $rule->item(0);
			$thisRule->parentNode->removeChild($thisRule);
		}
		$dom->save($file);
	}

	/*
		La regla de rewrite matcheada se guarda localmente para 
		ser utilizada despues
	*/
	public static function SetMatchedRule($rule)
	{
		self::$_MatchedRule = $rule;
	}

	public static function GetMatchedRule()
	{
		return self::$_MatchedRule;
	}

	public static function GetAppUrl()
	{
		$domain = Configuration::Query('/configuration/domain')->item(0)->nodeValue;
		$subdir = Configuration::Query('/configuration/domain/@subdir');
		if($subdir){
			$domain  = $domain . $subdir->item(0)->nodeValue;
			$subject = str_replace('/' . $subdir->item(0)->nodeValue, '', $subject); 
		}
		return $domain;
	}

	public static function SecureFront($xmlConf)
	{
		self::$securityConf       = $xmlConf;
		self::$SecureXSLTransform = self::GetSecurityDirective('xsl.transform', $xmlConf);
		self::$SecurePHPCode      = self::GetSecurityDirective('php.code', $xmlConf);
		self::$SecureJsonOutput   = self::GetSecurityDirective('json.output', $xmlConf);
		self::$SecurityExceptions = Configuration::Query('/security/exceptions/match', $xmlConf);
	
		if(self::$SecurePHPCode)
			self::ValidateUser();

		/* se carga la instancia de USER para poder usar validaciones */
		if(class_exists("User", true))
		{
			self::$User = new User();
		}

	}

	private static function GetSecurityDirective($name, $xmlConf)
	{
		return ( Configuration::Query("/security/restriction[@type='".$name."']/@authenticated_user_only", $xmlConf)->item(0)->nodeValue == 'true' ) 
		? true 
		: false;
	}

	public static function SecureXSLTransform()
	{
		if(self::$SecureXSLTransform)
			self::ValidateUser();
	}

	public static function SecureJsonOutput()
	{
		if(self::$SecureJsonOutput)
			self::ValidateUser();
	}

	private static function ValidateUser()
	{
		if(self::$SecurityExceptions){
			foreach (self::$SecurityExceptions as $exception) {
				$pattern = '#' . $exception->nodeValue . '#';
				if(preg_match($pattern, Rewrite::$url))
					return;
			}
		}

		if(class_exists("User", true))
		{
			$login = Configuration::Query('/security/exceptions/match[@islogin=1]', self::$securityConf);
			
			self::$User = new User();



			if (!self::$User->isLoguedIn()) {
				$loginurl = preg_replace('#[^a-zA-Z0-9_/%&-]#s', '', $login->item(0)->nodeValue);
				Util::redirect($loginurl.'?next='.$_SERVER["REQUEST_URI"]);
			}

			return self::$User->isLoguedIn();
		}
		else
		{
			throw new Exception(Configuration::Translate('system_wide/class_user'));
		}
	}


	public static function EventRegister($name, $handler, $priority = 10)
	{
		Event::on($name, $handler, $priority);
	}

	public static function EventTrigger($name)
	{
		Event::trigger($name);
	}
}
?>