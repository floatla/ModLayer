<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />

<xsl:variable name="cellsPerRow">3</xsl:variable>
<xsl:param name="item_id" />
<xsl:param name="category_parent" />
<xsl:param name="active_module" />

<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html>
	<head>
		<title><xsl:value-of select="$language/item_editor/add_category"/></title>
		
		<xsl:call-template name="htmlHead" />
		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
				<xsl:value-of select="$modPath"/>/ui/css/categories.css
			</xsl:with-param>
		</xsl:call-template>

		<script> 
			requirejs(['category/ui/js/panel.collection'], function(Panel){ 
				Panel.BindActions();
			});
		</script>

	</head>
	<body class="body_panel">
		<form name="categorizar" action="{$adminroot}?m={$active_module}&amp;action=BackSetCategories" method="post">
			<xsl:choose>
				<xsl:when test="content/ids/id">
					<xsl:for-each select="content/ids/id">
						<input type="hidden" name="elements[]" value="{.}" />
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="$item_id != ''">
					<input type="hidden" name="elements[]" value="{$item_id}" />	
				</xsl:when>
			</xsl:choose>
			<header>
				<span class="right">
					<a href="#" class="btn" onclick="parent.appUI.ClosePanel();return false;"><xsl:value-of select="$language/item_editor/btn_cancel"/></a>
					<button type="submit" class="btn lightblue"><xsl:value-of select="$language/item_editor/btn_save"/></button>
				</span>
				<h3>Categorizar contenido</h3>
			</header>
			<section class="panel-body">
				<div class="modal-categories" >
					<xsl:for-each select="content/categories/group">
						<h3 style="margin:0;padding:0;"><xsl:value-of select="name" /></h3>
						<ul class="list-parent rounded" style="margin:0 0 20px;">
							<li>
								<xsl:call-template name="list.categories">
									<xsl:with-param name="categories" select="categories"/>
								</xsl:call-template>
							</li>
						</ul>
					</xsl:for-each>
				</div>
			</section>
		</form>
		<xsl:if test="$debug = 1">
			<xsl:call-template name="debug" />
		</xsl:if>
	</body>
</html>

</xsl:template>


<xsl:template name="list.categories">
	<xsl:param name="categories" />
	<xsl:for-each select="$categories/category[not(@parent=1)]">
		<xsl:sort order="ascending" select="@order" />
		<xsl:sort order="ascending" select="name" />
		<ul>
			<li>
				<input type="checkbox" name="categories[]" id="cat_{@category_id}" value="{@category_id}" item_id="{@category_id}">
					<xsl:if test="@category_id = /xml/content/item//category or @category_id = /xml/content/item//category/category_id">
						<xsl:attribute name="checked">checked</xsl:attribute>
						<xsl:attribute name="disabled">disabled</xsl:attribute>
					</xsl:if>
				</input>
				<label for="cat_{@category_id}"><xsl:value-of select="name" /></label>
				<xsl:if test="categories/category">
					<xsl:call-template name="list.categories">
						<xsl:with-param name="categories" select="categories" />
					</xsl:call-template>
				</xsl:if>
			</li>
		</ul>
	</xsl:for-each>
</xsl:template>


</xsl:stylesheet>