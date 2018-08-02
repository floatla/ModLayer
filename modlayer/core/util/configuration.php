<?php
class Configuration
{
	protected static $_databaseConnection = array();
	protected static $_modules = array();
	protected static $_configuration = null;
	protected static $dom;

	protected static $_ApplicationID = null;

	protected static $_ErrorReportingInitialized = false;
	protected static $_LoggingInitialized = false;
	protected static $_SessionInitialized = false;
	protected static $_EnvironmentConfig = false;
	protected static $_configurationEnabled = null;

	
	protected static function SetApplicationID($applicationID)
	{
		if (strtolower($applicationID) == 'framework')
		{
			die('The application ID can\'t be "framework"');
		}

		self::$_ApplicationID = $applicationID;
	}
	
	protected static function GetBaseDir()
	{
		if (HTTPContext::Enabled()) {
			$baseDir = getcwd();
		} else {
			$baseDir = dirname(realpath($_SERVER['SCRIPT_FILENAME']));
		}
		return $baseDir;
	}
	
	public static function InitializeErrorReporting()
	{
		if (!self::$_ErrorReportingInitialized)
		{

			if (!self::ConfigurationEnabled())
			{
				MLError::SetScreen(true, false);
			}
			else
			{

				$screen = self::Query('/configuration/errorReporting/screen');
				if ($screen && $screen->item(0)->getAttribute('enabled') == 'true')
				{
					MLError::SetScreen(true);
				}
				else
				{
					MLError::SetScreen(false);
				}
				
				$email = self::Query('/configuration/errorReporting/email');

				if ($email && $email->item(0)->getAttribute('enabled') == 'true')
				{
					MLError::SetEMail(true);
				}else{
					MLError::SetEMail(false);
				}

			}
			self::$_ErrorReportingInitialized = true;
		}
	}
	
	public static function ConfigurationEnabled()
	{
		if (!isset(self::$_configurationEnabled)){

			self::$_configurationEnabled = (self::GetConfigFile()) ? true : false;
		}
		return self::$_configurationEnabled;
	}
	
	public static function SetEnvironment($environment)
	{
		self::$_EnvironmentConfig = ($environment !== false) ? '/configuration/environments/'.$environment.'.xml' : false;
	}

	public static function GetConfigFile()
	{
		if(self::$_EnvironmentConfig){
			$file = PathManager::GetFrameworkPath() . self::$_EnvironmentConfig;
			
			if(file_exists($file) && self::isValidXml($file)){
				return $file;
			}else{
				die('Configuration File not found!');
			}
		}else{
			die('No Enviroment defined. Set your enviroment in Application::Initialize().');
		}
		
	}
	
	public static function GetApplicationID()
	{
		$query = self::Query('/configuration/applicationID');
		return $query->item(0)->nodeValue;
	}
	
	
	public static function GetDatabaseConnection()
	{
		$dbconf    = self::Query('/configuration/database');
		$adminpath = self::Query('/configuration/adminpath')->item(0)->nodeValue;
		$subdir    = Configuration::Query('/configuration/domain/@subdir');
		if($subdir) $adminpath = '/' . $subdir->item(0)->nodeValue . $adminpath;
		
		$host   = self::Query('/configuration/database/host')->item(0)->nodeValue;
		$dbname = self::Query('/configuration/database/dbname')->item(0)->nodeValue;

		if(empty($host)){
			$request = $_SERVER['REQUEST_URI'];
			if($request != $adminpath.'firstrun.php')
			{
				Util::redirect($adminpath.'firstrun.php');
			}
		}
		
		if (!$dbconf)
		{
			die ('ConnectionString not properly configured. Check your configuration file.');
		}

		$socket = self::Query('/configuration/database/socket');
		if($socket){
			$_databaseConnection['dns'] = 'mysql:unix_socket='.$socket->item(0)->nodeValue .';';
			$_databaseConnection['dns'] .= 'port='.$socket->item(0)->getAttribute('port') .';';
		}
		$host = self::Query('/configuration/database/host');
		if($host){
			$_databaseConnection['dns'] = 'mysql:host='.$host->item(0)->nodeValue .';';
			$_databaseConnection['dns'] .= 'port='.$host->item(0)->getAttribute('port') .';';
		}
		$dbname = self::Query('/configuration/database/dbname')->item(0)->nodeValue;
		if(empty($dbname)){
			$request = $_SERVER['REQUEST_URI'];
			if($request != $adminpath.'firstrun.php')
			{
				Util::redirect($adminpath.'firstrun.php');
			}
		}
		$_databaseConnection['dns'] .= 'dbname='.$dbname;
		$_databaseConnection['user'] = self::Query('/configuration/database/user')->item(0)->nodeValue;
		$_databaseConnection['pass'] = self::Query('/configuration/database/pass')->item(0)->nodeValue;

		return $_databaseConnection;
	}
	
