<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template name="display.collection">
	<xsl:param name="collection" />
	<xsl:param name="IdAttribute">id</xsl:param>
	<xsl:param name="html" />
	<xsl:param name="withImage">1</xsl:param>

	<!-- 
		el parámetro includeLocalData indica si debe incluirse un llamado al template
		"local.collection.data" que deberá estar definido en el archivo XSL que llama a este template genérico 
		de listado.
		Como el llamado se hace para cada item, se utilizará para incluir datos propios del módulo.
		Por ej: la fecha de última importación de un feed RSS. 
	-->
	<xsl:param name="includeLocalData">0</xsl:param>
	<xsl:attribute name="class">content with-header</xsl:attribute>
	<xsl:call-template name="filter.list" />
	
	<section class="list-header floatFix">
		<xsl:call-template name="pagination.box" />
		<div class="list-actions">
			<span>
				<input type="checkbox" name="all" id="all" class="checkAll" />
				<label for="all"><xsl:value-of select="$language/collection/select_items"/></label>
			</span>
			<span>
				<xsl:value-of select="$language/collection/selected_label"/>
				<xsl:if test="$config/module/options/group[@name='categories']/option">
					<a href="#" class="btn blue categories"><xsl:value-of select="$language/collection/selected_setCategory"/></a>
				</xsl:if>
				<!-- <a href="#" class="btn duplicate">Duplicar</a> -->
				<a href="#" class="btn red delete"><xsl:value-of select="$language/collection/delete_selected"/></a>
			</span>
		</div>
	</section>

	<section class="collection" id="grid">
		<xsl:if test="$query != ''">
			<div class="alert" style="margin:20px 0;">
				<xsl:value-of select="$language/messages/showing_query_results"/>&#xa0;<strong><em>"<xsl:value-of select="$query"/>"</em></strong>
				<xsl:if test="$categories != ''">&#xa0;<xsl:value-of select="$language/messages/with_category_filter"/></xsl:if>
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
	    	<xsl:when test="not($collection/object) and $query = ''">
	    		<div class="empty-list rounded">
	    			<!-- No se encontró ningún elemento.<br/>
	    			Para cargar uno nuevo apretá la letra "n" de tu teclado ó en 
	    			<br/> -->
	    			<xsl:value-of select="$language/messages/empty_list/nothing_found"/><br/>
	    			<xsl:value-of select="$language/messages/empty_list/load_new"/><br/>
	    			<a href="{$adminroot}{$modName}/add/" class="btn lightblue"><xsl:value-of select="$language/item_editor/btn_add"/></a>
	    		</div>
	    	</xsl:when>
	    	<xsl:otherwise>
				<ul class="list" data-role="list-rows">
					<xsl:if test="$withImage != 1">
						<xsl:attribute name="class">list no-image</xsl:attribute>
					</xsl:if>
					<xsl:for-each select="$collection/object">
						<xsl:variable name="item_id" select="@*[name() = $IdAttribute]" />
						<li id="object_{@id}" item_id="{$item_id}" class="state-{@state}">
							<input type="checkbox" name="item_{$item_id}" class="check"/>
							<div class="quick">
								<xsl:if test="latitud != '' and longitud != ''">
									<span class="icon geoloc tooltip" title="{latitud}, {longitud}">&#xa0;</span>
								</xsl:if>
								<a href="#" class="unpublish tooltip" title="{$language/collection/btn_unpublish}">
									<xsl:if test="@state = 0">
										<xsl:attribute name="style">display:none;</xsl:attribute>
									</xsl:if>
									<!-- <xsl:value-of select="$language/collection/btn_unpublish" /> -->
									<i class="fas fa-cloud-download-alt">&#xa0;</i>
								</a>
								<a href="#" class="publish tooltip" title="{$language/collection/btn_publish}">
									<xsl:if test="@state = 1">
										<xsl:attribute name="style">display:none;</xsl:attribute>
									</xsl:if>
									<i class="fas fa-cloud-upload-alt">&#xa0;</i>
									<!-- <xsl:value-of select="$language/collection/btn_publish" /> -->
								</a>
								<a href="{$adminroot}?m={$modName}&amp;action=GotoItem&amp;id={$item_id}" target="_blank" class="popup tooltip" title="{$language/collection/btn_popout}">
									<xsl:if test="@state = 0">
										<xsl:attribute name="style">display:none;</xsl:attribute>
									</xsl:if>
									
									<i class="fas fa-external-link-square-alt ">&#xa0;</i>
									<!-- <xsl:value-of select="$language/collection/btn_popout" /> -->
								</a> 
							
								<a href="{$adminroot}{$modulename}/edit/{$item_id}" class="edit tooltip" title="{$language/collection/btn_edit}">
									<i class="fas fa-pencil-alt ">&#xa0;</i>
								</a> 
								<a class="delete tooltip" href="#" title="{$language/collection/btn_delete}">
									<!-- <xsl:value-of select="$language/collection/btn_delete"/> -->
									<i class="fas fa-eraser ">&#xa0;</i>
								</a>
							</div>
							<time>
								<xsl:variable name="date">
									<xsl:call-template name="date.time">
										<xsl:with-param name="fecha" select="@created_at" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="$date" />
							</time>
							<h2 title="{title}">
								<a href="{$adminroot}{$modulename}/edit/{$item_id}">
									<xsl:value-of select="title|name" />
									<xsl:if test="title = ''"><xsl:value-of select="$language/collection/no_title"/></xsl:if>
								</a>
							</h2>
							<xsl:if test="$withImage = 1">
								<xsl:choose>
									<xsl:when test="multimedias/images/image">
										<a href="{$adminroot}{$modulename}/edit/{$item_id}">
											<xsl:call-template name="image.bucket">
												<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
												<xsl:with-param name="type" select="multimedias/images/image/@type" />
												<xsl:with-param name="width">80</xsl:with-param>
												<xsl:with-param name="height">80</xsl:with-param>
												<xsl:with-param name="crop">c</xsl:with-param>
												<xsl:with-param name="class">pic rounded</xsl:with-param>
											</xsl:call-template>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<span class="pic rounded">&#xa0;</span>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="parent_title != ''">
								<span class="parent"><a href="{$adminroot}{parent_module}/edit/{@parent}"><xsl:value-of select="parent_title" /></a></span>
							</xsl:if>
							<xsl:if test="@creation_usertype = 'frontend'">
								<span><xsl:value-of select="user/name" />&#xa0;<xsl:value-of select="user/lastname" />&#xa0;(<xsl:value-of select="user/email" />)</span>
							</xsl:if>

							<!-- Extra HTML enviado desde el módulo que muestra el listado -->
							<xsl:copy-of select="$html" />

							<!-- Incluir datos locales -->
							<xsl:if test="$includeLocalData = 1">
								<xsl:call-template name="local.collection.data"/>
							</xsl:if>

							<div class="footer">
								<span class="user-data">
									<span class="icon creation tooltip" title="{$language/collection/created_by}">&#xa0;</span>
									<xsl:value-of select="createdby"/>,&#xa0;<abbr class="timeago" title="{@created_at}"><xsl:value-of select="@created_at"/></abbr>
								</span>

								<xsl:if test="modifiedby != ''">
									<span class="user-data">
										<span class="icon modified tooltip" title="{$language/collection/edited_by}">&#xa0;</span>
										<xsl:value-of select="modifiedby" />,&#xa0;<abbr class="timeago" title="{@updated_at}"><xsl:value-of select="@updated_at"/></abbr>
									</span>
								</xsl:if>
								
								<xsl:if test="publishedby != ''">
									<span class="user-data">
										<span class="icon publish tooltip" title="{$language/collection/published_by}">&#xa0;</span>
										<xsl:value-of select="publishedby" />,&#xa0;<abbr class="timeago" title="{published_at}"><xsl:value-of select="published_at"/></abbr>
									</span>
								</xsl:if>
									
								<xsl:if test="categories/*/category">
									<xsl:for-each select="categories/*/category">
										<xsl:sort order="ascending" select="order" data-type="number"/>
										<span class="category rounded" category_id="{@category_id}" title="{name}">
											<a href="{$adminroot}{$modName}/list/?categories[]={@category_id}">
												<xsl:value-of select="name" />
											</a>
											<a href="javascript:void(0);" title="{$language/collection/delete_category}" data-role="category-delete" onclick="return false;" data-item_id="{$item_id}" data-category_id="{@category_id}" class="remove">&#xa0;</a>
											<!-- category.delete({@category_id}, {$item_id}); -->
										</span>
									</xsl:for-each>
								</xsl:if>
							</div>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</section>
	<input type="hidden" name="modToken" value="{$modToken}" />
