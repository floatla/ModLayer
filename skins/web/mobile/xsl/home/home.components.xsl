<?xml version="1.0" encoding="UTF-8"?> <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<xsl:template name="article.time">
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
</xsl:template>

<!-- Template base de nota -->
<xsl:template name="article">
	<xsl:param name="item" />
	<xsl:param name="showPlayIcon" />
	<xsl:param name="classPrefix" />
	<xsl:param name="titlelimit" />
	<xsl:param name="summarylimit">130</xsl:param>
	<article itemscope="itemscope" itemtype="http://schema.org/NewsArticle">
		<xsl:if test="$classPrefix != ''">
			<xsl:attribute name="class"><xsl:value-of select="$classPrefix" />-<xsl:value-of select="position()" /></xsl:attribute>
		</xsl:if>
		<meta itemscope="itemscope" itemprop="mainEntityOfPage"  itemType="https://schema.org/WebPage" itemid="{$config/system/domain}{$item/url}"/>
		<a href="{$item/url}" itemprop="url">
			<xsl:if test="$item/rotator/image">
				<xsl:call-template name="rotator">
					<xsl:with-param name="item" select="$item" />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$item/@image_id != 0">
				<div class="article-image">
					<xsl:if test="$item/has_video = 1 or $showPlayIcon = '1'">
						<span class="play-btn">
							<i class="fa fa-play">&#xa0;</i>
						</span>
					</xsl:if>
					<xsl:call-template name="image.bucket.lazy">
						<xsl:with-param name="id" select="$item/@image_id" />
						<xsl:with-param name="type" select="$item/@image_type" />
						<xsl:with-param name="width">420</xsl:with-param>
						<xsl:with-param name="height">300</xsl:with-param>
						<xsl:with-param name="crop">c</xsl:with-param>
						<xsl:with-param name="class">pic</xsl:with-param>
						<xsl:with-param name="alt" select="$item/title" />
					</xsl:call-template>
				</div>
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
			<xsl:call-template name="article.time">
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


<xsl:template match="tags" mode="today-topics">
	<xsl:if test="item">
		<div class="today-topics">
			<div class="container">
				<span>Temas de hoy:</span>
				<xsl:for-each select="item">
					<a href="{url}"><xsl:value-of select="title" /></a>
				</xsl:for-each>
			</div>
		</div>
	</xsl:if>
</xsl:template>


<xsl:template match="bomba">
	<xsl:if test="item">
		<xsl:variable name="item" select="item" />
		<xsl:variable name="backImg">
			<xsl:call-template name="image.bucket.src">
				<xsl:with-param name="id" select="item/@image_id" />
				<xsl:with-param name="type" select="item/@image_type" />
			</xsl:call-template>
		</xsl:variable>
			<section class="bomb">
				<xsl:attribute name="style">background-image:url(<xsl:value-of select="$backImg" />);</xsl:attribute>
				<div class="container">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="item"/>
					</xsl:call-template>
				</div>
			</section>
	</xsl:if>
</xsl:template>

<xsl:template match="rieles">
	<xsl:if test="center/item">
		<section id="rails">
			<div class="container">
				<div class="middle">
					<xsl:for-each select="center/item">
						<xsl:call-template name="article">
							<xsl:with-param name="item" select="."/>
						</xsl:call-template>
					</xsl:for-each>
				</div>
				<xsl:for-each select="left/item">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="."/>
					</xsl:call-template>
				</xsl:for-each>

				<!-- Eplanning B-Mob Up -->
				<!-- <div class="ad300x100">
					<script type="text/javascript">eplAD4M("MobileUpB");</script>
				</div> -->
				<!-- Eplanning B-Mob Up -->
				
				<xsl:for-each select="right/item">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</section>
	</xsl:if>
</xsl:template>

<xsl:template match="apertura">
	<xsl:if test="./item">
		<section id="articles-c3">
			<div class="container">
				<xsl:for-each select="item">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="."/>
						<xsl:with-param name="titlelimit">70</xsl:with-param>
						<xsl:with-param name="summarylimit">90</xsl:with-param>
						<xsl:with-param name="classPrefix">c3</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</section>
	</xsl:if>
</xsl:template>