	public static function GetEmails()
	{
		$destination = self::Query('/configuration/errorReporting/email');
		return $destination->item(0)->getAttribute('destination');
	}
	
	public static function GetSender()
	{
		$sender = self::Query('/configuration/errorReporting/email');
		return $sender->item(0)->getAttribute('sender');
	}
	
	public static function GetSenderName()
	{
		$sender = self::Query('/configuration/errorReporting/email');
		return $sender->item(0)->getAttribute('sendername');
	}


	public static function GetModuleConfiguration($moduleName)
	{	
		$module = self::Query("/configuration/modules/module[@name='".$moduleName."']");
		return ($module) ? $module->item(0) : false;
	}
	

	public static function GetModuleConfigurationByType($typeId)
	{	
		$module = self::Query("/configuration/modules/module[@type_id='".$typeId."']");
		if($module)
			return $module->item(0);
		else
			throw new Exception("El type_id $typeId no existe", 1);
	}

	public static function GetSkinConfiguration(){
		$configuration = self::GetConfiguration();
		$skins = $configuration->skins;
		foreach($skins->skin as $skin){
			if($skin['active']==1){
				return $skin;
			}
		}
		return false;
	}

	public static function GetLoginPage()
	{
		$configuration = self::GetConfiguration();
		
		if (count($configuration->LoginPage) == 1)
		{
			return (string) $configuration->LoginPage;
		}
		else
		{
			die('The login page location has not been defined.');
		}
	}
	
		
	public static function isValidXml($filePath, $isFile=true)
	{
		if($isFile):
			$xml = file_get_contents($filePath);
		else:
			$xml = $filePath;
		endif;
		//$xml = file_get_contents($filePath);
		libxml_use_internal_errors(true);
		$doc = new DOMDocument('1.0', 'UTF-8');
		$doc->loadXML(utf8_encode($xml));

		$errors = libxml_get_errors();
		
		if (empty($errors)){
			return true;
		}else{
			$error = $errors[0];
			if($error->code == 4):
				return false;
			else:
				$lines = explode("\n", $xml);
				$line = $lines[($error->line)-1];
				$message = "<h1>XML Configuration not well formed</h1>";
				$message .= "<b>Archivo:</b> ".$filePath."<br/>";
				$message .= "<b>Error:</b> ".$error->message.'<br />';
				$message .= "<b>Linea ".$error->line.": </b>".htmlentities($line)."<br/>";
				//$message .= "<b>Columna ".$error->column.": </b>".substr($line, strpos($line, $error->column), strlen($line));
				echo $message."<br/>";
				die();
			endif;
		}
	}
	

	
	/* New configuration */

	public static function LoadConfiguration()
	{

		if(self::ConfigurationEnabled())
		{
			$file = self::GetConfigFile();
			$domDoc = new DOMDocument("1.0", "UTF-8");
			$domDoc->load($file);
			$domDoc->formatOutput = true;
			$modules = $domDoc->createElement('modules'); // This is where we'll insert each modules config.
			$domDoc->documentElement->appendChild($modules);
			self::$dom = $domDoc;
		}
		else{
			die('Configuration Not Enabled!');
		}
	}
	
