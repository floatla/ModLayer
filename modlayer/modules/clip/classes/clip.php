<?php
class Clip extends Element
{
	public function __construct($params = false)
	{

		$options = array(
			'module' => 'clip',
			'tag'    => ClipModel::$tag, // Solo se usa para el item
		);

		if(empty($params)) $params = array();

		$options = Util::extend(
			$options,
			$params
		);

		parent::__construct($options);
	}


	/**
	*	Sobre escribimos el metodo de la clase Element, para poder importar
	*	un video de youtube con la api.
	*	@return 1
	*/
	public function Edit($dto)
	{
		/*
			Para todas la interacciones con la base validamos el token
		*/
		if($this->params['internalCall'] === false)
		{
			Application::validateToken();
		}

		/*
			Lo instanciamos y lo cargamos de la base 
			para validar que exista
		*/
		$item = new ElementItem(
			$dto['clip_id'], 
			$this->params
		);


		if(!$item->Exists()) return false;


		/*
			Si solo viene la URL de youtube, importamos los datos
		*/
		if($dto['clip_title'] == '' && $dto['clip_youtube'] != '')
		{
			$youtube_id = $this->getYoutubeIdFromUrl($dto['clip_youtube']);
			$data       = $this->YoutubeFetch($youtube_id);
			$dto        = array_merge($dto, $data);

			$response = $this->ImportYoutubeImg($youtube_id, $dto['clip_title']);
			if($response)
			{
				$tmp = $this->item($dto['clip_id']);
				$tmp->SetMultimedia($response['image_id']);
			}
		}

		
		return parent::Edit($dto);
		
		// /*
		// 	Agregamos los datos del usuario modificando el elemento
		// */
		// $user = Admin::Logged();
		// $dto['modification_date']     = date('Y-m-d H:i:s');
		// $dto['modification_userid']   = (!empty($dto['user_id'])) ? $dto['user_id'] : $user['user_id'];
		// $dto['modification_usertype'] = (!empty($dto['user_type'])) ? $dto['user_type'] : $this->params['user_type'];

		
		// /*
		// 	Convertimos el array de datos al formato Element
		// */
		// $element = call_user_func_array(
		// 	array(
		// 		'Model', 
		// 		'inputObjectFields')
		// 	, 
		// 	array(
		// 		array(
		// 			'fields'        => $dto,
		// 			'table'         => ClipModel::$table,
		// 			'tables'        => ClipModel::$tables,
		// 			'objectFields'  => ClipModel::$objectFields,
		// 			'verbose'       => $this->params['verbose']
		// 		)
		// 	)
		// );

		// // Seteamos el contenido
		// $item->Set($element);

		// // Antes de guardar cambiamos el estado si está publicado
		// $st = $item->getProperty('state');
		// if($st == 1)
		// 	$item->SetProperty('state', 3);

		// // Guardamos el item
		// return $item->Save();
	}






	
	/**
	* BackAdd Save a new item
	* @return void.
	**/
	public function Add($dto, $internalCall=false)
	{
		$this->params['internalCall'] = $internalCall;
		$id  = parent::Add($dto);

		// If youtube URL is present, we will import the image and make the relation
		if(!empty($dto['clip_youtube']))
		{
			$url = $dto['clip_youtube'];
			$youtube_id = $this->getYoutubeIdFromUrl($url);

			$response = $this->ImportYoutubeImg($youtube_id, $dto['clip_title']);
			if($response)
			{
				$element = new Clip();
				$item = $element->item($id);
				$item->SetMultimedia($response['image_id']);
			}
		}

		if(!$internalCall){
			return $id;
		}
		else{
			return array(
				'clip_id'  => $id,
				'image_id' => $response['image_id'],
			);
		}
	}

	public function getYoutubeIdFromUrl($url)
	{
		$parts = parse_url($url);
		if(isset($parts['query'])){
			parse_str($parts['query'], $qs);
			if(isset($qs['v'])){
				return $qs['v'];
			}else if(isset($qs['vi'])){
				return $qs['vi'];
			}
		}
		if(isset($parts['path'])){
			$path = explode('/', trim($parts['path'], '/'));
			$youtube_id = $path[count($path)-1];

			if(strpos($youtube_id, '?') !== false)
				$youtube_id = substr($youtube_id, 0, strpos($youtube_id, '?'));

			return $youtube_id;
		}
		return false;
	}

	public function ImportYoutubeImg($id, $title)
	{

		// Util::debug("arranco.");
		// Max Resolution Size
		$src     = 'http://img.youtube.com/vi/'.$id.'/maxresdefault.jpg';
		$content = @file_get_contents($src);

		if($content === false){
			$src     = 'http://img.youtube.com/vi/'.$id.'/hqdefault.jpg';
			$content = @file_get_contents($src);			
		}

		if($content === false): return false; endif;

		$options = array(
			'module' => 'multimedia',
			'folderoption' => 'target',
		);

		$realpath = PathManager::GetContentTargetPath($options);

		$tempFile = $realpath .'/'. $id;

		$fp = fopen($tempFile, "w");
		fwrite($fp, $content);
		fclose($fp);


		$weight = filesize($tempFile);
		list($width, $height) = getimagesize($tempFile);

		try
		{
			$image  = new Image(
				array(
					'internalCall' => true // Para poder agregar un registro a la base sin validar token
				)
			);
			$dto = array(
				'image_title'       => $title,
				'image_type'		=> 'jpg',
				'image_width'		=> $width,
				'image_height'		=> $height,
				'image_weight'		=> $weight,
				'multimedia_typeid'	=> 1,
				'created_at'     => date('Y-m-d H:i:s'),
				'created_by'   => -1,
				'created_type' => 'system',
			);

			$image_id = $image->Add($dto);
			$options = array(
				'module'       => 'image',
				'folderoption' => 'target',
			);
			$path = PathManager::GetContentTargetPath($options);
			$path = PathManager::GetDirectoryFromId($path, $image_id);
			$file = $path.'/'.$image_id.'.jpg';
			
			@rename($tempFile, $file);
			@chmod($file, 0775);

			$this->setImageCategory($image_id);

			return array(
				'image_id' => $image_id,
				'type'     => 'jpg',
				'width'    => $width,
				'height'   => $height
			);
		}
		catch(Exception $e)
		{
			return false;
		}
	}

	private function setImageCategory($image_id)
	{
		$option = Configuration::Query("/configuration/modules/module[@name='clip']/options/group[@name='multimedias']/option[@name='image']");

		if($option)
		{
			$category_id = $option->item(0)->getAttribute('category_id');
			if(!empty($category_id))
			{
				$imgs       = array($image_id);
				$categories = array($category_id);

				$temp    = new Image();
				$collection = $temp->Collection();
				$collection->SetCategories($imgs, $categories);

			}
		}
	}

	public function YoutubeFetch($youtube_id)
	{
		$url = 'https://www.youtube.com/watch?v=' . $youtube_id;

		$yt = new Youtube();
		$service = $yt->getService();

		$response = $service->videos->listVideos('id,snippet', array(
			'id' => $youtube_id
		));

		$summary = $response['items'][0]['snippet']['description'];
		$summary = str_replace("\n", "<br/>", $summary);
		$tags    = (isset($response['items'][0]['snippet']['tags'])) ? implode(', ', $response['items'][0]['snippet']['tags']) : '';
		// $tags    = Encoding::toUTF8($tags);
		$tags = preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $tags);
		$data = array(
			'clip_youtube' => $url,
			'clip_title' => $response['items'][0]['snippet']['title'],
			'clip_summary' => $summary,
			'keywords' => $tags,
		);

		
		return $data;
	}

}
?>
