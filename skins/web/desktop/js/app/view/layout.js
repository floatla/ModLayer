define(
	[
		'jquery', 
		'underscore', 
		'Util', 
		'Modal', 
		'backbone'
	], function($, _, Util, modal, Backbone){


	LayoutController = {

		panels : null,
		content : null,

		SetConfig : function(config){
			this.config = config;
		},

		PrepareDOM : function()
		{
			var c = Util.Create('div', {'id' : 'appLayout'}).on('resize', function(){
				$(window).trigger('resize');
			});
			$('#app').append(c);
		},

		Start : function()
		{
			// this.PrepareDOM();
			this.panels = gl = new layout(this.config, $('#appLayout'));
			this.panels.on('initialised', function() {
                $('body').removeClass('loading')
            });
            $(window).on('resize', function() {
    			gl.updateSize();
    		});
		},

		Register : function()
		{
			var list = this.ParseContent(this.config.content);
			try
			{
				for(n in list){
					var comp = list[n]; //, type = this.getParser(comp.componentType);

					this.panels.registerComponent(comp.componentName, function( container, componentState ){
	    		    	// container.getElement().html( '<h2>' + componentState.label + '</h2>' );
	    		    	container.getElement().html( '<h2>55456156</h2>' );
	    			});
				}
			}
			catch(e){
				console.log("Error registrando componentes: " + e.message);
			}
			// console.log(list);
		},

		ParseContent : function(obj) {

			var a = [], b = null;
			if(obj.constructor === Array){
				for(i in obj) {
					a.push.apply( a, this.ParseContent(obj[i]) );
				}
			} else if (obj.constructor === Object) {
				for (var prop in obj) {
				    if (obj.hasOwnProperty("type") && prop == 'type' && (obj.type == 'row' || obj.type == 'column')) {
				    	a.push.apply( a, this.ParseContent(obj.content) );
				    }
				    else if (obj.hasOwnProperty("type") && obj.type == 'component' && prop == 'type') {
				    		a.push(obj);
				    }
				}
			}
			return a;
		},

		getInstance : function() {
			return this.panels;
		},

		GetContent : function() {
			return this.config.content;
		},

		SetContent : function(content) {
			this.config.content = content;
		},

		RenderMessage : function(message)
		{
			// alert(message);
			html = '<div class="modal-header"><h3>Mensaje del sistema</h3></div>';
			html += '<div class="modal-body">';
			html += '<p>'+message+'</p>';
			html += '</div>';
			
			modal.options.height = 'auto';
			modal.loadHTML(html);

		}
	}

	
	return LayoutController;

});