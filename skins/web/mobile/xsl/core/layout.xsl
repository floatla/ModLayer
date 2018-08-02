<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />


<xsl:param name="isArticle" />
<xsl:param name="eplanning" />

<xsl:template match="/xml">
	<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html>
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
		<div id="page">
			<section id="container" class="floatFix">
				<section class="content">
					<xsl:call-template name="content" />
				</section>
				<div class="desktop-link">
					<p>Estás visualizando la versión móvil</p>
					<a href="{$config/system/domain}/set-desktop/" class="btn">Ver versión de escritorio</a>
				</div>
			</section>
			<xsl:call-template name="header" />
			<nav id="menu">
				
				<xsl:call-template name="menu.navigation">
					<xsl:with-param name="menus" select="$context/menus/menu[@menu_id=1]/menus" />
				</xsl:call-template>
				
				<xsl:call-template name="footer" />
			</nav>
		</div>
		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>
	</body>
	<xsl:comment>Diseño y Desarrollo: FLOAT.LA (http://www.float.la)</xsl:comment>
</html>
</xsl:template>





</xsl:stylesheet>