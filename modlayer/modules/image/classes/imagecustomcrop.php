<?php 
class ImageCustomCrop {

	public $width; 
	public $height;
	public $pos_x;
	public $pos_y;
	public $custom_width;
	public $custom_height;


	// Crop the image 
	public function process($gd_img)
	{
		// Set initial dimensions 
		//$this->width  = imagesx($gd_img); 
		//$this->height = imagesy($gd_img); 

		// Create resize target 
		$temp = imagecreatetruecolor($this->custom_width, $this->custom_height);

		$transparent_index = imagecolortransparent($gd_img);
		// If is transparent GIF
		if ($transparent_index >= 0)
		{
			imagepalettecopy($gd_img, $temp);
			imagefill($temp, 0, 0, $transparent_index);
			imagecolortransparent($temp, $transparent_index);
			imagetruecolortopalette($temp, true, 256);
		}
		else
		{
		    // Turn off transparency blending (temporarily)
			imagealphablending($temp, false);
			// Create a new transparent color for image
			$color = imagecolorallocatealpha($temp, 0, 0, 0, 127);
			// Completely fill the background of the new image with allocated color.
			imagefill($temp, 0, 0, $color);
			// Restore transparency blending
			imagesavealpha($temp, true);
		}

		// Resize the image 
		imagecopyresampled(
			$temp,
			$gd_img,
			0,
			0,
			$this->pos_x,
			$this->pos_y, 
			$this->custom_width,
			$this->custom_height,
			$this->width,
			$this->height
		);
		$gd_img = $temp;

		return $gd_img;
	}
}
?>