<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:g="http://www.google.com/+1/button/" xmlns:fb="http://developers.facebook.com/">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template name="article.time.generic">
	<xsl:param name="item" />
	<strong>
		<xsl:choose>
			<xsl:when test="substring($item/published_at, 1, 10) = $fechaActual">
				<i class="fa fa-clock-o fa-lg" aria-hidden="true"><xsl:comment /></i>
				<xsl:call-template name="time">
					<xsl:with-param name="date" select="$item/published_at"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<i class="fa fa-dot-circle-o fa-lg" aria-hidden="true"><xsl:comment /></i>
				<xsl:call-template name="date.short">
					<xsl:with-param name="date" select="$item/published_at"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</strong>
</xsl:template>

<!-- Template base de nota -->
<xsl:template name="article.generic">
	<xsl:param name="item" />
	<xsl:param name="url" />
	<xsl:param name="classPrefix" />
	<xsl:param name="summarylimit">150</xsl:param>
	<article itemscope="itemscope" itemtype="http://schema.org/NewsArticle">
		<xsl:if test="$classPrefix != ''">
			<xsl:attribute name="class"><xsl:value-of select="$classPrefix" />-<xsl:value-of select="position()" /></xsl:attribute>
		</xsl:if>
		<meta itemscope="itemscope" itemprop="mainEntityOfPage"  itemType="https://schema.org/WebPage" itemid="{$config/system/domain}{$url}"/>
		<a href="{$url}" itemprop="url">
			<xsl:if test="$item/multimedias/images/image/@image_id != 0">
				<xsl:call-template name="image.bucket.lazy">
					<xsl:with-param name="id" select="$item/multimedias/images/image/@image_id" />
					<xsl:with-param name="type" select="$item/multimedias/images/image/@type" />
					<xsl:with-param name="width">360</xsl:with-param>
					<xsl:with-param name="height">240</xsl:with-param>
					<xsl:with-param name="crop">c</xsl:with-param>
					<xsl:with-param name="class">pic</xsl:with-param>
					<xsl:with-param name="alt" select="$item/multimedias/images/image/title" />
					<!-- <xsl:with-param name="itemprop">image</xsl:with-param> -->
				</xsl:call-template>
			</xsl:if>
			<h2 itemprop="headline">
				<xsl:value-of select="$item/title" />
			</h2>
			<xsl:if test="$item/summary != ''">
				<summary itemprop="description">
					<xsl:call-template name="limit.string">
						<xsl:with-param name="string" select="$item/summary" />
						<xsl:with-param name="limit" select="$summarylimit" />
					</xsl:call-template> 
				</summary>
			</xsl:if>
		</a>
		<div class="article-info floatFix">
			<xsl:call-template name="item.category">
				<xsl:with-param name="item" select="$item" />
			</xsl:call-template>
			<xsl:call-template name="social.article.btns">
				<xsl:with-param name="item" select="$item" />
			</xsl:call-template>
			<xsl:call-template name="article.time.generic">
				<xsl:with-param name="item" select="$item" />
			</xsl:call-template>
		</div>
		<div itemprop="image" itemscope="itemscope" itemtype="https://schema.org/ImageObject" style="display:none">
			<meta itemprop="url">
				<xsl:attribute name="content">
					<xsl:call-template name="image.bucket.src">
						<xsl:with-param name="id" select="$item/@image_id" />
						<xsl:with-param name="type" select="$item/@image_type" />
						<xsl:with-param name="width" select="$item/params/param[@name='image_width']/@value" />
						<xsl:with-param name="height" select="$item/params/param[@name='image_height']/@value" />
					</xsl:call-template>
				</xsl:attribute>
			</meta>
			<meta itemprop="width" content="{$item/params/param[@name='image_width']/@value}" />
			<meta itemprop="height" content="{$item/params/param[@name='image_height']/@value}" />
		</div>
		<div itemprop="author" itemscope="itemscope" itemtype="https://schema.org/Person" style="display:none;">
			<span itemprop="name">Editor Web</span>
		</div>
		<xsl:call-template name="article.microdata">
			<xsl:with-param name="item" select="$item" />
		</xsl:call-template>
		
	</article>
</xsl:template>


