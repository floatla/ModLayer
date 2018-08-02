<?php
Class Admin
{
	// private static $AdminCookieName = 'admin';
	// private static $cookieTime      = 1209600; //2 semanas; 
	// private static $cookiePath      = '/';
	private static $userData        = array();

	/* Nuevo del framework */
	// private static $adminTable      = 'user_admin';
	private static $datalog         = '/modules/admin/datalog.dat';

	
	
	
	public static function Logged($clearArr = true)
	{
        
		$user  = Session::Get('backend-' . Configuration::GetAppID());

		if(!empty($user))
		{
			if($clearArr) Util::ClearArray($user);
			return $user;
		}
		else{
			return false;
		}
	}

	

	public static function isInstalled()
	{
		$host   = Configuration::Query('/configuration/database/host');
		$dbname = Configuration::Query('/configuration/database/dbname');
		$user   = Configuration::Query('/configuration/database/user');
		$pass   = Configuration::Query('/configuration/database/pass');

		// No quiero comitear esto


		// Comitear
		if($dbname->item(0)->nodeValue != '' && $host->item(0)->nodeValue != '' && $user->item(0)->nodeValue != '')
		{
			// Check if db exists
			$dns = 'mysql:host='.$host->item(0)->nodeValue .';';
			$pdo = new PDO($dns, $user->item(0)->nodeValue, $pass->item(0)->nodeValue, $attrs=array());
			$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
			
			$sql  = "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '".$dbname->item(0)->nodeValue."'";
			$str = $pdo->prepare($sql);
			$str->execute();
			$result = $str->fetchAll(PDO::FETCH_ASSOC);			
			if(empty($result[0])) return false;

			// Check if tables exists
			$sql   = "SHOW TABLES LIKE '" . AdminModel::$table . "'";
			$query = new Query();
			$table = $query->run($sql);
			if(empty($table)) return false;

			return true;
		}else{
			return false;
		}
	}





	// Desencriptado 
	public static function decrypt ($Msg){

		$hash = Configuration::Query('/configuration/security/encrypthash');
		if(!$hash)
			throw new Exception(Configuration::Translate('backend_messages/encrypthash_not_found'), 1);
			// throw new Exception("No se encontró el EncryptHash en la configuración del sistema.", 1);

		$Key = $hash->item(0)->nodeValue;
		if( strlen( $Key ) != 48 ){
			throw new Exception(Configuration::Translate('backend_messages/encrypthash_wrong_length'), 1);
			// throw new Exception("Encrypthash length is not 48", 1);
		}
		$MsgLen = strlen ( $Msg );
		$Ctrl = 0;
		$MsgFinal = "";
		for ( $i = 0; $i < ( ( $MsgLen / 2 ) - 1 ) ; $i++ ){
			$Pos = $i % 17;
			if ( $Pos == 16 ){
				if ( $i > 0 ){
					$Part = hexdec ( substr( $Msg  , ( $i * 2 ) , 2 ) );
					$Ctrl = $Ctrl ^ ord ( substr ( $Key , 32 , 1 ) );
					/*if ( $Ctrl != $Part ){
					return ( -1 );
					}*/
				}
				$Ctrl = 0;
				continue;
			}
			$Part = hexdec ( substr( $Msg  , ( $i * 2 ) , 2 ) );
			$Part    = $Part ^ ord ( substr ( $Key , ( 16 + $Pos ) , 1 ) );
			$Ctrl    = $Ctrl ^ $Part;
			$Part    = $Part ^ ord ( substr ( $Key , $Pos , 1 ) );
			if ( $i < ( ( $MsgLen / 2 ) - 1 ) ){
				$MsgFinal = $MsgFinal . chr ($Part );
			}
		}
		// Tomo el Último Elemento para descartarlo del CTRL
		$Part = hexdec ( substr( $Msg  , ( $MsgLen - 2 )  , 2 ) );
		$Ctrl = $Ctrl ^ ord ( substr ( $Key , 32 , 1 ) );
		if ( $Ctrl != $Part){
			return ( -1 ) ;
		}
		return ( $MsgFinal );
	}

	// Encriptado 
	public static function encrypt ($Msg){

		$hash = Configuration::Query('/configuration/security/encrypthash');
		if(!$hash)
			throw new Exception(Configuration::Translate('backend_messages/encrypthash_not_found'), 1);
			
		$Key = $hash->item(0)->nodeValue;
		if( strlen( $Key ) != 48 ){
			throw new Exception(Configuration::Translate('backend_messages/encrypthash_wrong_length'), 1);
		}
		$MsgLen = strlen ( $Msg );
		$Ctrl = 0;
		$MsgFinal = "";
		for ( $i = 0; $i < $MsgLen; $i++ ){
			$Pos = $i % 16;
			if ( $Pos == 0 ){
				if ( $i > 0 ){
					$Part = $Ctrl ^ ord ( substr( $Key , 32 , 1 ) ); // 16 + 17 - 1
					$MsgFinal = $MsgFinal . sprintf ( "%02x", $Part );
				}
				$Ctrl = 0;
			}
			$Part    = ord ( substr( $Msg , $i , 1 ) ) ^ ord ( substr( $Key , $Pos , 1 ) );
			$Ctrl    = $Ctrl ^ $Part;
			$Part    = $Part ^ ord ( substr( $Key , ( 16 + $Pos ) , 1 ) );
			$MsgFinal = $MsgFinal . sprintf ( "%02x", $Part );
		}
		$Part = $Ctrl ^ ord ( substr( $Key , 32 , 1 ) ); // 16 + 17 - 1
		$MsgFinal = $MsgFinal . sprintf ( "%02x" , $Part );
		return ( $MsgFinal );
	}

	public static function pack()
	{
		$dir  = PathManager::GetFrameworkPath();
		$file = $dir . self::$datalog;

		$user = new AdminUser();
		$list = $user->GetList();

		$list = serialize($list);
		
		$iv = Configuration::Query('/configuration/security/iv')->item(0)->nodeValue;		
		$data = openssl_encrypt($list, "AES-256-CBC", Configuration::Query('/configuration/security/datakey')->item(0)->nodeValue, OPENSSL_RAW_DATA, $iv);

		file_put_contents($file, $data);
		return true;
	} 

	public static function unpack($id)
	{
		$dir  = PathManager::GetFrameworkPath();
		$file = $dir . self::$datalog; 

		if(!is_file($file)) 
			die("No se encontró el archivo .dat necesario. Para crear el paquete <a href='/admin/pack/'>haga click aquí</a>");
		
		$list = file_get_contents($file);
		
		$iv = Configuration::Query('/configuration/security/iv')->item(0)->nodeValue;
		$data = unserialize(openssl_decrypt($list, "AES-256-CBC", Configuration::Query('/configuration/security/datakey')->item(0)->nodeValue, OPENSSL_RAW_DATA, $iv));

		$data = Util::arrayNumeric($data);
		Util::ClearArray($data);

		foreach($data as $user){
			if($user['user_id'] == $id)
				return $user;
		}
	}

}
?>
