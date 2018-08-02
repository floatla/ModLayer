<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="article" select="/xml/content/article" />
<xsl:variable name="role" select="$article/featuring/group/role" />

<xsl:variable name="created_at" select="$article/@created_at | $article/@creation_date" />

<xsl:variable name="isArticle">1</xsl:variable>
<xsl:variable name="title">
	<xsl:choose>
		<xsl:when test="$article/metatitle != ''">
			<xsl:value-of select="$article/metatitle" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$article/title" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="itemDescription">
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
</xsl:variable>

<xsl:variable name="dinamicHead">
	<title><xsl:value-of select="$title" /> | <xsl:value-of select="$config/system/applicationID" /></title>
	<meta name="description" content="{$itemDescription}" />
	<xsl:apply-templates select="$config/skin/header/*[not(name()='title')][not(@name='description')]" mode="htmlhead"/>
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<!-- <xsl:value-of select="$device" />/assets/css/article.print.css|media=print -->
			<xsl:value-of select="$device" />/assets/css/gallery.css
			<xsl:value-of select="$device" />/assets/css/video-js.css
			<xsl:value-of select="$device" />/assets/css/article.css|media=screen
		</xsl:with-param>
	</xsl:call-template>

	<link rel="canonical" href="{$itemURL}" />
	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:site" content="@vindcms" />
	<meta property="og:title" content="{$title}"/>
	<meta property="og:description" content="{$itemDescription}"/>
	<meta property="og:image">
		<xsl:attribute name="content">
			<xsl:call-template name="image.bucket.src">
				<xsl:with-param name="id" select="$article/multimedias/images/image/@image_id" />
				<xsl:with-param name="type" select="$article/multimedias/images/image/@type" />
				<xsl:with-param name="width">620</xsl:with-param>
				<xsl:with-param name="height">450</xsl:with-param>
			</xsl:call-template>
		</xsl:attribute>
	</meta>
	<!-- <meta property="fb:admins" content=""/> -->
	<meta property="fb:app_id" content="2250597608299564"/>
	<meta property="og:url" content="{$itemURL}"/>
	<meta property="og:type" content="article"/>
	<meta property="og:site_name" content="vind.com.ar"/>
	<meta name="DC.date.issued" content="{substring($created_at, 0, 11)}" />
	<xsl:variable name="sanitized">
		<xsl:call-template name="sanitize">
			<xsl:with-param name="string" select="/xml/content/article/categories/group/category/name"/>
		</xsl:call-template>
	</xsl:variable>
	<script type="application/ld+json"><!-- 
	 -->{<!-- 
		 -->"@context": "http://schema.org",<!-- 
		 -->"@type": "NewsArticle",<!-- 
		 -->"mainEntityOfPage":{<!-- 
			 -->"@type":"WebPage",<!-- 
			 -->"@id":"<xsl:value-of select="$itemURL" />"<!-- 
		 -->},<!-- 
		 -->"headline": "<xsl:value-of select="$article/title" />",<!-- 
		 -->"image": {<!-- 
			 -->"@type": "ImageObject",<!-- 
			 -->"url": "<xsl:call-template name="image.bucket.src">
				<xsl:with-param name="id" select="$article/multimedias/images/image/@image_id" />
				<xsl:with-param name="type" select="$article/multimedias/images/image/@type" />
				<xsl:with-param name="width">696</xsl:with-param>
				<xsl:with-param name="height">450</xsl:with-param>
			</xsl:call-template>",<!-- 
			 -->"height": 450,<!-- 
			 -->"width": 696<!-- 
		 -->},<!-- 
		 -->"datePublished": "<xsl:value-of select="substring-before($created_at, ' ')"  />T<xsl:value-of select="substring-after($created_at, ' ')"  />-03:00",<!-- 
		 -->"dateModified": "<xsl:value-of select="substring-before($article/@updated_at, ' ')"  />T<xsl:value-of select="substring-after($article/@updated_at, ' ')"  />-03:00",<!-- 
		 -->"author": {<!-- 
			 -->"@type": "Person",<!-- 
			 -->"name": "<xsl:value-of select="$article/@updated_by" />"<!-- 
		 -->},<!-- 
		 -->"publisher": {<!-- 
			 -->"@type": "Organization",<!-- 
			 -->"name": "Vind",<!-- 
			 -->"logo": {<!-- 
				 -->"@type": "ImageObject",<!-- 
				 -->"url": "<xsl:value-of select="$device"/>/assets/imgs/logos/vind_logo.svg",<!-- 
				 -->"width": 176,<!-- 
				 -->"height": 59<!-- 
			 -->}<!-- 
		 -->},<!-- 
		 -->"description": "<xsl:call-template name="escape.quotes">
		 						<xsl:with-param name="cadena" select="$article/summary"/>
		 					</xsl:call-template>"<!-- 
	 -->}<!-- 
	 --></script>

	<script>requirejs(['app/controller/article']);</script>
