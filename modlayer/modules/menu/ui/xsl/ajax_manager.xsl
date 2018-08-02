<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="call" />
<xsl:param name="menu_id" />

<!--
	Este archivo, recibe por parametro a que template tiene que llamar, para imprimirlo.
	Se utiliza cuando se hace un llamado con ajax para obtener un bloque de html 
	que resulta de un template. Evitando cargar el layout, y sin pisar el match='/'
-->

<xsl:template match="/xml">
	<xsl:choose>
		<xsl:when test="$call='editMenu'">
			<xsl:call-template name="menu.edit">
				<xsl:with-param name="menu_id" select="$menu_id" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$call='addSubMenu'">
			<xsl:call-template name="menu.add_subMenu">
				<xsl:with-param name="menu_id" select="$menu_id" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$call='orderSubMenu'">
			<xsl:call-template name="menu.order_subMenu">
				<xsl:with-param name="menu_id" select="$menu_id" />
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="menu.edit">
	<xsl:param name="menu_id" />
	<!--<textarea><xsl:copy-of select="/"/></textarea>-->
	<form name="edit_menu_{$menu_id}" method="post" action="{$adminroot}?m=menu&amp;action=BackEdit">
		<input type="hidden" name="menu_id" value="{content/menu/@menu_id}" />
		<!--<textarea>
			<xsl:copy-of select="/" />
		</textarea>-->
	<ul class="form floatFix menus">
		<li>
			<label>Name</label>
			<input type="text" name="menu_name" value="{content/menu/name}" />
		</li>
		<li>
			<label>URL</label>
			<input type="text" name="menu_url" value="{content/menu/url}" />
		</li>
		<!-- <li>
			<label>Content Type</label>
			<select name="content_type">
				<option value="">Article</option>
				<option value="">Page</option>
				<option value="">Gallery</option>
				<option value="">Home</option>
			</select>
		</li>
		<li>
			<label>Action</label>
			<select name="content_type">
				<option value="">Display a List</option>
				<option value="">Display an Item</option>
				<option value="">Gallery</option>
				<option value="">Home</option>
			</select>
		</li>
		<li>
			<label>When Click Open in:</label>
			<select name="content_type">
				<option value="">Same window</option>
				<option value="">New Window</option>
			</select>
		</li> -->
		

		<li class="floatFix">
			<label for="description">Parent Menu</label>
			<select name="menu_parent" id="menu_parent">
				<option value="0">No Parent Menu</option>

				<xsl:call-template name="menu_item">
					<xsl:with-param name="menus" select="content/menus"/>
					<xsl:with-param name="parent" select="content/menu/@menu_id"/>
					<xsl:with-param name="parent" select="content/menu/@parent"/>
					<xsl:with-param name="order" select="content/menu/@order"/>
				</xsl:call-template>
			</select>
		</li>
		<li class="floatFix">
			<label for="description">Order</label>
			<select name="menu_order" id="menu_order">
				<xsl:call-template name="combo.item.incremental">
					<xsl:with-param name="start">0</xsl:with-param>
					<xsl:with-param name="end">20</xsl:with-param>
					<xsl:with-param name="selected" select="content/menu/@order" />
				</xsl:call-template>
			</select>
		</li>
		<!-- <li class="floatFix">
			<label for="description">Active</label>
			<select name="menu_state" id="menu_state">
				<xsl:call-template name="combo.item.incremental">
					<xsl:with-param name="start">0</xsl:with-param>
					<xsl:with-param name="end">1</xsl:with-param>
					<xsl:with-param name="selected" select="content/menu/@state" />
				</xsl:call-template>
			</select>
		</li> -->
		<li class="btnes">
			<button class="btn color">Guardar</button>&#xa0;&#xa0;<button class="btn cancel" onclick="return false;">Cancelar</button>
		</li>
	</ul>
	</form>
</xsl:template>

<xsl:template name="menu.add_subMenu">
	<xsl:param name="menu_id" />
	<!--<textarea><xsl:copy-of select="/"/></textarea>-->
	<form name="add_subMenu_{$menu_id}" action="{$adminroot}?m=menu&amp;action=BackAdd" method="POST">
		<input type="hidden" name="menu_parent" value="{$menu_id}" />
		<ul class="form floatFix">
			<li>
				<label>Name</label>
				<input type="text" name="menu_name" value="" />
			</li>
			<li>
				<label>URL</label>
				<input type="text" name="menu_url" value="" />
			</li>
			<li class="floatFix">
				<label for="description">Order</label>
				<select name="menu_order" id="menu_order">
					<xsl:call-template name="combo.item.incremental">
						<xsl:with-param name="start">0</xsl:with-param>
						<xsl:with-param name="end">20</xsl:with-param>
					</xsl:call-template>
				</select>
			</li>
			<!-- <li class="floatFix">
				<label for="description">Active</label>
				<select name="menu_state" id="menu_state">
					<option value="0">Inactive</option>
					<option value="1">Active</option>
				</select>
			</li> -->
			<li class="btnes">
				<button class="btn color">Guarda</button>&#xa0;&#xa0;<button class="btn cancel" onclick="return false;">Cancelar</button>
			</li>
		</ul>
	</form>
</xsl:template>


<xsl:template name="menu_item">
	<xsl:param name="menus" />
	<xsl:param name="id" />
	<xsl:param name="parent" />
	<xsl:param name="profundidad" select='8' />
	
		<xsl:if test="$parent!=0">
			<xsl:for-each select="$menus/menu[@menu_id != $menu_id]">
				<option value="{@menu_id}">
					<xsl:if test="@parent!=0">
						<xsl:attribute name="style">padding-left:<xsl:value-of select="$profundidad"/>px</xsl:attribute>
					</xsl:if>
					<xsl:if test="/xml/content/menu/@parent = @menu_id">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="name" />
				</option>
				<xsl:if test="count(menus/menu)>0">
					<xsl:call-template name="menu_item">
						<xsl:with-param name="menus" select="menus"/>
						<xsl:with-param name="profundidad" select="$profundidad + 8"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
</xsl:template>

</xsl:stylesheet>