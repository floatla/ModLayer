<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<!--The system pass the current url to the transformation-->
<xsl:param name="modName" />
<xsl:param name="action" />
<xsl:param name="query" />
<xsl:variable name="user_access" select="/xml/configuration/user/@access" />

<xsl:variable name="action2">action=<xsl:value-of select="$action" /></xsl:variable>
<xsl:variable name="group"><!--
	--><xsl:choose><!--
		--><xsl:when test="$action = ''"><!--
			--><xsl:value-of select="//item[@name = $modName][.//subitem/@url = '']/@group" /><!--
		--></xsl:when><!--
		--><xsl:otherwise><!--
			--><xsl:value-of select="//item[@name = $modName][.//subitem/@url = $action2]/@group" /><!--
		--></xsl:otherwise><!--
	--></xsl:choose><!--
--></xsl:variable>

<xsl:template name="header">
	<header id="top">
		<div class="menu">
			<div class="dropdown toleft">
				<span class="trigger"><xsl:value-of select="$config/user/name" /></span>
				<ul>
					<li>
						<a href="{$adminroot}admin/user/my-data/">
							<xsl:value-of select="$language/system_wide/user_profile" />
						</a>
					</li>
					<!-- <li>
						<a href="#">
							<xsl:value-of select="$language/system_wide/user_drafts" />
						</a>
					</li> -->
					<li class="line">&#xa0;</li>
					<li>
						<a href="{$adminroot}logout">
							<xsl:value-of select="$language/system_wide/logout" />
						</a>
					</li>
				</ul>
			</div>
		</div>
		<xsl:if test="$modName != 'admin'">
			<xsl:call-template name="search.box" />
		</xsl:if>
		<!-- <a href="#" class="closeNav icon toright">&#xa0;</a> -->
		<h3><xsl:value-of select="$config/navigation/item[@name=$modName]/@label" /></h3>
		<xsl:call-template name="module.navigation" />
	</header>
	<!-- <div class="subhead">
		hola
	</div> -->
</xsl:template>


<xsl:template name="navigation">
		<div id="admin_menu">
			<div class="dropdown dark toright">
				<a href="#" class="closeNav right icon closew">&#xa0;</a>
				<span class="icon settings trigger"><xsl:value-of select="$language/nav_menu/administration"/></span>
				<ul>
					<!-- Módulos de administración -->
					<xsl:if test="count($config/navigation//item[@group = 3 or @group ='administration'][contains(@access_level, $user_access) or contains(@access_level, 'all')]) &gt; 0">
						<xsl:for-each select="$config/navigation/item[@group = 3 or @group ='administration'][not(@access_level) or @access_level='all' or contains(@access_level, $user_access)]">
								<xsl:sort order="ascending" select="@order" data-type="number"/>
								<xsl:variable name="module_name" select="@name" />
								<li>
									<!-- <a href="{$adminroot}{$module_name}/{subitem/@url}"><xsl:value-of select="@label"/></a> -->
									<a>
										<xsl:attribute name="href">
											<xsl:call-template name="module.navigation.link">
												<xsl:with-param name="url" select="subitem/@url" />
												<xsl:with-param name="moduleName" select="$module_name" />
											</xsl:call-template>
										</xsl:attribute>
										<xsl:value-of select="@label"/>
									</a>
								</li>
							</xsl:for-each>
					</xsl:if>
					<!-- Módulos de administración -->
					<li class="line">&#xa0;</li>
					<li>
						<a href="{$adminroot}admin/preferences/"><xsl:value-of select="$language/nav_menu/preferences"/></a>
					</li>
					<li>
						<a href="{$adminroot}admin/preferences/module/"><xsl:value-of select="$language/nav_menu/module_config"/></a>
					</li>
					
				</ul>
			</div>
		</div>
		<div class="panel">
			<nav>
				<xsl:variable name="user_access" select="/xml/configuration/user/@access" />

				<!--CARGA Y EDICION-->
				<xsl:if test="count($config/navigation//item[@group = 1 or @group ='content'][not(@access_level) or @access_level='all' or contains(@access_level, $user_access)]) &gt; 0">
					<div class="navgroup">
						<!-- <h3>
							Contenido
						</h3> -->
						<xsl:for-each select="$config/navigation/item[@group = 1 or @group = 'content'][not(@access_level) or @access_level='all' or contains(@access_level, $user_access)]">
							<xsl:sort order="ascending" select="@order" data-type="number"/>
							<xsl:call-template name="navigation.item" />
						</xsl:for-each>
					</div>
				</xsl:if>
				<!--CARGA Y EDICION-->
				<!--MULTIMEDIAS-->
				<xsl:if test="count($config/navigation//item[@group = 2 or @group ='multimedia'][contains(@access_level, $user_access) or contains(@access_level, 'all')]) &gt; 0">
					<div class="navgroup">
						<!-- <h3>Multimedias</h3> -->
						<xsl:for-each select="$config/navigation/item[@group = 2 or @group ='multimedia'][not(@access_level) or @access_level='all' or contains(@access_level, $user_access)]">
							<xsl:sort order="ascending" select="@order" data-type="number"/>
								<xsl:call-template name="navigation.item" />
						</xsl:for-each>
					</div>
				</xsl:if>
				<!--MULTIMEDIAS-->
			</nav>
		</div>
			
	
