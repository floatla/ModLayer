<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="p" />

<xsl:param name="parent_id" />

<xsl:template match="/xml">

	<h2 class="section-title">Notas Publicadas</h2>
	<xsl:call-template name="pagination.ajax">
		<xsl:with-param name="currentPage" select="content/collection/@currentPage" />
		<xsl:with-param name="pageSize" select="content/collection/@pageSize" />
		<xsl:with-param name="total" select="content/collection/@total" />
		<xsl:with-param name="onclick">objectParent.pagination</xsl:with-param>
		<xsl:with-param name="parent_id" select="$parent_id" />
	</xsl:call-template>

	<xsl:for-each select="content/collection/object">
		<xsl:variable name="gurl">
			<xsl:call-template name="article.url">
				<xsl:with-param name="id" select="@id" />
				<xsl:with-param name="title" select="title" />
			</xsl:call-template>
		</xsl:variable>
		<article>
			<xsl:if test="position() mod 2 = 0">
				<xsl:attribute name="class">alt</xsl:attribute>
			</xsl:if>
			<a href="{$gurl}" class="floatFix">
				<xsl:if test="multimedias/images/image">
					<xsl:call-template name="image.bucket">
						<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
						<xsl:with-param name="type" select="multimedias/images/image/@type" />
						<xsl:with-param name="width">310</xsl:with-param>
						<xsl:with-param name="height">440</xsl:with-param>
						<xsl:with-param name="crop">c</xsl:with-param>
						<xsl:with-param name="class">pic</xsl:with-param>
						<xsl:with-param name="itemprop">image</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<time>
					<xsl:call-template name="date">
						<xsl:with-param name="date  " select="@created_at" />
					</xsl:call-template>
				</time>
				<h3><xsl:value-of select="title" /></h3>
				<summary>
					<xsl:apply-templates select="summary" />
				</summary>
			</a>
		</article>
	</xsl:for-each>
</xsl:template>

</xsl:stylesheet>