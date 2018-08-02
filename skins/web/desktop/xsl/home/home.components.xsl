<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template name="publication.time"><!-- 
	 --><xsl:variable name="pubdate" select="substring(/xml/content/home/pubDate, 1, 10)" /><!-- 
	 --><xsl:variable name="pubHour" select="substring(/xml/content/home/pubDate, 12, 2)" /><!-- 
	 --><xsl:variable name="pubMinute" select="substring(/xml/content/home/pubDate, 15, 2)" /><!-- 
	 --><xsl:variable name="currentHour" select="substring($horaActual, 1, 2)" /><!-- 
	 --><xsl:variable name="currentMinute" select="substring($horaActual, 4, 2)" /><!-- 
	 --><xsl:choose><!-- 
		 --><xsl:when test="($currentMinute - $pubMinute) &lt;= 1"><!-- 
			 -->Actualizado hace menos de 1 minuto<!-- 
		 --></xsl:when><!-- 
		 --><xsl:when test="($currentHour - $pubHour) = 0"><!-- 
		 -->Actualizado hace <xsl:value-of select="$currentMinute - $pubMinute" /> minutos<!-- 
		 --></xsl:when><!-- 
		 <xsl:when test="($currentHour - $pubHour) &lt; 2 and ($currentHour - $pubHour) &gt; 0">
			 Actualizado hace más <br/> de <xsl:value-of select="$currentHour - $pubHour" /> hora
		 </xsl:when>
	 --></xsl:choose>
	 <!-- 
 --></xsl:template>


<!-- <xsl:template name="article.time">
	<xsl:param name="item" />
	<strong>
		<xsl:choose>
			<xsl:when test="substring($item/element/published_at, 1, 10) = $fechaActual">
				<i class="fa fa-clock-o fa-lg" aria-hidden="true"><xsl:comment /></i>
				<xsl:call-template name="time">
					<xsl:with-param name="date" select="$item/element/published_at"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<i class="fa fa-dot-circle-o fa-lg" aria-hidden="true"><xsl:comment /></i>
				<xsl:call-template name="date.short">
					<xsl:with-param name="date" select="$item/element/published_at"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		</strong>
</xsl:template> -->

<!-- Template base de nota -->
<xsl:template name="article">
	<xsl:param name="item" />
	<xsl:param name="classPrefix" />
	<xsl:param name="summarylimit">500</xsl:param>
	<article itemscope="itemscope" itemtype="http://schema.org/NewsArticle">
		<xsl:if test="$classPrefix != ''">
			<xsl:attribute name="class"><xsl:value-of select="$classPrefix" />-<xsl:value-of select="position()" /></xsl:attribute>
		</xsl:if>
		<meta itemscope="itemscope" itemprop="mainEntityOfPage"  itemType="https://schema.org/WebPage" itemid="{$config/system/domain}{$item/url}"/>
		<a href="{$item/url}" itemprop="url">
			<xsl:if test="$item/@image_id != 0">
				<xsl:call-template name="image.bucket.lazy">
					<xsl:with-param name="id" select="$item/@image_id" />
					<xsl:with-param name="type" select="$item/@image_type" />
					<xsl:with-param name="width" select="$item/params/param[@name='image_width']/@value" />
					<xsl:with-param name="height" select="$item/params/param[@name='image_height']/@value" />
					<xsl:with-param name="crop">c</xsl:with-param>
					<xsl:with-param name="class">pic</xsl:with-param>
					<xsl:with-param name="alt" select="$item/title" />
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
			<!-- <xsl:call-template name="article.time">
				<xsl:with-param name="item" select="$item" />
			</xsl:call-template> -->
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


<xsl:template match="semibomba">
	<xsl:if test="item">
		<section class="semibomb">
			<div class="container">
				<xsl:for-each select="item">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="."/>
						<xsl:with-param name="summarylimit">200</xsl:with-param>
						<xsl:with-param name="classPrefix">c3</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</section>
	</xsl:if>
</xsl:template>


<xsl:template match="apertura">
	<xsl:if test="./item">
		<section class="apertura">
			<div class="container">
				<xsl:for-each select="item">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="."/>
						<xsl:with-param name="summarylimit">200</xsl:with-param>
						<xsl:with-param name="classPrefix">c3</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</section>
	</xsl:if>
</xsl:template>

<xsl:template match="color">
	<xsl:if test=".//item">
		<section class="content-color">
			<xsl:attribute name="style">background-color:<xsl:value-of select="@background" /></xsl:attribute>
			<div class="container floatFix">
				<xsl:variable name="boxTitle"><xsl:value-of select="@param_title" /></xsl:variable>
				<xsl:if test="$home/params/*[name()=$boxTitle] !=''">
					<header>
						<xsl:if test="@foreground != ''">
							<xsl:attribute name="style">background:<xsl:value-of select="@foreground" />;</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$home/params/*[name()=$boxTitle]"  />
						<xsl:comment />
					</header>
				</xsl:if>
				<div class="list floatFix">
					<xsl:for-each select="articles/item">
						<xsl:choose>
							<xsl:when test="@type = 'promo' and element/html != ''">
								<article class="promo">
									<xsl:apply-templates select="element/html" />
								</article>
								<!-- <xsl:value-of select="element/html" disable-output-escaping="" /> -->
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="article">
									<xsl:with-param name="item" select="."/>
									<xsl:with-param name="classPrefix">pos</xsl:with-param>
									<xsl:with-param name="summarylimit">130</xsl:with-param>
								</xsl:call-template>	
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</div>
			</div>
		</section>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>