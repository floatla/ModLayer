<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra">
	<script>
		var jsUser = {};
		requirejs(['admin/ui/js/app/controller/user'], function(User){ 
			jsUser = User;
			jsUser.BindListActions();
		});
	</script>
</xsl:variable>

<xsl:param name="page" />
<xsl:param name="query" />

<xsl:template name="content">
	<section class="list-header floatFix">
		<xsl:call-template name="pagination.box" />
	</section>

	<section class="collection" id="grid">
		<xsl:if test="$query != ''">
			<div class="alert" style="margin:20px 0;">
				<xsl:value-of select="$language/user/list/messages/showing_query_results"/>&#xa0;<strong><em>"<xsl:value-of select="$query"/>"</em></strong>
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
						(<xsl:value-of select="$found" />&#xa0;<xsl:value-of select="$language/user/list/messages/element_found"/>)
					</xsl:when>
					<xsl:otherwise>
						(<xsl:value-of select="$found" />&#xa0;<xsl:value-of select="$language/user/list/messages/elements_found"/>)
					</xsl:otherwise>
				</xsl:choose>
			</div>
	    </xsl:if>
		<!-- <xsl:if test="$query != ''">
			<div class="alert">
				<button class="close" data-dismiss="alert">×</button>
				Mostrando resultados  
				para la búsqueda <strong><em>"<xsl:value-of select="$query"/>"</em></strong>
				<xsl:variable name="found">
					<xsl:choose>
						<xsl:when test="/xml/content/collection/@total !=''">
							<xsl:value-of select="/xml/content/collection/@total" />
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				(<xsl:value-of select="$found" /> usuarios encontrados)
			</div>
	    </xsl:if> -->

		<ul class="simple-list">
			<xsl:for-each select="content/collection/user">
				<li class="floatFix" id="user_{@user_id}" item_id="{@user_id}">
					<span class="right">
						<a class="icon edit tooltip" href="{$adminroot}users/edit/{@user_id}/" title="{$language/user/list/btn_edit}"><xsl:value-of select="$language/user/list/btn_edit"/></a>
						<xsl:if test="username!='admin'">
							<a class="icon delete tooltip" href="#" onclick="jsUser.Remove({@user_id});return false;" title="{$language/user/list/btn_delete}"><xsl:value-of select="$language/user/list/btn_delete"/></a>
						</xsl:if>
					</span>
					<h2>
						<a href="{$adminroot}users/edit/{@user_id}/">
							<xsl:value-of select="username" />
						</a>
					</h2>
					<span>user_id: <xsl:value-of select="@user_id" /></span><br/>
					<span class="metadata">
						<xsl:value-of select="name" />&#xa0;<xsl:value-of select="lastname" /> | <xsl:value-of select="email" />
					</span>
					<div class="right" style="text-align:right;">
						<xsl:choose>
							<xsl:when test="@last_login = '0000-00-00 00:00:00'">
								<p style="margin:0;"><xsl:value-of select="$language/user/list/no_previous_logins"/></p>
							</xsl:when>
							<xsl:otherwise>
								<p style="margin:0;">
									<xsl:value-of select="$language/user/list/last_login"/>:
									<abbr class="timeago" title="{@last_login}"><xsl:value-of select="@last_login"/></abbr>
								</p>
							</xsl:otherwise>
						</xsl:choose>
						<p style="margin:0;"><xsl:value-of select="$language/user/list/access_level"/>: <xsl:value-of select="@access" /></p>
					</div>
				</li>
			</xsl:for-each>
		</ul>
	</section>
</xsl:template>
</xsl:stylesheet>