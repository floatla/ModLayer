<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<xsl:template match="m_document">
	<xsl:variable name="document_id" select="@id" />
	<xsl:if test="/xml/content/*/multimedias/documents/document[@document_id = $document_id]">
		<xsl:variable name="document" select="/xml/content/*/multimedias/documents/document[@document_id = $document_id]" />
		<div class="m_document">
			<a href="/document/download/{$document_id}/" title="Descargar">
				<span class="icon">
					<xsl:variable name="iconClass"><!-- 
						 --><xsl:choose>
							<xsl:when test="$document/@type = 'pdf'"> fa-file-pdf-o</xsl:when>
							<xsl:when test="$document/@type = 'ppt'"> fa-file-powerpoint-o</xsl:when>
							<xsl:when test="$document/@type = 'doc'"> fa-file-word-o</xsl:when>
							<xsl:when test="$document/@type = 'docx'"> fa-file-word-o</xsl:when>
							<xsl:when test="$document/@type = 'xls'"> fa-file-excel-o</xsl:when>
							<xsl:when test="$document/@type = 'xlsx'"> fa-file-excel-o</xsl:when>
							<xsl:otherwise> fa-file-o</xsl:otherwise>
						</xsl:choose><!-- 
					 --></xsl:variable>
					<i class="fa {$iconClass}">&#xa0;</i>
				</span>
				<i class="right download fa fa-download">&#xa0;</i>
				<h4>
					<small>Documento: </small>
					<xsl:value-of select="$document/title" />
				</h4>
			</a>
			<!-- <xsl:value-of select="$document/content" disable-output-escaping="yes" /> -->
		</div>
	</xsl:if>
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