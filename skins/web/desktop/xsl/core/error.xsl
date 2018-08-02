<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />
<xsl:param name="error" />



<xsl:variable name="htmlHeadExtra"></xsl:variable>


<xsl:template name="content">
	
	<section class="container">
		<div class="error">
			<xsl:choose>
				<xsl:when test="$error = '404'">
					<section class="floatFix">
						<h3 class="subtitle">Página no encontrada - 404</h3>
					</section>
					<p>
						La url solicitada no pudo ser reconocida por el sistema. Es posible que el contenido no esté disponible, o la dirección no esté bien formada.
						<!-- <br/>
						Para encotrar lo que estás buscando, te invitamos a utilizar el buscador: -->
					</p>
				</xsl:when>
				<xsl:otherwise>
					<section class="floatFix">
						<h3 class="subtitle">Se ha producido un Error</h3>
					</section>
					<p>El sistema ha encontrado un error interno. Se ha generado un ticket para solucionarlo.</p>
					<xsl:comment>type: modion error</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</section>


</xsl:template>







</xsl:stylesheet>