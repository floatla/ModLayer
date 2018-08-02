<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />

<xsl:param name="item_id" />


<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html>
	<head>
		<xsl:call-template name="htmlHead" />
		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
			</xsl:with-param>
		</xsl:call-template>
		<!-- <xsl:call-template name="include.js">
			<xsl:with-param name="url">
				<xsl:value-of select="$modPath"/>/ui/js/assets.js
			</xsl:with-param>
		</xsl:call-template> -->
		<script>
			jsPanel = {}; 
			requirejs(['article/ui/js/assets'], function(Panel){ 
				jsPanel = Panel;
				jsPanel.BindActions();
			});
		</script>
	</head>

	<body class="body_panel">
		<form name="assets" action="{$adminroot}?m=article&amp;action=AddAsset" method="post">
			<input type="hidden" name="item_id" value="{$item_id}" />	
			<header>
				<h3>Agregar código externo</h3>
			</header>
			<section class="panel-body">
				<div style="padding:15px 0;">
					<p>Pegá el codigo externo</p>
					<xsl:text disable-output-escaping="yes">&lt;textarea name="asset" style="width:100%;height:120px;">&lt;/textarea></xsl:text>
					<div style="text-align:center;padding:10px 0;">
						<a href="#" class="btn" onclick="parent.appUI.ClosePanel();return false;">Cancelar</a>
						<button type="submit" class="btn lightblue">Guardar</button>
					</div>
				</div>
			</section>
		</form>
		<xsl:if test="$debug = 1">
			<xsl:call-template name="debug" />
		</xsl:if>
	</body>
</html>

</xsl:template>

</xsl:stylesheet>