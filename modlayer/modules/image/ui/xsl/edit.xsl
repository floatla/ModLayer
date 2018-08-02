<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:param name="width" />
<xsl:param name="height" />

<xsl:variable name="image" select="/xml/content/image" /> 

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/css/image.css
		</xsl:with-param>
	</xsl:call-template>
	<!-- <xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$adminPath"/>/ui/js/module.edit.js
		</xsl:with-param>
	</xsl:call-template> -->
	<script>
		var jsItem = {};
		requirejs(['admin/ui/js/app/controller/item'], function(Item){ 
			jsItem = new Item(<xsl:value-of select="$image/@image_id" />);
			jsItem._state  = 0;
			jsItem._module = "<xsl:value-of select="$modName" />";
			jsItem.BindActions();
		});
	</script>
	<xsl:call-template name="tiny_mce.src" />
	<xsl:call-template name="tiny_mce.simple">
		<xsl:with-param name="elements">#image_summary</xsl:with-param>
	</xsl:call-template>
	
</xsl:variable>

<xsl:template name="content">
	<div class="item-edit">
		<form name="edit" action="{$adminroot}{$config/module/@name}/edit/" method="post">
			<input type="hidden" name="modToken" value="{$modToken}" />
			<input type="hidden" name="image_id" value="{$image/@image_id}" />
			<input type="hidden" name="item_id" value="{$image/@image_id}" disabled="disabled" />
			<input type="hidden" name="back" id="SaveAndBack" value="0" />
			<xsl:if test="$image/@preview = 1">
				<input type="hidden" name="image_preview" value="1" />
			</xsl:if>
		
			<section class="edit-header floatFix">
				<span class="right"> 
					<a href="javascript:history.back();" class="btn"><xsl:value-of select="$language/item_editor/btn_cancel"/></a>&#xa0; 
					<button type="button" onclick="jsItem._back=1;$('#SaveAndBack').val('1');$('form[name=edit]').submit();" class="btn save-back"><span><xsl:value-of select="$language/item_editor/btn_back"/></span></button>
					<!-- <button type="submit" name="back" value="1" onclick="item.back=1;"  class="btn"><span><xsl:value-of select="$language/item_editor/btn_back"/></span></button>&#xa0;  -->
					<button type="submit" class="btn lightblue"><span><xsl:value-of select="$language/item_editor/btn_save"/></span></button>&#xa0; 
				 </span>
				<h2><xsl:value-of select="$language/item_editor/page_title"/></h2>
				<div class="alert"><!-- Para mensajes --></div>
			</section>

			<div class="floatFix">
				<section class="item-sidebar" id="tools">
					<div class="sidebar-box">
						<label><xsl:value-of select="$language/item_editor/labels/image_label"/></label>
						<p class="image-preview">
							<xsl:call-template name="image.bucket">
								<xsl:with-param name="id" select="$image/@image_id" />
								<xsl:with-param name="type" select="$image/@type" />
								<xsl:with-param name="width">350</xsl:with-param>
								<xsl:with-param name="height">500</xsl:with-param>
								<xsl:with-param name="class">rounded</xsl:with-param>
							</xsl:call-template>
							<br/>
						</p>
						<span class="item-lista">
							<xsl:variable name="original">
								<xsl:call-template name="image.original.src">
									<xsl:with-param name="id" select="$image/@image_id" />
									<xsl:with-param name="type" select="$image/@type" />
								</xsl:call-template>
							</xsl:variable>
							<a target="blank" class="btn lightblue" href="{$original}"><xsl:value-of select="$language/item_editor/view_original"/></a>
						</span>
					</div>

					<div class="sidebar-box">
						<label><xsl:value-of select="$language/item_editor/labels/title_info"/></label>
						<div class="info">
							<ul>
								<li>
									<span>
										<xsl:call-template name="lang-eval">
											<xsl:with-param name="pPath" select="$language/item_editor/labels/info_upload" />
										</xsl:call-template>
									</span>
									<xsl:value-of select="$image/createdby" /> <br/>
									<xsl:call-template name="date.time">
										<xsl:with-param name="fecha" select="$image/@created_at" />
									</xsl:call-template>
								</li>
								<xsl:if test="$image/modifiedby">
									<li>
										<span>
											<xsl:call-template name="lang-eval">
												<xsl:with-param name="pPath" select="$language/item_editor/labels/info_modified" />
											</xsl:call-template>
										</span>
										<xsl:value-of select="$image/modifiedby" /> <br/>
										<xsl:call-template name="date.time">
											<xsl:with-param name="fecha" select="$image/@updated_at" />
										</xsl:call-template>
									</li>
								</xsl:if>
								<li>
									<span>
										<xsl:call-template name="lang-eval">
											<xsl:with-param name="pPath" select="$language/item_editor/labels/info_width" />
										</xsl:call-template>
									</span>
									<input type="text" name="image_width" value="{$image/@width}" readonly="true"/>
								</li>
								<li>
									<span>
										<xsl:call-template name="lang-eval">
											<xsl:with-param name="pPath" select="$language/item_editor/labels/info_height" />
										</xsl:call-template>
									</span>
									<input type="text" name="image_height" value="{$image/@height}" readonly="true"/>
								</li>
								<li>
									<span>
										<xsl:call-template name="lang-eval">
											<xsl:with-param name="pPath" select="$language/item_editor/labels/info_weight" />
										</xsl:call-template>
									</span>
									<xsl:choose>
										<xsl:when test="$image/@weight='' or not($image/@weight)">
											--
										</xsl:when>
										<xsl:when test="$image/@weight &gt; 1000000">
											<xsl:value-of select='format-number($image/@weight div 1000000, "#.##")' /> Mb
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select='format-number($image/@weight div 1000, "#.##")' /> Kb
										</xsl:otherwise>
									</xsl:choose>
								</li>
							</ul>
						</div>
					</div>

					<xsl:if test="$config/module/options/group[@name='categories']">
						<xsl:call-template name="item.categories">
							<xsl:with-param name="item" select="$image" />
						</xsl:call-template>
					</xsl:if>

					<div class="sidebar-box">
						<label><xsl:value-of select="$language/item_editor/label_delete"/></label>
						<p style="text-align:center;">
							<a class="btn red" href="#" onclick="item.delete({$image/@id});return false;">
								<xsl:value-of select="$language/item_editor/btn_delete"/>
							</a>
						</p>
					</div>
				</section>

				<section class="item-body">
					<ul class="form">
						<li>
							<label><xsl:value-of select="$language/item_editor/labels/image_title"/></label>
							<input type="text" name="image_title" value="{$image/title}" />
						</li>
						<li>
							<label><xsl:value-of select="$language/item_editor/labels/image_epigraph"/></label>
							<textarea name="image_summary" id="image_summary" class="mceSimple"><xsl:value-of select="$image/summary" />&#xa0;</textarea>
						</li>
						<li>
							<label><xsl:value-of select="$language/item_editor/labels/image_credits"/></label>
							<input type="text" name="image_credit" value="{$image/credit}" />
						</li>
						<!-- <li>
							<label><xsl:value-of select="$language/item_editor/labels/keywords"/></label>
							<input type="text" name="keywords" value="{$image/keywords}" />
						</li> -->
						<li data-role="tags">
							<label><xsl:value-of select="$language/item_editor/labels/image_tags"/></label>
							<xsl:for-each select="$image/tags/tag">
								<span class="m_tag" tag_id="{@tag_id}">
									<span><xsl:value-of select="tag_name"/></span>
									<a href="#" tag_id="{@tag_id}" onclick="return false;" class="remove">&#xa0;</a>
								</span>
							</xsl:for-each>
							<input type="text" name="" value="" class="AutocompleteTag" placeholder="{$language/item_editor/labels/tags_placeholder}"/>
						</li>
						

					</ul>

					<div class="item-relation">
						<label class="title"><xsl:value-of select="$language/item_editor/labels/label_edit"/></label>
						<div style="padding:10px 0;text-align:center;font-size:16px;">
							<a href="/admin/image/crop/{$image/@image_id}/?width=800&amp;height=window" onclick="window.appUI.OpenPanel(this.href);return false;" class="btn">
								<i class="fas fa-cut"><xsl:comment /></i>&#xa0;
								<xsl:value-of select="$language/item_editor/edit_image/crop"/>
							</a>
							<a href="/admin/image/rotate/{$image/@image_id}/?width=800&amp;height=window" onclick="window.appUI.OpenPanel(this.href);return false;" class="btn">
								<i class="fas fa-redo"><xsl:comment /></i>&#xa0;
								<xsl:value-of select="$language/item_editor/edit_image/rotate"/>
							</a>
							<!-- <a href="/admin/image/watermark/{$image/@image_id}/?width=800&amp;height=window" onclick="window.appUI.OpenPanel(this.href);return false;" class="btn">
								<span class="icon fingerprint" style="vertical-align:-6px;margin:0 5px 0 0;">&#xa0;</span>&#xa0;<xsl:value-of select="$language/item_editor/edit_image/watermark"/>
							</a> -->
						</div>
					</div>
				</section>
			</div>
		</form>
	</div>
	<xsl:if test="$content/who_is_using/item">
		<div class="item-extras">
			<h3 class="boxtitle"><xsl:value-of select="$language/item_editor/labels/who_is_using"/></h3>
			<div class="item-relation">
				<ul>
					<xsl:for-each select="$content/who_is_using/item">
						<li>
							<a href="{$adminroot}{module}/edit/{object_id}"><xsl:value-of select="data/title"/></a>
						</li>	
					</xsl:for-each>
				</ul>
			</div>
		</div>
	</xsl:if>
</xsl:template>
</xsl:stylesheet>