<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<xsl:template name="pagination">
	<!--Url para el paginado a la que se agrega el numero de pagina ej: /noticias/page/-->
	<xsl:param name="url" />
	<!--Pagina que estoy mostrando-->
	<xsl:param name="currentPage" />
	<!--Cantidad de items que se muestran por cada pagina-->
	<xsl:param name="pageSize" />
	<!--Total de items-->
	<xsl:param name="total" />

	<xsl:variable name="pageurl"><!-- 
		 --><xsl:choose><!-- 
			 --><xsl:when test="$url=''"><!-- 
				 --><xsl:choose><!-- 
					 --><xsl:when test="$query != ''"><!-- 
				 		 -->/search/?page=<!-- 
				 	 --></xsl:when><!-- 
				 	 --><xsl:otherwise><!-- 
				 		 -->/list/?page=<!-- 
				 	 --></xsl:otherwise><!-- 
				  --></xsl:choose><!-- 
			  --></xsl:when><!-- 
			  --><xsl:otherwise><xsl:value-of select="$url" />?page=</xsl:otherwise><!-- 
		 --></xsl:choose><!--  
	 --></xsl:variable>
	<xsl:variable name="queryStr"><!-- 
		--><xsl:if test="/xml/content/search/@query != ''">&amp;q=<xsl:value-of select="/xml/content/search/@query" /></xsl:if><!-- 
	 --></xsl:variable>
	<xsl:variable name="totalPages">
		<xsl:choose>
			<xsl:when test="ceiling($total div $pageSize) != '' and number(ceiling($total div $pageSize))">
				<xsl:value-of select="ceiling($total div $pageSize)" />
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:choose>
	<xsl:when test="$currentPage &gt; $totalPages">
		
	</xsl:when>
	<xsl:otherwise>

		<xsl:if test="$totalPages != 1">
		<div class="pagination floatFix">
			<div class="right">
				<ul>
					<xsl:choose>
						<xsl:when test="$currentPage!='' and $currentPage != 1">
							<li><!-- 
								 --><a class="btn" href="{$pageurl}{$currentPage - 1}{$queryStr}">&lt;</a><!-- 
							 --></li>
						</xsl:when>
						<xsl:otherwise>
							<li><!-- 
								 --><span  class="btn gray">&lt;</span><!-- 
							 --></li>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="$currentPage!='' and $currentPage != 1">
							<li><!-- 
								 --><a class="btn" href="{$pageurl}1{$queryStr}">&lt;&lt;</a><!-- 
							 --></li>
						</xsl:when>
						<xsl:otherwise>
							<li><!-- 
								 --><span class="btn gray">&lt;&lt;</span><!-- 
							 --></li>
						</xsl:otherwise>
					</xsl:choose>

						<xsl:call-template name="link.paginas">
							<xsl:with-param name="page" select="$currentPage" />
							<xsl:with-param name="pageurl" select="$pageurl" />
							<xsl:with-param name="queryStr" select="$queryStr" />
							<xsl:with-param name="total" select="$totalPages" />
							<xsl:with-param name="pageSize" select="1" />
							<xsl:with-param name="limit1" select="$currentPage - 4" />
							<xsl:with-param name="limit2" select="$currentPage + 4" />
						</xsl:call-template>

					<xsl:choose>
						<xsl:when test="$currentPage!='' and $currentPage != $totalPages">
							<li><!-- 
								 --><a class="btn arrow" href="{$pageurl}{$totalPages}{$queryStr}">>></a><!-- 
							 --></li><!-- 
							 --><li><!-- 
								 --><a class="btn arrow" href="{$pageurl}{$currentPage + 1}{$queryStr}">></a> <!-- 
							 --></li>
						</xsl:when>
						<xsl:when test="$currentPage='' and $totalPages &gt; 1">
							<li><!-- 
								 --><a class="btn arrow" href="{$pageurl}{$totalPages}{$queryStr}">>></a><!--
							 --></li><!--
							 --><li><!--
								 --><a class="btn arrow" href="{$pageurl}2{$queryStr}">></a><!--
							 --></li>
						</xsl:when>
						<xsl:otherwise>
							<li><!-- 
								 --><span class="btn gray"><xsl:value-of select="queryStr"/>>></span><!--
							 --></li><!--
							 --><li><!--
								 --><span class="btn gray">></span><!--
							 --></li>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>

			<div class="right total-info"><!-- 
				 -->
				 <xsl:variable name="totalshowing">
				 	<xsl:choose>
				 		<xsl:when test="$currentPage = $totalPages"><xsl:value-of select="$total" /></xsl:when>
				 		<xsl:otherwise><xsl:value-of select="$currentPage * $pageSize" /></xsl:otherwise> 
				 	</xsl:choose>
				 </xsl:variable>
				 <xsl:value-of select="($pageSize * ($currentPage - 1))+1"/> a <xsl:value-of select="$totalshowing" /> de <xsl:value-of select="$total" />
				 <!-- 
				 <xsl:choose>
					 <xsl:when test="$currentPage != ''"><xsl:value-of select="$currentPage" /></xsl:when>
					 <xsl:otherwise>1</xsl:otherwise>
				 </xsl:choose>
				 de <xsl:value-of select="$totalPages" />-->
			</div>
		</div>

		</xsl:if>



	</xsl:otherwise>
</xsl:choose>

</xsl:template>



