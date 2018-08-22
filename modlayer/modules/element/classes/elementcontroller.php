<?php
class ElementController extends AdminController
{

	/**
	* RenderDefault muestra un listado de elementos del módulo que lo esté pidiendo 
	* @return void.
	**/
	public static function RenderDefault()
	{
		$module = Application::GetModule();
		$query  = Util::getvalue('q');


		$element    = new $module();
		$collection = $element->Collection(
			// array('debug' => true)
		);

		parent::loadAdminInterface();
		parent::$template->setcontent(
			$collection->Get(), 
			null, 
			'collection'
		);

		parent::$template->setcontent(
			$collection->CategoryFilters(), 
			null, 
			'filter'
		);
		parent::$template->setparam(
			$collection->getFilters()
		);
		
		parent::$template->add("list.xsl");
		parent::$template->display();
	}

	/**
	* RenderEdit muestra en pantalla el editor de un elemento del modulo activo
	* @return void.
	**/
	public static function RenderEdit()
	{
		$id      = Util::RuleParam('id');
		$module  = Application::GetModule();
		
		$element = new $module();
		$item = $element->item(
			$id,
			array('metadata' => true)
		);
		
		$data = $item->Get();

		if(!$data)
			Application::Route(
				array(
					'module' => $module
				)
			);

		
		parent::loadAdminInterface();
		parent::$template->setcontent(
			$data, 
			null, 
			'object'
		);

		/*/
			Agregar contenido vinculado (child)
		/*/
		$childs = $element->Children($id, $state=false);
		parent::$template->setcontent(
			$childs, 
			null, 
			'children'
		);

		$elementConf = Configuration::GetModuleConfiguration('element');
		$groups      = Configuration::Query('/module/options/group', $elementConf);

		parent::$template->setconfig($groups, null, 'element_conf');
		parent::$template->add("edit.xsl");
		parent::$template->display();
	}

	/**
	* RenderAdd Genera un elemento vacio y redirecciona al editor
	* @return void.
	**/
	public static function RenderAdd()
	{

		$module  = Application::GetModule();
		$element = new $module();
		$id      = $element->NewItem();

		$display = array(
			'item_id'    => $id,
			'module'     => $module,
			'back'       => 0,
		);

		Application::Route($display);
	}

	/**
	* BackAdd Save a new item
	* @return void.
	**/
	public static function BackAdd()
	{
		$module  = Application::GetModule();
		$element = new $module();
		$id      = $element->Add($_POST);

		$display = array(
			'item_id'    => $id,
			'module'     => $module,
			'back'       => 0,
		);

		Application::Route($display);
	}

	/**
	* BackEdit Save a edited item
	* @return void.
	**/
	public static function BackEdit()
	{
		$ajax = Util::PostParam('ajaxEnabled');
		$back = Util::PostParam('back');

		unset($_POST['ajaxEnabled']);
		unset($_POST['back']);

		$module  = Application::GetModule();
		$element = new $module();
		$id      = $element->Edit($_POST); // Retorna el ID del elemento editado, o falso si no existe

		if(is_callable(array($module, 'FlushAutoSave')))
			$element->FlushAutoSave($id);

		$display = array(
			'back'    => ($back == 1) ? 1 : 0,
			'item_id' => ($id) ? $id : false,
			'module'  => $module,
		);

		if(!$ajax) {
			Application::Route($display);
		}

		Util::OutputJson(
			array(
				'code' => 200,
				'message' => 'ok',
				'url' => Application::RouteUrl($display),
			)
		);
	}


	/**
	*	BackJsonItem imprimir un elemento en formato json
	*	es utilizado para pedir datos con javascript
	*	@return void.
	**/
	public static function BackJsonItem()
	{
		// $id      = Util::getvalue('id');
		// $module  = Application::GetModule();
		
		// $element = new $module();
		// $item = $element->item($id);
		// $item->LoadFromDB();

		// if(!$item->RawContent()){ // No llamar a content()! para que no pida cateogrias y relaciones!
		// 	$response = array(
		// 		'code' => 500,
		// 		'message' => "El elemento $id no existe."
		// 	);
		// } 
		
		// $content = $item->content();
		// Util::ClearArray($content);

		// $response = array(
		// 	'code' => 200,
		// 	'item' => $content,
		// );
		
		// Util::OutputJson($response);

	}

