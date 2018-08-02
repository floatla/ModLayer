define([
	'jquery'
	, 'Util'
	, 'FileAPI'
	, 'FileAPI.id3'
	, 'FileAPI.exif'
], 
function (
	$
	, Util
	, FileAPI
	, FileAPI_id3
	, FileAPI_exif
) {

	function FileUpload() 
	{

		var self = this;
		self.accept = [];
		self.files  = [];
		self.index   = 0;
		self.active  = false;
		self.handler = null;
		self.data  = {};
		self.maxsize = 1000000;


		self.BindActions = function(handler)
		{
			$(document).ready(function()
			{
				var choose = document.getElementById('choose');
				FileAPI.event.on(choose, 'change', function (evt){
					var files = FileAPI.getFiles(evt); // Retrieve file list
					self.onFiles(files);
				});
			 
				/* Drag n Drop */
				if( FileAPI.support.dnd ){
					// $('#drop-area').css({"height" : $(window).width() + 'px'});
					$(document).dnd(function (over){
						$('#drop-zone').toggle(over);
					}, function (files){
						self.onFiles(files);
					});
				}
				self.SetHandler(handler);

				if( Util.isNull(self.handler) ){
					alert('No se definió la función <i>"handler"</i> para el upload. Evite errores.');
				}
			});
		}

		
		self.SetMaxsize = function(size) { self.maxsize = size; }

		self.AcceptedFormats = function(formats) { self.accept = formats; }

		self.SetHandler = function(handlerOBJ) { self.handler = handlerOBJ; }

		self.SetPostParams = function(dataOBJ) { self.data = dataOBJ; }
		

		self.onFiles = function(files)
		{
			FileAPI.each(files, function (file)
			{
				self.add(file);
			});
		}

		self.add = function(file)
		{
			if(file.size > self.maxsize){
				alert(window.appLanguage.translate('language/file_api/max_size_exceeded'));
				return false;
			}

			var isok = false;
			if(self.accept.indexOf(file.type) !== -1){ isok = true; }
			var d  = Util.Create('div', {'class':'row', 'file_name': file.name});
			var p  = Util.Create('p').html(file.name);
			var b  = Util.Create('div', {'class' : 'progress-bar'});
			var pr = Util.Create('span', {'class' : 'percent'}).html((isok) ? '0%' : 'No permitido');

			d.append(p, d, b, pr);
			d.appendTo('#upload-progress');

			if(isok){
				self.upload(file);
			}
		}

		self.upload = function(file)
		{
			if( file ){
				file.xhr = FileAPI.upload({
					url: adminpath + module + '/upload/',
					headers: { 'x-upload': 'modlayer-fileapi' },
					data: self.data,
					files: { file: file },
					upload: function (){},
					progress: function (evt){
						var c = $(".row[file_name='"+file.name+"']");
						$(".progress-bar",c).css('width', evt.loaded/evt.total*100+'%');
						$(".percent",c).html(evt.loaded/evt.total*100+'%');
					},
					complete: function (err, xhr){
						var state = err ? 'error' : 'done';
						var c = $(".row[file_name='"+file.name+"']");
						$(".progress-bar",c).fadeOut();
						$(".percent",c).html((err ? (xhr.statusText || err) : state));
						self.handler.uploadComplete(xhr);
					}
				});
			}
		}
	}	


	return FileUpload;
});