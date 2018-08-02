define([
		'jquery'
		, 'Util'
		, 'UI'
	], 
	function (
		$
		, Util
		, UI
	) {

	var multimedia = {
		id: 0,
		typeid: 0,

		BindActions : function()
		{
			var self = this;

			$('[data-role="multimedia-add"]').on('click', function(e){
				e.preventDefault();
				var uri = $(this).attr('href');
				window.appUI.OpenPanel(uri);
			});

			$('*[data-role="image-crop"]').on('click', function(e){
				e.preventDefault();
				var uri = $(this).attr('href');
				window.appUI.OpenPanel(uri);
			});

			$('*[data-role="multimedia-remove"]').on('click', function(e){
				e.preventDefault();
				var btn = $(this);
				self.unlink(btn.data('item_id'), btn.data('image_id'), btn.data('type_id'));
			});
		},

		setRelation : function(item_id, multimedia_id, type_id)
		{
			var self = this;
			self.id = multimedia_id;
			self.typeid = type_id;
			// self.object_id = object_id;

			var iframe = $('#sidepanel-window').contents();
			var row = $("*[item_id='"+self.id+"'] div.quick", iframe);
			$("a.btn", row).hide();
			$(row).append('<span class="right"><img src="'+adminmod+'/ui/imgs/backgrounds/loader.gif" class="loader" /></span>');


			Util.ajaxCall(
			{
				m: module,
				action: 'BackSetMultimedia',
				item_id: item_id,
				multimedia_id: multimedia_id,
				multimedia_typeid: type_id
			},
			{
				callback: self.setRelation_callback,
				context: self
			});
		},

		setRelation_callback: function(data, textStatus, jqXHR)
		{
			var self = this;
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					var iframe = $('#sidepanel-window').contents();
					var row    = $("*[item_id='"+data.multimedia_id+"'] div.quick", iframe);
					$('.loader', row).hide();
					$(row).append('<span class="icon ok"> </span>');
					$("*[item_id='"+data.multimedia_id+"']", iframe).addClass('related');
					self.updateView(data.id, self.typeid);
				}
				else
				{
					UI.RenderMessage(data.message);
				}
			}
			else
			{
				UI.RenderMessage(data);
			}
		},

		updateView: function(item_id, type_id)
		{
			var self = this;
			self.typeid = type_id;

			Util.ajaxCall(
			{
				m: module,
				action: 'BackUpdateMultimedia',
				item_id: item_id,
				multimedia_typeid: type_id,
				module: module
			},
			{
				callback: self.updateView_callback,
				context: self
			});
		},

		updateView_callback: function(data)
		{
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					var relation = $("ul[data-role='multimedia'][data-type='"+this.typeid+"']");
					relation.html(data.html);
					var count = $("li", relation).length;
					relation.parent().attr('data-count', count);
					$(".tooltip").tooltipster({'delay': 100});

				}
				else
				{
					UI.RenderMessage(data.message);
				}
			}
			else
			{
				UI.RenderMessage(data);
			}
		},


		unlink: function(item_id, multimedia_id, type_id)
		{
			var self = this;
			self.id     = multimedia_id;
			self.typeid = type_id;
			Util.ajaxCall(
			{
				m: module,
				action: 'BackUnlinkMultimedia',
				item_id: item_id,
				multimedia_id: multimedia_id
			},
			{
				callback: self.unlink_callback,
				context: self
			});

		},

		unlink_callback: function(data, textStatus, jqXHR)
		{
			var self = this;
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					var relation = $("ul[data-role='multimedia'][data-type='"+self.typeid+"']");
					$("li[item_id='"+data.multimedia_id+"']", relation).fadeOut('fast', function(){
						$(this).remove();

						var count = $('li', relation).length;
						relation.parent().attr('data-count', count);
					});
				}
				else
				{
					UI.RenderMessage(data.message);
				}
			}
			else
			{
				UI.RenderMessage(data);
			}
		}
	}

	return multimedia;
});