<xsl:template name="link.paginas"><!-- 
	--><xsl:param name="pageurl" /><!-- 
	--><xsl:param name="queryStr" /><!-- 
	--><xsl:param name="page" /><!-- 
	--><xsl:param name="total" /><!-- 
	--><xsl:param name="pageSize" /><!-- 
	--><xsl:param name="limit1" /><!-- 
	--><xsl:param name="limit2" /><!-- 
	--><xsl:if test="$limit1 != ''"><!-- 
		 --><xsl:if test="($page - 1) &gt; 0 and ($page - 1) &gt;= $limit1"><!-- 
			 --><xsl:if test="$limit1 &gt; 0"><!-- 
				 --><li><!-- 
					 --><a class="btn" href="{$pageurl}{$limit1}{$queryStr}"><xsl:value-of select="$limit1" /></a><!-- 
				 --></li><!-- 
			 --></xsl:if><!-- 
			 --><xsl:call-template name="link.paginas">
					<xsl:with-param name="page" select="$page" />
					<xsl:with-param name="pageurl" select="$pageurl" />
					<xsl:with-param name="queryStr" select="$queryStr" />
					<xsl:with-param name="total" select="$total" />
					<xsl:with-param name="limit1" select="$limit1 + 1" />
				</xsl:call-template><!-- 
		 --></xsl:if><!-- 
	 --></xsl:if><!-- 
	 --><xsl:if test="$pageSize!=''"><!-- 
		 --><li><!-- 
			 --><span class="btn selected"><xsl:value-of select="$page" /></span><!-- 
		 --></li><!-- 
	 --></xsl:if><!-- 
	 --><xsl:if test="$limit2 != ''"><!-- 
		 --><xsl:if test="($page + 1) &lt;= $limit2"><!-- 
			 --><xsl:if test="($page + 1) &lt;= $total"><!-- 
				 --><li><!-- 
					 --><a class="btn" href="{$pageurl}{$page + 1}{$queryStr}"><xsl:value-of select="$page + 1" /></a><!-- 
				 --></li><!-- 
			 --></xsl:if><!-- 
			 --><xsl:call-template name="link.paginas">
					<xsl:with-param name="page" select="$page + 1" />
					<xsl:with-param name="pageurl" select="$pageurl" />
					<xsl:with-param name="queryStr" select="$queryStr" />
					<xsl:with-param name="total" select="$total" />
					<xsl:with-param name="limit2" select="$limit2" />
				</xsl:call-template><!-- 
		 --></xsl:if><!-- 
	 --></xsl:if>
</xsl:template>




<xsl:template name="pagination.ajax">
	<xsl:param name="currentPage" />
	<xsl:param name="pageSize" />
	<xsl:param name="total">0</xsl:param>
	<xsl:param name="onclick" />
	<xsl:param name="parent_id" />
	

	
	<xsl:variable name="totalPages">
		<xsl:choose>
			<xsl:when test="ceiling($total div $pageSize) != '' and number(ceiling($total div $pageSize))">
				<xsl:value-of select="ceiling($total div $pageSize)" />
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:choose>
		<xsl:when test="$currentPage &gt; $totalPages"></xsl:when>
		<xsl:otherwise>

			<div class="pagination">
				<div class="right">
					<ul>
						<xsl:choose>
							<xsl:when test="$currentPage!='' and $currentPage != 1">
								<li> 
									 <a class="btn" href="#" onclick="{$onclick}({$parent_id}, {$currentPage - 1});return false;">&lt;</a> 
								 </li>
							</xsl:when>
							<xsl:otherwise>
								<li> 
									 <span  class="btn gray">&lt;</span> 
								 </li>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="($currentPage - 1) &gt; 0"> 
							<li> 
								<a class="btn" href="#" onclick="{$onclick}({$parent_id}, {$currentPage - 1});return false;"><xsl:value-of select="$currentPage - 1" /></a> 
							</li> 
						</xsl:if> 
						<li>
							<span class="selected">
								<xsl:choose>
							 		<xsl:when test="not($currentPage * 0 = 0)">1</xsl:when>
							 		<xsl:otherwise><xsl:value-of select="$currentPage" /></xsl:otherwise>
							 	</xsl:choose>
							</span>
						</li>
						<xsl:if test="($currentPage + 1) &lt;= $totalPages"> 
							<li> 
								<a class="btn" href="#" onclick="{$onclick}({$parent_id}, {$currentPage + 1});return false;"><xsl:value-of select="$currentPage + 1" /></a> 
							</li> 
						</xsl:if> 
						
						<xsl:choose>
							<xsl:when test="$currentPage!='' and $currentPage != $totalPages">
								<li> 
									 <a class="btn arrow" href="#" onclick="{$onclick}({$parent_id}, {$currentPage + 1});return false;">></a>  
								 </li>
							</xsl:when>
							<xsl:when test="$currentPage='' and $totalPages &gt; 1">
								<li>
									 <a class="btn arrow" href="#" onclick="{$onclick}({$parent_id}, 2);return false;">></a>
								 </li>
							</xsl:when>
							<xsl:otherwise>
								<li>
									 <span class="btn gray">></span>
								 </li>
							</xsl:otherwise>
						</xsl:choose>
					
					</ul>
				</div>


				<xsl:if test="$pageSize != ''">
					<div class="right total-info"> 
						 <xsl:variable name="totalshowing">
						 	<xsl:choose>
						 		<xsl:when test="$currentPage = $totalPages"><xsl:value-of select="$total" /></xsl:when>
						 		<xsl:otherwise><xsl:value-of select="$currentPage * $pageSize" /></xsl:otherwise> 
						 	</xsl:choose>
						 </xsl:variable>
						 <xsl:value-of select="($pageSize * ($currentPage - 1))+1"/> a <xsl:value-of select="$totalshowing" /> de <xsl:value-of select="$total" />
					</div>
				</xsl:if>
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>