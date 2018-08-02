<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="collection" select="/xml/content/collection" />

<xsl:variable name="title">
	<xsl:choose>
		<xsl:when test="$collection/object/categories/group/category/metatitle != ''">
			<xsl:value-of select="$collection/object/categories/group/category/metatitle" />
		</xsl:when>
		<xsl:when test="$content/tag/name">
			<xsl:value-of select="$content/tag/name" />
		</xsl:when>
		<xsl:when test="$content/category/name">
			<xsl:value-of select="$content/category/name" />
		</xsl:when>
		<xsl:otherwise>
			Notas
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<!-- <xsl:variable name="itemDescription">
	<xsl:choose>
		<xsl:when test="$article/metadescription != ''">
			<xsl:value-of select="$article/metadescription" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="limit.string">
				<xsl:with-param name="string" select="/xml/content/article/summary" />
				<xsl:with-param name="limit">250</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="itemURL">
	<xsl:call-template name="article.url">
		<xsl:with-param name="id" select="$article/@id" />
		<xsl:with-param name="title" select="$article/title" />
	</xsl:call-template>
</xsl:variable> -->

<xsl:variable name="dinamicHead">
	<title><xsl:value-of select="$title" /> | <xsl:value-of select="$config/system/applicationID" /></title>
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

		<xsl:choose>
			<xsl:when test="$collection/@total &gt; 0">
				<div class="article-list">
					<div class="section-head">
						<div class="container floatFix">
							<xsl:choose>
								<xsl:when test="$content/category/name">
									<h2><xsl:value-of select="$content/category/name" /></h2>
								</xsl:when>
								<xsl:when test="$content/tag/name">
									<h2>Notas de <xsl:value-of select="$content/tag/name" /></h2>
								</xsl:when>
								<xsl:otherwise>
									<h2>Notas</h2>
								</xsl:otherwise>
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

					<div class="list">
						<div class="container floatFix">
							<xsl:for-each select="$collection/object">
								<xsl:variable name="aurl">
									<xsl:call-template name="article.url">
										<xsl:with-param name="id" select="@id" />
										<xsl:with-param name="title" select="title" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:call-template name="article.generic">
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
			</xsl:when>
			<xsl:otherwise>
				<div class="empty-list">
					<div class="container floatFix">
						<xsl:choose>
							<xsl:when test="$content/category/name">
								<h2>No existen notas en <xsl:value-of select="$content/category/name" /></h2>
							</xsl:when>
							<xsl:when test="$content/tag/name">
								<h2>No existen notas de <xsl:value-of select="$content/tag/name" /></h2>
							</xsl:when>
						</xsl:choose>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
			
</xsl:template>


</xsl:stylesheet>