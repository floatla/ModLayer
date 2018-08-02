<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

<xsl:param name="domain" />
<xsl:param name="page_url" />
<xsl:param name="step" />


<xsl:variable name="config" select="/xml/configuration" />


<xsl:template match="/xml">
<html>
<head>
	<title>Install <xsl:value-of select="$config/system/applicationID"/></title>

	<link rel="stylesheet" type="text/css" href="{$adminPath}/desktop/css/backend.css"/>
	<link rel="stylesheet" type="text/css" href="{$config/system/adminpath}/firstrun/install.css"/>
	<!-- <link rel="stylesheet" type="text/css" href="{$adminPath}/desktop/css/admin.css"/> -->
	<!-- <script src="{$adminPath}/desktop/js/jquery-1.7.1.min.js">&#xa0;</script> -->
	<!-- <script type="text/javascript" src="{$adminPath}/desktop/bootstrap/js/bootstrap.min.js">&#xa0;</script> -->
</head>
<body class="install">
	<img src="{$adminPath}/desktop/imgs/logos/modion_header.png" alt="" class="mdnlogo"/>
	<div class="single-page rounded">

		<xsl:choose>
			<xsl:when test="$step = 1">

				<div class="floatFix">
					
						<div class="block">
							<h2>Instalación inicial</h2>
							<p>
								Antes de empezar es necesario configurar un par de datos básicos, que es la conexión a la base de datos y un usuario administrador.
								<br/>
								Completa los campos a continuación para empezar a usar el sistema.
							</p>
						</div>

						<form name="install" action="{$page_url}" method="post">
							
							<div class="left">
								<div class="block">
									<h3>Información del sistema</h3>
									<label>Nombre de la aplicación</label>
									<input type="text" name="app_name" value="{$config/system/applicationID}" />

									<label>Dominio</label>
									<input type="text" name="app_url" value="http://{$domain}" />

									<label>Directorio Admin</label>
									<input type="text" name="adminpath" value="{/xml/configuration/system/adminpath}" />
									<small>Si cambias este valor asegurate que la carpeta exista</small>

								</div>

								<div class="block">
									<h3>Base de datos</h3>
									
									<label>Host</label>
									<input type="text" name="database_host" value="{$config/system/database/host}" />

									<label>Nombre de la base de datos</label>
									<input type="text" name="database_name" value="{$config/system/database/dbname}" />

									<label>Usuario</label>
									<input type="text" name="database_user" value="{$config/system/database/user}" />

									<label>Contraseña</label>
									<input type="text" name="database_pass" value="{$config/system/database/pass}" />
								</div>
							</div>
							<div class="right">
								<div class="block">
									<h3>Usuario Administrador</h3>
									<label>Username</label>
									<input type="text" name="username" value="admin" />

									<label>Contraseña</label>
									<input type="password" name="user_password" value="" />

									<label>Nombre</label>
									<input type="text" name="user_name" value="" />

									<label>Apellido</label>
									<input type="text" name="user_lastname" value="" />

									<label>Email</label>
									<input type="text" name="user_email" value="" />
								</div>
							</div>

							<div class="continue">
								<button type="submit" class="btn btn-primary">Continuar</button>
							</div>
						</form>
				</div>
			</xsl:when>



			<xsl:otherwise>
				<div class="block">
					<h2>Instalación inicial</h2>
					<p>
						La instalación se realizó correctamente.
					</p>
					<div class="continue">
						<a href="{/xml/configuration/system/adminpath}login" class="btn">Login</a>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>

		

		
	</div>

	<!-- <xsl:call-template name="debug" /> -->
</body>
</html>

</xsl:template>


</xsl:stylesheet>