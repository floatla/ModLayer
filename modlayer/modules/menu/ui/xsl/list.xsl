<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/css/menu.css
		</xsl:with-param>
	</xsl:call-template>
	<script> 
		var jsTree = {};
		requirejs(['menu/ui/js/tree'], function(Tree){ 
			jsTree = Tree;
			Tree.BindActions();
		});
    </script>
</xsl:variable>

<xsl:template name="content">
	<xsl:attribute name="class">content</xsl:attribute>
	<section class="collection" id="grid">
		<xsl:choose>
			<xsl:when test="content/menus/menu">
				<xsl:apply-templates select="content/menus" mode="tree" />
			</xsl:when>
			<xsl:otherwise>
				<div class="empty-list rounded">
	    			<xsl:value-of select="$language/messages/empty_list/nothing_found" /><br/>
					<a class="btn lightblue" item_id="0" onclick="jsTree.addChild(this);return false;" href="#"><xsl:value-of select="$language/messages/empty_list/load_new" /></a>
	    		</div>
			</xsl:otherwise>
		</xsl:choose>
	</section>
</xsl:template>

<xsl:template match="menus" mode="tree">
	<ol class="tree">
		<xsl:if test="name(parent::*) = 'content'">
			<xsl:attribute name="class">tree sortable</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="menu" mode="tree">
			<xsl:sort order="ascending" select="@order" data-type="number" />
		</xsl:apply-templates>
	</ol>
</xsl:template>

<xsl:template match="menu" mode="tree">
	<li class="branch floatFix" id="order_{@menu_id}" data-raw="{@menu_id}">
		<div class="categoryRow floatFix" menu_id="{@menu_id}">
			<!-- <a href="#" class="icon order">&#xa0;</a> -->
			<span class="quick right">
				<a data-role="tree-add" class="tooltip add" href="#" item_id="{@menu_id}" onclick="jsTree.addChild(this);" title="{$language/collection/btn_add}"><i class="fas fa-plus">&#xa0;</i></a>
				<a data-role="tree-edit" class="tooltip edit" href="#" item_id="{@menu_id}" onclick="jsTree.edit(this);" title="{$language/collection/btn_edit}"><i class="fas fa-pencil-alt ">&#xa0;</i></a>
				<a data-role="tree-delete" class="tooltip delete" href="#" item_id="{@menu_id}" onclick="jsTree.delete(this);" title="{$language/collection/btn_delete}"><i class="fas fa-eraser">&#xa0;</i></a>
			</span>
			
			<xsl:if test="menus/menu">
				<a href="#" class="openclose opened">&#xa0;</a>
			</xsl:if>
			<h3>
				<b role="title"><xsl:value-of select="name" /></b>
				<small role="id">
					id: <xsl:value-of select="@menu_id"  />
				</small>
			</h3>
			<p role="url" style="display:none;">
				<xsl:if test="url != ''">
					<xsl:attribute name="style">display:block;</xsl:attribute>
				</xsl:if>
				<!-- <xsl:value-of select="$config/system/domain" /> --><xsl:value-of select="url" />
			</p>
		</div>
		<xsl:apply-templates select="menus" mode="tree" />
	</li>
</xsl:template>

</xsl:stylesheet>