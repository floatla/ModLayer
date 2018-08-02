<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />


<!-- 
	Este parametro se usa para poder imprimir correctamente 
	el trackPageview de google analytics con la categoria
	de la nota y poder tener estadisticas por seccion
-->
<xsl:param name="isArticle" />
<xsl:param name="eplanning" />

<xsl:template match="/xml">
	<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html lang="es">
	<head>
		<xsl:call-template name="htmlHead" />
		


		<!-- ACA VA EL ANALYTICS!!! -->
		<!-- ACA VA EL ANALYTICS!!! -->
		<!-- ACA VA EL ANALYTICS!!! -->
		<!-- ACA VA EL ANALYTICS!!! -->
		<!-- ACA VA EL ANALYTICS!!! -->




	</head>
	<body>
		<xsl:copy-of select="$eplanning" />
		<div id="fb-root" style="height:0">&#xa0;</div>
		<script><!-- 
		 -->window.fbAsyncInit = function() { <!-- 
			 -->FB.init({ <!-- 
				 -->appId : '2250597608299564',<!--  // App ID 
				 -->channelUrl : '//www.vind.com.ar/channel.html',<!-- // Channel File 
				 -->xfbml      : true,<!-- // parse XFBML 
				 -->version    : 'v2.8'<!--
				 status : true,  // check login status 
				 cookie : true,  // enable cookies to allow the server to access the session
			 -->});<!-- 
		 -->};<!--
		--><xsl:text disable-output-escaping="yes"><!-- 
			 -->(function(d, s, id) {<!-- 
					 -->var js, fjs = d.getElementsByTagName(s)[0];<!-- 
					 -->if (d.getElementById(id)) return;<!-- 
					 -->js = d.createElement(s); js.id = id;<!-- 
					 -->js.src = "//connect.facebook.net/es_LA/sdk.js";<!-- 
					 -->fjs.parentNode.insertBefore(js, fjs);<!-- 
					 -->}(document, 'script', 'facebook-jssdk'));<!-- 
			 --></xsl:text><!--
	--></script>
		<!-- <xsl:call-template name="topHeader" /> -->
		<xsl:call-template name="header" />
		
		<!-- Agregado para moviles -->
		<xsl:if test="$config/client/name != 'desktop' and $config/client/name != 'ipad' and $config/client/name != 'galaxy'">
			<div id="body" class="container">
				<script type="text/javascript" src="{$skinpath}/js/mobile.alert.js">&#xa0;</script>
				
				<div class="mobile-alert top" id="mobileText">
					Estás visualizando la versión de escritorio desde un dispositivo móvil. 
					<a href="{$config/system/domain}/clear-desktop/" class="btn">Ver para móviles</a>
					<!-- <a href="#" class="btn dark" onclick="closeReminder();return false;">No recordarme</a> -->
				</div>
			</div>
		</xsl:if>
		<!-- Agregado para moviles -->

		<xsl:call-template name="content" />

		<!-- Agregado para moviles -->
		<xsl:if test="$config/client/name != 'desktop' and $config/client/name != 'ipad' and $config/client/name != 'galaxy'">
			 <div class="mobile-alert">
				Estás visualizando la versión de escritorio desde un dispositivo móvil. 
				<a href="{$config/system/domain}/clear-desktop/" class="btn">Ver para móviles</a>
			</div>
		</xsl:if>
		<!-- Agregado para moviles -->
			
		<xsl:call-template name="footer" />

		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>
	</body>
	<xsl:comment>Diseño y Desarrollo: FLOAT.LA (http://www.float.la)</xsl:comment>
</html>
</xsl:template>





</xsl:stylesheet>