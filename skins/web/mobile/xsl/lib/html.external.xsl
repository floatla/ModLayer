<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template match="external">
	<xsl:variable name="uid" select="@uid" />
	<xsl:if test="count($content/article/assets/asset[uid = $uid]) = 1">
		<div class="floatFix" style="clear:both;">
			<xsl:apply-templates select="$content/article/assets/asset[uid = $uid]/external/*" mode="externalCode" />
		</div>
		<!-- <xsl:copy-of select="$content/article/assets/asset[uid = $uid]/external/*[not(name()='script')][not(name()='iframe')]" />
		<xsl:apply-templates select="$content/article/assets/asset[uid = $uid]/external/*[name()='iframe']" mode="externalIframe"/>
		<xsl:apply-templates select="$content/article/assets/asset[uid = $uid]/external/*[name()='script']" mode="externalScript"/> -->
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="externalCode">
	<xsl:element name="{name()}"><!-- 
		 --><xsl:apply-templates select="@*" mode="atts" /><!-- 
		 --><xsl:apply-templates /><!-- 
		 -->&#xa0;<!-- 
	 --></xsl:element>
</xsl:template>

<xsl:template match="script" mode="externalScript">
	<script><!-- 
		 --><xsl:apply-templates select="@*" mode="atts" /><!-- 
		 --><xsl:apply-templates /><!-- 
		 -->&#xa0;<!-- 
	 --></script>
</xsl:template>

<xsl:template match="iframe" mode="externalIframe">
	<xsl:choose>
		<xsl:when test="contains(@src, 'player.vimeo.com')">
			vimeo video
		</xsl:when>
		<xsl:otherwise>
			<iframe><!-- 
		 --><xsl:apply-templates select="@*" mode="atts" /><!-- 
		 --><xsl:apply-templates /><!-- 
		 -->&#xa0;<!-- 
	 --></iframe>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>