<xsl:template name="item.category">
	<xsl:param name="item" />
	<xsl:choose>
		<xsl:when test="$item/show_tag = 1">
			<span class="category colortag-{$item/element/tags/tag/@tag_id}" itemprop="articleSection">
				<xsl:value-of select="$item/element/tags/tag/tag_name" />
			</span>
		</xsl:when>
		<xsl:when test="$item/element/categories/group/category/name">
			<xsl:for-each select="$item/element/categories/group/category">
				<xsl:sort order="ascending" select="@order" data-type="number" />
				<xsl:if test="position() = 1">
					<span class="category color-{@category_id}" itemprop="articleSection">
						<xsl:value-of select="name" />
					</span>
				</xsl:if>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$item/categories/group/category/category_name">
			<xsl:for-each select="$item/categories/group/category">
				<xsl:sort order="ascending" select="@order" data-type="number" />
				<xsl:if test="position() = 1">
					<span class="category color-{@id}" itemprop="articleSection">
						<xsl:value-of select="category_name" />
					</span>
				</xsl:if>
			</xsl:for-each>	
		</xsl:when>
	</xsl:choose>
	<!-- <xsl:if test="$item/element/categories/group/category/name">
		<xsl:for-each select="$item/element/categories/group/category">
			<xsl:sort order="ascending" select="@order" data-type="number" />
			<xsl:if test="position() = 1">
				<span class="category color-{@category_id}" itemprop="articleSection">
					<xsl:value-of select="name" />
				</span>
			</xsl:if>
		</xsl:for-each>
	</xsl:if> -->
</xsl:template>

<xsl:template name="article.microdata">
	<xsl:param name="item" />
	<meta itemprop="datePublished" content="{substring-before($item/element/created_at, ' ')}T{substring-after($item/element/created_at, ' ')}-03:00" />
	<!-- <meta itemprop="publisher" content="Vind CMS" /> -->
	<div itemprop="publisher" itemscope="itemscope" itemtype="https://schema.org/Organization" style="display:none;">
		<div itemprop="logo" itemscope="itemscope" itemtype="https://schema.org/ImageObject">
			<meta itemprop="url" content="{$device}/assets/imgs/logos/vind_logo.svg" />
			<meta itemprop="width" content="176" />
			<meta itemprop="height" content="59" />
		</div>
		<meta itemprop="name" content="Vind CMS" />
	</div>
	<meta itemprop="dateModified" content="{substring-before($item/element/updated_at, ' ')}T{substring-after($item/element/updated_at, ' ')}-03:00" />
	<xsl:if test="$item/latitud != '' and $item/longitud != ''">
		<div style="display:none;" itemprop="contentLocation"><!-- 
			 --><div itemscope="itemscope" itemtype="http://schema.org/Place"><!-- 
				 --><div itemprop="geo" itemscope="itemscope" itemtype="http://schema.org/GeoCoordinates"><!-- 
					 --><meta itemprop="latitude" content="{$item/latitud}" /><!-- 
	    			 --><meta itemprop="longitude" content="{$item/longitud}" /><!-- 
				 --></div><!-- 
			 --></div><!-- 
		 --></div>
	</xsl:if>
</xsl:template>

<xsl:template name="social.article.btns">
	<xsl:param name="item" />
	<xsl:variable name="url">
		<xsl:choose>
			<xsl:when test="$isHome = 1">
				<xsl:call-template name="article.url">
					<xsl:with-param name="id" select="$item/@element_id" />
					<xsl:with-param name="title" select="$item/title" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="article.url">
					<xsl:with-param name="id" select="$item/@id" />
					<xsl:with-param name="title" select="$item/title" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="properties"><!-- 
		 -->{<!--
			 -->"En":<!--
			 -->{<!--
				 -->"text":"<xsl:value-of select="$item/element/group/category/name"/>",<!--
				 -->"href":"<xsl:value-of select="$config/system/domain"/>/<xsl:value-of select="$item/element/group/category/name"/>"<!--
			 -->},<!--
			 -->"Fecha de publicación":"<xsl:value-of select="substring($item/@date, 9, 2)"/>/<xsl:value-of select="substring($item/@date, 6, 2)"/>/<xsl:value-of select="substring($item/@date, 0, 5)"/>"<!--
		 -->}<!--
	 --></xsl:variable>

	<div class="share">
		<a href="#" class="fb" title="Compartir en Facebook">
			<xsl:attribute name="onclick"><!-- 
				 -->FB.ui({<!--
					  -->'method': 'feed',<!--
					  -->'link': '<xsl:value-of select="$url"/>',<!--
					  -->'display': 'popup',<!--
					  -->'caption': '<xsl:value-of select="$item/title"/>',<!--
					  -->'properties': '<xsl:value-of select="$properties"/>',<!--
					  -->'ref': 'article'<!--
					-->});<!-- 
			     -->return false;<!-- 
			 --></xsl:attribute><!-- 
	     --><i class="fa fa-facebook"><xsl:comment/></i></a>
		<a href="#" class="tw" title="Compartir en Twitter">
			<xsl:attribute name="onclick"><!-- 
				 -->window.open(<!-- 
					 -->'https://twitter.com/intent/tweet?<!-- 
					  -->url='+encodeURIComponent('<xsl:value-of select="$url" />')+'<!--
					  -->&amp;text='+encodeURIComponent('<xsl:value-of select="$item/title" />')+'<!--
					  -->&amp;via=vindcms',<!-- 
					 -->'twitter-share-dialog',<!-- 
					 -->'width=626,height=436');<!-- 
			     -->return false;<!-- 
			 --></xsl:attribute><!-- 
		 --><i class="fa fa-twitter"><xsl:comment/></i></a>
	</div><!-- 
	 <span class="comment-btn">Opiná <a href="{$url}#disqus_thread" data-disqus-identifier="{$item/@element_id | $item/@id}" title="Comentarios">0</a></span>
