<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template name="image.bucket.lazy">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:param name="width" />
	<xsl:param name="height" />
	<xsl:param name="crop" />
	<xsl:param name="quality" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />
	<xsl:param name="itemprop" />

	<!-- Imprimir tag imagen -->
	<img alt="{$alt}">
		<xsl:attribute name="src">data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==</xsl:attribute>
		<xsl:attribute name="width"><xsl:value-of select="$width" /></xsl:attribute>
		<xsl:attribute name="height"><xsl:value-of select="$height" /></xsl:attribute>
		<xsl:attribute name="data-src"><!-- 
			 --><xsl:value-of select="$config/system/content_domain" /><!--
			 --><xsl:value-of select="$config/system/images_bucket" />/<!-- 
			 --><xsl:value-of select="substring($id, string-length($id), 1)" />/<!-- 
			 --><xsl:value-of select="$id" /><!-- 
			 --><xsl:if test="$width!=''">w<xsl:value-of select="$width" /></xsl:if><!-- 
			 --><xsl:if test="$height!=''">h<xsl:value-of select="$height" /></xsl:if><!-- 
			 --><xsl:if test="$quality!=''">q<xsl:value-of select="$quality" /></xsl:if><!-- 
			 --><xsl:if test="$crop!=''">c</xsl:if><!-- 
			 -->.<!-- 
			 --><xsl:value-of select="$type" /><!-- 
		 --></xsl:attribute>
		<xsl:attribute name="class">b-lazy</xsl:attribute>
		<xsl:if test="$class!=''"><xsl:attribute name="class"><xsl:value-of select="$class" /> b-lazy</xsl:attribute></xsl:if>
		<xsl:if test="$style!=''"><xsl:attribute name="style"><xsl:value-of select="$style" /></xsl:attribute></xsl:if>
		<xsl:if test="$itemprop!=''"><xsl:attribute name="itemprop"><xsl:value-of select="$itemprop" /></xsl:attribute></xsl:if>
	</img>
</xsl:template>

<xsl:template name="image.bucket">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:param name="width" />
	<xsl:param name="height" />
	<xsl:param name="crop" />
	<xsl:param name="quality" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />
	<xsl:param name="itemprop" />

	<!-- Imprimir tag imagen -->
	<img alt="{$alt}">
		<xsl:attribute name="src"><!-- 
			 --><xsl:value-of select="$config/system/content_domain" /><!--
			 --><xsl:value-of select="$config/system/images_bucket" />/<!-- 
			 --><xsl:value-of select="substring($id, string-length($id), 1)" />/<!-- 
			 --><xsl:value-of select="$id" /><!-- 
			 --><xsl:if test="$width!=''">w<xsl:value-of select="$width" /></xsl:if><!-- 
			 --><xsl:if test="$height!=''">h<xsl:value-of select="$height" /></xsl:if><!-- 
			 --><xsl:if test="$quality!=''">q<xsl:value-of select="$quality" /></xsl:if><!-- 
			 --><xsl:if test="$crop!=''">c</xsl:if><!-- 
			 -->.<!-- 
			 --><xsl:value-of select="$type" /><!-- 
		 --></xsl:attribute>
		<xsl:if test="$class!=''"><xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute></xsl:if>
		<xsl:if test="$style!=''"><xsl:attribute name="style"><xsl:value-of select="$style" /></xsl:attribute></xsl:if>
		<xsl:if test="$itemprop!=''"><xsl:attribute name="itemprop"><xsl:value-of select="$itemprop" /></xsl:attribute></xsl:if>
	</img>
</xsl:template>

