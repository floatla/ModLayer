<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="htmlHeadExtra" />
<xsl:param name="skinpath" />
<xsl:param name="dinamicHead" />

<xsl:variable name="config" select="/xml/configuration"/>
<xsl:variable name="content" select="/xml/content"/>
<xsl:variable name="context" select="/xml/context"/>
<xsl:variable name="release" select="$config/system/release" />

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

<xsl:variable name="device"><!-- 
	--><xsl:value-of select="$config/system/assets_domain" /><!-- 
	--><xsl:value-of select="$skinpath" /><!-- 
--></xsl:variable>

<!-- ************** html head ************** -->
<xsl:template name="htmlHead">
	<meta charset="UTF-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<script><!-- 
          -->var require = { baseUrl: "<xsl:value-of select="$skinpath" />/js"};<!-- 
     --></script>
	<script data-main="{$device}/js/common.js" src="{$device}/js/lib/require.js">&#xa0;</script>
	<xsl:choose>
		<xsl:when test="$dinamicHead != ''">
			<xsl:copy-of select="$dinamicHead" />
		</xsl:when>
		<xsl:otherwise>
			<title><xsl:value-of select="$config/system/applicationID" /></title>
			<xsl:apply-templates select="$config/skin/header" mode="htmlhead"/>
			<xsl:copy-of select="$htmlHeadExtra" />
		</xsl:otherwise>
	</xsl:choose>
	<script type="text/javascript"><!-- 
		 -->var domain = "<xsl:value-of select="$config/system/domain" />";<!-- 
		 -->var skinpath = "<xsl:value-of select="$skinpath" />";<!-- 
	 --></script>
	<xsl:if test="$config/client/browser/browser_working = 'ie' and $config/client/browser/browser_number &lt; '9'">
		<script type="text/javascript" src="http://html5shiv.googlecode.com/svn/trunk/html5.js">&#xa0;</script>
	</xsl:if>
	<!-- <link rel="alternate" type="application/rss+xml" href="{$config/system/domain}/rss/feed/" title="vind.com.ar" /> -->
</xsl:template>

<!-- ************** html head ************** -->


<!-- ************** html head templates ************** -->
<xsl:template match="title" mode="htmlhead">
	<title><xsl:value-of select="."/></title>
</xsl:template>
<xsl:template match="css" mode="htmlhead">
	<xsl:variable name="cssfile"><xsl:apply-templates /></xsl:variable>
	<link rel="stylesheet" type="text/css" href="{$cssfile}" media="screen" />
</xsl:template>
<xsl:template match="skinpath">
	<xsl:value-of select="$device" />
</xsl:template>
<xsl:template match="favicon" mode="htmlhead">
	<xsl:variable name="iconfile"><xsl:apply-templates /></xsl:variable>
	<link rel="shortcut icon" href="{$iconfile}" />
</xsl:template>
<xsl:template match="style" mode="htmlhead">
	<xsl:copy-of select="." />
</xsl:template>
<xsl:template match="script" mode="htmlhead">
	<xsl:variable name="jsfile"><xsl:apply-templates /></xsl:variable>
	<script type="text/javascript" src="{$jsfile}">&#xa0;</script> <!-- {$config/system/content_domain} -->
</xsl:template>
<xsl:template match="meta" mode="htmlhead">
	<xsl:copy-of select="." />
</xsl:template>
<xsl:template match="seccion_eplad" mode="htmlhead">
	<script type="text/javascript">var seccion_id = "<xsl:copy-of select="text()" />";</script>
</xsl:template>
<!-- ************** html head templates ************** -->


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
		<xsl:otherwise>
			<script type="text/javascript" src="{$localstr}">&#xa0;</script>
		</xsl:otherwise>
	</xsl:choose>
	<!-- <xsl:if test="normalize-space($string) != ''">
		<script type="text/javascript" src="{normalize-space($string)}">&#xa0;</script>
	</xsl:if> -->
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
			<xsl:otherwise>
				<link rel="stylesheet" type="text/css" href="{$localstr}" />
			</xsl:otherwise>
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

<xsl:template name="date">
	<xsl:param name="date" />
	<xsl:param name="day">0</xsl:param>
	<xsl:param name="showTime">0</xsl:param>

	<xsl:variable name="diaNum" select="number(substring($date, 9, 2))" />
	<xsl:variable name="month" select="substring($date, 6, 2)" />
	<xsl:variable name="year" select="substring($date, 1, 4)" />
	<xsl:variable name="time" select="substring(substring-after($date, ' '),1,5)" />
	<xsl:variable name="mesNombre">
	<xsl:choose><!--
		--><xsl:when test="$month = 01">Enero</xsl:when><!--
		--><xsl:when test="$month = 02">Febrero</xsl:when><!--
		--><xsl:when test="$month = 03">Marzo</xsl:when><!--
		--><xsl:when test="$month = 04">Abril</xsl:when><!--
		--><xsl:when test="$month = 05">Mayo</xsl:when><!--
		--><xsl:when test="$month = 06">Junio</xsl:when><!--
		--><xsl:when test="$month = 07">Julio</xsl:when><!--
		--><xsl:when test="$month = 08">Agosto</xsl:when><!--
		--><xsl:when test="$month = 09">Septiembre</xsl:when><!--
		--><xsl:when test="$month = 10">Octubre</xsl:when><!--
		--><xsl:when test="$month = 11">Noviembre</xsl:when><!--
		--><xsl:when test="$month = 12">Diciembre</xsl:when><!--
	--></xsl:choose><!--
	--></xsl:variable>

	<xsl:if test="$day != 0">
		<xsl:choose><!--
			--><xsl:when test="$day='Sunday'">Domingo</xsl:when><!--
			--><xsl:when test="$day='Monday'">Lunes</xsl:when><!--
			--><xsl:when test="$day='Tuesday'">Martes</xsl:when><!--
			--><xsl:when test="$day='Wednesday'">Miércoles</xsl:when><!--
			--><xsl:when test="$day='Thursday'">Jueves</xsl:when><!--
			--><xsl:when test="$day='Friday'">Viernes</xsl:when><!--
			--><xsl:when test="$day='Saturday'">Sábado</xsl:when><!--
		--></xsl:choose><!--
		-->&#xa0;
	</xsl:if>
	<xsl:value-of select="$diaNum"/> de <xsl:value-of select="$mesNombre"/>, <xsl:value-of select="$year"/>
	<xsl:if test="$showTime = 1"> | <xsl:value-of select="$time" /> hs</xsl:if> 