</xsl:variable>


<xsl:template name="content">
	<section class="viewitem">
		<span class="noprint articleURL"><!-- 
			 -->Para ver esta nota en internet ingrese a: <xsl:value-of select="$config/system/domain" />/a/<!-- 
			 --><xsl:value-of select="$article/@id" /><!-- 
		 --></span>

		<article class="content" itemscope="itemscope" itemtype="http://schema.org/NewsArticle">
			
			<!-- Microdata -->
			<meta itemscope="itemscope" itemprop="mainEntityOfPage" itemType="https://schema.org/WebPage" itemid="{$itemURL}" />
			<meta itemprop="datePublished" content="{substring-before($created_at, ' ')}T{substring-after($created_at, ' ')}-03:00" />
			<div itemprop="publisher" itemscope="itemscope" itemtype="https://schema.org/Organization" style="display:none;">
				<div itemprop="logo" itemscope="itemscope" itemtype="https://schema.org/ImageObject">
					<meta itemprop="url" content="{$device}/assets/imgs/logos/vind_logo.svg"/>
					<meta itemprop="width" content="176" />
					<meta itemprop="height" content="59" />
				</div>
				<meta itemprop="name" content="Vind" />
			</div>
			<meta itemprop="dateModified" content="{substring-before($article/@updated_at, ' ')}T{substring-after($article/@updated_at, ' ')}-03:00" />
			<!-- Microdata -->

			<xsl:if test="$article/content//m_image[@align='highlight']">
				<xsl:call-template name="m_image.highlight">
					<xsl:with-param name="m_image" select="$article/content/m_image[@align='highlight']"/>
					<xsl:with-param name="title" select="$article/title" />
				</xsl:call-template>
			</xsl:if>
			
			<section class="container">
				<header>
				
					<!--Si tiene columnista -->
					<xsl:if test="$role/role = 'Columnista'">
						<xsl:variable name="columnista_id" select="$role[role = 'Columnista']/data/@id" />
						<xsl:variable name="columnista" select="$role/data[$columnista_id = @id]" />

						<xsl:call-template name="person.avatar">
							<xsl:with-param name="person" select="$columnista"/>
							<xsl:with-param name="prefix">Por: </xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<!--Si tiene columnista -->

					<xsl:if test="$article/header != ''">
						<span class="topic"><xsl:value-of select="$article/header" /></span>
					</xsl:if>
					<xsl:if test="not($article/content//m_image[@align='highlight'])">
						<h1 itemprop="headline"><xsl:value-of select="$article/title" /></h1>
					</xsl:if>
					<xsl:if test="$article/summary != ''">
						<summary itemprop="description">
							<xsl:apply-templates select="$article/summary" />
						</summary>
					</xsl:if>

					<!--Si tiene autor -->
					<xsl:if test="$role/role = 'Autor'">
						<xsl:variable name="author_id" select="$role[role = 'Autor']/data/@id" />
						<xsl:variable name="author" select="$role/data[$author_id = @id]" />
						<div itemprop="author" itemscope="itemscope" itemtype="https://schema.org/Person" style="display:none;">
							<span itemprop="name"><xsl:value-of select="$author/title" /></span>
						</div>
						<span class="author">
							Por <strong><xsl:value-of select="$author/title" /></strong>&#xa0;&#xa0;
						</span>
					</xsl:if>
					<!--Si tiene autor -->

					<time>
						<xsl:call-template name="date">
							<xsl:with-param name="date" select="$created_at" />
						</xsl:call-template>
					</time>
				</header>

				<div class="bar floatFix">
					<div class="toggleFont">
						<a href="#" class="imprimir" title="Imprimir nota" onclick="javascript:print();">
							<i class=" fa fa-print"><xsl:comment/></i>
						</a>
						<button type="button" class="ampliar" title="Agrandar tamaño de letra"><!-- 
							 -->A <i class="fa fa-plus"><xsl:comment/></i>
						</button>
						<button type="button" class="reducir" title="Achicar tamaño de letra"><!-- 
							 -->A <i class="fa fa-minus"><xsl:comment/></i>
						</button>
					</div>
					
					
					<xsl:call-template name="share.box" />
				</div>

				<div itemprop="image" itemscope="itemscope" itemtype="https://schema.org/ImageObject" style="display:none">
					<meta itemprop="url">
						<xsl:attribute name="content">
							<xsl:call-template name="image.bucket.src">
								<xsl:with-param name="id" select="$article/multimedias/images/image/@image_id" />
								<xsl:with-param name="type" select="$article/multimedias/images/image/@image_type" />
								<xsl:with-param name="width">696</xsl:with-param>
								<xsl:with-param name="height">450</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</meta>
					<meta itemprop="width" content="696" />
					<meta itemprop="height" content="450" />
				</div>
				<div itemprop="author" itemscope="itemscope" itemtype="https://schema.org/Person" style="display:none;">
					<span itemprop="name"><xsl:value-of select="$article/@updated_by" /></span>
				</div>

				<!-- contenido -->
				<xsl:apply-templates select="$article/content"/>
				<!-- /contenido -->

				<xsl:if test="$role/role = 'Aparece en la nota'">
					<div class="aparecen floatFix">
						<xsl:variable name="count" select="count($role/role[string()='Aparece en la nota'])" />
						<xsl:choose>
							<xsl:when test="$count = 1">
								<h3 class="gray-title large">Aparece en la nota:</h3>
							</xsl:when>
							<xsl:otherwise>
								<h3 class="gray-title large">Aparecen en la nota:</h3>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="$role/role[string()='Aparece en la nota']">
							<xsl:variable name="person_id" select="../data/@id" />
							<xsl:variable name="person" select="../data[$person_id = @id]" />
							<xsl:variable name="personurl">
								<xsl:call-template name="person.url">
									<xsl:with-param name="id" select="$person/@id" />
									<xsl:with-param name="title" select="$person/title" />
								</xsl:call-template>
							</xsl:variable>
							<!-- <a href="{$personurl}" class="aparece"><xsl:value-of select="$person/title" /></a> -->
							<div class="aparece"><xsl:value-of select="$person/title" /></div>
						</xsl:for-each>
					</div>
				</xsl:if>


				<xsl:if test="$article/tags/tag != ''">
					<div class="tags floatFix">
						<h3 class="gray-title large">Temas Relacionados</h3>
						<xsl:for-each select="$article/tags/tag">
							<xsl:variable name="tagurl">
								<xsl:call-template name="tag.url">
									<xsl:with-param name="tag" select="." />
								</xsl:call-template>
							</xsl:variable>
							<a href="{$tagurl}" class="tag"><xsl:value-of select="tag_name" /></a>	
						</xsl:for-each>
					</div>
				</xsl:if>
				
			
			</section>
		</article>


		<section class="container">
			<xsl:apply-templates select="content/article/relations" mode="related"/>
		

			<xsl:variable name="thisID" select="$content/article/@id" />
			<xsl:if test="count($content/collection/object[not(@id = $thisID)]) &gt; 0">
				<section id="suggested">
					<h3 class="gray-title large">Últimas noticias de <xsl:value-of select="$content/article/categories/group/category/name" /></h3>
					
					<xsl:for-each select="$content/collection/object[not(@id = $thisID)][position() &lt;= 4]">
						<article>
							<xsl:if test="position() = 1">
								<xsl:attribute name="class">first</xsl:attribute>
							</xsl:if>
							<xsl:if test="position() = last()">
								<xsl:attribute name="class">last</xsl:attribute>
							</xsl:if>

							<xsl:variable name="aurl">
								<xsl:call-template name="article.url">
									<xsl:with-param name="id" select="@id" />
									<xsl:with-param name="title" select="title" />
								</xsl:call-template>
							</xsl:variable>
							<a href="{$aurl}">
								<xsl:if test="multimedias/images/image/@image_id">
									<xsl:call-template name="photo.bucket">
										<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
										<xsl:with-param name="type" select="multimedias/images/image/@type" />
										<xsl:with-param name="width">194</xsl:with-param>
										<xsl:with-param name="height">220</xsl:with-param>
										<xsl:with-param name="class">pic rounded</xsl:with-param>
										<xsl:with-param name="alt" select="title" />
									</xsl:call-template>
								</xsl:if>
								<!-- <span class="category">
									<strong>
										<xsl:value-of select="categories/group/category/name" /><xsl:comment />
									</strong>
								</span> -->
								<h3>
									<xsl:if test="not(multimedias/images/image/@image_id)">
										<xsl:attribute name="class">nopic</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="title" />
								</h3>
								<summary>
									<p>
										<xsl:call-template name="cortarCadena">
											<xsl:with-param name="cadena" select="summary" />
											<xsl:with-param name="cantidad">150</xsl:with-param>
										</xsl:call-template>
									</p>
									<!-- <xsl:apply-templates select="summary" /> -->
								</summary>
							</a>
						</article>
					</xsl:for-each>
				</section>
			</xsl:if>

			<xsl:if test="$article/show_comments = '1'">
				<div id="disqus_thread"><xsl:comment /></div>
			    <script type="text/javascript"><!-- 
			        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */ 
			         -->var disqus_shortname  = 'nortechaco';<!--  // required: replace example with your forum shortname
			         -->var disqus_identifier = '<xsl:value-of select="$article/@id" />';<!--
			         -->var disqus_title = '<xsl:value-of select="$article/title" />';<!--
			         -->var disqus_url = '<xsl:value-of select="$config/system/domain" />/a/<xsl:value-of select="$article/@id" />';<!--
			         /* * * DON'T EDIT BELOW THIS LINE * * */ 
			        -->(function() {<!--
			            -->var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;<!--
			            -->dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';<!--
			            -->(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);<!--
			        -->})();<!--
			    --></script>
			    <!-- <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript> -->
			    <!-- <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a> -->
			</xsl:if>
		</section>

	</section>


	<xsl:choose>
		<xsl:when test="$article/categories/group/category/name">
			<script type="text/javascript"><!-- 
				 -->var category = "<xsl:call-template name="sanitize"><xsl:with-param name="string" select="$article/categories/group/category/name" /></xsl:call-template>";<!-- 
				 -->var id = "<xsl:value-of select="$article/@id" />";<!-- 
				 -->ga('send', 'pageview', '/'+ category + '/article/' + id);<!-- 
			 --></script>
		</xsl:when>
		<xsl:otherwise>
			<script type="text/javascript"><!-- 
				 -->var id = "<xsl:value-of select="$article/@id" />";<!-- 
				 -->ga('send', 'pageview', '/article/' + id);<!-- 
			 --></script>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>


<!-- Recuadros en Nota -->
<xsl:template match="recuadro" >
	<div>
		<xsl:attribute name="class">recuadro <xsl:value-of select="@class"/></xsl:attribute>
		<xsl:apply-templates select="p|h1|h2|h3|h4" />
	</div>	
</xsl:template>

</xsl:stylesheet>