<xsl:template name="image.bucket.src">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:param name="width" />
	<xsl:param name="height" />
	<xsl:param name="crop" />
	<xsl:param name="quality" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />
	<xsl:param name="itemprop" /><!--
	 
	 Imprimir ruta de la imagen 
	--><xsl:value-of select="$config/system/content_domain" /><!-- 
	 --><xsl:value-of select="$config/system/images_bucket" />/<!-- 
	 --><xsl:value-of select="substring($id, string-length($id), 1)" />/<!-- 
	 --><xsl:value-of select="$id" /><!-- 
	 --><xsl:if test="$width!=''">w<xsl:value-of select="$width" /></xsl:if><!-- 
	 --><xsl:if test="$height!=''">h<xsl:value-of select="$height" /></xsl:if><!-- 
	 --><xsl:if test="$quality!=''">q<xsl:value-of select="$quality" /></xsl:if><!-- 
	 --><xsl:if test="$crop!=''">c</xsl:if><!-- 
	 -->.<!-- 
	 --><xsl:value-of select="$type" />
</xsl:template>

<xsl:template name="image.src">
	<xsl:param name="id" />
	<xsl:param name="suffix" />
	<xsl:param name="type" /><!--
	--><xsl:value-of select="$config/system/content_domain"/><!-- 
	 --><xsl:if test="$config/system/domain/@subdir">/<xsl:value-of select="$config/system/domain/@subdir" /></xsl:if><!-- 
	 -->/<xsl:value-of select="$context/images_dir/option/@value"/><!-- 
	 -->/<xsl:value-of select="substring($id,string-length($id),1)"/><!-- 
	 -->/<xsl:value-of select="$id"/>.<xsl:value-of select="$type"/><!-- 
--></xsl:template>

<xsl:template match="m_image[not(@align = 'highlight')]">
	<xsl:variable name="image_id" select="@id" />
	<xsl:variable name="caption" select="@caption" />

	<!-- Solo hacemos algo si la imagen existe en las relaciones de la nota -->
	<xsl:if test="/xml/content/*/multimedias/images/image[@image_id = $image_id]">
		<xsl:variable name="image" select="/xml/content/*/multimedias/images/image[@image_id = $image_id]" />
		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="@size = 'small'">250</xsl:when>
				<xsl:when test="@size = 'medium'">440</xsl:when>
				<xsl:when test="@size = 'large'">980</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<div>
			<xsl:attribute name="class"><xsl:value-of select="@align"/><xsl:text> </xsl:text><xsl:value-of select="@size"/> m_image</xsl:attribute>
			<xsl:if test="@align = 'center'">
				<xsl:attribute name="style">text-align:center;margin:20px auto;</xsl:attribute>
			</xsl:if>
			<figure>
				<xsl:choose>
					<xsl:when test="@size != 'original'">
						<xsl:call-template name="image.bucket">
							<xsl:with-param name="id" select="@id" />
							<xsl:with-param name="type" select="@image_type" />
							<xsl:with-param name="width" select="$width" />
							<xsl:with-param name="class" select="@size" />
							<xsl:with-param name="alt" select="$image/title" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="image.bucket">
							<xsl:with-param name="id" select="@id" />
							<xsl:with-param name="type" select="@image_type" />
							<xsl:with-param name="class" select="@size" />
							<xsl:with-param name="alt" select="$image/title" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$caption = 1 or span[@class='epi'] != '' or $image/credit != ''">
					<figcaption>
						<xsl:if test="$caption = 1 or span[@class='epi'] != ''">
							<xsl:call-template name="remove.tags">
								<xsl:with-param name="string" select="$image/summary"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$image/credit != ''">
							<span class="credit">Foto: <xsl:value-of select="$image/credit" /></span>
						</xsl:if>
					</figcaption>
				</xsl:if>
			</figure>
		</div>
	</xsl:if>
</xsl:template>

<!-- Para las imagenes bomba del cuerpo no se hace nada -->
<xsl:template match="m_image[@align = 'highlight']"></xsl:template>

