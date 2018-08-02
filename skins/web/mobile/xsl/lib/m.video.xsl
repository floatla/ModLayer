<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />



<xsl:template match="m_clip">
	<xsl:variable name="id" select="@id" />
	<xsl:variable name="clip" select="/xml/content/*/relations/clips/clip[@id = $id]" />
	<xsl:variable name="clip_img">
		<xsl:call-template name="image.bucket.src">
			<xsl:with-param name="id" select="$clip/multimedias/images/image/@image_id" />
			<xsl:with-param name="type" select="$clip/multimedias/images/image/@type" />
		</xsl:call-template>
	</xsl:variable>
	<video id="video_{@id}" class="video-js vjs-default-skin vjs-16-9 vjs-big-play-centered" controls="true" preload="auto" width="640" height="264" poster="{$clip_img}" data-id="{@id}">
		<xsl:choose>
			<xsl:when test="$clip/youtube != ''">
				<source src="{$clip/youtube}" type="video/youtube"/>
			</xsl:when>
			<xsl:otherwise>
				<source>
					<xsl:attribute name="src">
						<xsl:call-template name="video.src">
							<xsl:with-param name="id" select="$clip/multimedias/videos/video/@video_id" />
							<xsl:with-param name="type" select="$clip/multimedias/videos/video/@type" />
						</xsl:call-template>
					</xsl:attribute>
				</source>
			</xsl:otherwise>
		</xsl:choose>
	</video>
</xsl:template>

<!-- <xsl:template name="video.player">
	<xsl:param name="clip" />
	<xsl:param name="width">620</xsl:param>
	<xsl:param name="height">348</xsl:param>
	<xsl:param name="container_id">video_container</xsl:param>

	<xsl:variable name="poster">
		<xsl:call-template name="image.bucket.src">
			<xsl:with-param name="id" select="$clip/multimedias/images/image/@image_id" />
			<xsl:with-param name="type" select="$clip/multimedias/images/image/@type" />
			<xsl:with-param name="width" select="$width" />
			<xsl:with-param name="height" select="$height" />
			<xsl:with-param name="crop">c</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<div class="player">
		<div id="container_{$container_id}" class="video_frame">
			<img src="{$poster}" width="100%" height="100%" alt=""/>
			<xsl:choose>
				<xsl:when test="$clip/youtube != ''">
					<meta name="youtube" content="{$clip/youtube}" />
				</xsl:when>
				<xsl:otherwise>
					<meta name="source">
						<xsl:attribute name="content">
							<xsl:call-template name="video.src">
								<xsl:with-param name="id" select="$clip/multimedias/videos/video/@video_id" />
								<xsl:with-param name="type" select="$clip/multimedias/videos/video/@type" />
							</xsl:call-template>
						</xsl:attribute>
					</meta>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</div>
	<script type="text/javascript">
		player.toggle('<xsl:value-of select="$container_id" />');
	</script>
</xsl:template> -->

<xsl:template name="video.src"><!-- 
	 --><xsl:param name="id" /><!--
	 --><xsl:param name="type" /><!--
	 --><xsl:value-of select="$config/system/content_domain"/><!-- 
	 --><xsl:if test="$config/system/domain/@subdir">/<xsl:value-of select="$config/system/domain/@subdir" /></xsl:if><!-- 
	 -->/<xsl:value-of select="$context/video_dir/option/@value"/><!-- 
	 -->/<xsl:value-of select="substring($id,string-length($id),1)"/><!-- 
	 -->/<xsl:value-of select="$id"/>.<xsl:value-of select="$type"/><!-- 
 --></xsl:template>


</xsl:stylesheet>