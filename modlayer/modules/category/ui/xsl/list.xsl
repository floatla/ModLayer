<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/css/categories.css
		</xsl:with-param>
	</xsl:call-template>
	<script> 
		var jsTree = {};
		var MultimediaService = {};
		requirejs(['category/ui/js/tree', 'multimedia/ui/js/service'], function(Tree, Image){ 
			jsTree = Tree;

			/*
				El modal de imagenes, dispara un callback de setRelation 
				en el objeto ImageService. Ese metodo lo tenemos definimos en Tree para nuestro listado
			*/
			MultimediaService = Tree;
			Tree.BindActions();
		});
    </script>
</xsl:variable>

<xsl:template name="content">
	<xsl:attribute name="class">content</xsl:attribute>
	<section class="collection" id="grid">
		<xsl:choose>
			<xsl:when test="content/categories/category">
				<xsl:apply-templates select="content/categories" mode="tree" />
			</xsl:when>
			<xsl:otherwise>
				<div class="empty-list rounded">
					<xsl:value-of select="$language/messages/empty_list/nothing_found"/><br/>
					<xsl:value-of select="$language/messages/empty_list/load_new"/>
					<br/>
					<a href="#" onclick="jsTree.addChild(this);" class="btn lightblue" item_id="0"><xsl:value-of select="$language/item_editor/btn_add"/></a>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</section>
</xsl:template>

<xsl:template match="categories" mode="tree">
	<ol class="tree">
		<xsl:if test="name(parent::*) = 'content'">
			<xsl:attribute name="class">tree sortable</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="category" mode="tree">
			<xsl:sort order="ascending" select="@order" data-type="number" />
		</xsl:apply-templates>
	</ol>
</xsl:template>

<xsl:template match="category" mode="tree">
	<li class="branch floatFix" id="order_{@category_id}" data-raw="{@category_id}">
		<div class="categoryRow floatFix" category_id="{@category_id}">
			<!-- <a href="#" class="icon order">&#xa0;</a> -->
			<span class="quick right">
				<a data-role="tree-addimage" class="tooltip image" href="#" item_id="{@category_id}" onclick="jsTree.addImage(this);" title="{$language/collection/add_image}"><i class="far fa-image">&#xa0;</i></a>
				<a data-role="tree-add" class="tooltip add" href="#" item_id="{@category_id}" onclick="jsTree.addChild(this);" title="{$language/collection/add_subcategory}"><i class="fas fa-plus">&#xa0;</i></a>
				<a data-role="tree-edit" class="tooltip edit" href="#" item_id="{@category_id}" onclick="jsTree.edit(this);" title="{$language/collection/btn_edit}"><i class="fas fa-pencil-alt ">&#xa0;</i></a>
				<a data-role="tree-delete" class="tooltip delete" href="#" item_id="{@category_id}" onclick="jsTree.delete(this);" title="{$language/collection/btn_delete}"><i class="fas fa-eraser">&#xa0;</i></a>
			</span>
			
			<!-- <xsl:if test="categories/category"> -->
			<span class="disclose"><span>&#xa0;</span></span>
				<!-- <a href="#" class="openclose opened">&#xa0;</a> -->
			<!-- </xsl:if> -->
			<xsl:if test="@image_id != 0">
				<div class="catImg">
					<a href="#" class="remove" onclick="jsTree.unlink({@category_id});return false;">&#xa0;</a>
					<xsl:call-template name="image.bucket">
						<xsl:with-param name="id" select="@image_id" />
						<xsl:with-param name="type" select="@image_type" />
						<xsl:with-param name="width">80</xsl:with-param>
						<xsl:with-param name="height">80</xsl:with-param>
						<xsl:with-param name="crop">c</xsl:with-param>
						<!-- <xsl:with-param name="class">catImg</xsl:with-param> -->
					</xsl:call-template>
				</div>
			</xsl:if>
			<h3>
				<b role="title"><xsl:value-of select="name" /></b>
				<small role="id">
					id: <xsl:value-of select="@category_id"  />
				</small>
			</h3>
			<p role="description" style="display:none;">
				<xsl:if test="description != ''">
					<xsl:attribute name="style">display:block;</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="description" />
			</p>
		</div>
		<xsl:apply-templates select="categories" mode="tree" />
	</li>
</xsl:template>
</xsl:stylesheet>