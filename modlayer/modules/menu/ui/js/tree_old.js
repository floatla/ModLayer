$(document).ready(function(){

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
			tree.updateOrder(event, ui);
		}
	});

	$('.openclose').on('click', function() {
		$(this).parents('.branch:eq(0)').find('ol.tree').toggleClass('collapsed');
		$(this).toggleClass('closed');
	});
	
	
});

var tree = {

	updateOrder : function(event, ui)
	{

		var menu_id = ui.item.attr('data-raw');
		// var order = ui.item.index();

		var array = $('ol.sortable').nestedSortable('toArray', {startDepthCount: 0});
		var json  = JSON.stringify(array);

		modlayer.ajaxCall(
		{
			m: module,
			action:'BackUpdateOrder',
			json: json,
			menu_id: menu_id
		},
		{
			callback: this.updateOrder_callback,
			context: tree
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
			modlayer.displayError(data.message);
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
				modlayer.displayError(data.message);
			}
		});
	},

	editModal : function(json)
	{

		var form = {
			'name' : 'editmenu',
			'method' : 'post',
			'action' : adminpath + 'menu/edit/',
			fields : [
				{
					"label" : language.translate('mod_language/modal/menu_title'),
					"tag" : "input",
					"type" : "text",
					"name" : "menu_name",
					"placeholder" : language.translate('mod_language/modal/menu_title_placeholder'),
					"autofocus" : "autofocus",
					"value" : json.menu.name
				},
				{
					"label" : language.translate('mod_language/modal/menu_url'),
					"tag" : "input",
					"type" : "text",
					"name" : "menu_url",
					"placeholder" : language.translate('mod_language/modal/menu_url_placeholder'),
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

		var form = tree.htmlForm(form);

		// Muestro el modal

		modal.header(language.translate('mod_language/modal/head_title_edit'));
		modal.options.height = 230;
		modal.body(form);
		modal.controls();
		modal.load();

		// Opciones para enviar el form por ajax
		var options = { 
	        // beforeSubmit:  showRequest,  
	        success: tree.editCallback
	    }; 

	    // Evento de enviar
		form.submit(function(){
			modal.loading(true);
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
			var menu = $('.category[menu_id='+json.menu.menu_id+']');
			$('*[role=title]', menu).html(json.menu.name);

			if (json.menu.url == '')
				$('*[role=url]', menu).hide();
			else
				$('*[role=url]', menu).html(domain+json.menu.url).show();

			modal.close();
		}
		else
		{
			modal.loading(false);
			alert(json.message);
		}
	},

	addChild : function(elem)
	{
		var parent = $(elem).attr('item_id');
		
		var form = {
			'name' : 'add',
			'method' : 'post',
			'action' : adminpath + 'menu/add/',
			fields : [
				{
					"label" : language.translate('mod_language/modal/menu_title'),
					"tag" : "input",
					"type" : "text",
					"name" : "menu_name",
					"placeholder" : language.translate('mod_language/modal/menu_title_placeholder'),
					"autofocus" : "autofocus",
					"value" : ""
				},
				{
					"label" : language.translate('mod_language/modal/menu_url'),
					"tag" : "input",
					"type" : "text",
					"name" : "menu_url",
					"placeholder" : language.translate('mod_language/modal/menu_url_placeholder'),
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

		var form = tree.htmlForm(form);

		// Muestro el modal
		modal.header(language.translate('mod_language/modal/head_title_add'));
		modal.options.height = 300;
		modal.body(form);
		modal.controls();
		modal.load();

		

		// Opciones para enviar el form por ajax
		var options = { 
	        // beforeSubmit:  showRequest,  
	        success: tree.addChildCallback
	    }; 

	    // Evento de enviar
		form.submit(function(){
			modal.loading(true);
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
			modal.close();
			window.location.reload();
		}
		else
		{
			modal.loading(false);
			alert(json.message);
		}
	},

	delete : function(elem)
	{
		var id = $(elem).attr('item_id');
		if(confirm(language.translate('mod_language/backend_message/delete_item')))
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
					modlayer.displayError(data.message);
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
		return form;

	}



}




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