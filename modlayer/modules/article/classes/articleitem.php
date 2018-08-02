<?php
Class ArticleItem extends ElementItem {

	/*
		Sobre escribimos el método Get para poder insertar 
		los assets externos de la nota.
	*/
	public function Get()
	{
		$tempData = parent::Get();

		$assets   = new Asset();
		$assets->SetArticle($this->id);

		$data = $assets->Get();

		if($data){
			foreach ($data as $i => $asset) {
				$data[$i]['external-xml'] = $asset['asset'];
				unset($data[$i]['asset']);
			}
			$data['tag'] = 'asset';
			$tempData['assets']	= $data;		
		}
		
		return $tempData;
	}



}

?>