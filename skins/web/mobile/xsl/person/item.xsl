<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="person" select="/xml/content/person" />

<xsl:variable name="title">
	<xsl:choose>
		<xsl:when test="$person/metatitle != ''">
			<xsl:value-of select="$person/metatitle" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$person/title" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="itemDescription">
	<xsl:choose>
		<xsl:when test="$person/metadescription != ''">
			<xsl:value-of select="$person/metadescription" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="limit.string">
				<xsl:with-param name="string" select="/xml/content/person/summary" />
				<xsl:with-param name="limit">250</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="itemURL">
	<xsl:call-template name="person.url">
		<xsl:with-param name="id" select="$person/@id" />
		<xsl:with-param name="title" select="$person/title" />
	</xsl:call-template>
</xsl:variable>

<xsl:variable name="dinamicHead">
	<title><xsl:value-of select="$title" /> | <xsl:value-of select="$config/system/applicationID" /></title>
	<meta name="description" content="{$itemDescription}" />
	<xsl:apply-templates select="$config/skin/header/*[not(name()='title')][not(@name='description')]" mode="htmlhead"/>
	
	<!-- <link rel="canonical" href="{$itemURL}" /> -->
	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:site" content="@vindcms" />
	<meta property="og:title" content="{$title}"/>
	<meta property="og:description" content="{$itemDescription}"/>
	<meta property="og:image">
		<xsl:attribute name="content">
			<xsl:call-template name="image.bucket.src">
				<xsl:with-param name="id" select="$person/multimedias/images/image/@image_id" />
				<xsl:with-param name="type" select="$person/multimedias/images/image/@type" />
				<xsl:with-param name="width">620</xsl:with-param>
				<xsl:with-param name="height">450</xsl:with-param>
			</xsl:call-template>
		</xsl:attribute>
	</meta>
	<!-- <meta property="fb:admins" content="567857997"/> -->
	<meta property="fb:app_id" content="2250597608299564"/>
	<meta property="og:url" content="{$itemURL}"/>
	<meta property="og:type" content="person"/>
	<meta property="og:site_name" content="vind.com.ar"/>
	
	<xsl:variable name="sanitized">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="$person/categories/group/category/name"/>
		</xsl:call-template>
	</xsl:variable>
</xsl:variable>


<xsl:template name="content">
	<div class="container floatFix">
		Ficha de Persona
		<xsl:comment/>
	</div>
</xsl:template>

</xsl:stylesheet>