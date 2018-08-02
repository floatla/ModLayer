<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:param name="message" />
<xsl:param name="pass" />


<xsl:variable name="htmlHeadExtra">
	<xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$modPath"/>/ui/js/users.js
		</xsl:with-param>
	</xsl:call-template>
	<style>.panel-form {padding:20px;background:#f0f0f0;margin:15px auto 0;border-radius:5px;}</style>
</xsl:variable>

<xsl:template name="content">
	<xsl:attribute name="class">content</xsl:attribute>
	<div class="item-edit">
		<div class="panel-form">
			<xsl:variable name="user" select="content/user" />
			<form name="user" action="{$adminroot}?m={$config/module/@name}&amp;action=EditMyData" method="post">
				<input type="hidden" name="user_id" value="{$user/@user_id}" />
				<div class="floatFix">
					<section class="item-sidebar" id="tools">
						<div class="sidebar-box">
							<label><xsl:value-of select="$language/user/profile/send_by_email" /></label>
							<ul>
								<li>
									<a id="sendEmail" class="btn" href="#" onclick="sendMail({$user/@user_id});return false;"><xsl:value-of select="$language/user/profile/btn_send" /></a>
								</li>
							</ul>
						</div>
					</section>

					<section class="item-body">
						<xsl:if test="$message!=''">
							<div class="alert" style="margin:0 0 15px;">
								<xsl:value-of select="$message" />
							</div>
						</xsl:if>
						<ul class="form">
							<li>
								<label><xsl:value-of select="$language/user/profile/username" /></label>
								<input type="text" name="username" value="{$user/username}"/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/profile/name" /></label>
								<input type="text" name="user_name" value="{$user/name | $user/user_name}"/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/profile/lastname" /></label>
								<input type="text" name="user_lastname" value='{$user/lastname | $user/user_lastname}'/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/profile/email" /></label>
								<input type="text" name="user_email" value="{$user/email | $user/user_email}"/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/profile/old_password" /></label>
								<input type="password" name="user_password" value=""/>
								<p></p>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/profile/new_password" /><!--(actual: <xsl:value-of select="$pass" />)--></label>
								<input type="password" name="user_pass0" value=""/>
							</li>
							<li>
								<label><xsl:value-of select="$language/user/profile/repeat_new_password" /></label>
								<input type="password" name="user_pass1" value=""/>
								<p></p>
							</li>
						</ul>
					</section>

					<section class="edit-header floatFix">
						<span class="right">
							<a href="{$adminroot}users/list/" class="btn"><xsl:value-of select="$language/user/profile/btn_back_no_save" /></a>&#xa0;
							<button type="submit" name="back" value="1" class="btn save-back"><span><xsl:value-of select="$language/user/profile/btn_back_save" /></span></button>&#xa0;
							<button type="submit" class="btn color"><span><xsl:value-of select="$language/user/profile/btn_save" /></span></button>&#xa0;
						 </span>
						<h2><xsl:value-of select="$language/user/profile/head_title" /></h2>
					</section>
				</div>
			</form>
		</div>
	</div>
</xsl:template>
</xsl:stylesheet>