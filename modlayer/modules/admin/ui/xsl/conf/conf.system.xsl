<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$adminPath"/>/ui/js/module.config.js
		</xsl:with-param>
	</xsl:call-template>
</xsl:variable>

<xsl:variable name="configxml" select="/xml/content/configuration" /> 

<xsl:template name="content">
	<xsl:attribute name="class">content with-header</xsl:attribute>
	<div class="item-edit" style="border:0;">
		<form name="preferences" action="{$adminroot}?m={$config/module/@name}&amp;action=BackPreferencesSave" method="post">
			

			<section class="edit-header floatFix">
				<span class="right">
					 <!-- <a href="{$adminroot}{$modName}/return/" class="boton">Volver sin guardar</a>&#xa0; -->
					 <!-- <button type="submit" name="back" value="1" class="btn"><span>Guardar y volver</span></button>&#xa0; -->
					 <button type="submit" class="btn lightblue"><span><xsl:value-of select="$language/modules/preferences/btn_save"/></span></button>&#xa0;
				 </span>
				<h2><xsl:value-of select="$language/modules/preferences/general_configuration"/></h2>
				<div class="alert"><!-- Para mensajes --></div>
			</section>

			<section class="item-sidebar" id="tools">
				<div class="sidebar-box">
					<h3 class="boxtitle"><xsl:value-of select="$language/modules/preferences/debug_xml"/></h3>
					<p>
						<span class="right">
							<input type="radio" id="debug1" name="/configuration/backend_debug" value="1">
								<xsl:if test="$configxml/backend_debug = 1">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="debug1"><xsl:value-of select="$language/modules/preferences/radio_yes"/></label>
							<input type="radio" id="debug0" name="/configuration/backend_debug" value="0">
								<xsl:if test="$configxml/backend_debug = 0">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="debug0"><xsl:value-of select="$language/modules/preferences/radio_no"/></label>
						</span>
						<label><xsl:value-of select="$language/modules/preferences/backend_label"/></label>
					</p>
					<p>
						<span class="right">
							<input type="radio" id="debugf1" name="/configuration/frontend_debug" value="1">
								<xsl:if test="$configxml/frontend_debug = 1">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="debugf1"><xsl:value-of select="$language/modules/preferences/radio_yes"/></label>
							<input type="radio" id="debugf0" name="/configuration/frontend_debug" value="0">
								<xsl:if test="$configxml/frontend_debug = 0">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="debugf0"><xsl:value-of select="$language/modules/preferences/radio_no"/></label>
						</span>
						<label><xsl:value-of select="$language/modules/preferences/frontend_label"/></label>
					</p>
				</div>
				<!-- <ul>
					<li class="header">
						<h3>Base de datos</h3>
					</li>
					<li class="collapsable metadata">
						<p>
							<label>Host</label>
							<input type="text" name="/configuration/database/host" value="{$configxml/database/host}" style="width:96%;"/>
						</p>
						<p>
							<label>DB Name</label>
							<input type="text" name="/configuration/database/dbname" value="{$configxml/database/dbname}" style="width:96%;"/>
						</p>
						<p>
							<label>DB User</label>
							<input type="text" name="/configuration/database/user" value="{$configxml/database/user}" style="width:96%;"/>
						</p>
						<p>
							<label>DB Pass</label>
							<input type="text" name="/configuration/database/pass" value="{$configxml/database/pass}" style="width:96%;"/>
						</p>
					</li>
				</ul> -->
				<div class="sidebar-box">
					<h3 class="boxtitle"><xsl:value-of select="$language/modules/preferences/error_reporting"/></h3>
					<p>
						<span class="right">
							<input type="radio" name="/configuration/errorReporting/screen/@enabled" value="true" id="screen1">
								<xsl:if test="$configxml/errorReporting/screen/@enabled = 'true'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="screen1"><xsl:value-of select="$language/modules/preferences/radio_yes"/></label>
							<input type="radio" name="/configuration/errorReporting/screen/@enabled" value="false" id="screen0">
								<xsl:if test="$configxml/errorReporting/screen/@enabled = 'false'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="screen0"><xsl:value-of select="$language/modules/preferences/radio_no"/></label>
						</span>
						<label><xsl:value-of select="$language/modules/preferences/display_on_screen"/></label>
					</p>
					<p>
						<span class="right">
							<input type="radio" name="/configuration/errorReporting/email/@enabled" value="true" id="email1">
								<xsl:if test="$configxml/errorReporting/email/@enabled = 'true'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="email1"><xsl:value-of select="$language/modules/preferences/radio_yes"/></label>
							<input type="radio" name="/configuration/errorReporting/email/@enabled" value="false" id="email0">
								<xsl:if test="$configxml/errorReporting/email/@enabled = 'false'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
							</input>
							<label style="display:inline;" for="email0"><xsl:value-of select="$language/modules/preferences/radio_no"/></label>
						</span>
						<label><xsl:value-of select="$language/modules/preferences/send_by_mail"/></label>
					</p>
					<p>
						<label><xsl:value-of select="$language/modules/preferences/recipients"/>&#xa0;<small><xsl:value-of select="$language/modules/preferences/recipients_small"/></small></label>
						<input type="text" name="/configuration/errorReporting/email/@destination" value="{$configxml/errorReporting/email/@destination}" style="width:96%;"/>
					</p>
					<p>
						<label><xsl:value-of select="$language/modules/preferences/sender"/></label>
						<input type="text" name="/configuration/errorReporting/email/@sender" value="{$configxml/errorReporting/email/@sender}" style="width:96%;"/>
					</p>
					<p>
						<label><xsl:value-of select="$language/modules/preferences/sender_name"/></label>
						<input type="text" name="/configuration/errorReporting/email/@sendername" value="{$configxml/errorReporting/email/@sendername}" style="width:96%;"/>
					</p>
				</div>
				<xsl:comment />
			</section>

			<section class="item-body">
				<h3 class="boxtitle"><xsl:value-of select="$language/modules/preferences/system_configuration"/></h3>
				<ul class="form">
					<xsl:for-each select="$configxml/*[not(*)][not(name()='frontend_debug' or name()='backend_debug')]">
						<li>
							<label><xsl:value-of select="name()" /></label>
							<input type="text" name="/configuration/{name()}" value="{text()}" />
						</li>
						<xsl:if test="name() = 'domain' and @subdir != ''">
							<li>
								<label><xsl:value-of select="$language/modules/preferences/subdirectory"/></label>
								<input type="text" name="/configuration/domain/@subdir" value="{@subdir}" />
							</li>
						</xsl:if>
					</xsl:for-each>
				</ul>

				<!-- <h3>Skin</h3>
				<ul class="form">
					<xsl:for-each select="$configxml/skin/*">
						<li>
							<label><xsl:value-of select="name()" /></label>
							<input type="text" name="/configuration/skin/{name()}" value="{text()}" />
						</li>
					</xsl:for-each>
				</ul> -->

			</section>
			<input type="hidden" name="modToken" value="{$modToken}" />
		</form>
	</div>


</xsl:template>

</xsl:stylesheet>