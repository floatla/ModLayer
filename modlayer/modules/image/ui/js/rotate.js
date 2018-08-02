define([
	'jquery'
	, 'Util'
	, 'jForm'
], function(
	$
	, Util
	, jForm
){

	var rotate = {

		src : null,
		init : function()
		{
			$('#target').click(function(e){
				e.preventDefault();
				var id = $(this).attr('image_id');
				rotate.apply(id);
			});

			this.src = $('#target').attr('src');
		},

		apply : function(id)
		{
			var self = this;
			Util.ajaxCall(
			{
				m: 'image',
				action: 'Rotate',
				image_id: id,
			},
			{
				callback: self.applyCallback,
				context: self
			});
		},

		applyCallback : function(json)
		{
			if(json.code == 200)
			{
				var date = new Date();
				$('#target').attr({'src': this.src + '?v=' + date.getTime()});

				prevSrc = parent.$('.image-preview img').attr('src');
				parent.$('.image-preview img').attr('src', prevSrc + '?v=' + date.getTime());
			}
		}
	}

	return rotate;
});





















