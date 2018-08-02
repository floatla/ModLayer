<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra"></xsl:variable>

<xsl:variable name="gallery" select="/xml/content/gallery" />

<xsl:variable name="title">
	<xsl:choose>
		<xsl:when test="$gallery/metatitle != ''">
			<xsl:value-of select="$gallery/metatitle" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$gallery/title" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="descripcion">
	<xsl:choose>
		<xsl:when test="$gallery/metadescription != ''">
			<xsl:value-of select="$gallery/metadescription" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="limit.string">
				<xsl:with-param name="cadena" select="/xml/content/gallery/summary" />
				<xsl:with-param name="cantidad">250</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="this_url">
	<xsl:call-template name="gallery.url">
		<xsl:with-param name="id" select="/xml/content/gallery/@id" />
		<xsl:with-param name="title" select="/xml/content/gallery/title" />
	</xsl:call-template>
</xsl:variable>

<xsl:variable name="dinamicHead">
	<title><xsl:value-of select="$title" /> | En Imágenes | <xsl:value-of select="$config/system/applicationID" /></title>
	<xsl:apply-templates select="$config/skin/header/*[not(name()='title')]" mode="htmlhead"/>
	
	<meta property="og:title" content="{$title}"/>
	<meta property="og:description" content="{$descripcion}"/>
	<meta property="og:image">
		<xsl:attribute name="content">
			<xsl:call-template name="image.bucket">
				<xsl:with-param name="id" select="$gallery/multimedias/images/image/@image_id" />
				<xsl:with-param name="type" select="$gallery/multimedias/images/image/@type" />
			</xsl:call-template>
		</xsl:attribute>
	</meta>
	<meta property="fb:admins" content="567857997"/>
	<meta property="fb:app_id" content="315386301913502"/>

	<meta property="og:url" content="{$this_url}"/>
	<meta property="og:type" content="article"/>
	<meta property="og:site_name" content="Vind.com.ar"/>

	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$device" />/assets/css/gallery.css
		</xsl:with-param>
	</xsl:call-template>
	<script>requirejs(['app/controller/gallery']);</script>
</xsl:variable>



<xsl:template name="content">

	<main class="gallery">
		<div class="container floatFix">
			<span class="right date-info">
				<time>
					<i class="fa fa-dot-circle-o fa-lg" aria-hidden="true"><xsl:comment /></i>
					<xsl:call-template name="date.short">
						<xsl:with-param name="date" select="$gallery/@created_at" />
					</xsl:call-template>
				</time>
				<strong>
					<xsl:value-of select="count($gallery/multimedias/images/image)" /> fotos
				</strong>
			</span>
			<h1 id="title"><xsl:value-of select="$gallery/title" /></h1>
			<xsl:value-of select="$gallery/summary" disable-output-escaping='yes'/>
		</div>
			
		<xsl:variable name="total" select="count($gallery/multimedias/images/image)" />
		<div id="gallery" class="swiper-container">
			<div class="swiper-wrapper">
				<xsl:for-each select="$gallery/multimedias/images/image">
					<div class="swiper-slide panel">
						<span class="total">Foto <xsl:value-of select="position()" /> de <xsl:value-of select="$total" /></span>
							<xsl:variable name="id" select="@image_id" />
							<xsl:variable name="type" select="@type" />
							<xsl:choose>
								<xsl:when test="@height &lt; 500">
									<xsl:call-template name="image.bucket">
										<xsl:with-param name="id" select="@image_id" />
										<xsl:with-param name="type" select="@type" />
										<xsl:with-param name="width">480</xsl:with-param>
										<xsl:with-param name="height">270</xsl:with-param>
										<xsl:with-param name="alt" select="title" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="image.bucket">
										<xsl:with-param name="id" select="@image_id" />
										<xsl:with-param name="type" select="@type" />
										<xsl:with-param name="height">270</xsl:with-param>
										<xsl:with-param name="alt" select="title" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						
						<xsl:if test="summary!=''">
							<summary>
								<xsl:value-of select="summary" disable-output-escaping="yes" />
							</summary>
						</xsl:if>
					</div>
				</xsl:for-each>
			</div>
		</div>
		<div class="arrows">
			Utilizá las flechas del teclado para navegar la galería
			<span class="left">&#xa0;</span>
			<span class="right">&#xa0;</span>
			<span class="up">&#xa0;</span>
			<span class="down">&#xa0;</span>
		</div>
	</main>
	<div class="container floatFix glist">
		<xsl:if test="content/collection/object">
			<h2>Últimas Galerías</h2>
			<div class="masonry">
				<xsl:for-each select="$content/collection//object">
					<xsl:variable name="gurl">
						<xsl:call-template name="gallery.url">
							<xsl:with-param name="id" select="@id" />
							<xsl:with-param name="title" select="title" />
						</xsl:call-template>
					</xsl:variable>
					<div class="brick">
						<a href="{$gurl}" title="{title}">
							<xsl:call-template name="image.bucket">
								<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
								<xsl:with-param name="type" select="multimedias/images/image/@type" />
								<xsl:with-param name="width">460</xsl:with-param>
								<xsl:with-param name="height">720</xsl:with-param>
							</xsl:call-template>
							<span class="mask">
								<h3><xsl:value-of select="title" /></h3>
							</span>
						</a>
					</div>
				</xsl:for-each>
			</div>
		</xsl:if>
		<xsl:comment />
	</div>

</xsl:template>







</xsl:stylesheet>