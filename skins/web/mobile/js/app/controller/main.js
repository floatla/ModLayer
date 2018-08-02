define(function (require) {
	var $  = require('jquery'),
	Blazy  = require('blazy'),
	layout = require('app/view/layout');
	jmmenu = require('jmmenu')

	/* Ejecutar este codigo */	
	$(function () {
		window.onerror = layout.RenderMessage;
	});

	$(window).scroll(
		function(){
			setScroll();
	});

	$("nav#menu").mmenu(
		{
			// configuration
			classNames: {
			selected: "active"
		}
	});

	var bLazy = new Blazy({
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

	function setScroll()
	{
		var top  = $(window).scrollTop();
		if(top >= 190){
			$('#black').addClass('showing');
		}else{
			$('#black').removeClass('showing');
		}
	}
	
});
