<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="htmlHeadExtra" />
<xsl:param name="adminroot" />
<xsl:param name="categories" />
<xsl:param name="startdate" />
<xsl:param name="enddate" />
<xsl:param name="state" />

<xsl:variable name="config" select="/xml/configuration" />
<xsl:variable name="content" select="/xml/content" />
<xsl:variable name="context" select="/xml/context" />
<xsl:variable name="language" select="$config/mod_language|$config/language" />
<xsl:variable name="release" select="$config/system/release" />

<xsl:variable name="modulename" select="$config/module/@name" />
<xsl:variable name="appUrl"><!-- 
	 --><xsl:choose><!-- 
		 --><xsl:when test="$config/system/domain/@subdir != ''"><!-- 
			 --><xsl:value-of select="$config/system/domain" /><xsl:value-of select="$config/system/domain/@subdir" />/<!-- 
		 --></xsl:when><!-- 
		 --><xsl:otherwise><!-- 
			 --><xsl:value-of select="$config/system/domain" /><!-- 
		 --></xsl:otherwise><!-- 
	 --></xsl:choose><!-- 
 --></xsl:variable>

<!-- 
	Template: htmlHead
	Use: Is the <head> tag for all Admin pages 
	Called: In every page of admin
-->
<xsl:template name="htmlHead">
	<meta charset="UTF-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<title><!--  
		--><xsl:if test="$config/navigation/item[@name=$modName]/@label != ''"><!--
			--><xsl:value-of select="$config/navigation/item[@name=$modName]/@label"  /> | <!--
		--></xsl:if><!--
		-->Admin: <xsl:value-of select="$config/system/applicationID" /><!--
	--></title>
	<!-- Modlayer Favicon -->
	<link rel="apple-touch-icon" sizes="180x180" href="{$adminPath}/ui/favicons/apple-touch-icon.png" />
	<link rel="icon" type="image/png" href="{$adminPath}/ui/favicons/favicon-32x32.png" sizes="32x32" />
	<link rel="icon" type="image/png" href="{$adminPath}/ui/favicons/favicon-16x16.png" sizes="16x16" />
	<link rel="manifest" href="{$adminPath}/ui/favicons/manifest.json" />
	<link rel="mask-icon" href="{$adminPath}/ui/favicons/safari-pinned-tab.svg" color="#5bbad5" />
	<link rel="shortcut icon" href="{$adminPath}/ui/favicons/favicon.ico" />
	<meta name="msapplication-config" content="{$adminPath}/ui/favicons/browserconfig.xml" />
	<meta name="theme-color" content="#ffffff" />
	<!-- Modlayer Favicon -->

	<script type="text/javascript"><!-- 
	 	$.timeago.settings.strings
		 -->var timeagoStr = {<!-- 
			 --><xsl:for-each select="$language/timeago/*"><!-- 
				 --><xsl:value-of select="name()"/> : "<xsl:value-of select="."/>"<!-- 
				 --><xsl:if test="position() != last()">, </xsl:if><!-- 
			 --></xsl:for-each><!-- 
		 -->}<!-- 
	 --></script>
	<xsl:call-template name="require.script" />
	<xsl:apply-templates select="$config/admin/assets/*" />
	<script type="text/javascript"><!-- 
		 -->adminmod = '<xsl:value-of select="$adminPath"/>';<!-- 
		 -->adminpath = '<xsl:value-of select="$adminroot"/>';<!-- 
		 -->module = '<xsl:value-of select="$modName"/>';<!-- 
	 --></script>
	<xsl:copy-of select="$htmlHeadExtra" />

	<!-- IE 6-8 support for html5 -->
	<xsl:comment><!-- 
	-->[if lt IE 9]&gt;
      	 &lt;script src="http://html5shim.googlecode.com/svn/trunk/html5.js"&gt;&lt;/script&gt;
    &lt;![endif]<!-- 
	 --></xsl:comment>
	 
</xsl:template>

<xsl:template name="require.script">
	<script><!-- 
          -->var require = { baseUrl: "<xsl:value-of select="substring-before($adminPath, '/admin')" />"};<!-- 
     --></script>
	<script data-main="{$adminPath}/ui/js/common.js" src="{$adminPath}/ui/js/lib/require.js">&#xa0;</script>