	public static function AddModule($configFile)
	{	
		if(self::isValidXml($configFile)){
			$module = new DOMDocument("1.0", "UTF-8");
			$module->load($configFile);

			if($module->firstChild->getAttribute('active') == 1)
			{
				$dom_sxe = self::$dom->importNode($module->documentElement, true);
				$modules = self::$dom->getElementsByTagName('modules')->item(0);
				$modules->appendChild($dom_sxe);	
			}
		
		}
	}

	public static function LoadBackendRules()
	{
		$str  = self::Query('/configuration/backendrules');
		$file = PathManager::GetFrameworkPath().'/'.$str->item(0)->nodeValue;
		
		if(self::isValidXml($file)){
			$module = new DOMDocument("1.0", "UTF-8");
			$module->load($file);

			$dom_sxe = self::$dom->importNode($module->documentElement, true);
			$modules = self::$dom->getElementsByTagName('configuration')->item(0);
			$modules->appendChild($dom_sxe);
		}
	}

	public static function LoadFrontendRules()
	{
		$str  = self::Query('/configuration/frontendrules');
		$file = PathManager::GetFrameworkPath().'/'.$str->item(0)->nodeValue;
		
		if(self::isValidXml($file)){
			$module = new DOMDocument("1.0", "UTF-8");
			$module->load($file);

			$dom_sxe = self::$dom->importNode($module->documentElement, true);
			$modules = self::$dom->getElementsByTagName('configuration')->item(0);
			$modules->appendChild($dom_sxe);
		}
	}

	public static function GetLanguageStr()
	{
		$str  = self::Query('/configuration/adminpath/@lang');
		/* Si no tiene configurado un lenguaje carga por default es-ar */
		return (!$str) ? 'es-ar' : $str->item(0)->nodeValue;
	}

	public static function GetLanguagePath()
	{
		$lang  = self::GetLanguageStr();
		$file  = PathManager::GetFrameworkPath().'/configuration/lang/' . $lang . '.xml';
		if(!file_exists($file))
			throw new Exception("Translation file for '".$lang."' not found. Check your configuration. (or put the file in place)", 1);

		if(!self::isValidXml($file))
			throw new Exception("Translation file for '".$lang."' not well formed. Check your configuration.", 1);

		return $file;
	}

	public static function SetLanguage()
	{
		$file = self::GetLanguagePath();
	
		$langFile = new XMLDom();
		$langFile->load($file);

		$dom_sxe = self::$dom->importNode($langFile->documentElement, true);
		$config = self::$dom->getElementsByTagName('configuration')->item(0);
		$config->appendChild($dom_sxe);
		$langFile = null;

	}

	public static function GetModuleLanguagePath()
	{
		$lang = self::GetLanguageStr();
		$file = array(
			PathManager::GetModulesPath(),
			Application::GetModule(),
			'ui/lang',
			$lang . '.xml'
		);
		$file = implode('/', $file);

		return (file_exists($file) && self::isValidXml($file)) ? $file : false;
	}

	public static function SetModuleLanguage()
	{
		$filePath = self::GetModuleLanguagePath();

		if($filePath) 
		{
			$relativePath = substr($filePath, strlen(PathManager::GetApplicationPath()));
			$langFile = new DOMDocument("1.0", "UTF-8");
			$langFile->load($filePath);

			$path = $langFile->createElement('path', $relativePath);
			$langFile->documentElement->appendChild($path);

			$dom_sxe = self::$dom->importNode($langFile->documentElement, true);
			$config = self::$dom->getElementsByTagName('configuration')->item(0);
			$config->appendChild($dom_sxe);
		}
	}
	
