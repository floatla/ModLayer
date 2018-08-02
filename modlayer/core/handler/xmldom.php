<?php
Class XMLDom extends DOMDocument {
	
	private $dom;
	private $namespace = false;


	public function __construct()
	{
		parent::__construct('1.0', 'UTF-8');
		$this->preserveWhiteSpace = false;
		$this->formatOutput = true;
		return $this;
	}

	public function Query($node, $xml=false)
	{
		if($xml){
			$source = new XMLDom();
			$dom_sxe = $source->importNode($xml, true);
			$source->appendChild($dom_sxe);			
		}else{
			$source = $this;
		}

		$xpath  = new DOMXPath($source);

		if(is_array($this->namespace))
			$xpath->registerNamespace($this->namespace['name'], $this->namespace['value']);

		$return = $xpath->query($node);

		if(!$return)
			return false;
		elseif($return->length == 0)
			return false;
		else
			return $return;
	}

	public function registerNamespace($name, $value)
	{
		$this->namespace = array(
			'name' => $name,
			'value' => $value,
		);
	}

	/**
	 * Recursive function to turn a DOMDocument element to an array
	 * @param DOMDocument $root the document (might also be a DOMElement/DOMNode?)
	 */
	public function XML2Array()
	{
		return $this->ParseXML2Array($this->firstChild);
	}

	public function ParseXML2Array($node)
	{
		$array = [];
		$name  = $node->nodeName;

		if($node->hasAttributes())
		{
			foreach ($node->attributes as $attr)
			{
				$array['_'.$attr->nodeName] = $attr->nodeValue;
			}
		}

		if($name == 'p' || $name == 'content' || $name == 'summary' || $name == 'description'){
			return $this->NodeAsString($name, $node);
		}

		if($node->hasChildNodes()){
			$name  = $node->childNodes->item(0)->nodeName;
			$count = count($node->getElementsByTagName($name));
			foreach($node->childNodes as $childNode)
			{
				if ($childNode->nodeType == XML_TEXT_NODE || $childNode->nodeType == XML_CDATA_SECTION_NODE)
				{
					$array = $childNode->nodeValue;
				}
				else
				{
					if(!is_string($array)){
						if($childNode->nodeName == $name && $count > 1)
							$array[$childNode->nodeName][] = $this->ParseXML2Array($childNode);
						else
							$array[$childNode->nodeName] = $this->ParseXML2Array($childNode);
					}
					else{
						$array = $childNode->nodeValue;
					}
				}
				$name = $childNode->nodeName;
			}
		}
		return $array;
	}

	private function NodeAsString($name, $node)
	{
		$str = $this->saveXML($node);
		$str = str_replace('<'.$name.'>', '', $str);
		$str = str_replace('</'.$name.'>', '', $str);
		$str = str_replace('<'.$name.'/>', '', $str);
		return $str;
	}

}
?>