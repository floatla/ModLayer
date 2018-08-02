<?php
class ArticleModel extends Model 
{
	static $table = 'article';
	static $tag   = 'object';

	static $objectFields = array(
		'item_id'         => 'article_id',
		'module'         	=> 'module',
		'parent_id'     => 'article_parent',
		'title'      => 'article_title',
		'content'    => 'article_content',
		'summary'    => 'article_summary',
		'state'      => 'article_state',
		'slug'        => 'slug',
		'created_at'     => 'created_at',
		'created_by'       => 'created_by',
		'created_type'     => 'created_type',
		'updated_at'     => 'updated_at',
		'updated_by'   => 'updated_by',
		'updated_type' => 'updated_type',
		'published_at'  => 'published_at',
		'deferred_publication'  => 'deferred_publication',
	);


	static $tables = array(
		"article" => array(
			"fields" 		=> array(
				"article_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"article_header" => array(
					"xml"			=> "value",
					"alias"			=> "header",
					"type"			=> "varchar(250)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"article_title" => array(
					"xml"			=> "value",
					"alias"			=> "title",
					"type"			=> "varchar(350)",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"article_summary" => array(
					"xml"			=> "nodes",
					"alias"			=> "summary",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"article_content" => array(
					"xml"			=> "nodes",
					"alias"			=> "content",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"article_author" => array(
					"xml"			=> "value",
					"alias"			=> "author",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> NULL,
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
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
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
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
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
				"deferred_publication" => array(
					"xml"			=> "value",
					"alias"			=> "deferred_publication",
					"type"			=> "datetime",
					"null" 			=> "NOT NULL",
					"default" 		=> '0000-00-00 00:00:00',
				),
				"keywords" => array(
					"xml"			=> "value",
					"alias"			=> "keywords",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
				"article_comments" => array(
					"xml"			=> "attribute",
					"alias"			=> "comments",
					"type"			=> "tinyint(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"article_state" => array(
					"xml"			=> "attribute",
					"alias"			=> "state",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"article_parent" => array(
					"xml"			=> "attribute",
					"alias"			=> "parent",
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
				"slug" => array(
					"xml"			=> "value",
					"alias"			=> "slug",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"article_externallink" => array(
					"xml"			=> "value",
					"alias"			=> "externallink",
					"type"			=> "varchar(255)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"article_latitud" => array(
					"xml"			=> "value",
					"alias"			=> "latitud",
					"type"			=> "varchar(50)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"article_longitud" => array(
					"xml"			=> "value",
					"alias"			=> "longitud",
					"type"			=> "varchar(50)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"show_map" => array(
					"xml"			=> "value",
					"alias"			=> "show_map",
					"type"			=> "int(1)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
			),
			"primary_key"	=> 'article_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array(),
			"virtual" 		=> 1,
		),

		"article_assets" => array(
			"fields" 		=> array(
				"uid" => array(
					"xml"			=> "attribute",
					"alias"			=> "uid",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"article_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "article_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"asset" => array(
					"xml"			=> "value",
					"alias"			=> "header",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> NULL,
				),
			),
			// "primary_key"	=> 'uid',
			"charset"		=> 'utf8',
			"indexes" 		=> array(
				array(
					"index_name"	=> "uid",
					"fields_name"	=> array('uid'),
					"index_type"	=> "UNIQUE"
				),
			),
		),
	);

}
?>