--></xsl:template>

<xsl:template name="breadcrumb">
	<xsl:param name="item" />
	<div class="breadcrumb">
		<a href="/">Inicio</a><!-- 
		 --><xsl:choose>
				<xsl:when test="count($item/categories/group/category) = 1"><!-- 
					 --> » <span><xsl:value-of select="$item/categories/group/category/parent_name" /></span><!-- 
					 --> » <!-- 
					 --><a><!-- 
						 --><xsl:attribute name="href">/<!-- 
							--><xsl:call-template name="sanitize">
								<xsl:with-param name="string" select="$item/categories/group/category/name" />
							</xsl:call-template>/<!-- 
						 --></xsl:attribute><!-- 
						 --><xsl:value-of select="$item/categories/group/category/name" /><!-- 
					 --></a><!-- 
				 --></xsl:when>
				<xsl:when test="count($item/categories/group/category) &gt; 1"><!-- 
					 --> » <span><xsl:value-of select="$item/categories/group/category/parent_name" /></span><!-- 
					 --> » <!-- 
					 -->
					 <xsl:for-each select="$item/categories/group/category">
					 <a>
					 <!-- 
						 --><xsl:attribute name="href">/<!-- 
							--><xsl:call-template name="sanitize">
								<xsl:with-param name="string" select="name" />
							</xsl:call-template>/<!-- 
						 --></xsl:attribute><!-- 
						 --><xsl:value-of select="name" /><!-- 
					 -->
					 </a>
					 <xsl:if test="position() != last()"> + </xsl:if>
					</xsl:for-each>
					 <!-- 
				 --></xsl:when>
		</xsl:choose>
		»  <span><xsl:value-of select="$item/title" /></span>
	</div>
</xsl:template>

<xsl:template name="share.box">
	<div class="share">
		<span class="tw-btn">
			<a href="http://twitter.com/share" class="twitter-share-button" data-count="horizontal"  data-lang="es">Tweet</a> <!-- data-via="LivePassArg" -->
			<script type="text/javascript" src="http://platform.twitter.com/widgets.js">&#xa0;</script>
		</span>
		<span class="fb-btn">
			<div class="fb-share-button" data-layout="button" data-size="small" data-mobile-iframe="true">
				<a class="fb-xfbml-parse-ignore" target="_blank" href="https://www.facebook.com/sharer/sharer.php?u={$page_url}&amp;src=sdkpreparse">Compartir</a>
			</div>
		</span>
		<span class="gp-btn">
			<!-- Place this tag where you want the +1 button to render -->
			<g:plusone size="medium">&#xa0;</g:plusone>
		</span>
		<!-- Place this render call where appropriate -->
		<script type="text/javascript"><!-- 
		   -->window.___gcfg = {lang: 'es-419'};<!-- 
		   -->(function() {<!-- 
		     -->var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;<!-- 
		     -->po.src = 'https://apis.google.com/js/plusone.js';<!-- 
		     -->var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);<!-- 
		   -->})();<!-- 
		 --></script>
		<!-- <xsl:if test="/xml/content/article">
			<span class="email">
				<a href="/article/send/{/xml/content/article/@id}/" onclick="layer.loadExternal(this);return false;" style="line-height:12px;">Enviar</a>
			</span>
		</xsl:if> -->
	</div>
</xsl:template>

<!-- Relaciones -->
<xsl:template match="relations" mode="related">
	<xsl:if test="./*[name()='articles' or name()='galleries']">
		<section id="relations">
			<xsl:apply-templates />
			<xsl:comment />
		</section>
	</xsl:if>
</xsl:template>

<xsl:template match="articles">
	<h3 class="gray-title large">También te puede interesar</h3>
	<section class="mosaic articles">
		<xsl:apply-templates mode="related">
			<xsl:sort order="descending" select="@created_at" />
		</xsl:apply-templates>
	</section>
</xsl:template>

<xsl:template match="article" mode="related">
	<xsl:variable name="url">
		<xsl:call-template name="article.url">
			<xsl:with-param name="id" select="@id" />
			<xsl:with-param name="title" select="title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:call-template name="article.generic">
		<xsl:with-param name="item" select="." />
		<xsl:with-param name="url" select="$url" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="clips">
</xsl:template>

<xsl:template match="clip" mode="related">
</xsl:template>
<!-- Relaciones -->

</xsl:stylesheet>