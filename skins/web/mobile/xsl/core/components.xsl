<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:variable name="config" select="/xml/configuration"/>
<xsl:variable name="content" select="/xml/content"/>
<xsl:variable name="context" select="/xml/context"/>


<xsl:param name="htmlHeadExtra" />
<xsl:param name="skinpath" />
<xsl:param name="page" />
<xsl:param name="isHome" />
<xsl:param name="dinamicHead" />
<xsl:param name="search_category" />
<xsl:param name="search_type" />


<!-- ************** html head ************** -->
<xsl:template name="htmlHead">
	<meta charset="UTF-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<link rel="apple-touch-icon-precomposed" href="{$skinpath}/imgs/logos/touch_icon_128x128.png" />
	<script><!-- 
          -->var require = { baseUrl: "<xsl:value-of select="$skinpath" />/js"};<!-- 
     --></script>
	<script data-main="{$device}/js/common.js" src="{$device}/js/lib/require.js">&#xa0;</script>
	<script type='text/javascript'><!-- 
		 -->var googletag = googletag || {};<!-- 
		 -->googletag.cmd = googletag.cmd || [];<!-- 
		 -->(function() {<!-- 
		 -->var gads = document.createElement('script');<!-- 
		 -->gads.async = true;<!-- 
		 -->gads.type = 'text/javascript';<!-- 
		 -->var useSSL = 'https:' == document.location.protocol;<!-- 
		 -->gads.src = (useSSL ? 'https:' : 'http:') + <!-- 
		 -->'//www.googletagservices.com/tag/js/gpt.js';<!-- 
		 -->var node = document.getElementsByTagName('script')[0];<!-- 
		 -->node.parentNode.insertBefore(gads, node);<!-- 
		 -->})();<!-- 
	 --></script>
	<xsl:choose>
		<xsl:when test="$dinamicHead != ''">
			<xsl:copy-of select="$dinamicHead" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$config/skin/header/*" mode="htmlhead"/>
			<xsl:copy-of select="$htmlHeadExtra" />
		</xsl:otherwise>
	</xsl:choose>
	<link rel="alternate" type="application/rss+xml" href="{$config/system/domain}/rss/feed/" title="Vind.com.ar" />

	<script type="text/javascript"><!-- 
		 -->var domain = "<xsl:value-of select="$config/system/domain" />";<!-- 
		 -->var skinpath = "<xsl:value-of select="$skinpath" />";<!-- 
	 --></script>

	<xsl:if test="/xml/configuration/client/browser/browser_working = 'ie'">
		<link rel="stylesheet" type="text/css" href="{$config/system/images_domain}{$skinpath}/css/ie.css?v=13" />
		<script type="text/javascript" src="{$config/system/images_domain}{$skinpath}/js/ie_script.js">&#xa0;</script>
	</xsl:if>

</xsl:template>
<!-- ************** html head ************** -->


<!-- ************** html head templates ************** -->
<xsl:template match="title" mode="htmlhead">
	<title><xsl:value-of select="."/></title>
</xsl:template>
<xsl:template match="css" mode="htmlhead">
	<xsl:variable name="cssfile"><xsl:apply-templates /></xsl:variable>
	<link rel="stylesheet" type="text/css" href="{$cssfile}" /> <!-- {$config/system/images_domain} -->
</xsl:template>
<xsl:template match="skinpath">
	<xsl:value-of select="$skinpath" />
</xsl:template>
<xsl:template match="favicon" mode="htmlhead">
	<xsl:variable name="iconfile"><xsl:apply-templates /></xsl:variable>
	<link rel="shortcut icon" href="{$iconfile}" />
</xsl:template>
<xsl:template match="jquery" mode="htmlhead">
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js">&#xa0;</script>
</xsl:template>
<xsl:template match="style" mode="htmlhead">
	<xsl:copy-of select="." />
</xsl:template>
<xsl:template match="script" mode="htmlhead">
	<xsl:variable name="jsfile"><xsl:apply-templates /></xsl:variable>
	<script type="text/javascript" src="{$jsfile}">&#xa0;</script>
</xsl:template>
<xsl:template match="meta" mode="htmlhead">
	<xsl:copy-of select="." />
</xsl:template>
<xsl:template match="seccion_eplad" mode="htmlhead">
	<script type="text/javascript">var seccion_id = "<xsl:copy-of select="text()" />";</script>
</xsl:template>
<!-- ************** html head templates ************** -->



<xsl:template name="fecha.con.dia">
<xsl:param name="fecha" />
<xsl:param name="dia" />
<xsl:param name="showTime">0</xsl:param>

<xsl:variable name="diaNum" select="number(substring($fecha, 9, 2))" />
<xsl:variable name="mes" select="substring($fecha, 6, 2)" />
<xsl:variable name="anio" select="substring($fecha, 1, 4)" />
<xsl:variable name="hora" select="substring(substring-after($fecha, ' '),1,5)" />
<xsl:variable name="mesNombre">
<xsl:choose><!--
	--><xsl:when test="$mes=01">Enero</xsl:when><!--
	--><xsl:when test="$mes=02">Febrero</xsl:when><!--
	--><xsl:when test="$mes=03">Marzo</xsl:when><!--
	--><xsl:when test="$mes=04">Abril</xsl:when><!--
	--><xsl:when test="$mes=05">Mayo</xsl:when><!--
	--><xsl:when test="$mes=06">Junio</xsl:when><!--
	--><xsl:when test="$mes=07">Julio</xsl:when><!--
	--><xsl:when test="$mes=08">Agosto</xsl:when><!--
	--><xsl:when test="$mes=09">Septiembre</xsl:when><!--
	--><xsl:when test="$mes=10">Octubre</xsl:when><!--
	--><xsl:when test="$mes=11">Noviembre</xsl:when><!--
	--><xsl:when test="$mes=12">Diciembre</xsl:when><!--
--></xsl:choose><!--
--></xsl:variable>

<xsl:variable name="diaNombre">
<xsl:choose><!--
	--><xsl:when test="$dia='Sunday'">Domingo</xsl:when><!--
	--><xsl:when test="$dia='Monday'">Lunes</xsl:when><!--
	--><xsl:when test="$dia='Tuesday'">Martes</xsl:when><!--
	--><xsl:when test="$dia='Wednesday'">Miércoles</xsl:when><!--
	--><xsl:when test="$dia='Thursday'">Jueves</xsl:when><!--
	--><xsl:when test="$dia='Friday'">Viernes</xsl:when><!--
	--><xsl:when test="$dia='Saturday'">Sábado</xsl:when><!--
--></xsl:choose><!--
--></xsl:variable>

<xsl:value-of select="$diaNombre"/>&#xa0;<xsl:value-of select="$diaNum"/> de <xsl:value-of select="$mesNombre"/> <!-- / <xsl:value-of select="$anio"/> -->
<xsl:if test="$showTime = 1"> | <xsl:value-of select="$hora" /> hs</xsl:if> 
</xsl:template>




<xsl:template name="fecha.formato.nota">
<xsl:param name="fecha" />
<xsl:variable name="dia" select="number(substring($fecha, 9, 2))" />
<xsl:variable name="mes" select="substring($fecha, 6, 2)" />
<xsl:variable name="anio" select="substring($fecha, 1, 4)" />
<xsl:variable name="mesNombre">
<xsl:choose><!--
	--><xsl:when test="$mes=01">Ene</xsl:when><!--
	--><xsl:when test="$mes=02">Feb</xsl:when><!--
	--><xsl:when test="$mes=03">Mar</xsl:when><!--
	--><xsl:when test="$mes=04">Abr</xsl:when><!--
	--><xsl:when test="$mes=05">May</xsl:when><!--
	--><xsl:when test="$mes=06">Jun</xsl:when><!--
	--><xsl:when test="$mes=07">Jul</xsl:when><!--
	--><xsl:when test="$mes=08">Ago</xsl:when><!--
	--><xsl:when test="$mes=09">Sep</xsl:when><!--
	--><xsl:when test="$mes=10">Oct</xsl:when><!--
	--><xsl:when test="$mes=11">Nov</xsl:when><!--
	--><xsl:when test="$mes=12">Dic</xsl:when><!--
--></xsl:choose><!--
--></xsl:variable>
<xsl:value-of select="$dia"/> de <xsl:value-of select="$mesNombre"/>, <xsl:value-of select="$anio"/>
</xsl:template>


<xsl:template name="fecha.formato.comentario">
	<xsl:param name="fecha" />
	<xsl:variable name="dia" select="substring($fecha, 9, 2)" />
	<xsl:variable name="mes" select="substring($fecha, 6, 2)" />
	<xsl:variable name="anio" select="substring($fecha, 1, 4)" />
	<xsl:variable name="hora" select="substring(substring-after($fecha, ' '),1,5)" />

	<xsl:value-of select="$dia" />.<xsl:value-of select="$mes" />.<xsl:value-of select="$anio" /> | <xsl:value-of select="$hora" /> hs
</xsl:template>

<xsl:template name="fecha.formato.simple">
	<xsl:param name="fecha" />
	<xsl:variable name="dia" select="substring($fecha, 9, 2)" />
	<xsl:variable name="mes" select="substring($fecha, 6, 2)" />
	<xsl:variable name="anio" select="substring($fecha, 1, 4)" />
	<xsl:value-of select="$dia" />/<xsl:value-of select="$mes" />/<xsl:value-of select="$anio" />
</xsl:template>




<xsl:template name="normalizar.texto">
	<xsl:param name="nCaracteres"/>
	<xsl:param name="string"/>
	<xsl:variable name="caracteresReemplazar">!¡°¿?%$¥ø,;:()“”"'_.ë&amp;/</xsl:variable>

	<xsl:variable name="lower">
		<xsl:value-of select="translate($string,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
	</xsl:variable>
	<xsl:variable name="result1a">
		<xsl:value-of select="translate($lower,'áéíóúñàèìòùç','aeiounaeiouc')"/>
	</xsl:variable>
	<xsl:variable name="result1">
		<xsl:value-of select="translate($result1a,'âêîôû','aeiou')"/>
	</xsl:variable>
	<xsl:variable name="result2">
		<xsl:value-of select="translate($result1,'ÁÉÍÓÚÑÀÈÌÒÙÇ','aeiounaeiouc')"/>
	</xsl:variable>
	<xsl:variable name="result3">
		<xsl:value-of select="translate($result2,$caracteresReemplazar,'')"/>
	</xsl:variable>
	<xsl:variable name="result4">
		<xsl:value-of select="translate($result3,'+','')"/>
	</xsl:variable>
	<xsl:variable name="result5">
	<xsl:choose>
		<xsl:when test="$nCaracteres != ''">
			<xsl:value-of select="substring(translate($result4,' ','-'),0,$nCaracteres)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="translate($result4,' ','-')"/>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	<xsl:variable name="result6">
		<xsl:call-template name="limpiar.guiones">
			<xsl:with-param name="string" select="$result5" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$result6"/>
</xsl:template>

<xsl:template name="limpiar.guiones"><!--
	--><xsl:param name="string" /><!--
	--><xsl:variable name="cadena"><!--
	--><xsl:choose><!--
		--><xsl:when test="contains($string, '--')">
			<xsl:value-of select="substring-before($string, '--')" />-<!--
			--><xsl:call-template name="limpiar.guiones"><!--
				--><xsl:with-param name="string" select="substring-after($string, '--')" /><!--
			--></xsl:call-template><!--
		--></xsl:when><!--
		--><xsl:otherwise><!--
			--><xsl:value-of select="$string"/><!--
		--></xsl:otherwise><!--
	--></xsl:choose><!--
	--></xsl:variable><!--
	--><xsl:variable name="texto"><!--
		--><xsl:call-template name="limpiar.tags"><!--
			--><xsl:with-param name="cadena" select="$cadena" /><!--
		--></xsl:call-template><!--
	--></xsl:variable><!--
	--><xsl:value-of select="$texto" /><!--
--></xsl:template>

<xsl:template name="limpiar.tags">
	<xsl:param name="cadena" />
	<xsl:choose>
		<xsl:when test="contains($cadena, '&lt;')">
			<xsl:value-of select="substring-before($cadena, '&lt;')" />
			<xsl:call-template name="limpiar.tags">
				<xsl:with-param name="cadena" select="substring-after($cadena, '&gt;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="contains($cadena, '&gt;')">
			<xsl:value-of select="substring-before($cadena, '&gt;')" />
			<xsl:call-template name="limpiar.tags">
				<xsl:with-param name="cadena" select="substring-after($cadena, '&gt;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$cadena" disable-output-escaping="yes" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>




<xsl:template name="combo.day">
	<xsl:param name="selected" />
	<select name="day" id="day">
		<option value="0">DÌa</option>
		<option value="01"><xsl:if test="$selected = '01'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>01</option>
		<option value="02"><xsl:if test="$selected = '02'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>02</option>
		<option value="03"><xsl:if test="$selected = '03'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>03</option>
		<option value="04"><xsl:if test="$selected = '04'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>04</option>
		<option value="05"><xsl:if test="$selected = '05'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>05</option>
		<option value="06"><xsl:if test="$selected = '06'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>06</option>
		<option value="07"><xsl:if test="$selected = '07'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>07</option>
		<option value="08"><xsl:if test="$selected = '08'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>08</option>
		<option value="09"><xsl:if test="$selected = '09'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>09</option>
		<option value="10"><xsl:if test="$selected = '10'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>10</option>
		<option value="11"><xsl:if test="$selected = '11'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>11</option>
		<option value="12"><xsl:if test="$selected = '12'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>12</option>
		<option value="13"><xsl:if test="$selected = '13'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>13</option>
		<option value="14"><xsl:if test="$selected = '14'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>14</option>
		<option value="15"><xsl:if test="$selected = '15'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>15</option>
		<option value="16"><xsl:if test="$selected = '16'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>16</option>
		<option value="17"><xsl:if test="$selected = '17'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>17</option>
		<option value="18"><xsl:if test="$selected = '18'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>18</option>
		<option value="19"><xsl:if test="$selected = '19'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>19</option>
		<option value="20"><xsl:if test="$selected = '20'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>20</option>
		<option value="21"><xsl:if test="$selected = '21'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>21</option>
		<option value="22"><xsl:if test="$selected = '22'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>22</option>
		<option value="23"><xsl:if test="$selected = '23'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>23</option>
		<option value="24"><xsl:if test="$selected = '24'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>24</option>
		<option value="25"><xsl:if test="$selected = '25'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>25</option>
		<option value="26"><xsl:if test="$selected = '26'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>26</option>
		<option value="27"><xsl:if test="$selected = '27'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>27</option>
		<option value="28"><xsl:if test="$selected = '28'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>28</option>
		<option value="29"><xsl:if test="$selected = '29'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>29</option>
		<option value="30"><xsl:if test="$selected = '30'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>30</option>
		<option value="31"><xsl:if test="$selected = '31'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>31</option>
	</select>
</xsl:template>

<xsl:template name="combo.month">
	<xsl:param name="selected" />
	<select name="month" id="month">
		<option value="0">Mes</option>
		<option value="01"><xsl:if test="$selected = '01'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Enero</option>
		<option value="02"><xsl:if test="$selected = '02'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Febrero</option>
		<option value="03"><xsl:if test="$selected = '03'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Marzo</option>
		<option value="04"><xsl:if test="$selected = '04'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Abril</option>
		<option value="05"><xsl:if test="$selected = '05'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Mayo</option>
		<option value="06"><xsl:if test="$selected = '06'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Junio</option>
		<option value="07"><xsl:if test="$selected = '07'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Julio</option>
		<option value="08"><xsl:if test="$selected = '08'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Agosto</option>
		<option value="09"><xsl:if test="$selected = '09'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Septiembre</option>
		<option value="10"><xsl:if test="$selected = '10'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Octubre</option>
		<option value="11"><xsl:if test="$selected = '11'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Noviembre</option>
		<option value="12"><xsl:if test="$selected = '12'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Diciembre</option>
	</select>
</xsl:template>

<xsl:template name="combo.year">
	<xsl:param name="selected" />
	<select name="year" id="year">
		<option value="0">AÒo</option>
		<xsl:call-template name="combo.year.item">
			<xsl:with-param name="start">1948</xsl:with-param>
			<xsl:with-param name="end">2005</xsl:with-param>
			<xsl:with-param name="selected" select="$selected" />
		</xsl:call-template>
	</select>
</xsl:template>


<xsl:template name="combo.year.item">
	<xsl:param name="start"/>
	<xsl:param name="end"/>
	<xsl:param name="selected" />
	<xsl:choose>
		<xsl:when test="number($end) &gt;= number($start)">
			<option value="{$end}">
				<xsl:if test="$selected = $end"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
				<xsl:value-of select="$end" />
			</option>
			<xsl:call-template name="combo.year.item">
				<xsl:with-param name="start"><xsl:value-of select="$start" /></xsl:with-param>
				<xsl:with-param name="end"><xsl:value-of select="number($end) - 1" /></xsl:with-param>
				<xsl:with-param name="selected" select="$selected" />
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>





<xsl:template name="pagination">
	<!--Url para el paginado a la que se agrega el numero de pagina ej: /noticias/page/-->
	<xsl:param name="url" />
	<!--Pagina que estoy mostrando-->
	<xsl:param name="currentPage" />
	<!--Cantidad de items que se muestran por cada pagina-->
	<xsl:param name="display" />
	<!--Total de items-->
	<xsl:param name="total" />

	<xsl:variable name="pageurl"><!-- 
		 --><xsl:choose><!-- 
			 --><xsl:when test="$url=''"><!-- 
				 --><xsl:choose><!-- 
					 --><xsl:when test="$query != ''"><!-- 
				 		 --><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/search/?page=<!-- 
				 	 --></xsl:when><!-- 
				 	 --><xsl:otherwise><!-- 
				 		 --><xsl:value-of select="$adminroot"/><xsl:value-of select="$modName"/>/list/?page=<!-- 
				 	 --></xsl:otherwise><!-- 
				  --></xsl:choose><!-- 
			  --></xsl:when><!-- 
			  --><xsl:otherwise><xsl:value-of select="$url" />?page=</xsl:otherwise><!-- 
		 --></xsl:choose><!--  
	 --></xsl:variable>
	<xsl:variable name="queryStr"><!-- 
		--><xsl:if test="$query != ''">&amp;q=<xsl:value-of select="translate($query, ' ', '+')" disable-output-escaping="yes" /></xsl:if><!-- 
		--><xsl:if test="$category_id != ''">&amp;categories=<xsl:value-of select="$category_id" /></xsl:if><!-- 
		--><xsl:if test="$search_category != ''">&amp;category=<xsl:value-of select="$search_category" /></xsl:if><!-- 
		--><xsl:if test="$search_type != ''">&amp;type=<xsl:value-of select="$search_type" /></xsl:if><!-- 
	 --></xsl:variable>
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

		<xsl:if test="$totalPages != 1">
		<div class="pagination floatFix">
			<div class="info"><!-- 
				 -->
				 <xsl:variable name="totalshowing">
				 	<xsl:choose>
				 		<xsl:when test="$currentPage = $totalPages"><xsl:value-of select="$total" /></xsl:when>
				 		<xsl:otherwise><xsl:value-of select="$currentPage * $display" /></xsl:otherwise> 
				 	</xsl:choose>
				 </xsl:variable>
				 <xsl:value-of select="($display * ($currentPage - 1))+1"/> a <xsl:value-of select="$totalshowing" /> de <xsl:value-of select="$total" />
			</div>
			<div class="pages-link">
				<ul>
					<xsl:choose>
						<xsl:when test="$currentPage!='' and $currentPage != 1">
							<li>
								<a class="btn arrow" href="{$pageurl}{$currentPage - 1}{$queryStr}">&lt;</a>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<span  class="btn arrow">&lt;</span>
							</li>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:call-template name="pagination.pages">
						<xsl:with-param name="selected" select="$currentPage"/>
						<xsl:with-param name="currentPage" select="$currentPage" />
						<xsl:with-param name="pageurl" select="$pageurl" />
						<xsl:with-param name="queryStr" select="$queryStr" />
						<xsl:with-param name="total" select="$totalPages" />
						<xsl:with-param name="offset" select="2" />
					</xsl:call-template>

				
					<xsl:choose>
						<xsl:when test="$totalPages &gt; 1 and $currentPage != $totalPages">
							<li> 
								<a class="btn arrow" href="{$pageurl}{$currentPage + 1}{$queryStr}">></a>  
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

			
		</div>

		</xsl:if>



	</xsl:otherwise>
</xsl:choose>

</xsl:template>

<xsl:template name="pagination.pages">
	<xsl:param name="selected" />
	<xsl:param name="currentPage" />
	<xsl:param name="pageurl" />
	<xsl:param name="queryStr" />
	<xsl:param name="total" />
	<xsl:param name="offset" />


	<xsl:variable name="from">
		<xsl:choose>
			<xsl:when test="($currentPage - $offset) &lt;= 0">1</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$currentPage - $offset" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="to">
		<xsl:choose>
			<xsl:when test="($currentPage - $offset) &lt;= 0 and $total &gt; ($currentPage + $offset)"><xsl:value-of select="($offset * 2) + 1" /></xsl:when>
			<xsl:when test="($currentPage - $offset) &lt;= 0 and $total &lt; ($currentPage + $offset)"><xsl:value-of select="$total" /></xsl:when>
			<xsl:when test="($currentPage + 1) &gt;= $total"><xsl:value-of select="$total" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$currentPage + $offset" /></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:call-template name="combo.pages.item">
		<xsl:with-param name="start" select="$from" />
		<xsl:with-param name="end" select="$to" />
		<xsl:with-param name="selected" select="$selected" />
		<xsl:with-param name="currentPage" select="$currentPage" />
		<xsl:with-param name="pageurl" select="$pageurl" />
		<xsl:with-param name="queryStr" select="$queryStr" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="combo.pages.item">
	<xsl:param name="start"/>
	<xsl:param name="end"/>
	<xsl:param name="selected" />
	<xsl:param name="currentPage" />
	<xsl:param name="pageurl" />
	<xsl:param name="queryStr" />
	<xsl:choose>
		<xsl:when test="number($start) &lt;= number($end)">
			<li>
				<xsl:choose>
					<xsl:when test="$selected = $start">
						<span class="btn selected" href="#"><xsl:value-of select="$start" /></span>
					</xsl:when>
					<xsl:otherwise>
						<a class="btn" href="{$pageurl}{$start}{$queryStr}"><xsl:value-of select="$start" /></a>
					</xsl:otherwise>
				</xsl:choose>
			</li>
			<xsl:call-template name="combo.pages.item">
				<xsl:with-param name="start"><xsl:value-of select="number($start) + 1" /></xsl:with-param>
				<xsl:with-param name="end"><xsl:value-of select="$end" /></xsl:with-param>
				<xsl:with-param name="selected" select="$selected" />
				<xsl:with-param name="currentPage" select="$currentPage" />
				<xsl:with-param name="pageurl" select="$pageurl" />
				<xsl:with-param name="queryStr" select="$queryStr" />
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>



<xsl:template name="string.limit">
	<xsl:param name="string" />
	<xsl:param name="limit" />
	<xsl:if test="$string != ''">
		<xsl:choose>
			<xsl:when test="string-length($string) &gt; $limit"><!-- 
				 --><xsl:call-template name="limpiar.tags">
					<xsl:with-param name="cadena" select="substring($string,0,$limit)" />
				</xsl:call-template> ...<!-- 
			 --></xsl:when>
			<xsl:otherwise><!-- 
				 --><xsl:call-template name="limpiar.tags">
					<xsl:with-param name="cadena" select="$string" />
				</xsl:call-template><!-- 
			 --></xsl:otherwise>
		</xsl:choose>
	</xsl:if>
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
				<xsl:if test="$pageSize != ''">
					<div class="info"> 
						 <xsl:variable name="totalshowing">
						 	<xsl:choose>
						 		<xsl:when test="$currentPage = $totalPages"><xsl:value-of select="$total" /></xsl:when>
						 		<xsl:otherwise><xsl:value-of select="$currentPage * $pageSize" /></xsl:otherwise> 
						 	</xsl:choose>
						 </xsl:variable>
						 <xsl:value-of select="($pageSize * ($currentPage - 1))+1"/> a <xsl:value-of select="$totalshowing" /> de <xsl:value-of select="$total" />
					</div>
				</xsl:if>
				<div class="pages-link">
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
							<span class="selected btn">
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


				
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template name="cortarCadena">
<xsl:param name="cadena" />
<xsl:param name="cantidad" />
<xsl:if test="$cadena!=''">
	<xsl:choose>
		<xsl:when test="string-length($cadena)&gt;$cantidad"><!-- 
			 --><xsl:call-template name="limpiar.tags">
				<xsl:with-param name="cadena" select="substring($cadena,0,$cantidad)" />
			</xsl:call-template> [...]<!-- 
		 --></xsl:when>
		<xsl:otherwise><!-- 
			 --><xsl:call-template name="limpiar.tags">
				<xsl:with-param name="cadena" select="$cadena" />
			</xsl:call-template><!-- 
		 --></xsl:otherwise>
	</xsl:choose>
</xsl:if>
</xsl:template>



<xsl:template name="limpiartags">
	<xsl:param name="cadena" />
	<xsl:choose>
		<xsl:when test="contains($cadena, '&lt;')">
			<xsl:value-of select="substring-before($cadena, '&lt;')" />
			<xsl:call-template name="limpiartags">
				<xsl:with-param name="cadena" select="substring-after($cadena, '&gt;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="contains($cadena, '&gt;')">
			<xsl:value-of select="substring-before($cadena, '&gt;')" />
			<xsl:call-template name="limpiartags">
				<xsl:with-param name="cadena" select="substring-after($cadena, '&gt;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$cadena" disable-output-escaping="yes" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>









<!--URLS-->

<xsl:template name="video.url">
	<xsl:param name="id" />
	<xsl:param name="titulo" />
	<xsl:variable name="videotitulo">
		<xsl:call-template name="normalizar.texto">
			<xsl:with-param name="string" select="$titulo" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/videos/<xsl:value-of select="$id"/>/<xsl:value-of select="$videotitulo" />
</xsl:template>



<xsl:template name="article.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="article_title">
		<xsl:call-template name="normalizar.texto">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/article/<xsl:value-of select="$id"/>/<xsl:value-of select="$article_title" />
</xsl:template>

<xsl:template name="suple.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="article_title">
		<xsl:call-template name="normalizar.texto">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/suple/<xsl:value-of select="$id"/>/<xsl:value-of select="$article_title" />
</xsl:template>

<xsl:template name="author.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="article_title">
		<xsl:call-template name="normalizar.texto">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/columnista/<xsl:value-of select="$id"/>/<xsl:value-of select="$article_title" />
</xsl:template>


<xsl:template name="gallery.url">
	<xsl:param name="id" />
	<xsl:param name="title" />
	<xsl:variable name="notatitulo">
		<xsl:call-template name="normalizar.texto">
			<xsl:with-param name="string" select="$title" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="/xml/configuration/system/domain"/>/gallery/<xsl:value-of select="$id"/>/<xsl:value-of select="$notatitulo" />
</xsl:template>



<xsl:template name="photo.bucket">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:param name="width" />
	<xsl:param name="height" />
	<xsl:param name="crop" />
	<xsl:param name="quality" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />
	<xsl:param name="itemprop" />

	<img alt="{$alt}">
		<xsl:attribute name="src"><!-- 
			 <xsl:value-of select="$config/system/images_domain" />
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
		<xsl:if test="$itemprop!=''"><xsl:attribute name="itemprop"><xsl:value-of select="$itemprop" /></xsl:attribute></xsl:if>
	</img>
</xsl:template>

<xsl:template name="photo.bucket.src">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:param name="width" />
	<xsl:param name="height" />
	<xsl:param name="crop" />
	<xsl:param name="quality" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />
	<xsl:param name="itemprop" />

	
	<!-- <xsl:value-of select="$config/system/images_domain" />
	 --><xsl:value-of select="$config/system/images_bucket" />/<!-- 
	 --><xsl:value-of select="substring($id, string-length($id), 1)" />/<!-- 
	 --><xsl:value-of select="$id" /><!-- 
	 --><xsl:if test="$width!=''">w<xsl:value-of select="$width" /></xsl:if><!-- 
	 --><xsl:if test="$height!=''">h<xsl:value-of select="$height" /></xsl:if><!-- 
	 --><xsl:if test="$quality!=''">q<xsl:value-of select="$quality" /></xsl:if><!-- 
	 --><xsl:if test="$crop!=''">c</xsl:if><!-- 
	 -->.<!-- 
	 --><xsl:value-of select="$type" />
</xsl:template>

<xsl:template name="photo">
	<xsl:param name="id" />
	<xsl:param name="suffix" />
	<xsl:param name="type" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />
	<xsl:param name="itemprop" />

	<img src="{$config/system/images_domain}{$config/skin/options/photos/folders/generated}/{substring($id, string-length($id), 1)}/{$id}{$suffix}.{$type}" alt="{$alt}">
		<xsl:if test="$class!=''"><xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute></xsl:if>
		<xsl:if test="$style!=''"><xsl:attribute name="style"><xsl:value-of select="$style" /></xsl:attribute></xsl:if>
		<xsl:if test="$itemprop!=''"><xsl:attribute name="itemprop"><xsl:value-of select="$itemprop" /></xsl:attribute></xsl:if>
	</img>
</xsl:template>

<xsl:template name="photo.original">
	<xsl:param name="id" />
	<xsl:param name="type" />
	<xsl:param name="class" />
	<xsl:param name="style" />
	<xsl:param name="alt" />
	<xsl:param name="itemprop" />

	<img src="{$config/system/image_domain}{$config/skin/options/photos/folders/source}/{substring($id, string-length($id), 1)}/{$id}.{$type}" alt="{$alt}">
		<xsl:if test="$class!=''"><xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute></xsl:if>
		<xsl:if test="$style!=''"><xsl:attribute name="style"><xsl:value-of select="$style" /></xsl:attribute></xsl:if>
		<xsl:if test="$itemprop!=''"><xsl:attribute name="itemprop"><xsl:value-of select="$itemprop" /></xsl:attribute></xsl:if>
	</img>
</xsl:template>

<xsl:template name="photo.src"><!--
--><xsl:param name="id" /><!--
--><xsl:param name="suffix" /><!--
--><xsl:param name="type" /><!--
	
--><xsl:value-of select="$config/system/images_domain" /><!--
--><xsl:value-of select="$config/skin/options/photos/folders/generated" />/<!--
--><xsl:value-of select="substring($id, string-length($id), 1)" />/<!--
--><xsl:value-of select="$id" /><!--
--><xsl:value-of select="$suffix" />.<!--
--><xsl:value-of select="$type" /><!--
--></xsl:template>

<xsl:template name="photo.original.src"><!--
--><xsl:param name="id" /><!--
--><xsl:param name="suffix" /><!--
--><xsl:param name="type" /><!--
	
--><xsl:value-of select="$config/system/images_domain" /><!--
--><xsl:value-of select="$config/skin/options/photos/folders/source" />/<!--
--><xsl:value-of select="substring($id, string-length($id), 1)" />/<!--
--><xsl:value-of select="$id" />.<!--
--><xsl:value-of select="$type" /><!--
--></xsl:template>


<xsl:template name="video.src">
	<xsl:param name="video_id" />
	<xsl:param name="type" /><!--
	--><xsl:value-of select="$config/skin/images_domain" /><!--
	--><xsl:value-of select="$config/skin/options/videos/folders/source" />/<!--
	--><xsl:value-of select="substring($video_id, string-length($video_id),1)" />/<!--
	--><xsl:value-of select="$video_id" />.<xsl:value-of select="$type" /><!--
	-->
</xsl:template>

<xsl:template name="audio.src">
	<xsl:param name="audio_id" />
	<xsl:param name="type" /><!--
	--><xsl:value-of select="$config/system/images_domain" /><!--
	-->/<xsl:value-of select="$context/audio_dir/option/@value" />/<!--
	--><xsl:value-of select="substring($audio_id, string-length($audio_id),1)" />/<!--
	--><xsl:value-of select="$audio_id" />.<xsl:value-of select="$type" /><!--
	-->
</xsl:template>

<xsl:template name="doc.src">
	<xsl:param name="doc_id" />
	<xsl:param name="type" /><!--
	--><xsl:value-of select="$config/skin/images_domain" /><!--
	--><xsl:value-of select="$config/skin/options/documents/folders/source" />/<!--
	--><xsl:value-of select="substring($doc_id, string-length($doc_id),1)" />/<!--
	--><xsl:value-of select="$doc_id" />.<xsl:value-of select="$type" /><!--
	-->
</xsl:template>


<xsl:template name="publication.time"><!-- 
	 --><xsl:variable name="pubdate" select="substring(/xml/content/home/pubDate, 1, 10)" /><!-- 
	 --><xsl:variable name="pubHour" select="substring(/xml/content/home/pubDate, 12, 2)" /><!-- 
	 --><xsl:variable name="pubMinute" select="substring(/xml/content/home/pubDate, 15, 2)" /><!-- 
	 --><xsl:variable name="currentHour" select="substring($horaActual, 1, 2)" /><!-- 
	 --><xsl:variable name="currentMinute" select="substring($horaActual, 4, 2)" /><!-- 
	 --><xsl:choose><!-- 
		 --><xsl:when test="($currentMinute - $pubMinute) &lt;= 1"><!-- 
			 -->Actualizado hace menos de 1 minuto<!-- 
		 --></xsl:when><!-- 
		 --><xsl:when test="($currentHour - $pubHour) = 0"><!-- 
		 -->Actualizado hace <xsl:value-of select="$currentMinute - $pubMinute" /> minutos<!-- 
		 --></xsl:when><!-- 
		 <xsl:when test="($currentHour - $pubHour) &lt; 2 and ($currentHour - $pubHour) &gt; 0">
			 Actualizado hace más <br/> de <xsl:value-of select="$currentHour - $pubHour" /> hora
		 </xsl:when>
	 --></xsl:choose>
	 <!-- 
 --></xsl:template>


</xsl:stylesheet>