</xsl:template>

<xsl:template match="css">
	<xsl:variable name="cssfile"><xsl:apply-templates mode="replaceTags"/></xsl:variable>
	<link rel="stylesheet" type="text/css" href="{$cssfile}" />
</xsl:template>
<xsl:template match="script">
	<xsl:variable name="scriptfile"><xsl:apply-templates mode="replaceTags"/></xsl:variable>
	<script type="text/javascript" src="{$scriptfile}">&#xa0;</script>
</xsl:template>

<xsl:template name="jquery">
	<xsl:variable name="scriptfile"><xsl:apply-templates select="/xml/configuration/admin/ui/script[@name='jquery']" mode="replaceTags"/></xsl:variable>
	<script type="text/javascript" src="{$scriptfile}">&#xa0;</script>
</xsl:template>

<xsl:template name="css-backend">
	<xsl:for-each select="/xml/configuration//css[@name='backend']">
		<xsl:variable name="file"><xsl:apply-templates select="." mode="replaceTags"/></xsl:variable>
		<link rel="stylesheet" type="text/css" href="{$file}" />
	</xsl:for-each>
</xsl:template>

<xsl:template match="adminpath" mode="replaceTags">
	<xsl:value-of select="$adminPath" />
</xsl:template>
<xsl:template match="modpath" mode="replaceTags">
	<xsl:value-of select="$modPath" />
</xsl:template>

<xsl:template name="inline.js">
	<xsl:param name="string" />
	<xsl:param name="localstr" select="normalize-space($string)" />
	<xsl:choose>
		<xsl:when test="contains($localstr, '|')">
			<script type="text/javascript" src="{substring-before($localstr, '|')}">
				<xsl:call-template name="inline.attrs">
					<xsl:with-param name="str" select="substring-after($localstr, '|')"/>
				</xsl:call-template><!-- 
				 -->&#xa0;<!-- 
			 --></script>
		</xsl:when>
		<xsl:when test="$localstr != ''">
			<script type="text/javascript" src="{$localstr}">&#xa0;</script>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="inline.css">
	<xsl:param name="string" />
	<xsl:param name="localstr" select="normalize-space($string)" />
	<xsl:if test="$localstr != ''">
		<xsl:choose>
			<xsl:when test="contains($localstr, '|')">
				<link rel="stylesheet" type="text/css" href="{substring-before($localstr, '|')}">
					<xsl:call-template name="inline.attrs">
						<xsl:with-param name="str" select="substring-after($localstr, '|')"/>
					</xsl:call-template>
				</link>
			</xsl:when>
			<xsl:when test="$localstr != ''">
				<link rel="stylesheet" type="text/css" href="{$localstr}" />
			</xsl:when>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="inline.attrs">
	<xsl:param name="str" />
	<xsl:choose>
		<xsl:when test="contains($str, '|')">
			<xsl:attribute name="{substring-before($str,'=')}">
				<xsl:value-of select="substring-after(substring-before($str, '|'),'=')" />
			</xsl:attribute>
			<xsl:call-template name="inline.attrs">
				<xsl:with-param name="str" select="substring-after($str, '|')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="{substring-before($str,'=')}">
				<xsl:value-of select="substring-after($str,'=')" />
			</xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="include.js">
	<xsl:param name="url" />
	<xsl:choose>
		<xsl:when test="contains($url, '&#xA;')">
			<xsl:call-template name="inline.js">
				<xsl:with-param name="string" select="substring-before($url, '&#xA;')" />
			</xsl:call-template>
			<xsl:call-template name="include.js">
				<xsl:with-param name="url" select="substring-after($url, '&#xA;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="inline.js">
				<xsl:with-param name="string" select="$url" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="include.css">
	<xsl:param name="url" />
	<xsl:choose>
		<xsl:when test="contains($url, '&#xA;')">
			<xsl:call-template name="inline.css">
				<xsl:with-param name="string" select="substring-before($url, '&#xA;')" />
			</xsl:call-template>
			<xsl:call-template name="include.css">
				<xsl:with-param name="url" select="substring-after($url, '&#xA;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="inline.css">
				<xsl:with-param name="string" select="$url" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="modal.scripts">
	<script type="text/javascript" src="{$adminPath}/ui/js/jquery.form.min.js">&#xa0;</script>
	<script type="text/javascript" src="{$adminPath}/ui/js/jquery-ui.js">&#xa0;</script>
	<script type="text/javascript" src="{$adminPath}/ui/js/jquery.tooltipster.min.js">&#xa0;</script>
	<script type="text/javascript" src="{$adminPath}/ui/js/backend.js">&#xa0;</script>
	<script type="text/javascript" src="{$adminPath}/ui/js/backend.keyboard.js">&#xa0;</script>
	<script type="text/javascript" src="{$adminPath}/ui/js/jquery.cookie.js">&#xa0;</script>
	<script type="text/javascript" src="{$adminPath}/ui/js/module.language.js">&#xa0;</script>
	<script type="text/javascript" src="{$adminPath}/ui/js/xml2json.js">&#xa0;</script>
