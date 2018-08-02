<?php
class ImageRotate {
	
	public $rotation = 0;
	
	// Rotate the image 
	public function process($gd_img)
	{
		if ($this->rotation)
		{
			// Get “filler” background color 
			$color  = imagecolorallocate($gd_img, 255, 255, 255);
			// Rotate the image 
			$gd_img = imagerotate($gd_img, $this->rotation, $color);
		} 
		return $gd_img;
	}
	
}
?>