</xsl:template>

	<!--################### TEMPLATES DE FILTROS ####################-->

	<xsl:template name="filter.list">
	<xsl:param name="filterURL">0</xsl:param>
	<!-- Si tiene filtros en el xml -->
	<!-- <xsl:if test="$content/filter/*"> -->
		<xsl:variable name="filter" select="$content/filter" />
		<xsl:variable name="sort" select="$context/get_params/sort" />
		<xsl:variable name="filteraction"><!-- 
			 --><xsl:choose>
				<xsl:when test="$filterURL = '0'"><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/list/</xsl:when>
				<xsl:otherwise><xsl:value-of select="$filterURL" /></xsl:otherwise>
			</xsl:choose><!-- 
		 --></xsl:variable>
		<section class="filter">
			<div class="trigger">
				<a href="#" title="{$language/filters/open_filters}">
					<xsl:value-of select="$language/filters/tab" />
				</a>
			</div>
			<div class="fields">
				<form name="listfilter" action="{$filteraction}" method="get">
					<xsl:if test="count($context/get_params/*) &gt; 0">
						<xsl:for-each select="$context/get_params/*">
							<xsl:if test="name() != 'state' and name() != 'startdate' and name() != 'enddate' and name() != 'categories' and name() != 'sort' and name() != 'order' and name() != 'pageSize' and name() != 'page'">
								<input type="hidden" name="{name()}" value="{.}" />	
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<header>
						<xsl:value-of select="$language/filters/title" />
					</header>

					<!-- Estado -->
					<xsl:if test="$filter/states/state">
						<section>
							<span class="header">
								<xsl:value-of select="$language/filters/title_state" />
							</span>
							<select name="state" style="width:100%;">
								<option value=""><xsl:value-of select="$language/filters/state/no_filter" /></option>
								<xsl:for-each select="$filter/states/state">
									<option value="{value}">
										<xsl:if test="$state = value"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
										<!-- <xsl:value-of select="label" /> -->
										<xsl:call-template name="lang-eval">
											<xsl:with-param name="pPath" select="label" />
										</xsl:call-template>
									</option>
								</xsl:for-each>
							</select>
						</section>
					</xsl:if>
					<!-- Estado -->

					<!-- Fecha -->
					<section>
						<span class="header">
							<xsl:value-of select="$language/filters/title_date" />
						</span>
						<div class="date-filter date-start">
							<label><xsl:value-of select="$language/filters/title_date_from" /></label>
							<input type="text" name="startdate" value="{$startdate}" readonly="true" class="dateonly" placeholder="{$language/filters/title_date_from}"/>
							<a href="javascript:void(0);" class="close">
								<xsl:if test="$startdate != ''"><xsl:attribute name="style">display:block;</xsl:attribute></xsl:if>
								&#xa0;
							</a>
						</div>
						<div class="date-filter date-end">
							<label><xsl:value-of select="$language/filters/title_date_to" /></label>
							<input type="text" name="enddate" value="{$enddate}" readonly="true" class="dateonly" placeholder="{$language/filters/title_date_to}"/>
							<a href="javascript:void(0);" class="close">
								<xsl:if test="$enddate != ''"><xsl:attribute name="style">display:block;</xsl:attribute></xsl:if>
								&#xa0;
							</a>
						</div>
					</section>
					<!-- Fecha -->

					<!-- Categorías -->
					<xsl:if test="$filter/group//category">
						<xsl:for-each select="$filter/group">
							<section>
								<div class="sub-filter">
									<span class="header">
										<xsl:value-of select="@name" />
										<i class="icon ac-down-w">&#xa0;</i>
									</span>
									<div class="float-menu">
										<xsl:if test="$categories != ''">
											<xsl:attribute name="class">float-menu expanded</xsl:attribute>
										</xsl:if>
										<ul>
											<xsl:for-each select="categories/category">
												<xsl:sort order="ascending" select="name" />
												<xsl:call-template name="filter.item" />
											</xsl:for-each>
										</ul>
									</div>
								</div>
							</section>
						</xsl:for-each>
					</xsl:if>
					<!-- Categorías -->
					
					<!-- Ordenar -->
					<header>
						<xsl:value-of select="$language/filters/title_order" />
					</header>
					<section>
						<span class="header">
							<xsl:value-of select="$language/filters/title_order_by" />
						</span>
						<select name="sort" style="margin:0 0 5px 0;">
							<option value="date">
								<xsl:if test="$sort = 'date'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
								<!-- Fecha creación -->
								<xsl:value-of select="$language/filters/order_by/created_at" />
							</option>
							<option value="mod">
								<xsl:if test="$sort = 'mod'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
								<!-- Fecha modificación -->
								<xsl:value-of select="$language/filters/order_by/updated_at" />
							</option>
							<option value="id">
								<xsl:if test="$sort = 'id'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
								<!-- Item id -->
								<xsl:value-of select="$language/filters/order_by/object_id" />
							</option>
							<option value="title">
								<xsl:if test="$sort = 'title'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
								<!-- Título -->
								<xsl:value-of select="$language/filters/order_by/object_title" />
							</option>
							
						</select>
						<input type="radio" name="order" value="desc" id="desc">
							<xsl:if test="$order = 'desc'">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
							<label for="desc"><xsl:value-of select="$language/filters/order_by/descending" /></label>
						</input>
						<input type="radio" name="order" value="asc" id="asc">
							<xsl:if test="$order = 'asc'">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
							<label for="asc"><xsl:value-of select="$language/filters/order_by/ascending" /></label>
						</input>
					</section>
					<!-- Ordenar -->
					<!-- pageSize -->
					<section>
						<span class="header">
							<xsl:value-of select="$language/filters/title_display" />
						</span>
						<input type="text" name="pageSize" value="{$pageSize}" />
					</section>
					<!-- pageSize -->
					<p style="text-align:center;margin:20px 0;">
						<button type="submit" class="btn blue">
							<xsl:value-of select="$language/filters/btn_apply" />
						</button>
					</p>

				</form>
				<!-- <xsl:call-template name="js.cal" /> -->

			</div>
		</section>
	<!-- </xsl:if> -->
	</xsl:template>

	<xsl:template name="filter.item">
		<xsl:param name="prefix" />
			<li item_id="{@category_id}">
				<xsl:if test="$prefix = 1">
					<xsl:attribute name="style">padding-left:15px;</xsl:attribute>
				</xsl:if>
				<input type="checkbox" name="categories[]" value="{@category_id}" id="catid{@category_id}">
					<xsl:variable name="isSelected">
						<xsl:call-template name="checkid">
							<xsl:with-param name="list" select="$categories" />
							<xsl:with-param name="id" select="@category_id" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$isSelected = 1">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
					<label for="catid{@category_id}"><xsl:value-of select="name" /></label>
				</input>
			</li>
			<xsl:if test="categories/category">
				<xsl:for-each select="categories/category">
					<xsl:sort order="ascending" select="name" />
					<xsl:call-template name="filter.item">
						<xsl:with-param name="prefix">1</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
	</xsl:template>


	<!-- 
		Este template sirve para comprobar si un ID viene en un string de ids separados
		por coma
	 -->
	<xsl:template name="checkid">
		<xsl:param name="list" />
		<xsl:param name="id" />
		<xsl:choose>
			<xsl:when test="contains($list, ',')">
				<xsl:choose>
					<xsl:when test="substring-before($list, ',') = $id">1</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="checkid">
							<xsl:with-param name="list" select="substring-after($list, ',')" />
							<xsl:with-param name="id" select="$id" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$list = $id">1</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--################### FIN TEMPLATES DE FILTROS ####################-->

</xsl:stylesheet>