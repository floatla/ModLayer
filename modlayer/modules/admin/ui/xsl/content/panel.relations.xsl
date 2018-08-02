<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

<xsl:variable name="cellsPerRow">3</xsl:variable>

<xsl:param name="item_id" />
<xsl:param name="type_id" />
<xsl:param name="relation_module" />
<xsl:param name="query" />
<xsl:param name="category_id" />
<xsl:param name="isSearch" />
<xsl:param name="callback" />
<xsl:param name="active_module" />


<xsl:variable name="modalurl"><!-- 
	 --><xsl:value-of select="$adminroot"/>?<!-- 
--></xsl:variable>
<xsl:variable name="thisModal"><!--
	--><xsl:value-of select="$adminroot" />?<!-- 
	--><xsl:for-each select="$context/get_params/*[not(name() = 'categories') and not(name() = 'page')]"><!-- 
 		--><xsl:value-of select="name()" />=<xsl:value-of select="text()" /><!-- 
 		--><xsl:if test="position() != last()">&amp;</xsl:if><!-- 
  	--></xsl:for-each><!-- 
 --></xsl:variable>

<xsl:template match="/xml">
<html>
	<head>
		<xsl:call-template name="htmlHead" />
		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
			</xsl:with-param>
		</xsl:call-template>

		<script type="text/javascript">
			requirejs(['admin/ui/js/app/controller/panel.relations'], function(panel){ 
				
				panel._item_id       = <xsl:value-of select="$item_id" />;
				panel._active_module = "<xsl:value-of select="$active_module" />";
				panel.BindActions();
			});
		</script>

		<style>
			body {font-size:13px;}
		</style>
	</head>
	<body class="body_panel">

		<header>
			<div class="search">
				<form name="search" action="?m={$active_module}&amp;action=RenderItemRelations&amp;module={$relation_module}&amp;item_id={$item_id}" method="get">
					<input type="text" name="q" value="{$query}" />
					<xsl:for-each select="$context/get_params/*[not(name() = 'q')]">
						<input type="hidden" name="{name()}" value="{.}" />
			  		</xsl:for-each>
					<button type="submit"><xsl:value-of select="$language/system_wide/btn_search"/></button>
				</form>
			</div>
			<h3><xsl:value-of select="$language/modal/relations/head_title"/></h3>

			<section class="list-header floatFix">
				<section class="right">
					<a class="btn" onclick="parent.appUI.ClosePanel();return false;"><xsl:value-of select="$language/modal/relations/btn_cancel"/></a>
					<button type="submit" class="btn lightblue" data-role="submit"><xsl:value-of select="$language/modal/relations/btn_save"/></button>
				</section>

				<xsl:call-template name="pagination">
					<xsl:with-param name="total" select="content/collection/@total" />
					<xsl:with-param name="display" select="content/collection/@pageSize" />
					<xsl:with-param name="currentPage" select="content/collection/@currentPage" />
					<xsl:with-param name="url" select="$modalurl" />
				</xsl:call-template>
				<xsl:call-template name="relation.filter.list">
					<xsl:with-param name="filter" select="content/filter" />
				</xsl:call-template>
			</section>
		</header>

		<section class="panel-body with-header">
			<form name="relacionar" action="{$adminroot}?m={$active_module}&amp;action=BackSetRelations" method="post">
				<input type="hidden" name="item_id" value="{$item_id}" />
				<input type="hidden" name="active_module" value="{$active_module}" />
				<input type="hidden" name="relation_module" value="{$relation_module}" />

		
				<!-- <xsl:if test="$query != ''">
					<a href="#" onclick="javascript:history.back();return false;" class="btn back">Salir de la búsqueda</a>
				</xsl:if> -->
			
				<div class="module-relation-panel">
					<xsl:if test="$query != ''">
						<div class="alert" style="margin:20px 0;">
							<xsl:value-of select="$language/messages/showing_query_results"/>&#xa0;<strong><em>"<xsl:value-of select="$query"/>"</em></strong>
							<xsl:if test="$categories != ''">&#xa0;<xsl:value-of select="$language/messages/with_category_filter"/></xsl:if>
							<xsl:variable name="found">
								<xsl:choose>
									<xsl:when test="/xml/content/collection/@total !=''">
										<xsl:value-of select="/xml/content/collection/@total" />
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$found = 1">
									(<xsl:value-of select="$found" />&#xa0;<xsl:value-of select="$language/messages/element_found"/>)
								</xsl:when>
								<xsl:otherwise>
									(<xsl:value-of select="$found" />&#xa0;<xsl:value-of select="$language/messages/elements_found"/>)
								</xsl:otherwise>
							</xsl:choose>
							<a href="?q=&amp;m=clip&amp;action=RenderItemRelations&amp;item_id=443&amp;module=article"><xsl:value-of select="$language/modal/relations/back_to_list"/></a>
						</div>
					</xsl:if>

					<!-- <xsl:if test="$query != ''">
						<div class="alert">
							Mostrando resultados de "<xsl:value-of select="$query" />"
						</div>
					</xsl:if> -->

					<xsl:if test="count(content/collection/object[not(@id = $item_id)]) = 0">
						<div class="empty-list rounded">
							<xsl:value-of select="$language/modal/relations/empty_clip_list"/>
						</div>
					</xsl:if>

			    	
			    	<xsl:variable name="collection">
			    		 <!-- select="content/collection/object" -->
			    		 <xsl:choose>
			    		 	<xsl:when test="$active_module = $relation_module">
			    		 		<xsl:copy-of select="content/collection/object[@id != $item_id]" />
			    		 	</xsl:when>
			    		 	<xsl:otherwise>
			    		 		<xsl:copy-of select="content/collection/object" />
			    		 	</xsl:otherwise>
			    		 </xsl:choose>
			    	</xsl:variable>
			    	<ul id="relation-{$active_module}" class="relation with-order" data-role="relation" data-type="{$active_module}" module="{$active_module}">
						<xsl:choose>
			    		 	<xsl:when test="$active_module = $relation_module">
								<xsl:for-each select="content/collection/object[@id != $item_id]">
									<xsl:call-template name="item.details" />
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="content/collection/object">
									<xsl:call-template name="item.details" />
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</ul>
				</div>
			</form>
		</section>
		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>
	</body>
</html>
</xsl:template>

<xsl:template name="item.details">
<xsl:variable name="parent_name" select="$config/module/@parent_name" />
<li>
	<xsl:if test="@id = /xml/content/relations/*[name()=$parent_name]/*/@id">
		<xsl:attribute name="class">related</xsl:attribute>
	</xsl:if>
	<div class="wrapper">
		<label for="rel_{@id}">
			<xsl:choose>
				<xsl:when test="multimedias/images/image">
					<span class="frame">
						<xsl:call-template name="image.bucket">
							<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
							<xsl:with-param name="type" select="multimedias/images/image/@type" />
							<xsl:with-param name="width">320</xsl:with-param>
							<xsl:with-param name="height">180</xsl:with-param>
							<xsl:with-param name="crop">c</xsl:with-param>
						</xsl:call-template>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<span class="frame">
						<span class="no-pic"><xsl:comment /></span>
					</span>
				</xsl:otherwise>
			</xsl:choose>
			<h3>
				<!-- <a href="{$adminroot}{$active_module}/edit/{@id}" target="_blank"> -->
					<xsl:value-of select="title | name"/>
				<!-- </a> -->
			</h3>
			
			<span>
				<xsl:call-template name="fecha.formato.numerico">
					<xsl:with-param name="fecha" select="@created_at" />
				</xsl:call-template>
			</span>
		</label>
		
		<!-- <xsl:if test="categories/category">
			<span class="right">
				<xsl:for-each select="categories/category[not(@parent=1)]">
					<xsl:sort order="ascending" select="@order" data-type="number"/>
						<span class="category rounded" style="padding:3px 7px"><xsl:value-of select="name" /></span>
				</xsl:for-each>
			</span>
		</xsl:if> -->

		<span class="info size">
			<input type="checkbox" name="elements[]" id="rel_{@id}" value="{@id}" class="checkbox">
				<xsl:if test="@id = /xml/content/relations/*[name()=$parent_name]/*/@id">
					<xsl:attribute name="checked">checked</xsl:attribute>
					<xsl:attribute name="disabled">disabled</xsl:attribute>
				</xsl:if>
			</input>
		</span>
	</div>
</li>
</xsl:template>


<xsl:template name="relation.filter.list">
	<xsl:param name="filter" />
	
	<xsl:if test="$filter/group">
		<xsl:for-each select="$filter/group">
			<div class="filters dropdown">
				<span class="btn trigger" data-toggle="dropdown">
					<xsl:value-of select="@name" />&#xa0;
				</span>
				<ul class="dropdown-menu left">
			    	<xsl:for-each select="category">
						<xsl:call-template name="relation.filter.item" />
					</xsl:for-each>
					<li class="line">&#xa0;</li>
					<li>
						<a>
							<xsl:attribute name="href"><xsl:value-of select="$thisModal"/></xsl:attribute>
							<xsl:value-of select="$language/modal/relations/show_all"/>
						</a>
					</li>
				</ul>
			</div>
		</xsl:for-each>
	</xsl:if>
</xsl:template>


<xsl:template name="relation.filter.item">
	<xsl:param name="prefix" />
		<li>
			<xsl:if test="@category_id = $categories">
				<xsl:attribute name="class">active</xsl:attribute>
			</xsl:if>
			<a>
				<xsl:attribute name="href"><xsl:value-of select="$thisModal"/>&amp;categories=<xsl:value-of select="@category_id"/></xsl:attribute>
				<xsl:if test="$prefix != ''"><xsl:value-of select="$prefix" /></xsl:if>
				<xsl:value-of select="name" />
			</a>
		</li>
		<xsl:if test="categories/category">
			<xsl:for-each select="categories/category">
				<xsl:call-template name="relation.filter.item">
					<xsl:with-param name="prefix"><xsl:value-of select="$prefix"/>- </xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
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