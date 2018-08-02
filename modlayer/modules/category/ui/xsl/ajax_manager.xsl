<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="call" />
<xsl:param name="categoria_id" />



<!--
	Este archivo, recibe por parámetro a que template tiene que llamar, para imprimirlo.
	Se utiliza cuando se hace un llamado con ajax para obtener un bloque de html 
	que resulta de un template. Evitando cargar el layout, y sin pisar el match='/'
-->

<xsl:template match="/xml">
	<xsl:choose>
		<xsl:when test="$call='editarCategoria'">
			<xsl:call-template name="categoria.editar">
				<xsl:with-param name="categoria_id" select="$categoria_id" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$call='agregarSubcategoria'">
			<xsl:call-template name="categoria.agregar_subcategoria">
				<xsl:with-param name="categoria_id" select="$categoria_id" />
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
	
</xsl:template>


<xsl:template name="categoria.editar">
	<xsl:param name="categoria_id" />
	<!--<textarea><xsl:copy-of select="/"/></textarea>-->
	<form name="editar_categoria_{$categoria_id}" method="post" action="{$adminroot}?m=category&amp;action=BackEdit">
		<input type="hidden" name="category_id" value="{content/category/@category_id}" />
		<!--<textarea>
			<xsl:copy-of select="/" />
		</textarea>-->
	<ul class="form floatFix categories">
		<li>
			<label>Nombre</label>
			<input type="text" name="category_name" value="{content/category/name}" />
		</li>
		<li class="floatFix">
			<label for="description">Categoría Superior</label>
			<select name="category_parent" id="categoria_parent">
				<option value="0">Sin Categoría Superior</option>

				<xsl:call-template name="category_item">
					<xsl:with-param name="categories" select="content/categories"/>
					<xsl:with-param name="id" select="content/category/@category_id"/>
					<xsl:with-param name="parent" select="content/category/@parent"/>
					<xsl:with-param name="order" select="content/category/@order"/>
				</xsl:call-template>
			</select>
		</li>
		<li class="floatFix">
			<label for="description">Orden</label>
			<select name="category_order" id="category_order">
				<xsl:call-template name="combo.item.incremental">
					<xsl:with-param name="start">0</xsl:with-param>
					<xsl:with-param name="end">20</xsl:with-param>
					<xsl:with-param name="selected" select="content/category/@order" />
				</xsl:call-template>
			</select>
		</li>
		<li class="btnes">
			<button class="btn color">Guardar</button>&#xa0;&#xa0;<button class="btn cancel" onclick="return false;">Cancelar</button>
		</li>
	</ul>
	</form>
</xsl:template>


<xsl:template name="categoria.agregar_subcategoria">
	<xsl:param name="categoria_id" />
	<!--<textarea><xsl:copy-of select="/"/></textarea>-->
	<form name="agregar_subcategoria_{$categoria_id}" action="{$adminroot}?m=category&amp;action=BackAdd" method="POST">
		<input type="hidden" name="category_parent" value="{$categoria_id}" />
		<ul class="form floatFix">
			<li>
				<label>Nombre</label>
				<input type="text" name="category_name" value="" />
			</li>
			<li class="btnes">
				<button class="btn color">Guardar</button>&#xa0;&#xa0;<button class="btn cancel" onclick="return false;">Cancelar</button>
			</li>
		</ul>
	</form>
</xsl:template>

<xsl:template name="category_item">
	<xsl:param name="categories" />
	<xsl:param name="id" />
	<xsl:param name="parent" />
	<xsl:param name="order" select='8' />
	
		<!-- <xsl:if test="$parent!=0"> -->
			<xsl:for-each select="$categories/category[@category_id != $categoria_id]">
				<option value="{@category_id}">
					<xsl:if test="@parent!=0">
						<xsl:attribute name="style">padding-left:<xsl:value-of select="$order"/>px</xsl:attribute>
					</xsl:if>
					<xsl:if test="/xml/content/category/@parent = @category_id">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="name" />
				</option>
				<xsl:if test="count(categories/category)>0">
					<xsl:call-template name="category_item">
						<xsl:with-param name="categories" select="categories"/>
						<xsl:with-param name="order" select="$order + 8"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		<!-- </xsl:if> -->
</xsl:template>

</xsl:stylesheet>