<?php
class MultimediaModel extends Model 
{
	public static $table 		 = 'multimedia';
	public static $RelationTable = 'multimedia_module';
	public static $CategoryTable = 'multimedia_category';

	static $tables = array(
		"multimedia" => array(
			"fields" 		=> array(
				"multimedia_id" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"multimedia_typeid" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_typeid",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"multimedia_source" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_source",
					"type"			=> "varchar(10)",
					"null" 			=> "NOT NULL",
					"default" 		=> '',
				),
				"multimedia_weight" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_weight",
					"type"			=> "int(15)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"multimedia_parent" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_parent",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"multimedia_title" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_title",
					"type"			=> "varchar(500)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"multimedia_content" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_content",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"multimedia_state" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_state",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"created_at" => array(
					"xml"			=> "value",
					"alias"			=> "created_at",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
				"created_by" => array(
					"xml"			=> "value",
					"alias"			=> "created_by",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> '0',
				),
				"created_type" => array(
					"xml"			=> "value",
					"alias"			=> "created_type",
					"type"			=> "varchar(50)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"updated_at" => array(
					"xml"			=> "value",
					"alias"			=> "updated_at",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
				"updated_by" => array(
					"xml"			=> "value",
					"alias"			=> "updated_by",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> '0',
				),
				"updated_type" => array(
					"xml"			=> "value",
					"alias"			=> "updated_type",
					"type"			=> "varchar(50)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"custom_data" => array(
					"xml"			=> "value",
					"alias"			=> "custom_data",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
			),
			"primary_key"	=> 'multimedia_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array(
				array(
					"index_name"	=> "busqueda",
					"fields_name"	=> array('multimedia_title', 'multimedia_content', 'custom_data'),
					"index_type"	=> "FULLTEXT"
				),
			)
		),

		"multimedia_module" => array(
			"fields" 		=> array(
				"rel_id"=>array(
					"xml"			=>"attribute",
					"alias"			=>"rel_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"object_id" => array(
					"xml"			=> "value",
					"alias"			=> "object_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"multimedia_id" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"relation_order" => array(
					"xml"			=> "value",
					"alias"			=> "relation_order",
					"type"			=> "int(3)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"module" => array(
					"xml"			=> "value",
					"alias"			=> "module",
					"type"			=> "varchar(30)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"multimedia_typeid" => array(
					"xml"			=> "value",
					"alias"			=> "multimedia_typeid",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
			),
			"primary_key"	=> 'rel_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array()
		),
	);
}
?>