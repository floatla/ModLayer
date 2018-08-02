<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<xsl:template match="m_document">
	<xsl:variable name="document_id" select="@id" />
	<xsl:variable name="document" select="/xml/content/*/multimedias/documents/document[@document_id = $document_id]" />
	<section class="document-embeded">
		<span class="right">
			<a class="boton" href="/document/download/{$document_id}/">Descargar</a>
		</span>
		<h4><small>Documento: </small><xsl:value-of select="$document/title" /></h4>
		<xsl:value-of select="$document/content" disable-output-escaping="yes" />
	</section>
</xsl:template>


<xsl:template name="doc.src">
	<xsl:param name="doc_id" />
	<xsl:param name="type" /><!--
	--><xsl:value-of select="$config/system/content_domain" />/<!--
	--><xsl:if test="$config/system/domain/@subdir">/<xsl:value-of select="$config/system/domain/@subdir" /></xsl:if><!-- 
	-->/<xsl:value-of select="$context/doc_dir/option/@value" />/<!--
	--><xsl:value-of select="substring($doc_id, string-length($doc_id),1)" />/<!--
	--><xsl:value-of select="$doc_id" />.<xsl:value-of select="$type" /><!--
--></xsl:template>


</xsl:stylesheet>