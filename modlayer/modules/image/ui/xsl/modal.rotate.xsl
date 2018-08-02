<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

<xsl:param name="modal">0</xsl:param>
<xsl:param name="item_id" />
<xsl:param name="categories" />
<xsl:param name="module" />

<xsl:variable name="photo" select="/xml/content/image" />

<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html>
	<head>
		<title>Relaciones</title>
		<xsl:call-template name="htmlHead" />
		
		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath" />/ui/css/sidepanel.css
				<xsl:value-of select="$modPath"/>/ui/css/image.css
			</xsl:with-param>
		</xsl:call-template>
		<script type="text/javascript">
			var jsPanel = {};
			requirejs(['image/ui/js/rotate'], function(rotate){ 
				rotate.init();
			});
		
		</script>
		<!-- <xsl:call-template name="include.js">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/js/jquery.form.min.js
				<xsl:value-of select="$modPath"/>/ui/js/rotate.js
			</xsl:with-param>
		</xsl:call-template> -->
	</head>
	<body class="body_panel">

		<header>
			<span class="right">
				<a class="btn" onclick="parent.appUI.ClosePanel();return false;">Cancelar</a>
			</span>
			<h3>Rotar Imagen</h3>
		</header>


		<section class="panel-body">	
			<div class="image-rotate">
				<xsl:variable name="photosrc">
					<xsl:call-template name="image.original.src">
						<xsl:with-param name="id" select="content/image/@image_id" />
						<xsl:with-param name="type" select="content/image/@type" />
					</xsl:call-template>
				</xsl:variable>
				<div class="hover">
					<img src="{$photosrc}?v={$horaActual}" id="target" style="max-width:100%;max-height:100%;" image_id="{content/image/@image_id}"/>
				</div>
			</div>
		</section>

		
		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>


	</body>
</html>

</xsl:template>


</xsl:stylesheet>