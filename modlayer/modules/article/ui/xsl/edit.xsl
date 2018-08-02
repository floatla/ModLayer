<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
<xsl:param name="calendar" />
<xsl:param name="type" />
<xsl:param name="person" />

<xsl:variable name="htmlHeadExtra">
    <script>
		jsAssets = {}; 
		jsAutosave = {}; 
		requirejs(['article/ui/js/assets', 'article/ui/js/autosave'], function(Assets, Autosave){ 
			jsAssets = Assets; jsAutosave = Autosave;
			<xsl:for-each select="$content/object/assets/asset">
				jsAssets.put(<xsl:value-of select="uid"/>);
			</xsl:for-each>
			<xsl:if test="$config/module/options/group[@name='settings']/option[@name='autosave']/@value = 'true'">
				Autosave.BindActions();
			</xsl:if>
		});
	</script>
	<xsl:call-template name="tiny_mce.src" />
	<xsl:call-template name="tiny_mce.simple">
		<xsl:with-param name="elements">#article_summary</xsl:with-param>
	</xsl:call-template>
	<!-- <xsl:call-template name="TinyMce"> -->
	<xsl:call-template name="TinyMce">
		<xsl:with-param name="elements">#article_content</xsl:with-param>
		<xsl:with-param name="item_id" select="$content/object/@id" />
		<xsl:with-param name="item_module" select="$content/object/module" />
	</xsl:call-template>

</xsl:variable>

<xsl:template name="content">

	<xsl:variable name="object" select="$content/object" />
	<xsl:variable name="html">
		<ul class="form">
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/article_title"/></label>
				<input type="text" maxlength="200" name="article_title" value="{$object/title}" autofocus="autofocus" />
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/article_header"/></label>
				<input type="text" name="article_header" value="{$object/header}"/>
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/article_summary"/></label>
				<textarea name="article_summary" id="article_summary" class="mceSimple">
					<xsl:apply-templates select="$object/summary" />
					<xsl:comment />
				</textarea>
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/article_content"/></label>
				<xsl:text disable-output-escaping="yes"><!-- 
					 -->&lt;textarea name="article_content" id="article_content" class="mceAdvanced"&gt;<!-- 
				--></xsl:text><!-- 
				--><xsl:apply-templates select="$object/content"/><!-- 
				--><xsl:text disable-output-escaping="yes">&lt;/textarea&gt;</xsl:text>
			</li>
			<li data-role="tags">
				<label><xsl:value-of select="$language/item_editor/labels/article_tags"/></label>
				<xsl:for-each select="$object/tags/tag">
					<span class="m_tag" tag_id="{@tag_id}">
						<span><xsl:value-of select="tag_name"/></span>
						<a href="#" tag_id="{@tag_id}" onclick="return false;" class="remove">&#xa0;</a>
					</span>
				</xsl:for-each>
				<input type="text" name="" value="" class="AutocompleteTag" placeholder="{$language/item_editor/labels/tags_placeholder}"/>
			</li>
			<li>
				<label><xsl:value-of select="$language/item_editor/labels/article_slug"/></label>
				<input type="text" name="slug" value="{$object/slug}" placeholder="{$language/item_editor/labels/slug_placeholder}"/>
			</li>
		</ul>
	</xsl:variable>


	<xsl:call-template name="display.item.edit">
		<xsl:with-param name="object" select="$object" />
		<xsl:with-param name="id_field" select="'article_id'" />
		<xsl:with-param name="html" select="$html" />
		<xsl:with-param name="preview"><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/preview/<xsl:value-of select="$object/@id"/></xsl:with-param>
		<xsl:with-param name="latname">article_latitud</xsl:with-param>
		<xsl:with-param name="lngname">article_longitud</xsl:with-param>
	</xsl:call-template>

</xsl:template>
</xsl:stylesheet>