	/*
		Translate recibe una parte de la ruta xPath y 
		devuelve el valor si existe en la configuracion del lenguaje.
	*/
	public static function Translate($sub_xpath)
	{
		// Vemos si existe en la configuración del módulo
		$textM = self::Query('/configuration/mod_language/' . $sub_xpath);
		if($textM)
			return $textM->item(0)->nodeValue;

		// Si no existe, vemos en la configuración del sistema, 
		$text = self::Query('/configuration/language/' . $sub_xpath);
		if($text)
			return $text->item(0)->nodeValue;

		

		throw new Exception("Translation Error: '" . $sub_xpath . "', Path not found in language file.", 1);
	}

	/*
		EvanTranslate recibe un string que puede ser la una ruta 
		de lenguaje o no. Evalua este string y si es una referencia de lenguaje
		retorna el valor del nodo, sino retorna el string original.
	*/
	public static function EvalTranslate($string)
	{
		if(strpos($string, '{$language') !== false) {
			$string = str_replace('{$language/', '', $string);
			$string = str_replace('}', '', $string);
			return Configuration::Translate($string);
		}

		return $string;
	}

	/*
		ModuleEvanTranslate realiza la misma accion que EvalTranslate, 
		pero sobre un modulo especifico, buscando el archivo de lenguaje de ese modulo
		si existe el archivo y el nodo, retorna el valor del nodo, sino retorna el string original.
	*/
	public static function ModuleEvalTranslate($string, DOMElement $module)
	{
		// Util::debug($string);
		
		if(strpos($string, '{$language') !== false) {
			$xpath = str_replace('{$language/', '', $string);
			$xpath = str_replace('}', '', $xpath);

			$str   = self::Query('/configuration/adminpath/@lang');

			/* Si no tiene configurado un lenguaje carga por default es-ar */
			$lang  = (!$str) ? 'es-ar' : $lang = $str->item(0)->nodeValue;
			$mPath = PathManager::GetModulesPath() . '/' . $module->getAttribute('name') . '/ui/lang/' . $lang . '.xml';

			if(file_exists($mPath)){
				// throw new Exception("Configuration for module '" . $module->getAttribute('name') . "' is asking a language expression. File not found: " . $mPath);
			

				$xdom = new XMLDom();
				$xdom->load($mPath);

				$text = $xdom->query('/mod_language/' . $xpath);
				// Util::debug($text);
				// die;

				if(!$text)
					return $string;

				return $text->item(0)->nodeValue;
			}
		}

		return $string;
	}


	public static function Query($node, $xml=false)
	{
		if($xml){
			$source = new DOMDocument("1.0", "UTF-8");
			$dom_sxe = $source->importNode($xml, true);
			$source->appendChild($dom_sxe);			
		}else{
			$source = self::$dom;
		}
		$conf   = new DOMXPath($source);
		$result = $conf->query($node);

		if($result->length == 0){
			return false;
		}else{
			return $result;
		}
	}

	public static function GetConfiguration()
	{
		Util::debugXML(self::$dom->documentElement);
	}

	public static function GetAppID($sanitize = true)
	{
		$appID = Configuration::Query('/configuration/applicationID')->item(0)->nodeValue;
		if($sanitize){
			$appID = str_replace(' ', '-', $appID);
			// $appID = preg_replace('/[^A-Za-z0-9\-]/', '', $appID);
			$appID = preg_replace('/[^A-Za-z\-]/', '', $appID);
		}
		return strtolower($appID);
	}
	
	public static function QueryGroup($groupName, $module=false)
	{
		$mod = ($module) ? $module : Application::GetModule();
		return self::Query("/configuration/modules/module[@name='".$mod."']/options/group[@name='".$groupName."']/*");
	}

	public static function RegisterEvents()
	{
		$events = Configuration::Query("//group[@name='events']/event");
		if($events)
		{
			foreach($events as $event)
			{
				$name   = $event->getAttribute('name');
				$class  = $event->getAttribute('handler_class');
				$method = $event->getAttribute('handler_method');
				$priority = $event->getAttribute('priority');

				Event::on($name, array($class, $method), $priority);
			}
		}
	}	
	
}
?>