	/**
	*	GotoItem redirecciona a la URL del item publicado
	*	@return void.
	**/
	public static function GotoItem()
	{
		$id     = Util::GetParam('id');
		$module = Application::GetModule();

		$elem = new $module();
		$item = $elem->Item($id);

		$data = $item->Get();

		if(isset($data['url'])){
			Util::redirect(str_replace('?','', $data['url']));
			die;	
		}

		$slug = (isset($data['slug'])) ? $data['slug'] : Util::Sanitize($data['title']);
		Util::redirect('/' . $id . '-' . $slug);	
	}


	/*** PUBLICAR / DESPUBLICAR ***/

	/**
	*	BackPublish recibe un id para publicar el contenido en xml
	*	@param id : del elemento a publicar
	*	@param internallCall : define si imprime en pantalla un json con el resultado o retorna el elemento
	*/
	public static function BackPublish($id=false, $internalCall=false)
	{
		$id = (!$id) ? Util::getvalue('item_id') : $id;

		$module  = Application::GetModule();
		$element = new $module();

		// Pedimos el elemento con todos los datos disponibles para publicarlo
		$item = $element->item($id,
			array(
				'internalCall' => $internalCall,
			)
		);
		
		$item->Publish();

		

		if(!$internalCall)
		{
			Cache::SoftClear($module);
			$response = array(
				'code' => 200,
				'meesage' => 'Ok',
				'id'      => $id,
			);
			Util::OutputJson($response);
		}
	}

	/**
	*	Limpia la estructura de un elemento a un formato 
	*	acorde al mapeo de ElasticSearch
	*/
	public static function ClearRecursive__(&$input)
	{
		foreach ($input as $key => $value)
		{
			if (is_array($input[$key]))
			{
				switch($key)
				{
					case $key == "relations":
					case $key == "multimedias":
						unset($input[$key]);
						break;
					case $key == "categories":
						$terms = array();
						$input[$key] = Util::arrayNumeric($input[$key]);

						if(!empty($input[$key][0][0]))
						{
							foreach($input[$key] as $group)
							{
								$group = Util::arrayNumeric($group);
								foreach($group as $index=>$category)
								{
									if(is_array($category))
									{
										$terms[] = array('name' => $category['name'], 'category_id' => $category['category_id-att']);
									}
								}
							}
							$input[$key] = $terms;
						}
						else
						{
							unset($input[$key]);
						}
						break;
					default:
						self::ClearRecursive($input[$key]);
						break;				
				}
			}
			else
			{
				switch($key)
				{
					case "created_at":
					case "updated_at":
					case "published_at":
						if($value == '0000-00-00 00:00:00') {
					   		$value = '1979-12-17 07:00:00';
					   	}
						$input[$key] = str_replace(' ', 'T', $value);
						break;
					case "categories":
						unset($input[$key]);
						break;
				}
				
				$value = str_replace("\n", '', $value);
				$value = str_replace("\r", '', $value);
				$value = str_replace("\n\r", '', $value);

				$saved_value = $value;
				$saved_key   = $key;
				Util::ClearKeys($value, $key);

				if($value !== $saved_value || $saved_key !== $key):
					unset($input[$saved_key]);
					$input[$key] = strip_tags($value);
				endif;
			}
		}

		// Added for geo location
		if(!empty($input['latitud']) && !empty($input['longitud'])){
			$input['pin'] = array('location' => array('lat' => $input['latitud'], 'lon' => $input['longitud']));
			unset($input['latitud']);
			unset($input['longitud']);
		}
	}