</xsl:template>


<!-- 
	lang-eval se usa para evaluar expresiones de xPath en configuraciones, para archivos de traduccion 
-->
<xsl:template name="lang-eval">
		<xsl:param name="pPath" />
		<xsl:param name="pContext" select="$language"/>
		<xsl:param name="pExp" select="$pPath" />
		<xsl:choose>
			<xsl:when test="string-length($pPath) > 0">
				<xsl:variable name="vPath1" select="substring($pPath,2)"/>
				<xsl:variable name="vPath">
					<xsl:choose>
						<xsl:when test="contains($vPath1, '}')">
							<xsl:value-of select="substring-before($vPath1, '}')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$vPath1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="vNameTest">
					<xsl:choose>
						<xsl:when test="contains($vPath, '$language/')">
							<xsl:value-of select="substring-before(substring-after($vPath, '$language/'), '/')"/>
						</xsl:when>
						<xsl:when test="not(contains($vPath, '/'))">
							<xsl:value-of select="$vPath"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-before($vPath, '/')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="lang-eval">
					<xsl:with-param name="pPath" select="substring-after($vPath, $vNameTest)"/>
					<xsl:with-param name="pContext" select="$pContext/*[name()=$vNameTest]"/>
					<xsl:with-param name="pExp" select="$pExp"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not($pContext)">
						<xsl:choose>
							<xsl:when test="contains($pExp, '$language')">
								<u style="color:red;">Language translation undefined for text <i><xsl:value-of select="$pExp"/></i></u>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$pExp" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$pContext"/>		
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>




<xsl:template name="fecha.formato.numerico">
	<xsl:param name="fecha" />
	<xsl:variable name="dia" select="substring($fecha, 9, 2)" />
	<xsl:variable name="mes" select="substring($fecha, 6, 2)" />
	<xsl:variable name="anio" select="substring($fecha, 1, 4)" />
	<xsl:value-of select="$dia" />.<xsl:value-of select="$mes" />.<xsl:value-of select="$anio" />
</xsl:template>


<xsl:template name="fecha.formato.mensaje">
	<xsl:param name="fecha" />
	<xsl:variable name="dia" select="substring($fecha, 9, 2)" />
	<xsl:variable name="mes" select="substring($fecha, 6, 2)" />
	<xsl:variable name="anio" select="substring($fecha, 1, 4)" />
	<xsl:variable name="min" select="substring($fecha, 12, 2)" />
	<xsl:variable name="seg" select="substring($fecha, 15, 2)" />
	<xsl:value-of select="$dia" />.<xsl:value-of select="$mes" />.<xsl:value-of select="$anio" />&#xa0;<xsl:value-of select="$min" />:<xsl:value-of select="$seg" /> hs
</xsl:template>

