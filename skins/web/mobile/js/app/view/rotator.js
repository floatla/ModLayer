define(['jquery', 'swiper'], function($, Swiper) {

	localSwiper = {
		Init : function(tagName, options) 
		{
			// $(document).ready(function(){
			return new Swiper(tagName, options);
			// });
		}
	}

	return localSwiper;

});