	/**
	*	Despublica un elemento
	*	@return void
	*/
	public static function BackUnPublish()
	{
		$id = Util::getvalue('item_id');

		$module  = Application::GetModule();
		$element = new $module();

		// Check homes
		$hasHome = false;
		try{
			if(class_exists("Instance", true)){
				$hasHome = true;
			}
		}
		catch(Exception $e){/* La clase no se puede cargar */}

		if ($hasHome !== false)
		{
			$hasInstance = Instance::isTaken($id, $module);
			if($hasInstance)
			{
				$json = array(
					'code'    => 500,
					'message' => sprintf(
						Configuration::Translate('backend_messages/delete_home_instance'),
						$hasInstance['object_title'],
						$hasInstance['title']
					),
					'id'      => $id,
				);
				Util::OutputJson($json);
				die;
			}
		}

		/* Is ElasticSearch available ? */
		$elasticSearch = false;
		try{
			if(class_exists("ElasticSearch", true)){
				$elasticSearch = true;
			}
		}
		catch(Exception $e){
			// La clase no se puede cargar
		}

		if ($elasticSearch !== false)
		{
			ElasticSearch::Delete($module, $id);
		}
		/* End ElasticSearch */

		
		// Pedimos el elemento con todos los datos disponibles para publicarlo
		$item = $element->item($id);
		$item->LoadFromDB();

		$item->setProperty('state', 0);

		// Guardar en la base
		$item->Save();
		$item->DeleteXML();

		// Guardar las relaciones
		$item->__destruct();
		$item->UpdateRelations();

		// Pugar el cache
		Cache::SoftClear($module);

		$response = array(
			'code' => 200,
			'meesage' => 'Ok',
			'id'      => $id,
		);
		Util::OutputJson($response);
	}


	/*** COLLECTION ***/

	

	/**
	* BackAjaxList se utiliza para el paginado con ajax de listados
	* @return void.
	**/
	public static function BackAjaxList()
	{
		try{
			$id          = Util::getvalue('parent_id');
			$childModule = Util::getvalue('module');
			$module      = Application::GetModule();
			
			$element = new $module();
			
			parent::loadAdminInterface("ajax.xsl", false, 'element');
			$childs = $element->Children($id);
			parent::$template->setcontent(
				$childs, 
				null, 
				'children'
			);
			parent::$template->setparam('call', 'children');
			parent::$template->setparam('item_id', $id);
			parent::$template->setparam('module', $childModule);
			$html = parent::$template->returnDisplay();

			$response = array(
				'code' => 200,
				'message' => 'ok',
				'module' => $childModule,
				'html' => $html,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage()
			);
		}

		Util::OutputJson($response);
	}



	
	/*** CATEGORY ***/


	




	


	

	

	

	



	/*** PARENT ***/

	/**
	*	RenderItemParent muestra un listado de elementos de un modulo para elegir otro contenido como parent
	*	segun los parametros recibidos
	*	@return void
	*/
	public static function RenderItemParent()
	{
		$id     = Util::getvalue('item_id');
		$mp     = Util::getvalue('moduleParent');
		$query  = Util::getvalue('q');
		$module = Application::GetModule();

		// if(empty($type_id)) throw new Exception("No se recibió el tipo id para el listado", 1);
		

		// Obtenermos las relaciones que ya tiene el elemento
		$element    = new $mp();
		$collection = $element->Collection(
			array('module' => $mp)
		);

		
		parent::loadAdminInterface($base='modal.parent.xsl', false, 'element');

		parent::$template->setcontent(
			$collection->Get(), 
			null, 
			'collection'
		);
		parent::$template->setcontent(
			$collection->CategoryFilters(), 
			null, 
			'filter'
		);

		parent::$template->setparam(
			$collection->getFilters()
		);
		parent::$template->setparam(
			array(
				'item_id' => $id,
				'moduleParent'  => $mp,
				'active_module' => $module,
			)
		);
		parent::$template->display();
	}

