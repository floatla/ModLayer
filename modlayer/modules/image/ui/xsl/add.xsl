<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:param name="message" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/css/image.css
		</xsl:with-param>
	</xsl:call-template>

	<script type="text/javascript">
		var UploadHandler = {};
		requirejs(['image/ui/js/upload'], function(ImageUpload){ 
			UploadHandler = ImageUpload;
			UploadHandler.bucketPath = "<!-- 
			 --><xsl:if test="$config/system/domain/@subdir"><!-- 
				 --><xsl:value-of select="$config/system/domain/@subdir"/><!-- 
			 --></xsl:if><!-- 
			 --><xsl:value-of select="$config/system/images_bucket"/><!-- 
		 -->/";
		});
	</script>

</xsl:variable>

<xsl:template name="content">
	<div style="margin-top:-45px;">
		<xsl:if test="$message != ''">
			<div class="alert">
				<xsl:value-of select="$message" disable-output-escaping="yes" />
			</div>
		</xsl:if>

		<xsl:call-template name="fileapi">
			<xsl:with-param name="handler">uploadComplete</xsl:with-param>
			<xsl:with-param name="formAction"><xsl:value-of select="$adminroot"/>image/bulk-update/</xsl:with-param>
		</xsl:call-template>
	</div>
</xsl:template>
</xsl:stylesheet>