<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<xsl:param name="query" />
<xsl:param name="isHome" />


<xsl:template name="topHeader">
	<section id="top">
		<div class="container">
			<ul>
				<li><a href="#">Ingresar</a></li>
				<li><a href="#">Registrarse</a></li>
			</ul>

			<!-- Redes -->
			<div class="social right">
				<!-- <a href="/rss/" class="rss" title="Feed Rss"><i class="fa fa-rss" aria-hidden="true"><xsl:comment /></i><span>Rss</span></a> -->
				<a class="twitter" href="https://twitter.com/vindcms" target="_blank" title="Seguinos en Twitter"><i class="fa fa-twitter" aria-hidden="true"><xsl:comment /></i><span>Twitter</span></a>
				<a class="facebook" href="http://www.facebook.com/vindcms" target="_blank" title="Seguinos en Facebook"><i class="fa fa-facebook" aria-hidden="true"><xsl:comment /></i><span>Facebook</span></a>
				<!-- <a class="google" href="https://twitter.com/vindcms" target="_blank" title="Seguinos en Google+">Google+</a> -->
			</div>
			<!-- Redes -->
		</div>
	</section>
</xsl:template>

<xsl:template name="header">

	<header class="site-header">
		<div class="container floatFix">

			<div id="nav-icon3">
				<span>&#xa0;</span>
				<span>&#xa0;</span>
				<span>&#xa0;</span>
				<span>&#xa0;</span>
			</div>

			<!-- Logo -->
			<a href="/" class="logo">
				<img alt="{$config/skin/header/title}">
					<xsl:attribute name="src"><!-- 
						  --><xsl:value-of select="$device" /><!-- 
						  -->/assets/imgs/logos/vind_logo.svg<!-- 
					 --></xsl:attribute>
				</img>
			</a>
			<!-- Logo -->

			<!-- fecha -->
			<div class="day-info">
				<time> 
					Buenos Aires <br/> 
					<xsl:call-template name="date">
						<xsl:with-param name="date" select="$fechaActual"/>
						<xsl:with-param name="day" select="$diaActual"/>
					</xsl:call-template>
					<!-- <xsl:if test="$isHome = 1"> 
						<span> 
							<xsl:call-template name="publication.time" /> 
						</span> 
					</xsl:if> -->
				</time>

				 <!-- Clima -->
				<div class="conditions"> 
					<xsl:variable name="weather" select="/xml/context/weather/current_observation" /> 
					<xsl:choose>
						<xsl:when test="substring($horaActual, 1, 2) &gt;= 10 or substring($horaActual, 1, 2) &lt;= 6">
							<xsl:attribute name="style"><!--  
								 -->background-image:url('<xsl:value-of select="$device"/>/assets/imgs/weather/medium/<xsl:value-of select="$weather/icon"/>_n.png');<!--  
							 --></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="style"><!--  
								 -->background-image:url('<xsl:value-of select="$device"/>/assets/imgs/weather/medium/<xsl:value-of select="$weather/icon"/>.png');<!--  
							 --></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose> 

					<span>T:&#xa0; <xsl:value-of select="$weather/temp_c" /> º</span>
					<span>H:&#xa0; <xsl:value-of select="$weather/relative_humidity" /></span>
					<xsl:if test="$weather/feelslike_c != ''"> 
						<span>ST:&#xa0; <xsl:value-of select="$weather/feelslike_c" /></span>
					</xsl:if> 
					<span class="desc"><xsl:value-of select="$weather/weather" /></span> 
					<!-- <p><a href="#">Ampliar</a></p> -->
				</div>
				<!-- Clima --> 
					
			 </div>
			<!-- fecha -->

			<!-- Buscador -->
			<div class="search"> 
				<form name="buscar" action="/search/" method="GET"  accept-charset="iso-8859-1, utf-8"> 
					<input type="text" name="q" value="" placeholder="Buscar.." class="rounded"> 
						<xsl:if test="$query != ''"><xsl:attribute name="value"><xsl:value-of select="$query" /></xsl:attribute></xsl:if> 
					</input> 
					<button type="submit" style="cursor:pointer;" class="fa fa-search">&#xa0;</button> 
				</form> 
			</div>
			<!-- Buscador -->
		</div>
	</header>

	<div class="top">
			<div class="navpane">
				<nav id="menu">
		<div class="container floatFix">
					<!-- <div class="title">
						<h3><span>Usuario</span></h3>
					</div>
					<div class="login-links">
						<xsl:choose>
							<xsl:when test="$config/user/user_id">
								<ul>
									<li><a href="/profile/" class="profile"><xsl:value-of select="$config/user/first_name" />&#xa0;<xsl:value-of select="$config/user/last_name" /></a></li>
									<li><a href="/logout/" class="logout">Salir</a></li>
								</ul>	
							</xsl:when>
							<xsl:otherwise>
								<ul>
									<li><a href="/login/" class="login-btn">Ingresar</a></li>
									<li><a href="/register/" class="register-btn">Registrarse</a></li>
								</ul>	
							</xsl:otherwise>
						</xsl:choose>
					</div> -->
					<div class="title">
						<h3><span>Menu</span></h3>
					</div>
					<xsl:call-template name="menu.navigation">
						<xsl:with-param name="menus" select="$context/menu-navtop" />
					</xsl:call-template>
			</div>	
				</nav>
		</div>
		<div id="overlay" class="hide">&#xa0;</div>
	</div>

</xsl:template>



<!-- MENU -->
<xsl:template name="menu.navigation">
<xsl:param name="menus" />
<ul>
	<xsl:for-each select="$menus/menu">
		<xsl:sort order="ascending" select="@order" />
		<xsl:call-template name="menu.subitem" />
	</xsl:for-each>
</ul>
</xsl:template>

<xsl:template name="menu.subitem">
	<li>
		<xsl:if test="menus//menu">
			<xsl:attribute name="class">menu</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="name"><xsl:call-template name="sanitize"><xsl:with-param name="string" select="name"/></xsl:call-template></xsl:attribute>
		<a>
			<xsl:if test="$page_url = url">
				<xsl:attribute name="class">active</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute>
			<xsl:value-of select="name"/>
		</a>

		<xsl:if test="menus//menu">
			<ul class="subnav">
				<xsl:for-each select="menus/menu">
					<xsl:sort order="ascending" select="@order" data-type="number"/>
					<xsl:call-template name="menu.subitem" />
				</xsl:for-each>
			</ul>
		</xsl:if>
	</li>

</xsl:template>
<!-- /MENU -->




</xsl:stylesheet>