<xsl:template name="date.time">
	<xsl:param name="fecha" />
	<xsl:variable name="dia" select="substring($fecha, 9, 2)" />
	<xsl:variable name="mes" select="substring($fecha, 6, 2)" />
	<xsl:variable name="anio" select="substring($fecha, 1, 4)" />
	<xsl:variable name="min" select="substring($fecha, 12, 2)" />
	<xsl:variable name="seg" select="substring($fecha, 15, 2)" />
	<xsl:value-of select="$dia" />/<xsl:value-of select="$mes" />/<xsl:value-of select="$anio" />&#xa0;<xsl:value-of select="$min" />:<xsl:value-of select="$seg" /> hs
</xsl:template>

<xsl:template name="combo.item.incremental">
	<xsl:param name="start"/>
	<xsl:param name="end"/>
	<xsl:param name="selected"/>
	<xsl:choose>
		<xsl:when test="number($start) &lt;= number($end)">
			<option value="{$start}">
				<xsl:if test="$selected = $start">
					<xsl:attribute name="selected">selected</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="$start" />
			</option>
			<xsl:call-template name="combo.item.incremental">
				<xsl:with-param name="end" select="$end" />
				<xsl:with-param name="selected" select="$selected" />
				<xsl:with-param name="start"><xsl:value-of select="number($start) + 1" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>




<xsl:template name="pagination.box">
	
	
			<xsl:call-template name="pagination">
				<xsl:with-param name="total" select="content/collection/@total" />
				<xsl:with-param name="display" select="content/collection/@pageSize" />
				<xsl:with-param name="currentPage" select="content/collection/@currentPage" />
				<xsl:with-param name="url"><!--
				--><xsl:choose>
						<xsl:when test="$state = '0'"><!--
							-->?state=0<!--
					--></xsl:when>
						<xsl:when test="$state = '1'"><!--
							-->?state=1<!--
					--></xsl:when>
					<xsl:when test="$state = '3'"><!--
							-->?state=3<!--
					--></xsl:when>
						<xsl:when test="$state = '4'"><!--
							-->?state=4<!--
					--></xsl:when>
					<xsl:when test="$state = '5'"><!--
							-->?state=5<!--
					--></xsl:when>
					</xsl:choose><!--
				--></xsl:with-param>
			</xsl:call-template>



</xsl:template>


