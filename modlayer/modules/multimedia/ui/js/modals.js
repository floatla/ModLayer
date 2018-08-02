define([
		  'jquery'
		, 'Modal'
		, 'Sidepanel'
		, 'tooltipster'
		, 'Util'
		, 'Keyboard'
	], function (
		$
		, Modal
		, Sidepanel
		, tooltipster
		, Util
		, Keyboard
	) {

	var panel = {

		BindActions : function()
		{
			var actions = this;
			$(document).ready(function(){
				$('.upload').click(function(){
					actions.showUpload();
				});
				$('.back').click(function(){
					actions.showlist();
				});
			});

			Keyboard.keys.push(
				{
					"name"     : 'Esc', 
					"code"     : 27,  
					"callback" : function(){ parent.appUI.ClosePanel() },
					"ctrl"     : 0, 
					"shift"    : 0
				}
			);
		},

		showUpload : function()
		{
			$('.list-tools, #grid').fadeOut('fast',function(){
				$('.upload-tools, .upload-container').fadeIn('fast');
				//setSlider($('.upload-container'));
			});
		},
		showlist : function()
		{
			$('.upload-tools, .upload-container').fadeOut('fast',function(){
				$('.list-tools, #grid').fadeIn('fast');
			});
		}

	}

	return panel;
});