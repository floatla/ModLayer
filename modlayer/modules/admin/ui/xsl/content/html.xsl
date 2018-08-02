<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<!-- Elementos del sistema -->
<xsl:template match="recuadro">
	<recuadro>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</recuadro>
</xsl:template>

<xsl:template match="m_audio">
	<m_audio>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</m_audio>
</xsl:template>

<xsl:template match="m_document">
	<m_document>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</m_document>
</xsl:template>

<xsl:template match="m_clip">
	<m_clip>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</m_clip>
</xsl:template>

<xsl:template match="m_poll">
	<m_poll>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</m_poll>
</xsl:template>

<xsl:template match="m_image[*]">
	<m_image>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</m_image>
</xsl:template>

<xsl:template match="m_gallery_embed">
	<m_gallery_embed>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</m_gallery_embed>
</xsl:template>

<xsl:template match="external">
	<xsl:variable name="uid" select="@uid" />
	<xsl:if test="count($content/object/assets/asset[uid = $uid]) = 1">
		<external id="a-{@uid}" uid="{@uid}">
			<span>Contenido externo embebido. </span>
		</external>
	</xsl:if>
</xsl:template>

<!-- HTML TEMPLATES -->

<xsl:template match="p|P">
	<p>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="b|strong">
	<strong>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</strong>
</xsl:template>

<xsl:template match="i|em">
	<em>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</em>
</xsl:template>

<xsl:template match="span">
	<span>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="a|A">
	<a>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</a>
</xsl:template>

<xsl:template match="img">
	<img>
		<xsl:if test="@src"><xsl:attribute name="src"><xsl:value-of select="@src" /></xsl:attribute></xsl:if>
		<xsl:if test="@class"><xsl:attribute name="class"><xsl:value-of select="@class" /></xsl:attribute></xsl:if>
		<xsl:if test="@width"><xsl:attribute name="width"><xsl:value-of select="@width" /></xsl:attribute></xsl:if>
		<xsl:if test="@height"><xsl:attribute name="height"><xsl:value-of select="@height" /></xsl:attribute></xsl:if>
		<xsl:if test="@alt"><xsl:attribute name="alt"><xsl:value-of select="@alt" /></xsl:attribute></xsl:if>
	</img>
</xsl:template>

<xsl:template match="br">
	<br/>
</xsl:template>

<xsl:template match="h1|h2|h3|h4|h5">
	<xsl:element name="{name()}">
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="iframe">
	<iframe>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />&#xa0;
	</iframe>
	<!-- <xsl:copy-of select="." /> -->
</xsl:template>

<xsl:template match="div">
	<div>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="ul">
	<ul>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</ul>
</xsl:template>

<xsl:template match="ol">
	<ol>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</ol>
</xsl:template>

<xsl:template match="li">
	<li>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</li>
</xsl:template>

<xsl:template match="blockquote">
	<blockquote>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
	</blockquote>
</xsl:template>

<xsl:template match="object">
	<xsl:copy-of select="." />
</xsl:template>

<xsl:template match="embed">
	<xsl:copy-of select="." />
</xsl:template>

<xsl:template match="@*" mode="atts">
	<xsl:attribute name="{name()}"><xsl:value-of select="." /></xsl:attribute>
</xsl:template>

<xsl:template match="text()">
	<xsl:if test="contains(., '/#')">
		--- <xsl:value-of select="*[name() = substring-before(substring-after(., '/#'), '#/')]"/>
	</xsl:if>
	<xsl:value-of select="." disable-output-escaping="yes" />
</xsl:template>






</xsl:stylesheet>