<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>

<xsl:param name="ytplay" />
<xsl:variable name="clip" select="/xml/content/clip" />
<xsl:variable name="poster">
	<xsl:call-template name="image.src">
		<xsl:with-param name="id" select="$clip/multimedias/images/image/@image_id" />
		<xsl:with-param name="type" select="$clip/multimedias/images/image/@type" />
	</xsl:call-template>
</xsl:variable>

<xsl:template match="/xml">
	<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
			<title><xsl:value-of select="$language/modal/preview/head_title" /></title>
			<xsl:call-template name="htmlHead" />
			
			<xsl:call-template name="include.css">
				<xsl:with-param name="url">
					<xsl:value-of select="$modPath"/>/ui/css/video-js.min.css
					<xsl:value-of select="$modPath"/>/ui/css/videojs-playlist-ui.vertical.css
					<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
					<xsl:value-of select="$modPath"/>/ui/css/clip.css
				</xsl:with-param>
			</xsl:call-template>
		</head>
		<body class="body_panel">
			<header>
				<a href="#" onclick="parent.sidepanel.close();return false;" class="right btn"><xsl:value-of select="$language/modal/preview/btn_close" /></a>
				<h3><xsl:value-of select="$language/modal/preview/title" /></h3>
			</header>

			<section class="panel-body" style="height:95%;min-height:auto;">
				<div class="video"><xsl:comment /></div>
				<xsl:if test="$debug = 1">
					<xsl:call-template name="debug" />
				</xsl:if>
			</section>
			<script> 
				var jsPlayer = {};
				requirejs(['clip/ui/js/player'], function(player){ 
					jsPlayer = player;
					jsPlayer.modpath    = "<xsl:value-of select="$modPath" />";
					jsPlayer.youtubeURL = "<xsl:value-of select="$clip/youtube" />";
					jsPlayer.toggle(<xsl:value-of select="$clip/@id" />,"<xsl:value-of select="$poster" />");
				});
		    </script>
		</body>
	</html>
</xsl:template>

<xsl:template name="videofile"><!--
 --><xsl:param name="id" /><!--
 --><xsl:param name="type" /><!--
 --><xsl:value-of select="$config/system/images_domain"/><!-- 
 --><xsl:if test="$config/system/domain/@subdir">/<xsl:value-of select="$config/system/domain/@subdir" /></xsl:if><!-- 
 -->/<xsl:value-of select="$context/video_configuration/module/options/group[@name='repository']/option[@name='target']/@value"/><!-- 
 -->/<xsl:value-of select="substring($id,string-length($id),1)"/><!-- 
 -->/<xsl:value-of select="$id"/>.<xsl:value-of select="$type"/><!-- 
--></xsl:template>

</xsl:stylesheet>