<xsl:template name="rotator">
	<xsl:param name="item" />
	<div id="r_{$item/@element_id}" class="rotator swiper-container">
		<div class="swiper-wrapper">
			<xsl:for-each select="$item/rotator/image">
				<div class="swiper-slide">
					<xsl:call-template name="image.bucket">
						<xsl:with-param name="id" select="image_id" />
						<xsl:with-param name="type" select="image_type" />
						<xsl:with-param name="width" select="$item/params/param[@name='image_width']/@value" />
						<xsl:with-param name="height" select="$item/params/param[@name='image_height']/@value" />
						<xsl:with-param name="crop">c</xsl:with-param>
						<xsl:with-param name="class">pic</xsl:with-param>
						<xsl:with-param name="alt" select="$item/title" />
					</xsl:call-template>
				</div>
			</xsl:for-each>
		</div>
		 <!-- Add Pagination -->
		<div class="swiper-pagination">&#xa0;</div>
        <!-- Add Arrows -->
		<div class="swiper-button-next"><i class="fa fa-angle-right" aria-hidden="true">&#xa0;</i></div>
		<div class="swiper-button-prev"><i class="fa fa-angle-left" aria-hidden="true">&#xa0;</i></div>
	</div>
</xsl:template>


<xsl:template match="box">
	<div class="content-box">
		<div class="container">
			<xsl:variable name="boxTitle"><xsl:value-of select="@param_title" /></xsl:variable>
			<xsl:if test="$home/params/*[name() = $boxTitle] != ''">
				<header class="floatFix">
					<xsl:if test="tags/item">
						<div class="right tags">
							<xsl:for-each select="tags/item">
								<a href="{url}"><xsl:value-of select="title" /></a>
							</xsl:for-each>
						</div>
					</xsl:if>
					<h1><xsl:value-of select="$home/params/*[name() = $boxTitle]" /></h1>
				</header>
			</xsl:if>
			<div class="floatFix">
				<section class="left">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="large/item"/>
						<xsl:with-param name="classPrefix">box</xsl:with-param>
					</xsl:call-template>
				</section>
				<section class="right">
					<xsl:for-each select="regular/item">
						<div class="item">
							<xsl:if test="position() mod 2 = 0">
								<xsl:attribute name="class">item alt</xsl:attribute>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="@type = 'article'">
									<xsl:call-template name="article">
										<xsl:with-param name="item" select="."/>
										<xsl:with-param name="classPrefix">box</xsl:with-param>
										<xsl:with-param name="summarylimit">300</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="@type = 'promo'">
									<div class="content-ad">
										<xsl:value-of select="element/html" disable-output-escaping="yes"/>
									</div>
								</xsl:when>
							</xsl:choose>
						</div>
					</xsl:for-each>
				</section>
			</div>
		</div>
	</div>
</xsl:template>


<xsl:template match="row">
	<xsl:for-each select="item">
		<xsl:call-template name="article">
			<xsl:with-param name="item" select="."/>
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>

<xsl:template match="color">
	<xsl:variable name="id">pos-<xsl:value-of select="position()" /></xsl:variable>
	<section class="content-color">
		<xsl:attribute name="id"><xsl:value-of select="$id" /></xsl:attribute>
		<xsl:attribute name="style">background-color:<xsl:value-of select="@background" /></xsl:attribute>
		<div class="container floatFix">
			<header>
				<xsl:if test="@foreground != ''">
					<xsl:attribute name="style">background:<xsl:value-of select="@foreground" />;</xsl:attribute>
				</xsl:if>
				<xsl:variable name="boxTitle"><xsl:value-of select="@param_title" /></xsl:variable>
				<xsl:value-of select="$home/params/*[name()=$boxTitle]"  />
				<xsl:comment />
			</header>
			<div class="on-top floatFix">
				<xsl:for-each select="large/item | side/item">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="."/>
						<xsl:with-param name="classPrefix">pos</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</div>
			<div class="list floatFix">
				<xsl:for-each select="articles/item">
					<xsl:call-template name="article">
						<xsl:with-param name="item" select="."/>
						<xsl:with-param name="classPrefix">pos</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</div>
	</section>
	<xsl:choose>
		<xsl:when test="$id = 'pos-5'">
			<div class="ad-mega">
				<script type="text/javascript">eplAD4M("HiImpactLayer");</script>
			</div>
		</xsl:when>
		<xsl:when test="$id = 'pos-10'">
			<!-- Eplanning E-Mob Down -->
				<!-- <div class="ad300x100">
					<script type="text/javascript">eplAD4M("MobileDwnE");</script>
				</div> -->
			<!-- Eplanning E-Mob Down -->
		</xsl:when>
	</xsl:choose>
</xsl:template>

<!-- <xsl:template match="gallery">
	<section class="content-color gallery">
		<xsl:attribute name="style">background-color:<xsl:value-of select="@background" /></xsl:attribute>
		<div class="container floatFix">
			<header>
				<xsl:if test="@foreground != ''">
					<xsl:attribute name="style">background:<xsl:value-of select="@foreground" />;</xsl:attribute>
				</xsl:if>
				<xsl:variable name="boxTitle"><xsl:value-of select="@param_title" /></xsl:variable>
				<xsl:value-of select="$home/params/*[name()=$boxTitle]"  />
				<xsl:comment />
			</header>
			<div class="on-top floatFix">
				<xsl:for-each select="box/item | side/item">
					<xsl:choose>
						<xsl:when test="@type = 'gallery'">
							<div class="brick">
								<xsl:call-template name="article">
									<xsl:with-param name="item" select="."/>
									<xsl:with-param name="classPrefix">pos</xsl:with-param>
								</xsl:call-template>
								<a href="{url}">
									<span class="mask">
										<h3><xsl:value-of select="title" /></h3>
									</span>
								</a>
							</div>
						</xsl:when>
						<xsl:when test="@type = 'promo'">
							<div class="content-ad">
								<xsl:value-of select="element/html" disable-output-escaping="yes"/>
							</div>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</div>
		</div>
	</section>
