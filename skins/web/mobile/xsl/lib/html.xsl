<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<!-- 
	Este archivo contiene los match de los nodos html para que puedan ser 
	renderizados y manipulados segun lo que se necesite.
 -->


<xsl:template match="p|P">
	<xsl:choose>
		<xsl:when test="not(@class = 'embed')">
			<p>
				<xsl:apply-templates select="@*" mode="atts" />
				<xsl:apply-templates />
			</p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="b|strong">
	<strong>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
		<xsl:if test="not(text())">&#xa0;</xsl:if>
	</strong>
</xsl:template>

<xsl:template match="i|em">
	<em>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
		<xsl:if test="not(text())">&#xa0;</xsl:if>
	</em>
</xsl:template>

<xsl:template match="span">
	<span>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
		<xsl:if test="not(text())">&#xa0;</xsl:if>
	</span>
</xsl:template>

<xsl:template match="a|A">
	<a>
		<xsl:apply-templates select="@*" mode="atts" />
		<xsl:apply-templates />
		<xsl:if test="not(text())">&#xa0;</xsl:if>
	</a>
</xsl:template>


<!-- 
	Para las imagenes Se corrigen las urls de las imagenes embebidas viejas en Norte 
-->
<xsl:template match="img">
	<xsl:variable name="size_l_width">320</xsl:variable>
	<xsl:variable name="size_l_height">320</xsl:variable>
	<xsl:variable name="size_n_width">620</xsl:variable>
	<xsl:variable name="size_n_height">450</xsl:variable>
	<img>
		<xsl:if test="@src"><!-- 
			 --><xsl:choose><!-- 
				 --><xsl:when test="contains(@src, 'http://')"><!-- 
					 --><xsl:attribute name="src"><!-- 
						 --><xsl:value-of select="@src" /><!-- 
					 --></xsl:attribute><!-- 
				 --></xsl:when><!-- 
				 --><xsl:when test="contains(@src, 'photos/generated') and contains(@src, '_l.')">
					 <xsl:attribute name="src"><!-- 
						 --><xsl:value-of select="$config/system/images_bucket" />/<!--
						 --><xsl:value-of select="substring-after(substring-before(@src, '_l'), 'photos/generated/')" /><!--
						 -->w<xsl:value-of select="$size_l_width" /><!--
						 -->h<xsl:value-of select="$size_l_height" />.<!--
						 --><xsl:value-of select="substring-after(@src, '_l.')" /><!-- 
					 --></xsl:attribute> 
				 </xsl:when><!-- 
				--><xsl:when test="contains(@src, 'photos/generated') and contains(@src, '_n.')">
					 <xsl:attribute name="src"><!-- 
						 --><xsl:value-of select="$config/system/images_bucket" />/<!--
						 --><xsl:value-of select="substring-after(substring-before(@src, '_n'), 'photos/generated/')" /><!--
						 -->w<xsl:value-of select="$size_n_width" /><!--
						 -->h<xsl:value-of select="$size_n_height" />c.<!--
						 --><xsl:value-of select="substring-after(@src, '_n.')" /><!-- 
					 --></xsl:attribute> 
				 </xsl:when><!-- 
				 --><xsl:otherwise><!-- 
					 --><xsl:attribute name="src"><!-- 
						 --><xsl:value-of select="$config/system/content_domain" /><xsl:value-of select="@src" /><!-- 
					 --></xsl:attribute><!-- 
				 --></xsl:otherwise><!-- 
			 --></xsl:choose><!-- 
		 --></xsl:if>
		<xsl:if test="@class"><xsl:attribute name="class"><xsl:value-of select="@class" /></xsl:attribute></xsl:if>
		<xsl:if test="@alt"><xsl:attribute name="alt"><xsl:value-of select="@alt" /></xsl:attribute></xsl:if>
		<xsl:if test="not(@class)"><xsl:attribute name="class">external-image</xsl:attribute></xsl:if>
	</img>
</xsl:template>

<xsl:template match="br">
	<br/>
</xsl:template>

<xsl:template match="h1|h2|h3|h4|h5">
	<xsl:element name="{name()}">
		<xsl:if test="@class"><xsl:attribute name="class"><xsl:value-of select="@class" /></xsl:attribute></xsl:if>
		<xsl:if test="@width"><xsl:attribute name="width"><xsl:value-of select="@width" /></xsl:attribute></xsl:if>
		<xsl:if test="@height"><xsl:attribute name="height"><xsl:value-of select="@height" /></xsl:attribute></xsl:if>
		<xsl:if test="@onclick"><xsl:attribute name="onclick"><xsl:value-of select="@onclick" /></xsl:attribute></xsl:if>
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
	<xsl:attribute name="{name()}">
		<xsl:choose>
			<xsl:when  test="contains(.,'&amp;amp;')">
				<xsl:value-of select="substring-before(., '&amp;')" disable-output-escaping="yes" />&amp;<xsl:value-of select="substring-after(., 'amp;')" disable-output-escaping="yes" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." disable-output-escaping="yes" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="text()">
	<xsl:value-of select="." disable-output-escaping="yes" />
</xsl:template>

<xsl:template name="html.titles">
	<xsl:param name="string" />
	<xsl:choose>
		<xsl:when test="contains($string, '[color]')">
			<xsl:value-of select="substring-before($string, '[color]')" disable-output-escaping="yes" />
			<span class="color"><xsl:value-of select="substring-after(substring-before($string, '[/color]'), '[color]')" /></span>
			<xsl:call-template name="html.titles">
				<xsl:with-param name="string" select="substring-after($string, '[/color]')" />
			</xsl:call-template>
			<!-- <xsl:value-of select="substring-after($string, '[/bold]')" /> -->
		</xsl:when>
		<xsl:when test="contains($string, '[italic]')">
			<xsl:value-of select="substring-before($string, '[italic]')" disable-output-escaping="yes" />
			<em><xsl:value-of select="substring-after(substring-before($string, '[/italic]'), '[italic]')" /></em>
			<xsl:call-template name="html.titles">
				<xsl:with-param name="string" select="substring-after($string, '[/italic]')" />
			</xsl:call-template>
			<!-- <xsl:value-of select="substring-after($string, '[/italic]')" /> -->
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$string" disable-output-escaping="yes" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<!--TEMPLATES DE HTML-->

</xsl:stylesheet>