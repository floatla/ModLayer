define([
		  'jquery'
		, 'Modal'
		, 'Sidepanel'
		, 'tooltipster'
		, 'Util'
		, 'Keyboard'
		, 'jForm'
	], function (
		$
		, Modal
		, Sidepanel
		, tooltipster
		, Util
		, Keyboard
		, jForm
	) {

	var panel = {

		BindActions : function()
		{
			var self = this;
			var options = { 
				success: self.ClosePanel 
			};
			$("form[name='categorizar']").ajaxForm(options);

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

		ClosePanel : function(json, statusText, xhr, $form) {
			if(json.code == 200) {
				parent.jsCollection.updateView();
				parent.appUI.ClosePanel();
			} else {
				parent.appUI.RenderMessage(json.message);

			}
		}

	}

	return panel;
});
	
