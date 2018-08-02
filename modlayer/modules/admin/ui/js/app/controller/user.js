define([
		'jquery'
		, 'Util'
		, 'UI'
		, 'Language'
		, 'Sidepanel'
	], 
	function (
		$
		, Util
		, UI
		, Language
		, Sidepanel
	) {

	var user = {

		relation_id : 0,
		type_id : 0,

		BindListActions : function()
		{
			$('.list-row .delete').click(function(e){
				e.preventDefault();
			});

			if($('.list-header').length > 0){
				$('section.content').addClass('with-header');
			}
		},

		SendEmail : function(user_id)
		{
			$('#sendEmail').after('<span id="sendingEmail" class="botoncito" style="display:block;width:80px;margin:auto;">' +Language.translate('mod_language/user/backend_messages/send_info/sending') + '</span>');
			$('#sendEmail').hide();
			
			
			$.ajax({
				type: "POST",
				url: adminpath+"?m=admin&action=BackEmailSend",
				data: "user_id="+user_id,
				success: function(response){
					if(response.code == 200){
						$('li.user').html('<p>' + Language.translate('mod_language/user/backend_messages/send_info/success') + '</p>');
					}else{
						alert(response.message);
					}
				}
			});
		},

		
		Remove : function(user_id)
		{
			if(confirm(Language.translate('mod_language/user/backend_messages/delete_user'))){
				
				$.ajax({
					type: "POST",
					url: adminpath+"users/delete/"+user_id,
					data: "user_id="+user_id,
					success: function(response){
						if(response==1){
							jQuery('#user_'+user_id).slideUp('fast');
							jQuery('#user_'+user_id).remove();
						}else{
							//alert('Se ha producido un error y no se pudo borrar al usuario');
							alert(response);
						}
					}
				});
			}
		}
	}

	return user;

});