<?php 
class ImageResize {

	public $ratio = 1; 
	public $max_width; 
	public $max_height;


	// Resize the image 
	public function process($gd_img)
	{
		// Set initial dimensions 
		$old_width  = imagesx($gd_img); 
		$old_height = imagesy($gd_img); 
		$new_width = 0; 
		$new_height = 0;

		// New dimensions to fall within maximums provided 
		if ($this->max_width and $this->max_height)
		{
			if ($this->max_width/$old_width <= $this->max_height/$old_height)
			{
				$new_width = ceil(($this->max_width/$old_width) * $old_width); 
				$new_height = ceil(($this->max_width/$old_width) * $old_height);
			}else{
				$new_width = ceil(($this->max_height/$old_height) * $old_width); 
				$new_height = ceil(($this->max_height/$old_height) * $old_height);
			}
		}
		// New dimensions based on a ratio 
		else if ($this->ratio)
		{
			$new_width = ceil($this->ratio * $old_width); 
			$new_height = ceil($this->ratio * $old_height);
		}

		// Resize only if dimensions changed 
		if ($new_width and $new_height)
		{
			// Create resize target 
			$temp = imagecreatetruecolor($new_width, $new_height);

			$transparent_index = imagecolortransparent($gd_img);
			// If it's a transparent GIF
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
								0, 
								0, 
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