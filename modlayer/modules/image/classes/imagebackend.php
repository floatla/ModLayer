<?php
class ImageBackend extends MultimediaBackend
{
	
	/*/ UPLOAD /*/

	/**
	*	BackUpload realiza la subida de archivos al sistema
	* @return void.
	**/
	public static function Upload()
	{
		try
		{
			$image  = new Image(
				array(
					'internalCall' => true // Para poder agregar un registro a la base sin validar token
				)
			);
			$upload = $image->upload();

			if(!$upload)
				throw new Exception(Configuration::Translate('messages/empty_upload'), 1);

			/*
				Con el archivo subido, creamos un registro en la base
			*/
			$image->load($upload->target);

			$user = Admin::Logged();
			$size = $image->Size();

			$dto = array(
				'image_title'       => $upload->tempFile['name'],
				'image_type'		=> $image->Extension(),
				'image_width'		=> $size['width'],
				'image_height'		=> $size['height'],
				'image_weight'		=> filesize($upload->target),
				'created_at'     => date('Y-m-d H:i:s'),
				'created_by'   => $user['user_id'],
				'created_type' => 'backend',
			);

			$image_id = $image->Add($dto);

			$options = array(
				'module'       => 'image',
				'folderoption' => 'target',
			);
			$path = PathManager::GetContentTargetPath($options);
			$path = PathManager::GetDirectoryFromId($path, $image_id);
			$file = $path.'/'.$image_id.'.'.$image->Extension();
			
			$upload->Move($file);
		
			/* Fin del upload */

			$category_id = Util::getvalue('category_id');
			$categoriesConfig = Configuration::QueryGroup("categories");
			$categories = array();

			if($categoriesConfig)
			{
				foreach($categoriesConfig as $option)
				{
					/*
						Si tiene configurado asignar una categoría por default
					*/
					if($option->getAttribute('type') == 'default')
					{
						$categories = array($option->getAttribute('value'));
						$item = $image->item($image_id);
						$item->SetCategories($categories);
					}

					// Si configurado un parent para elegir categoría, mandamos el listado en el json 
					
					if($option->getAttribute('type') == 'parent')
					{
						$category = array(
							'category_id'   => $option->getAttribute('value'),
							'title'         => str_replace('{$','', str_replace('}' , '', $option->getAttribute('label'))),
							'subcategories' => array(),
						);

						$cat = new Category();
						$catItem = $cat->item($option->getAttribute('value'));
						$list = $catItem->GetTree();
						$list = Util::arrayNumeric($list['categories']);
						foreach($list as $key=>$cat)
						{
							$subcategory = array(
								'category_id' => $cat['category_id-att'],
								'name'        => $cat['name'],
								'selected'    => ($category_id && $cat['category_id-att']==$category_id) ? 1 : 0,
							);
							array_push($category['subcategories'], $subcategory);
						}
						array_push($categories, $category);
					}
				}
			}

			$response = array(
				'code'		=> 200,
				'message'    => 'ok',
				'type'       => 'image',
				'id'		 => $image_id,
				'extension'	 => $dto['image_type'],
				'name'       => $dto['image_title'],
				'categories' => $categories,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
			$message = $e->getMessage();
		}

		Util::OutputJson($response);
	}

	public static function BulkUpdate()
	{
		$images = $_POST;
		$url = Util::getvalue('url', false);

		if(!empty($_POST['ids']))
		{

			foreach($_POST['ids'] as $key=>$id)
			{
				$image = new Image(array('internalCall' => true));
				$size  = $image->GetSize($id);

				$dto['image_title']   = $images['title_'.$id];
				$dto['image_summary'] = $images['summary_'.$id];
				$dto['image_credit']  = $images['credit_'.$id];
				$dto['image_width']   = $size['width'];
				$dto['image_height']  = $size['height'];
				$dto['image_id']      = $id;

				if(isset($images['categories_'.$id]) && count($images['categories_'.$id]))
				{
					$items = array($id);
					// $items[] = array('multimedia_id' => );
					$categories = array();
					foreach($images['categories_'.$id] as $cat)
					{
						$categories[] = $cat;
					}
					$collection = $image->Collection();
					$collection->SetCategories($items, $categories);
				}

				$image->Edit($dto);
			}

			// Set relation on save
			if(!empty($_POST['add_relation']))
			{
				$module  = Util::getvalue('module');
				$item_id = $_POST['item_id'];
				$multimedia_typeid = $image->GetTypeId();
				$element = new $module();

				foreach($_POST['ids'] as $key=>$id)
				{
					$item    = $element->item($item_id);
					$item->SetMultimedia($id, $module);
				}

				$response = array(
					'code'      => 200,
					'message'   => 'Ok',
					'item_id' 	=> $item_id,
					'typeid'    => $multimedia_typeid,
				);
				Util::OutputJson($response);
				die;
			}
		}
		Application::Route(array('module'=>'image', 'url'=>$url));
	}


	public static function RenderCrop()
	{
		$id      = Util::getvalue('id');
		$image   = new Image();
		$item    = $image->item($id);

		if(!$item->Exists())
		{
			Application::Route(array('module'=>'image'));
		}

		parent::loadAdminInterface();
		self::$template->setcontent(
			$item->Get(), 
			null, 
			'image'
		);

		self::$template->add("modal.crop.xsl");
		self::$template->display();
	}

	public static function Crop()
	{
		try
		{
			$user = Admin::Logged();

			$data = array(
				'image_id'    => Util::getvalue('image_id'),
				'user_id'     => $user['user_id'],
				'user_type'   => 'backend',
				'pos_x'       => Util::getvalue('x'),
				'pos_y'       => Util::getvalue('y'),
				'width'       => Util::getvalue('w'),
				'height'      => Util::getvalue('h'),
				'true_width'  => Util::getvalue('tw'),
				'true_height' => Util::getvalue('th'),
			);

			ini_set("memory_limit","256M");

			$image = new Image();
			$photo = $image->item($data['image_id']);
			$photo = $photo->Get();

			$options = array(
				'module' => 'multimedia',
				'folderoption' => 'target'
			);

			$realPath   = PathManager::GetContentTargetPath($options);

			$sourcePath   = PathManager::GetContentTargetPath(array('module'=>'image', 'folderoption'=>'target'));
			$sourceFolder = PathManager::GetDirectoryFromId($sourcePath, $data['image_id']);
			$sourceFile   = $sourceFolder . '/' . $data['image_id'] . '.' . $photo['type-att'];
			
			$newFile      = $realPath . '/crop-' . $data['image_id'];

			$img = new Image();
			$img->load($sourceFile);

			$img->customcrop(
				$data['pos_x'],
				$data['pos_y'],
				$data['width'],
				$data['height'],
				$data['width'],
				$data['height']
			);

			/*
				If cropped image is too large, 
				it makes it smaller than 1920 px
				keeping its proportions
			*/
			if($data['width'] >= 1920 || $data['height'] >= 1920)
			{
				$img->resize(1920, 1920);
			}

			$img->save($newFile, 75);
			$tempFile   = $newFile . '.' . $photo['type-att'];

			list($width, $height) = getimagesize($tempFile);

			$dto = array(
				'image_title'   => $photo['title'] . ' copy', 
				'image_summary' => $photo['summary'], 
				'image_type'  => $photo['type-att'],
				'image_width'		=> $width,
				'image_height'		=> $height,
				'image_weight'  => filesize($tempFile),
				'created_at'      => date('Y-m-d H:i:s'),
				'created_by'    => $data['user_id'],
				'created_type'  => $data['user_type'],
			);

			$image_id = new Image(
							array(
								'internalCall' => true // Para poder agregar un registro a la base sin validar token
							)
			);
			$image_id = $image_id->Add($dto);

			$targetFolder = PathManager::GetDirectoryFromId($sourcePath, $image_id);
			$targetFile   = $targetFolder. '/' . $image_id . '.' . $photo['type-att'];

			rename($tempFile, $targetFile);
			chmod($targetFile, 0775);

			if(!empty($photo['categories'][0]))
			{
				$categories = array();
				foreach($photo['categories'] as $category)
				{
					if (is_array($category))
					{
						foreach ($category as $key => $cat)
						{
							if(is_numeric($key))
							{
								array_push($categories, $cat['category_id-att']);
							}	
						}
					}
				}

				$items = array($image_id);
				
				$collection = $image->Collection();					
				
				$collection->SetCategories($items, $categories);
			}
			
			$response = array(
				'code' => 200,
				'message' => 'Ok',
				'new_id' => $image_id,
			);
		}
		catch(Exception $e)
		{
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);	
		}

		Util::OutputJson($response);
	}

