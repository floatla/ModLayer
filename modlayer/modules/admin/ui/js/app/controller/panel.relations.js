define([
		'jquery'
		, 'Util'
		, 'UI'
		, 'Language'
		, 'jForm'
		, 'Keyboard'
	], 
	function (
		$
		, Util
		, UI
		, Language
		, jForm
		, Keyboard
	) {


	var panel = {

		_item_id : 0,
		_active_module : '',

		BindActions : function()
		{
			var self = this;
			// self._item_id = item_id;
			// self._active_module = active_module;

			// console.log('=> ' + self._item_id);
			// console.log('=> ' + self._active_module);

			$(document).ready(function(){ 
				$('input:checkbox').change(function(){
					self.AddItem($(this));
				});

				var options = { 
					success: self.Close,
					data : {id: self._item_id}
				};
				$("form[name='relacionar']").ajaxForm(options);

				$('[data-role="submit"]').click(function(){
					$("form[name='relacionar']").submit();
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

		AddItem : function(elem)
		{
			if(elem.is(':checked')){
				var label = $('label[for=rel_'+elem.val()+']').html();
				$('#relations-list')
					.append('<li id="item-'+elem.val()+'"><input type="hidden" name="objects[]" value="'+elem.val()+'"/>'+label+'</li>');
			}else{
				$('#relations-list #item-'+elem.val()).remove();
			}
		},

		Close : function(json, statusText, xhr, $form)
		{
			var self = this;
			var form = $form[0];
			// console.log($form);
			// console.log('=> ' + form.item_id.value);
			// console.log('=> ' + form.active_module.value);
			if(Util.isObject(json))
			{
				if(json.code == 200)
				{
					parent.RelationService.updateView(form.item_id.value, form.active_module.value);
					parent.appUI.ClosePanel();
				}else{
					parent.appUI.RenderMessage(json.message);
				}
			}
			else{
				parent.appUI.RenderMessage(json);
			}
		}
	}

	return panel;

})