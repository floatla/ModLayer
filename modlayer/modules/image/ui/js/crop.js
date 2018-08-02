define([
	'jquery'
	, 'Util'
	, 'jCrop'
	, 'jForm'
], function(
	$
	, Util
	, Jcrop
	, jForm
){

	var Panel = 
	{
		_width : 0,
		_height : 0,
		_modal : 0,
		_item_id : 0,
		_callback : '',
		_categories : '',
		_module : '',

		BindActions : function()
		{
			var self = this;
			$(window).bind('load', function(){

				var wh = $(this).height();
				$('.image-crop').css('height', (wh - 120) + 'px');

				$('#cropbox').Jcrop({
					bgOpacity: 0.5,
					bgColor: 'white',
					addClass: 'jcrop-light',
					trueSize: [self._width, self._height],
					onSelect: self.updateCoords
				});
			});

			$(document).ready(function(){
				var options = {
					beforeSubmit : self.checkCoords,
					success: self.Close
				};
				$("form[name='cropimage']").ajaxForm(options);
			});
		},
		

		updateCoords : function(c)
		{
			console.log(c);
			$('#x').val(c.x);
			$('#y').val(c.y);
			$('#w').val(c.w);
			$('#h').val(c.h);
		},

		checkCoords : function()
		{
			if (parseInt($('#w').val())){
				$('.modal-controls').fadeOut('fast');
				return true;
			} 
			alert(window.appLanguage.translate('language/modal/crop/no_region_selected'));
			return false;
		},

		Close : function(json, statusText, xhr, $form)
		{
			var self = Panel;
			if(json.code == 200)
			{
				if( self._modal == 1 )
				{
					var 
						URL  = adminpath + module;
						URL += '/modal/?';
						URL += 'item_id=' + self._item_id;
						URL += '&callback=' + self._callback;
						URL += '&module=' + self._module;
						URL += '&categories=' + self._categories;
						URL += '&height=window';

						// console.log(URL);
						window.location.href = URL;
				}
				else
				{
					parent.appUI.ClosePanel();
					parent.location.replace(adminpath + module + '/edit/' + json.new_id);
				}
			}
			else
			{
				parent.appUI.RenderMessage(json.message);
			}
			
		}
	}



	return Panel;
});


















