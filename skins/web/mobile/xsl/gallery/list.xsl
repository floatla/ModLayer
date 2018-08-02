<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="cellsPerRow">3</xsl:variable>
<xsl:variable name="htmlHeadExtra"></xsl:variable>

<xsl:variable name="item" select="$content/collection//object" />

<xsl:variable name="dinamicHead">
	<title>En Imágenes | <xsl:value-of select="$config/system/applicationID" /></title>
	<xsl:apply-templates select="$config/skin/header/*[not(name()='title')]" mode="htmlhead"/>
	
	<meta property="og:title" content="En Imágenes"/>
	<meta property="og:description" content="La actualidad de la región en imágenes"/>
	<meta property="og:image">
		<xsl:attribute name="content">
			<xsl:call-template name="image.bucket.src">
				<xsl:with-param name="id" select="$item/multimedias/images/image/@image_id" />
				<xsl:with-param name="type" select="$item/multimedias/images/image/@type" />
			</xsl:call-template>
		</xsl:attribute>
	</meta>
	<!-- <meta property="og:image:type" content="image/{$item/multimedias/images/image/@type}" /> -->
	<meta property="og:image:width" content="{$item/multimedias/images/image/@width}" />
	<meta property="og:image:height" content="{$item/multimedias/images/image/@height}" />
	<meta property="fb:admins" content="567857997"/>
	<meta property="fb:app_id" content="315386301913502"/>

	<meta property="og:url" content="{$config/system/domain}/en-imagenes/"/>
	<meta property="og:site_name" content="{$config/system/applicationID}"/>

	<meta http-equiv="refresh" content="3600" />
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$device" />/assets/css/gallery.css
		</xsl:with-param>
	</xsl:call-template>
	<!-- <script>requirejs(['app/controller/google_dfp_script.js']);</script>
	<script>requirejs(['app/controller/google_dfp_section.js']);</script> -->
</xsl:variable>


<xsl:variable name="home" select="/xml/content/home" />
<xsl:template name="content">


	<div class="container ghome">
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
						<!-- <span class="mask"> -->
							<h3><xsl:value-of select="title" /></h3>
						<!-- </span> -->
					</a>
				</div>
			</xsl:for-each>
			
		</div>
	</div>


</xsl:template>

</xsl:stylesheet>