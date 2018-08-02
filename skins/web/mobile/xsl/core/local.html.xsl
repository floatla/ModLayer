<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<xsl:template name="body-ads" >
	<xsl:for-each select="$article/content/*">
		<!-- <div style="background:red;color:#fff;padding:15px;font-size:23px;">
			<xsl:value-of select="position()" /> - <xsl:value-of select="name()" />
		</div> -->
		<xsl:choose>
			<xsl:when test="position()= 3">
				<!-- Eplanning In2 -->
				<div class="content-ad">
					<script type="text/javascript">eplAD4M("In1_300x250");</script>
				</div>
				<!-- Eplanning In2 -->
				<xsl:apply-templates select="." mode="ads-chaco"/>
			</xsl:when>
			<xsl:when test="position()= 9">
				<!-- Eplanning In2 -->
				<div class="content-ad">
					<script type="text/javascript">eplAD4M("In2_300x250");</script>
				</div>
				<!-- Eplanning In2 -->
				<xsl:apply-templates select="." mode="ads-chaco"/>
			</xsl:when>
			<xsl:when test="position()= 20">
				<!-- Eplanning In2 -->
				<div class="content-ad">
					<script type="text/javascript">eplAD4M("In1_300x250");</script>
				</div>
				<!-- Eplanning In2 -->
				<xsl:apply-templates select="." mode="ads-chaco"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="ads-chaco"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<xsl:template match="*[not(name()='p')]" mode="ads-chaco">
	<xsl:apply-templates select="." />
</xsl:template>

<xsl:template match="*[name()='p']" mode="ads-chaco">
	<xsl:choose>
		<xsl:when test="not(@class = 'embed')">
			<p>
				<xsl:apply-templates select="@*" mode="atts" />
				<xsl:apply-templates />
			</p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>