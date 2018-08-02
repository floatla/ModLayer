define(['backbone'], function(Backbone) {
	
	
	
	var model = Backbone.Model.extend({
					urlRoot: (requirejs.s.contexts._.config.enviroment == 'dev') 
							 ? 'http://54.165.179.113:8080/flowwe/' 
							 : ''
					
				});


	Backbone.history.start();
	return new model();
});