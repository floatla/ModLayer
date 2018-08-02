<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:param name="module" />

<xsl:variable name="active" select="/xml/content/module" />
<xsl:variable name="htmlHeadExtra">
	<!-- <xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$adminPath"/>/ui/js/module.config.js
		</xsl:with-param>
	</xsl:call-template> -->
	<script type="text/javascript">
		var xmlConf = {};
		requirejs(['admin/ui/js/app/controller/module.config'], function(conf){ 
			conf.BindActions();

			xmlConf = conf;

			xmlConf.moduleName = "<xsl:value-of select="/xml/content/module/@name" />";
			xmlConf.types = [<!-- 
				 --><xsl:for-each select="/xml/content/modules/module[@relational = 1]"><!-- 
					 -->{"name" : "<xsl:value-of select="@name" />"}<!-- 
					 --><xsl:if test="position() != last()">, </xsl:if><!-- 
				 --></xsl:for-each><!-- 
			 -->];
			xmlConf.multimedia = [<!-- 
				--><xsl:variable name="include">image,document,video,audio</xsl:variable><!--
				--><xsl:for-each select="/xml/content/modules/module"><!--
					--><xsl:if test="contains($include, @name)"><!--
						-->{"name" : "<xsl:value-of select="@name" />", "value" : <xsl:value-of select="@multimedia_typeid" />}<!-- 
						--><xsl:if test="position() != last()">, </xsl:if><!-- 
					--></xsl:if><!-- 
				--></xsl:for-each><!--
			-->];
		});
	</script>
</xsl:variable>



