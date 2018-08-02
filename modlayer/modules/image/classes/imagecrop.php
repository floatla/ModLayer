<?php 
class ImageCrop {

	public $width; 
	public $height;

	// Crop the image 
	public function process($gd_img)
	{
		// Set initial dimensions 
		$old_width  = imagesx($gd_img); 
		$old_height = imagesy($gd_img); 

		// Check aspect radio of source and destination pictures
		$original_aspect = $old_width / $old_height;
		$crop_aspect     = $this->width / $this->height;

		if($original_aspect >= $crop_aspect) {
		   // If image is wider than thumbnail (in aspect ratio sense)
		   $new_height = $this->height;
		   $new_width = $old_width / ($old_height / $this->height);
		} else {
		   // If the thumbnail is wider than the image
		   $new_width = $this->width;
		   $new_height = $old_height / ($old_width / $this->width);
		}

		// Resize only if dimensions changed 
		if ($new_width and $new_height)
		{
			// Create resize target 
			$temp = imagecreatetruecolor($this->width, $this->height);

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
			imagecopyresampled($temp,
								$gd_img,
								0 - ($new_width - $this->width) / 2, // Center the image horizontally
								0 - ($new_height - $this->height) / 2, // Center the image vertically
								0,
								0, 
								$new_width,
								$new_height,
								$old_width,
								$old_height);
			$gd_img = $temp;
		}

		return $gd_img;
	}
}
?>