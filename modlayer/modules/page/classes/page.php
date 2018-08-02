<?php
class Page extends Element
{
	public function __construct($params = false)
	{
		
		$options = array(
			'module' => 'page',
			'tag'    => PageModel::$tag, // Solo se usa para el item
		);

		if(empty($params)) $params = array();

		$options = Util::extend(
			$options,
			$params
		);

		parent::__construct($options);
	}
}

?>