<xsl:template name="pagination.ajax">
	<xsl:param name="currentPage" />
	<xsl:param name="perPage" />
	<xsl:param name="total">0</xsl:param>
	<xsl:param name="onclick" />
	<xsl:param name="parent_id" />
	<xsl:param name="module" />

	<xsl:variable name="totalPages">
		<xsl:choose>
			<xsl:when test="ceiling($total div $perPage) != '' and number(ceiling($total div $perPage))">
				<xsl:value-of select="ceiling($total div $perPage)" />
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
									 <a href="#" class="btn" onclick="{$onclick}({$parent_id}, {$currentPage - 1}, '{$module}')">&lt;</a> 
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
								<a class="btn" href="#" onclick="{$onclick}({$parent_id}, {$currentPage - 1}, '{$module}')"><xsl:value-of select="$currentPage - 1" /></a> 
							</li> 
						</xsl:if> 
						<li>
							<span class="btn selected">
								<xsl:choose>
							 		<xsl:when test="not($currentPage * 0 = 0)">1</xsl:when>
							 		<xsl:otherwise><xsl:value-of select="$currentPage" /></xsl:otherwise>
							 	</xsl:choose>
							</span>
						</li>
						<xsl:if test="($currentPage + 1) &lt;= $totalPages"> 
							<li> 
								<a class="btn" href="#" onclick="{$onclick}({$parent_id}, {$currentPage + 1}, '{$module}')"><xsl:value-of select="$currentPage + 1" /></a> 
							</li> 
						</xsl:if> 
						
						<xsl:choose>
							<xsl:when test="$currentPage!='' and $currentPage != $totalPages">
								<li> 
									 <a class="btn arrow" href="#" onclick="{$onclick}({$parent_id}, {$currentPage + 1}, '{$module}')">></a>  
								 </li>
							</xsl:when>
							<xsl:when test="$currentPage='' and $totalPages &gt; 1">
								<li>
									 <a class="btn arrow" href="#" onclick="{$onclick}({$parent_id}, 2, '{$module}')">></a>
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


				<xsl:if test="$perPage != ''">
					<div class="right total-info"> 
						 <xsl:variable name="totalshowing">
						 	<xsl:choose>
						 		<xsl:when test="$currentPage = $totalPages"><xsl:value-of select="$total" /></xsl:when>
						 		<xsl:otherwise><xsl:value-of select="$currentPage * $perPage" /></xsl:otherwise> 
						 	</xsl:choose>
						 </xsl:variable>
						 <xsl:value-of select="($perPage * ($currentPage - 1))+1"/><xsl:value-of select="$language/pagination/total_showing" /><xsl:value-of select="$totalshowing" /><xsl:value-of select="$language/pagination/total" /><xsl:value-of select="$total" />
					</div>
				</xsl:if>
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="pagination">
	<!--Url para el paginado a la que se agrega el número de página ej: /noticias/page/-->
	<xsl:param name="url" />
	<!--Página que estoy mostrando-->
	<xsl:param name="currentPage" />
	<!--Cantidad de items que se muestran por cada página-->
	<xsl:param name="display" />
	<!--Total de items-->
	<xsl:param name="total">0</xsl:param>

	<xsl:variable name="pageurl"><!-- 
		 --><xsl:choose>
			<xsl:when test="$url=''">
				<xsl:choose>
					<xsl:when test="$query != ''"><!-- 
				 		 --><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/search/?page=<!-- 
				 	 --></xsl:when>
				 	<xsl:otherwise><!-- 
				 		 --><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/list/?page=<!-- 
				 	 --></xsl:otherwise>
				 </xsl:choose>
			 </xsl:when>
			 <xsl:otherwise><xsl:value-of select="$url" />&amp;page=</xsl:otherwise>
		</xsl:choose><!-- 
	 --></xsl:variable>
	<xsl:variable name="queryStr">
		<xsl:for-each select="/xml/context/get_params/*[not(name()='page')]"><!-- 
			 -->&amp;<xsl:value-of select="name()" />=<xsl:value-of select="." /><!-- 
		 --></xsl:for-each>
		<!-- <xsl:if test="$query != ''">&amp;q=<xsl:value-of select="$query" /></xsl:if>
		<xsl:if test="$categories != ''">&amp;categories=<xsl:value-of select="$categories" /></xsl:if>
		<xsl:if test="$startdate != ''">&amp;startdate=<xsl:value-of select="$startdate" /></xsl:if>
		<xsl:if test="$enddate != ''">&amp;enddate=<xsl:value-of select="$enddate" /></xsl:if>
		<xsl:if test="$state != ''">&amp;state=<xsl:value-of select="$state" /></xsl:if> -->
	</xsl:variable>
	<xsl:variable name="totalPages">
		<xsl:choose>
			<xsl:when test="ceiling($total div $display) != '' and number(ceiling($total div $display))">
				<xsl:value-of select="ceiling($total div $display)" />
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


