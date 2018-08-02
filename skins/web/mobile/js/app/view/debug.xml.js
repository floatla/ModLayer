define(['jquery'], function($) {

	var Debug = {

		Init : function() 
		{
			var Context = this;
			this.ShowDebug();
			var isCtrl = false;
			$(document).keyup(function (e){
				if(e.which == 18) isCtrl=false;
			}).keydown(function (e) {
			    if(e.which == 18) isCtrl=true;
			    if(e.which == 68 && isCtrl == true) {
					Context.OpenDebug();
			 		return false;
			 	}
			});

			$(".techoDebug a").click(function(e){
				e.preventDefault();
				Context.OpenDebug()
			});
		},

		ShowDebug : function()
		{
			var Context = this;
			$(document).scroll(function(){
				var offset = $(window).scrollTop();
				$(".xmlContentBack").css("top", offset);
				$(".xmlContent").css("top", offset);
				$(".debug").css("top", offset);
			})
			
			$('.codigo a').click(function(){
				$(this).next().next().toggle(Context.CheckTree($(this)));
				return false;
			});
		},

		CheckTree : function(elem)
		{
			elem.children('img').toggle();
		},

		OpenDebug : function()
		{
			var Context = this;
			$(".techoDebug a").unbind('click');
			$(".techoDebug a").click(function(e){
				e.preventDefault();
				Context.CloseDebug();
			});

			$('body').css({overflow:'hidden'});
			
			var offset = $(window).scrollTop();
			var h = $(window).height();
			var w = $(window).width();
			
			$(".debug").css("height", h);
			$(".debug").css("top", offset);
			
			$(".debug").show();
			$(".xmlContentBack").css("height", h - 27);
			$(".xmlContentBack").css("width", w);
			
			$(".techoDebug").css({top:"24px",bottom:'auto'});
			$(".xmlContentBack").css("top", offset + 27);
			$(".xmlContentBack").show()
			$(".xmlContent").css("height", h - 27);
			$(".xmlContent").css("width", w - 20);
			$(".xmlContent").css("top", offset + 27);
			$(".xmlContent").fadeIn('fast');

			document.onkeydown = function(e){ 	
				if (e == null) { // ie
					keycode = event.keyCode;
				} else { // mozilla
					keycode = e.which;
				}
				//alert(keycode);
				if(keycode == 27){ // close
					Context.CloseDebug();
				} 
			};
		},

		CloseDebug : function()
		{
			var Context = this;
			$(".techoDebug a").unbind('click');
			$(".techoDebug a").click(function(e){
				e.preventDefault();
				Context.OpenDebug();
			});

			$('body').css({overflow:'auto'});
			$(".techoDebug").css({top:'auto',bottom:0});
			$(".xmlContent, .debug, .xmlContentBack").hide();
		}


	}

	return Debug;

});