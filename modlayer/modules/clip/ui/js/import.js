define([
	'jquery'
	, 'UI'
	, 'Util'
	, 'Language'
], function(
	$
	, UI
	, Util
	, Language
){

	var clipYT = {

		videoId : null,

		BindActions : function()
		{
			$('[data-role="import"]').click(function(e){
				e.preventDefault();
				clipYT.import($(this).data('id'));
			})
		},

		import : function(videoId)
		{
			var self = this;
			self.videoId = videoId;
			var obj = $('li[item_id='+videoId+']');

			if($('span.importing',obj).length == 0){
				$('a.import', obj).before('<span class="boton importing right"><img src="'+adminmod+'/ui/imgs/loader.gif" style="vertical-align:-3px;margin:0 5px 0 0;" />'+Language.translate('mod_language/youtube/importing')+'</span>').hide();
			}else{
				$('a.import', obj).hide();
				$('span.importing', obj).show();
			}
			Util.ajaxCall(
			{
				m: 'clip',
				action: 'ImportYoutube',
				modToken: $("input[name='modToken']").val(),
				id: videoId
			},
			{
				callback: self.import_callback,
				context: self
			});
		},

		import_callback : function(data, textStatus, jqXHR)
		{
			var obj = $('li[item_id='+this.videoId+']');
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					$('span.importing', obj)
						.html('<img src="'+adminmod+'/ui/imgs/icons/checkmark.png" style="vertical-align:-3px;margin:0 5px 0 0;" />'+Language.translate('mod_language/youtube/imported'))
						.before('<a class="btn right" href="'+adminpath+module+'/edit/'+data.clip.clip_id+'">'+Language.translate('mod_language/youtube/btn_edit')+'</a>');
				}
				else
				{
					modlayer.displayMessage(data.message);
					$('span.importing', obj).hide();
				}
			}
			else
			{
				modlayer.displayMessage(data);
			}
		},

		importClipData : function(elem, service)
		{
			if (elem.value.length > 0)
			{
				var link = $(document.createElement('a')).attr({'href':'#', 'onclick' : 'clip.importClip("'+service+'");', 'style' : 'position:absolute;top:32px;right:5px;', 'class':'btn'}).html(Language.translate('mod_language/youtube/import_clip_data'));
				$('li.'+service+'-holder').append(link);
			}
			else
			{
				$('li.'+service+'-holder a.btn').remove();
			}
		},

		importClip : function(service)
		{
			var url = $('input#'+service+'URL').val();
			// alert(url);
			// return;
			Util.ajaxCall(
			{
				m: 'clip',
				action: 'ImportClip',
				modToken: $("input[name='modToken']").val(),
				clip_id: $("input[name='clip_id']").val(),
				url: url,
				service: service
			},
			{
				callback: this.importClipCallback,
				context: clipYT
			});
		},

		importClipCallback : function(data, textStatus, jqXHR)
		{
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					location.reload(true);
				}
				else
				{
					modlayer.displayMessage(data.message);
				}
			}
			else
			{
				modlayer.displayMessage(data);
			}
		}
	}

	return clipYT;

});

