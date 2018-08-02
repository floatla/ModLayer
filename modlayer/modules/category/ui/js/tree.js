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

	var tree = {

		BindActions : function()
		{
			var ns = $('ol.sortable').nestedSortable({
				forcePlaceholderSize: true,
				handle: 'div',
				helper:	'clone',
				forceHelperSize : false,
				items: 'li',
				opacity: .6,
				placeholder: 'placeholder',
				revert: 100,
				tabSize: 10,
				tolerance: 'pointer',
				toleranceElement: '> div',
				maxLevels: 6,
				isTree: true,
				expandOnHover: 700,
				startCollapsed: false,
				stop: function(event, ui){
					// console.log('Relocated item');
					// console.log(this);
					tree.updateOrder(event, ui);
				}
			});

			$('.disclose').on('click', function() {
				$(this).closest('li').toggleClass('mjs-nestedSortable-collapsed').toggleClass('mjs-nestedSortable-expanded');
			})

			$('.openclose').on('click', function() {
				$(this).parents('.branch:eq(0)').find('ol.tree').toggleClass('collapsed');
				$(this).toggleClass('closed');
			});
		},

		updateOrder : function(event, ui)
		{

			var category_id = ui.item.attr('data-raw');
			// var order = ui.item.index();

			var array = $('ol.sortable').nestedSortable('toArray', {startDepthCount: 0});
			var json  = JSON.stringify(array);

			Util.ajaxCall(
			{
				m: module,
				action:'BackUpdateOrder',
				json: json,
				category_id: category_id
			},
			{
				callback: this.updateOrder_callback,
				context: tree
			});

		},

		updateOrder_callback: function(data, textStatus, jqXHR)
		{

			if(data.code == 200) {
				// Ok
			}
			else
			{
				UI.RenderMessage(data.message);
			}
		},

		edit : function(elem)
		{
			var id  = $(elem).attr('item_id');
			var url = adminpath + module + '/ajax/?id=' + id;
			var obj = jQuery.getJSON(url, function(data){

				if(data.code == 200)
				{
					tree.editModal(data);
				}
				else
				{
					UI.RenderMessage(data.message);
				}
			});
		},

		editModal : function(json)
		{
			var form = {
				'name' : 'editcategory',
				'method' : 'post',
				'action' : adminpath + 'category/edit/',
				fields : [
					{
						"label" : Language.translate('mod_language/modal/title'),
						"tag" : "input",
						"type" : "text",
						"name" : "category_name",
						"placeholder" : Language.translate('mod_language/modal/title_placeholder'),
						"autofocus" : "autofocus",
						"value" : json.category.name
					},
					{
						"label" : Language.translate('mod_language/modal/description'),
						"tag" : "textarea",
						"name" : "category_description",
						"placeholder" : Language.translate('mod_language/modal/description_placeholder'),
						"style" : "width:100%;height:100px;",
						"value" : json.category.description
					}
				],
				hidden : [
					{
						"name" : "category_id",
						"value" : json.category.category_id
					}
				]
			}

			var form = tree.htmlForm(form);

			// Muestro el modal
			Modal.header(Language.translate('mod_language/modal/edit_category_header'));
			Modal.options.height = 300;
			Modal.body(form);
			Modal.controls();
			Modal.load();

			// Opciones para enviar el form por ajax
			var options = { 
		        // beforeSubmit:  showRequest,  
		        success: tree.editCallback
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
			if(json.code == 200)
			{
				var category = $('.categoryRow[category_id='+json.category.category_id+']');
				$('*[role=title]', category).html(json.category.name);

				if(json.category.description == '')
					$('*[role=description]', category).hide();
				else
					$('*[role=description]', category).html(json.category.description).show();

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
			var parent = $(elem).attr('item_id');
			
			var form = {
				'name' : 'addcategory',
				'method' : 'post',
				'action' : adminpath + 'category/add/',
				fields : [
					{
						"label" : Language.translate('mod_language/modal/title'),
						"tag" : "input",
						"type" : "text",
						"name" : "category_name",
						"placeholder" : Language.translate('mod_language/modal/title_placeholder'),
						"autofocus" : "autofocus",
						"value" : ""
					},
					{
						"label" : Language.translate('mod_language/modal/description'),
						"tag" : "textarea",
						"name" : "category_description",
						"placeholder" : Language.translate('mod_language/modal/description_placeholder'),
						"style" : "width:100%;height:100px;",
						"value" : ""
					}
				],
				hidden : [
					{
						"name" : "category_parent",
						"value" : parent
					}
				]
			}

			var form = tree.htmlForm(form);

			// Muestro el modal
			Modal.header(Language.translate('mod_language/modal/add_category_header'));
			Modal.controls();
			Modal.body(form);
			Modal.options.height = 300;
			Modal.load();

			// Opciones para enviar el form por ajax
			var options = { 
		        // beforeSubmit:  showRequest,  
		        success: tree.addChildCallback
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
			if(json.code == 200)
			{
				Modal.close();
				location.reload();
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
			if(confirm(Language.translate('mod_language/messages/delete')))
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
		},

		addImage : function(elem)
		{
			var id = $(elem).attr('item_id');
			var url = adminpath + 'image/modal/?item_id='+id+'&callback=BackSetImage&module=category&width=1200&height=window';

			Sidepanel.load(url);
		},

		multimedia_id: 0,
		multimedia_type: 0,

		// Para las imagenes necesitamos crear tamaños
		setRelation : function(item_id, multimedia_id, type_id)
		{
			var self = this;
			self.multimedia_id = multimedia_id;
			self.multimedia_type = type_id;
			// self.object_id = object_id;

			var iframe = $('#mdl_iframe').contents();
			var row = $("*[item_id='"+multimedia_id+"'] div.quick", iframe);
			jQuery("a.btn", row).hide();
			$(row).append('<span class="right"><img src="'+adminmod+'/ui/imgs/backgrounds/loader.gif" class="loader" /></span>');


			Util.ajaxCall(
			{
				m: 'category',
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
			if(data.code == 200)
			{
				var id = data.id;
				var imgId = data.multimedia_id;
				var type  = data.multimedia_type;

				var row = $('.category[category_id='+id+']');
				var imgBox = $('.catImg', row);
				var src = '/content/bucket/' + imgId.substr(-1) + '/' + imgId + 'w80h80c.' +  type;

				if(imgBox.length > 0)
				{
					$('img', imgBox).attr({'src' : src});
				}
				else
				{
					var img = $(document.createElement('img')).attr({'src':src, 'alt':''});
					var box = $(document.createElement('div')).attr({'class':'catImg'});
					var rem = $(document.createElement('a'))
								.attr({'href':'#', 'class':'remove', 'onclick':'return false;'})
								.click(function(e){
									self.unlink(id);
								});

					box.append(rem, img);
					$('h3', row).before(box);
				}
				Sidepanel.close();
			}
			else
			{
				UI.RenderMessage(data.message);
			}
		},

		unlink: function(item_id)
		{
			var self = this;
			Util.ajaxCall(
			{
				m: 'category',
				action: 'BackUnlinkMultimedia',
				item_id: item_id
			},
			{
				callback: self.unlink_callback,
				context: self
			});

		},

		unlink_callback: function(data, textStatus, jqXHR)
		{
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					var id = data.id;
					var row = $('.category[category_id='+id+']');
					var imgBox = $('.catImg', row).remove();
				}
				else
				{
					UI.RenderMessage(data.message);
				}
			}else{
				UI.RenderMessage(data);
			}
		}

	}

	return tree;
});




function dump(arr,level) {
	var dumped_text = "";
	if(!level) level = 0;

	//The padding given at the beginning of the line.
	var level_padding = "";
	for(var j=0;j<level+1;j++) level_padding += "    ";

	if(typeof(arr) == 'object') { //Array/Hashes/Objects
		for(var item in arr) {
			var value = arr[item];

			if(typeof(value) == 'object') { //If it is an array,
				dumped_text += level_padding + "'" + item + "' ...\n";
				dumped_text += dump(value,level+1);
			} else {
				dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
			}
		}
	} else { //Strings/Chars/Numbers etc.
		dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
	}
	return dumped_text;
}



