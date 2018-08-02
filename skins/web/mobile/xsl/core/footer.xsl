<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:template name="footer">
	<footer>
		<section class="container">
			<div class="company-info">
				<p>
					<!-- Copyright <xsl:value-of select="substring($fechaActual, 1, 4)" /> - -->
					Vind CMS <xsl:value-of select="substring($fechaActual, 1, 4)" /> - El contenido publicado en este demo tiene su crédito correspondiente.
					<br/>
				</p>
				<p>
					<span>Herramienta de publicación de contenidos editoriales.</span>
					<span>Desarrollado sobre: <a href="http://www.modlayer.com">ModLayer</a></span>
				</p>
			</div>

			<a href="http://www.float.la" target="_blank">Float.la</a>
		</section>
		
	 </footer>
	
</xsl:template>



</xsl:stylesheet>