<?php
class PageModel extends Model 
{
	static $table = 'page';
	static $tag   = 'object';
	
	static $objectFields = array(
		'item_id'      	=> 'page_id',
		'module'  			=> 'module',
		'parent_id'  	=> 'page_parent',
		'created_at'    	=> 'created_at',
		'created_by'       => 'created_by',
		'created_type'     => 'created_type',
		'updated_at'     => 'updated_at',
		'updated_by'   => 'updated_by',
		'updated_type' => 'updated_type',
		'published_at'      => 'published_at',
		'title'   	=> 'page_title',
		'content' 	=> 'page_content',
		'summary' 	=> 'page_summary',
		'state'   	=> 'page_state',
		'slug' 		=> 'page_url'
	);	
	
	static $tables = array(
		"page" => array(
			"fields" => array(
				"page_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"page_title" => array(
					"xml"			=> "value",
					"alias"			=> "title",
					"type"			=> "varchar(255)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"page_url" => array(
					"xml"			=> "attribute",
					"alias"			=> "url",
					"type"			=> "varchar(255)",
					"null" 			=> "NULL",
					"default" 		=> "",
				),
				"page_tags" => array(
					"xml"			=> "value",
					"alias"			=> "tags",
					"type"			=> "varchar(255)",
					"null" 			=> "NULL",
					"default" 		=> "",
				),
				"page_content" => array(
					"xml"			=> "nodes",
					"alias"			=> "content",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"page_summary" => array(
					"xml"			=> "nodes",
					"alias"			=> "summary",
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
					"type"			=> "varchar(255)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"page_datemod" => array(
					"xml"			=> "attribute",
					"alias"			=> "datemod",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> "0000-00-00 00:00:00",
				),
				"page_date" => array(
					"xml"			=> "attribute",
					"alias"			=> "date",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> "0000-00-00 00:00:00",
				),
				"module" => array(
					"xml"			=> "value",
					"alias"			=> "module",
					"type"			=> "varchar(30)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"page_parent" => array(
					"xml"			=> "attribute",
					"alias"			=> "parent",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
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
				"page_state" => array(
					"xml"			=> "attribute",
					"alias"			=> "state",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"page_url" => array(
					"xml"			=> "value",
					"alias"			=> "url",
					"type"			=> "varchar(200)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
			),
			"primary_key"	=> 'page_id',
			"indexes" 		=> array(),
			"virtual" 		=> 1,
			),
	);
}
?>