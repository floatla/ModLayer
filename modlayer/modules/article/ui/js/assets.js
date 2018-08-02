define([
	'jquery'
	, 'Util'
	, 'jForm'
], function(
	$
	, Util
	, jForm
){

	var Assets = {

		list : [],
		editorInstance : null,

		BindActions : function()
		{
			var self = this;
			$(document).ready(function() {
				var options = {
					success: self.Close
				};
				$("form[name='assets']").ajaxForm(options);
			});
		},

		put : function(id, asset)
		{
			// var t = {"id": id, "html" : };
			this.list.push(id);
		},

		place : function(editor)
		{
			var self = this;
			self.editorInstance = editor;

			Util.ajaxCall(
			{
				m: 'article',
				action: 'AssetsByArticle',
				id : item.id,
				list : JSON.stringify(self.list)
			},
			{
				callback: self.placeCallback,
				context: self
			});
		},

		placeCallback : function(json)
		{
			var self = this;
			if(json.assets.length > 0){
				console.log(json);

				for(i in json.assets)
				{
					var ins  = json.assets[i];
					var uid  = 'a-'+ins.uid;
					// console.log(assets.editorInstance.dom.select('external#'+uid));
					
					self.editorInstance.dom.setHTML(
						self.editorInstance.dom.select('#'+uid), 
						ins.asset
					);
				}
				
			}
		},

		Close : function(json, statusText, xhr, $form) {
			if(json.code == 200)
			{
				// console.log(json);	
				html = '<external uid="'+json.uid+'">'+json.asset+'</external>';
				parent.tinyMCE.activeEditor.selection.setContent(html, {format : 'raw'});
				// parent.tinyMCE.activeEditor.dom.insertAfter(html, parent.tinyMCE.activeEditor.selection);
				parent.appUI.ClosePanel();		
			}
			else
			{
				parent.appUI.RenderMessage(json.message);
			}
		}
	}

	return Assets;
});
