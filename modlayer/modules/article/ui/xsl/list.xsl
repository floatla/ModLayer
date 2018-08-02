<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="calendar" />
<xsl:param name="type" />
<xsl:param name="pagenumber" />
<xsl:param name="query" />
<xsl:param name="filter" />
<xsl:param name="state" >0</xsl:param>
<xsl:param name="category_id" />

<xsl:variable name="htmlHeadExtra">
	
	<script> 
		var jsCollection = {} 
		requirejs(['admin/ui/js/app/controller/collection'], function(List){ 
			jsCollection = List;
			List.BindActions();
		});
    </script>
</xsl:variable>


<xsl:template name="content">
	<xsl:call-template name="display.collection" >
		<xsl:with-param name="collection" select="$content/collection"/>
		<xsl:with-param name="includeLocalData">1</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="local.collection.data">
	<xsl:if test="tags/tag">
		<div class="inline-tag">
			<!-- Tags:  -->
			<xsl:for-each select="tags/tag">
				<a href="{$page_url}?tags={@tag_id}"><xsl:value-of select="tag_name"/></a>
				<!-- <xsl:if test="position() != last()">, </xsl:if> -->
			</xsl:for-each>
		</div>
	</xsl:if>
</xsl:template>
</xsl:stylesheet>