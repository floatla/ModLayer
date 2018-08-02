<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

<xsl:param name="item_id" />
<xsl:param name="type_id" />
<xsl:param name="categories" />
<xsl:param name="parent_id" />
<xsl:param name="module" />
<xsl:param name="edit" />
<xsl:param name="parent" />
<xsl:param name="query" />

<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html>
	<head>
		<xsl:call-template name="htmlHead" />
		<xsl:call-template name="include.css">
			<xsl:with-param name="url">
				<xsl:value-of select="$adminPath"/>/ui/css/sidepanel.css
				<xsl:value-of select="$modPath"/>/ui/css/image.css
			</xsl:with-param>
		</xsl:call-template>
		<!-- <xsl:call-template name="include.js">
			<xsl:with-param name="url">
				<xsl:value-of select="$modPath"/>/ui/js/upload.js
			</xsl:with-param>
		</xsl:call-template> -->

		<script type="text/javascript">
			var UploadHandler = {};
			requirejs(['image/ui/js/upload', 'multimedia/ui/js/modals'], function(ImageUpload, Panel){ 
				UploadHandler = ImageUpload;
				UploadHandler.bucketPath = "<!-- 
				 --><xsl:if test="$config/system/domain/@subdir"><!-- 
					 --><xsl:value-of select="$config/system/domain/@subdir"/><!-- 
				 --></xsl:if><!-- 
				 --><xsl:value-of select="$config/system/images_bucket"/><!-- 
			 -->/";
			 	Panel.BindActions();
			});
	
		</script>
	</head>
	<body class="body_panel">
		<header>
			<div class="search">
				<form name="search" action="{$adminroot}{$modName}/modal/" method="get">
					<input type="text" name="q" value="" placeholder="{$language/system_wide/btn_search}" />
					<xsl:for-each select="/xml/context/get_params/*[not(name()='q')]">
						<input type="hidden" name="{name()}" value="{.}" />	
					</xsl:for-each>
					<button type="submit"><xsl:value-of select="$language/system_wide/btn_search"/></button>
				</form>
			</div>
			<h3><xsl:value-of select="$language/modal/list/related_images"/></h3>

			<section class="list-header floatFix">
				<div class="list-tools floatFix">

					<xsl:variable name="modalurl"><!-- 
					 --><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/modal/<!-- 
					 --><xsl:if test="$query != ''">search/</xsl:if><!-- 
					-->?<!-- 
					 --><xsl:for-each select="context/get_params/*[not(name()='page')]"><!-- 
						 --><xsl:value-of select="name()"/>=<xsl:value-of select="."/><xsl:if test="position()!=last()">&amp;</xsl:if><!-- 
					 --></xsl:for-each><!-- 
				 --></xsl:variable>
					<xsl:call-template name="pagination">
						<xsl:with-param name="total" select="content/collection/@total" />
						<xsl:with-param name="display" select="content/collection/@pageSize" />
						<xsl:with-param name="currentPage" select="content/collection/@currentPage" />
						<xsl:with-param name="url" select="$modalurl" />
					</xsl:call-template>

					<xsl:call-template name="filter.combo" />

					<xsl:if test="$query = ''">
						<button href="#" class="btn upload"><span class="icon upload" style="vertical-align:-4px;">&#xa0;</span><xsl:value-of select="$language/modal/list/btn_upload"/></button>
					</xsl:if>
				</div>
				<div class="upload-tools" style="display:none;">
					<button href="#" class="btn back"><xsl:value-of select="$language/modal/list/back_to_list"/></button>
				</div>
			</section>
		</header>

		<section class="panel-body with-header">
			<!-- <xsl:if test="$query != ''">
				<a style="display:block;background:#3a3a3a;color:#fff;padding:5px 10px;margin:0 0 10px 0;">
					<xsl:attribute name="href">
						<xsl:for-each select="/xml/context/get_params/*[not(name()='q')]">
							<input type="hidden" name="{name()}" value="{.}" />	
						</xsl:for-each>
					</xsl:attribute>
					« <xsl:value-of select="$language/modal/list/results"/> "<xsl:value-of select="$query"/>". <xsl:value-of select="$language/modal/list/back_to_list"/>
				</a>
			</xsl:if> -->
			<xsl:if test="$query != ''">
				<div class="alert">
					<xsl:value-of select="$language/messages/showing_query_results" />&#xa0;<strong><em>"<xsl:value-of select="$query"/>"</em></strong>
					<xsl:variable name="found">
						<xsl:choose>
							<xsl:when test="/xml/content/collection/@total !=''">
								<xsl:value-of select="/xml/content/collection/@total" />
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$found = 1">
							(<xsl:value-of select="$found" />&#xa0;<xsl:value-of select="$language/messages/element_found"/>)
						</xsl:when>
						<xsl:otherwise>
							(<xsl:value-of select="$found" />&#xa0;<xsl:value-of select="$language/messages/elements_found"/>)
						</xsl:otherwise>
					</xsl:choose>
					<a href="''"><xsl:value-of select="$language/modal/list/back_to_list"/></a>
				</div>
		    </xsl:if>
			<div id="grid" class="grid-multimedia">
				<xsl:if test="count(content/collection/image) = 0">
					<div class="empty-list rounded">
		    			<xsl:value-of select="$language/modal/list/empty_image_list"/>
		    		</div>
		    	</xsl:if>
				<ul class="multimedia-list">
					<xsl:for-each select="content/collection//image">
						<li item_id="{@image_id}" class="no-footer">
							<xsl:variable name="thisID" select="@image_id" />
							<xsl:if test="$thisID = $content/item//image/@image_id">
								<xsl:attribute name="class">related no-footer</xsl:attribute>
							</xsl:if>
							<div class="preview">
								<xsl:call-template name="image.bucket">
									<xsl:with-param name="id" select="@image_id" />
									<xsl:with-param name="type" select="@type" />
									<xsl:with-param name="width">200</xsl:with-param>
									<xsl:with-param name="height">200</xsl:with-param>
									<xsl:with-param name="class">pic</xsl:with-param>
								</xsl:call-template>
							</div>
							<h3 style="overflow:hidden;">
								<xsl:value-of select="title" />
								<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
							</h3>
							<span class="dimensions">
								<xsl:value-of select="@width" /> x <xsl:value-of select="@height" />
								| 
								<xsl:choose>
									<xsl:when test="@weight='' or not(@weight)">
										--
									</xsl:when>
									<xsl:when test="@weight &gt; 1000000">
										<xsl:value-of select='format-number(@weight div 1000000, "#.##")' /> Mb
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select='format-number(@weight div 1000, "#.##")' /> Kb
									</xsl:otherwise>
								</xsl:choose>
							</span>

							<div class="quick right" style="height:30px;">
								<a href="{$adminroot}{$modulename}/crop/{@image_id}/?modal=1&amp;item_id={$item_id}&amp;categories={$categories}&amp;module={$module}" class="icon crop" title="{$language/item_editor/multimedias/crop_image}" rel="tooltip" style="vertical-align:middle;height:26px;margin:0 5px 0 0;"><xsl:value-of select="$language/item_editor/multimedias/crop_image"/></a>
								<xsl:choose>
									<xsl:when test="not($thisID = $content/item//image/@image_id)">
										<a style="line-height:19px;" href="#" onclick="parent.MultimediaService.setRelation({$item_id},{@image_id},{@type_id});return false;" class="btn"><xsl:value-of select="$language/system_wide/ok"/></a>
									</xsl:when>
									<xsl:otherwise>
										<span class="right"><span class="icon ok">&#xa0;</span></span>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</li>
					</xsl:for-each>
				</ul>
			</div>
			
			<div class="upload-container" style="display:none">
				<xsl:call-template name="fileapi">
					<xsl:with-param name="handler">UploadHandler</xsl:with-param>
					<xsl:with-param name="formAction"><xsl:value-of select="$adminroot"/>image/bulk-update/</xsl:with-param>
					<xsl:with-param name="postParams"><!-- 
						 -->category_id=<xsl:value-of select="$categories" />|<!-- 
						 -->parent=<xsl:value-of select="$parent_id" />|<!-- 
						 -->item_id=<xsl:value-of select="$item_id" />|<!-- 
						 -->module=<xsl:value-of select="$module" />|<!-- 
						 -->url=<xsl:value-of select="$request_uri"/><!-- 
					 --></xsl:with-param>
				</xsl:call-template>
			</div>
		</section>

		<xsl:if test="$debug=1">
			<xsl:call-template name="debug" />
		</xsl:if>
	</body>
</html>

</xsl:template>

<!-- 
	filter.combo
	General el desplegable para filtrar el modal por categorias 
-->
<xsl:template name="filter.combo">
	<xsl:variable name="filter" select="$content/filter" />

	<xsl:variable name="modalurl"><!-- 
		--><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/modal/<!-- 
		-->?<!-- 
		--><xsl:for-each select="/xml/context/get_params/*[not(name()='categories')]"><!-- 
			 --><xsl:value-of select="name()"/>=<xsl:value-of select="."/><xsl:if test="position()!=last()">&amp;</xsl:if><!-- 
		--></xsl:for-each><!-- 
	--></xsl:variable>

	<xsl:if test="$filter/group//category">
		<xsl:for-each select="$filter/group">
			<div class="filters dropdown">
				<span class="btn trigger" data-toggle="dropdown">
						<xsl:value-of select="@name" />
						<xsl:if test="$categories != '' and .//category[@category_id=$categories]"> &#x02192; <xsl:value-of select=".//category[@category_id=$categories]/name" />&#xa0;</xsl:if>
				</span>
				<ul class="dropdown-menu left">
			    	<xsl:for-each select="categories/category">
						<xsl:call-template name="filter.combo.item">
							<xsl:with-param name="modalurl" select="$modalurl" />
						</xsl:call-template>
					</xsl:for-each>
					<li class="line">&#xa0;</li>
					<li>
						<a>
							<xsl:attribute name="href"><xsl:value-of select="$modalurl"/>&amp;page=1</xsl:attribute>
							<xsl:value-of select="$language/modal/list/show_all" />
						</a>
					</li>
				</ul>
			</div>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template name="filter.combo.item">
	<xsl:param name="prefix" />
	<xsl:param name="modalurl" />
	
	<li>
		<xsl:if test="@category_id = $categories">
			<xsl:attribute name="class">active</xsl:attribute>
		</xsl:if>
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="$modalurl"/>&amp;page=1&amp;categories=<xsl:value-of select="@category_id"/>
			</xsl:attribute>
			<xsl:if test="$prefix != ''"><xsl:value-of select="$prefix" /></xsl:if>
			<xsl:value-of select="name" />
		</a>
	</li>
	<xsl:if test="categories/category">
		<xsl:for-each select="categories/category">
			<xsl:call-template name="filter.combo.item">
				<xsl:with-param name="prefix"><xsl:value-of select="$prefix"/>- </xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>