</xsl:template> -->

<xsl:template match="play">
	<xsl:if test="item">
		<section class="n-play">
			<div class="container">
				<div class="wt floatFix">
					<header><h2>Norte Play</h2></header>
					<xsl:for-each select="item">
						<xsl:call-template name="article">
							<xsl:with-param name="item" select="."/>
							<xsl:with-param name="showPlayIcon">1</xsl:with-param>
							<xsl:with-param name="classPrefix">pos</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</div>
		</section>
	</xsl:if>
</xsl:template>

<xsl:template match="grid1">
	
	<!-- Eplanning C-Mob Mid -->
		<!-- <div class="ad300x100">
			<script type="text/javascript">eplAD4M("MobileMidC");</script>
		</div> -->
	<!-- Eplanning C-Mob Mid -->
	
	<xsl:if test=".//item">
		<section class="grid-1 container floatFix">
			<xsl:for-each select="column">
				<section class="column">
					<xsl:for-each select="item">
						<xsl:choose>
							<xsl:when test="@type = 'article'">
								<xsl:call-template name="article">
									<xsl:with-param name="item" select="."/>
									<xsl:with-param name="summarylimit">300</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="@type = 'promo'">
								<div class="content-ad">
									<xsl:value-of select="element/html" disable-output-escaping="yes"/>
								</div>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</section>
			</xsl:for-each>

			<aside>
				<!-- Tapa -->
				<xsl:apply-templates select="aside/frontpage" />

				<div class="editorial">
					<header><i class="fa fa-paragraph">&#xa0;</i> Editorial</header>
					<xsl:if test="aside/article/item">
						<xsl:call-template name="article">
							<xsl:with-param name="item" select="aside/article/item"/>
							<xsl:with-param name="summarylimit">200</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</div>

				<xsl:if test="aside/banner/item">
					<div class="content-ad">
						<xsl:value-of select="aside/banner/item/element/html" disable-output-escaping="yes"/>
					</div>
				</xsl:if>
			</aside>
		</section>
	</xsl:if>
</xsl:template>

<xsl:template match="frontpage">
	<div class="frontpage">
		<header>
			<xsl:call-template name="html.titles">
				<xsl:with-param name="string" select="$home/params/frontpage"/>
			</xsl:call-template>
		</header>
		<xsl:call-template name="image.bucket.lazy">
			<xsl:with-param name="id" select="item/@image_id" />
			<xsl:with-param name="type" select="item/@image_type" />
			<xsl:with-param name="width" select="item/params/param[@name='image_width']/@value" />
			<xsl:with-param name="height" select="item/params/param[@name='image_height']/@value" />
			<!-- <xsl:with-param name="crop">c</xsl:with-param> -->
		</xsl:call-template>
		<a href="/tapa-del-dia/"><i class="fa fa-chevron-right">&#xa0;</i>Ver Anteriores</a>
	</div>
</xsl:template>

<xsl:template match="mosaic">
	<section class="mosaic">
		<div class="container">
			<xsl:for-each select="item">
				<xsl:choose>
					<xsl:when test="@type = 'article'">
						<xsl:call-template name="article">
							<xsl:with-param name="item" select="."/>
							<xsl:with-param name="classPrefix">pos</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="@type = 'promo'">
						<div class="content-ad">
							<xsl:value-of select="element/html" disable-output-escaping="yes"/>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</div>
	</section>
</xsl:template>

