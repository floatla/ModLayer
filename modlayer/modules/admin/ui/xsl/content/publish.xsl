<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="UTF-8" cdata-section-elements="html script"/>
<xsl:preserve-space elements="*" />

<xsl:variable name="config" select="/xml/configuration" />

<xsl:template match="/xml">
	<xml>
		<pubDate><xsl:value-of select="$fechaActual"/>T<xsl:value-of select="$horaActual"/>:00</pubDate>
		<xsl:apply-templates select="content/*"/>
	</xml>
</xsl:template>


<xsl:template match="*" >
	<xsl:element name="{name()}">
		<xsl:apply-templates select="@*"  />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="@*" >
	<xsl:attribute name="{name()}"><xsl:value-of select="." disable-output-escaping="yes"/></xsl:attribute>
</xsl:template>

<xsl:template match="*[name()='image']">
	<xsl:element name="{name()}">
		<xsl:apply-templates select="@*" />
		<xsl:value-of select="text()" />
		<xsl:apply-templates select="*"/>
		<bucket><!-- 
			 <xsl:value-of select="$config/images_domain"/>
			 --><xsl:value-of select="$config/images_bucket"/>/<!-- 
			 --><xsl:value-of select="substring(@image_id, string-length(@image_id), 1)" />/<!-- 
		--></bucket>
	</xsl:element>
</xsl:template>




</xsl:stylesheet>