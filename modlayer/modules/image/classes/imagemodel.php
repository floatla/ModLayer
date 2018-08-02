<?php
class ImageModel extends Model 
{	
	static $multimedia_typeid = 1;
	static $table = 'image';
	static $tag   = 'image';

	static $multimediaFields = array(
		'multimedia_id'      => 'image_id',
		'multimedia_typeid'  => 'multimedia_typeid',
		'multimedia_source'  => 'image_type',
		'multimedia_parent'  => 'image_parent',
		'multimedia_userid'  => 'image_userid',
		'created_at'      => 'created_at',
		'created_by'       => 'created_by',
		'created_type'     => 'created_type',
		'updated_at'     => 'updated_at',
		'updated_by'   => 'updated_by',
		'updated_type' => 'updated_type',
		'multimedia_title'   => 'image_title',
		'multimedia_content' => 'image_summary',
		'multimedia_state'   => 'image_state',
		'multimedia_weight'  => 'image_weight',
	);
	
	static $tables = array(
		'image'	=> array(
			'fields' 		=> array(
				'image_id' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'image_id',
					'type'			=> 'int(11)',
					'null' 			=> 'NOT NULL',
					'default' 		=> false,
					'extra' 		=> 'auto_increment',
				),
				'image_title' => array(
					'xml'			=> 'value',
					'alias'			=> 'title',
					'type'			=> 'varchar(100)',
					'null' 			=> 'NULL',
					'default' 		=> false,
				),
				'image_summary' => array(
					'xml'			=> 'value',
					'alias'			=> 'summary',
					'type'			=> 'text',
					'null' 			=> 'NULL',
					'default' 		=> false,
				),
				'image_type' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'type',
					'type'			=> 'varchar(10)',
					'null' 			=> 'NULL',
					'default' 		=> '',
				),
				'created_at' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'created_at',
					'type'			=> 'datetime',
					'null' 			=> 'NOT NULL',
					'default' 		=> '0000-00-00 00:00:00',
				),
				'created_by' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'created_by',
					'type'			=> 'int(11)',
					'null' 			=> 'NOT NULL',
					'default' 		=> '0',
				),
				'created_type' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'created_type',
					'type'			=> 'varchar(50)',
					'null' 			=> 'NULL',
					'default' 		=> '',
				),
				'updated_at' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'updated_at',
					'type'			=> 'datetime',
					'null' 			=> 'NOT NULL',
					'default' 		=> '0000-00-00 00:00:00',
				),
				'updated_by' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'updated_by',
					'type'			=> 'int(11)',
					'null' 			=> 'NOT NULL',
					'default' 		=> '0',
				),
				'updated_type' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'updated_type',
					'type'			=> 'varchar(50)',
					'null' 			=> 'NULL',
					'default' 		=> '',
				),
				'image_state' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'state',
					'type'			=> 'int(1)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'multimedia_typeid' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'type_id',
					'type'			=> 'int(1)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_parent' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'parent',
					'type'			=> 'int(1)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_userid' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'user_id',
					'type'			=> 'int(1)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_width' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'width',
					'type'			=> 'int(5)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_height' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'height',
					'type'			=> 'int(5)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_weight' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'weight',
					'type'			=> 'int(30)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_preview' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'preview',
					'type'			=> 'int(1)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_tags' => array(
					'xml'			=> 'value',
					'alias'			=> 'tags',
					'type'			=> 'varchar(100)',
					'null' 			=> 'NULL',
					'default' 		=> '',
				),
				'image_weight' => array(
					'xml'			=> 'attribute',
					'alias'			=> 'weight',
					'type'			=> 'int(15)',
					'null' 			=> 'NOT NULL',
					'default' 		=> 0,
				),
				'image_credit' => array(
					'xml'			=> 'value',
					'alias'			=> 'credit',
					'type'			=> 'text',
					'null' 			=> 'NULL',
					'default' 		=> '',
				),
				'keywords' => array(
					'xml'			=> 'value',
					'alias'			=> 'keywords',
					'type'			=> 'text',
					'null' 			=> 'NULL',
					'default' 		=> '',
				),
			),
			'primary_key'	=> 'image_id',
			'indexes'	 	=> array(
				'index_name'	=>	'',
				'fields_name'	=>	'',
				'index_type'	=>	''
			),
			'virtual' => 1,
		),		
	);
}
?>