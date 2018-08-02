define([
	'jquery',
	'app/view/rotator'
	], function ($, rotator) {
	
	var GalSwipe;

	$(function () {
		
		GalSwipe = rotator.Init(
			'.swiper-container',
			{
				pagination: '.swiper-pagination',
				nextButton: '.next',
				prevButton: '.prev',
				paginationClickable: true,
				spaceBetween: 10,
				centeredSlides: true,
				// autoplay: 6000,
				// autoplayDisableOnInteraction: true,
				loop: true,
			}
		);

		
	});
});