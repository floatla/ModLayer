<?php
Class Youtube {

	var $privatePass = 'notasecret';
	var $client;
	var $service_account_email;
	var $key_file_location;
	var $apikey;
	var $client_id = '728316285108-u4qit4bnddsmis4esthl8fo1un5ejtfn.apps.googleusercontent.com';

	public function __construct()
	{
		$this->autoload();
		$this->service_account_email = '728316285108-b0m4lhd8ig8lol8ij23inv33om6j1lt7@developer.gserviceaccount.com';
 		$this->key_file_location     = $this->sdkPath() . '/Float Clients-7065e7298f00.p12';
 		$this->apikey = "AIzaSyBwtUCkjHv262c2M4YUWbT60zIyMg9_tf8";
	}

	private function autoload()
	{
		$path     = $this->sdkPath();
		$autoload = $path . '/src/Google/autoload.php';
		require_once($autoload);
	}

	private function sdkPath()
	{
		return PathManager::GetFrameworkPath() . '/sdks/google-api-php-client-master';
	}


	// Creates and returns the Analytics service object.
	public function getService()
	{
		$client = new Google_Client();
		$client->setDeveloperKey($this->apikey);

		$youtube = new Google_Service_YouTube($client);

		return $youtube;

		// $client = new Google_Client();
		// $client->setClientId($this->client_id);
		// $client->setClientSecret($this->privatePass);
		// $client->setScopes('https://www.googleapis.com/auth/youtube');
		// $redirect = filter_var('http://' . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'], FILTER_SANITIZE_URL);
		// $client->setRedirectUri($redirect);

		// // Define an object that will be used to make all API requests.
		// $youtube = new Google_Service_YouTube($client);

		// if (isset($_GET['code'])) {
		// 	if (strval($_SESSION['state']) !== strval($_GET['state'])) {
		// 		die('The session state did not match.');
		// 	}

		// 	$client->authenticate($_GET['code']);
		// 	$_SESSION['token'] = $client->getAccessToken();
		// 	header('Location: ' . $redirect);
		// }

		// if (isset($_SESSION['token'])) {
		// 	$client->setAccessToken($_SESSION['token']);
		// }

		// if ($client->getAccessToken()) {
		// 	$resourceId = new Google_Service_YouTube_ResourceId();
		// 	$resourceId->setChannelId('UCtVd0c0tGXuTSbU5d8cSBUg');
		// 	$resourceId->setKind('youtube#channel');
		// }


	}


}
?>