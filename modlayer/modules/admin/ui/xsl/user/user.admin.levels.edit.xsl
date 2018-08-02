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
			<form name="user" action="{$adminroot}?m={$config/module/@name}&amp;action=BackEditLevel" method="post">
				<input type="hidden" name="id" value="{$content/access_level/user_level_id}" />
				<section class="edit-header floatFix">
					<span class="right">
						<a href="#" class="btn" onclick="javascript:history.back();">Cancelar</a>&#xa0;
						<button type="submit" class="btn color"><span>Guardar</span></button>&#xa0;
					 </span>
					<h2>Nuevo Nivel de Acceso</h2>
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
								<label>Nombre</label>
								<input type="text" name="name" value="{$content/access_level/user_level_name}"/>
							</li>
						</ul>
					</section>
				</div>
			</form>
		</div>
	</div>
</xsl:template>
</xsl:stylesheet>