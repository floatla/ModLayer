<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="call" />
<xsl:param name="item_id" />
<xsl:param name="module" />

<xsl:template match="/xml">
	<xsl:choose>
		<xsl:when test="$call='parent'">
			<xsl:call-template name="parent.list" />
		</xsl:when>
		<xsl:when test="$call='children'">
			<xsl:call-template name="children.list" />
		</xsl:when>
	</xsl:choose>
</xsl:template>


<xsl:template name="parent.list">
	<xsl:if test="/xml/content/item/parent">
		<xsl:variable name="parent" select="/xml/content/item/parent" />
		<div parent_id="{$parent/@id}" class="item state-{$parent/@state} floatFix">
			<button 
				type="button"
				data-role="parent-remove"
				item_id="{$parent/@id}"
				data-module="{$parent/module}"
				class="tooltip fa-icon right" 
				type_id="{$parent/module}"
				title="{$language/item_editor/unlink}"
				onclick="ParentService.unlink({$content/item/@id}, '{$parent/module}')"
				style="padding:10px;border-radius:5px;border:0;">
				<i class="fa fa-eraser"><xsl:comment /></i>
			</button>
			<xsl:choose>
				<xsl:when test="$parent/multimedias/images/image">
					<a href="{$adminroot}{$parent/module}/edit/{$parent/@id}">
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
			<a href="{$adminroot}{$parent/module}/edit/{$parent/@id}">
				<xsl:value-of select="$parent/title"/>
			</a>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template name="children.list">
	<xsl:for-each select="$content/children/collection[@name = $module]">
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
					<div class="wrapper">
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
									<xsl:with-param name="limit">150</xsl:with-param>
								</xsl:call-template>
							</p>
						</xsl:if>
						

						<xsl:if test="../@name = 'clip'">
							<span class="info size">
								<a href="{$adminroot}?m=clip&amp;action=RenderPreview&amp;id={@id}" class="icon play tooltip" style="margin:0 0 -5px 0;" title="{$language/collection/btn_preview}" onclick="sidepanel.load(this);return false;"><xsl:value-of select="$language/collection/btn_preview"/></a>
							</span>	
						</xsl:if>

						<span class="info actions">
							<a class="icon delete tooltip" href="#" onclick="jsChildren.unlinkChild({@id}, '{../@name}');return false;" title="{$language/item_editor/unlink_parent_child}"><xsl:value-of select="$language/item_editor/unlink_parent_child"/></a>
						</span>
					</div>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:for-each>
</xsl:template>

</xsl:stylesheet>