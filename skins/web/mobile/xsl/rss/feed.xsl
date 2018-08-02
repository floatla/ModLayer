<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes" xmlns:content="http://purl.org/rss/1.0/modules/content/"/>

<xsl:param name="feedDate" />

<xsl:template match="/xml">
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
	    <title><xsl:value-of select="$config/system/applicationID" /></title>
	    <link><xsl:value-of select="$config/system/domain" />/</link>
	    <description><xsl:value-of select="$config/skin/header/meta[@name='description']/@content" /></description>
	    <language>es</language>
	    <pubDate><xsl:value-of select="$feedDate" /></pubDate>
	    <generator>ModLayer*</generator>
	    <image>
	    	<title><xsl:value-of select="$config/system/applicationID" /></title>
			<url><xsl:value-of select="$config/system/domain" /><xsl:value-of select="$skinpath" />/imgs/logos/header.gif</url>
			<link><xsl:value-of select="$config/system/domain" />/</link>
		</image>
		<atom:link href="{$config/system/domain}/rss/feed/" rel="self" type="application/rss+xml" />
		<xsl:for-each select="content/feed/article">
		    <item>
				<title><xsl:value-of select="title" /></title>
				<link><xsl:value-of select="$config/system/domain" />/article/<xsl:value-of select="@id" />/<xsl:value-of select="object_shorttitle" />?utm_source=feed&amp;utm_medium=rss&amp;utm_term=rss&amp;utm_campaign=Rss%20Feed</link>
				<description><!-- 
					 --><xsl:text disable-output-escaping="yes"><!-- 
					     -->&lt;![CDATA[<!-- 
					 --></xsl:text><!-- 
						 --><xsl:apply-templates select="summary" /><!-- 
					 --><xsl:text disable-output-escaping="yes"><!-- 
					     -->]]&gt;<!-- 
					  --></xsl:text><!-- 
				 --></description>
				<content:encoded><!-- 
					 --><xsl:text disable-output-escaping="yes"><!-- 
					     -->&lt;![CDATA[<!-- 
					 --></xsl:text><!-- 
					 --><xsl:if test="oldid != '' and multimedias/photos/photo">
							<xsl:call-template name="photo">
								<xsl:with-param name="id" select="multimedias/photos/photo/@photo_id" />
								<xsl:with-param name="suffix">_l</xsl:with-param>
								<xsl:with-param name="type" select="multimedias/photos/photo/@type" />
								<xsl:with-param name="style">float:left;margin:0 0 10px 15px;</xsl:with-param>
								<xsl:with-param name="alt" select="title" />
							</xsl:call-template>
						</xsl:if>
						<xsl:apply-templates select="content" /><!-- 
					 --><xsl:text disable-output-escaping="yes"><!-- 
					     -->]]&gt;<!-- 
					  --></xsl:text><!-- 
				 --></content:encoded>
				<guid isPermaLink="true"><xsl:value-of select="$config/system/domain" />/article/<xsl:value-of select="@id" />/<xsl:value-of select="object_shorttitle" />?utm_source=feed&amp;utm_medium=rss&amp;utm_term=rss&amp;utm_campaign=Rss%20Feed</guid>
				<pubDate><xsl:value-of select="pubDate" /></pubDate>
		    </item>
		</xsl:for-each>
	</channel>
</rss>
<!-- <html>
	<head>
		<xsl:call-template name="htmlHead" />

	</head>
	<body>
		hola
		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>
	</body>
</html> -->
</xsl:template>





</xsl:stylesheet>