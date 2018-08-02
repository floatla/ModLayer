<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:param name="filter" />
<xsl:param name="type" />
<xsl:param name="id" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/css/cache.css
		</xsl:with-param>
	</xsl:call-template>

	<script> 
		var jsTree = {};
		requirejs(['cache/ui/js/cache'], function(Tree){ 
			jsTree = Tree;
			Tree.BindActions();
		});
    </script>
	<!-- <xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/js/cache.js
		</xsl:with-param>
	</xsl:call-template> -->
</xsl:variable>


<xsl:template name="content">

	<xsl:if test="$filter != ''">
		<span class="" style="display:block;margin:0 10px 15px 0;">
			<a href="{$adminroot}{$modName}/list" class="btn"><i class="icon back">&#xa0;</i>Volver</a>
		</span>
	</xsl:if>

	
	<section id="grid">
		<xsl:if test="not(content/cache/item)">
			<div class="empty-list rounded">
    			La carpeta no tiene ningún archivo de caché.<br/>
    		</div>
		</xsl:if>
		<ul class="simple-list">
			<xsl:for-each select="content/cache/item">
				<xsl:choose>
					<xsl:when test="@type = 'folder'">
						<li folder="{@name}">
							
									
							<span class="right">
								<a href="#" data-role="empty-folder" data-name="{@name}" onclick="return false;" class="icon delete tooltip" title="Vaciar">Vaciar</a>
								<!-- cache.deleteFolder('{@name}'); -->
							</span>
							<img src="{$adminPath}/ui/imgs/icons/folder.png" alt="folder" style="float:left;margin:5px 10px 0 0;"/>
							<h3>
								<a href="{$adminroot}{$modName}/list/{@name}">
									<xsl:value-of select="@name" />
								</a>
							</h3>
							<div class="footer">
								<span>
									<xsl:attribute name="title"><!-- 
										 --><xsl:for-each select="files/*"><!-- 
											 --><xsl:if test="text() != '.' and text() != '..'"><!-- 
												 --><xsl:value-of select="." disable-output-escaping="" />.
<!-- 
											 --></xsl:if><!-- 
										 --></xsl:for-each><!-- 
									 --></xsl:attribute>
									Total archivos: <xsl:value-of select="count(files/*) - 2"  />
								</span>
							</div>
								
						</li>
					</xsl:when>
					<xsl:otherwise>
						<li name="{@name}">
							<span class="right">
								<a href="#" data-role="delete-file" data-name="{@name}" data-filter="{$filter}" onclick="return false;" class="icon delete tooltip" title="Eliminar">Eliminar</a>
								<!-- cache.deleteFile('{@name}', '{$filter}'); -->
							</span>
							<img src="{$adminPath}/ui/imgs/icons/file.png" alt="folder" style="float:left;margin:5px 10px 0 0;"/>
							<h3>
								<xsl:value-of select="@name" />
							</h3>
							<div class="footer">
								<span>
									Expira: <!-- <xsl:value-of select="@expires" /> -->
									<abbr class="timeago" title="{@expires}"><xsl:value-of select="@expires"/></abbr>
								</span>
							</div>
						</li>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</ul>
	</section>
	<input type="hidden" name="modToken" value="{$modToken}" />
</xsl:template>




</xsl:stylesheet>