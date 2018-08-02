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
			var l = Util.Create('div', {
						'class':'modal-layer', 
						'style' : 'width:' + modal.options.width + ';height:' + modal.options.height,
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
			l.append(Contextl.headerStr);
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
			this.bodyStr = Util.Create('div', {'class' : 'modal-body'}).append(content);
		}
	}

	return modal;

});