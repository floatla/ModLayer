define(function (require) {
	var $  = require('jquery'),
	Blazy  = require('blazy'),
	layout = require('app/view/layout');
	
	/* Ejecutar este codigo */	
	$(function () {
		window.onerror = layout.RenderMessage;

		$('#nav-icon3, #overlay').click(function(e){
			e.preventDefault();
			$('.navpane').toggleClass('open');
			$('#nav-icon3').toggleClass('open');
			$('#overlay').toggleClass('hide');
		});
		
		var bLazy = new Blazy({
			loadInvisible: true,
			offset : 100,
		});

	});
});
