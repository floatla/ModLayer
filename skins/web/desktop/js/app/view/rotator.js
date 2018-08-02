define(['jquery', 'swiper'], function($, Swiper) {

	localSwiper = {
		Init : function(tagName, options) 
		{
		
			new Swiper(tagName, options);
		
		}
	}

	return localSwiper;

});