	/**
	*	BackSetParent setea un elemento como parent de otro
	*	segun los parametros recibidos
	*	@return void
	*/
	public static function BackSetParent()
	{
		$id        = Util::getvalue('item_id');
		$parent_id = Util::getvalue('parent_id');
		$parentMod = Util::getvalue('moduleParent');

		if(empty($parent_id)){
			$parent_id = 0;
		}
		
		try
		{
			$module  = Application::GetModule();
			$el      = new $module();

			$item = $el->item($id);
			$item->setProperty('parent_id', $parent_id);

			$item->Save();

			$response = array(
				'code'      => 200,
				'message'   => 'Ok',
				'item_id'   => $id,
				'parent_id' => $parent_id,
				'parentModule' => $parentMod,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code'    => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($response);
	}

	/**
	*	BackRefreshParent actualiza en pantalla el parent de un item
	*	@return void
	*/
	public static function BackRefreshParent()
	{
		$id      = Util::getvalue('item_id');
		$module = Util::getvalue('module');

		try
		{

			$element = new $module();
			$item = $element->item($id);
			

			parent::loadAdminInterface($base='ajax.xsl', false, 'element');
			parent::$template->setcontent(
				$item->Get(), 
				null, 
				'item'
			);
			parent::$template->setparam(
				array(
					'call'    => 'parent',
					'item_id' => $id,
					'module'  => $module
				)
			);

			// parent::$template->displayXML();
			$html = parent::$template->returnDisplay();

			$json = array(
				'code'		=> 200,
				'message'	=> 'Ok',
				'id'		=> $id,
				'module'	=> $module,
				'html'		=> $html,
			);
		}
		catch(Exception $e)
		{
			$json = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($json);
	}


	public static function BackUnsetChildren()
	{
		$id        = Util::getvalue('id');
		$parent_id = 0;

		try
		{
			$module  = Application::GetModule();
			$el      = new $module();

			$item = $el->item($id);
			$item->setProperty('parent_id', 0);

			$item->Save();

			$response = array(
				'code'      => 200,
				'message'   => 'Ok',
				'item_id'   => $id,
				'module' => $module
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code'    => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($response);
	}





	/***  MULTIMEDIAS ***/

	/**
	*	BackUpdateMultimedia sobreescribe el metodo definido en AdminController
	*	para definir la ruta del XSL
	*	@return void
	*/
	public static function BackUpdateMultimedia()
	{
		parent::$module = 'element';
		parent::BackUpdateMultimedia();
	}
	
	

	/**
	*	FrontRedirect
	*	Toma una url en el formato /a/{id} y la redirecciona al modulo / item correspondiente con la url completa
	*	@return void
	*/
	public static function FrontRedirect()
	{
		$id = Util::getvalue('id');
		$get = $_GET;

		$element = new Element();
		$module  = $element->getmodule($id);
		// echo $module;
		// die;
		// $module  = Configuration::Query("/configuration/modules/module[@type_id = '". $type ."']")->item(0)->getAttribute('name');

		$article = new $module();
		$item = $article->item($id);
		$item = $item->LoadFromXML();

		if($item)
		{
			$xml = new XMLDom();
			$xml->load($item);

			$url = $xml->Query('/xml/*/slug|/xml/*/object_url');

			$slug = (!$url) 
					? Util::Sanitize($xml->Query('/xml/*/title')->item(0)->nodeValue) 
					: $url->item(0)->nodeValue; 

			$location = '/' . $module . '/'.$id.'/'. $slug;
			if(!empty($get)){
				$location .= '/?';
				foreach ($get as $param => $value) {
					$location .= $param . '=' . $value . '&';
				}
			}

			header ('HTTP/1.1 301 Moved Permanently');
  			header ('Location: '.$location);
  			die;
		}
		else
		{
			Frontend::RenderNotFound();
			// Util::redirect('/not-found/404/?'.$module.'-not-valid');
		}	
	}

	/*/ Publicacion Diferida /*/

	/**
	*	PublishContent
	*	Publica todos los elementos segun el campo publication_date de cada uno (publicacion diferida).
	*	@return void
	*/
	public static function PublishContent()
	{
		try{
			$now     = strtotime(date('Y-m-d H:i:s'));

			$element = new Element();
			$elements = $element->GetElementsForDP();
			if($elements)
			{
				foreach($elements as $element)
				{

					$publicationDate = strtotime($element['deferred_publication']);
					if($publicationDate <= $now)
					{
						$module  = $element['module']; 
						$obj  = new $module();
						$item = $obj->item($element['item_id'], array( 'internalCall' => true ));
						$item->Publish();
						$item->SaveAfterDP();
					}
				}
			}
		}
		catch(Exception $e){
			$e->getMessage();
		}
	}
}
?>