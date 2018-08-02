<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template match="m_audio">
	<xsl:variable name="audio_id" select="@id" />
	<xsl:variable name="audio" select="/xml/content/*/multimedias/audios/audio[@audio_id = $audio_id]" />
	<section class="audio-embeded">
		<span class="right">
			<xsl:call-template name="audio.player">
				<xsl:with-param name="audio_id" select="$audio/@audio_id" />
				<xsl:with-param name="type" select="$audio/@type" />
			</xsl:call-template>
		</span>
		<h4><small>Audio: </small><xsl:value-of select="$audio/title" /></h4>
		<xsl:value-of select="$audio/content" disable-output-escaping="yes" />
	</section>
</xsl:template>

<xsl:template name="audio.player">
	<xsl:param name="audio_id" />
	<xsl:param name="type" />
	<xsl:param name="container_id">audio_container</xsl:param>
	
	<xsl:variable name="audiosource"><!--
		--><xsl:call-template name="audio.src"><!--
			--><xsl:with-param name="audio_id" select="$audio_id" /><!--
			--><xsl:with-param name="type" select="$type" /><!--
		--></xsl:call-template><!--
	--></xsl:variable>

	<xsl:choose>
		<xsl:when test="($config/client/name != 'ipad') and ($config/client/name != 'iphone')">
			<object width="265" height="24">
				<param name="movie" value="{$skinpath}/js/jwplayer/player.swf"></param>
				<param name="allowFullScreen" value="true"></param>
				<param name="allowscriptaccess" value="always"></param>
				<param name="flashvars" value="file={$audiosource}&amp;provider=sound"></param>
				<embed 
					src="{$skinpath}/js/jwplayer/player.swf" 
					type="application/x-shockwave-flash" 
					allowscriptaccess="always" 
					flashvars="file={$audiosource}&amp;provider=sound"
					width="265" 
					height="24">
				</embed>
			</object>
		</xsl:when>
		<xsl:otherwise>
			<audio />
		</xsl:otherwise>
	</xsl:choose>
	
	<!-- <script type="text/javascript">
		jwplayer("<xsl:value-of select="$container_id" />").setup({
			flashplayer: "<xsl:value-of select="$skinpath"/>/js/jwplayer/player.swf",
			file: "<xsl:value-of select="$audiosource"/>",
			width: 265,
			height: 24
		});
	</script> -->
</xsl:template>

<xsl:template name="audio.src">
	<xsl:param name="audio_id" />
	<xsl:param name="type" /><!--
	--><xsl:value-of select="$config/system/content_domain" />/<!--
	--><xsl:if test="$config/system/domain/@subdir">/<xsl:value-of select="$config/system/domain/@subdir" /></xsl:if><!-- 
	-->/<xsl:value-of select="$context/audio_dir/option/@value" />/<!--
	--><xsl:value-of select="substring($audio_id, string-length($audio_id),1)" />/<!--
	--><xsl:value-of select="$audio_id" />.<xsl:value-of select="$type" /><!--
--></xsl:template>


</xsl:stylesheet>