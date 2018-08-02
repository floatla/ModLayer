<?php
class CategoryModel extends Model
{
	public static $table         = 'category';
	public static $relationTable = 'category_relation';

	public static $tables = array(
		"category" => array(
			"fields" 		=> array(
				"category_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "category_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"category_name" => array(
					"xml"			=> "value",
					"alias"			=> "name",
					"type"			=> "varchar(255)",
					"null" 			=> "NOT NULL",
					"default" 		=> '',
				),
				"category_parent" => array(
					"xml"			=> "attribute",
					"alias"			=> "parent",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"category_order" => array(
					"xml"			=> "attribute",
					"alias"			=> "order",
					"type"			=> "int(3)",
					"null" 			=> "NULL",
					"default" 		=> 0,
				),
				"category_url" => array(
					"xml"			=> "attribute",
					"alias"			=> "url",
					"type"			=> "url(255)", // El tipo url es un varchar que se transforma en url amigable reemplazando caracteres raros
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"category_description" => array(
					"xml"			=> "value",
					"alias"			=> "description",
					"type"			=> "text",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
				"image_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "image_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
				),
				"image_type" => array(
					"xml"			=> "attribute",
					"alias"			=> "image_type",
					"type"			=> "varchar(4)",
					"null" 			=> "NULL",
					"default" 		=> '',
				),
			),
			"primary_key"	=> 'category_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array()
			),

		"category_relation" => array(
			"fields" 		=> array(
				"rel_id"=>array(
					"xml"			=>"attribute",
					"alias"			=>"rel_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> 0,
					"extra" 		=> "auto_increment",
				),
				"item_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "category_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> '0',
				),
				"module" => array(
					"xml"			=> "value",
					"alias"			=> "module",
					"type"			=> "varchar(30)",
					"null" 			=> "NOT NULL",
					"default" 		=> 'notset',
				),
				"category_id" => array(
					"xml"			=> "attribute",
					"alias"			=> "category_id",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> '0',
				),
				"category_parentid" => array(
					"xml"			=> "attribute",
					"alias"			=> "category_parentid",
					"type"			=> "int(11)",
					"null" 			=> "NOT NULL",
					"default" 		=> '0',
				),
				"category_order" => array(
					"xml"			=> "attribute",
					"alias"			=> "category_order",
					"type"			=> "int(2)",
					"null" 			=> "NOT NULL",
					"default" 		=> '0',
				),				
			),
			"primary_key"	=> 'rel_id',
			"charset"		=> 'utf8',
			"indexes" 		=> array(
				array(
					"index_name"	=> "ix_item",
					"fields_name"	=> array('item_id'),
					"index_type"	=> "INDEX"
				)
			)
		)
	);
}
?>