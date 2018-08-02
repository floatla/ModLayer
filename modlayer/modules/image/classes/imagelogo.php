<?php
class ImageLogo {
	
	public $logofile; 
	public $ratio = 1; 
	public $location = array('x' => '', 'y' => ''); 
	public $padding = 0;
	
	
	public function process($gd_img)
	{
		if ($this->logofile)
		{
			// Load the logo 
			$logo = new Image(); 
			$logo->load($this->logofile);
			
			// Resize logo if needed 
			if ($this->ratio and $this->ratio != 1)
			{
				$logo->resize($this->ratio);
			}
			
			// Determine logo placement (x)
			switch ($this->location['x'])
			{
				case 'l': 
					$logo_x = $this->padding;
					break;
				case 'r': 
					$logo_x = imagesx($gd_img) - $this->padding - imagesx($logo->gdresource);
					break; 
				default:
					$logo_x = round((imagesx($gd_img) / 2) - (imagesx($logo->gdresource) / 2));
					
			}
			
			// Determine logo placement (y)
			switch ($this->location['y'])
			{
				case 't': 
					$logo_y = $this->padding;
					break;
				case 'b':
					$logo_y = imagesy($gd_img) - $this->padding - imagesy($logo->gdresource);
					break;
				default:
					$logo_y = round((imagesy($gd_img) / 2) - (imagesy($logo->gdresource) / 2));
			}

			// Copy the logo onto the main image
			imagecopy($gd_img,
						$logo->gdresource, 
						$logo_x, 
						$logo_y, 
						0,
						0, 
						imagesx($logo->gdresource), 
						imagesy($logo->gdresource));
		}
		return $gd_img;
	}
}
?>