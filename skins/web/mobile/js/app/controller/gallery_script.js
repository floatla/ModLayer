/*  
	Claudio Romano Cherñac
	2010
	http://www.float.la
*/

var gallery = {

	element : null,
	container : null,
	panelCount : 0,
	panelWidth : 0,
	panelPos : 0,
	options : {
		panel    :  '.panel',
		thumbs   :  '#previews',
		wrap     :  'wrap',
		container:  'panelcontainer',
		animation : true
	},

	init : function(object, conf)
	{
		this.options      = jQuery.extend(gallery.options, conf);
		this.element      = $(object);
		this.panelCount   = this.element.find(this.options.panel).size();
		this.panelWidth   = $(this.options.panel, this.element).width();
		this.elementWidth = this.panelWidth * this.panelCount;

		var wr = $(document.createElement('div')).attr('class', this.options.wrap);
		var ps = $(document.createElement('div')).attr('class', this.options.container);

		$(wr).css({height: this.element.children().height()+'px'})
		$(ps).css({width: gallery.elementWidth+'px', position: 'relative'});

		ps.css("width" , this.elementWidth);

		this.element.prepend($(wr).append($(ps).append(gallery.element.children())));

		// Next button
		this.element.append(
			$(document.createElement('a'))
				.attr('href', '#')
				.addClass('next')
				.click(function(e){e.preventDefault();gallery.next();})
		);

		// Previous button
		this.element.append(
			$(document.createElement('a'))
				.attr('href', '#')
				.addClass('prev')
				.click(function(e){e.preventDefault();gallery.prev();})
		);

		this.container = ps;
		this.initPreviews();

		$("p.loading").fadeOut('fast', function(){
			gallery.element.animate({opacity: 1});
			$(gallery.options.thumbs).fadeIn('fast');
			gallery.setScroll();
			gallery.loadImage(gallery.panelPos);
			// console.log(gallery.panelPos);
		});

		$(document).keydown(function(event){
			if(event.keyCode == 39 || event.keyCode == 40)
			{
				gallery.next();
				return false;
			}
			if(event.keyCode == 37 || event.keyCode == 38)
			{
				gallery.prev();
				return false;
			}
		});

		var previewWidth = $('.panel', this.options.thumbs).width() + 1;

		var previewCount = jQuery('.panel', this.options.thumbs).size();
		jQuery('.panelcontainer', this.options.thumbs).css({width: (previewCount * previewWidth)+'px'});
	},

	setScroll : function()
	{
		$('html, body').animate({
		        scrollTop: $("h1#title").offset().top
		}, 'fast');	
	},

	next : function()
	{
		this.panelPos = (this.panelPos == (this.panelCount - 1)) ? 0 : this.panelPos + 1;
		this.move();
	},

	prev : function()
	{
		this.panelPos = (this.panelPos == 0) ? this.panelCount - 1 : this.panelPos - 1;
		this.move();
	},

	move: function()
	{
		this.loadImage(this.panelPos);
		//console.log(this.panelPos);
		var left = this.panelPos * this.panelWidth;

		if(this.options.animation){
			this.container.fadeOut(200, function(){
				$(this).css({left:-left+'px'});
				$(this).fadeIn('fast');
			});
		}else{
			//this.element.hide();
			this.container.animate({left:-left+'px'}, 'fast');
			//this.element.show();
		}
		this.updatePreviews();
	},

	initPreviews : function()
	{
		$('a', this.options.thumbs).each(function(index){

			var $thumb = $(this);
			$thumb.fadeTo(10, 0.3);
			$thumb.hover(function(){
				if(!$thumb.hasClass('active')){
					$(this).fadeTo(10, 1);
				}
			}, function(){
				if(!$thumb.hasClass('active')){
					$(this).fadeTo(10, 0.3);
				}
			});

			$(this).click(function(e){
				e.preventDefault();
				gallery.moveTo(index);
			});
		});

		$('a:eq('+(this.panelPos) +')', this.options.thumbs).fadeTo(10, 1).addClass("active");
	},

	moveTo: function(index)
	{
		this.panelPos = index;
		this.move();
	},

	updatePreviews : function()
	{
		var side  = 3;
		var total = 7;
		var thumbWidth = $('.panel', this.options.thumbs)[0].offsetWidth + 1;
		
		if(this.panelCount > total - 1){
			if(this.panelPos <= side)
			{
				$('.panelcontainer', this.options.thumbs).animate({left:0}, 200);
			}
			else if (this.panelPos >= (this.panelCount - side))
			{
				var offset = - ((this.panelCount - (side + 1)) * thumbWidth) + (thumbWidth * side);
				$('.panelcontainer', this.options.thumbs).animate({left:offset+'px'}, 200);
			}
			else
			{
				var offset = - (this.panelPos * thumbWidth) + (thumbWidth * side);
				$('.panelcontainer', this.options.thumbs).animate({left:offset+'px'}, 200);
			}
		}
		$('a.active').fadeTo(10, 0.3).removeClass("active");
		$('a:eq('+this.panelPos+')', this.options.thumbs).fadeTo(10, 1).addClass("active");
	},

	loadImage : function(position)
	{
		var img = $('.panel:eq('+position+') img.poster', this.container);
		if(img.attr('src') == '')
		{
			var source = img.attr('data-src');
			img.hide();
			img.attr('src', source).fadeIn('fast');
		}
	}


};


jQuery(window).bind("load", function() {
	gallery.init('#gallery');
});

jQuery(function(){
	jQuery("#gallery").before("<div class='loader'><p class='loading'>Cargando...</p></div>");
});