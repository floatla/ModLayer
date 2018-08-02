define([
		'jquery'
		, 'tooltipster'
		, 'jForm'
		, 'Util'
		, 'UI'
		, 'sortable'
		, 'autocomplete'
		, 'Keyboard'
		, 'Language'
		, 'Sidepanel'
		, 'datetime'
		, 'category/ui/js/service'
		, 'tag/ui/js/service'
	], 
	function (
		$
		, tooltipster
		, jForm
		, Util
		, UI
		, Sortable
		, autocomplete
		, Keyboard
		, Language
		, Sidepanel
		, datetime
		, Categories
		, Tags
	) {


	function Item(id) {

		var self    = this;
		self._id    = id,
		self._back  = false,
		self._state = null;


		self.BindActions = function() {
			// self.cookieOptions = {path : String(adminpath), expires : 7}

			var sortable = $('.with-order');
			sortable.each(function(){
				// console.log($(this)[0]);
				Sortable.create($(this)[0], {
					forceFallback: true,
					ghostClass: 'order-ghost',
					chosenClass: 'order-chosen',
					animation: 150,
					onUpdate: function (evt) {
						UI.SetOrder(evt, self._id);
					}
				});
			});


			formOptions = { 
				beforeSubmit:  self.save,
				success: self.saveCallback,  // post-submit callback 
			};

			Categories.BindActions(self._id, self._module);
			Tags.BindActions(self._id, self._module);
		}

		/*
			Sobreescribir esta función para módulos 
			que no extiendan de Element y manejar el cambio de 
			estados aparte
		*/
		self.changeState = function(id, state)
		{
			self._state = state;
			if(state == 1){
				self.publish(id);
				return;
			}
			if(state == 0){
				self.unpublish(id);
				return;
			}

			if(confirm(Language.translate('language/backend_messages/change_state')))
			{	
				$('.currentState').addClass('loading');
				var token = $('input[name=modToken]').val();


				self._id    = id;
				// self._state = state;

				Util.ajaxCall(
				{
					m: module,
					action: 'UpdateState',
					item_id: id,
					newState: state,
					currentState : self._state,
					modToken: token
				},
				{
					callback: self.changeState_callback,
					context: self
				});
			}
		}

		self.changeState_callback = function(data, textStatus, jqXHR)
		{
			$('.currentState').removeClass('loading');
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					$('.item-edit').removeClass('state-0 state-1 state-2 state-3 state-4');
					$('.item-edit').addClass('state-' + data.currentState);
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

		self.publish = function(item_id)
		{
			if(confirm(Language.translate('mod_language/backend_messages/publish')))
			{	
				$('.currentState').addClass('loading');
				var token = $('input[name=modToken]').val();

				Util.ajaxCall(
				{
					m: module,
					action: 'BackPublish',
					item_id: item_id,
					modToken: token
				},
				{
					callback: this.publish_callback,
					context: self
				});
			}

		},

		self.publish_callback = function(data, textStatus, jqXHR)
		{
			$('.currentState').removeClass('loading');
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					$('.item-edit').removeClass('state-0 state-3 state-4');
					$('.item-edit').addClass('state-1');
					$('[data-role="item-popup"]').show();
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

		self.unpublish = function(item_id)
		{
			if(confirm(Language.translate('mod_language/backend_messages/unpublish')))
			{
				$('.currentState').addClass('loading');

				var token = $('input[name=modToken]').val();

				Util.ajaxCall(
				{
					m: module,
					action: 'BackUnPublish',
					item_id: item_id,
					modToken: token
				},
				{
					callback: this.unpublish_callback,
					context: self
				});
			}
		}

		self.unpublish_callback = function(data, textStatus, jqXHR)
		{
			$('.currentState').removeClass('loading');
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					$('.item-edit').removeClass('state-1 state-3');
					$('.item-edit').addClass('state-0');
					$('[data-role="item-popup"]').hide();

				}else
				{
					UI.RenderMessage(data.message);
				}
			}
			else
			{
				UI.RenderMessage(data);
			}
		}

		self.delete = function()
		{
			if(confirm(Language.translate('mod_language/backend_messages/delete_element')))
			{
				Util.ajaxCall(
				{
					m: module,
					action: 'BackDelete',
					item_id: self._id
				},
				{
					callback: this.delete_callback,
					context: self
				});
			}
		}

		self.delete_callback = function(json, textStatus, jqXHR)
		{
			if(typeof json == 'object')
			{
				if(json.code == 200) {
					window.location.href = adminpath + module;
				}
				else {
					UI.RenderMessage(json.message);
				}
			}
			else {
				UI.RenderMessage(json);
			}


		}

		self.save = function(formData, jqForm, options)
		{

			$('.edit-header .alert').html('Guardando').addClass('onScreen');
			tinyMCE.activeEditor.save();

			if($('#article_content').length > 0){
				$('#article_content').html(tinymce.get('article_content').getContent());
				console.log(tinymce.get('article_content').getContent());
			}
			// console.log();

			// return false;
			var xd = {'name' : 'ajaxEnabled', 'value' : '1'};
			formData.push(xd);

			if(item.back == 1){
				var xdb = {'name' : 'back', 'value' : '1'};
				formData.push(xdb);			
			}
		}

		self.saveCallback = function(json, textStatus, jqXHR)
		{
			if(json.code == 200)
			{
				if(item.back == 1) {
					window.location.href = json.url;
					return false;
				}
				$('.edit-header .alert').html(Language.translate('mod_language/modules/backend_messages/changes_saved'));
				$('div.alert').animate({'top': 0}, 2000, function(){ $(this).removeClass('onScreen');});

				if(item.state == 1){
					$('.item-edit').removeClass('state-1');
					$('.item-edit').addClass('state-3');	
				}
			}
			else
			{
				UI.RenderMessage(json.message);
			}
		}

		self.deferred_on = function() {
			$('.deferredDate').css({'height':'auto', 'overflow':'visible'});
		}

		self.deferred_off = function() {
			$('.deferredDate').css({'height':0, 'overflow':'hidden'});
		}

		// self.ClosePanel = function() {
		// 	Sidepanel.close();
		// }

		// self.OpenPanel = function(url) {
		// 	Sidepanel.load(url);
		// }



		// self.BindActions();
	}


	

	return Item;

});