<xsl:template name="content">
	<xsl:attribute name="class">content with-header</xsl:attribute>
	<div class="item-edit" style="border:0;">
	<form name="preferences" action="{$adminroot}?m={$config/module/@name}&amp;action=BackPreferencesModuleSave" method="post">
		<input type="hidden" name="module" value="{$module}" />
		<xsl:choose>

			<!-- Listado de módulos -->
			<xsl:when test="$module = ''">
				<section class="edit-header floatFix">
					<h2><xsl:value-of select="$language/modules/main_header"/></h2>
					<div class="alert"><!-- Para mensajes --></div>
				</section>
				<p><xsl:value-of select="$language/modules/active_modules"/>:</p>
				<section class="modules-grid">
					<ul>
						<xsl:for-each select="content/modules/module">
							<xsl:sort order="ascending" select="@name" />
							<li>
								<a href="{$adminroot}{$config/module/@name}/preferences/module/{@name}">
									<xsl:value-of select="@name" />
								</a>
							</li>
						</xsl:for-each>
					</ul>
				</section>
			</xsl:when>
			<!-- Listado de módulos -->

			
			<!-- Editar módulo -->
			<xsl:otherwise>
				<section class="edit-header floatFix">
					<span class="right">
						<a href="{$adminroot}{$modName}/preferences/module/" class="btn"><xsl:value-of select="$language/modules/module_edit/btn_back"/></a>&#xa0;
						<!-- <button type="submit" name="back" value="1" class="boton save-back"><span>Guardar y volver</span></button>&#xa0; -->
						<button type="submit" class="btn lightblue"><span><xsl:value-of select="$language/modules/module_edit/btn_save"/></span></button>&#xa0;
					</span>
					<h2><xsl:value-of select="$language/modules/module_edit/header"/>&#xa0;<em><xsl:value-of select="$module" /></em></h2>
					<div class="alert"><!-- Para mensajes --></div>
				</section>

				<div class="modules-conf">
					<xsl:for-each select="content/module/options/group">
							<xsl:choose>
								<!-- Navegación -->
								<xsl:when test="@name = 'navigation'">
									<h3><xsl:value-of select="$language/modules/module_edit/nav_header"/></h3>
									<p>
										<xsl:value-of select="$language/modules/module_edit/nav_description"/>
									</p> 
									<div class="module floatFix">
										<ul class="row">
											<xsl:if test="position() = last()"><xsl:attribute name="class">row last</xsl:attribute></xsl:if>
											<li class="three">
												<div>
													<!-- <xsl:variable name="label">
														<xsl:call-template name="lang-eval">
															<xsl:with-param name="pPath" select="@label" />
														</xsl:call-template>
													</xsl:variable> -->
													<label>@label</label>
													<input type="text" name="group[navigation][@label]" value="{@label}" />
												</div>
												<div>
													<label>@order</label>
													<input type="text" name="group[navigation][@order]" value="{@order}" />
												</div>
												<div>
													<label>@group</label>
													<input type="text" name="group[navigation][@group]" value="{@group}" />
												</div>
											</li>
										</ul>
									</div>
									<h3><xsl:value-of select="$language/modules/module_edit/subnav_header"/></h3>
									<p>
										<xsl:value-of select="$language/modules/module_edit/subnav_description"/>
									</p> 
									<div class="module floatFix">
										<xsl:for-each select="option">
											<ul class="row" data-ref="navigation" data-position="{position()}">
												<li class="left three">
													<input type="hidden" name="group[navigation][{position()}][@name]" value="item" />
													<div>
														<!-- <xsl:variable name="label">
															<xsl:call-template name="lang-eval">
																<xsl:with-param name="pPath" select="@label" />
															</xsl:call-template>
														</xsl:variable> -->
														<label>@label</label>
														<input type="text" name="group[navigation][{position()}][@label]" value="{@label}" />
													</div>
													<div>
														<label>@url</label>
														<input type="text" name="group[navigation][{position()}][@url]" value="{@url}" />
													</div>
													<div>
														<label>@access_level</label>
														<select name="group[navigation][{position()}][@access_level]">
															<option value=""><xsl:value-of select="$language/modules/module_edit/access_select_all"/></option>
															<xsl:variable name="thisLevel" select="@access_level" />
															<xsl:for-each select="/xml/content/levels/level">
																<option value="{name}">
																	<xsl:if test="name = $thisLevel">
																		<xsl:attribute name="selected">selected</xsl:attribute>
																	</xsl:if>
																	<xsl:value-of select="name" />
																</option>
															</xsl:for-each>
														</select>
													</div>
												</li>
												<li class="right">
													<a href="#" onclick="xmlConf.deleteProperty('navigation', {position()});return false;" class="actions tooltip" title="{$language/modules/module_edit/btn_delete}">
														<i class="fas fa-trash"><xsl:comment /></i>
														<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
													</a>
												</li>
											</ul>
										</xsl:for-each>
										<span class="right">
											<a href="#" class="btn add" onclick="xmlConf.addRow('navigation');return false;"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
										</span>
									</div>
								</xsl:when>

								<!-- acceso -->
								<xsl:when test="@name = 'settings'">
									<h3><xsl:value-of select="$language/modules/module_edit/variables_header"/></h3>
									<p>
										<xsl:value-of select="$language/modules/module_edit/variables_description"/>
									</p> 
									<div class="module floatFix">
										<xsl:for-each select="option">
											<ul class="row">
												<xsl:if test="position() = last()"><xsl:attribute name="class">row last</xsl:attribute></xsl:if>
												<li>
													<div>
														<label>@<xsl:value-of select="@name" /></label>
														<input type="text" name="group[settings][{position()}][@value]" value="{@value}" />
													</div>
												</li>
												<!-- <li class="right">
													<a href="#" class="delete" title="Eliminar" rel="tooltip">Borrar</a>
												</li> -->
											</ul>
										</xsl:for-each>
										<!-- <span class="right">
											<a href="#" class="btn">Agregar</a>
										</span> -->
									</div>
								</xsl:when>

								<!-- Categorías -->
								<xsl:when test="@name = 'categories'">
									<h3><xsl:value-of select="$language/modules/module_edit/categories_header"/></h3>
									<p>
										<xsl:value-of select="$language/modules/module_edit/categories_description_1"/>&#xa0;<a href="{$adminroot}category/"><xsl:value-of select="$language/modules/module_edit/categories_description_2"/></a>.
									</p> 
									<div class="module floatFix">
										<xsl:for-each select="option">
											<ul class="row" data-ref="categories" data-position="{position()}">
												<li class="left three">
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/type"/></label>
														<select name="group[categories][{position()}][@type]">
															<option value="parent">
																<xsl:if test="@type = 'parent'">
																	<xsl:attribute name="selected">selected</xsl:attribute>
																</xsl:if>
																parent
															</option>
															<option value="default">
																<xsl:if test="@type = 'default'">
																	<xsl:attribute name="selected">selected</xsl:attribute>
																</xsl:if>
																default
															</option>
														</select>
													</div>
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/category_label"/></label>
														<select name="group[categories][{position()}][@value]">
															<xsl:variable name="thisCategory" select="@value" />
															<xsl:for-each select="/xml/content/categories/category">
																<xsl:call-template name="category.item">
																	<xsl:with-param name="thisCategory" select="$thisCategory" />
																</xsl:call-template>
															</xsl:for-each>
														</select>
													</div>
													<div>
														<!-- <xsl:variable name="label">
															<xsl:call-template name="lang-eval">
																<xsl:with-param name="pPath" select="@label" />
															</xsl:call-template>
														</xsl:variable> -->
														<label><xsl:value-of select="$language/modules/module_edit/label"/></label>
														<input type="text" name="group[categories][{position()}][@label]" value="{@label}" />
													</div>
												</li>
												<li class="right">
													<a href="#" class="actions tooltip" onclick="xmlConf.deleteProperty('categories', {position()});return false;" title="{$language/modules/module_edit/btn_delete}">
														<i class="fas fa-trash"><xsl:comment /></i>
														<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
													</a>
												</li>
											</ul>
										</xsl:for-each>
										<span class="right">
											<a href="#" class="btn add" onclick="xmlConf.addRow('categories');return false;"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
										</span>
									</div>
									<!-- <script type="text/javascript">
										
									</script> -->
								</xsl:when>

								<!-- Relaciones -->
								<xsl:when test="@name = 'relations'">
									<h3><xsl:value-of select="$language/modules/module_edit/relations_header"/></h3>
									<div class="module floatFix">
										<xsl:for-each select="option">
											<ul class="row" data-ref="relations" data-position="{position()}">
												<li class="left three">
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/module_label"/></label>
														<xsl:variable name="thisType" select="@type_id" />
														
														<select name="group[relations][{position()}][@name]" onchange="xmlConf.updateType('relations', this)">
															<xsl:for-each select="/xml/content/modules/module[@relational = 1]">
																<!-- <xsl:if test="not(contains($exclude, @name))"> -->
																	<option value="{@name}" type_id="{@type_id}">
																		<xsl:if test="@type_id = $thisType">
																			<xsl:attribute name="selected">selected</xsl:attribute>
																		</xsl:if>
																		<xsl:value-of select="@title" />
																	</option>
																<!-- </xsl:if> -->
															</xsl:for-each>
														</select>
													</div>
													<div>
														<!-- <xsl:variable name="label">
															<xsl:call-template name="lang-eval">
																<xsl:with-param name="pPath" select="@label" />
															</xsl:call-template>
														</xsl:variable> -->
														<label><xsl:value-of select="$language/modules/module_edit/label"/></label>
														<input type="text" name="group[relations][{position()}][@label]" value="{@label}" />
													</div>
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/multimedias_label"/></label>
														<input type="radio" name="group[relations][{position()}][@multimedias]" value="1" id="multimedia{position()}1">
															<xsl:if test="@multimedias = 1">
																<xsl:attribute name="checked">checked</xsl:attribute>
															</xsl:if>
														</input>
														<label class="inline" for="multimedia{position()}1"><xsl:value-of select="$language/modules/module_edit/multimedias_yes"/></label>
														<input type="radio" name="group[relations][{position()}][@multimedias]" value="0" id="multimedia{position()}0">
															<xsl:if test="@multimedias = 0">
																<xsl:attribute name="checked">checked</xsl:attribute>
															</xsl:if>
														</input>
														<label class="inline" for="multimedia{position()}0"><xsl:value-of select="$language/modules/module_edit/multimedias_no"/></label>
													</div>
												</li>
												<li class="right">
													<a onclick="xmlConf.deleteProperty('relations', {position()});return false;" href="#" class="actions tooltip" title="{$language/modules/module_edit/btn_delete}">
														<i class="fas fa-trash"><xsl:comment /></i>
														<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
													</a>
												</li>
											</ul>
										</xsl:for-each>
										<span class="right">
											<a href="#" class="btn add" onclick="xmlConf.addRow('relations');return false;"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
										</span>
									</div>
								</xsl:when>

								<!-- Multimedias -->
								<xsl:when test="@name = 'multimedias'">
									<h3><xsl:value-of select="$language/modules/module_edit/multimedias_header"/></h3>
									<div class="module floatFix">
										<xsl:for-each select="option">
											<ul class="row" data-ref="multimedias" data-position="{position()}">
												<li class="left four">
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/module_label"/></label>
														<xsl:variable name="thisType" select="@type_id" />
														<xsl:variable name="include">image,document,video,audio</xsl:variable>
														<select name="group[multimedias][{position()}][@name]" onchange="xmlConf.updateMultimedia('multimedias', this);">
															<xsl:for-each select="/xml/content/modules/module">
																<xsl:if test="contains($include, @name)">
																	<option value="{@name}" type_id="{@multimedia_typeid}">
																		<xsl:if test="@multimedia_typeid = $thisType">
																			<xsl:attribute name="selected">selected</xsl:attribute>
																		</xsl:if>
																		<xsl:value-of select="@name" />
																	</option>
																</xsl:if>
															</xsl:for-each>
														</select>
													</div>
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/type_id_label"/></label>
														<input type="text" data-type="type_id" name="group[multimedias][{position()}][@type_id]" value="{@type_id}" readonly="true"/>
													</div>
													<div>
														<!-- <xsl:variable name="label">
															<xsl:call-template name="lang-eval">
																<xsl:with-param name="pPath" select="@label" />
															</xsl:call-template>
														</xsl:variable> -->
														<label><xsl:value-of select="$language/modules/module_edit/label"/></label>
														<input type="text" name="group[multimedias][{position()}][@label]" value="{@label}" />
													</div>
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/category_label"/></label>
														<xsl:variable name="thisCategory" select="@category_id" />
														<select name="group[multimedias][{position()}][@category_id]">
															<option value=""><xsl:value-of select="$language/modules/module_edit/category_select_none"/></option>
															<xsl:for-each select="/xml/content/categories/category">
																<xsl:call-template name="category.item">
																	<xsl:with-param name="thisCategory" select="$thisCategory" />
																</xsl:call-template>
															</xsl:for-each>
														</select>
													</div>
												</li>
												<li class="right">
													<a onclick="xmlConf.deleteProperty('multimedias', {position()});return false;" href="#" class="actions tooltip" title="{$language/modules/module_edit/btn_delete}">
														<i class="fas fa-trash"><xsl:comment /></i>
														<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
													</a>
												</li>
											</ul>
										</xsl:for-each>
										<span class="right">
											<a href="#" class="btn add" onclick="xmlConf.addRow('multimedias');return false;"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
										</span>
									</div>
								</xsl:when>

								<!-- Accepted Files -->
								<xsl:when test="@name = 'accepted_files'">
									<h3><xsl:value-of select="$language/modules/module_edit/accepted_files_header"/></h3>
									<div class="module floatFix">
										<xsl:for-each select="option">
											<ul class="row">
												<xsl:if test="position() = last()"><xsl:attribute name="class">row last</xsl:attribute></xsl:if>
												<li class="left">
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/accepted_types_label"/></label>
														<input type="text" name="group[accepted_files][{position()}][@types]" value="{@types}" />
													</div>
													<!-- <div>
														<label>Limite por subida</label>
														<input type="text" name="group[accepted_files][{position()}][@limit]" value="{@limit}" />
													</div>
													<div>
														<label>Peso Max</label>
														<input type="text" name="group[accepted_files][{position()}][@sizelimit]" value="{@sizelimit}" />
													</div> -->
												</li>
												<li class="right">
													<a href="#" class="actions tooltip" title="{$language/modules/module_edit/btn_delete}">
														<i class="fas fa-trash"><xsl:comment /></i>
														<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
													</a>
												</li>
											</ul>
										</xsl:for-each>
										<span class="right">
											<a href="#" class="btn add"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
										</span>
									</div>
								</xsl:when>

								<!-- Folders -->
								<xsl:when test="@name = 'folders'">
									<h3><xsl:value-of select="$language/modules/module_edit/folders_header"/></h3>
									<div class="module floatFix">
										<xsl:for-each select="option">
											<ul class="row">
												<xsl:if test="position() = last()"><xsl:attribute name="class">row last</xsl:attribute></xsl:if>
												<li class="left two">
													<div>
														<label><xsl:value-of select="$language/modules/module_edit/value_label"/></label>
														<input type="text" name="group[folders][{position()}][text()]" value="{.}" />
													</div>
													<div>
														<label>@Name</label>
														<input type="text" name="group[folders][{position()}][@name]" value="{@name}" />
													</div>
													
												</li>
												<li class="right">
													<a href="#" class="actions tooltip" title="{$language/modules/module_edit/btn_delete}">
														<i class="fas fa-trash"><xsl:comment /></i>
														<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
													</a>
												</li>
											</ul>
										</xsl:for-each>
										<span class="right">
											<a href="#" class="btn add"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
										</span>
									</div>
								</xsl:when>
							</xsl:choose>
					</xsl:for-each>
				</div>

				<!-- Reglas de rewrite -->
				<div class="modules-conf">
					<h3><xsl:value-of select="$language/modules/module_edit/rewrite_rules_header"/></h3>
					<div class="module floatFix">
						<ul class="row">
							<li>
								<div>
									<label>@debug</label>
									<input type="text" name="/module/rewrite/@debug" value="{content/module/rewrite/@debug}" />
								</div>
							</li>
						</ul>
					</div>
				</div>

				<xsl:if test="content/module/rewrite/backend/rule">
					<div class="modules-conf">
						<h3><xsl:value-of select="$language/modules/module_edit/backend_rules_header"/></h3>
						<div class="module floatFix">
							<xsl:for-each select="content/module/rewrite/backend/rule">
								<ul class="row" data-ref="backend" data-position="{position()}">
									<li class="left five">
										<div>
											<label>@match</label>
											<input type="text" name="rewrite[backend][{position()}][@match]" value="{@match}" />
										</div>
										<div>
											<label>@apply</label>
											<input type="text" name="rewrite[backend][{position()}][@apply]" value="{@apply}" />
										</div>
										<div>
											<label>@args</label>
											<input type="text" name="rewrite[backend][{position()}][@args]" value="{@args}" />
										</div>
										<div>
											<label>@access_level</label>
											<input type="text" name="rewrite[backend][{position()}][@access_level]" value="{@access_level}" />
										</div>
										<div>
											<label>@redirect</label>
											<input type="text" name="rewrite[backend][{position()}][@redirect]" value="{@redirect}" />
										</div>
									</li>
									<li class="right">
										<a onclick="xmlConf.deleteRule('backend', {position()});return false;" href="#" class="actions tooltip" title="{$language/modules/module_edit/btn_delete}">
											<i class="fas fa-trash"><xsl:comment /></i>
											<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
										</a>
									</li>
								</ul>
							</xsl:for-each>
							<span class="right">
								<a href="#" class="btn add" onclick="xmlConf.addRule('backend');return false;"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
							</span>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="content/module/rewrite/frontend/rule">
					<div class="modules-conf">
						<h3><xsl:value-of select="$language/modules/module_edit/frontend_rules_header"/></h3>
						<div class="module floatFix">
							<xsl:for-each select="content/module/rewrite/frontend/rule">
								<ul class="row" data-ref="frontend" data-position="{position()}">
									<li class="left three">
										<div>
											<label>@match</label>
											<input type="text" name="rewrite[frontend][{position()}][@match]" value="{@match}" />
										</div>
										<div>
											<label>@apply</label>
											<input type="text" name="rewrite[frontend][{position()}][@apply]" value="{@apply}" />
										</div>
										<div>
											<label>@args</label>
											<input type="text" name="rewrite[frontend][{position()}][@args]" value="{@args}" />
										</div>
									</li>
									<li class="right">
										<a onclick="xmlConf.deleteRule('frontend', {position()});return false;" href="#" class="actions tooltip" title="{$language/modules/module_edit/btn_delete}">
											<i class="fas fa-trash"><xsl:comment /></i>
											<!-- <xsl:value-of select="$language/modules/module_edit/btn_delete"/> -->
										</a>
									</li>
								</ul>
							</xsl:for-each>
							<span class="right">
								<a href="#" class="btn add" onclick="xmlConf.addRule('frontend');return false;"><xsl:value-of select="$language/modules/module_edit/btn_add"/></a>
							</span>
						</div>
					</div>
				</xsl:if>
			</xsl:otherwise>
			<!-- Editar módulo -->

		</xsl:choose>
		<input type="hidden" name="modToken" value="{$modToken}" />
	</form>
	</div>


</xsl:template>



<xsl:template name="category.item">
	<xsl:param name="prefix" />
	<xsl:param name="thisCategory" />

	<option value="{@category_id}">
		<xsl:if test="@category_id = $thisCategory">
			<xsl:attribute name="selected">selected</xsl:attribute>
		</xsl:if>
		<xsl:value-of select="$prefix" />&#xa0;<xsl:value-of select="name" />
	</option>
	<xsl:if test="categories/category">
		<xsl:for-each select="categories/category">
			<xsl:call-template name="category.item">
				<xsl:with-param name="thisCategory" select="$thisCategory" />
				<xsl:with-param name="prefix"><xsl:value-of select="$prefix" />-</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:if>
</xsl:template>


</xsl:stylesheet>