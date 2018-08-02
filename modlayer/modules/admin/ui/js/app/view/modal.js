define(['jquery', 'Util'], function($, Util){

	var modal = {
		instance : null,
		html : null,
		headerStr : null,
		bodyStr : null,
		controlsStr : null,
		options : {
			'width' : '760px',
			'height': '500px'
		},
		
		layer : function() 
		{
			var self = this;
			var l = Util.Create('div', {
						'class':'modal-layer', 
						'style' : 'width:' + self.options.width // height:' + self.options.height,
					}).click(function(e){
						e.stopPropagation();
					});
			return l;
		},

		open : function(body)
		{
			var Context = this;
			var overlay = Util.Create('div', {'class' : 'modal-overlay'}).click(function(e){ Context.close(); });
			var wrapper = Util.Create('div', {'class' : 'modal-wrapper'});
			var close   = Util.Create('a', {'href':'#', 'class' : 'modal-close'})
							.html('Cerrar')
							.click(function(e){
								e.preventDefault();
								Context.close();
							});

			$('body').append(
				overlay.append(
					wrapper.append(
						body.append(
							close
						)
					)
				)
			);

			$('body').animate({opacity: 1}, 100, function(){
				body.addClass('showing');
				overlay.addClass('done');
			});

			Context.instance = body;
			if($('.modal-body .innerHeight').height() >= 450){
				$('.modal-body').css('height', Context.options.height);
			}
		},

		close : function()
		{
			var Context = this;
			$('.modal-layer').removeClass('showing');
			$('body').animate({opacity: 1}, 100, function(){
				$('.modal-overlay').fadeOut('fast', function(){
					$(this).remove();
				});
			})
			Context.instance = null;
		},

		loadHTML : function(html)
		{
			var Context = this;
			if(!Util.isNull(Context.instance)) {$('.modal-overlay').remove();}
			var l = Context.layer();
			l.append(html);
			this.open(l);
		},

		load : function()
		{
			var Context = this;
			if(!Util.isNull(Context.instance)) {$('.modal-overlay').remove();}
			var l = Context.layer();
			l.append(Context.headerStr);
			l.append(Context.bodyStr);
			this.open(l);

			$('*[autofocus]', l).focus();

		},

		header : function(title)
		{
			this.headerStr = Util.Create('div', {'class' : 'modal-header'}).append('<h3>'+title+'</h3>');
		},

		body : function(content)
		{
			var innerHeight = Util.Create('div', {'class' : 'innerHeight'});
			this.bodyStr = Util.Create('div', {'class' : 'modal-body'}).append(innerHeight.append(content));
		},

		controls : function(action)
		{
			var ok           = Util.Create('a',{'class' : 'btn modalSave lightblue'}, {'onclick' : 'return false;'}).html('Guardar');
			var cancel       = Util.Create('a',{'class' : 'btn'}, {'onclick' : 'modal.close();return false;'}).html('Cancelar');
			this.controlsStr = Util.Create('div',{'class' : 'modal-controls'});
			this.controlsStr.append(ok, cancel);
		},

		loading : function(bool)
		{
			if(bool !== false){
				$('.modal-controls *').hide();
				var img = '<img id="deleteLoader" src="' + adminmod + '/ui/imgs/icons/ripple.svg" alt="" style="width:32px;height:32px;"/>';
				$('.modal-controls').append(img);
			}
			else
			{
				$('.modal-controls #deleteLoader').remove();
				$('.modal-controls *').fadeIn('slow');
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

	return modal;

});