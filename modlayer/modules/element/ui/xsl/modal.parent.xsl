<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

<xsl:variable name="cellsPerRow">3</xsl:variable>

<xsl:param name="item_id" />
<xsl:param name="type_id" />
<xsl:param name="moduleParent" />
<xsl:param name="query" />
<xsl:param name="category_id" />
<xsl:param name="isSearch" />
<xsl:param name="callback" />
<xsl:param name="active_module" />


<xsl:variable name="modalurl"><!-- 
	 --><xsl:value-of select="$adminroot"/>?<!-- 
	 --><xsl:for-each select="/xml/context/get_params/*[name()!='categories']"><!-- 
		 --><xsl:value-of select="name()"/>=<xsl:value-of select="."/><xsl:if test="position()!=last()">&amp;</xsl:if><!-- 
	 --></xsl:for-each><!-- 
	 --><xsl:if test="$query!=''">&amp;q=<xsl:value-of select="$query"/></xsl:if><!-- 
 --></xsl:variable>
<xsl:template match="/xml">
<html>
	<head>
		<xsl:call-template name="htmlHead" />
		<link rel="stylesheet" type="text/css" href="{$adminPath}/ui/css/sidepanel.css" />
		<script type="text/javascript">
			requirejs(['element/ui/js/parent'], function(Parent){ 
				
				Parent.BindActions();
			});
		</script>
		<style>
			body {font-size:13px;}
		</style>
	</head>
	<body class="body_panel">
	
		<header>
			<div class="search">
				<form name="search" action="?m={$modName}&amp;action=RenderItemParent&amp;item_id={$item_id}&amp;moduleParent={$moduleParent}" method="post">
					<input type="text" name="q" value="{$query}" />
					<input type="hidden" name="item_id" value="{$item_id}" />
					<input type="hidden" name="moduleParent" value="{$moduleParent}" />
					<xsl:if test="$categories != ''">
						<input type="hidden" name="categories" value="{$categories}" />
					</xsl:if>
					<button type="submit"><xsl:value-of select="$language/modal/relations/btn_search"/></button>
				</form>
			</div>
			<h3><xsl:value-of select="$language/modal/relations/head_title"/></h3>
	
			<section class="list-header floatFix">
				<section class="right">
					<button type="button" class="btn cancel"><xsl:value-of select="$language/modal/relations/btn_cancel"/></button>
					<button type="submit" data-role="submit" class="btn lightblue" ><xsl:value-of select="$language/modal/relations/btn_save"/></button>
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
			<form name="parent" action="{$adminroot}?m={$active_module}&amp;action=BackSetParent" method="post">
				<input type="hidden" name="item_id" value="{$item_id}" />
				<input type="hidden" name="moduleParent" value="{$moduleParent}" />

				<div class="module-relation-panel">
					<xsl:if test="count(content/collection/object[not(@id = $item_id)]) = 0">
						<div class="empty-list rounded">
							<xsl:value-of select="$language/modal/relations/empty_element_list"/>
						</div>
					</xsl:if>

					<ul class="relation">
						<xsl:for-each select="content/collection/object[not(@id = $item_id)]">
							<li>
								<xsl:if test="@id = /xml/content/relations/*/*/@id">
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
											<a href="{$adminroot}{$active_module}/edit/{@id}" target="_blank">
												<xsl:value-of select="title | name"/>
											</a>
										</h3>
										
										<span>
											<xsl:call-template name="fecha.formato.numerico">
												<xsl:with-param name="fecha" select="@created_at" />
											</xsl:call-template>
										</span>
									</label>

									<span class="info size">
										<input type="radio" name="parent_id" id="rel_{@id}" value="{@id}" class="checkbox">
											<xsl:if test="@id = /xml/content/parent/*/@id">
												<xsl:attribute name="checked">checked</xsl:attribute>
												<xsl:attribute name="disabled">disabled</xsl:attribute>
											</xsl:if>
										</input>
									</span>
								</div>
							</li>
						</xsl:for-each>
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


<xsl:template name="relation.filter.list">
	<xsl:param name="filter" />

	<xsl:if test="$filter/group">
		<xsl:for-each select="$filter/group">
			<div class="filters dropdown">
				<button class="btn dropdown-toggle" data-toggle="dropdown"><xsl:value-of select="@name" />&#xa0;
				<xsl:if test="$categories != '' and .//category[@category_id=$categories]"> &#x02192; <xsl:value-of select=".//category[@category_id=$categories]/name" />&#xa0;</xsl:if>
				<span class="caret">&#xa0;</span></button>
				<ul class="dropdown-menu left">
			    	<xsl:for-each select="category">
						<xsl:call-template name="relation.filter.item" />
					</xsl:for-each>
					<li class="line">&#xa0;</li>
					<li>
						<a>
							<xsl:attribute name="href"><xsl:value-of select="$modalurl"/></xsl:attribute>
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
				<xsl:attribute name="href"><xsl:value-of select="$modalurl"/>&amp;categories[]=<xsl:value-of select="@category_id"/></xsl:attribute>
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