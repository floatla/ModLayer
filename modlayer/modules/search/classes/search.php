<?php
class Search
{

	public static function FetchResults($dto)
	{
		$module  = Configuration::GetModuleConfiguration('search');
		$config  = Configuration::Query("/module/options/group[@name='modules']/option", $module);
		$catFilter = [];
		$tagFilter = [];

		$dto['catFilters'] = $catFilter;
		$dto['tagFilters'] = $tagFilter;

		foreach($config as $item)
		{
			$class     = $item->getAttribute('module');

			$modConfig = Configuration::GetModuleConfiguration($class);
			$parent    = $modConfig->getAttribute('parent_name');

			$dto['module'] = $class;

			$mod    = new $class();
			$result = $mod->SearchFiltered($dto);
		}

		$result['query-att'] = Encoding::toUTF8($dto['query']);
		return $result;
	}
}
?>