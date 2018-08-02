<?php
Class AdminLevels {
	
	private $dbtable;

	public function __construct()
	{
		$this->table       = AdminModel::$tableLevels;
		$this->structure   = AdminModel::$tables;
	}

	public function FetchById($levelId)
	{
		if($levelId)
		{
			$query = new Query();
			$query->fields(array('*'));
			$query->table($this->table);
			$query->filter('user_level_id = :level_id');
			$query->param(':level_id', $levelId, 'int');
			
			$result = $query->select();
			return count($result) ? $result[0] : false;

		}
	}

	public function GetList()
	{
		$fields = array('*');
		$fields = Model::parseFields($this->structure, $fields, $this->table);

		$query = new Query(
			array(
				'fields' => $fields,
				'table'  =>$this->table,
			)
		);
		$result = $query->select();
		
		$result['tag'] = 'level';
		return $result;
	}

	public function validateAccesLevel($userAccessLevel=false,$moduleAccessLevel=false)
	{
		
		if($userAccessLevel && $moduleAccessLevel)
		{
			//If AccessLevel is 'all' returns true to getAccess
			if($moduleAccessLevel == 'all' || $userAccessLevel == 'administrator') {
				return true;
			}

			$moduleAccessLevel = explode(",",$moduleAccessLevel);
			foreach($moduleAccessLevel as $accessLevel) {
				if($accessLevel === $userAccessLevel) {
					return true;
				}
			}

			$rule = Application::GetMatchedRule();
			if($rule){
				$rule_access = $rule->getAttribute('access_level');
				if(strpos($rule_access, $userAccessLevel) !== false){
					return true;
				}
			}
			return false;
		}
		else
		{
			return false;
		}
	}
	
	public function AddAccessLevel($dto)
	{
		$fields = Model::inputFields($this->structure, $dto, $this->table, $verbose=true);
		$query = new Query(
			array(
				'fields' => $fields,
				'table'  => $this->table,
			)
		);
		
		return $query->insert();
	}


	public function EditAccessLevel($dto)
	{
		$fields = AdminModel::inputFields($this->structure, $dto, $this->table, $verbose=true);
		$query = new Query(
			array(
				'fields' => $fields,
				'table'  => $this->table,
			)
		);
		$query->filter('user_level_id = :level_id');
		$query->param(':level_id', $dto["user_level_id"], 'int');
		
		return $query->update($fields);
	}

	public function RemoveAccessLevel(){

		//1. validar si hay algún usuario asignado a ese nivel
		$params = array(
			'fields'=>array("user_id"),
			'table'=>UserModel::$table,
			'filters'=>array("access_level=".$levelId)
		);
		$result = parent::select($params);
		util::debug($result);
		//2. si ningún usuario tiene este nivel de acceso se elimina


	}
}
?>