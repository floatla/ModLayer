<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra"></xsl:variable>
<xsl:param name="page" />
<xsl:param name="query" />
<xsl:param name="message" />
<xsl:param name="currentPage" />
<xsl:param name="perPage" />
<xsl:param name="category_id" />
<xsl:param name="search_category" />
<xsl:param name="search_type" />

<xsl:variable name="dinamicHead">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><xsl:value-of select="$content/search/@query" /> | <xsl:value-of select="$config/system/applicationID" /></title>
	<meta name="description" content="Noticias de {/xml/content/categoria/name}" />
	<xsl:apply-templates select="$config/skin/header[not(name()='title')]" mode="htmlhead"/>
	<style>
		.pagination {float:right;}
		.mosaic article {height:242px;}
		.mosaic article h2 {margin-top:0;height:auto;}
		.mosaic article summary {display:block;margin-bottom:15px;height:auto}
		.mosaic article h2 em,
		.mosaic article summary em {font-weight:bold;color:#ee5b0d;}
		.mosaic article .category {margin-right:5px;position:absolute;left:15px;bottom:15px;}
		.mosaic article time {position:absolute;right:15px;bottom:15px;}
		.mosaic article time i {margin-right:5px;}
	</style>
</xsl:variable>

<xsl:template name="content">

	<xsl:variable name="total" select="content/search/hits/total" />

	

	<div class="article-list">
		<div class="section-head">
			<div class="container floatFix">
				<xsl:choose>
					<xsl:when test="$message != ''">
						<div class="search-alert">
							<xsl:value-of select="$message" />
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="search-alert">
							<p>Resultado de la búsqueda <em><xsl:value-of select="$content/search/@query" disable-output-escaping="yes" /></em></p>
						</div>
						<div class="floatFix search-data">
							<xsl:call-template name="pagination">
								<xsl:with-param name="url">/search/</xsl:with-param>
								<xsl:with-param name="total" select="$total" />
								<xsl:with-param name="pageSize" select="$perPage" />
								<xsl:with-param name="currentPage" select="$currentPage" />
							</xsl:call-template>
							<xsl:value-of select="content/search/hits/total" /> resultados. (<xsl:value-of select="(content/search/took) div 1000" /> seg.)
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:comment />
			</div>
		</div>

		<section class="search-result">
			<div class="mosaic">
				<div class="container floatFix">
					<xsl:for-each select="content/search/hits/hits/*">
						<xsl:sort order="descending" select="_score" data-type="number" />

						<article>
							<xsl:variable name="link">
								<xsl:choose>
									<xsl:when test="_source/module = 'gallery'">
										<xsl:call-template name="gallery.url">
											<xsl:with-param name="id" select="_id" />
											<xsl:with-param name="title" select="_source/title" />
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="_source/module = 'suple'">
										<xsl:call-template name="suple.url">
											<xsl:with-param name="id" select="_id" />
											<xsl:with-param name="title" select="_source/title" />
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="article.url">
											<xsl:with-param name="id" select="_id" />
											<xsl:with-param name="title" select="_source/title" />
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<a href="{$link}">
								<h2>
									<xsl:choose>
										<xsl:when test="highlight/title/node0"><xsl:value-of select="highlight/title/node0" disable-output-escaping="yes"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="_source/title" disable-output-escaping="yes"/></xsl:otherwise>
									</xsl:choose>
								</h2>
								<summary>
									<xsl:choose>
										<xsl:when test="highlight/summary/node0"><xsl:value-of select="highlight/summary/node0" disable-output-escaping="yes"/></xsl:when>
										<xsl:when test="highlight/content/node0"><xsl:value-of select="highlight/content/node0" disable-output-escaping="yes"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="_source/summary" disable-output-escaping="yes"/></xsl:otherwise>
									</xsl:choose>
								</summary>
								<xsl:if test="_source/categories/node0/name">
									<span class="category color-{_source/categories/node0/category_id}"><xsl:value-of select="_source/categories/node0/name" /></span>
								</xsl:if>
								<time>
									<i class="fa fa-dot-circle-o"><xsl:comment /></i>
									<xsl:call-template name="date.short"> 
										<xsl:with-param name="date" select="_source/created_at" />
									</xsl:call-template>
								</time>
							</a>
						</article>
					</xsl:for-each>
				</div>
				<div class="container">
					<div class="floatFix search-data">
						<xsl:call-template name="pagination">
							<xsl:with-param name="url">/search/</xsl:with-param>
							<xsl:with-param name="total" select="$total" />
							<xsl:with-param name="pageSize" select="$perPage" />
							<xsl:with-param name="currentPage" select="$currentPage" />
						</xsl:call-template>
						<xsl:value-of select="content/search/hits/total" /> resultados. (<xsl:value-of select="(content/search/took) div 1000" /> seg.)
					</div>
				</div>
			</div>

		</section>
	</div>
	
</xsl:template>

</xsl:stylesheet>