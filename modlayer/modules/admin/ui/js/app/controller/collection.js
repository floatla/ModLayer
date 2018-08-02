define([
		'jquery'
		, 'tooltipster'
		, 'timeago'
		, 'jForm'
		, 'Util'
		, 'UI'
		, 'Keyboard'
		, 'Language'
		, 'Sidepanel'
	], 
	function (
		$
		, tooltipster
		, timeago
		, jForm
		, Util
		, UI
		, Keyboard
		, Language
		, Sidepanel
	) {
	


	var list = {
		id : 0,
		group : [],
		loader : {},
		target : {
			"publish"     : "BackPublish",
			"unpublish"   : "BackUnPublish",
			"delete"      : "BackDelete",
			"deleteGroup" : "BackDeleteCollection"
		},

		BindActions : function()
		{
			var self = this;
			// var oldSintax = 'ul.list > li, ul.multimedia > li, table.data-list tr, .simple-list > li';
			var compat = 'table.data-list tr, .simple-list > li';

			$("*[data-role='list-rows'] li, " + compat).each(function(i,v){
				//console.log($(this).attr('id'));
				self.initRow($(this));
			});

			self.SetActions();

			// Filtros
			$('.sub-filter span').click(function(e){
				e.preventDefault();
				$(this).toggleClass('expanded');
				var parent = $(this).parent();
				$('.float-menu', parent).slideToggle('fast');
			});
			
			
			var self = this;
			Keyboard.keys.push(
				{
					"name"     : 'Esc', 
					"code"     : 27,  
					"callback" : function(){ self.clear() },
					"ctrl"     : 0, 
					"shift"    : 0
				},
				{
					"name"     : 'a',
					"code"     : 65,
					"callback" : function(){ self.selectAll() },
					"ctrl"     : 1,
					"shift"    : 0
				},
				{
					"name"     : 'f',
					"code"     : 70,
					"callback" : function(){ self.filters() },
					"ctrl"     : 0,
					"shift"    : 0
				}
			);

			self.loader = Util.Create('img', {"src" : adminmod + "/ui/imgs/backgrounds/loader.gif", "class" : "loader"});
		},

		initRow : function(row)
		{
			var self = this;
			var id = row.attr('item_id');
			$('.delete', row)
					.click(
						function(e){
							e.preventDefault(); 
							self.delete(id); 
						}
					);

			$('.publish, .republish', row)
					.click(
						function(e){
							e.preventDefault();
							self.publish(id, $(this));
						}
					);

			$('.unpublish', row)
					.click(
						function(e){
							e.preventDefault();
							self.unpublish(id, $(this));
						}
					);

			$('*[data-role="category-delete"]', row)
					.click(
						function(e){
							e.preventDefault();
							self.CategoryDelete($(this).data('category_id'), $(this).data('item_id'));
						}
					);

			$('.check', row)
					.change(function(){
						if($(this).is(':checked')){

							// self.ActionsShow();
							self.GroupItemAdd(row);
						}else{
							// self.ActionsHide();
							self.GroupItemRemove(row);
						}
					});

			if($('ul.multimedia').length > 0){
				$('.longbox', row).hover(
					function(){
						$('.data', $(this)).show();
					},
					function(){
						
						$('.data', $(this)).hide();
					}
				);
				$('.more-data', row).click(function(){
					self.ToggleExtradata(row);
				});
			}
		},

		ToggleExtradata : function(row){
			if($('.extra-data', row).is(':visible'))
			{
				$('.extra-data', row).hide();
				$('.more-data', row)
					.removeClass('icon-minus-sign')
					.addClass('icon-plus-sign');
			}
			else
			{
				//$('.data', row).hide();
				$('.extra-data', row).show();
				$('.more-data', row)
					.removeClass('icon-plus-sign')
					.addClass('icon-minus-sign');
			}
			
		},

		filters : function()
		{
			$('section.filter').toggleClass('open');
		},

		SetActions : function()
		{
			// Acciones en grupo
			var actions = $('.list-actions');
			$('.checkAll', actions)
					.change(function(){
						if($(this).is(':checked')){
							$('.check').each(function(){
								$(this).prop('checked', true);
								list.GroupItemAdd($(this).parents('li[item_id]'));
							});
						}else{
							$('.check').each(function(){
								$(this).prop('checked', false);
								list.GroupItemRemove($(this).parents('li[item_id]'));
							});
						}
					});

			$('.delete', actions)
					.click(function(e){
						e.preventDefault();
						if(list.group.length > 0)
						{
							list.GroupDelete();
						}else
						{
							alert(Language.translate('language/collection/messages/empty_selection'));
						}
						
					});

			$('.categories', actions)
					.click(function(e){
						e.preventDefault();
						if(list.group.length > 0)
						{
							list.SetCategories();
						}else
						{
							alert(Language.translate('language/collection/messages/empty_selection'));
						}
					});

			
		},


		SetCategories : function()
		{
			var url = adminpath+'?m=category&action=RenderModalCollection&module='+module+'&list='+this.group+'&height=window';
			Sidepanel.load(url);
		},

		GroupItemAdd : function(elem)
		{
			var id = elem.attr('item_id');
			var index = $.inArray(id, this.group);
			if(index == -1){
				this.group.push(elem.attr('item_id'));
			}
			// console.log(this.group);
		},

		GroupItemRemove : function(elem)
		{
			var id = elem.attr('item_id');
			var index = $.inArray(id, this.group);
			this.group.splice(index,1);
			//console.log(this.group);
		},

		/*
		GroupChangeState : function(state)
		{
			$.each(this.group, function(i, v){list.changeState(v, state);});
		},
		*/

		GroupDelete : function()
		{
			//console.log(this.group);
			if(confirm(Language.translate('language/collection/messages/delete_group')))
			{
				Util.ajaxCall(
				{
					m: module,
					action:this.target.deleteGroup,
					list: this.group
				},
				{
					callback: this.GroupDelete_callback,
					context: list
				});
			}
		},

		GroupDelete_callback : function(data, textStatus, jqXHR)
		{
			if(data.code == 200)
			{
				$.each(data.elements, function(i, element){
					var item_id = element;
					$("*[item_id='"+item_id+"']").slideUp('fast', function(){ $(this).remove() });
				});
				this.group = [];
			}
			else
			{
				UI.RenderMessage(data.message);
			}
			//console.log(data);
		},

		delete : function(object_id)
		{
			//alert('Borro: '+ object_id)
			
			if(confirm(Language.translate('language/collection/messages/delete_selected_element'))){
				
				this.id = object_id;
				Util.ajaxCall(
				{
					m: module,
					action: this.target.delete,
					item_id: object_id
				},
				{
					callback: this.delete_callback,
					context: list
				});
			}
		},

		delete_callback : function(json, textStatus, jqXHR)
		{
			//console.log(this.id);
			if(json.code == 200)
			{
				$("*[item_id="+this.id+"]").fadeOut('fast');	
			}
			else
			{
				UI.RenderMessage(json.message);
				//alert('Se ha producido un error');
			}
			
		},

		publish : function(item_id, jElement)
		{
			if(confirm(Language.translate('language/collection/messages/publish')))
			{
				var 
					self    = this,
					status  = $("li[item_id="+item_id+"] .publish");

				status.prepend(self.loader).find('.status').hide();
				self.id   = item_id;
				var token = $('input[name=modToken]').val();

				

				Util.ajaxCall(
				{
					m: module,
					action: self.target.publish,
					item_id: item_id,
					modToken: token
				},
				{
					callback: self.publish_callback,
					context: self
				});
			}

		},

		publish_callback : function(data, textStatus, jqXHR)
		{
			var row = $("li[item_id="+data.id+"]");	
			$('.loader', row).hide().remove();
			
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					row.attr('class', 'state-1');
					$('.unpublish', row).show();
					$('.popup', row).show();
					$('.publish', row).hide();
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

		unpublish : function(object_id, jElement)
		{
			if(confirm(Language.translate('language/collection/messages/unpublish')))
			{
				var self = this;
				jElement.prepend(self.loader).find('.status').hide();

				self.id = object_id;
				var token = $('input[name=modToken]').val();

				Util.ajaxCall(
				{
					m: module,
					action: self.target.unpublish,
					item_id: object_id,
					modToken: token
				},
				{
					callback: self.unpublish_callback,
					context: self
				});
			}

		},

		unpublish_callback : function(data, textStatus, jqXHR)
		{
			var row = $("li[item_id="+data.id+"]");	
			$('.loader', row).hide().remove();

			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					row.attr('class', 'state-0');
					$('.unpublish', row).hide();
					$('.popup', row).hide();
					$('.publish', row).show();
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

		updateView : function()
		{
			window.location.reload();
		},

		selectAll : function()
		{

			// Acciones en grupo
			var actions = $('.list-actions');
			$('li[item_id] .check').each(function(){
				$(this).prop('checked', true);
				list.GroupItemAdd($(this).parents('li[item_id]'));
			});
			$('.checkAll', actions).prop('checked', true);
			
		},

		clear : function()
		{
			// Acciones en grupo
			var actions = $('.list-actions');
			// if($('.checkAll', actions).is(':visible'))
			// {
				
				$('.checkAll', actions).attr('checked', false);
				$('.check').each(function(){
					$(this).attr('checked', false);
					list.GroupItemRemove($(this).parent().parent().parent());
				});
				// list.ActionsHide();
			// }
			
		},

		CategoryDelete : function(category_id, object_id)
		{
			var self = this;
			self.id = category_id;
			Util.ajaxCall(
			{
				m: module,
				action:'BackUnlinkCategory',
				item_id: object_id,
				category_id: category_id
			},
			{
				callback: self.CategoryDeleteCallback,
				context: self
			});
		},

		CategoryDeleteCallback : function(json, textStatus, jqXHR)
		{
			if(json.code == 200)
			{
				$("*[item_id="+json.id+"] span[category_id="+json.category_id+"]").slideUp('fast', function(){$(this).remove()});
			}
			else
			{
				modlayer.displayError(json.message);
			}
		},

		ClosePanel : function()
		{
			Sidepanel.close();
		},

		OpenPanel : function(url)
		{
			Sidepanel.load(url);
		}
	}


	return list;
});