<xsl:template match="suple">
	<section class="suple">
		<div class="container">
			<header>Suplementos</header>
			<div class="floatFix">
				<xsl:for-each select="item">
					<article itemscope="itemscope" itemtype="http://schema.org/NewsArticle">
						<!-- <xsl:if test="$classPrefix != ''">
							<xsl:attribute name="class"><xsl:value-of select="$classPrefix" />-<xsl:value-of select="position()" /></xsl:attribute>
						</xsl:if> -->
						<meta itemscope="itemscope" itemprop="mainEntityOfPage"  itemType="https://schema.org/WebPage" itemid="{$config/system/domain}{url}"/>
						<a href="{url}" itemprop="url">
							<xsl:if test="rotator/image">
								<xsl:call-template name="rotator">
									<xsl:with-param name="item" select="." />
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="@image_id != 0">
								<xsl:call-template name="image.bucket.lazy">
									<xsl:with-param name="id" select="@image_id" />
									<xsl:with-param name="type" select="@image_type" />
									<xsl:with-param name="width">360</xsl:with-param>
									<xsl:with-param name="height">480</xsl:with-param>
									<xsl:with-param name="crop">c</xsl:with-param>
									<xsl:with-param name="class">pic</xsl:with-param>
									<xsl:with-param name="alt" select="title" />
								</xsl:call-template>
							</xsl:if>
						</a>
						<div class="article-info floatFix">
							<xsl:call-template name="item.category">
								<xsl:with-param name="item" select="." />
							</xsl:call-template>
							<xsl:call-template name="social.article.btns">
								<xsl:with-param name="item" select="." />
							</xsl:call-template>
							<xsl:call-template name="article.time">
								<xsl:with-param name="item" select="." />
							</xsl:call-template>
						</div>
						<div itemprop="image" itemscope="itemscope" itemtype="https://schema.org/ImageObject" style="display:none">
							<meta itemprop="url">
								<xsl:attribute name="content">
									<xsl:call-template name="image.bucket.src">
										<xsl:with-param name="id" select="@image_id" />
										<xsl:with-param name="type" select="@image_type" />
										<xsl:with-param name="width" select="params/param[@name='image_width']/@value" />
										<xsl:with-param name="height" select="params/param[@name='image_height']/@value" />
									</xsl:call-template>
								</xsl:attribute>
							</meta>
							<meta itemprop="width" content="{params/param[@name='image_width']/@value}" />
							<meta itemprop="height" content="{params/param[@name='image_height']/@value}" />
						</div>
						<div itemprop="author" itemscope="itemscope" itemtype="https://schema.org/Person" style="display:none;">
							<span itemprop="name">Editor Web</span>
						</div>
						<xsl:call-template name="article.microdata">
							<xsl:with-param name="item" select="." />
						</xsl:call-template>
					</article>
				</xsl:for-each>	
			</div>
		</div>
	</section>
	<!-- Eplanning F-Mob Bottom -->
		<!-- <div class="ad320x50">
			<script type="text/javascript">eplAD4M("MobileBottom");</script>
		</div> -->
	<!-- Eplanning F-Mob Bottom -->
</xsl:template>

<xsl:template match="authors">
	<xsl:if test="//item">
		<div class="content-authors">
			<header>
				<span class="tip">&#xa0;</span>
				<xsl:value-of select="$home/params/title_authors" />
				<span class="tip">&#xa0;</span>
			</header>
			<div class="container floatFix">
				<xsl:for-each select="author">
					<section class="person">
						<div itemprop="author" itemscope="itemscope" itemtype="https://schema.org/Person">
							<a href="{person/item/url}">
								<xsl:call-template name="image.bucket">
									<xsl:with-param name="id" select="person/item/@image_id" />
									<xsl:with-param name="type" select="person/item/@image_type" />
									<xsl:with-param name="width" select="person/item/params/param[@name='image_width']/@value" />
									<xsl:with-param name="height" select="person/item/params/param[@name='image_height']/@value" />
									<xsl:with-param name="crop">c</xsl:with-param>
									<xsl:with-param name="class">pic</xsl:with-param>
									<xsl:with-param name="alt" select="title" />
									<xsl:with-param name="itemprop">image</xsl:with-param>
								</xsl:call-template>
								<h1 itemprop="name">
									<xsl:value-of select="person/item/title" />
								</h1>
							</a>
						</div>
						<div class="person-social">
							<xsl:if test="person/item/element/facebook != ''">
								<a href="{person/item/element/facebook}" target="_new" title="Facebook"><i class="fa fa-facebook">&#xa0;</i></a>
							</xsl:if>
							<xsl:if test="person/item/element/twitter != ''">
								<a href="{person/item/element/twitter}" target="_new" title="Twitter"><i class="fa fa-twitter">&#xa0;</i></a>
							</xsl:if>
							<a href="#" target="_new" title="Rss"><i class="fa fa-rss">&#xa0;</i></a>
							<xsl:comment />
						</div>

						<xsl:for-each select="articles/item">
							<article>
								<h3>
									<a href="{url}">
										<xsl:value-of select="title"  />
									</a>
								</h3>
							</article>
						</xsl:for-each>
					</section>
				</xsl:for-each>
			</div>
		</div>
	</xsl:if>

	<!-- Eplanning D-Mob Mid -->
		<!-- <div class="ad300x100">
			<script type="text/javascript">eplAD4M("MobileMidD");</script>
		</div> -->
	<!-- Eplanning D-Mob Mid -->

</xsl:template>
</xsl:stylesheet>