<xsl:choose>
	<xsl:when test="$currentPage &gt; $totalPages">
		
	</xsl:when>
	<xsl:otherwise>

		<!-- <xsl:if test="$totalPages != 1"> -->
		<div class="pagination">
			<div class="right">
				<ul>
					<xsl:choose>
						<xsl:when test="$currentPage!='' and $currentPage != 1">
							<li><!-- 
								 --><a class="btn first arrow" href="{$pageurl}{$currentPage - 1}{$queryStr}">&lt;</a><!-- 
							 --></li>
						</xsl:when>
						<xsl:otherwise>
							<li><!-- 
								 --><span class="btn gray first arrow">&lt;</span><!-- 
							 --></li>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="$currentPage!='' and $currentPage != 1">
							<li><!-- 
								 --><a class="btn arrow" href="{$pageurl}1{$queryStr}">&lt;&lt;</a><!-- 
							 --></li>
						</xsl:when>
						<xsl:otherwise>
							<li><!-- 
								 --><span class="btn gray arrow">&lt;&lt;</span><!-- 
							 --></li>
						</xsl:otherwise>
					</xsl:choose>

						<xsl:call-template name="link.paginas">
							<xsl:with-param name="pagina" select="$currentPage" />
							<xsl:with-param name="pageurl" select="$pageurl" />
							<xsl:with-param name="queryStr" select="$queryStr" />
							<xsl:with-param name="cantidad" select="$totalPages" />
							<xsl:with-param name="display" select="1" />
							<xsl:with-param name="limit1" select="$currentPage - 4" />
							<xsl:with-param name="limit2" select="$currentPage + 4" />
						</xsl:call-template>

					<xsl:choose>
						<xsl:when test="$currentPage!='' and $currentPage != $totalPages">
							<li><!-- 
								 --><a class="btn arrow" href="{$pageurl}{$totalPages}{$queryStr}">>></a><!-- 
							 --></li><!-- 
							 --><li><!-- 
								 --><a class="btn arrow last" href="{$pageurl}{$currentPage + 1}{$queryStr}">></a> <!-- 
							 --></li>
						</xsl:when>
						<xsl:when test="$currentPage='' and $totalPages &gt; 1">
							<li><!-- 
								 --><a class="btn arrow" href="{$pageurl}{$totalPages}{$queryStr}">>></a><!--
							 --></li><!--
							 --><li><!--
								 --><a class="btn arrow last" href="{$pageurl}2{$queryStr}">></a><!--
							 --></li>
						</xsl:when>
						<xsl:otherwise>
							<li><!-- 
								 --><span class="btn gray"><xsl:value-of select="queryStr"/>>></span><!--
							 --></li><!--
							 --><li><!--
								 --><span class="btn gray last">></span><!--
							 --></li>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>


			<xsl:if test="$display != ''">
				<div class="right total-info"><!-- 
					 -->
					 <xsl:variable name="totalshowing">
					 	<xsl:choose>
					 		<xsl:when test="$currentPage = $totalPages"><xsl:value-of select="$total" /></xsl:when>
					 		<xsl:otherwise><xsl:value-of select="$currentPage * $display" /></xsl:otherwise> 
					 	</xsl:choose>
					 </xsl:variable>
					 <xsl:value-of select="($display * ($currentPage - 1))+1"/><xsl:value-of select="$language/pagination/total_showing" /><xsl:value-of select="$totalshowing" /><xsl:value-of select="$language/pagination/total" /><xsl:value-of select="$total" />
					 <!-- 
					 <xsl:choose>
						 <xsl:when test="$currentPage != ''"><xsl:value-of select="$currentPage" /></xsl:when>
						 <xsl:otherwise>1</xsl:otherwise>
					 </xsl:choose>
					 de <xsl:value-of select="$totalPages" />-->
				</div>
			</xsl:if>
		</div>

		<!-- </xsl:if> -->



	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template name="link.paginas"><!-- 
	--><xsl:param name="pageurl" /><!-- 
	--><xsl:param name="queryStr" /><!-- 
	--><xsl:param name="pagina" /><!-- 
	--><xsl:param name="cantidad" /><!-- 
	--><xsl:param name="display" /><!-- 
	--><xsl:param name="limit1" /><!-- 
	--><xsl:param name="limit2" /><!-- 
	--><xsl:if test="$limit1 != ''"><!-- 
		 --><xsl:if test="($pagina - 1) &gt; 0 and ($pagina - 1) &gt;= $limit1"><!-- 
			 --><xsl:if test="$limit1 &gt; 0"><!-- 
				 --><li><!-- 
					 --><a class="btn" href="{$pageurl}{$limit1}{$queryStr}"><xsl:value-of select="$limit1" /></a><!-- 
				 --></li><!-- 
			 --></xsl:if><!-- 
			 --><xsl:call-template name="link.paginas">
					<xsl:with-param name="pagina" select="$pagina" />
					<xsl:with-param name="pageurl" select="$pageurl" />
					<xsl:with-param name="queryStr" select="$queryStr" />
					<xsl:with-param name="cantidad" select="$cantidad" />
					<xsl:with-param name="limit1" select="$limit1 + 1" />
				</xsl:call-template><!-- 
		 --></xsl:if><!-- 
	 --></xsl:if><!-- 
	 --><xsl:if test="$display != ''"><!-- 
		 --><li><!-- 
			 --><span class="btn selected">
			 		<xsl:choose>
			 			<xsl:when test="not($pagina * 0 = 0)">1</xsl:when>
			 			<xsl:otherwise><xsl:value-of select="$pagina" /></xsl:otherwise>
			 		</xsl:choose>
			 	</span><!-- 
		 --></li><!-- 
	 --></xsl:if><!-- 
	 --><xsl:if test="$limit2 != ''"><!-- 
		 --><xsl:if test="($pagina + 1) &lt;= $limit2"><!-- 
			 --><xsl:if test="($pagina + 1) &lt;= $cantidad"><!-- 
				 --><li><!-- 
					 --><a class="btn" href="{$pageurl}{$pagina + 1}{$queryStr}"><xsl:value-of select="$pagina + 1" /></a><!-- 
				 --></li><!-- 
			 --></xsl:if><!-- 
			 --><xsl:call-template name="link.paginas">
					<xsl:with-param name="pagina" select="$pagina + 1" />
					<xsl:with-param name="pageurl" select="$pageurl" />
					<xsl:with-param name="queryStr" select="$queryStr" />
					<xsl:with-param name="cantidad" select="$cantidad" />
					<xsl:with-param name="limit2" select="$limit2" />
				</xsl:call-template><!-- 
		 --></xsl:if><!-- 
	 --></xsl:if>
