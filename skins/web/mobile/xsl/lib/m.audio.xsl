<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template match="m_audio">
	<xsl:variable name="audio_id" select="@id" />
	<xsl:if test="/xml/content/*/multimedias/audios/audio[@audio_id = $audio_id]">
		<xsl:variable name="audio" select="/xml/content/*/multimedias/audios/audio[@audio_id = $audio_id]" />
		<div class="m_audio">
			<xsl:call-template name="audio.player">
				<xsl:with-param name="audio" select="$audio" />
			</xsl:call-template>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template name="audio.player">
	<xsl:param name="audio" />
	<xsl:param name="audio_id" select="$audio/@audio_id" />
	<xsl:param name="type" select="$audio/@type" />
	
	<xsl:variable name="audiosource"><!--
		--><xsl:call-template name="audio.src"><!--
			--><xsl:with-param name="audio_id" select="$audio_id" /><!--
			--><xsl:with-param name="type" select="$type" /><!--
		--></xsl:call-template><!--
	--></xsl:variable>

	<!-- <div  class="audioPlayer">&#xa0;</div> -->
	<div id="jquery_jplayer_{$audio_id}" class="jp-jplayer" data-src="{$audiosource}" data-id="{$audio_id}" data-title="{$audio/title}"><xsl:comment /></div>
	<div id="jp_container_{$audio_id}" class="jp-audio" role="application" aria-label="media player">
		<div class="jp-type-single">
			<div class="jp-gui jp-interface">
				<div class="jp-controls">
					<div class="jp-play" role="button" tabindex="0" title="Reproducir / Pausar">
						<i class="fa fa-play"><xsl:comment /></i>
						<i class="fa fa-pause"><xsl:comment /></i>
					</div>
					<div class="jp-stop" role="button" tabindex="0" title="Detener">
						<i class="fa fa-square"><xsl:comment /></i>
					</div>
					<!-- <button class="jp-play" role="button" tabindex="0">play</button> -->
					<!-- <button class="jp-stop" role="button" tabindex="0">stop</button> -->
				</div>
				<div class="jp-progress">
					<div class="jp-seek-bar">
						<div class="jp-play-bar"><xsl:comment /></div>
					</div>
				</div>
				<div class="jp-volume-controls">
					<div class="jp-mute" title="Silenciar">
						<i class="fa fa-volume-off"><xsl:comment /></i>
						<i class="fa fa-volume-up"><xsl:comment /></i>
					</div>
					<div class="jp-volume-max" title="Volumen máximo">
						<i class="fa fa-volume-up"><xsl:comment /></i>
					</div>
					<!-- <button class="jp-mute" role="button" tabindex="0">mute</button> -->
					<!-- <button class="jp-volume-max" role="button" tabindex="0">max volume</button> -->
					<div class="jp-volume-bar">
						<div class="jp-volume-bar-value"><xsl:comment /></div>
					</div>
				</div>
				<div class="jp-time-holder">
					<div class="jp-current-time" role="timer" aria-label="time">&#xa0;</div>
					<div class="jp-duration" role="timer" aria-label="duration">&#xa0;</div>
					<div class="jp-toggles">
						<div class="jp-repeat" role="button" tabindex="0" title="Reproducción en bucle">
							<i class="fa fa-refresh"><xsl:comment /></i>
						</div>
						<!-- <button class="jp-repeat" role="button" tabindex="0">repeat</button> -->
					</div>
				</div>
			</div>
			<div class="jp-details">
				<div class="jp-title" aria-label="title">&#xa0;</div>
			</div>
			<div class="jp-no-solution">
				<span>Update Required</span>
				To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
			</div>
		</div>
	</div>
	<!-- <xsl:choose>
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
	</xsl:choose> -->
	

</xsl:template>

<xsl:template name="audio.src">
	<xsl:param name="audio_id" />
	<xsl:param name="type" /><!--
	--><xsl:value-of select="$config/system/content_domain" /><!--
	--><xsl:if test="$config/system/domain/@subdir">/<xsl:value-of select="$config/system/domain/@subdir" /></xsl:if><!-- 
	-->/<xsl:value-of select="$context/audio_dir/option/@value" />/<!--
	--><xsl:value-of select="substring($audio_id, string-length($audio_id),1)" />/<!--
	--><xsl:value-of select="$audio_id" />.<xsl:value-of select="$type" /><!--
--></xsl:template>


</xsl:stylesheet>