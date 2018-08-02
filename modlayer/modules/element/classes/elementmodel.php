<?php
class ElementModel extends Model 
{
	public static $table = 'element';
	public static $RelationTable = 'module_relation';
	public static $CategoryTable = 'category_relation';
	// public static $DeletedTable  = 'object_deleted';

	static $objectFields = array(
		'item_id'      => 'item_id',
		'module'  		 => 'module',
		'parent_id'  => 'parent_id',
		'created_at'     => 'created_at',
		'created_by'       => 'created_by',
		'created_type'     => 'created_type',
		'updated_at'     => 'updated_at',
		'updated_by'   => 'updated_by',
		'updated_type' => 'updated_type',
		'title'   => 'title',
		'content' => 'content',
		'summary' => 'summary',
		'state'   => 'state',
	);
	
	static $tables = array(
		"element" => array(
			"fields" 		=> array(
				"item_id" => array(
					"xml"			=> "value",
					"alias"			=> "object_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"module" => array(
					"xml"			=> "value",
					"alias"			=> "module",
					"type"			=> "varchar(30)",
					"null" 			=> "NOT NULL",
					"default" 		=> 'noset',
				),
				"parent_id" => array(
					"xml"			=> "value",
					"alias"			=> "object_parent",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"title" => array(
					"xml"			=> "value",
					"alias"			=> "title",
					"type"			=> "varchar(500)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"slug" => array(
					"xml"			=> "value",
					"alias"			=> "slug",
					"type"			=> "varchar(255)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"content" => array(
					"xml"			=> "value",
					"alias"			=> "content",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"summary" => array(
					"xml"			=> "value",
					"alias"			=> "summary",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
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
				"published_at"=>array(
					"xml"			=> "value",
					"alias"			=> "published_at",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
				"published_by" => array(
					"xml"			=> "value",
					"alias"			=> "published_by",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> '0',
				),
				"deferred_publication"=>array(
					"xml"			=> "value",
					"alias"			=> "deferred_publication",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
				"state" => array(
					"xml"			=> "value",
					"alias"			=> "state",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"custom_data" => array(
					"xml"			=> "value",
					"alias"			=> "custom_data",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
			),
			"primary_key"	=> 'item_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array(
				array(
					"index_name"	=> "search",
					"fields_name"	=> array('title', 'summary', 'content', 'custom_data'),
					"index_type"	=> "FULLTEXT"
				),
			)
		),

		"module_relation" => array(
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
				"object_module" => array(
					"xml"			=> "value",
					"alias"			=> "object_module",
					"type"			=> "varchar(30)",
					"null" 			=> "NOT NULL",
					"default" 		=> '',
				),
				"relation_id" => array(
					"xml"			=> "value",
					"alias"			=> "relation_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"relation_module" => array(
					"xml"			=> "value",
					"alias"			=> "relation_module",
					"type"			=> "varchar(30)",
					"null" 			=> "NOT NULL",
					"default" 		=> '',
				),
				"object_order" => array(
					"xml"			=> "value",
					"alias"			=> "object_order",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"relation_order" => array(
					"xml"			=> "value",
					"alias"			=> "relation_order",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"relation_date" => array(
					"xml"			=> "value",
					"alias"			=> "date",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
			),
			"primary_key"	=> 'rel_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array()
		),
	);
}
?>