</xsl:template>


<xsl:template name="navigation.item">
	<xsl:variable name="module_name" select="@name" />
	<ul class="item" name="{@name}" group="{@group}">
		<xsl:choose>
			<xsl:when test="@name = $modName and @group = $group">
				<xsl:attribute name="class">item active <xsl:if test="position() = 1">first</xsl:if></xsl:attribute>
			</xsl:when>
			<xsl:when test="@name = $modName and $group = ''">
				<xsl:attribute name="class">item active <xsl:if test="position() = 1">first</xsl:if></xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<li>
			<a href="{$adminroot}{$module_name}/{subitem/@url}"><xsl:value-of select="@label"/></a>
		</li>
	</ul>
</xsl:template>

<xsl:variable name="moduleNav" select="$config/navigation/item[@name = $modName]" />
<xsl:variable name="module_name" select="$moduleNav/@name" />

<xsl:template name="module.navigation">

		<xsl:if test="$moduleNav/subitem">
			<xsl:variable name="user_access" select="/xml/configuration/user/@access" />
			<ul class="floatFix module-subnav">
				<xsl:for-each select="$moduleNav/subitem">
					<xsl:choose>
						<xsl:when test="@access_level='' or contains(@access_level, $user_access)">
							<xsl:call-template name="module.navigation.item" />
						</xsl:when>
						<xsl:when test="@access_level = /xml/configuration/user/@access">
							<xsl:call-template name="module.navigation.item" />
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</ul>
		</xsl:if>
</xsl:template>

<xsl:template name="module.navigation.item">
	<li>
		<xsl:if test="position() = last()"><xsl:attribute name="class">last</xsl:attribute></xsl:if>
		<xsl:variable name="thisUrl"><xsl:value-of select="$adminroot" /><xsl:value-of select="$modName"/>/<xsl:value-of select="@url" /></xsl:variable>
		<a>
			<xsl:attribute name="href">
				<xsl:call-template name="module.navigation.link">
					<xsl:with-param name="url" select="@url" />
					<xsl:with-param name="moduleName" select="$modName" />
				</xsl:call-template>
			</xsl:attribute>
			<xsl:if test="@modal = 1">
				<xsl:attribute name="onclick">layer.loadExternal(this);return false;</xsl:attribute>
			</xsl:if>
			<xsl:if test="$page_url = $thisUrl">
				<xsl:attribute name="class">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="@name" disable-output-escaping="yes" />
		</a>
	</li>
</xsl:template>

<xsl:template name="module.navigation.link">
	<xsl:param name="url" />
	<xsl:param name="moduleName" />
	<xsl:choose>
		<xsl:when test="contains($url, '{$adminPath}/')"><!-- 
			 --><xsl:value-of select="$adminroot"/><!-- 
			 --><xsl:value-of select="substring-after($url, '{$adminPath}/')"/><!-- 
		 --></xsl:when>
		<xsl:otherwise><!-- 
			 --><xsl:value-of select="$adminroot"/><xsl:value-of select="$moduleName"/>/<xsl:value-of select="$url"/><!-- 
		 --></xsl:otherwise>
	</xsl:choose>
	<!-- href="{$adminroot}{$module_name}/{@url}" -->
</xsl:template>

<xsl:template name="search.box" >
	<div class="search right">
		<form name="search" action="{$adminroot}{$config/module/@name}/search/" method="GET">
			<xsl:if test="$categories != ''">
				<xsl:call-template name="category.item.split">
					<xsl:with-param name="categories" select="$categories" />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$startdate != ''">
				<input type="hidden" name="startdate" value="{$startdate}" />
			</xsl:if>
			<xsl:if test="$enddate != ''">
				<input type="hidden" name="enddate" value="{$enddate}" />
			</xsl:if>
			<xsl:if test="$state != ''">
				<input type="hidden" name="state" value="{$state}" />
			</xsl:if>
			<input type="text" name="q" value="{$query}"  placeholder="{$language/system_wide/search}" />
			<button type="submit" title="{$language/system_wide/btn_search}">
				<xsl:value-of select="$language/system_wide/btn_search" />
			</button>
		</form>
	</div>
</xsl:template>

<xsl:template name="category.item.split">
	<xsl:param name="categories" />
	<xsl:choose>
		<xsl:when test="contains($categories,',')">
			<input type="hidden" name="categories[]" value="{substring-before($categories,',')}" />
			<xsl:call-template name="category.item.split">
				<xsl:with-param name="categories" select="substring-after($categories,',')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<input type="hidden" name="categories[]" value="{$categories}" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>