</xsl:template>

<xsl:template name="date.short">
	<xsl:param name="date" />
	<xsl:param name="showTime">0</xsl:param>
	<xsl:variable name="day" select="substring($date, 9, 2)" />
	<xsl:variable name="month" select="substring($date, 6, 2)" />
	<xsl:variable name="year" select="substring($date, 1, 4)" />
	<xsl:variable name="time" select="substring(substring-after($date, ' '),1,5)" />
	<xsl:value-of select="$day"/>.<xsl:value-of select="$month"/>.<xsl:value-of select="$year"/>
	<xsl:if test="$showTime = 1"> | <xsl:value-of select="$time" /> hs</xsl:if> 
</xsl:template>

<xsl:template name="time">
	<xsl:param name="date" />
	<xsl:variable name="time" select="substring(substring-after($date, ' '),1,5)" />
	<xsl:value-of select="$time" /> hs
</xsl:template>

<xsl:template name="sanitize">
	<xsl:param name="nCaracteres"/>
	<xsl:param name="string"/>
	<xsl:variable name="caracteresReemplazar">!¡°¿?%$¥ø,;:()“”"'`´’_.ë&amp;/</xsl:variable>

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
		<xsl:call-template name="fix.dash">
			<xsl:with-param name="string" select="$result5" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$result6"/>
</xsl:template>

<xsl:template name="fix.dash"><!--
	--><xsl:param name="string" /><!--
	--><xsl:variable name="string"><!--
	--><xsl:choose><!--
		--><xsl:when test="contains($string, '--')">
			<xsl:value-of select="substring-before($string, '--')" />-<!--
			--><xsl:call-template name="fix.dash"><!--
				--><xsl:with-param name="string" select="substring-after($string, '--')" /><!--
			--></xsl:call-template><!--
		--></xsl:when><!--
		--><xsl:otherwise><!--
			--><xsl:value-of select="$string"/><!--
		--></xsl:otherwise><!--
	--></xsl:choose><!--
	--></xsl:variable><!--
	--><xsl:variable name="texto"><!--
		--><xsl:call-template name="remove.tags"><!--
			--><xsl:with-param name="string" select="$string" /><!--
		--></xsl:call-template><!--
	--></xsl:variable><!--
	--><xsl:value-of select="$texto" /><!--
--></xsl:template>

<xsl:template name="remove.tags">
	<xsl:param name="string" />
	<xsl:choose>
		<xsl:when test="contains($string, '&lt;')">
			<xsl:value-of select="substring-before($string, '&lt;')" />
			<xsl:call-template name="remove.tags">
				<xsl:with-param name="string" select="substring-after($string, '&gt;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="contains($string, '&gt;')">
			<xsl:value-of select="substring-before($string, '&gt;')" />
			<xsl:call-template name="remove.tags">
				<xsl:with-param name="string" select="substring-after($string, '&gt;')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$string" disable-output-escaping="yes" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="limit.string">
	<xsl:param name="string" />
	<xsl:param name="limit" />
	<xsl:if test="$string != ''">
		<xsl:choose>
			<xsl:when test="string-length($string) &gt; $limit"><!-- 
				 --><xsl:call-template name="remove.tags">
					<xsl:with-param name="string" select="substring($string,0,$limit)" />
				</xsl:call-template> ...<!-- 
			 --></xsl:when>
			<xsl:otherwise><!-- 
				 --><xsl:call-template name="remove.tags">
					<xsl:with-param name="string" select="$string" />
				</xsl:call-template><!-- 
			 --></xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!-- Para respuestas en JSON -->
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
			--><xsl:value-of select="$string" disable-output-escaping="yes" /><!--
		--></xsl:otherwise><!--
	--></xsl:choose><!--
--></xsl:template>

<xsl:template name="checkid">
	<xsl:param name="list" />
	<xsl:param name="id" />
	<xsl:choose>
		<xsl:when test="contains($list, ',')">
			<xsl:if test="substring-before($list, ',') = $id">1</xsl:if>
			<xsl:call-template name="checkid">
				<xsl:with-param name="list" select="substring-after($list, ',')" />
				<xsl:with-param name="id" select="$id" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="$list = $id">1</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>




