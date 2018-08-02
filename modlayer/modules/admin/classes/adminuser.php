<?php
Class AdminUser {

	private $id;
	private $dbtable;
	private $levels;
	private $structure;
	private $restricted = array('admin', 'administrator', 'superadmin', 'superman');

	public function __construct($id = false)
	{
		$this->id = $id;
		$this->table       = AdminModel::$table;
		$this->tableLevels = AdminModel::$tableLevels;
		$this->structure   = AdminModel::$tables;

	}

	public function Login($user)
	{
		$fields = array('*');
		$fields = Model::parseFields($this->structure, $fields, $this->table);

		$query = new Query(
			array(
				'table' => $this->table,
				'fields' => $fields,	
			)
		);

		$query->filter('username = :user_name');
		$query->filter('user_password = :password');

		$query->param(':user_name', $user['username'], 'string');
		$query->param(':password', Admin::encrypt($user['password']), 'string');

		$userData = $query->select();

		if(count($userData)==1)
		{
			$date = date('Y-m-d H:i:s');
			$query->fields(
				array(
					'last_login' => $date,
					'login_attemps' => 0,
					'login_time' => ''
				), 
				$sum=false
			);

			$query->update();

			$levels = new AdminLevels();
			$data   = $userData[0];
			$accessLevel = $levels->FetchById($userData[0]['access_level-att']);
			$data['access-att'] = $accessLevel['user_level_name'];


			Session::Set(
				'backend-' . Configuration::GetAppID(),
				$data
			);

			return true;
		}else{
			return false;
		}
	}

	public function Logout()
	{
		Session::Destroy('backend-' . Configuration::GetAppID());
	}

	public function Add($dto)
	{
		$fields = Model::inputFields($this->structure, $dto, $this->table, $verbose=false);
		$query  = new Query();
		$query->table($this->table);
		$query->fields($fields);

		return $query->insert();
	}

	public function Delete($user_id)
	{
		$query = new Query(
			array(
				'table'=>$this->table,	
			)
		);
		$query->filter('user_id = :user_id');
		$query->param(':user_id', $user_id, 'int');
		$query->delete();

		return 1;
	}

	public function FetchById($user_id)
	{
		$fields = array('*');
		$fields = AdminModel::parseFields($this->structure, $fields, $this->table);

		$query = new Query(
			array(
				'table'  => $this->table,
				'fields' => $fields,
			)
		);
		$query->filter('user_id = :user_id');
		$query->param(':user_id', $user_id, 'int');

		$user = $query->select();
		if(count($user)==1)
		{
			$data   = $user[0];
			$levels = new AdminLevels();
			$accessLevel    = $levels->FetchById($user[0]['access_level-att']);
			$data['access-att'] = $accessLevel['user_level_name'];
			return $data;
		}else{
			return false;
		}
	}
	public static function GetByEmail($email)
	{
		$query = new Query(
			array(
				'table'=>$this->table,	
			)
		);
		$query->filter('user_email = :email');
		$query->param(':email', $email, 'string');
		
		$user = $query->select();
		if(count($user)==1):
			return $user[0];
		else:
			return false;
		endif;
	}

	public static function GetPass($pass){
		return Admin::decrypt($pass, Configuration::Query('/configuration/security/encrypthash')->item(0)->nodeValue);
	}

	public function GetList()
	{
		$fields = array('*');
		$fields = Model::parseFields($this->structure, $fields, $this->table);

		$query = new Query(
			array(
				'table'   => $this->table,
				'fields'  => $fields,
				'orderby' => 'user_id',
				'order'   => 'DESC',
			)
		);

		$query->limit(1000, 1);
		$list = $query->select();
		
		$level = new AdminLevels();
		foreach($list as $key=>$user)
		{
			$accessLevel = $level->FetchById($user['access_level-att']);
			$list[$key]['access-att'] = $accessLevel["user_level_name"];
		}
			
		$list['tag'] = 'user';

		$query->fields(array('count(user_id) as total'), $sum=false);
		$query->limit(-1);
		$total = $query->select();
		$count = $total[0]['total'];

		$list['total-att'] = $count;
		$list['pageSize-att'] = 1000;
		$list['currentPage-att'] = 1;
		return $list;
	}

	public function UpdateUser($dto)
	{
		$fields = Model::inputFields($this->structure, $dto, $this->table, $verbose=true);
		$query  = new Query(
			array(
				'table'  => $this->table,
				'fields' => $fields,
			)
		);
		$query->filter('user_id = :user_id');
		$query->param(':user_id', $dto['user_id'], 'int');

		$return = $query->update();

		if($return) {
			$user = Admin::Logged();
			if($user['user_id'] == $dto['user_id']) {
				$this->UpdateSession();
			}
			return true;
		}
		else {
			return false;
		}
	}

	/*
		UpdateSession actualiza los datos en la session del usuario
		Solo se utiliza cuando un usuario logueado modifica sus datos.
	*/
	public function UpdateSession($id=false)
	{
		$logged = Admin::Logged();
		$data   = $this->FetchById($logged['user_id']);
		Session::Set('backend-' . Configuration::GetAppID(), $data);
	}
	

	/* Validaciones */
	
	public function ValidEmail($email)
	{
		return filter_var($email, FILTER_VALIDATE_EMAIL);
	}

	public function UsernameExists($username, $user_id=false)
	{
		$query = new Query(
			array(
				'table'=> $this->table,
				'fields'=>array('*'),
			)
		);
		$query->filter('username = :user_name');
		$query->param(':user_name', $username, 'string');

		if($user_id)
		{
			$query->filter('user_id != :user_id');
			$query->param(':user_id', $user_id, 'int');
		}
		
		$return = $query->select();
		return (!empty($return)) ? true : false;
	}

	public function EmailExists($email, $user_id=false)
	{
		$query = new Query(
			array(
				'table'=> $this->table,
				'fields'=>array('*'),
			)
		);
		$query->filter('user_email = :email');
		$query->param(':email', $email, 'string');
		
		if($user_id)
		{
			$query->filter('user_id != :user_id');
			$query->param(':user_id', $user_id, 'int');
		}

		// $query->debug();
		// $query->debugSQL();
		$return = $query->select();

		return (count($return) >= 1) ? true : false;
	}

	public function ValidatePass($username, $pass)
	{
		$query = new Query(
			array(
				'table'  => $this->table,
				'fields' => array('*'),
			)
		);
		$query->filter('username = :user_name');
		$query->filter('user_password = :password');

		$query->param(':user_name', $username, 'string');
		$query->param(':password', Admin::encrypt($pass), 'string');

		$return = $query->select();
		return (count($return) == 1) ? true : false;
	}



	public static function Search($query)
	{
		if(get_magic_quotes_gpc()){
			$query = stripslashes($query);
		}
		$query = str_replace("'", "\'", $query);

		$fields = array('*');
		$fields = Model::parseFields($this->structure, $fields, $this->table);

		$params = array(
			'table'   => $this->table,
			'fields'  => $fields,
			'filters' => array("username like '%".$query."%'", "user_name like '%".$query."%'", "user_lastname like '%".$query."%'", "user_email like '%".$query."%'"),
			'exclusive' => false,
		);

		$list = parent::select($params);
		
		$levels = new AdminLevels();
		foreach($list as $key=>$user):
			$accessLevel = $levels->FetchById($user['access_level-att']);
			$list[$key]['access-att'] = $accessLevel['user_level_name'];
		endforeach;

		$list['tag'] = 'user';
		return $list;
	}



	/* EDITAR USUARIOS */
	public function CheckForm($dto, $class, $callback)
	{
		$user_id = (isset($dto['user_id'])) ? $dto['user_id'] : false;
		$flag    = false;

		if($user_id){
			$data = $this->FetchById($user_id);
			Util::ClearArray($data);
			if($data['access_level'] == 1)
				$flag = true;
		}

		// Si el nick que eligió esta restringido

		if(in_array($dto['username'], $this->restricted) && !$flag){
			$this->message = Configuration::Translate('user/backend_messages/username_restricted');
			call_user_func_array(array($class, $callback), array($this->message));
		}

		if($this->UsernameExists($dto['username'], $user_id)){
			$text = Configuration::Translate('user/backend_messages/username_taken');
			$this->message = sprintf($text, $dto['username']);
			call_user_func_array(array($class, $callback), array($this->message));
		}
		
		if(!$this->ValidEmail($dto['user_email'])){
			$text = Configuration::Translate('user/backend_messages/email_not_valid');
			$this->message = sprintf($text, $dto['user_email']);
			call_user_func_array(array($class, $callback), array($this->message));
		}

		
		if($this->EmailExists($dto['user_email'], $user_id)){
			$text = Configuration::Translate('user/backend_messages/email_taken');
			$this->message = sprintf($text, $dto['user_email']);
			call_user_func_array(array($class, $callback), array($this->message));
		}

	}

	public function CheckNewPass(&$dto, $class, $callback, $new=false)
	{
		if(!$new && empty($dto['user_pass0']) && empty($dto['user_pass1'])){
			unset($dto['user_pass0']);
			unset($dto['user_pass1']);
			return true;
		}

		if($dto['user_pass0'] != $dto['user_pass1']){
			$this->message = Configuration::Translate('user/backend_messages/newpass_mismatch');
			call_user_func_array(array($class, $callback), array($this->message));
		}

		$length = 6;
		if(strlen($dto['user_pass0']) < $length){
			$text = Configuration::Translate('user/backend_messages/newpass_length');
			$this->message = sprintf($text, $length);
			call_user_func_array(array($class, $callback), array($this->message));
		}

		$dto['user_password'] = $dto['user_pass0'];
		unset($dto['user_pass0']);
		unset($dto['user_pass1']);
	}


	/* 
		Validar cantidad de logins 
	*/
	public function CanLogin($user)
	{
		$ip = (isset($_SERVER['REMOTE_ADDR'])) ? $_SERVER['REMOTE_ADDR'] : '127.0.0.1';
		$query = new Query();
		$query->table($this->table);
		$query->fields(['login_attemps', 'login_time']);
		$query->filter('username = :username and login_ip = :ip');
		$query->param(':username', $user['username'], 'string');
		$query->param(':ip', $ip, 'string');

		$data = $query->select();

		if(!isset($data[0]))
		{
			return true;	
		}
		else
		{
			return [
				'attemps' => $data[0]['login_attemps'],
				'time'    => $data[0]['login_time'],
			];
		}
	}

	public function failedLogin($user)
	{
		$ip = (isset($_SERVER['REMOTE_ADDR'])) ? $_SERVER['REMOTE_ADDR'] : '127.0.0.1';

		$sql = "UPDATE `admin_user` SET `login_attemps` = login_attemps+1, `login_ip` = :login_ip, login_time = '". date('Y-m-d H:i:s', strtotime("+1 hour"))."' WHERE username = :username";
		$bind = [
			['name' => 'login_ip', 'value' => $ip],
			['name' => 'username', 'value' => $user['username']],
		];

		$query = new Query();
		
		// $query->debug();
		// $query->debugSQL();
		return $query->execute($sql, $bind);

	}

}
?>