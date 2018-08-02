<?php
class ClipModel extends Model 
{
	static $table = 'clip';
	static $tag   = 'object';

	static $objectFields = array(
		'item_id'      	=> 'clip_id',
		'module'         	=> 'module',
		'parent_id'  	=> 'clip_parent',
		'created_at'     => 'created_at',
		'created_by'       => 'created_by',
		'created_type'     => 'created_type',
		'updated_at'     => 'updated_at',
		'updated_by'   => 'updated_by',
		'updated_type' => 'updated_type',
		'published_at'  	=> 'published_at',
		'title'   => 'clip_title',
		'content' => 'clip_content',
		'summary' => 'clip_summary',
		'state'   => 'clip_state',
		'deferred_publication'  => 'deferred_publication',
	);

	public static $tables = array(
		"clip" => array(
			"fields" 		=> array(
				"clip_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"clip_title" => array(
					"xml"			=> "value",
					"alias"			=> "title",
					"type"			=> "varchar(100)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"clip_summary" => array(
					"xml"			=> "nodes",
					"alias"			=> "summary",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"clip_content" => array(
					"xml"			=> "nodes",
					"alias"			=> "content",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"metatitle" => array(
					"xml"			=> "value",
					"alias"			=> "metatitle",
					"type"			=> "varchar(200)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"metadescription" => array(
					"xml"			=> "value",
					"alias"			=> "metadescription",
					"type"			=> "varchar(250)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"created_at" => array(
					"xml"			=> "attribute",
					"alias"			=> "created_at",
					"type"			=> "date",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00',
				),
				"created_by" => array(
					"xml"			=> "attribute",
					"alias"			=> "created_by",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"created_type" => array(
					"xml"			=> "attribute",
					"alias"			=> "created_type",
					"type"			=> "varchar(50)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"updated_at" => array(
					"xml"			=> "attribute",
					"alias"			=> "updated_at",
					"type"			=> "date",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00',
				),
				"updated_by" => array(
					"xml"			=> "attribute",
					"alias"			=> "updated_by",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"updated_type" => array(
					"xml"			=> "attribute",
					"alias"			=> "updated_type",
					"type"			=> "varchar(50)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"published_at" => array(
					"xml"			=> "value",
					"alias"			=> "published_at",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
				"clip_state" => array(
					"xml"			=> "attribute",
					"alias"			=> "state",
					"type"			=> "int(1)",
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
				"clip_parent" => array(
					"xml"			=> "attribute",
					"alias"			=> "parent",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"clip_youtube" => array(
					"xml"			=> "value",
					"alias"		    => "youtube",
					"type"		    => "varchar(250)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"keywords" => array(
					"xml"			=> "value",
					"alias"		    => "keywords",
					"type"		    => "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"deferred_publication" => array(
					"xml"			=> "value",
					"alias"			=> "deferred_publication",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
			),
			"primary_key"	=> 'clip_id',
			"indexes"	 	=> array(),
			'virtual' 		=> 1,
		),
	);
}
?>