</xsl:template>

<xsl:template name="limit.string"><!-- 
 --><xsl:param name="string" /><!-- 
 --><xsl:param name="limit" /><!-- 
 --><xsl:if test="$string!=''"><!-- 
	 --><xsl:choose><!-- 
		 --><xsl:when test="string-length($string)&gt;$limit"><!-- 
			 --><xsl:call-template name="strip.tags"><!-- 
				 --><xsl:with-param name="string" select="substring($string,0,$limit)" /><!-- 
			 --></xsl:call-template> [...]<!--
			<xsl:value-of select="substring($string,0,$limit)" />...
	 --></xsl:when><!-- 
		 --><xsl:otherwise><!-- 
			 --><xsl:call-template name="strip.tags"><!-- 
				 --><xsl:with-param name="string" select="$string" /><!-- 
			 --></xsl:call-template><!-- 
		 --></xsl:otherwise><!-- 
	 --></xsl:choose><!-- 
 --></xsl:if><!-- 
 --></xsl:template>


<xsl:template name="strip.tags"><!-- 
	 --><xsl:param name="string" /><!-- 
	 --><xsl:variable name="string0"><!-- 
		 --><xsl:value-of select="translate($string, '&#13;', ' ')" /><!-- 
	 --></xsl:variable><!-- 
	 --><xsl:variable name="localStr"><!-- 
		 --><xsl:value-of select="translate($string0, '&#xa;', '')" /><!-- 
	 --></xsl:variable><!-- 
	 --><xsl:choose><!-- 
		 --><xsl:when test="contains($localStr, '&lt;')"><!-- 
			 --><xsl:value-of select="substring-before($localStr, '&lt;')" /><!-- 
			 --><xsl:call-template name="strip.tags"><!-- 
				 --><xsl:with-param name="string" select="substring-after($localStr, '&gt;')" /><!-- 
			 --></xsl:call-template><!-- 
		 --></xsl:when><!-- 
		 --><xsl:when test="contains($localStr, '&gt;')"><!-- 
			 --><xsl:value-of select="substring-before($localStr, '&gt;')" /><!-- 
			 --><xsl:call-template name="strip.tags"><!-- 
				 --><xsl:with-param name="string" select="substring-after($localStr, '&gt;')" /><!-- 
			 --></xsl:call-template><!-- 
		 --></xsl:when><!-- 
		 --><xsl:otherwise><!-- 
			 --><xsl:value-of select="$localStr" disable-output-escaping="yes" /><!-- 
		 --></xsl:otherwise><!-- 
	 --></xsl:choose><!-- 
 --></xsl:template>

