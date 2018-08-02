<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
<xsl:param name="calendar" />
<xsl:param name="type" />

<xsl:variable name="htmlHeadExtra">


	<xsl:call-template name="tiny_mce.src" />
	<xsl:call-template name="TinyMce">
		<xsl:with-param name="elements">#page_content</xsl:with-param>
		<xsl:with-param name="item_id" select="$content/object/@id" />
		<xsl:with-param name="item_module" select="$content/object/module" />
	</xsl:call-template>

</xsl:variable>

<xsl:template name="content">

	<xsl:variable name="object" select="$content/object" />
	<xsl:variable name="html">
		<ul class="form addNota">
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/page_title"/></label>
				<input type="text" maxlength="200" name="page_title" value="{$object/title}"/>
				<!-- <span class="air right">slug: <xsl:value-of select="$object/url" /></span> -->
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/page_url"/></label>
				<input type="text" maxlength="200" name="page_url" value="{$object/url}" placeholder="{$language/item_editor/labels/page_url_placeholder}"/>
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/page_content"/></label>
				<textarea name="page_content" id="page_content">
					<xsl:apply-templates select="$object/content"/>
					<xsl:comment />
				</textarea>
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/page_tags"/></label>
				<input type="text" name="page_tags" value="{$object/tags}" placeholder="{$language/item_editor/labels/tags_placeholder}"/>
			</li>
		</ul>
	</xsl:variable>


	<xsl:call-template name="display.item.edit">
		<xsl:with-param name="object" select="$object" />
		<xsl:with-param name="id_field" select="'page_id'" />
		<xsl:with-param name="html" select="$html" />
	</xsl:call-template>

</xsl:template>
</xsl:stylesheet>