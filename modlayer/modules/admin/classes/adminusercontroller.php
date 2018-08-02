<?php
Class AdminUserController extends Backend 
{
	private static $restrictedNicks = array('admin', 'administrator', 'superadmin', 'superman');
	private static $message = false;
	private static $email   = false;
	private static $next    = false;
	public static $module   = false;

	/* Login */
	public static function RenderLogin()
	{
		$dir    = Configuration::Query('/configuration/adminpath');
		$sdc    = Configuration::Query('/configuration/domain/@subdir');
		$subdir = ($sdc) ? $sdc->item(0)->nodeValue : false;

		$adminFolder = $dir->item(0)->nodeValue;
		if($subdir) $adminFolder = '/' . $subdir . $adminFolder;

		
		
		if(!Admin::isInstalled())
		{
			Util::redirect($adminFolder.'firstrun/index.php');
		}
		else
		{
			$module  = Configuration::GetModuleConfiguration('admin');
			$sysConf = Configuration::Query("/configuration/*[not(*)]");
			$lang    = Configuration::Query('/configuration/language');

			$template = new Templates();
        	$template->setDevice('ui');
			$template->setBaseStylesheet(
                PathManager::GetModulesPath() . '/admin/ui/xsl/user/user.login.xsl'
            );
			

			$template->setconfig($module, $xpath=null, $target=null);
	        $template->setconfig($sysConf, null, 'system');
	        $template->setconfig($lang, null, null);


			$modPath = ($subdir) ? $subdir : '';
			$modPath = Util::DirectorySeparator($modPath . '/modlayer/modules/admin', true);

			
			$template->setparam(
				array(
					'adminroot' => ($subdir) ? Util::DirectorySeparator($subdir . '/admin/', true) : '/admin/',
					'modPath'   => $modPath,
					'next'      => Util::getvalue('next', (self::$next) ? self::$next : getenv('HTTP_next')),
					'message'   => self::$message,
					'email'     => self::$email,
				)
			);
			$template->display();
		}
	}

	public static function Login()
	{
		$user = array();
		$user['next']     = Util::getvalue('next');
		$user['email']    = Util::getvalue('email');
		$user['username'] = Util::getvalue('username');
		$user['password'] = Util::getvalue('password');
		$remember         = Util::getvalue('remember');
		$user['remember'] = (isset($remember))?$remember:0;

		$user['next'] = strtolower($user['next']);
		$user['next'] = preg_replace('/[^a-z0-9 -\/]+/', '', $user['next']);

		$user['username'] = strtolower($user['username']);
		$user['username'] = preg_replace('/[^a-z0-9 -]+/', '', $user['username']);
		
		self::$next = $user['next'];
		self::$email   = $user['email'];

		$adminUser = new AdminUser();

		/* 
			Validar si el usuario se puede loguear
		*/
		$canlog = $adminUser->CanLogin($user);
		if(isset($canlog['attemps'])) {

			if($canlog['attemps'] >= 5)
			{
				self::$message = "Usuario bloqueado por 1 hora. <br/> Desbloqueo: " . $canlog['time'];
				self::RenderLogin();
				die;
			}
		
		}

		if($adminUser->UsernameExists($user['username']) && $user['password']!='')
		{
			if(!$adminUser->ValidatePass($user['username'], $user['password']))
			{
				$adminUser->failedLogin($user);
				$left = 5 - ($canlog['attemps'] * 1);
				self::$message = "La combinación usuario / clave no es correcta. <br/> Te quedan <b>" . $left . "</b> intentos antes de bloquear al usuario";
				// self::$message = Configuration::Translate('user/backend_messages/login_error');
			}
			else
			{
				$adminUser->Login($user);
				$adminpath     = Configuration::Query('/configuration/adminpath');
				$urlToRedirect = ($user['next']) ? $user['next'] : $adminpath->item(0)->nodeValue;
				Util::redirect($urlToRedirect);
			}
		}
		elseif($user['password']==''){
			self::$message = Configuration::Translate('user/backend_messages/login_error');
		}
		elseif(!$adminUser->UsernameExists($user['username'])){
			self::$message = Configuration::Translate('user/backend_messages/login_error');
		}
		else{
			self::$message = Configuration::Translate('backend_messages/error/general_message');
		}
		self::RenderLogin();
	}

	public static function Logout()
	{
		$adminUser = new AdminUser();
		$adminUser->Logout();

		Util::redirect( (Util::getvalue('next')) ? Util::getvalue('next') : PathManager::GetAdminDir() );
	}

	public static function DeleteUser()
	{
		$user_id = Util::getvalue('user_id');
		$adminUser = new AdminUser();
		echo $adminUser->Delete($user_id);
	}

	public static function BackEmailSend()
	{
		try
		{
			$user_id = Util::getvalue('user_id');
			$user    = Admin::unpack($user_id);
			
			$html    = self::BackEmailBody($user);
			$subject = Configuration::Translate('user/email/subject') . ' ' . Configuration::GetApplicationID();
			$address = (string)$user['email'];
			
			Application::SendEmail($address, $html, $subject, $rtte=false);
			$response = array(
				'code' => 200,
				'message' => 'Ok',
			);
		}
		catch(Exception $e){
			$response = array(
				'code' => 500,
				'message' => $e-getMessage(),
			);
		}
		Util::OutputJson($response);
	}

	/*
		BackEmailBody realiza la transformación del cuerpo del email 
		con las instrucciones con la contraseña
		Devuelve la transformación, sin imprimir nada en pantalla.
	*/
	public static function BackEmailBody($user)
	{
		if(isset($user['password'])){
			$pass = Admin::decrypt($user['password']);
		}
		else
		{
			$pass = Admin::decrypt($user['user_password']);
		}
		parent::loadAdminInterface($baseXsl='user/user.mail.xsl');
		self::$template->setcontent($user, null, 'user');
		self::$template->setparam('pass', $pass);
		return self::$template->returnDisplay();
	}	


	/*  User profile data */
	public static function RenderEditMyData($msg=false)
	{
		$user    = Admin::Logged( $clearArr=false );

		parent::loadAdminInterface();
		parent::$template->setcontent($user, null, 'user');
		if(!is_array($msg))
			parent::$template->setparam('message', $msg);
		parent::$template->add('user/user.profile.xsl');
		parent::$template->display();
	}

	public static function EditMyData()
	{
		if ($user = Admin::Logged())
		{
			$dto    = $_POST;
			$adminUser = new AdminUser();
			
			if($dto['user_id'] != $user['user_id']){
				$message = Configuration::Translate('user/backend_messages/edit_user_id');
				self::RenderEditMyData($message);
			}
			
			$adminUser->CheckForm($dto, 'AdminUserController', 'RenderEditMyData');
			if(!$adminUser->ValidatePass($dto['username'], $dto['user_password']))
			{
				$message = Configuration::Translate('user/backend_messages/pass_mismatch');
				self::RenderEditMyData($message);
			}
			$adminUser->CheckNewPass($dto, 'AdminUserController', 'RenderEditUser');

			$user = $adminUser->UpdateUser($dto);
			Admin::pack();
			$message = Configuration::Translate('user/backend_messages/edit_success');
			self::RenderEditMyData($message);
		}
	}



	/* Listado de Usuarios */	
	public static function RenderUsers()
	{
		$user = new AdminUser();
		parent::loadAdminInterface();
		self::$template->setcontent($user->GetList(), null, 'collection');
		self::$template->add('user/user.list.xsl');
		self::$template->display();
	}


	// Agregar usuario
	public static function RenderAddUser($msg)
	{
		$levels  = new AdminLevels();
		$dto     = $_POST;

		parent::loadAdminInterface();
		self::$template->setcontent($levels->GetList(), null, 'levels');
		if(!is_array($msg))
			self::$template->setparam('message', $msg);
		self::$template->setcontent($dto, null, 'user');
		self::$template->add('user/user.add.xsl');
		self::$template->display();
	}

	public static function AddUser()
	{
		$dto    = $_POST;
		
		$adminUser = new AdminUser();
		$adminUser->CheckForm($dto, 'AdminUserController', 'RenderAddUser');
		$adminUser->CheckNewPass($dto, 'AdminUserController', 'RenderAddUser', true);

		// $dto['user_password'] = $dto['user_pass0'];
		$user_id = $adminUser->Add($dto);
		Admin::pack();
		Application::Route(
			array(
				'module'     => 'users',
				'item_id'    => $user_id,
				'back'       => 0,
			)
		);

	}

	public static function RenderEditUser($msg=false)
	{

		$user_id = (isset($_POST['user_id'])) ? $_POST['user_id'] : Util::getvalue('id');
		$user    = Admin::unpack($user_id);

		if(is_null($user)){
			Application::Route(
				array(
					'module'     => 'users',
					'back'       => 0,
				)
			);
		}

		$adminUser = new AdminUser();
		
		$message   = (is_string($msg)) ? $msg : '';

		parent::loadAdminInterface();
		self::$template->setcontent($user, null, 'user');
		self::$template->setparam('pass', $adminUser->GetPass($user['password']));	

		$levels = new AdminLevels();
		self::$template->setcontent($levels->GetList(), null, 'levels');

		self::$template->setparam('message', $message);
		self::$template->add('user/user.edit.xsl');
		self::$template->display();
	}

	public static function EditUser()
	{

		if($user = Admin::Logged()){

			$dto    = $_POST;
			if(!isset($dto['user_id'])){
				Application::Route(
					array(
						'module'     => 'users',
						'back'       => 0,
					)
				);
			}

			$adminUser = new AdminUser();
			$adminUser->CheckForm($dto, 'AdminUserController', 'RenderEditUser');

			if(!$adminUser->ValidatePass($dto['username'], $dto['user_password']))
			{
				$message = Configuration::Translate('user/backend_messages/pass_mismatch');
				self::RenderEditUser($message);
			}

			$adminUser->CheckNewPass($dto, 'AdminUserController', 'RenderEditUser');

			$user = $adminUser->UpdateUser($dto);
			Admin::pack();
			$message = Configuration::Translate('user/backend_messages/edit_success');
			self::RenderEditUser($message);

		}
	}


	/* Niveles de Acceso */
	public static function DisplayLevels()
	{
		$levels = new AdminLevels();

		parent::loadAdminInterface();
		self::$template->setcontent($levels->GetList(), null, 'levels');
		self::$template->add('user/levels.list.xsl');
		self::$template->display();		
	}

	public static function DisplayLevelsAdd()
	{
		parent::loadAdminInterface();
		self::$template->add('user/levels.add.xsl');
		self::$template->display();		
	}

	public static function BackAddLevel()
	{
		$name = util::getvalue("name");
		if($name){
			$id = Admin::AddAccessLevel(array("user_level_name"=>$name));

			$adminpath = Configuration::Query('/configuration/adminpath');
			$adminpath = $adminpath->item(0)->nodeValue;

			Application::Route(array(
				'module'     => 'admin',
				'url'       => $adminpath .'admin/users/levels/'
				)
			);
		}
	}

	// 

	public static function DisplayLevelsEdit()
	{
		$userLevelId = Util::getvalue("id");
		$AccessLevel = Admin::getAccessLevel($userLevelId);

		parent::loadAdminInterface();
		self::$template->setcontent($AccessLevel, null, 'access_level');
		self::$template->add('user/user.admin.levels.edit.xsl');
		self::$template->display();		
	}

	public static function EditLevel(){
		$response = Admin::EditAccessLevel(array(
			'user_level_id'=>Util::getvalue("id"),
			'user_level_name'=>Util::getvalue("name")
		));
		Admin::pack();
		$adminpath = Configuration::Query('/configuration/adminpath');
		$adminpath = $adminpath->item(0)->nodeValue;

		Application::Route(array(
			'module'     => 'admin',
			'url'       => $adminpath .'admin/users/levels/'
			)
		);
	}


	public static function RemoveLevel()
	{
		$levelId = Util::getvalue("id");

		$response = Admin::RemoveAccessLevel(array(
			'user_level_id'=>$levelId
		));

		$adminpath = Configuration::Query('/configuration/adminpath');
		$adminpath = $adminpath->item(0)->nodeValue;

		Application::Route(array(
			'module'     => 'admin',
			'url'       => $adminpath .'admin/users/levels/'
			)
		);
	}
}
?>