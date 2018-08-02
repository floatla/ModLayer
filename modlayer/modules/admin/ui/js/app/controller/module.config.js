define([
		'jquery'
		, 'Util'
		, 'UI'
		, 'Sidepanel'
		, 'nestedSortable'
		, 'Language'
		, 'Modal'
		, 'jForm'
	], 
	function (
		$
		, Util
		, UI
		, Sidepanel
		, nestedSortable
		, Language
		, Modal
		, jForm
	) {

	var xmlConf = {

		moduleName : null,
		types : [],
		multimedia : [],

		BindActions : function()
		{
			var self = this;
			var options = { 
				beforeSubmit: self.standby,
				success: self.updatePreferences,
				data: {'ajaxcall' : 1}
			};

			// $("form[name='preferences']").ajaxForm(options);
			$("form[name='preferences']").submit(function() { 
		        $(this).ajaxSubmit(options); 
		        return false; 
		    }); 
		},

		deleteProperty : function(name, index)
		{
			var self = this;
			var row = $("*[data-ref='"+name+"'][data-position='"+index+"']");
			row.slideUp();
			row.remove();
			// $('.tooltip').remove();
			self.deleteOption(name, index);
		},

		deleteOption : function(name, index)
		{
			var self = this;
			Util.ajaxCall(
			{
				m: 'admin',
				action: 'ModuleGroupPropertyDelete',
				module: self.moduleName,
				group: name,
				index: index
			},
			{
				callback: self.deleteOption_callback,
				context: self
			});
		},

		deleteOption_callback : function(json, textStatus, jqXHR)
		{
			var self = this;
			// console.log(json);
			if(json.code == 200)
			{
				self.updateIndex(json.group);
			}
			else
			{
				UI.RenderMessage(json.message);
			}
		},

		addRow : function(name)
		{
			var row = $("*[data-ref='"+name+"']").last();
			var position = row.attr('data-position');

			var newRow = row.clone();
			$('input, select', newRow).each(function(i,v){
				var name = $(v).attr('name');
				$(v).attr("name", name.replace(position, (position*1)+1));
			});
			newRow.attr('data-position', (position*1)+1);
			$('a.delete', newRow).attr('onclick', '').click(function(e){
				e.preventDefault();
				xmlConf.deleteProperty(name, (position*1)+1);
			});
			newRow.insertAfter(row)

		},

		deleteRule : function(name, index)
		{
			var row = $("*[data-ref='"+name+"'][data-position='"+index+"']");
			row.slideUp();
			row.remove();
			$('.tooltip').remove();
			this.deleteRewrite(name, index);
		},

		deleteRewrite : function(name, index)
		{
			var self = this;
			Util.ajaxCall(
			{
				m: 'admin',
				action: 'ModuleGroupRuleDelete',
				module: self.moduleName,
				group: name,
				index: index
			},
			{
				callback: self.deleteRewrite_callback,
				context: self
			});
		},

		deleteRewrite_callback : function(json, textStatus, jqXHR)
		{
			// console.log(json);
			if(json.code == 200)
			{
				this.updateRulesIndex(json.group);
			}
			else
			{
				UI.RenderMessage(json.message);
			}
		},

		addRule : function(name)
		{
			var row = $("*[data-ref='"+name+"']").last();
			var position = row.attr('data-position');

			var newRow = row.clone();
			$('input, select', newRow).each(function(i,v){
				var name = $(v).attr('name');
				$(v).attr("name", name.replace(position, (position*1)+1));
			});
			newRow.attr('data-position', (position*1)+1);
			$('a.delete', newRow).attr('onclick', '').click(function(e){
				e.preventDefault();
				xmlConf.deleteRule(name, (position*1)+1);
			});
			newRow.insertAfter(row)
		},

		updateIndex : function(group)
		{
			var row = $("*[data-ref='"+group+"']");

			row.each(function(i,v){
				var index    = $(this).attr('data-position');
				var position = i+1;

				$(this).attr('data-position', position);

				$('input, select', $(this)).each(function(i,v){
					var name = $(v).attr('name');
					$(v).attr("name", name.replace(index, position));
				});
				$('a.delete', $(this)).attr('onclick', '').unbind('click').click(function(e){
					e.preventDefault();
					xmlConf.deleteProperty(group, position);
				});
			});
		},

		updateRulesIndex : function(group)
		{
			var row = $("*[data-ref='"+group+"']");

			row.each(function(i,v){
				var index    = $(this).attr('data-position');
				var position = i+1;

				$(this).attr('data-position', position);

				$('input, select', $(this)).each(function(i,v){
					var name = $(v).attr('name');
					$(v).attr("name", name.replace(index, position));
				});
				$('a.delete', $(this)).attr('onclick', '').unbind('click').click(function(e){
					e.preventDefault();
					xmlConf.deleteRule(group, position);
				});
			});
		},

		updateType : function(name, selected)
		{
			var module  = selected.value;
			var type_id; 
			for(i in this.types){
				if(this.types[i].name == module)
				{
					type_id = this.types[i].value;
				}
			}
			var input = $(selected).parents('li').find("input[data-type='type_id']").val(type_id);
		},

		updateMultimedia : function(name, selected)
		{
			var module  = selected.value;
			var type_id; 
			for(i in this.multimedia){
				if(this.multimedia[i].name == module)
				{
					type_id = this.multimedia[i].value;
				}
			}
			var input = $(selected).parents('li').find("input[data-type='type_id']").val(type_id);
		},

		standby : function(formData, jqForm, options)
		{
			$('section.box-overflow').css({'opacity': 0.2});
		},

		updatePreferences: function(json, statusText, xhr, $form)
		{
			if(json.code == 200)
			{
				$('.edit-header .alert').html(Language.translate('mod_language/modules/backend_messages/changes_saved')).addClass('onScreen');
				$('div.alert').animate({'top': 0}, 2000, function(){ $(this).removeClass('onScreen');});
			}
			else
			{
				UI.RenderMessage(json.message);
			}
			
		}
	}

	return xmlConf;	
});


	/* Ejecutar este codigo */	
	// $(function () {

	// 	// $(".tooltip").tooltipster({'delay': 100});
	// 	// jQuery("abbr.timeago").timeago();

	// 	var options = { 
	// 		beforeSubmit: standby,
	// 		success: updatePreferences,
	// 		data: {'ajaxcall' : 1}
	// 	};

	// 	// $("form[name='preferences']").ajaxForm(options);
	// 	$("form[name='preferences']").submit(function() { 
	//         $(this).ajaxSubmit(options); 
	//         return false; 
	//     }); 
		
	// });

	

	
