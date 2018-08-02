define([
	'jquery'
	, 'UI'
	, 'Util'
	, 'clip/ui/js/video'
	// , 'clip/ui/js/videojs-playlist'
	// , 'clip/ui/js/videojs-playlist-ui.min'
	, 'clip/ui/js/youtube'
], function(
	$
	, UI
	, Util
	, videojs
){

	var player = {

		modPath : '',
		youtubeURL : '',

		toggle : function(id, poster)
		{
			var self = this;
			var videoElem = $('#video_'+id);

			if (videoElem.length == 0)
			{
				var autoplay = true;
				// var youtube  = $("meta[name='url']", article).attr('content');
				var video    = Util.Create('video', 
								{
									'id' :"video_"+id,
									'poster' : poster,
									// 'width'  : "auto",
									// 'height' : "auto",
									'class'  :"video-js vjs-default-skin vjs-big-play-centered"
								});

				$('.video').append(video);

				videojs('video_'+id, {
					"controls": true, 
					"autoplay": true, 
					"preload": "auto", 
					"loop": false, 
					"techOrder": ["youtube"], 
					"sources": [
						{ 
							"type": "video/youtube", 
							"src": ""+self.youtubeURL 
						}
					]
				});

			}
			else
			{
				self.togglePlay(id, 'play');
			}
		},

		toggleList : function(id, sources)
		{
			// console.log(sources);

			var video = Util.Create('video', 
						{
							'id' :"video_"+id,
							// 'poster' : poster,
							'width'  : "640",
							'height' : "480",
							'class'  :"video-js vjs-default-skin vjs-big-play-centered"
						});

			$('.video').append(video);

			list = 	videojs('video_'+id, {
						"controls": true,
						"autoplay": true,
						"preload": "auto",
						"loop": false,
						"techOrder": ["html5", "youtube"],
					});

			list.playlist(sources);
			list.playlist.autoadvance(0);
			// list.playlistUi();
		},

		togglePlay : function(id, event)
		{
			var instance = videojs('video_'+id);

			if(event == 'play')
			{
				// this.stopAll();
				instance.play();
			}
			else
			{
				instance.pause();
			}
		},

		stopAll : function()
		{
			for(x in this.collection)
			{
				if(typeof this.collection[x] == 'object')
				{
					var v = this.collection[x];
					var p = videojs(v.id);
					if(!p.paused())
						p.pause();
				}
			}
		}
	}

	return player;
});


