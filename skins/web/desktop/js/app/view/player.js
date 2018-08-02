define([
    'jquery', 
    'videojs',
    'youtube'
    ], function ($, videojs, youtube) {

	var player =
	{
		toggle : function(id, poster)
		{
			var videoElem = $('#video_'+id);

			if (videoElem.length == 0)
			{
				videojs('video_'+id, {"controls": true, "autoplay": false, "preload": "auto", "loop": false, "techOrder": ["youtube"], "sources": [{ "type": "video/youtube", "src": ""+youtubeurl}],'youtube': {"autoplay": 0 } });
			}
			else
			{
				this.togglePlay(id, 'play');
			}
		},

		togglePlay : function(id, event)
		{
			var instance = videojs('video_'+id);
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
		},
	}

	return player;
});