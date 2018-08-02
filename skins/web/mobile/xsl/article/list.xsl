<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra"></xsl:variable>
<xsl:variable name="collection" select="/xml/content/collection" />

<xsl:variable name="dinamicHead">
	<title><xsl:value-of select="/xml/content/category/name | $content/tag/name" /> | <xsl:value-of select="$config/system/applicationID" /></title>
	<meta name="description" content="Noticias de {/xml/content/category/name}. {$config/skin/header/meta[@name='description']/@content}" />
	<xsl:apply-templates select="$config/skin/header/*[not(name()='title')][not(@name='description')]" mode="htmlhead"/>
</xsl:variable>


<xsl:template name="content">
	<xsl:variable name="paginadourl">
		<xsl:choose>
			<xsl:when test="contains($page_url, '/page/')">
				<xsl:value-of select="substring-before($page_url, 'page/')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($page_url, 1, string-length($page_url))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<div class="article-list">

		<div class="section-head">
			<div class="container floatFix">
				<xsl:choose>
					<xsl:when test="$content/category/name">
						<h2><xsl:value-of select="$content/category/name" /></h2>
					</xsl:when>
					<xsl:when test="$content/tag/name">
						<h2>Notas de: <xsl:value-of select="$content/tag/name" /></h2>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="$collection/@total &gt; $collection/@pageSize">
					<xsl:call-template name="pagination">
						<xsl:with-param name="url" select="$paginadourl"></xsl:with-param>
						<xsl:with-param name="total" select="$collection/@total" />
						<xsl:with-param name="pageSize" select="$collection/@pageSize" />
						<xsl:with-param name="currentPage" select="$collection/@currentPage" />
					</xsl:call-template>
				</xsl:if>
			</div>
		</div>

		<div class="mosaic">
			<xsl:if test="$content/category/name = 'Editorial'">
				<xsl:attribute name="class">mosaic editorial</xsl:attribute>
			</xsl:if>
			<div class="container floatFix">
				<xsl:for-each select="content/collection/object">
					<xsl:variable name="aurl">
						<xsl:call-template name="article.url">
							<xsl:with-param name="id" select="@id" />
							<xsl:with-param name="title" select="title" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="article.generic.mosaic">
						<xsl:with-param name="item" select="."/>
						<xsl:with-param name="url" select="$aurl"/>
						<xsl:with-param name="classPrefix">pos</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</div>
		
		<xsl:if test="$collection/@total &gt; $collection/@pageSize">
			<div class="section-footer">
				<div class="container floatFix">
					<xsl:call-template name="pagination">
						<xsl:with-param name="url" select="$paginadourl"></xsl:with-param>
						<xsl:with-param name="total" select="$collection/@total" />
						<xsl:with-param name="pageSize" select="$collection/@pageSize" />
						<xsl:with-param name="currentPage" select="$collection/@currentPage" />
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
	</div>
	
	<!-- <xsl:call-template name="disqus.count.script" /> -->
</xsl:template>


</xsl:stylesheet>