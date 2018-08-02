<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

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