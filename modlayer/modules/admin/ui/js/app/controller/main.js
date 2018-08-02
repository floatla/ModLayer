define([
		'jquery'
		, 'UI'
		, 'Keyboard'
		, 'Language'
		, 'timeago'
		, 'admin/ui/fontawesome/js/fontawesome-all'
		, 'jscolor'
		, 'datetime'
	], 
	function ($, UI, Keyboard, Language, timeago, fontaewsome, jscolor, datetime) {
	

	/* Ejecutar este codigo */	
	$(function (){
		
		var adminpath, adminmod, module, cookieOptions = {};

		window.appUI = UI;
		window.appLanguage = Language;
		Language.load();
		$(document).ready(function(){
			cookieOptions = {path : String(adminpath), expires : 7}
			UI.init();
		});

		window.onerror = UI.RenderMessage;
		Keyboard.init();
	
	});
});
