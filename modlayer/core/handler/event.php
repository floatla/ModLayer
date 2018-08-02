<?php
Class Event {

	/**
		* From https://github.com/sphido/events
		* @author Roman Ožana <ozana@omdesign.cz>
		* Adapted to work as static class
	*/

	private static $events = array();

	public static function events()
	{
		return self::$events;
		// static $events;
		// return $events ?: $events = new stdClass();
	}

	public static function listeners($event) 
	{
		if (isset(self::$events[$event])) {
			ksort(self::$events[$event]);
			return call_user_func_array('array_merge', self::$events[$event]);
		}
	}

	public static function on($event, $listener = null, $priority = 10) 
	{
		// if(!is_callable($listener))
		// 	throw new Exception("El listener no es un llamado valido");
			
		self::$events[$event][$priority][] = $listener;
			// Util::debug(self::$events);
		// $events[$event][$priority][] = $listener;
	}

	public static function one($event, $listener, $priority = 10)
	{
		if(!is_callable($listener)) {
			$text = Configuration::Translate('system_wide/event_callback_error');
			throw new Exception(sprintf($text, $listener));
		}

		$once = function () use (&$once, $event, $listener) {
			self::off($event, $once);
			return call_user_func_array($listener, func_get_args());
		};

		self::on($event, $once, $priority);
	}

	public static function off($event, $listener = null)
	{
		if (!isset(self::$events[$event])) return false;

		if ($listener === null) {
			unset(self::$events[$event]);
		} else {
			foreach (self::$events[$event] as $priority => $listeners) {
				if (false !== ($index = array_search($listener, $listeners, true))) {
					unset(self::$events[$event][$priority][$index]);
				}
			}
		}
		return true;
	}

	public static function trigger($events, ...$args)
	{
		$out = [];
		foreach ((array)$events as $event) {
			foreach ((array)self::listeners($event) as $listener) {
				if (($out[] = call_user_func_array($listener, $args)) === false) break; // return false ==> stop propagation
			}
		}

		return $out;
	}

	public static function ensure($event, $listener = null) 
	{
		if(!is_callable($listener)) {
			$text = Configuration::Translate('system_wide/event_callback_error');
			throw new Exception(sprintf($text, $listener));
		}
			
		if ($listener) self::on($event, $listener, 0); // register default listener

		if ($listeners = self::listeners($event)) {
			return call_user_func_array(end($listeners), array_slice(func_get_args(), 2));
		}
	}

}
?>