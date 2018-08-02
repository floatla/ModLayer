<?php
Class XSLDoc
{
	public function __construct()
	{
		// set_error_handler(array('XSLDoc','XML_errorHandler'));
	}

	public function XMLTransform($xmlDoc, $xslDoc, $params=array())
	{
		$xml = new DOMDocument("1.0", "UTF-8");
		$xml->loadXML($xmlDoc);

		$xsl = new DOMDocument("1.0", "UTF-8");
		$xsl->loadXML($xslDoc);

		$proc = new XSLTProcessor;
		// $proc->setProfiling('profiling.txt');
		libxml_use_internal_errors(true);

		$proc->importStyleSheet($xsl);

		if (is_array($params) && count($params))
			{
				foreach ($params as $key=>$value) {
					$proc->setParameter(null, $key, $value);
				}
			}
		
		$fechaActual = date("Y-m-d");
		$horaActual  = date("H:i");
		$diaActual   = date("l", mktime(0,0,0, substr($fechaActual, 5, 2), substr($fechaActual, 8, 2), substr($fechaActual, 0, 4)));
		$proc->setParameter(null, "fechaActual", $fechaActual);
		$proc->setParameter(null, "horaActual", $horaActual);
		$proc->setParameter(null, "diaActual", $diaActual);
		
		set_error_handler(array($this, 'XML_errorHandler'));
		$t = $proc->transformToXML($xml);
		if(!$t)
		{
			$errValues = array();

			foreach (libxml_get_errors() as $error) {
				// echo "Libxml error: {$error->message}.";
				$errValues[] = 	"Libxml error: {$error->message}.";
			}
			throw new Exception("Error Processing XSL: <br/>" . implode('<br/>', $errValues) , 1);
		}
			// $lastError = error_get_last();
			// Util::debug($php_errormsg);
			// throw new Exception("Error Processing XSL", 1);
			
		return $t;
		

		// return $return;
	}

	public function XML_errorHandler($errno, $errstr, $errfile, $errline, $errcontext)
	// deal with errors from XML or XSL functions.
	{
		// Util::debug($errcontext);
		// die;
		// pass these details to the standard error handler
		MLError::ErrorHandler(E_USER_ERROR, $errstr, $errfile, $errline, $errcontext);
	} // XML_errorHandler

	public function XSLHandler($E_USER_ERROR, $errstr, $errfile, $errline, $errcontext)
	{
		var_dump($errstr);
		var_dump($errcontext);
	}
}


?>