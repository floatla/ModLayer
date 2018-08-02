<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />


<xsl:param name="item_id" />
<xsl:param name="type_id" />
<xsl:param name="module" />
<xsl:param name="categories" />


<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html>
	<head>
		<title><xsl:value-of select="$language/modal/embed/head_title"/></title>
		<xsl:call-template name="htmlHead" />

		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
				<xsl:value-of select="$modPath"/>/ui/css/image.css
			</xsl:with-param>
		</xsl:call-template>
		<!-- <xsl:call-template name="include.js">
			<xsl:with-param name="url">
				<xsl:value-of select="$modPath"/>/ui/js/modals.js
				<xsl:value-of select="$modPath"/>/ui/js/embed.js
			</xsl:with-param>
		</xsl:call-template> -->

		<script type="text/javascript">
			var jsPanel = {};
			requirejs(['image/ui/js/embed'], function(panel){ 
				<!-- panel.BindActions(); -->

				jsPanel = panel;
				jsPanel.bucket = "<!-- 
				 --><xsl:if test="$config/system/domain/@subdir"><!-- 
					 --><xsl:value-of select="$config/system/domain/@subdir"/><!-- 
				 --></xsl:if><!-- 
				 --><xsl:value-of select="$config/system/images_bucket"/><!-- 
			 -->/";
			});
		
		</script>

		<!-- <script type="text/javascript" >
			bucket = "<xsl:value-of select="$config/system/images_bucket"/>/";
		</script> -->
		<style type="text/css">
			.list-tools h3 {margin:-10px;}
			.list-tools h3 small {display:block;font-size:12px;line-height:14px;padding:0 0 5px;}
			.list-tools .right {margin-top:15px;}
			.selectControls {display:none;}
		</style>
	</head>
	<body class="body_panel">

		<header>
			<h3><xsl:value-of select="$language/modal/embed/insert_images"/></h3>
			
				<section class="list-header">
					<div class="list-tools floatFix">
						<xsl:choose>
							<xsl:when test="count(content/item//image) &gt; 1">
								<div class="galleryControls">
									<a href="#" onclick="jsPanel.SelectAll({$item_id});return false;" class="btn lightblue right selectAll" title=""><xsl:value-of select="$language/modal/embed/select_all"/></a>
									<a href="#" onclick="jsPanel.SelectEach({$item_id});return false;" class="btn right selectEach" ><xsl:value-of select="$language/modal/embed/select"/></a>
								</div>
								<div class="selectControls">
									<a href="#" onclick="jsPanel.SelectEachSave();return false;" class="btn lightblue right" ><xsl:value-of select="$language/item_editor/btn_save"/></a>
									<a href="#" onclick="jsPanel.SelectEachCancel();return false;" class="btn right" title=""><xsl:value-of select="$language/item_editor/btn_cancel"/></a>
								</div>
								<h3 class="boxtitle">
									<xsl:value-of select="$language/modal/embed/as_gallery"/>
									<small><xsl:value-of select="$language/modal/embed/gallery_order"/></small>
								</h3>
							</xsl:when>
							<xsl:otherwise>
								<h3 class="boxtitle">
									<xsl:value-of select="$language/modal/embed/as_gallery"/>
									<small><xsl:value-of select="$language/modal/embed/as_gallery_empty"/></small>
								</h3>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</section>
			
		</header>
		
		<section class="panel-body with-header">
			<xsl:if test="count(content/item//image) = 0">
				<div class="empty-list rounded">
	    			<xsl:value-of select="$language/modal/embed/no_related_images"/><br/>
	    			<a href="/admin/image/modal/?item_id={$item_id}&amp;callback=BackSetImage&amp;module={$module}&amp;categories={$categories}" class="btn lightblue"><xsl:value-of select="$language/modal/embed/btn_add_images"/></a>
	    		</div>
	    	</xsl:if>
			<div class="embed-images">
				<ul>
					<xsl:for-each select="content/item//image">
						<xsl:variable name="thisID" select="@image_id" />
						<li id="photo-{@image_id}" item_id="{@image_id}" type="{@type}">
							<span class="frame">
								<xsl:call-template name="image.bucket">
									<xsl:with-param name="id" select="@image_id" />
									<xsl:with-param name="type" select="@type" />
									<xsl:with-param name="width">240</xsl:with-param>
									<xsl:with-param name="height">240</xsl:with-param>
									<xsl:with-param name="class">pic</xsl:with-param>
								</xsl:call-template>
							</span>

							
							<h3>
								<xsl:value-of select="title" />
								<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
							</h3>
							<!-- <p>
								
							</p> -->
							<xsl:variable name="sumText">
								<xsl:call-template name="limit.string">
									<xsl:with-param name="string" select="summary" />
									<xsl:with-param name="limit">350</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<form name="image_{@image_id}" id="image_{@image_id}" method="post" action="{$adminroot}?m=photo" onsubmit="jsPanel.processPhoto(this);return false;">
								<input type="hidden" name="image_id" value="{@image_id}" />
								<input type="hidden" name="type" value="{@type}" />
								<input type="hidden" name="summarytext" value="{$sumText}" />
								<div class="floatFix">
									<div class="column left">
										<h4><xsl:value-of select="$language/modal/embed/align"/></h4>
										<p>
											<input type="radio" name="align" id="align1_{@image_id}" value="left" checked="checked"/> 
											<label for="align1_{@image_id}"><xsl:value-of select="$language/modal/embed/align_left"/></label>
										</p>
										<p>
											<input type="radio" name="align" id="align2_{@image_id}" value="right" /> 
											<label for="align2_{@image_id}"><xsl:value-of select="$language/modal/embed/align_right"/></label>
										</p>
										<p>
											<input type="radio" name="align" id="align3_{@image_id}" value="center" /> 
											<label for="align3_{@image_id}"><xsl:value-of select="$language/modal/embed/align_center"/></label>
										</p>
									</div>
									<div class="column right">
										<h4><xsl:value-of select="$language/modal/embed/size"/></h4>
										<p>
											<input type="radio" name="size" id="size1_{@image_id}" value="small" checked="checked"/> 
											<label for="size1_{@image_id}"><xsl:value-of select="$language/modal/embed/size_small"/></label>
										</p>
										<p>
											<input type="radio" name="size" id="size2_{@image_id}" value="medium" />
											<label for="size2_{@image_id}"><xsl:value-of select="$language/modal/embed/size_medium"/></label>
										</p>
										<p>
											<input type="radio" name="size" id="size3_{@image_id}" value="large" />
											<label for="size3_{@image_id}"><xsl:value-of select="$language/modal/embed/size_large"/></label>
										</p>
										<p>
											<input type="radio" name="size" id="size4_{@image_id}" value="source" />
											<label for="size4_{@image_id}"><xsl:value-of select="$language/modal/embed/size_source"/></label>
										</p>
									</div>
								</div>
								<div class="highlight floatFix">
									<div class="column left">
										<p>
											<input type="radio" name="align" id="align4_{@image_id}" value="highlight" /> 
											<label for="align4_{@image_id}">Portada</label>
										</p>
									</div>
									<div class="column right">
										<p>
											<input type="radio" name="size" id="size5_{@image_id}" value="bomb" /> 
											<label for="size5_{@image_id}">Bomba</label>
										</p>
										<p>
											<input type="radio" name="size" id="size6_{@image_id}" value="inline" /> 
											<label for="size6_{@image_id}">Encolumnada</label>
										</p>
									</div>
								</div>
								<footer class="floatFix">
									<button type="submit" class="btn lightblue right"><xsl:value-of select="$language/modal/embed/btn_embed"/></button>
									<input type="checkbox" name="summary" value="1" id="showsummary{position()}"/>
									<label for="showsummary{position()}"><xsl:value-of select="$language/modal/embed/show_epigraph"/></label>
								</footer>
							</form>
							<div class="selectGallery">
								<a href="#" class="btn border" onclick="jsPanel.addItem({@image_id}, '{@type}');return false;"><xsl:value-of select="$language/modal/embed/select"/></a>
								<span class="btn lightblue" style="display:none;">
									<img src="{$adminPath}/ui/imgs/icons/checkmarkw.png" alt="" style="margin:5px 0 0;"/>
								</span>
							</div>
						</li>
					</xsl:for-each>
				</ul>
		</div>
		</section>

		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>


	</body>
</html>

</xsl:template>


</xsl:stylesheet>