	public static function RenderEmbedModal()
	{
		$item_id    = Util::getvalue('item_id');
		$module     = Util::getvalue('module');
		$categories = Util::getvalue('categories');

		if($item_id)
		{
			$image = new Image();
			/*
				Pedimos al módulo las imágenes ya relacionadas
				El módulo pidiendo imágenes debe contener un método GetItemMultimedias($item_id, $multimedia_typeid) 
				donde $type_id es el tipo id del multimedia (1 para imágenes)
			*/
			$multimedias = $image->GetModuleMultimedias($module, $item_id);

			
			parent::loadAdminInterface($base='modal.embed.xsl');
			parent::$template->setcontent($multimedias, null, 'item');
			parent::$template->setparam('item_id', $item_id);
			parent::$template->setparam('type_id', $image->GetTypeId());
			parent::$template->setparam('module', $module);
			parent::$template->setparam('categories', $categories);
			parent::$template->display();
		}
	}

	public static function RenderRotate()
	{
		$id      = Util::getvalue('id');
		$image   = new Image();
		$item    = $image->item($id);

		if(!$item->Exists())
		{
			Application::Route(array('module'=>'image'));
		}

		parent::loadAdminInterface();
		self::$template->setcontent(
			$item->Get(), 
			null, 
			'image'
		);

		self::$template->add("modal.Rotate.xsl");
		self::$template->display();
	}

	public static function Rotate()
	{
		$id = Util::getvalue('image_id');

		try{
			$image = new Image(['internalCall' => true]);
			$image->LoadFromRepository($id);

			$image->Rotate(-90);
			$image->SaveToRepository();

			$size = $image->Size();
			$imgSize = [
				'image_id'     => $id,
				'image_width'  => $size['width'],
				'image_height' => $size['height']
			];
			
			$image->Edit($imgSize);
			$image->PurgeBucket();

			$response = array(
				'code' => 200,
				'message' => 'Ok',
			);
		}
		catch(Exception $e){
			$response = array(
				'code' => 500,
				'message' => $e->getMessage(),
			);
		}

		Util::OutputJson($response);
	}
}
?>