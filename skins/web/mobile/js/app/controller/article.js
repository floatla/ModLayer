define([
    'jquery', 
    'app/view/player', 
    'app/view/rotator',
    'jplayer'
    ], function ($, player, rotator, jPlayer) {

    // var $     = require('jquery');
    // var player = require('app/view/player');

    var font = {
		size : 1,
		sizeUp : function()
		{
			$('.viewitem').removeClass('size' + this.size);
			this.size = (this.size == 3) ? 3 : this.size + 1;
			$('.viewitem').addClass('size' + this.size);
		},
		sizeDown : function()
		{
			$('.viewitem').removeClass('size' + this.size);
			this.size = (this.size == 0) ? 0 : this.size - 1;
			$('.viewitem').addClass('size' + this.size);
		}
	}
    var GalEmbed;

    $(function () {
    	var videos = $('.video-js').toArray();
    	for (i in videos) {
    		var id = $(videos[i]).data('id');
    		player.toggle(id);
    	}

    	// Tamaño de fuente
    	$('.ampliar').click(function(){
    		font.sizeUp();
    	});
    	$('.reducir').click(function(){
    		font.sizeDown();
    	});

        // Galerias Embebidas
        GalEmbed = rotator.Init(
            '.m_gallery_embed',
            {
                pagination: '.swiper-pagination',
                nextButton: '.next',
                prevButton: '.prev',
                paginationClickable: true,
                spaceBetween: 0,
                centeredSlides: true,
                // autoplay: 6000,
                // autoplayDisableOnInteraction: false,
                loop: true,
            }
        );
        $('.m_gallery_embed .m_image').click(function(){
            GalEmbed.slideNext();
        });

        $(document).ready(function(){
            $(".jp-jplayer").each(function(){
                var id = $(this).data('id');

                $("#jquery_jplayer_" + id).jPlayer({
                    ready: function (event) {
                        var thisSrc = $(this).data('src');
                        var thisTit = $(this).data('title');
                        $(this).jPlayer("setMedia", {
                            title: thisTit,
                            mp3: thisSrc
                        });
                    },
                    cssSelectorAncestor: "#jp_container_" + id,
                    swfPath: skinpath + "/js/lib/jplayer",
                    supplied: "mp3",
                    wmode: "window",
                    globalVolume: true,
                    useStateClassSkin: true,
                    autoBlur: false,
                    smoothPlayBar: true,
                    keyEnabled: true
                });

            });
        });

        

        
        
    });


});
