<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="page" />
<xsl:param name="query" />
<xsl:param name="category_id" />
<xsl:param name="headerbtn" />


<xsl:template name="header">

	<header id="top">
		
		<a href="#menu" id="menu" class="menu"><i class="fa fa-bars" aria-hidden="true">&#xa0;</i></a>
		<!-- <xsl:copy-of select="$headerbtn" /> -->
		<!-- <a href="#menu"></a> -->
		<div class="logo">
			<a href="/"><img src="{$skinpath}/assets/imgs/logos/header.png" alt="{$config/sysmte/applicationID}" /></a>
		</div>

	</header>
	<div id="black">
		<span>Resistencia</span>
		<time class="right">
			<xsl:call-template name="date">
				<xsl:with-param name="date" select="$fechaActual"/>
				<xsl:with-param name="day" select="$diaActual"/>
			</xsl:call-template>
		</time>
	</div>

	<!-- <header class="floatFix">
		<a href="/" class="logo">
			<img src="{$skinpath}/imgs/logos/asterion2.gif" alt="{$config/skin/header/title}" />
		</a>
		<nav>
			<xsl:call-template name="menu.navigation">
				<xsl:with-param name="menus" select="$context/menus/menu[@menu_id=1]/menus" />
			</xsl:call-template>
		</nav>
	</header> -->

</xsl:template>



<!-- MENU -->

<xsl:template name="menu.navigation">
<xsl:param name="menus" />

<xsl:variable name="menu_left" select="$menus//menu[@order &lt;= 2]" />
<xsl:variable name="menu_right" select="$menus//menu[@order &gt; 2]" />

<ul>
	<li class="search">
		<form name="buscar" action="/search/" method="GET"  accept-charset="iso-8859-1, utf-8">
			<input type="text" name="q" value="" placeholder="Buscar" class="rounded">
				<xsl:if test="$query != ''"><xsl:attribute name="value"><xsl:value-of select="$query" /></xsl:attribute></xsl:if>
			</input>
			<button type="submit" style="cursor:pointer;" class="fa fa-search">&#xa0;</button> 
		</form>
	</li>
	<xsl:for-each select="$menus/menu">
		<xsl:sort order="ascending" select="@order" />
		<xsl:call-template name="menu.subitem" />
	</xsl:for-each>
	<li>
		<a href="http://www.nortecorrientes.com/">Norte Corrientes</a>
	</li>
	<li>
		<a href="http://www.soynorteclub.com/">SoyNorte Club</a>
	</li>
</ul>

<!-- <xsl:if test="$menus//menu[url = $page_url]/menus/menu">
	<ul class="submenu">
		<xsl:for-each select="$menus//menu[url = $page_url]/menus/menu">
			<xsl:sort order="ascending" select="@order" />
			<xsl:call-template name="menu.subitem" />
		</xsl:for-each>
	</ul>
</xsl:if>

<xsl:if test="$menus//menu/menus//menu[url = $page_url]">
	<ul class="submenu">
		<xsl:for-each select="$menus/menu[menus//menu[url = $page_url]]/menus/menu">
			<xsl:sort order="ascending" select="@order" />
			<xsl:call-template name="menu.subitem" />
		</xsl:for-each>
	</ul>
</xsl:if> -->


</xsl:template>

<xsl:template name="menu.subitem">
	<li>
		<!-- <xsl:attribute name="id"><xsl:call-template name="normalizar.texto"><xsl:with-param name="string" select="name"/></xsl:call-template></xsl:attribute> -->
		<!-- Agrego el nombre en el id -->
		<!-- <xsl:if test="position() = 1">
			<xsl:attribute name="class">first</xsl:attribute>
		</xsl:if>
		<xsl:if test="position() = last()">
			<xsl:attribute name="class">last</xsl:attribute>
		</xsl:if> -->
		<xsl:choose>
			<xsl:when test="url = '#'">
				<span><xsl:value-of select="name"/></span>
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:if test="$page_url = url">
						<xsl:attribute name="class">active</xsl:attribute>
					</xsl:if>
					<!--<xsl:attribute name="class"><xsl:call-template name="normalizar.texto"><xsl:with-param name="string" select="name"/></xsl:call-template></xsl:attribute>-->
					<xsl:attribute name="href"><xsl:value-of select="url"/></xsl:attribute>
					<xsl:value-of select="name"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="menus//menu">
			<ul>
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