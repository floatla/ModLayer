define([
	'jquery', 
	'app/view/layout', 
	'app/view/rotator',
	'blazy'
	], function ($, layout, rotator, Blazy) {
	
	
	/* Ejecutar este codigo */	
	$(function () {
		window.onerror = layout.RenderMessage;

		// if($('.gsearch').length > 0){
		// 	autocomplete.Init();
		// }
		
		// Inicializar Slide home
		rotator.Init(
			'.rotator',
			{
				pagination: '.swiper-pagination',
				nextButton: '.swiper-button-next',
				prevButton: '.swiper-button-prev',
				paginationClickable: true,
				spaceBetween: 10,
				centeredSlides: true,
				autoplay: 6000,
				autoplayDisableOnInteraction: false,
				loop: true,
			}
		);
		
		// Inicializar Mapa
		// GMap.FetchLocations();

		var bLazy = new Blazy({
			// breakpoints: [{
			// 	width: 420 // Max-width
			//   , src: 'data-src-small'
			// }], 
			loadInvisible: true,
			offset : 100,
			success: function(element){
				setTimeout(function(){
					// We want to remove the loader gif now.
					// First we find the parent container
					// then we remove the "loading" class which holds the loader image
					var parent = element.parentNode;
					parent.className = parent.className.replace(/\bloading\b/,'');
					element.removeAttribute('width');
					element.removeAttribute('height');
					}, 
					200
				);
			}
		});
	});
});
