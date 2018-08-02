<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="call" />
<xsl:param name="mid" />

<xsl:param name="object_id" />
<xsl:param name="object_typeid" />



<xsl:template match="/xml">

	<xsl:choose>
		<xsl:when test="$call='categories'">
			<xsl:call-template name="categories.list" />
		</xsl:when>
	</xsl:choose>
	
</xsl:template>

<xsl:template name="categories.list">
	<xsl:for-each select="/xml/content/item/category[category_parent = $category_parent]">
		<xsl:sort order="ascending" select="order" data-type="number"/>
		<li id="cat-{category_id}" category_id="{category_id}">
			<a class="right icon remove" onclick="category.delete({category_id}, {$item_id});" href="#" title="Delete">Delete</a>
			<xsl:value-of select="category_name"/>
		</li>
	</xsl:for-each>
</xsl:template>



</xsl:stylesheet>