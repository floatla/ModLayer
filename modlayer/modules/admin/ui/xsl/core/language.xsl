<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />


<xsl:template match="/xml">
<xml>
	<xsl:copy-of select="$config/language" />
	<xsl:copy-of select="$content/mod_language" />
</xml>
</xsl:template>


</xsl:stylesheet>