<!-- La portada se llama con call-template -->
<xsl:template name="m_image.highlight">
	<xsl:param name="m_image" />
	<xsl:param name="title" />
	<xsl:param name="header" />
	<xsl:if test="/xml/content/*/multimedias/images/image[@image_id = $m_image/@id]">
		<xsl:choose>
			<xsl:when test="$m_image/@size = 'bomb'">
				<div class="big">
					<xsl:call-template name="image.bucket">
						<xsl:with-param name="id" select="$m_image/@id" />
						<xsl:with-param name="type" select="$m_image/@image_type" />
						<xsl:with-param name="height">460</xsl:with-param>
						<!-- <xsl:with-param name="width">1680</xsl:with-param> -->
						<xsl:with-param name="crop">c</xsl:with-param>
						<xsl:with-param name="class">pic</xsl:with-param>
						<xsl:with-param name="itemprop">image</xsl:with-param>
						<xsl:with-param name="alt" select="$article/title" />
					</xsl:call-template>
					<div class="container">
						<h1 itemprop="headline">
							<xsl:if test="$header != ''">
								<small class="topic"><xsl:value-of select="$header" /></small>
							</xsl:if>
							<xsl:value-of select="$title" />
						</h1>
					</div>
				</div>
			</xsl:when>
			<xsl:when test="$m_image/@size = 'inline'">
				<div class="container big-column">
					<xsl:call-template name="image.bucket">
						<xsl:with-param name="id" select="$m_image/@id" />
						<xsl:with-param name="type" select="$m_image/@image_type" />
						<xsl:with-param name="height">460</xsl:with-param>
						<xsl:with-param name="width">980</xsl:with-param>
						<xsl:with-param name="crop">c</xsl:with-param>
						<xsl:with-param name="class">pic</xsl:with-param>
						<xsl:with-param name="itemprop">image</xsl:with-param>
						<xsl:with-param name="alt" select="$article/title" />
					</xsl:call-template>
					<h1 itemprop="headline">
						<xsl:if test="$header != ''">
							<small class="topic"><xsl:value-of select="$header" /></small>
						</xsl:if>
						<xsl:value-of select="$title" />
					</h1>
				</div>
			</xsl:when>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template match="m_gallery_embed">
	<xsl:param name="images" />
	<div id="gallery" class="{@item_id}-swiper swiper-container">
		<xsl:variable name="total" select="count(img)" />
		
		<div class="swiper-wrapper">
			<xsl:variable name="ids" select="@images" />
			<xsl:for-each select="/xml/content/*/multimedias/images/image">
				<xsl:sort order="ascending" select="@order" data-type="number" />
				<xsl:variable name="isSelected">
					<xsl:call-template name="checkid">
						<xsl:with-param name="list" select="$ids" />
						<xsl:with-param name="id" select="@image_id" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="contains($isSelected, '1')">
					<div class="swiper-slide panel">
						<!-- <span class="total">Foto <xsl:value-of select="position()" /> de <xsl:value-of select="$total" /></span> -->
							<xsl:variable name="id" select="@image_id" />
							<xsl:variable name="type" select="@type" />
							<xsl:choose>
								<xsl:when test="@height &lt; 500">
									<xsl:call-template name="image.bucket">
										<xsl:with-param name="id" select="@image_id" />
										<xsl:with-param name="type" select="@type" />
										<xsl:with-param name="width">1280</xsl:with-param>
										<xsl:with-param name="height">720</xsl:with-param>
										<xsl:with-param name="alt" select="title" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="image.bucket">
										<xsl:with-param name="id" select="@image_id" />
										<xsl:with-param name="type" select="@type" />
										<xsl:with-param name="height">720</xsl:with-param>
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
				</xsl:if>
			</xsl:for-each>
		</div>
		<div class="arrows">
			<div class="prev"><i class="fa fa-angle-left" aria-hidden="true">&#xa0;</i></div>
			<div class="next"><i class="fa fa-angle-right" aria-hidden="true">&#xa0;</i></div>
		</div>
	</div>
</xsl:template>



</xsl:stylesheet>