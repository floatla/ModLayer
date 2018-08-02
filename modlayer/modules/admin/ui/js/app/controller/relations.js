define([
		'jquery'
		, 'Util'
		, 'UI'
		, 'Language'
		, 'Sidepanel'
	], 
	function (
		$
		, Util
		, UI
		, Language
		, Sidepanel
	) {

	var relation = {

		relation_id : 0,
		type_id : 0,

		BindActions : function()
		{
			$('*[data-role="relation-add"]').on('click', function(e){
				e.preventDefault();
				var uri = $(this).attr('href');
				Sidepanel.load(uri);
			});
		},

		// AddItem : function(elem)
		// {
		// 	if(elem.is(':checked')){
		// 		var label = $('label[for=rel_'+elem.val()+']').html();
		// 		$('#relations-list')
		// 			.append('<li id="item-'+elem.val()+'"><input type="hidden" name="objects[]" value="'+elem.val()+'"/>'+label+'</li>');
		// 	}else{
		// 		$('#relations-list #item-'+elem.val()).remove();
		// 	}
		// },

		updateView : function(item_id, relation_module)
		{

			Util.ajaxCall(
			{
				m: relation_module,
				action:'BackRefreshRelations',
				item_id: item_id,
				relation_module: module
			},
			{
				callback: this.updateView_callback,
				context: relation
			});

		},

		updateView_callback : function(json, textStatus, jqXHR)
		{
			if(typeof json == 'object')
			{
				if(json.code == 200)
				{
					var relation = $("ul[data-role='relation'][module='"+json.module+"']");
					relation.html(json.html);

					relation.parent().attr('data-count', json.count);
					$(".tooltip").tooltipster({'delay': 100});
				}
				else
				{
					appUI.RenderMessage(json.message);
				}
			}
			else
			{
				appUI.RenderMessage(json);
			}
		},

		unlink : function(item_id, relation_id, relation_module)
		{
			Util.ajaxCall(
			{
				m: relation_module,
				action: 'BackUnlinkRelation',
				item_id: relation_id,
				relation_id: item_id,
				relation_module: module
			},
			{
				callback: this.unlink_callback,
				context: relation
			});

		},

		unlink_callback : function(data, textStatus, jqXHR)
		{
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					var relations = $("ul[data-role='relation'][module='"+data.relation_module+"']");
					$("li[item_id='"+data.id+"']", relations).fadeOut('fast', function(){

						$(this).remove();
						var count = $("li", relations).length;
						relations.parent().attr('data-count', count);

					});
					
				}
				else
				{
					appUI.RenderMessage(data.message);
				}
			}
			else
			{
				appUI.RenderMessage(data);
			}
		}
	}

	return relation;

});