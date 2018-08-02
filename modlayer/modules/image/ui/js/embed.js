define([
	'jquery'
	, 'Util'
	, 'jForm'
], function(
	$
	, Util
	, jForm
){

	var Panel = 
	{
		bucket : '',

		processPhoto : function(form)
		{

			var id          = $('input[name=image_id]', form).val();
			var type        = $('input[name=type]', form).val();
			var align       = $('input[name=align]:checked', form).val();
			var size        = $('input[name=size]:checked', form).val();

			var summary     = $('input[name=summary]:checked', form).val();
			var summarytext = $('input[name=summarytext]', form).val();	

			if(align == 'highlight' && (size != 'bomb' && size != 'inline')) {
				alert("El tamaño seleccionado para portada no es correcto.");
				return false;
			}
			if(align != 'highlight' && (size == 'bomb' || size == 'inline')){
				alert("La alineación seleccionada para portada no es correcto.");
				return false;
			}

			var 
			folder  = id.substr(id.length - 1, 1),
			ed      = parent.tinyMCE.activeEditor,
			caption = (summary==1) ? 1 : 0,
			width, widthStr;

			
			switch(size){
				case "small":
					widthStr	 = 'w200';
					break;
				case "medium":
					widthStr	 = 'w300';
					break;
				case "large":
					widthStr	 = 'w640';
					break;
				case "bomb":
				case "inline":
					widthStr	 = 'w80h80c';
					break;
				case "original":
					width	 = false;
					break;
			}
			
			
			var desc = ed.dom.create('span', {"class": "epi"}, summarytext) ;
			var img  = ed.dom.create('img', {"src": this.bucket + folder + '/' + id + widthStr + '.'+type, "alt" : ""});
			var el   = ed.dom.create('m_image', {"id" : id, "align" : align, "size" : size, "image_type" : type, "caption" : caption}, img);

			if(summary==1) { 
				$(el).append(desc); 
			}

			ed.selection.setNode(el);
			parent.appUI.ClosePanel()
			return false;
		},

		items : [],
		item_id : 0,
		
		addItem : function(id, type)
		{
			this.items.push({"id" : id, "type" : type});
			$("li[item_id="+id+"] .selectGallery a").hide();
			$('li[item_id='+id+'] .selectGallery span').show();
		},

		SelectEach : function(item_id)
		{
			this.item_id = item_id;
			$('.galleryControls').hide();
			$('.selectControls').show();
			$('.embed-images').addClass('gallerySelection');
			
		},

		SelectEachCancel : function()
		{
			$('.galleryControls').show();
			$('.selectControls').hide();
			$('.embed-images').removeClass('gallerySelection');
		},

		SelectEachSave : function()
		{
			var ed     = parent.tinyMCE.activeEditor;
			var ids    = '';
			var gEmbed = ed.dom.create('m_gallery_embed', {"item_id": this.item_id});
			
			for(o in this.items)
			{
				var id   = this.items[o].id;
				var type = this.items[o].type;

				var folder = id.toString().substr(id.length - 1, 1);
				var img  = ed.dom.create('img', {"src": this.bucket + folder + '/' + id  + 'w80h80c.'+type, "alt" : ""});
				$(gEmbed).append(img);

				ids += id + ',';
			}

			$(gEmbed).attr('images', Util.trim(ids));
			// ed.getBody().insertBefore(gEmbed, ed.selection.getNode());
			ed.getBody().insertBefore(gEmbed, (ed.selection.getNode().nodeName == 'BODY') ? ed.getBody().firstChild : ed.selection.getNode());
			parent.appUI.ClosePanel()
		},

		SelectAll : function(item_id)
		{
			this.item_id = item_id;

			var ed     = parent.tinyMCE.activeEditor;
			var ids    = '';
			var gEmbed = ed.dom.create('m_gallery_embed', {"item_id": this.item_id});

			$('.embed-images li').each(function(){

				var id   = $(this).attr('item_id');
				var type = $(this).attr('type');

				var folder = id.toString().substr(id.length - 1, 1);
				var img  = ed.dom.create('img', {"src": this.bucket + folder + '/' + id  + 'w80h80c.'+type, "alt" : ""});
				$(gEmbed).append(img);

				ids += id + ',';
			});	

			$(gEmbed).attr('images', Util.trim(ids));
			// ed.getBody().insertBefore(gEmbed, ed.selection.getNode());
			ed.getBody().insertBefore(gEmbed, (ed.selection.getNode().nodeName == 'BODY') ? ed.getBody().firstChild : ed.selection.getNode());
			parent.appUI.ClosePanel()
		}

	}

	return Panel;
});









