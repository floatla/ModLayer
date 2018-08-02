<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />


<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html lang="en">
<head>
	<xsl:call-template name="htmlHead" />
</head>
<body>
	<div id="ui">
		<section id="navpanel" class="">
			<xsl:if test="$context/cookies/mainNav = 'hidden'">
				<xsl:attribute name="class">hidden</xsl:attribute>
				<div class="openNav" onclick="window.appUI.openMainNav();"><xsl:comment /></div>
			</xsl:if>
			<h1 class="white" title="{$config/system/applicationID}"><xsl:value-of select="$config/system/applicationID" /><a href="{$appUrl}" target="_blank" class="icon viewsite"><xsl:value-of select="$language/system_wide/viewsite"/></a></h1>
			<xsl:call-template name="navigation" />
		</section>
		<section id="mainpanel">
			<div class="panel">
				<xsl:call-template name="header" />
				<section class="content with-header">
					<xsl:call-template name="content" />
				</section>
			</div>
		</section>
	</div>

<xsl:if test="$debug=1">
	<xsl:call-template name="debug" />
</xsl:if>

</body>
</html>

</xsl:template>


</xsl:stylesheet>