<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="cellsPerRow">2</xsl:variable>

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$device" />/assets/css/home.css
		</xsl:with-param>
	</xsl:call-template>
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

	<!-- TAGS -->
	<xsl:apply-templates select="$home/tags" mode="today-topics" />

	<div class="subtop floatFix">
		<!-- <xsl:call-template name="publication.time" />  -->
		<time> 
			Resistencia <br/> 
			<xsl:call-template name="date">
				<xsl:with-param name="date" select="$fechaActual" />
				<xsl:with-param name="day" select="$diaActual" />
				<xsl:with-param name="showYear">0</xsl:with-param>
			</xsl:call-template> 
		</time>
		<div class="weather">
			<xsl:variable name="weather" select="/xml/context/weather/current_observation" /> 
			<xsl:choose>
				<xsl:when test="substring($horaActual, 1, 2) &gt;= 20 or substring($horaActual, 1, 2) &lt;= 6">
					<xsl:attribute name="style"><!-- 
						 -->background:url('<xsl:value-of select="$config/system/images_domain"/><xsl:value-of select="$skinpath"/>/assets/imgs/weather/medium/<xsl:value-of select="$weather/icon"/>_n.png') right -5px no-repeat;<!-- 
					 --></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="style"><!-- 
						 -->background:url('<xsl:value-of select="$config/system/images_domain"/><xsl:value-of select="$skinpath"/>/assets/imgs/weather/medium/<xsl:value-of select="$weather/icon"/>.png') right -5px no-repeat; <!-- 
					 --></xsl:attribute>
				</xsl:otherwise>
			</xsl:choose> 

			<strong><span>T:&#xa0;</span> <xsl:value-of select="$weather/temp_c" /> º</strong> 
			<strong><span>H:&#xa0;</span> <xsl:value-of select="$weather/relative_humidity" /></strong> 
			<xsl:if test="$weather/feelslike_c != ''"> 
				<strong><span>ST:&#xa0;</span> <xsl:value-of select="$weather/feelslike_c" /></strong> 
			</xsl:if> 
			<!-- <p><xsl:value-of select="$weather/weather" /></p>  -->
		</div>
	</div>


	<main>
		<xsl:apply-templates select="$home/main/*" />
		<xsl:comment />
	</main>

</xsl:template>


</xsl:stylesheet>