<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra"/>

<xsl:template name="content">
	<form name="add" action="{$adminroot}?m={$config/module/@name}&amp;action=BackAdd" method="POST">
		<section class="edit-header floatFix">
			<span class="right"><!-- 
				 --><a href="{$adminroot}{$modName}/return/" class="btn">Cancelar</a>&#xa0;<!-- 
				 --><button type="submit" class="btn color">Guardar</button><!-- 
			 --></span>

			<h2>Agregar</h2>
		</section>

		
		<section class="box-overflow">
			<div class="edit-body">
				<section class="mdneditor full">
					<ul class="form">
						<li>
							<label for="name">Título</label><input type="text" id="nombre" name="menu_name" value=""/>
						</li>
						<li>
							<label for="name">URL</label><input type="text" id="url" name="menu_url" value=""/>
						</li>
						<li>
							<label for="description">Menu Padre</label>
							<select name="menu_parent" id="menu_parent">
								<option value="0">Sin menu padre</option>
								<xsl:call-template name="menu_item">
									<xsl:with-param name="menus" select="content/menus"/>
								</xsl:call-template>
							</select>
						</li>
					</ul>
				</section>
			</div>
		</section>

	</form>
	
</xsl:template>

<xsl:template name="menu_item">
	<xsl:param name="menus" />
	<xsl:param name="profundidad" select='8' />
		<xsl:for-each select="$menus/menu">
			<option value="{@menu_id}">
				<xsl:if test="@parent!=0">
					<xsl:attribute name="style">padding-left:<xsl:value-of select="$profundidad"/>px</xsl:attribute>
				</xsl:if>
				<xsl:if test="/xml/content/menu/@parent = @id">
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
</xsl:template>

</xsl:stylesheet>