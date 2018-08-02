<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="cellsPerRow">4</xsl:variable>
<xsl:variable name="videosPerRow">2</xsl:variable>
<xsl:variable name="isHome">1</xsl:variable>

<!-- <xsl:variable name="eplanning">
	<xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$device" />/js/lib/eplanning.js
		</xsl:with-param>
	</xsl:call-template>
</xsl:variable> -->

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$device" />/assets/css/home.css
		</xsl:with-param>
	</xsl:call-template>

	<meta http-equiv="refresh" content="300" />
	<meta property="og:title" content="Vind"/>
	<meta property="og:image" content="{$device}/imgs/logos/fb.png" />
	<!-- <meta property="fb:admins" content="567857997"/> -->
	<meta property="fb:app_id" content="2250597608299564"/>
	<meta property="og:url" content="http://www.vind.com.ar"/>
	<meta property="og:type" content="website"/>
	<meta property="og:site_name" content="vind.com.ar"/>
	<script> <!-- 
		 -->requirejs(['app/controller/home']);<!-- 
     --></script>
	<script type="application/ld+json"><!-- 
	 -->{<!-- 
		 -->"@context": "http://schema.org",<!-- 
		 -->"@type": "WebSite",<!-- 
		 -->"url": "http://www.vind.com.ar/",<!-- 
		 -->"potentialAction": {<!-- 
			 -->"@type": "SearchAction",<!-- 
			 -->"target": "http://www.vind.com.ar/search/?q={search_term_string}",<!-- 
			 -->"query-input": "required name=search_term_string"<!-- 
		 -->}<!-- 
	 -->}<!-- 
	 --></script>
</xsl:variable>


<xsl:variable name="home" select="/xml/content/home" />
<xsl:template name="content">
	
	<main>
		<xsl:apply-templates select="$home/main/*" />

		<xsl:comment />
	</main>

	<!-- <xsl:call-template name="disqus.count.script" /> -->
</xsl:template>

</xsl:stylesheet>