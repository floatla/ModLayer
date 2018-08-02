<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:param name="message" />
<xsl:param name="pass" />
<xsl:variable name="htmlHeadExtra">
	<style>.panel-form {padding:20px;background:#f0f0f0;margin:15px auto 0;border-radius:5px;}</style>
</xsl:variable>

<xsl:template name="content">
	<div class="item-edit">
		<div class="panel-form">
			<form name="user" action="{$adminroot}?m={$config/module/@name}&amp;action=AddLevel" method="post">
				<section class="edit-header floatFix">
					<span class="right">
						<a href="#" class="btn" onclick="javascript:history.back();"><xsl:value-of select="$language/user/levels/add/btn_cancel"/></a>&#xa0;
						<button type="submit" class="btn color"><span><xsl:value-of select="$language/user/levels/add/btn_save"/></span></button>&#xa0;
					 </span>
					<h2><xsl:value-of select="$language/user/levels/add/new_access_level"/></h2>
				</section>

				<div class="floatFix">					
					<section class="item-body">
						<xsl:if test="$message != ''">
							<div class="alert">
								<xsl:value-of select="$message" />
							</div>
						</xsl:if>
						<ul class="form">
							<li>
								<label><xsl:value-of select="$language/user/levels/add/name"/></label>
								<input type="text" name="name" value=""/>
							</li>
						</ul>
					</section>
				</div>
			</form>
		</div>
	</div>
</xsl:template>
</xsl:stylesheet>