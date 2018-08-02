<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

<xsl:param name="modal">0</xsl:param>
<xsl:param name="item_id" />
<xsl:param name="categories" />
<xsl:param name="module" />

<xsl:variable name="image" select="/xml/content/image" />

<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html>
	<head>
		<title><xsl:value-of select="$language/modal/head_title"/></title>
		<xsl:call-template name="htmlHead" />
		
		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
				<xsl:value-of select="$modPath"/>/ui/css/jquery.Jcrop.css
			</xsl:with-param>
		</xsl:call-template>

		<script type="text/javascript">
			var jsPanel = {};
			requirejs(['image/ui/js/crop'], function(panel){ 
				

				jsPanel = panel;
				jsPanel._width  = <xsl:value-of select="$image/@width"  />;
				jsPanel._height = <xsl:value-of select="$image/@height"  />;
				<xsl:if test="$context/get_params/modal">
				jsPanel._modal = <xsl:value-of select="$context/get_params/modal"  />;
				</xsl:if>
				<xsl:if test="$context/get_params/item_id">
				jsPanel._item_id = <xsl:value-of select="$context/get_params/item_id" />;
				</xsl:if>

				jsPanel._callback = 'BackSetImage';
				jsPanel._categories = '<xsl:value-of select="$context/get_params/categories" />';
				jsPanel._module = '<xsl:value-of select="$context/get_params/module" />';


				jsPanel.bucket = "<!-- 
				 --><xsl:if test="$config/system/domain/@subdir"><!-- 
					 --><xsl:value-of select="$config/system/domain/@subdir"/><!-- 
				 --></xsl:if><!-- 
				 --><xsl:value-of select="$config/system/images_bucket"/><!-- 
			 -->/";
			 	panel.BindActions();
			});
		
		</script>
	</head>
	<body class="body_panel">

		<header>
			<span class="right">
				<form name="cropimage" action="{$adminroot}{$modName}/crop-image/" method="post" onsubmit="return jsPanel.checkCoords();">
					<input type="hidden" name="image_id" value="{$image/@image_id}" />
					<input type="hidden" id="x" name="x" />
					<input type="hidden" id="y" name="y" />
					<input type="hidden" id="w" name="w" />
					<input type="hidden" id="h" name="h" />
					<input type="hidden" name="tw" value="{$image/@width}" />
					<input type="hidden" name="th" value="{$image/@height}" />
					<xsl:choose>
						<xsl:when test="$modal = 1">
							<a class="btn" onclick="history.go(-1);return false;"><xsl:value-of select="$language/modal/crop/back" /></a>
						</xsl:when>
						<xsl:otherwise>
							<a class="btn" onclick="parent.appUI.ClosePanel();return false;"><xsl:value-of select="$language/item_editor/btn_cancel" /></a>
						</xsl:otherwise>
					</xsl:choose>
					<button type="submit" class="btn blue"><xsl:value-of select="$language/modal/crop/generate_image" /></button>
					<!-- <input type="submit" value="Crop Image" class="btn btn-large btn-inverse" /> -->
				</form>
			</span>
			<h3><xsl:value-of select="$language/modal/crop/create_new_image" /></h3>
		</header>


		<section class="panel-body">	
			<p><xsl:value-of select="$language/modal/crop/select_crop_area" /></p>
			<div class="image-crop">
				<xsl:variable name="photosrc">
					<xsl:call-template name="image.original.src">
						<xsl:with-param name="id" select="content/image/@image_id" />
						<xsl:with-param name="type" select="content/image/@type" />
					</xsl:call-template>
				</xsl:variable>
				<img src="{$photosrc}" id="cropbox" style="max-width:100%;max-height:100%;" />
			</div>
		</section>

		
		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>


	</body>
</html>

</xsl:template>


</xsl:stylesheet>