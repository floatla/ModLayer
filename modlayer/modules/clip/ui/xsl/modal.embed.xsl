<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />


<xsl:param name="item_id" />
<xsl:param name="module" />


<xsl:template match="/xml">

	
<html>
	<head>
		<title><xsl:value-of select="$language/modal/embed/head_title"/></title>
		<xsl:call-template name="htmlHead" />
		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
				<xsl:value-of select="$modPath"/>/ui/css/clip.css
			</xsl:with-param>
		</xsl:call-template>

		<script>
			jsPanel = {}; 
			requirejs(['clip/ui/js/embed'], function(EmbedPanel){ 
				jsPanel = EmbedPanel;
			});
		</script>

		<!-- <xsl:call-template name="include.js">
			<xsl:with-param name="url">
				<xsl:value-of select="$modPath"/>/ui/js/embed.js
			</xsl:with-param>
		</xsl:call-template>

		<script type="text/javascript" >
			videoPath  = "/<xsl:value-of select="$config/module/options/group[@name='folders']/option[@name='target']"/>/";
			modPath    = "<xsl:value-of select="$modPath" />";
		</script> -->
	</head>
	<body class="body_panel">

		<header>
			<h3><xsl:value-of select="$language/modal/embed/insert_clips"/></h3>
		</header>

		<section class="panel-body">
			<div style="padding:15px 0 0;">
				<div id="listado" class="on listado">
					<xsl:if test="count(content/relations/clips) = 0">
						<div class="empty-list rounded">
			    			<xsl:value-of select="$language/modal/embed/no_related_clips"/><br/>
			    			<a href="{$adminroot}?m=clip&amp;action=RenderItemRelations&amp;item_id={$item_id}&amp;module={$module}" class="btn lightblue"><xsl:value-of select="$language/modal/embed/btn_add_clips" /></a>
			    		</div>
			    	</xsl:if>
					<ul class="clip-list">
						<xsl:if test="position() mod 2 = 0">
							<xsl:attribute name="class">alt</xsl:attribute>
						</xsl:if>
						<xsl:for-each select="content/relations/clips/clip">
							<xsl:variable name="thisID" select="@id" />
							<li id="clip-{@id}">
								<xsl:choose>
									<xsl:when test="multimedias/images/image">
										<span class="frame">
											<xsl:call-template name="image.bucket">
												<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
												<xsl:with-param name="type" select="multimedias/images/image/@type" />
												<xsl:with-param name="width">240</xsl:with-param>
												<xsl:with-param name="height">135</xsl:with-param>
												<xsl:with-param name="crop">c</xsl:with-param>
												<xsl:with-param name="class">pic</xsl:with-param>
											</xsl:call-template>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<span class="frame pic">
											<span class="no-pic"><xsl:comment /></span>
										</span>
									</xsl:otherwise>
								</xsl:choose>
								
								<h3><xsl:value-of select="title" /></h3>
								<!-- <xsl:value-of select="summary" disable-output-escaping="yes"/> -->
								
								<xsl:variable name="img_id" select="multimedias/images/image/@image_id" />
								<xsl:variable name="poster"><!-- 
									 --><xsl:value-of select="$config/system/images_bucket" />/<!-- 
									 --><xsl:value-of select="substring($img_id, string-length($img_id), 1)" />/<!-- 
									 --><xsl:value-of select="$img_id" />w620h440c.<!-- 
									 --><xsl:value-of select="multimedias/images/image/@type" /><!-- 
								--></xsl:variable>
								<div class="quick-modal quick">
									<form name="clip_{@id}" id="clip_{@id}" method="post" action="{$config/system/adminpath}" onsubmit="jsPanel.processClip(this);return false;">
										<input type="hidden" name="id" value="{@id}" />
										<input type="hidden" name="poster" value="{$poster}" />
										<input type="hidden" name="title" value="{title}" />
										<button type="submit" class="btn"><xsl:value-of select="$language/modal/embed/btn_embed" /></button>
									</form>
								</div>

							</li>
						</xsl:for-each>
					</ul>
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