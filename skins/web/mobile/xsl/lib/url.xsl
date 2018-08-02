<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<!--URLS-->

<xsl:template name="video.url">
	<xsl:param name="id" />
	<xsl:param name="titulo" />
	<xsl:variable name="videotitulo">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$titulo" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/videos/<xsl:value-of select="$id"/>/<xsl:value-of select="$videotitulo" />
</xsl:template>



<xsl:template name="article.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="article_title">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/article/<xsl:value-of select="$id"/>/<xsl:value-of select="$article_title" />
</xsl:template>

<xsl:template name="suple.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="article_title">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/suple/<xsl:value-of select="$id"/>/<xsl:value-of select="$article_title" />
</xsl:template>

<xsl:template name="tapa.url">
	<xsl:param name="id" />
	<xsl:param name="date" />
	<xsl:variable name="day" select="substring($date, 9, 2)" />
	<xsl:variable name="month" select="substring($date, 6, 2)" />
	<xsl:variable name="year" select="substring($date, 1, 4)" />

	<xsl:value-of select="/xml/configuration/system/domain"/>/tapa/<xsl:value-of select="$id"/>/edicion-del-<xsl:value-of select="$day" />-<xsl:value-of select="$month" />-<xsl:value-of select="$year" />
</xsl:template>

<xsl:template name="person.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="title">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/person/<xsl:value-of select="$id"/>/<xsl:value-of select="$title" />
</xsl:template>

<xsl:template name="columnista.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="title">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/columnista/<xsl:value-of select="$id"/>/<xsl:value-of select="$title" />
</xsl:template>

<xsl:template name="author.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="title">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/autor/<xsl:value-of select="$id"/>/<xsl:value-of select="$title" />
</xsl:template>

<xsl:template name="gallery.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="notatitulo">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/gallery/<xsl:value-of select="$id"/>/<xsl:value-of select="$notatitulo" />
</xsl:template>

<xsl:template name="tag.url">
	<xsl:param name="tag" />
	<xsl:variable name="tag_name">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$tag/tag_name" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/t<xsl:value-of select="$tag/@tag_id"/>-<xsl:value-of select="$tag_name" />
</xsl:template>




</xsl:stylesheet>