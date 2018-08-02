<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:param name="category_id" />
<xsl:param name="query" />
<xsl:param name="filter" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/css/image.css
		</xsl:with-param>
	</xsl:call-template>
	<script> 
		var jsCollection = {} 
		requirejs(['admin/ui/js/app/controller/collection'], function(List){ 
			jsCollection = List;
			List.BindActions();
		});
    </script>
</xsl:variable>


<xsl:template name="content">

	<xsl:call-template name="filter.list" />

		<div class="list-header floatFix">
			<xsl:call-template name="pagination.box" />
			<div class="list-actions">
				<span>
					<input type="checkbox" name="all" id="all" class="checkAll" />
					<label for="all"><xsl:value-of select="$language/collection/select_items" /></label>
				</span>
				<span>
					<xsl:value-of select="$language/collection/selected_label" />
					<xsl:if test="content/filter/group//category">
						<a href="#" class="btn blue categories"><xsl:value-of select="$language/collection/selected_setCategory" /></a>
					</xsl:if>
					<!-- <a href="#" class="btn duplicate">Duplicar</a> -->
					<a href="#" class="btn red delete"><xsl:value-of select="$language/collection/delete_selected" /></a>
				</span>
			</div>
		</div>

		<section class="collection" id="grid">
			<xsl:if test="$query != ''">
				<div class="alert">
					<xsl:value-of select="$language/messages/showing_query_results" />&#xa0;<strong><em>"<xsl:value-of select="$query"/>"</em></strong>
					<xsl:if test="$categories != ''">&#xa0;<xsl:value-of select="$language/messages/with_category_filter"/><xsl:value-of select="//category[@category_id=$category_id]/name" /></xsl:if>
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
				</div>
		    </xsl:if>

		    <xsl:choose>
		    	<xsl:when test="not(content/collection/image) and $query = ''">
					<div class="empty-list rounded">
		    			<xsl:value-of select="$language/messages/empty_list/nothing_found"/><br/>
		    			<xsl:value-of select="$language/messages/empty_list/load_new"/><br/>
		    			<a href="{$adminroot}{$modName}/add/" class="btn lightblue"><xsl:value-of select="$language/item_editor/btn_add"/></a>
		    		</div>
				</xsl:when>
				<xsl:otherwise>
					<ul class="multimedia multimedia-list" data-role="list-rows">
						<xsl:for-each select="content/collection/image">
							<!--<xsl:sort order="descending" select="@image_id" />-->
							<li id="object_{@image_id}" item_id="{@image_id}">
								<xsl:if test="position() mod 4 = 0">
									<xsl:attribute name="class">side</xsl:attribute>
								</xsl:if>
								<xsl:if test="position() mod 2 = 0">
									<xsl:attribute name="class">alt</xsl:attribute>
								</xsl:if>
								<div class="preview">
									<a href="{$adminroot}image/edit/{@image_id}">
										<xsl:call-template name="image.bucket">
											<xsl:with-param name="id" select="@image_id" />
											<xsl:with-param name="type" select="@type" />
											<xsl:with-param name="width">260</xsl:with-param>
											<xsl:with-param name="height">260</xsl:with-param>
											<xsl:with-param name="class">pic</xsl:with-param>
										</xsl:call-template>
									</a>
								</div>
								<h3>
									<a href="{$adminroot}image/edit/{@image_id}">
										<xsl:value-of select="title" />
										<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
									</a>
								</h3>
								<span class="dimensions">
									<xsl:value-of select="@width" /> x <xsl:value-of select="@height" />
									|
									<xsl:choose>
										<xsl:when test="@weight='' or not(@weight)">
											<xsl:value-of select="$language/collection/no_weight"/>
										</xsl:when>
										<xsl:when test="@weight &gt; 1000000">
											<xsl:value-of select='format-number(@weight div 1000000, "#.##")' /> Mb
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select='format-number(@weight div 1000, "#.##")' /> Kb
										</xsl:otherwise>
									</xsl:choose>
								</span>
								<div class="footer">
									<xsl:variable name="original">
										<xsl:call-template name="image.original.src">
											<xsl:with-param name="id" select="@image_id" />
											<xsl:with-param name="type" select="@type" />
										</xsl:call-template>
									</xsl:variable>
									<div class="quick right">
										<a href="{$adminroot}{$modulename}/crop/{@image_id}/?width=800&amp;height=window" onclick="window.appUI.OpenPanel(this.href);return false;" class="tooltip" title="{$language/item_editor/multimedias/crop_image}"><i class="fas fa-cut">&#xa0;</i></a>
										<a href="{$adminroot}{$modulename}/edit/{@image_id}" class="tooltip" title="{$language/collection/btn_edit}"><i class="fas fa-pencil-alt ">&#xa0;</i></a> 
										<a href="{$original}" target="_blank" class="tooltip" title="{$language/item_editor/view_original}"><i class="fa fa-external-link-alt">&#xa0;</i></a> 
										<a class="tooltip delete" href="#" title="{$language/collection/btn_delete}"><i class="fas fa-eraser">&#xa0;</i></a>
										<!-- <a href="#" class="icon-plus-sign more-data" style="vertical-align:middle;">&#xa0;</a> -->
									</div>
									<input type="checkbox" name="check" class="check" />
								</div>
								<xsl:if test="summary != '' or credit != '' or categories/*/category">
									<div class="info">
										<xsl:if test="summary != ''">
											<span class="summary">
												<xsl:call-template name="limit.string">
													<xsl:with-param name="string" select="summary" />
													<xsl:with-param name="limit">240</xsl:with-param>
												</xsl:call-template>
												<xsl:comment />
											</span>
										</xsl:if>
										<xsl:if test="credit != ''">
											<span class="credit">
												<xsl:value-of select="$language/item_editor/labels/image_credits"/>: <xsl:value-of select="credit"  />
											</span>
										</xsl:if>
										<xsl:if test="categories/*/category">
											<div class="categories">
												<xsl:for-each select="categories/*/category">
													<xsl:sort order="ascending" select="@order" data-type="number"/>
														<!-- <a class="category" href="{$adminroot}{$modName}/list/?categories={@category_id}"><xsl:value-of select="name" /></a><br/> -->
														<span class="category rounded" category_id="{@category_id}">
															<a href="{$adminroot}{$modName}/list/?categories[]={@category_id}">
																<xsl:value-of select="name" />
															</a>
															<a href="javascript:void(0);" title="{$language/collection/delete_category}" onclick="category.delete({@category_id}, {../../../@image_id});" class="remove">&#xa0;</a>
														</span>
												</xsl:for-each>
											</div>
										</xsl:if>
									</div>
								</xsl:if>
							</li>
						</xsl:for-each>
					</ul>
		    	</xsl:otherwise>
		    </xsl:choose>
		</section>
</xsl:template>
</xsl:stylesheet>