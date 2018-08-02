<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
<xsl:param name="calendar" />
<xsl:param name="type" />

<xsl:variable name="htmlHeadExtra">

	<!-- <xsl:call-template name="js.cal" />
	<xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$adminPath"/>/ui/js/module.edit.js
			<xsl:value-of select="$modPath"/>/ui/js/import.js
		</xsl:with-param>
	</xsl:call-template> -->

	<xsl:call-template name="tiny_mce.src" />
	<xsl:call-template name="tiny_mce.simple">
		<xsl:with-param name="elements">#clip_summary</xsl:with-param>
	</xsl:call-template>

</xsl:variable>

<xsl:template name="content">

	<xsl:variable name="object" select="$content/object" />
	<xsl:variable name="html">
		<ul class="form">
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/clip_title"/></label>
				<input type="text" maxlength="200" name="clip_title" value="{$object/title}"/>
			</li>
			<li class="youtube-holder" style="position:relative;">
				<label>
					<xsl:value-of select="$language/item_editor/labels/youtube_url"/>
					<xsl:if test="$object/youtube != ''">
						<a onclick="appUI.OpenPanel(this.href);return false;" class="btn" href="{$adminroot}?m=clip&amp;action=RenderPreview&amp;id={$object/@id}&amp;ytplay=1"><xsl:value-of select="$language/item_editor/labels/btn_preview"/></a>
					</xsl:if>
				</label>
				<input type="text" name="clip_youtube" value="{$object/youtube}" id="youtubeURL" />
			</li>
			<!-- <li class="vimeo-holder" style="position:relative;">
				<label>
					Vimeo url
					<xsl:if test="$object/vimeo != ''">
						<a onclick="sidepanel.load(this);return false;" class="btn" href="{$adminroot}?m=clip&amp;action=RenderPreview&amp;id={$object/@id}&amp;service=vimeo">Preview</a>
					</xsl:if>
				</label>
				<input type="text" name="clip_vimeo" value="{$object/vimeo}" id="vimeoURL" onchange="clip.importClipData(this,'vimeo');"/>
			</li> -->
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/clip_summary"/></label>
				<textarea name="clip_summary" id="clip_summary" class="mceSimple">
					<xsl:apply-templates select="$object/summary" />

					<xsl:comment />
				</textarea>
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/clip_keywords"/></label>
				<input type="text" maxlength="200" name="keywords" value="{$object/keywords}"/>
			</li>
		</ul>
	</xsl:variable>

	<xsl:call-template name="display.item.edit">
		<xsl:with-param name="object" select="$object" />
		<xsl:with-param name="id_field" select="'clip_id'" />
		<xsl:with-param name="html" select="$html" />
	</xsl:call-template>

</xsl:template>
</xsl:stylesheet>