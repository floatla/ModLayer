define([
		'jquery'
		, 'Util'
		, 'UI'
	], 
	function (
		$
		, Util
		, UI
	) {

	var cache = {
		fileName : '',
		folderName : '',

		BindActions : function()
		{
			var self = this;
			$('*[data-role="empty-folder"]').click(function(e){
				e.preventDefault();
				self.EmptyFolder($(this).data('name'));
			});

			$('*[data-role="delete-file"]').click(function(e){
				e.preventDefault();
				self.DeleteFile($(this).data('name'), $(this).data('filter'));
			});
		},

		DeleteFile : function(name, filter)
		{
			var self = this;
			self.fileName = name;
			var token = $('input[name=modToken]').val();
			Util.ajaxCall(
			{
				m: 'cache',
				action: 'BackDeleteFile',
				name: name,
				filter: filter,
				modToken: token
			},
			{
				callback: self.deleteFile_callback,
				context: self
			});
		},

		deleteFile_callback : function(data, textStatus, jqXHR)
		{
			var self = this;
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					$("li[name='"+self.fileName+"']").fadeOut('fast');
				}
				else
				{
					UI.RenderMessage(data.message);
				}
			}
			else
			{
				UI.RenderMessage(data);
			}

		},

		EmptyFolder: function(filter)
		{
			var self = this;
			self.folderName = filter;
			var token = $('input[name=modToken]').val();
			Util.ajaxCall(
			{
				m: 'cache',
				action: 'BackDeleteFolder',
				filter: filter,
				modToken: token
			},
			{
				callback: self.deleteFolder_callback,
				context: cache
			});
		},

		deleteFolder_callback : function(data, textStatus, jqXHR)
		{
			var self = this;
			if(typeof data == 'object')
			{
				if(data.code == 200)
				{
					$("li[folder='"+self.folderName+"']").fadeOut('fast');
				}
				else
				{
					UI.RenderMessage(data.message);
				}
			}
			else
			{
				UI.RenderMessage(data);
			}
		}

	};

	return cache;

});

// var cache = {
// 	fileName : '',
// 	folderName : '',

// 	deleteFile : function(name, filter)
// 	{
// 		this.fileName = name;
// 		var token = $('input[name=modToken]').val();
// 		Util.ajaxCall(
// 		{
// 			m: 'cache',
// 			action: 'BackDeleteFile',
// 			name: name,
// 			filter: filter,
// 			modToken: token
// 		},
// 		{
// 			callback: this.deleteFile_callback,
// 			context: cache
// 		});
// 	},

// 	deleteFile_callback : function(data, textStatus, jqXHR)
// 	{
// 		if(data == '1'){
// 			$("li[name='"+this.fileName+"']").fadeOut('fast');
// 		}
// 	},

// 	deleteFolder: function(filter)
// 	{
// 		this.folderName = filter;
// 		var token = $('input[name=modToken]').val();
// 		Util.ajaxCall(
// 		{
// 			m: 'cache',
// 			action: 'BackDeleteFolder',
// 			filter: filter,
// 			modToken: token
// 		},
// 		{
// 			callback: this.deleteFolder_callback,
// 			context: cache
// 		});
// 	},

// 	deleteFolder_callback : function(data, textStatus, jqXHR)
// 	{
// 		if(data == '1'){
// 			$("li[folder='"+this.folderName+"']").fadeOut('fast');
// 		}
// 	}

// };




// jQuery.fn.deleteAll = function(){
// 	jQuery(this).click(function(e){
// 		e.preventDefault();
		
// 		var objeto = $("ul.list li");
// 		jQuery.ajax({
// 			type: "POST",
// 			url: "?m=cache&action=cache_delete",
// 			data: "type="+jQuery('.box').attr('id')+"&name=all",
// 			success: function(msg){
// 				if(msg == '1'){
// 					if($.browser.safari){
// 						//objeto.slideUp('slow');
// 					}
// 					//objeto.animate({ backgroundColor: "#cae5f7" }, "fast").slideUp('slow')
// 					objeto.hide();
// 				}else{
// 					var bk = objeto.css('background-color');
// 					if(bk == 'transparent'){bk='#ffffff';}
// 					objeto.animate({ backgroundColor: "#fbc7c7" }, "fast").animate({ backgroundColor: bk }, "fast").animate({ backgroundColor: "#fbc7c7" }, "fast").animate({ backgroundColor: bk }, "fast");
// 				}
// 			}
// 		});
		
// 	});
// }


