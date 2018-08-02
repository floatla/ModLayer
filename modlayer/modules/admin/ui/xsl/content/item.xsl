<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

	<!-- Editor -->
	<xsl:template name="display.item.edit">
		<xsl:param name="object" />
		<xsl:param name="id_field" />
		<xsl:param name="html" />
		<xsl:param name="preview" />
		<xsl:param name="latname" />
		<xsl:param name="lngname" />
		<xsl:param name="metadata" />
		<xsl:variable name="item_id" select="$object/@id | $object/@*[name() = $id_field] | $object/*[name() = $id_field]" />
		<script>
			var jsItem = {};
			requirejs(['admin/ui/js/app/controller/item'], function(Item){ 
				jsItem = new Item(<xsl:value-of select="$item_id" />);
				jsItem._state  = <xsl:value-of select="$object/@state" />;
				jsItem._module = "<xsl:value-of select="$modName" />";
				jsItem.BindActions();
			});
		</script>
    


		<div class="item-edit state-{$object/@state}">
			<form name="edit" action="{$adminroot}{$config/module/@name}/edit/" method="post">
				<input type="hidden" name="modToken" value="{$modToken}" />
				<input type="hidden" name="{$id_field}" value="{$item_id}" />
				<input type="hidden" name="updated_by" value="{$config/user/@user_id}" />
				<input type="hidden" name="updated_type" value="backend" />
				<input type="hidden" name="item_id" value="{$item_id}" disabled="disabled" />
				<input type="hidden" name="back" id="SaveAndBack" value="0" />

				
				<section class="edit-header floatFix">
					<span class="right">
							<a 
								data-role="item-popup"
								class="header-icon tooltip" 
								title="{$language/collection/btn_popout}" 
								href="{$adminroot}?m={$modName}&amp;action=GotoItem&amp;id={$item_id}" 
								target="_blank" 
							>
								<xsl:if test="$object/@state = 0 or $object/@state = 4">
									<xsl:attribute name="style">display:none;</xsl:attribute>
								</xsl:if>
								<i class="fa fa-external-link-alt"><xsl:comment /></i>
							</a>
						<xsl:if test="$preview != ''">
							<a 
								data-role="item-preview"
								class="header-icon tooltip" 
								title="{$language/collection/btn_preview}" 
								href="{$preview}" 
								target="_blank" 
							>
								<i class="fa fa-eye"><xsl:comment /></i>
							</a>
						</xsl:if>
						
						<a href="{$adminroot}{$modName}/return/" class="btn"><xsl:value-of select="$language/item_editor/btn_cancel"/></a>
						<button type="button" onclick="jsItem._back=1;$('#SaveAndBack').val('1');$('form[name=edit]').submit();" class="btn save-back"><span><xsl:value-of select="$language/item_editor/btn_back"/></span></button>
						<button type="submit" class="btn lightblue"><span><xsl:value-of select="$language/item_editor/btn_save"/></span></button>
					 </span>
					<h2><xsl:value-of select="$language/item_editor/page_title"/></h2>
					<div class="alert"><!-- Para mensajes --></div>
				</section>

				
				<div class="floatFix">
					<section class="item-sidebar" id="tools">
						<xsl:call-template name="item.date">
							<xsl:with-param name="item" select="$object" />
						</xsl:call-template>
		
						<xsl:call-template name="item.metadata">
							<xsl:with-param name="item" select="$object" />
						</xsl:call-template>
					
						<xsl:call-template name="item.categories">
							<xsl:with-param name="item" select="$object" />
						</xsl:call-template>
						
						<xsl:call-template name="item.geolocation">
							<xsl:with-param name="latname" select="$latname" />
							<xsl:with-param name="lngname" select="$lngname" />
							<xsl:with-param name="item" select="$object" />
						</xsl:call-template>

						<div class="sidebar-box">
							<label><xsl:value-of select="$language/item_editor/label_delete"/></label>
							<p style="text-align:center;">
								<a class="btn red" href="#" onclick="jsItem.delete({$item_id});return false;">
									<xsl:value-of select="$language/item_editor/btn_delete"/>
								</a>
							</p>
						</div>
					</section>

					<section class="item-body">
						<xsl:copy-of select="$html" />

						<xsl:call-template name="element.parent">
							<xsl:with-param name="item" select="$object" />
						</xsl:call-template>
					</section>
				</div>
			</form>
		</div>

		<div class="item-extras">
			
			<xsl:call-template name="roles">
				<xsl:with-param name="object" select="$object" />
				<xsl:with-param name="item_id" select="$item_id" />
			</xsl:call-template>

			<xsl:if test="$config/module/options/group[@name='multimedias']/option">
				<xsl:call-template name="relations.multimedia">
					<xsl:with-param name="item" select="$object" />
					<xsl:with-param name="item_id" select="$item_id" />
				</xsl:call-template>
			</xsl:if>

			<xsl:call-template name="relations.modules">
				<xsl:with-param name="item" select="$object" />
				<xsl:with-param name="item_id" select="$item_id" />
			</xsl:call-template>

			

			<xsl:if test="content/children/collection">
				<script>
					var jsChildren = {};
					requirejs(['element/ui/js/children'], function(Children){ 
						jsChildren = Children;
					});
				</script>
				<div class="item-relation" data-role="children">
					<xsl:for-each select="content/children/collection">
						<div class="item-collection" module="{@name}">
							<div class="right" style="padding:5px 5px 0 0;">
								<xsl:call-template name="pagination.ajax">
									<xsl:with-param name="total" select="@total" />
									<xsl:with-param name="perPage" select="@pageSize" />
									<xsl:with-param name="currentPage" select="@currentPage" />
									<xsl:with-param name="onclick">jsChildren.pagination</xsl:with-param>
									<xsl:with-param name="parent_id" select="$item_id" />
									<xsl:with-param name="module" select="@name" />
								</xsl:call-template>
							</div>
							<div class="boxtitle" style="margin:0 0 5px 0;padding:8px 10px;">
								<xsl:call-template name="lang-eval">
									<xsl:with-param name="pPath" select="@label" />
								</xsl:call-template>
							</div>
							<ul id="relation-{@name}" class="relation module" data-role="children" module="{@name}">
								<xsl:for-each select="object">
									<xsl:sort order="descending" select="@created_at" />
									<li item_id="{@id}" class="state-{@state}">
										<xsl:choose>
											<xsl:when test="multimedias/images/image">
												<span class="frame">
													<a href="{$adminroot}{../@name}/edit/{@id}">
														<xsl:call-template name="image.bucket">
															<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
															<xsl:with-param name="type" select="multimedias/images/image/@type" />
															<xsl:with-param name="width">320</xsl:with-param>
															<xsl:with-param name="height">180</xsl:with-param>
															<xsl:with-param name="crop">c</xsl:with-param>
														</xsl:call-template>
													</a>
												</span>		
											</xsl:when>
											<xsl:otherwise>
												<span class="frame">
													<span class="no-pic"><xsl:comment /></span>
												</span>
											</xsl:otherwise>
										</xsl:choose>

										<h3>
											<a href="{$adminroot}{../@name}/edit/{@id}">
												<xsl:value-of select="title | name"/>
											</a>
										</h3>
										<xsl:if test="summary != ''">
											<p>
												<xsl:call-template name="limit.string">
													<xsl:with-param name="string" select="summary" />
													<xsl:with-param name="limit">130</xsl:with-param>
												</xsl:call-template>
											</p>
										</xsl:if>
										

										<xsl:if test="../@name = 'clip'">
											<span class="info size">
												<a href="{$adminroot}?m=clip&amp;action=RenderPreview&amp;id={@id}" class="icon play tooltip" style="margin:0 0 -5px 0;" title="{$language/collection/btn_preview}" onclick="window.appUI.OpenPanel(this.href);return false;"><xsl:value-of select="$language/collection/btn_preview"/></a>
											</span>	
										</xsl:if>

										<span class="info actions">
											<a class="icon delete tooltip" href="#" onclick="jsChildren.unlinkChild({@id}, '{../@name}');return false;" title="{$language/item_editor/unlink_parent_child}"><xsl:value-of select="$language/item_editor/unlink_parent_child"/></a>
										</span>
									</li>
								</xsl:for-each>
							</ul>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	<!-- / Editor -->

	<!-- Metadata -->
	<xsl:template name="item.metadata">
		<xsl:param name="item" />

		<xsl:if test="$item/metatitle and $item/metadescription">
			<div class="sidebar-box">
				<p class="row">
					<label><xsl:value-of select="$language/item_editor/meta_title"/></label>
					<xsl:choose>
						<xsl:when test="$item/metatitle != ''">
							<input type="text" name="metatitle" value="{$item/metatitle}" style="width:100%;" maxlength="200"/>
						</xsl:when>
						<xsl:otherwise>
							<input type="text" name="metatitle" value="{$item/title}" style="width:100%;" maxlength="200"/>
						</xsl:otherwise>
					</xsl:choose>
				</p>
				<p class="last">
					<label><xsl:value-of select="$language/item_editor/meta_description"/></label>
					<xsl:choose>
						<xsl:when test="$item/metadescription != ''">
							<input type="text" maxlength="200" name="metadescription" value="{$item/metadescription}" style="width:100%;"/>
						</xsl:when>
						<xsl:otherwise>
							<input type="text" maxlength="200" name="metadescription" value="{substring($item/summary, 0, 200)}" style="width:100%;"/>
						</xsl:otherwise>
					</xsl:choose>
				</p>
			</div>
		</xsl:if>
	</xsl:template>
	<!-- / Metadata -->

	<!-- Publicación -->
	<xsl:template name="item.date">
		<xsl:param name="item" />

		<div class="sidebar-box currentState">
			<xsl:choose>
				<xsl:when test="$config/module/options/group[@name='item-states']/option">
					<xsl:for-each select="$config/module/options/group[@name='item-states']/option">
						<p class="pub" data-role="{@value}">
							<b><xsl:value-of select="$language/item_editor/status" /></b>&#xa0;<!-- 
							 --><xsl:call-template name="lang-eval">
								<xsl:with-param name="pPath" select="@label" />
							</xsl:call-template>
							<br/>
							<a href="#" onclick="jsItem.changeState({$item/@id}, {@turns});return false;" class="btn state-{@turns}">
								<xsl:value-of select="@turns_label"  />
							</a>
						</p>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$config/element_conf/group[@name='item-states']/option">
						<p class="pub" data-role="{@value}">
							<b><xsl:value-of select="$language/item_editor/status" /></b>&#xa0;<!-- 
							 --><xsl:call-template name="lang-eval">
								<xsl:with-param name="pPath" select="@label" />
							</xsl:call-template>
							<br/>
							<a href="#" onclick="jsItem.changeState({$item/@id}, {@turns});return false;" class="btn state-{@turns}">
								<xsl:value-of select="@turns_label"  />
							</a>
						</p>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<div class="loader">
				<img src="{$adminPath}/ui/imgs/icons/ripple.svg" width="56" />
			</div>
			<!-- Manejar los estados desde la configuración del módulo -->
			
			<xsl:if test="$config/module/options/group[@name='settings']/option[@name='deferredPublication']/@value = 'true'">
				<div class="deferred floatFix">
					<span class="right">
						<input type="radio" name="deferred" value="1" id="deferred1" onclick="jsItem.deferred_on();">
							<xsl:if test="$item/@state = 4">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="deferred1"><xsl:value-of select="$language/item_editor/labels/radio_yes" /></label>
						<input type="radio" name="deferred" value="0" id="deferred0" onclick="jsItem.deferred_off();">
							<xsl:if test="$item/@state != 4">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="deferred0"><xsl:value-of select="$language/item_editor/labels/radio_no" /></label>
					</span>
					<xsl:value-of select="$language/item_editor/labels/deferred_publication" />
					<div class="deferredDate">
						<xsl:if test="$item/@state = 4">
							<xsl:attribute name="class">deferredDate open</xsl:attribute>
						</xsl:if>
						<input type="text" name="deferred_publication" value="{$item/deferred_publication}" class="datefield"  id="pub-field" readonly="true"/>
					</div>
				</div>
			</xsl:if>

			<hr />

			<p class="field floatFix">
				<label><xsl:value-of select="$language/item_editor/labels/article_date" /></label>
				<input type="text" name="created_at" value="{$item/@created_at}" class="datefield" readonly="true"/>
			</p>

			<xsl:if test="$item/createdby != ''">
				<p class="user-info">
					<span class="tooltip" title="{$language/collection/created_by}">
						<i class="fa fa-user-plus"><xsl:comment /></i>
					</span>
					<!-- <span class="icon creation tooltip" title="{$language/collection/created_by}">&#xa0;</span> -->
					<xsl:value-of select="$item/createdby" />&#xa0;<abbr class="timeago" title="{$item/@created_at}"><xsl:value-of select="$item/@created_at"/></abbr>
				</p>
			</xsl:if>
			
			<xsl:if test="$item/modifiedby != ''">
				<p class="user-info">
					<span class="tooltip" title="{$language/collection/edited_by}">
						<i class="fa fa-edit"><xsl:comment /></i>
					</span>
					<xsl:value-of select="$item/modifiedby" />&#xa0;<abbr class="timeago" title="{$item/@updated_at}"><xsl:value-of select="$item/@updated_at"/></abbr>
				</p>
			</xsl:if>

			<xsl:if test="($item/@state = 1 or $item/@state = 3) and $item/publishedby">
				<p class="user-info">
					<span class="tooltip" title="{$language/collection/published_by}">
						<i class="fa fa-cloud-upload-alt"><xsl:comment /></i>
					</span>
					<xsl:value-of select="$item/publishedby" />&#xa0;<abbr class="timeago" title="{$item/published_at}"><xsl:value-of select="$item/published_at"/></abbr>
				</p>
			</xsl:if>

		
		</div>
	</xsl:template>
	<!-- / Publicación -->

	<!-- Geolocation -->
	<xsl:template name="item.geolocation">
		<xsl:param name="latname" />
		<xsl:param name="lngname" />
		<xsl:param name="item" />

		<xsl:variable name="latvalue" select="$item/latitud" />
		<xsl:variable name="lngvalue" select="$item/longitud" />

		<xsl:if test="$config/module/options/group[@name='settings']/option[@name='geolocation']/@value = 'true'">
			<xsl:if test="$latname != '' and $lngname != ''">

				<script>
					var MapsService = {};
					requirejs(['admin/ui/js/app/controller/map'], function(GMap){ 
						MapService = new GMap();
						<xsl:if test="$latvalue != '' and $lngvalue != ''">
							MapService.SetLatLon(<xsl:value-of select="$latvalue" />, <xsl:value-of select="$lngvalue" />);
						</xsl:if>
					});
				</script>

				<div class="sidebar-box">

					
					<label><xsl:value-of select="$language/item_editor/geolocation/title" /></label>
					<ul>
						<li class="left" style="width:49.5%;margin:0 0 10px 0;">
							<label><xsl:value-of select="$language/item_editor/geolocation/longitud" /></label>
							<input type="text" name="{$lngname}" id="lng" value="{$lngvalue}" class="half right" />
						</li>
						<li class="right" style="width:49.5%;margin:0 0 10px 0;">
							<label><xsl:value-of select="$language/item_editor/geolocation/latitud" /></label>
							<input type="text" name="{$latname}" id="lat" value="{$latvalue}" class="half" />
						</li>
						<li>
							<label><xsl:value-of select="$language/item_editor/geolocation/find_in_map" /></label>
							<input id="address" type="text" value="" class="left" placeholder="{$language/item_editor/geolocation/geo_placeholder}" style="margin:0 0 0 0;width:60%;">
									<xsl:attribute name="onkeypress">if(event.keyCode == 13) {MapService.codeAddress();return false;}</xsl:attribute>
							</input>
							<button onclick="MapService.codeAddress();return false;" class="btn left"><xsl:value-of select="$language/item_editor/geolocation/btn_find" /></button>
						</li>
						<li>
							<div id="map-canvas" style="width:100%;height:400px;margin:10px 0 40px;">&#xa0;</div>
						</li>
					</ul>
				</div>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- / Geolocation -->

	<!-- Multimedias -->
	<xsl:template name="relations.multimedia">
		<xsl:param name="item" />
		<xsl:param name="item_id" />
		<xsl:variable name="configuration" select="$config/module/options/group[@name='multimedias']" />
		<xsl:variable name="multimedias" select="$item/multimedias" />
		
		<script>
			var MultimediaService = {};
			requirejs(['multimedia/ui/js/service'], function(multimedia){ 
				MultimediaService = multimedia;
				MultimediaService.BindActions();
			});
		</script>

		<xsl:apply-templates select="$configuration/option" mode="item-multimedia">
			<xsl:sort order="ascending" select="relation_order" />
			<xsl:with-param name="multimedias" select="$multimedias" />
			<xsl:with-param name="item_id" select="$item_id" />
		</xsl:apply-templates>
	</xsl:template>

	<!-- IMAGES -->
	<xsl:template match="option[@name='image']" mode="item-multimedia">
		<xsl:param name="multimedias" />
		<xsl:param name="item_id" />

		<xsl:variable name="node" select="@name" />
		<xsl:variable name="option_category" select="@category_id" />
		<xsl:variable name="option_parent" select="@category_parentid" />

		<div class="item-relation" name="{@name}" data-count="{count($multimedias/images/image)}">
			<label class="title">
				<span>
					<xsl:call-template name="lang-eval">
						<xsl:with-param name="pPath" select="@label" />
					</xsl:call-template>
				</span>
				<a 
					 data-role="multimedia-add"
					 item_id="{$item_id}"
					 multimedia_name="{@name}" 
					 category_id="{@category_id}" 
					 class="btn" 
					 href="{$adminroot}image/modal/?item_id={$item_id}&amp;callback=BackSetImage&amp;module={$config/module/@name}&amp;categories={$option_category}" 
				><xsl:value-of select="$language/item_editor/btn_add"/></a>
			</label>
			<ul class="multimedia {$node} with-order" data-role="multimedia" data-type="{@type_id}" module="{@name}">
				<xsl:for-each select="$multimedias/images/image">
					<xsl:sort order="ascending" select="relation_order" />
					<li item_id="{@image_id}" rel_id="{rel_id}">
						<div class="wrapper">
							<span class="frame">
								<xsl:call-template name="image.bucket">
									<xsl:with-param name="id" select="@image_id" />
									<xsl:with-param name="type" select="@type" />
									<xsl:with-param name="width">200</xsl:with-param>
									<xsl:with-param name="height">200</xsl:with-param>
								</xsl:call-template>
							</span>
							<h3>
								<a href="{$adminroot}image/edit/{@image_id}/" title="{title}">
									<xsl:value-of select="title"/>
									<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
								</a>
							</h3>
							<p>
								<xsl:choose>
									<xsl:when test="summary = ''"><xsl:value-of select="$language/item_editor/multimedias/image/missing_epigraph" /></xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="limit.string">
											<xsl:with-param name="string" select="summary" />
											<xsl:with-param name="limit">80</xsl:with-param>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</p>
							<span class="info size">
								<xsl:value-of select="@width" /> x <xsl:value-of select="@height" /> » 
								<xsl:value-of select="@type" />
							</span>
							<span class="info actions">
								<a 
									data-role="image-crop" 
									href="{$adminroot}image/crop/{@image_id}/?modal=1&amp;item_id={$item_id}&amp;categories={$option_category}&amp;module={$modName}&amp;width=890&amp;height=window" 
									class="tooltip" 
									title="{$language/item_editor/multimedias/crop_image}">
									<i class="fa fa-cut"><xsl:comment /></i>
									<!-- <xsl:value-of select="$language/item_editor/multimedias/crop_image"/> -->
								</a>
								<a 
									data-role="multimedia-remove" 
									data-item_id="{$item_id}"
									data-type_id="{@type_id}"
									data-image_id="{@image_id}"
									class="tooltip" 
									href="#" 
									title="{$language/item_editor/unlink}">
									<i class="fa fa-eraser"><xsl:comment /></i>
								</a>
							</span>
						</div>
					</li>
				</xsl:for-each>
				<xsl:comment />
			</ul>			
			<div class="alert grey"><xsl:value-of select="$language/item_editor/alert_no_relation"/>&#xa0;<!-- 
				 --><xsl:call-template name="lang-eval">
					<xsl:with-param name="pPath" select="@label" />
				</xsl:call-template>
			</div>
		</div>
	</xsl:template>
	<!-- /IMAGES -->

	<xsl:template match="option[@name='audio']" mode="item-multimedia">
		<xsl:param name="multimedias" />
		<xsl:param name="item_id" />

		<xsl:variable name="node" select="@name" />
		<xsl:variable name="option_category" select="@category_id" />
		<xsl:variable name="option_parent" select="@category_parentid" />

		<div class="item-relation" name="{@name}" data-count="{count($multimedias/audios/audio)}">
			<label class="title">
				<span>
					<xsl:call-template name="lang-eval">
						<xsl:with-param name="pPath" select="@label" />
					</xsl:call-template>
				</span>
				<a   
					 data-role="multimedia-add"
					 item_id="{$item_id}"
					 multimedia_name="{@name}" 
					 category_id="{@category_id}" 
					 class="btn" 
					 href="{$adminroot}audio/modal/?item_id={$item_id}&amp;callback=BackSetAudio&amp;module={$config/module/@name}&amp;categories={$option_category}" 
				><xsl:value-of select="$language/item_editor/btn_add"/></a>
			</label>
			<ul class="multimedia {$node} with-order" data-role="multimedia" data-type="{@type_id}" module="{@name}">
				<xsl:for-each select="$multimedias/audios/audio">
					<xsl:sort order="ascending" select="relation_order" />
					<li item_id="{@audio_id}" rel_id="{rel_id}">
						<div class="wrapper">
							<span class="frame">
								<img src="/modlayer/modules/audio/ui/imgs/audio.png" />
							</span>
							<h3>
								<a href="{$adminroot}audio/edit/{@audio_id}/" title="{title}">
									<xsl:value-of select="title"/>
									<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
								</a>
							</h3>
							<xsl:choose>
								<xsl:when test="summary = ''"><xsl:value-of select="$language/item_editor/multimedias/image/missing_epigraph" /></xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="limit.string">
										<xsl:with-param name="string" select="summary" />
										<xsl:with-param name="limit">150</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							<span class="data">
								<xsl:if test="@playtime != ''">
									<xsl:value-of select="$language/item_editor/multimedias/audio/playtime" /><xsl:value-of select="@playtime" /><br/> 
								</xsl:if>
								<xsl:value-of select="$language/item_editor/multimedias/audio/type" /><xsl:value-of select="@type" /><br />
								<xsl:value-of select="$language/item_editor/multimedias/audio/weight" />
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
							<span class="info actions">
								<a 
									data-role="multimedia-remove" 
									data-item_id="{$item_id}"
									data-type_id="{@type_id}"
									data-image_id="{@audio_id}"
									class="tooltip" href="#" onclick="return false;" title="{$language/item_editor/unlink}">
									<i class="fa fa-eraser"><xsl:comment /></i>
								</a>
							</span>
						</div>
					</li>
				</xsl:for-each>
				<xsl:comment />
			</ul>
			<div class="alert grey"><xsl:value-of select="$language/item_editor/alert_no_relation"/>&#xa0;<!-- 
				 --><xsl:call-template name="lang-eval">
					<xsl:with-param name="pPath" select="@label" />
				</xsl:call-template>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="option[@name='document']" mode="item-multimedia">
		<xsl:param name="multimedias" />
		<xsl:param name="item_id" />

		<xsl:variable name="node" select="@name" />
		<xsl:variable name="option_category" select="@category_id" />
		<xsl:variable name="option_parent" select="@category_parentid" />

		<div class="item-relation" name="{@name}" data-count="{count($multimedias/documents/document)}">
			<label class="title">
				<span>
					<xsl:call-template name="lang-eval">
						<xsl:with-param name="pPath" select="@label" />
					</xsl:call-template>
				</span>
				<a 
					 data-role="multimedia-add"
					 item_id="{$item_id}"
					 multimedia_name="{@name}" 
					 category_id="{@category_id}" 
					 class="btn" 
					 href="{$adminroot}document/modal/?item_id={$item_id}&amp;callback=BackSetDocument&amp;module={$config/module/@name}&amp;categories={$option_category}" 
				><xsl:value-of select="$language/item_editor/btn_add"/></a>
			</label>
			<ul class="multimedia {$node} with-order" data-role="multimedia" data-type="{@type_id}" module="{@name}">
				<xsl:for-each select="$multimedias/documents/document">
					<xsl:sort order="ascending" select="relation_order" />
					<li item_id="{@document_id}">
						<div class="wrapper">
							<span class="frame">
								<img src="/modlayer/modules/document/ui/imgs/{@type}.png" />
							</span>
							<h3>
								<a href="{$adminroot}document/edit/{@document_id}/" title="{title}">
									<xsl:value-of select="title"/>
									<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
								</a>
							</h3>
							<xsl:choose>
								<xsl:when test="summary = ''"><xsl:value-of select="$language/item_editor/multimedias/document/no_summary"/></xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="limit.string">
										<xsl:with-param name="string" select="summary" />
										<xsl:with-param name="limit">150</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							<span class="data">
								<xsl:value-of select="$language/item_editor/multimedias/document/type"/><xsl:value-of select="@type" /><br />
								<xsl:value-of select="$language/item_editor/multimedias/document/weight"/>
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
							<span class="info actions">
								<a 
									href="{$adminroot}document/download/{@document_id}" class="tooltip" title="{$language/item_editor/multimedias/document/download}">
									<i class="fa fa-download"><xsl:comment /></i>
								</a>
								<a 
									data-role="multimedia-remove" 
									data-item_id="{$item_id}"
									data-type_id="{@type_id}"
									data-image_id="{@document_id}"
									class="tooltip" href="#" onclick="return false;" title="{$language/item_editor/unlink}">
									<i class="fa fa-eraser"><xsl:comment /></i>
								</a>
							</span>
						</div>
					</li>
				</xsl:for-each>
				<xsl:comment />
			</ul>
			<div class="alert grey">
				<xsl:value-of select="$language/item_editor/alert_no_relation"/>&#xa0;<!-- 
				 --><xsl:call-template name="lang-eval">
					<xsl:with-param name="pPath" select="@label" />
				</xsl:call-template>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="option[@name='video']" mode="item-multimedia">
		<xsl:param name="multimedias" />
		<xsl:param name="item_id" />

		<xsl:variable name="node" select="@name" />
		<xsl:variable name="option_category" select="@category_id" />
		<xsl:variable name="option_parent" select="@category_parentid" />

		<div class="item-relation" name="{@name}" data-count="{count($multimedias/videos/video)}">
			<label class="title">
				<span>
					<xsl:call-template name="lang-eval">
						<xsl:with-param name="pPath" select="@label" />
					</xsl:call-template>
				</span>
				<a 
					 data-role="multimedia-add"
					 item_id="{$item_id}"
					 multimedia_name="{@name}" 
					 category_id="{@category_id}" 
					 class="btn" 
					 href="{$adminroot}video/modal/?item_id={$item_id}&amp;callback=BackSetvideo&amp;module={$config/module/@name}&amp;categories={$option_category}" 
				><xsl:value-of select="$language/item_editor/btn_add"/></a>
			</label>
			<ul class="multimedia {$node} with-order" data-role="multimedia" data-type="{@type_id}" >
				<xsl:for-each select="$multimedias/videos/video">
					<xsl:sort order="ascending" select="relation_order" />
					<li item_id="{@video_id}">
						<div class="wrapper">
							<span class="frame">
								<img src="/modlayer/modules/video/ui/imgs/{@type}.png" />
							</span>
							<h3>
								<a href="{$adminroot}video/edit/{@video_id}/" title="{title}">
									<xsl:value-of select="title"/>
									<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
								</a>
							</h3>
							<xsl:choose>
								<xsl:when test="summary = ''"><xsl:value-of select="$language/item_editor/multimedias/image/missing_epigraph" /></xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="limit.string">
										<xsl:with-param name="string" select="summary" />
										<xsl:with-param name="limit">150</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							<span class="info size">
								<xsl:value-of select="@width" /> x <xsl:value-of select="@height" /> » 
								<xsl:value-of select="@type" />
							</span>
							<span class="info actions">
								<a 
									title="{$language/collection/btn_preview}"
									class="tooltip"
									onclick="window.appUI.OpenPanel(this.href);return false;"
									href="/admin/?m=video&amp;action=DisplayPreview&amp;video_id={@video_id}">
									<i class="fa fa-play-circle"><xsl:comment /></i>
									<!-- <xsl:value-of select="$language/collection/btn_preview"/> -->
								</a>
								<a 
									data-role="multimedia-remove" 
									data-item_id="{$item_id}"
									data-type_id="{@type_id}"
									data-image_id="{@video_id}"
									class="tooltip" 
									href="#" 
									onclick="return false;" title="{$language/item_editor/unlink}"> 
									<i class="fa fa-eraser"><xsl:comment /></i>
								</a>
							</span>
						</div>
					</li>
				</xsl:for-each>
				<xsl:comment />
			</ul>
			<div class="alert grey">
				<xsl:value-of select="$language/item_editor/alert_no_relation"/>&#xa0;<!-- 
				 --><xsl:call-template name="lang-eval">
					<xsl:with-param name="pPath" select="@label" />
				</xsl:call-template>
			</div>
		</div>
	</xsl:template>
	<!-- / Multimedias -->

	<!-- Parent -->
	<xsl:template name="element.parent">
		<xsl:param name="item" />

		<xsl:if test="$config/module/options/group[@name='element_parent']/option">
		
			<xsl:variable name="options" select="$config/module/options/group[@name='element_parent']" />
			<xsl:variable name="parent" select="$item/parent" />
			<script>
				var ParentService = {};
				requirejs(['element/ui/js/parent'], function(Parent){ 
					ParentService = Parent;
					ParentService.BindItemActions();
				});
			</script>

			<xsl:for-each select="$options/option">
				<xsl:variable name="node" select="@name" />
				<div class="item-parent" data-count="{count($item/parent)}" data-role="element_parent" data-type="{$node}">
					<xsl:if test="count($item/parent) &gt; 0 and $item/parent/module != $node">
						<xsl:attribute name="class">item-parent hidden</xsl:attribute>
						<xsl:attribute name="data-count">0</xsl:attribute>
					</xsl:if>
						<h3>
							<xsl:call-template name="lang-eval">
								<xsl:with-param name="pPath" select="@label" />
							</xsl:call-template>
						</h3>
						<xsl:if test="$parent/module = $node">
						<div parent_id="{$parent/@id}" class="item state-{$parent/@state} floatFix">
							<button 
								type="button"
								data-role="parent-remove"
								data-id="{$item/@id}"
								data-module="{$parent/module}"
								class="tooltip fa-icon right" 
								item_id="{$parent/@id}" type_id="{$node}" title="{$language/item_editor/unlink}" 
								style="padding:10px;border-radius:5px;border:0;">
								<i class="fa fa-eraser"><xsl:comment /></i>
								<!-- <xsl:value-of select="$language/item_editor/unlink" /> -->
							</button>
							<xsl:choose>
								<xsl:when test="$parent/multimedias/images/image">
									<a href="{$adminroot}{$node}/edit/{$parent/@id}">
										<xsl:call-template name="image.bucket">
											<xsl:with-param name="id" select="$parent/multimedias/images/image/@image_id" />
											<xsl:with-param name="type" select="$parent/multimedias/images/image/@type" />
											<xsl:with-param name="width">80</xsl:with-param>
											<xsl:with-param name="height">80</xsl:with-param>
											<xsl:with-param name="crop">c</xsl:with-param>
											<xsl:with-param name="class">rounded</xsl:with-param>
											<xsl:with-param name="style">float:left;margin:0 10px 0 0;</xsl:with-param>
										</xsl:call-template>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<span class="pic">&#xa0;</span>
								</xsl:otherwise>
							</xsl:choose>
							<!-- <span class="status state-{$parent/@state} rounded">&#xa0;</span> -->
							<a href="{$adminroot}{$node}/edit/{$parent/@id}">
								<xsl:value-of select="$parent/title"/>
							</a>
						</div>
					</xsl:if>
					<xsl:comment />
					<div class="alert grey">
						No hay ninguna relación.
						<a 
						 class="btn lightblue" 
						 href="{$adminroot}?m={$config/module/@name}&amp;action=RenderItemParent&amp;item_id={$item/@id}&amp;moduleParent={@name}" 
						 onclick="window.appUI.OpenPanel(this.href);return false;"
						 type_id="{@type_id}" 
						 module="{@name}">
						 	<xsl:value-of select="$language/item_editor/btn_add"/>
						 </a>
					</div>
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<!-- / Parent -->

	<!-- Relations -->
	<xsl:template name="relations.modules">
		<xsl:param name="item" />
		<xsl:param name="item_id" />
		<!-- <xsl:variable name="item_id" select="$item/@id" /> -->

		<xsl:variable name="objects" select="$config/module/options/group[@name='relations']" />
		<xsl:variable name="relations" select="$item/relations" />
		
		<xsl:if test="count($objects/option) &gt; 0">
			<script>
				var RelationService = {};
				requirejs(['admin/ui/js/app/controller/relations'], function(Relation){ 
					RelationService = Relation;
					RelationService.BindActions();
				});
			</script>
		</xsl:if>

		<xsl:for-each select="$objects/option">
			<xsl:variable name="node" select="@name" />
			<div class="item-relation" name="{@name}" data-count="{count($relations/*/*[name()=$node])}">

				<label class="title">
					<span>
						<xsl:call-template name="lang-eval">
							<xsl:with-param name="pPath" select="@label" />
						</xsl:call-template>
					</span>
					<a 
						data-role="relation-add" 
						class="btn relation-add" 
						href="{$adminroot}?m={@name}&amp;action=RenderItemRelations&amp;item_id={$item_id}&amp;module={$config/module/@name}" 
						type_id="{@type_id}" 
						module="{@name}"
						><xsl:value-of select="$language/item_editor/btn_add"/></a>
				</label>

				<ul id="relation-{@name}" class="relation with-order" data-role="relation" data-type="{@name}" module="{@name}">
					<xsl:for-each select="$relations/*/*[name()=$node]">
						<xsl:sort order="ascending" select="relation_order" data-type="number"/>
						<li id="rel-{@id}" item_id="{@id}" class="state-{@state}" rel_id="{rel_id}">
							<div class="wrapper">
								<xsl:choose>
									<xsl:when test="multimedias/images/image">
										<span class="frame">
											<a href="{$adminroot}{$node}/edit/{@id}">
												<xsl:call-template name="image.bucket">
													<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
													<xsl:with-param name="type" select="multimedias/images/image/@type" />
													<xsl:with-param name="width">320</xsl:with-param>
													<xsl:with-param name="height">180</xsl:with-param>
													<xsl:with-param name="crop">c</xsl:with-param>
												</xsl:call-template>
											</a>
										</span>		
									</xsl:when>
									<xsl:otherwise>
										<span class="frame">
											<span class="no-pic"><xsl:comment /></span>
										</span>
									</xsl:otherwise>
								</xsl:choose>

								<h3>
									<a href="{$adminroot}{$node}/edit/{@id}">
										<xsl:value-of select="title | name"/>
										<xsl:if test="title = '' or name = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
									</a>
								</h3>
								<xsl:if test="summary != ''">
									<p>
										<xsl:call-template name="limit.string">
											<xsl:with-param name="string" select="summary" />
											<xsl:with-param name="limit">120</xsl:with-param>
										</xsl:call-template>
									</p>
								</xsl:if>
								<xsl:if test="$node = 'clip'">
									<span class="info fa-icon size">
										<a 
											href="{$adminroot}?m=clip&amp;action=RenderPreview&amp;id={@id}"
											class="tooltip"
											style="margin:0 0 -5px 0;"
											title="{$language/collection/btn_preview}"
											onclick="window.appUI.OpenPanel(this.href);return false;">
											<i class="fa fa-play-circle"><xsl:comment /></i>
											<!-- <xsl:value-of select="$language/collection/btn_preview"/> -->
										</a>
									</span>	
								</xsl:if>

								<span class="info actions">
									<a 
										class="tooltip"
										href="#"
										onclick="RelationService.unlink({$item_id}, {@id}, '{$node}');return false;"
										title="{$language/item_editor/unlink}">
										<i class="fa fa-eraser"><xsl:comment /></i>
									</a>
								</span>
							</div>
						</li>
					</xsl:for-each>
					
					<!-- Este tag hace falta para que si no hay nodos no se cierre inline y rompa el html5 -->
					<xsl:comment />
				</ul>
				<div class="alert grey">
					<xsl:value-of select="$language/item_editor/alert_no_relation"/>&#xa0;<!-- 
				 --><xsl:call-template name="lang-eval">
					<xsl:with-param name="pPath" select="@label" />
				</xsl:call-template>
				</div>
			</div>
		</xsl:for-each>
	</xsl:template>
	<!-- Relations -->

	<!-- Categories -->
	<xsl:template name="item.categories">
		<xsl:param name="item" />

		<xsl:variable name="categories" select="$item/categories" />
		<!-- <xsl:variable name="item_id" select="$item/@id|$item/@image_id" /> -->
		<xsl:variable name="item_id">
			<xsl:choose>
				<xsl:when test="$item/@id"><xsl:value-of select="$item/@id"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$item/@*[contains(name(), '_id')]"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$config/module/options/group[@name='categories']/option">
			<xsl:for-each select="$config/module/options/group[@name='categories']/option[@type='parent']">
				<div class="sidebar-box" data-type="category" parent="{@value}">
					<xsl:variable name="parent_id" select="@value" />
					<!-- <a href="javascript:void(0);" onclick="return false;" class="btn right category-order" data-parent="{$parent_id}" >Ordenar</a> -->
					<label>
						<!-- <xsl:value-of select="@label"/> -->
						<xsl:call-template name="lang-eval">
							<xsl:with-param name="pPath" select="@label" />
						</xsl:call-template>
					</label>
					<ul class="cat-list with-order" module="category" data-role="categories">
						<xsl:for-each select="$categories/group[@parent_id=$parent_id]/category">
							<xsl:sort order="ascending" select="order" data-type="number"/>
							<li category_id="{@category_id}" item_id="{@category_id}" rel_id="{rel_id}">
								<span>
									<a href="#" category_id="{@category_id}" item_id="{$item_id}" class="right icon remove" title="{$language/collection/delete_category}" onclick="return false;"><xsl:value-of select="$language/collection/delete_category"/></a>
									<xsl:value-of select="name"/>
								</span>
							</li>
						</xsl:for-each>
						<xsl:comment />
					</ul>
					<input value="" placeholder="{$language/item_editor/btn_add} {$language/filters/title_categories}" class="autocomplete AutocompleteCategory cat_{$parent_id}" parent_id="{$parent_id}"/>
					<xsl:comment />
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<!-- / Categories -->

	<!-- Roles -->
	<xsl:template name="roles">
		<xsl:param name="object" />
		<xsl:param name="item_id" />
		<xsl:if test="$config/module/options/group[@name='roles']/option">

			<script>
				var RolesService = {};
				requirejs(['role/ui/js/service'], function(Roles){ 
					RolesService = Roles;
					RolesService.BindActions();
				});
			</script>

			<xsl:for-each select="$config/module/options/group[@name='roles']/option">
				<xsl:variable name="thisModule" select="@module" />

				<!-- Usamos IF y no CHOOSE porque pueden estar los dos activos  -->
				<xsl:if test="@featuring = 1">
					<div class="item-relation" data-count="{count($object/featuring/group[@name=$thisModule]/role)}" name="{$thisModule}">
						<label class="title">
							<span>
								<xsl:call-template name="lang-eval">
									<xsl:with-param name="pPath" select="@label" />
								</xsl:call-template>
								<!-- <xsl:value-of select="@label"/> -->
							</span>
							<a class="btn" data-role="role-add" href="javascript:void(0);" data-id="{$item_id}" data-foreign="{@module}" onclick="return false;"><xsl:value-of select="$language/item_editor/btn_add"/></a>
							<!-- roles.showmodal({$item_id}, '{@module}'); -->
						</label>
						<ul class="role with-order" data-role="roles" foreign_module="{$thisModule}" module="role">
							<xsl:for-each select="$object/featuring/group[@name=$thisModule]/role">
								<xsl:sort select="order" order="ascending" data-type="number" />
								<li data-type="role" rel_id="{@rel_id}" item_id="{@rel_id}">
									<xsl:choose>
										<xsl:when test="data/multimedias/images/image/@image_id">
											<xsl:call-template name="image.bucket">
												<xsl:with-param name="id" select="data/multimedias/images/image/@image_id" />
												<xsl:with-param name="type" select="data/multimedias/images/image/@type" />
												<xsl:with-param name="width">70</xsl:with-param>
												<xsl:with-param name="height">70</xsl:with-param>
												<xsl:with-param name="crop">c</xsl:with-param>
												<xsl:with-param name="class">pic</xsl:with-param>
											</xsl:call-template>		
										</xsl:when>
										<xsl:otherwise>
											<span class="pic">&#xa0;</span>
										</xsl:otherwise>
									</xsl:choose>

									<!-- <a class="right icon delete tooltip" data-role="role-remove" data-rel_id="{@rel_id}" onclick="return false;" title="{$language/item_editor/roles/delete_role}" href="javascript:void(0);"><xsl:value-of select="$language/item_editor/roles/btn_delete_role" /></a> -->
									<a 
										class="right fa-icon tooltip" 
										data-role="role-remove"
										data-rel_id="{@rel_id}" 
										onclick="return false;"
										title="{$language/item_editor/roles/delete_role}" 
										href="javascript:void(0);">
										<i class="fa fa-eraser"><xsl:comment /></i>
										<!-- <xsl:value-of select="$language/item_editor/btn_delete"/> -->
									</a>
									<h3 class="regular" title="{data/title|data/first_name} {data/last_name}">
										<a href="{$adminroot}{$thisModule}/edit/{foreign_id}">
											<xsl:value-of select="data/title|data/first_name"/>&#xa0;<xsl:value-of select="data/last_name" />
										</a>
									</h3>
									<span class="roleTag" title="{role}"><xsl:value-of select="role" /></span>
									
									<span><xsl:value-of select="description"/></span>
								</li>
							</xsl:for-each>
						</ul>
						<div class="alert grey"><xsl:value-of select="$language/item_editor/alert_no_relation"/>&#xa0;<xsl:call-template name="lang-eval">
								<xsl:with-param name="pPath" select="@label" />
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="@featured_in = 1">
					<div class="item-relation" data-count="{count($object/featured_in/group[@name=$thisModule]/role)}" name="{$thisModule}">
						<label class="title">
							<span>
								<xsl:call-template name="lang-eval">
									<xsl:with-param name="pPath" select="@label" />
								</xsl:call-template>
							</span>
						</label>
						<ul class="role with-order" data-role="roles" foreign_module="{$thisModule}" module="role">
							<xsl:for-each select="$object/featured_in/group/role">
								<li data-type="role" rel_id="{@rel_id}" item_id="{@rel_id}">
									<xsl:choose>
										<xsl:when test="data/multimedias/images/image">
											<xsl:call-template name="image.bucket">
												<xsl:with-param name="id" select="data/multimedias/images/image/@image_id" />
												<xsl:with-param name="type" select="data/multimedias/images/image/@type" />
												<xsl:with-param name="width">70</xsl:with-param>
												<xsl:with-param name="height">70</xsl:with-param>
												<xsl:with-param name="crop">c</xsl:with-param>
												<xsl:with-param name="class">pic</xsl:with-param>
											</xsl:call-template>		
										</xsl:when>
										<xsl:otherwise>
											<span class="pic">&#xa0;</span>
										</xsl:otherwise>
									</xsl:choose>
									<a class="right icon delete tooltip" onclick="roles.UnSetRole({@rel_id});" title="{$language/item_editor/roles/delete_role}" href="javascript:void(0);"><xsl:value-of select="$language/item_editor/roles/btn_delete_role" /></a>
									<!-- <a class="right icon remove tooltip" rel="tooltip" onclick="roles.UnSetRole({@id});" title="{$language/item_editor/roles/delete_role}" href="javascript:void(0);"><xsl:value-of select="$language/item_editor/roles/btn_delete_role"/></a> -->
									<span class="roleTag" title="{role}">
										<xsl:value-of select="role" />
									</span>
									<p style="margin:0;">
										<a href="{$adminroot}{item_module}/edit/{item_id}">
											<xsl:value-of select="data/name|data/title" />
										</a>
										<span style="display:block;color:#888;font-size:11px;"><xsl:value-of select="item_module" /></span>
									</p>
								</li>
							</xsl:for-each>
						</ul>
						<div class="alert grey">
							<xsl:value-of select="$language/item_editor/alert_no_relation"/>&#xa0;<!-- 
							 --><xsl:call-template name="lang-eval">
								<xsl:with-param name="pPath" select="@label" />
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				
			</xsl:for-each>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>