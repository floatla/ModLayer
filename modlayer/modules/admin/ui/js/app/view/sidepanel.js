define([
	'jquery'
	, 'Util'
	], function ($, Util) {
	
	var Sidepanel = {

		html : null,
		load : function(reference)
		{
			var self = this;
			url = ( Util.isObject(reference) ) ? reference.href : reference;
			var iframe = Util.Create('iframe', {
				"frameborder" :"0", 
				"hspace" : "0", 
				"src" : url,
				"id" : 'sidepanel-window',
				"name" : Math.round(Math.random()*1000),
				"style" : "width:100%;height:100%"
			});
			iframe[0].addEventListener('load', function(){ self.loaded(); });
			self.html = iframe;
			self.open();
		},

		open : function()
		{
			var self = this;
			var overlay = $(document.createElement('div'))
							.addClass('sidepanel-overlay')
							.click(function(e){
								self.close();
							});
			var close = $(document.createElement('a'))
							.addClass('sidepanel-close')
							.html('<span></span><span></span>')
							.click(function(e){
								self.close();
							});
			var wrapper = $(document.createElement('div')).addClass('sidepanel-wrapper');
			var layer   = $(document.createElement('div'))
							.addClass('sidepanel-layer')
							.click(function(e){
								e.stopPropagation();
							});

			$('body').append(
				overlay.append(wrapper, close)
			);

			$('body').animate({opacity: 1}, 100, function(){
				wrapper.addClass('showing');
				overlay.addClass('done');
				wrapper.append(self.html)
			})
		},

		close : function()
		{
			$('.sidepanel-wrapper').removeClass('showing');
			$('body').animate({opacity: 1}, 100, function(){
				$('.sidepanel-overlay, .sidepanel-close').fadeOut('fast', function(){
					$(this).remove();
				});
			})
		},

		loaded : function()
		{
			$('.sidepanel-wrapper').addClass('loaded');
		}
	}
	
	return Sidepanel;
});