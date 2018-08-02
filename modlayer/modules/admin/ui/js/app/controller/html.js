define([
	'jquery'
	], function ($) {
	
	
	/* Ejecutar este codigo */	
	$(function () {
		
		var html = {

			form : function(obj)
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
		
	});
});