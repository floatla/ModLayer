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

	var menuTree = {

		BindActions : function()
		{
			var self = this;
			var ns = $('ol.sortable').nestedSortable({
				forcePlaceholderSize: true,
				handle: 'div',
				helper:	'clone',
				forceHelperSize : true,
				items: 'li',
				opacity: .6,
				placeholder: 'placeholder',
				revert: 250,
				tabSize: 25,
				tolerance: 'pointer',
				toleranceElement: '> div',
				maxLevels: 4,
				isTree: true,
				expandOnHover: 700,
				startCollapsed: false,
				stop: function(event, ui){
					// console.log('Relocated item');
					// console.log(this);
					self.updateOrder(event, ui);
				}
			});

			$('.openclose').on('click', function() {
				$(this).parents('.branch:eq(0)').find('ol.tree').toggleClass('collapsed');
				$(this).toggleClass('closed');
			});

		},

		updateOrder : function(event, ui)
		{
			var self = this;
			var menu_id = ui.item.attr('data-raw');
			// var order = ui.item.index();

			var array = $('ol.sortable').nestedSortable('toArray', {startDepthCount: 0});
			var json  = JSON.stringify(array);

			Util.ajaxCall(
			{
				m: module,
				action:'BackUpdateOrder',
				json: json,
				menu_id: menu_id
			},
			{
				callback: self.updateOrder_callback,
				context: self
			});

		},

		updateOrder_callback: function(data, textStatus, jqXHR)
		{

			if(data.code == 200)
			{
				// Ok
			}
			else
			{
				UI.RenderMessage(data.message);
			}
		},

		edit : function(elem)
		{
			var self = this;
			var id  = $(elem).attr('item_id');
			var url = adminpath + module + '/ajax/?id=' + id;
			var obj = jQuery.getJSON(url, function(data){

				if(data.code == 200)
				{
					self.editModal(data);
				}
				else
				{
					UI.RenderMessage(data.message);
				}
			});
		},

		editModal : function(json)
		{
			var self = this;
			var form = {
				'name' : 'editmenu',
				'method' : 'post',
				'action' : adminpath + 'menu/edit/',
				fields : [
					{
						"label" : Language.translate('mod_language/modal/menu_title'),
						"tag" : "input",
						"type" : "text",
						"name" : "menu_name",
						"placeholder" : Language.translate('mod_language/modal/menu_title_placeholder'),
						"autofocus" : "autofocus",
						"value" : json.menu.name
					},
					{
						"label" : Language.translate('mod_language/modal/menu_url'),
						"tag" : "input",
						"type" : "text",
						"name" : "menu_url",
						"placeholder" : Language.translate('mod_language/modal/menu_url_placeholder'),
						"value" : json.menu.url
					}
				],
				hidden : [
					{
						"name" : "menu_id",
						"value" : json.menu.menu_id
					}
				]
			}

			var form = self.htmlForm(form);

			// Muestro el modal

			Modal.header(Language.translate('mod_language/modal/head_title_edit'));
			Modal.options.height = 230;
			Modal.body(form);
			Modal.controls();
			Modal.load();

			// Opciones para enviar el form por ajax
			var options = { 
		        // beforeSubmit:  showRequest,  
		        success: self.editCallback
		    }; 

		    // Evento de enviar
			form.submit(function(){
				Modal.loading(true);
				$(this).ajaxSubmit(options); 
				return false;
			});

			// Enviar el form 
			$('.modalSave').click(function(){
				form.submit();
			});

		},

		editCallback : function(json, statusText, xhr, $form)
		{
			var self = this;
			if(json.code == 200)
			{
				var menu = $('.category[menu_id='+json.menu.menu_id+']');
				$('*[role=title]', menu).html(json.menu.name);

				if (json.menu.url == '')
					$('*[role=url]', menu).hide();
				else
					$('*[role=url]', menu).html(json.menu.url).show();

				Modal.close();
			}
			else
			{
				Modal.loading(false);
				alert(json.message);
			}
		},

		addChild : function(elem)
		{
			var self = this;
			var parent = $(elem).attr('item_id');
			
			var form = {
				'name' : 'add',
				'method' : 'post',
				'action' : adminpath + 'menu/add/',
				fields : [
					{
						"label" : Language.translate('mod_language/modal/menu_title'),
						"tag" : "input",
						"type" : "text",
						"name" : "menu_name",
						"placeholder" : Language.translate('mod_language/modal/menu_title_placeholder'),
						"autofocus" : "autofocus",
						"value" : ""
					},
					{
						"label" : Language.translate('mod_language/modal/menu_url'),
						"tag" : "input",
						"type" : "text",
						"name" : "menu_url",
						"placeholder" : Language.translate('mod_language/modal/menu_url_placeholder'),
						"value" : ""
					}
				],
				hidden : [
					{
						"name" : "menu_parent",
						"value" : parent
					}
				]
			}

			var form = self.htmlForm(form);

			// Muestro el modal
			Modal.header(Language.translate('mod_language/modal/head_title_add'));
			Modal.options.height = 300;
			Modal.body(form);
			Modal.controls();
			Modal.load();

			

			// Opciones para enviar el form por ajax
			var options = { 
		        // beforeSubmit:  showRequest,  
		        success: self.addChildCallback
		    }; 

		    // Evento de enviar
			form.submit(function(){
				Modal.loading(true);
				$(this).ajaxSubmit(options); 
				return false;
			});

			// Enviar el form 
			$('.modalSave').click(function(){
				form.submit();
			});
		},

		addChildCallback : function(json, statusText, xhr, $form)
		{
			// var modal = new Modal();

			if(json.code == 200)
			{
				Modal.close();
				window.location.reload();
			}
			else
			{
				Modal.loading(false);
				alert(json.message);
			}
		},

		delete : function(elem)
		{
			var id = $(elem).attr('item_id');
			if(confirm(Language.translate('mod_language/backend_message/delete_item')))
			{
				var url = adminpath + module + '/ajax/delete/?id=' + id;
				var obj = jQuery.getJSON(url, function(data){

					if(data.code == 200)
					{
						$('li[data-raw='+id+']').slideUp('fast');
						// tree.editModal(data);
					}
					else
					{
						UI.RenderMessage(data.message);
					}

				});
				
			}
		},

		htmlForm : function(obj)
		{
			var form = $(document.createElement('form'))
							.attr({
								"name" : obj.name,
								"method" : obj.method,
								"action" : obj.action
							});
			var ul = $(document.createElement('ul')).attr('class', 'form');
			var fields = obj.fields;
			var hidden = obj.hidden;

			for(i in hidden)
			{
				var hide = $(document.createElement('input')).attr({"type":"hidden", "name": hidden[i].name, "value":hidden[i].value});
				form.append(hide);
			}

			for(x in fields)
			{
				var row   = $(document.createElement('li'));
				var field = fields[x];

				if(field.label !== undefined){
					var label = $(document.createElement('label')).html(field.label);
					row.append(label);
				}
				if(field.tag !== undefined)
				{
					var html = $(document.createElement(field.tag));
					if(field.tag == 'textarea'){
						html.html(field.value);
						delete(field.value);					
					}
					delete field.tag;
					delete field.label;
					html.attr(field);
					row.append(html);
				}
				ul.append(row);
			}
			form.append(ul);

			var submitbox = Util.Create('div', {"style" : "text-align:center;"});
			var submitbtn = Util.Create('button', {"type":"submit", "class" : "btn lightblue"}).html('Guardar');
			form.append(submitbox.append(submitbtn));
			return form;

		}

	}

	return menuTree;
});





