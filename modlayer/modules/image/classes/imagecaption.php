<?php
class ImageCaption {

	public $caption = ''; 
	public $fontfile = '';
	public $fontsize = 10;
	public $padding = 5;
	public $drawline = true;

	// Caption the image 
	public function process($gd_img)
	{
		if ($this->caption and $this->fontfile)
		{
			// Get text box height 
			$text_box           = imagettfbbox($this->fontsize, 0, $this->fontfile, $this->caption);
			$text_height        = $text_box[3] - $text_box[5]; 
			$text_underbaseline = $text_box[3];
			
			// Get some image dimensions 
			$img_x = imagesx($gd_img); 
			$img_y = imagesy($gd_img);
			
			// Draw background shading
			imagealphablending($gd_img, true);

			$rect_color = imagecolorallocatealpha($gd_img, 0, 0, 0, 75);
			imagefilledrectangle($gd_img,
								0, 
								$img_y - $text_height - ($this->padding * 2), 
								$img_x, 
								$img_y, 
								$rect_color);
								
			// Draw caption text 
			$text_color = imagecolorallocate($gd_img, 255, 255, 255);
			imagettftext($gd_img,
						$this->fontsize, 
						0, 
						$this->padding, 
						$img_y - $text_underbaseline - $this->padding, 
						$text_color,
						$this->fontfile, 
						$this->caption);
			
			// Draw shading border if requested 
			if ($this->drawline)
			{
				$line_color = imagecolorallocatealpha($gd_img, 200, 200, 200, 75);
				imageline($gd_img,
							0,
							$img_y - $text_height - ($this->padding * 2) - 1,
							$img_x, 
							$img_y - $text_height - ($this->padding * 2) - 1,
							$line_color);
			}
		}
		return $gd_img;
	}

}
?>