<?php
class AdminModel extends Model 
{

	static $table       = 'admin_user';
	static $tableLevels = 'admin_userlevel';

	static $tables = array(
		"admin_user" => array(
			"fields" 		=> array(
				"user_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "user_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"user_email" => array(
					"xml"			=> "value",
					"alias"			=> "email",
					"type"			=> "varchar(100)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"user_password" => array(
					"xml"			=> "value",
					"alias"			=> "password",
					"type"			=> "password(500)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"username" => array(
					"xml"			=> "value",
					"alias"			=> "username",
					"type"			=> "varchar(30)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"user_name" => array(
					"xml"			=> "value",
					"alias"			=> "name",
					"type"			=> "varchar(100)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"user_lastname" => array(
					"xml"			=> "value",
					"alias"			=> "lastname",
					"type"			=> "varchar(100)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"user_active" => array(
					"xml"			=> "attribute",
					"alias"			=> "active",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"photo_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "photo_id",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"access_level" => array(
					"xml"			=> "attribute",
					"alias"			=> "access_level",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"last_login" => array(
					"xml"			=> "attribute",
					"alias"			=> "last_login",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
			),
			"primary_key"	=> 'user_id',
			"charset"     	=> 'utf8',
			"indexes" 		=> array(
				array(
					"index_name"	=> "alias",
					"fields_name"	=> array('username'),
					"index_type"	=> "UNIQUE"
				),
				array(
					"index_name"	=> "email",
					"fields_name"	=> array('user_email'),
					"index_type"	=> "UNIQUE"
				),
			)
		),

		"admin_userlevel" => array(
			"fields" 		=> array(
				"user_level_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "level_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"user_level_name" => array(
					"xml"			=> "value",
					"alias"			=> "name",
					"type"			=> "varchar(100)",
					"null" 			=> "NOT NULL",
					"default" 		=> '',
				),
			),
			"primary_key"	=> 'user_level_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array(),
		),
	);	
}
?>