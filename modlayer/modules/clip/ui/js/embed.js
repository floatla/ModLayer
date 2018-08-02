define([
	'jquery'
	, 'Util'
], function(
	$
	, Util
){

	var EmbedPanel = {

		processClip : function(form)
		{
			var id     = $('input[name=id]', form).val();
			var poster = $('input[name=poster]', form).val();
			var title  = $('input[name=title]', form).val();

			html = '<clip id="'+id+'"><img src="'+poster+'" alt="" /> '+title+'</document>';

			var ed   = parent.tinyMCE.activeEditor;

			var desc = ed.dom.create('span', {"class": "title"}, title) ;
			var img  = ed.dom.create('img', {"src": poster, "alt" : ""});
			var el   = ed.dom.create('m_clip', {"id" : id}, img);

			$(el).append(desc);

			// console.log(ed.selection.getNode().nodeName);
			// return false;

			// if(ed.selection.getNode().nodeName == 'BODY'){
			// 	ed.getBody().insertBefore(el, ed.getBody().firstChild);
			// }else{
			// 	ed.getBody().insertBefore(el, ed.selection.getNode());
			// }

			ed.getBody().insertBefore(el, (ed.selection.getNode().nodeName == 'BODY') ? ed.getBody().firstChild : ed.selection.getNode());
			parent.appUI.ClosePanel();
			return false;

			// parent.tinyMCE.activeEditor.selection.setContent(html, {format : 'raw'});

			// //parent.sidepanel.close();;
			// parent.sidepanel.close();
			// return false;
			
		}

	}

	return EmbedPanel;
});

// var docPath, modPath;


// function processClip(form)
// {
// 	var id     = $('input[name=id]', form).val();
// 	var poster = $('input[name=poster]', form).val();
// 	var title  = $('input[name=title]', form).val();

// 	html = '<clip id="'+id+'"><img src="'+poster+'" alt="" /> '+title+'</document>';

// 	var ed   = parent.tinyMCE.activeEditor;

// 	var desc = ed.dom.create('span', {"class": "title"}, title) ;
// 	var img  = ed.dom.create('img', {"src": poster, "alt" : ""});
// 	var el   = ed.dom.create('m_clip', {"id" : id}, img);

// 	$(el).append(desc);

// 	// console.log(ed.selection.getNode().nodeName);
// 	// return false;

// 	// if(ed.selection.getNode().nodeName == 'BODY'){
// 	// 	ed.getBody().insertBefore(el, ed.getBody().firstChild);
// 	// }else{
// 	// 	ed.getBody().insertBefore(el, ed.selection.getNode());
// 	// }

// 	ed.getBody().insertBefore(el, (ed.selection.getNode().nodeName == 'BODY') ? ed.getBody().firstChild : ed.selection.getNode());
// 	parent.sidepanel.close();
// 	return false;

// 	// parent.tinyMCE.activeEditor.selection.setContent(html, {format : 'raw'});

// 	// //parent.sidepanel.close();;
// 	// parent.sidepanel.close();
// 	// return false;
	
// }


