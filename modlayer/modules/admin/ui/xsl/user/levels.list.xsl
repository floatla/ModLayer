<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/js/users.js
			<xsl:value-of select="$adminPath"/>/ui/js/module.list.js
		</xsl:with-param>
	</xsl:call-template>
</xsl:variable>
<xsl:param name="page" />
<xsl:param name="query" />

<xsl:template name="content">

	<section class="list-header floatFix">
		<xsl:call-template name="pagination.box" />
	</section>

	<section class="collection" id="grid">
		<ul class="simple-list">
			<xsl:for-each select="content/levels/level">
				<li class="floatFix" >
					<!-- <xsl:if test="@level_id != 1">
						<div class="right">
							<a href="{$adminroot}{$modulename}/users/levels/edit/{@level_id}"  class="icon edit tooltip" title="{$language/user/levels/list/btn_edit}" data-original-title="Editar"><xsl:value-of select="$language/user/levels/list/btn_edit"/></a>
							<a href="{$adminroot}{$modulename}/users/levels/delete/{@level_id}" class="icon delete tooltip" title="{$language/user/levels/list/btn_delete}"><xsl:value-of select="$language/user/levels/list/btn_delete"/></a>
						</div>
					</xsl:if> -->
					<h2><xsl:value-of select="name" /></h2>
					<p><xsl:value-of select="$language/user/levels/list/level"/>: <xsl:value-of select="@level_id" /></p>
				</li>
			</xsl:for-each>
		</ul>
	</section>
</xsl:template>
</xsl:stylesheet>