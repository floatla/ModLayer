define([
	'jquery', 
	'app/view/rotator'
	], function ($, rotator) {
	
	var GalSwipe;
	/* Ejecutar este codigo */	
	$(function () {
		

		// if($('.gsearch').length > 0){
		// 	autocomplete.Init();
		// }
		
		// Inicializar Slide home
		GalSwipe = rotator.Init(
			'#gallery',
			{
				pagination: '.swiper-pagination',
				nextButton: '.swiper-button-next',
				prevButton: '.swiper-button-prev',
				paginationClickable: true,
				spaceBetween: 0,
				centeredSlides: true,
				autoplay: 6000,
				autoplayDisableOnInteraction: true,
				loop: true,
			}
		);

		$('#gallery .panel').click(function(){
			GalSwipe.slideNext();
		});

		$(document).keydown(function(event){
			if(event.keyCode == 39 || event.keyCode == 40)
			{
				GalSwipe.slideNext();
				return false;
			}
			if(event.keyCode == 37 || event.keyCode == 38)
			{
				GalSwipe.slidePrev();
				return false;
			}
		});
		
		// Inicializar Mapa
		// GMap.FetchLocations();

		// var bLazy = new Blazy({
		// 	// breakpoints: [{
		// 	// 	width: 420 // Max-width
		// 	//   , src: 'data-src-small'
		// 	// }], 
		// 	loadInvisible: true,
		// 	offset : 100,
		// 	success: function(element){
		// 		setTimeout(function(){
		// 			// We want to remove the loader gif now.
		// 			// First we find the parent container
		// 			// then we remove the "loading" class which holds the loader image
		// 			var parent = element.parentNode;
		// 			parent.className = parent.className.replace(/\bloading\b/,'');
		// 			element.removeAttribute('width');
		// 			element.removeAttribute('height');
		// 			}, 
		// 			200
		// 		);
		// 	}
		// });
	});
});


/*  
	Claudio Romano Cherñac
	2010
	http://www.float.la
*/
// var gallery={element:null,container:null,panelCount:0,panelWidth:0,panelPos:0,options:{panel:".panel",thumbs:"#previews",wrap:"wrap",container:"panelcontainer",animation:true},init:function(e,t){this.options=jQuery.extend(gallery.options,t);this.element=$(e);this.panelCount=this.element.find(this.options.panel).size();this.panelWidth=$(this.options.panel,this.element).width();this.elementWidth=this.panelWidth*this.panelCount;var n=$(document.createElement("div")).attr("class",this.options.wrap);var r=$(document.createElement("div")).attr("class",this.options.container);$(n).css({height:this.element.children().height()+"px"});$(r).css({width:gallery.elementWidth+"px",position:"relative"});r.css("width",this.elementWidth);this.element.prepend($(n).append($(r).append(gallery.element.children())));this.element.append($(document.createElement("a")).attr("href","#").addClass("next").click(function(e){e.preventDefault();gallery.next()}));this.element.append($(document.createElement("a")).attr("href","#").addClass("prev").click(function(e){e.preventDefault();gallery.prev()}));this.container=r;this.initPreviews();$("p.loading").fadeOut("fast",function(){gallery.element.animate({opacity:1});$(gallery.options.thumbs).fadeIn("fast");gallery.setScroll();gallery.loadImage(gallery.panelPos)});$(document).keydown(function(e){if(e.keyCode==39||e.keyCode==40){gallery.next();return false}if(e.keyCode==37||e.keyCode==38){gallery.prev();return false}});var i=$(".panel",this.options.thumbs).width()+1;var s=jQuery(".panel",this.options.thumbs).size();jQuery(".panelcontainer",this.options.thumbs).css({width:s*i+"px"})},setScroll:function(){$("html, body").animate({scrollTop:$("h1#title").offset().top},"fast")},next:function(){this.panelPos=this.panelPos==this.panelCount-1?0:this.panelPos+1;this.move()},prev:function(){this.panelPos=this.panelPos==0?this.panelCount-1:this.panelPos-1;this.move()},move:function(){this.loadImage(this.panelPos);var e=this.panelPos*this.panelWidth;if(this.options.animation){this.container.fadeOut(200,function(){$(this).css({left:-e+"px"});$(this).fadeIn("fast")})}else{this.container.animate({left:-e+"px"},"fast")}this.updatePreviews()},initPreviews:function(){$("a",this.options.thumbs).each(function(e){var t=$(this);t.fadeTo(10,.3);t.hover(function(){if(!t.hasClass("active")){$(this).fadeTo(10,1)}},function(){if(!t.hasClass("active")){$(this).fadeTo(10,.3)}});$(this).click(function(t){t.preventDefault();gallery.moveTo(e)})});$("a:eq("+this.panelPos+")",this.options.thumbs).fadeTo(10,1).addClass("active")},moveTo:function(e){this.panelPos=e;this.move()},updatePreviews:function(){var e=3;var t=7;var n=$(".panel",this.options.thumbs)[0].offsetWidth+1;if(this.panelCount>t-1){if(this.panelPos<=e){$(".panelcontainer",this.options.thumbs).animate({left:0},200)}else if(this.panelPos>=this.panelCount-e){var r=-((this.panelCount-(e+1))*n)+n*e;$(".panelcontainer",this.options.thumbs).animate({left:r+"px"},200)}else{var r=-(this.panelPos*n)+n*e;$(".panelcontainer",this.options.thumbs).animate({left:r+"px"},200)}}$("a.active").fadeTo(10,.3).removeClass("active");$("a:eq("+this.panelPos+")",this.options.thumbs).fadeTo(10,1).addClass("active")},loadImage:function(e){var t=$(".panel:eq("+e+") img.poster",this.container);if(t.attr("src")==""){var n=t.attr("data-src");t.hide();t.attr("src",n).fadeIn("fast")}}};jQuery(window).bind("load",function(){gallery.init("#gallery")});jQuery(function(){jQuery("#gallery").before("<div class='loader'><p class='loading'>Cargando...</p></div>")})