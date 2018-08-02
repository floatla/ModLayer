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
		requirejs(['admin/ui/js/app/controller/collection'], function(List){ 
			List.BindActions();
		});
    </script>
</xsl:variable>


<xsl:template name="content">
	<xsl:call-template name="display.collection" >
		<xsl:with-param name="collection" select="$content/collection"/>
	</xsl:call-template>
</xsl:template>

</xsl:stylesheet>