<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="error" />
<xsl:param name="nota_id" />
<xsl:param name="mensaje" />
<xsl:variable name="page" select="/xml/content/page" />

<xsl:variable name="htmlHeadExtra"></xsl:variable>
<xsl:variable name="title">
	<xsl:choose>
		<xsl:when test="/xml/content/page/title != ''">
			<xsl:value-of select="$page/title" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$page/titulo" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="descripcion">
	<xsl:call-template name="limit.string">
		<xsl:with-param name="string" select="$page/summary" />
		<xsl:with-param name="limit">250</xsl:with-param>
	</xsl:call-template>
</xsl:variable>

<xsl:variable name="dinamicHead">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><xsl:value-of select="$page/title" /> | <xsl:value-of select="$config/system/applicationID" /></title>
	<xsl:apply-templates select="$config/skin/header/*[not(name()='title')]" mode="htmlhead"/>
	<meta name="title" content="{$title}" />
	<meta property="og:title" content="{$title}"/>
	<meta property="og:description" content="{$descripcion}"/>
	<meta property="og:image">
		<xsl:attribute name="content"><xsl:value-of select="$config/system/domain" /><!-- 
			 --><xsl:call-template name="image.bucket.src">
				<xsl:with-param name="id" select="$page/multimedias/images/image/@image_id" />
				<xsl:with-param name="type" select="$page/multimedias/images/image/@type" />
			</xsl:call-template>
		</xsl:attribute>
	</meta>
    <meta property="og:type" content="article"/>
	<meta name="medium" content="news" />
</xsl:variable>




<xsl:template name="content">

	<div class="container page floatFix">

		<h1><xsl:value-of select="content/page/title" /></h1>
		<xsl:apply-templates select="content/page/content" />
		
	</div>
</xsl:template>







</xsl:stylesheet>