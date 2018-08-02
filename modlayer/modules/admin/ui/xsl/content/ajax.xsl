<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="call" />
<xsl:param name="item_id" />
<xsl:param name="module" />
<xsl:param name="object_typeid" />
<xsl:param name="category_parent" />
<xsl:param name="multimedia_typeid" />


<xsl:template match="/xml">
	<xsl:choose>
		<xsl:when test="$call='relations'">
			<xsl:call-template name="relations.list" />
		</xsl:when>
		<xsl:when test="$call='multimedias'">
			<xsl:call-template name="multimedia.list" />
		</xsl:when>
	</xsl:choose>
</xsl:template>


<xsl:template name="relations.list">
	<xsl:for-each select="content/item/object">
		<xsl:sort order="ascending" select="relation_order" data-type="number"/>
		<li id="rel-{@id}" item_id="{@id}" class="state-{@state}">
			<div class="wrapper">
				<xsl:choose>
					<xsl:when test="multimedias/images/image">
						<span class="frame">
							<a href="{$adminroot}{$module}/edit/{@id}">
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
					<a href="{$adminroot}{$module}/edit/{@id}">
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
				<xsl:if test="$module = 'clip'">
					<span class="info size">
						<a href="{$adminroot}?m=clip&amp;action=RenderPreview&amp;id={@id}" class="icon play tooltip" style="margin:0 0 -5px 0;" title="{$language/collection/btn_preview}" onclick="sidepanel.load(this);return false;"><xsl:value-of select="$language/collection/btn_preview"/></a>
					</span>	
				</xsl:if>
				<span class="info actions">
					<a class="icon delete tooltip" href="#" onclick="RelationService.unlink({$item_id}, {@id}, '{$module}');return false;" title="{$language/item_editor/unlink}"><xsl:value-of select="$language/item_editor/unlink"/></a>
				</span>
			</div>
		</li>
	</xsl:for-each>
</xsl:template>


<xsl:template name="multimedia.list">
	<xsl:choose>

		<!-- Imágenes -->
		<xsl:when test="$multimedia_typeid = 1">
			<xsl:for-each select="content/item/multimedias/images/image">
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
								href="{$adminroot}image/crop/{@image_id}/?modal=1&amp;item_id={$item_id}&amp;module={$modName}"
								class="tooltip" 
								title="{$language/item_editor/multimedias/crop_image}"
								onclick="window.appUI.OpenPanel(this.href);return false;"
								>
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
								title="{$language/item_editor/unlink}"
								onclick="MultimediaService.unlink({$item_id}, {@image_id}, {@type_id});return false;"
								>
								<i class="fa fa-eraser"><xsl:comment /></i>
							</a>
						</span>
					</div>
				</li>
			</xsl:for-each>
		</xsl:when>
		<!-- Fin Imágenes -->

		<!-- Audios -->
		<xsl:when test="$multimedia_typeid = 4">
			<xsl:for-each select="content/item/multimedias/audios/audio">
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
								<xsl:value-of select="$language/collection/playtime" />: <xsl:value-of select="@playtime" /><br/> 
							</xsl:if>
							<xsl:value-of select="$language/collection/type" />: <xsl:value-of select="@type" /><br />
							<xsl:value-of select="$language/collection/weight" />: 
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
								class="tooltip" href="#" title="{$language/item_editor/unlink}"
								onclick="MultimediaService.unlink({$item_id}, {@audio_id}, {@type_id});return false;"
								>
								<i class="fa fa-eraser"><xsl:comment /></i>
							</a>
						</span>

					</div>
				</li>
			</xsl:for-each>
		</xsl:when>
		<!-- Fin Audios -->

		<!-- Documentos -->
		<xsl:when test="$multimedia_typeid = 3">
			<xsl:for-each select="content/item/multimedias/documents/document">
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
							<xsl:when test="summary = ''"><xsl:value-of select="$language/collection/no_summary"/></xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="limit.string">
									<xsl:with-param name="string" select="summary" />
									<xsl:with-param name="limit">150</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<span class="data">
							<xsl:value-of select="$language/collection/type"/>: <xsl:value-of select="@type" /><br />
							<xsl:value-of select="$language/collection/weight"/>: 
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
								class="tooltip" href="#" title="{$language/item_editor/unlink}"
								onclick="MultimediaService.unlink({$item_id}, {@document_id}, {@type_id});return false;" 
								>
								<i class="fa fa-eraser"><xsl:comment /></i>
							</a>
						</span>
					</div>
				</li>
			</xsl:for-each>
		</xsl:when>
		<!-- Fin Documentos -->

		<!-- Videos -->
		<xsl:when test="$multimedia_typeid = 2">
			<xsl:for-each select="content/item/multimedias/videos/video">
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
								title="{$language/item_editor/unlink}"
								onclick="MultimediaService.unlink({$item_id}, {@video_id}, {@type_id});return false;"
								> 
								<i class="fa fa-eraser"><xsl:comment /></i>
							</a>
						</span>
					</div>
				</li>
			</xsl:for-each>
		</xsl:when>
		<!-- Fin Videos -->

	</xsl:choose>


</xsl:template>

</xsl:stylesheet>