<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="article" select="/xml/content/article" />
<xsl:variable name="role" select="$article/featuring/group/role" />

<xsl:variable name="created_at" select="$article/@created_at | $article/@creation_date" />

<xsl:variable name="eplanning">
	<xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$device" />/js/lib/eplanning.js
		</xsl:with-param>
	</xsl:call-template>
	<script>
		eplArgs.sec = "InnerNotes";
		eplArgs.eIs = ["In2_300x250", "In1_300x250"];
	</script>
</xsl:variable>

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
			<!-- <xsl:value-of select="$device" />/js/lib/jplayer/jplayer.blue.monday.css -->
			<xsl:value-of select="$device" />/assets/css/article.css|media=screen
			<xsl:value-of select="$device" />/assets/css/article.print.css|media=print
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
	<!-- <script type="text/javascript" src="{$skinpath}/js/google_dfp_script.js">&#xa0;</script>
	<script type="text/javascript" src="{$skinpath}/js/google_dfp_page.js">&#xa0;</script> -->
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
	<main class="viewitem">
		<span class="noprint articleURL"><!-- 
			 -->Para ver esta nota en internet ingrese a: <xsl:value-of select="$config/system/domain" />/a/<!-- 
			 --><xsl:value-of select="$article/@id" /><!-- 
		 --></span>

		 <article class="floatFix" itemscope="itemscope" itemtype="http://schema.org/NewsArticle">

			<!-- Microdata -->
			<meta itemscope="itemscope" itemprop="mainEntityOfPage" itemType="https://schema.org/WebPage" itemid="{$itemURL}" />
			<meta itemprop="datePublished" content="{substring-before($created_at, ' ')}T{substring-after($created_at, ' ')}-03:00" />
			<div itemprop="publisher" itemscope="itemscope" itemtype="https://schema.org/Organization" style="display:none;">
				<div itemprop="logo" itemscope="itemscope" itemtype="https://schema.org/ImageObject">
					<meta itemprop="url" content="{$device}/assets/imgs/logos/vind_logo.svg" />
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

					<time title="Fecha de creación">
						<i class="fa fa-dot-circle-o fa-lg" aria-hidden="true"><xsl:comment /></i>&#xa0;
						<xsl:call-template name="date">
							<xsl:with-param name="date" select="$created_at" />
						</xsl:call-template>
					</time>



				</header>

				<div class="bar floatFix">
					<!-- <xsl:call-template name="share.box" /> -->
					<xsl:call-template name="social.article.btns">
						<xsl:with-param name="item" select="$article" />
					</xsl:call-template>
					<div class="toggleFont">
						<a href="#" class="imprimir" title="Imprimir nota" onclick="javascript:print();">
							<i class=" fa fa-print"><xsl:comment/></i>
						</a>
						<button type="button" class="ampliar" title="Agrandar tamaño de letra">
							A <i class="fa fa-plus"><xsl:comment/></i>
						</button>
						<button type="button" class="reducir" title="Achicar tamaño de letra">
							A <i class="fa fa-minus"><xsl:comment/></i>
						</button>
					</div>
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
				<!-- <div itemprop="author" itemscope="itemscope" itemtype="https://schema.org/Person" style="display:none;">
					<span itemprop="name"><xsl:value-of select="$article/@updated_by" /></span>
				</div> -->

				<!-- Path -->
				<xsl:call-template name="breadcrumb">
					<xsl:with-param name="item" select="$article" />
				</xsl:call-template>
				<!-- Path -->

				<!-- contenido -->
				<section class="body">
					<xsl:apply-templates select="$article/content" />
				</section>
				<!-- /contenido -->
			
				<xsl:if test="$article/featuring/group//role[role = 'Aparece en la Nota']">
					<div class="aparecen floatFix">
						<xsl:variable name="count" select="count($article/featuring/group//role[role = 'Aparece en la Nota'])" />
						<xsl:choose>
							<xsl:when test="$count = 1">
								<h3 class="gray-title large">Aparece en esta Nota:</h3>
							</xsl:when>
							<xsl:otherwise>
								<h3 class="gray-title large">Aparecen en esta nota:</h3>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="$article/featuring/group//role[role = 'Aparece en la Nota']">
							<xsl:call-template name="person.avatar">
								<xsl:with-param name="person" select="data"/>
							</xsl:call-template>
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
						
				<xsl:if test="$article/parent/module = 'suple'">
					<div class="suple-related floatFix" style="margin-bottom:0;">
						<xsl:variable name="surl">
							<xsl:call-template name="suple.url">
								<xsl:with-param name="id" select="$article/parent/@id" />
								<xsl:with-param name="title" select="$article/parent/title" />
							</xsl:call-template>
						</xsl:variable>
						<a href="{$surl}">
							<xsl:call-template name="image.bucket">
								<xsl:with-param name="id" select="$article/parent/multimedias/images/image/@image_id" />
								<xsl:with-param name="type" select="$article/parent/multimedias/images/image/@type" />
								<xsl:with-param name="width">260</xsl:with-param>
								<xsl:with-param name="height">365</xsl:with-param>
								<xsl:with-param name="crop">c</xsl:with-param>
								<xsl:with-param name="class">poster left</xsl:with-param>
								<xsl:with-param name="alt" select="$article/parent/title" />
							</xsl:call-template>
							<div class="info right">
								<p>
									Esta nota fué publicada en el suplemento <xsl:value-of select="$article/parent/categories/group/category[@parent='23']/name" /> del día 
									<xsl:call-template name="date">
										<xsl:with-param name="date" select="$article/parent/@created_at" />
									</xsl:call-template>.
								</p>
								<h3><xsl:value-of select="$article/parent/title" /></h3>
								<span>Ver todas las notas de esta edición »</span>
							</div>
						</a>
					</div>
				</xsl:if>
			
				 <xsl:if test="$article/latitud != '' and $article/longitud != ''">
					 <div style="display:none;" itemprop="contentLocation"><!-- 
						 --><div itemscope="itemscope" itemtype="http://schema.org/Place"><!-- 
							 --><div itemprop="geo" itemscope="itemscope" itemtype="http://schema.org/GeoCoordinates"><!-- 
								 --><meta itemprop="latitude" content="{$article/latitud}" /><!-- 
				    			 --><meta itemprop="longitude" content="{$article/longitud}" /><!-- 
							 --></div><!-- 
						 --></div><!-- 
					 --></div>
				</xsl:if>

			</section>

		</article>

		<section class="container">
			<xsl:apply-templates select="content/article/relations" mode="related"/>
		</section>

		<xsl:if test="(not($role/role = 'Columnista') and not($article/categories//category[@category_id=43])) and ($article/@comments = 1 or not($article/@comments))">
			<section class="container">
				<div id="disqus_thread"><xsl:comment /></div>
			    <script type="text/javascript"><!-- 
			        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */ 
			         -->var disqus_shortname  = "nortechaco";<!--  // required: replace example with your forum shortname
			         -->var disqus_identifier = "<xsl:value-of select="$article/@id" />";<!--
			         -->var disqus_title = "<xsl:call-template name="escape.quotes">
			         							<xsl:with-param name="string" select="$article/title"/>
			         						</xsl:call-template>";<!-- 
			         <xsl:value-of select="$article/title" />
			         -->var disqus_url = "<xsl:value-of select="$config/system/domain" />/a/<xsl:value-of select="$article/@id" />";<!--
			         /* * * DON'T EDIT BELOW THIS LINE * * */ 
			        -->(function() {<!--
			            -->var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;<!--
			            -->dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';<!--
			            -->(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);<!--
			        -->})();<!--
			    --></script>
			    <!-- <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript> -->
			    <!-- <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a> -->
			</section>
		</xsl:if>
	</main>

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