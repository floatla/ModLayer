<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />
<xsl:param name="error" />

<xsl:variable name="htmlHeadExtra"></xsl:variable>




<xsl:template name="content">

	<section id="not-found">
		<div class="container">
			<xsl:choose>
				<xsl:when test="$error = '404'">
					<div class="error floatFix">
						<i class="fa fa-exclamation-triangle"><xsl:comment /></i>
						<h3 class="subtitle">Página no encontrada - 404</h3>
					</div>
					<p>
						La URL solicitada no pudo ser reconocida por el sistema. Es posible que el contenido no esté disponible, o la dirección no esté bien formada.
					</p>
					<p>
						Si no estás seguro como llegaste a esta página, podés:
					</p>
					<a class="btn back" href="#" onclick="javascript:history.back();return false;">Volver a la página anterior</a>
					<a class="btn" href="/">Ir a la página de inicio</a><br/>

				</xsl:when>
				<xsl:otherwise>
					<div class="error floatFix" style="width:280px;">
						<i class="fa fa-exclamation-triangle"><xsl:comment /></i>
						<h3 class="subtitle">Se ha producido un Error</h3>
					</div>
					<p>El sistema ha encontrado un error interno. Se ha generado un ticket para solucionarlo.</p>
					<xsl:comment>type: modion error</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</section>

</xsl:template>







</xsl:stylesheet>