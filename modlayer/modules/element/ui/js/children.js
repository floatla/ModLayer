define([
		'jquery'
		, 'Util'
		, 'UI'
		, 'Sidepanel'
	], 
	function (
		$
		, Util
		, UI
		, Sidepanel
) {

		var children = {

			parent_id : 0,

			pagination : function(parent_id, currentPage, chidldModule)
			{
				var self = this;
				self.parent_id = parent_id;

				Util.ajaxCall(
				{
					m:module,
					action:'BackAjaxList',
					parent_id: parent_id,
					module: chidldModule,
					page: currentPage
				},
				{
					callback: self.pagination_callback,
					context: self
				});
			},

			pagination_callback : function(data, textStatus, jqXHR)
			{
				if(Util.isObject(data))
				{
					if(data.code == 200){
						$("div.item-collection[module='"+data.module+"'] ul").fadeOut('fast', function(){
							$("div.item-collection[module='"+data.module+"']").html(data.html);	
							$(".tooltip").tooltipster();
						});

					}
					else
					{
						window.appUI.RenderMessage(data.message);
					}
				}
				else
				{
					window.appUI.RenderMessage(data);
				}
			},

			unlinkChild : function(id, module)
			{
				var self = this;
				Util.ajaxCall(
				{
					m:module,
					action:'BackUnsetChildren',
					id: id
				},
				{
					callback: self.unlinkChild_callback,
					context: self
				});
			},

			unlinkChild_callback : function(data, textStatus, jqXHR)
			{
				if(Util.isObject(data))
				{
					if(data.code == 200){
						$("div.item-collection[module='"+data.module+"'] li[item_id='"+data.item_id+"']").fadeOut('fast');
					}
					else
					{
						window.appUI.RenderMessage(data.message);
					}
				}
				else
				{
					window.appUI.RenderMessage(data);
				}
			}

		}
		return children;
});