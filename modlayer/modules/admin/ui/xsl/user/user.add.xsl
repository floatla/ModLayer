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
			<xsl:variable name="user" select="content/user" />
			<form name="user" action="{$adminroot}?m={$config/module/@name}&amp;action=AddUser" method="post">

				<section class="edit-header floatFix">
					<span class="right">
						<a href="#" class="btn" onclick="javascript:history.back();"><xsl:value-of select="$language/user/add/btn_cancel"/></a>&#xa0;
						<button type="submit" class="btn color"><span><xsl:value-of select="$language/user/add/btn_save"/></span></button>&#xa0;
					 </span>
					<h2><xsl:value-of select="$language/user/add/new_user"/></h2>
				</section>

				<section class="item-sidebar" id="tools">
					<ul id="sorteable-0">
						<li class="header">
							<h3><xsl:value-of select="$language/user/add/access_level"/></h3>
						</li>
						<li class="collapsable avatar">
							<select name="access_level">
								<xsl:for-each select="content/levels/level">
									<option value="{@level_id}"><xsl:value-of select="name" /></option>
								</xsl:for-each>
							</select>
						</li>
					</ul>
				</section>

				<div class="floatFix">					
					<section class="item-body">

						<xsl:if test="$message != ''">
							<div class="alert" style="margin:0 0 15px;">
								<xsl:value-of select="$message" />
							</div>
						</xsl:if>
						<ul class="form">
							<li>
								<label><xsl:value-of select="$language/user/add/username"/></label>
								<input type="text" name="username" value=""/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/add/name"/></label>
								<input type="text" name="user_name" value="{$user/name | $user/user_name}"/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/add/lastname"/></label>
								<input type="text" name="user_lastname" value='{$user/lastname | $user/user_lastname}'/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/add/email"/></label>
								<input type="text" name="user_email" value="{$user/email | $user/user_email}"/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/add/password"/></label>
								<input type="password" name="user_pass0" value=""/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/add/repeat_password"/></label>
								<input type="password" name="user_pass1" value=""/>
							</li>
						</ul>
					</section>
				</div>
			</form>
		</div>
	</div>
</xsl:template>
</xsl:stylesheet>