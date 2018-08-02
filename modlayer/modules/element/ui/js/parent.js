define([
		'jquery'
		, 'Util'
		, 'jForm'
	], 
	function (
		$
		, Util
		, jForm
) {

		var parentHandler = {

			BindItemActions : function()
			{
				var self = this;
				$('[data-role="parent-remove"]').click(function(e){
					e.preventDefault();
					self.unlink( $(this).data('id'), $(this).data('module') );
				});
			},

			BindActions : function()
			{
				var self = this;
				
					var options = { 
						success: self.Close
					};

					$("form[name='parent']").ajaxForm(options);
					$('[data-role="submit"]').click(function(){
						$("form[name='parent']").submit();
					});

					$('.cancel').click(function(){
						parent.appUI.ClosePanel();
					});
				
			},

			updateView : function(item_id, moduleParent)
			{
				// this.module = module;
				var self = this;
				Util.ajaxCall(
				{
					m: module,
					action:'BackRefreshParent',
					item_id: item_id,
					module: moduleParent
				},
				{
					callback: self.updateView_callback,
					context: self
				});

			},

			updateView_callback : function(json, textStatus, jqXHR)
			{
				if(typeof json == 'object')
				{
					if(json.code == 200)
					{
						var divparent = $(".item-parent[data-type='"+json.module+"']");
						$("div.item", divparent).remove();
						divparent.append(json.html);

						var count = $("div.item", divparent).length;

						// Si tiene un parent solo dejamos visible esa caja
						if(count > 0){
							$('.item-parent').addClass('hidden');
							divparent.removeClass('hidden');
						}
						// Si no tiene parent se muesran todas las cajas disponibles
						else{
							$('.item-parent').removeClass('hidden');
						}

						divparent.attr('data-count', count);
					}
					else
					{
						parent.appUI.RenderMessage(json.message);
					}
				}
				else
				{
					parent.appUI.RenderMessage(json);
				}
			},

			unlink : function(item_id, moduleParent)
			{
				var self = this;
				Util.ajaxCall(
				{
					m: module,
					action: 'BackSetParent',
					item_id: item_id,
					moduleParent: moduleParent,
					parent_id: 0
				},
				{
					callback: self.unlink_callback,
					context: self
				});

			},

			unlink_callback : function(json, textStatus, jqXHR)
			{
				var self = this;
				if(typeof json == 'object')
				{
					if(json.code == 200)
					{
						self.updateView(json.item_id, json.parentModule);
					}else{
						parent.appUI.RenderMessage(json.message);
					}
				}else{
					parent.appUI.RenderMessage(json);
				}
			
			},

			Close : function(data, textStatus, jqXHR)
			{

				if(Util.isObject(data))
				{
					if(data.code == 200){
						parent.ParentService.updateView(data.item_id, data.parentModule);
						parent.appUI.ClosePanel();
					}
					else
					{
						parent.appUI.RenderMessage(data.message);
					}
				}
				else
				{
					parent.appUI.RenderMessage(data);
				}
			}

		}
		return parentHandler;
});