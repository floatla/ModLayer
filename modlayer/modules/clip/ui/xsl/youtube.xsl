<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />
<xsl:param name="term" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.css">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/css/clip.css
		</xsl:with-param>
	</xsl:call-template>
	<script> 
		requirejs(['clip/ui/js/import'], function(clipYT){ 
			clipYT.BindActions();
		});
    </script>
</xsl:variable>


<xsl:template name="content">
	<xsl:attribute name="class">content with-header</xsl:attribute>
	<section class="list-header floatFix">
		
			<xsl:variable name="totalPages">
				<xsl:choose>
					<xsl:when test="ceiling($content/collection/@total div $content/collection/@pageSize) != '' and number(ceiling($content/collection/@total div $content/collection/@pageSize))">
						<xsl:value-of select="ceiling($content/collection/@total div $content/collection/@pageSize)" />
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="pathURL"><!-- 
				 --><xsl:value-of select="$adminroot" /><!-- 
				 --><xsl:value-of select="$modName" /><!-- 
				 -->/youtube/?<!-- 
				 --><xsl:if test="$term != ''">term=<xsl:value-of select="$term" />&amp;</xsl:if><!-- 
			 --></xsl:variable>
			<div class="pagination">
				<div class="right">
					<ul>
						<li>
							<xsl:choose>
								<xsl:when test="$content/collection/@prevPageToken != ''">
									<a class="btn" style="width:auto;padding:0 10px;" href="{$pathURL}page={$content/collection/@currentPage - 1}&amp;pageToken={$content/collection/@prevPageToken}"><xsl:value-of select="$language/youtube/previous" /></a>
								</xsl:when>	
								<xsl:otherwise>
									<span class="btn" style="width:auto;padding:0 10px;color:#999!important;"><xsl:value-of select="$language/youtube/previous" /></span>
								</xsl:otherwise>
							</xsl:choose>
						</li>
						<li>
							<xsl:choose>
								<xsl:when test="$content/collection/@nextPageToken != ''">
									<a class="btn" style="width:auto;padding:0 10px;" href="{$pathURL}page={$content/collection/@currentPage + 1}&amp;pageToken={$content/collection/@nextPageToken}"><xsl:value-of select="$language/youtube/next" /></a>
								</xsl:when>	
								<xsl:otherwise>
									<span class="btn" style="width:auto;padding:0 10px;color:#999!important;"><xsl:value-of select="$language/youtube/next" /></span>
								</xsl:otherwise>
							</xsl:choose>
						</li>
					</ul>
				</div>
				<div class="right total-info"><!-- 
					 -->
					 <xsl:variable name="totalshowing">
					 	<xsl:choose>
					 		<xsl:when test="$content/collection/@currentPage = $totalPages"><xsl:value-of select="$content/collection/@total" /></xsl:when>
					 		<xsl:otherwise><xsl:value-of select="$content/collection/@currentPage * $content/collection/@pageSize" /></xsl:otherwise> 
					 	</xsl:choose>
					 </xsl:variable>
					 <xsl:value-of select="($content/collection/@pageSize * ($content/collection/@currentPage - 1))+1"/> <xsl:value-of select="$language/pagination/total_showing" /> <xsl:value-of select="$totalshowing" /> <xsl:value-of select="$language/pagination/total" /> <xsl:value-of select="$content/collection/@total" />
				</div>
			</div>
	</section>

	<div class="YT-Search">

		<form name="ytsearch" method="get" action="{$adminroot}{$modName}/youtube/search/">
			<input type="text" name="term" value="{$term}" placeholder="Buscar en Youtube" />
		</form>
	</div>

	<section class="collection" id="grid">
		<ul class="simple-list ytvideos">
			<xsl:for-each select="$content/collection/item[id!='']">
				<li item_id="{id}">
					<xsl:if test="imported != 0">
						<xsl:attribute name="class">imported</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="imported = 0">
							<a href="#" data-role="import" data-id="{id}" onclick="return false;" class="btn import right">
								<i class="fas fa-download">&#xa0;</i>&#xa0;
								<xsl:value-of select="$language/youtube/import" />
							</a>
							<!-- clipYT.import('{id}'); -->
						</xsl:when>
						<xsl:otherwise>
							<span class="icon ok right"><xsl:value-of select="$language/youtube/imported" /></span>
						</xsl:otherwise>
					</xsl:choose>
					<img src="{image}" alt="" width="200" style="float:left;margin:0 15px 0 0;"/>
					<!-- <xsl:call-template name="image.bucket">
						<xsl:with-param name="id" select="multimedias/images/image/@image_id" />
						<xsl:with-param name="type" select="multimedias/images/image/@type" />
						<xsl:with-param name="width">80</xsl:with-param>
						<xsl:with-param name="height">80</xsl:with-param>
						<xsl:with-param name="crop">c</xsl:with-param>
						<xsl:with-param name="class">pic rounded</xsl:with-param>
					</xsl:call-template> -->
					<h2>
						<xsl:value-of select="title" />
					</h2>
					<xsl:if test="description != ''">
						<p><xsl:value-of select="description" /></p>
					</xsl:if>
					<a class="external" href="http://youtu.be/{id}" target="_blank">
						Ver en YouTube &#xa0;<i class="fas fa-external-link-alt">&#xa0;</i>
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</section>
	<input type="hidden" name="modToken" value="{$modToken}" />

</xsl:template>
</xsl:stylesheet>