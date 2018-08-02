define(['jquery', 'jForm', 'app/model/service', 'Util'], function($, jForm, service, Util){

	User = {

		data : {},

		Login : function()
		{
			var Context = this;
			var options = { 
				beforeSubmit:  Context.SendLogin
				// success: closeModal
			};
			$('#loginForm').ajaxForm(options);
		},

		SendLogin : function(formData, jqForm, options)
		{
			var email, pass;

			/* Revalidamos los campos para no confiarnos en el required del navegador */
			for(i in formData){
				if(formData[i].value == ''){
					alert("Los campos Email y contraseña son requeridos.");
				}
				if(formData[i].name == 'email')
					email = formData[i].value;

				if(formData[i].name == 'password')
					pass = formData[i].value;
			}

			service.url = service.urlRoot + 'iniciarsesion';
			service.fetch({
				data : {'username' : email, 'password' : pass},
				type: 'POST',
				xhrFields: { withCredentials: true },
				complete: function(resp){
					if(resp.status == 200){
						window.location.href = "index.html";
					}else{
						alert("Los datos no son correctos.");
					}
			   }
			});
			return false;
		},

		Register : function()
		{
			var Context = this;
			var options = { 
				beforeSubmit:  Context.SendRegistration
				// success: closeModal
			};
			$('#registerForm').ajaxForm(options);
		},

		SendRegistration : function(formData, jqForm, options)
		{
			if($(jqForm)[0].password1.value != $(jqForm)[0].password.value){
				alert("Las contraseñas no coinciden");
				return false;
			}

			var params = {
				'nombre' : '',
				'apellido' : '',
				'email' : '',
				'password' : '',
				'empresa' : {},
				'idioma' : ''
			};

			for(i in formData){

				if(formData[i].value == ''){
					alert("Todos los campos son obligatorios.");
				}

				if(formData[i].name == 'nombre')
					params.nombre = formData[i].value;

				if(formData[i].name == 'apellido')
					params.apellido = formData[i].value;

				if(formData[i].name == 'email')
					params.email = formData[i].value;

				if(formData[i].name == 'password')
					params.password = formData[i].value;

				if(formData[i].name == 'empresa')
					params.empresa.nombre = formData[i].value;

				if(formData[i].name == 'idioma')
					params.idioma = formData[i].value;
			}

			// console.log(params);
			// return false;

			service.url = service.urlRoot + 'resources/usuario/registracion';
			var data = service.fetch({
				type: 'POST',
				data : JSON.stringify(params),
				contentType: "application/json; charset=utf-8",
				dataType: 'json',
				complete: function(resp){
					
					if(resp.responseJSON.status == 'ERROR'){
						alert('No se pudo realizar la registración, se produjo un error.');
					}
					console.log(resp.responseJSON);
					// alert(resp.getAllResponseHeaders());
				}
			   });
			   // console.log(data.responseJSON);
			return false;
		},

		logged : function()
		{
			service.url = service.urlRoot + 'resources/usuario/logueado';
			var resp =  service.fetch({
							async : false,
							xhrFields: { withCredentials: true }
						});

			if(resp.responseJSON.data == null)
				return false;

			this.data = resp.responseJSON.data;
			this.ShowData();
			return this.data;
			// console.log(resp.responseJSON);
		},

		ShowData : function()
		{
			var Context  = this;
			var userdata = Util.Create('span').html(this.data.nombre + " " + this.data.apellido);
			var logout   = Util.Create('a', {'href' : '#'})
							.on('click', function(e){
								e.preventDefault();
								Context.Logout();
							}).html('Salir');
			$('#user-data').html('').append(userdata, logout);
		},

		Logout : function()
		{
			service.url = service.urlRoot + 'cerrarsesion';
			var resp =  service.fetch({
				async : false,
				xhrFields: { withCredentials: true },
				complete: function(resp){
					window.location.replace('login.html');
					// alert(resp.status);
					// if(resp.status == 200){
					// 	window.location.href = "index.html";
					// }else{
					// 	alert("Los datos no son correctos.");
					// }
			   }
			});
		},
	}


	return User;

});