<xsl:template name="clear.break">
	<xsl:param name="string" />
	<xsl:variable name="string0">
		<xsl:value-of select="translate($string, '&#13;', ' ')" />
	</xsl:variable>
	<xsl:variable name="string1">
		<xsl:value-of select="translate($string0, '&#xa;', '')" />
	</xsl:variable>
	<xsl:value-of select="$string1" disable-output-escaping="yes"/>
</xsl:template>








<xsl:template name="image.src">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:value-of select="$config/system/images_dir" />/source/<xsl:value-of select="substring($id, string-length($id), 1)"/>/<xsl:value-of select="$id"/>.<xsl:value-of select="$type" />
</xsl:template>

<xsl:template name="image.original.src">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:value-of select="$config/system/images_dir" />/source/<xsl:value-of select="substring($id, string-length($id), 1)"/>/<xsl:value-of select="$id"/>.<xsl:value-of select="$type" />
</xsl:template>

<xsl:template name="image.bucket">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:param name="width" />
	<xsl:param name="height" />
	<xsl:param name="crop" />
	<xsl:param name="quality" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />

	<img alt="{$alt}">
		<xsl:attribute name="src"><!-- 
			 --><xsl:value-of select="$config/system/content_domain" /><!--
			 --><xsl:value-of select="$config/system/images_bucket" />/<!-- 
			 --><xsl:value-of select="substring($id, string-length($id), 1)" />/<!-- 
			 --><xsl:value-of select="$id" /><!-- 
			 --><xsl:if test="$width!=''">w<xsl:value-of select="$width" /></xsl:if><!-- 
			 --><xsl:if test="$height!=''">h<xsl:value-of select="$height" /></xsl:if><!-- 
			 --><xsl:if test="$quality!=''">q<xsl:value-of select="$quality" /></xsl:if><!-- 
			 --><xsl:if test="$crop!=''">c</xsl:if><!-- 
			 -->.<!-- 
			 --><xsl:value-of select="$type" /><!-- 
		 --></xsl:attribute>
		<xsl:if test="$class!=''"><xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute></xsl:if>
		<xsl:if test="$style!=''"><xsl:attribute name="style"><xsl:value-of select="$style" /></xsl:attribute></xsl:if>
	</img>
</xsl:template>


<!--################### FIN TEMPLATES DE MULTIMEDIA ####################-->


<xsl:template name="escape.quotes"><!--
	--><xsl:param name="string" /><!--
	--><xsl:choose><!--
		--><xsl:when test="contains($string, '&quot;')"><!--
			--><xsl:value-of select="substring-before($string, '&quot;')" />\"<!--
			--><xsl:call-template name="escape.quotes"><!--
				--><xsl:with-param name="string" select="substring-after($string, '&quot;')" /><!--
			--></xsl:call-template><!--
		--></xsl:when><!--
		--><xsl:when test="contains($string, '&#9;')"><!--
			--><xsl:value-of select="substring-before($string, '&#9;')" />\"<!--
			--><xsl:call-template name="escape.quotes"><!--
				--><xsl:with-param name="string" select="substring-after($string, '&#9;')" /><!--
			--></xsl:call-template><!--
		--></xsl:when><!--
		--><xsl:otherwise><!--
			--><xsl:call-template name="replace.newline"><!--
				--><xsl:with-param name="string" select="$string" /><!--
			--></xsl:call-template><!--
			<xsl:value-of select="$string" disable-output-escaping="yes" />
		--></xsl:otherwise><!--
	--></xsl:choose><!--
--></xsl:template>

<xsl:template name="replace.newline"><!--
	--><xsl:param name="string" /><!--
	--><xsl:choose><!--
		--><xsl:when test="contains($string, '&#xa;')"><!--
			--><xsl:value-of select="substring-before($string, '&#xa;')" /><!--
			--><xsl:call-template name="replace.newline"><!--
				--><xsl:with-param name="string" select="substring-after($string, '&#xa;')" /><!--
			--></xsl:call-template><!--
		--></xsl:when><!--
		--><xsl:otherwise><!--
			--><xsl:value-of select="normalize-space($string)" disable-output-escaping="yes" /><!--
		--></xsl:otherwise><!--
	--></xsl:choose><!--
--></xsl:template>

</xsl:stylesheet>