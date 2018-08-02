<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />
<xsl:strip-space elements="*" />

<xsl:param name="next" />
<xsl:param name="email" />
<xsl:param name="message" />
<xsl:param name="call" />
<xsl:variable name="release" select="/xml/configuration/system/release" />
<xsl:variable name="language" select="/xml/configuration/language" />


<xsl:template match="/xml">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
	<title>Admin: <xsl:value-of select="configuration/system/applicationID" /></title>
	<style type="text/css">
		/* Box model */
		*, *:before, *:after { -webkit-box-sizing: border-box;  -moz-box-sizing: border-box;  box-sizing: border-box; }

		html {height:100%;}
		body{
			background-color:#3f4658 !important;
			background-image:url("../imgs/logo_new-w.svg");
			background-position: left bottom;
			background-repeat: no-repeat;
			background-size:180px, auto;
			margin:0 0 0 0;
			color:#666;
			height:100%;
			font-family:"Helvetica Neue", Helvetica, Arial, sans-serif;
		}
		.left {float:left;}
		.right {float:right;}
		a, img {text-decoration: none;border:0;}

		header {
			display:block;
			padding:15px 15px 12px;
			font-size:28px;
			margin:-20px -20px 20px;
			border-bottom:1px solid #d0d0d0;
			font-family: 'source_sans_prolight', 'Helvetica Neue', Helvetica, Arial,sans-serif;
		}
		#loginbox {
			max-width:340px;
			background:#fff;
			padding:20px 20px 50px;
			position:relative;
			top:15%;
			margin:auto;
			border-radius:5px;
			box-shadow: 0 17px 50px -20px rgba(0, 0, 0, 0.19), 0 12px 15px -10px rgba(0, 0, 0, 0.24);
			/*left:50%;*/
			/*transform:translate(-50%, -50%);*/
		}
		#loginbox input[type='text'],
		#loginbox input[type='password'] {width:300px;height:auto;line-height:21px;padding:8px;font-size:17px;margin:5px 0 20px;border:1px solid #c0c0c0;border-color: rgba(94, 135, 168, 0.5);}
		#loginbox label {font-size:16px;line-height:19px;color:#999;font-weight:normal;}


		.alert { margin:0 0 20px; }
		.alert {
			padding: 8px 35px 8px 14px;
			margin:10px 0 18px;
			background-color: #fcf8e3;
			border: 1px solid #fbeed5;
			-webkit-border-radius: 4px;
			-moz-border-radius: 4px;
			border-radius: 4px;
			color: #c09853;
			line-height: 20px;
			font-size:14px;
		}


		/* Botones */
		.btn:visited, .btn:link {color:#000;}
		.btn {
		  border: 0 none;
		  border-radius: 20px;
		  padding: 6px 15px;
		  margin: 0 0 0 5px;
		  cursor: pointer;
		  text-align: center;
		  line-height: 16px;
		  font-size: 14px;
		  background: #e0e0e0;
		  color: #000;
		  text-transform: none;
		  display:inline-block;
		  font-weight: 400;
		  -webkit-transition: all 100ms ease-in-out;
		  transition: all 100ms ease-in-out;
		  display:inline-block;
		}
		.btn:hover {
		  opacity: .9;
		}
		.btn:active {
		  opacity: .75;
		  -webkit-transform: scale(0.95);
		  -moz-transform: scale(0.95);
		  transform: scale(0.95);
		}

		.btn.dark {
		  background: #333030;
		  color: #FFFFFF;
		}

		.btn.green {
		  background: #3ac569;
		  color: #FFFFFF;
		}

		.btn.blue {
		  background: #127CE6;
		  color: #FFFFFF;
		}

		.btn.lightblue {
		  background:#2b90d9;
		  color:#fff;
		}



		input[type="text"]:focus,
		input[type="password"]:focus,
		textarea:focus,
		select:focus {
		  /*border-color: rgba(94, 135, 168, 0.5);*/
		  background:#ddeefb;
		  border-color: rgba(39, 160, 218, 0.6);
		  -webkit-box-shadow: 0 2px 6px -3px rgba(71, 147, 209,.25) inset;
		  -moz-box-shadow: 0 2px 6px -3px rgba(71, 147, 209,.25) inset;
		  box-shadow: 0 2px 6px -3px rgba(71, 147, 209,.25) inset;
		}

		input[type="text"],
		input[type="password"],
		input[type="number"],
		textarea,
		select {
		  background:#fff;
		  color:#454545;
		  outline:0;
		  -moz-box-shadow:0 2px 4px -3px rgba(0,0,0,.25) inset;
		  -o-box-shadow:0 2px 4px -3px rgba(0,0,0,.25) inset;
		  -webkit-box-shadow:0 2px 4px -3px rgba(0,0,0,.25) inset;
		  box-shadow:0 2px 4px -3px rgba(0,0,0,.25) inset;
		  -moz-border-radius: 0;
		  -o-border-radius: 0;
		  -webkit-border-radius: 0;
		  border-radius: 0;
		  border:1px solid #dbdbdb;
		  margin:0;
		  font:normal 14px/17px arial,sans-serif;
		  padding:3px 5px;
		  vertical-align:middle;
		  -webkit-transition: all 0.2s ease;
		  -moz-transition: all 0.2s ease;
		  -ms-transition: all 0.2s ease;
		  -o-transition: all 0.2s ease;
		  transition: all 0.2s ease;
		}

		input[type="text"],
		input[type="password"], {height:26px;}
		input[type="submit"],
		input[type="reset"],
		input[type="button"],
		input[type="radio"],
		input[type="checkbox"],
		input[type="number"] {
		  width: auto;
		}

		input[type="checkbox"],
		input[type="radio"] {
		    margin:0 3px 0 5px;
		    vertical-align: 1px;
		}
		
	</style>
</head>
<body>
	<div id="loginbox" class="floatFix">
		<header>
			<xsl:value-of select="/xml/configuration/system/applicationID"/>
		</header>
			<xsl:if test="$message!=''">
				<div class="alert">
					<xsl:value-of select="$message" disable-output-escaping="yes"/>
				</div>
			</xsl:if>
			<form name="user" action="{$adminroot}login/run" method="post" id="user" autocomplete="off">
				<xsl:choose>
					<xsl:when test="not(contains($next,'firstrun.php'))">
						<input type="hidden" name="next" value="{$next}" />
					</xsl:when>
					<xsl:otherwise>
						<input type="hidden" name="next" value="{$adminroot}" />
					</xsl:otherwise>
				</xsl:choose>
				<label><xsl:value-of select="/xml/configuration/language/login/label_user" /></label>
				<input type="text" name="username" autofocus="autofocus" />
				<label><xsl:value-of select="$language/login/label_pass" /></label>
				<input type="password" name="password" />

				<button class="btn right lightblue" type="submit"><xsl:value-of select="$language/login/btn_login"/></button>
			</form>
	</div>
	
	<xsl:if test="$debug=1">
		<xsl:call-template name="debug" />
	</xsl:if>
</body>
</html>

</xsl:template>
</xsl:stylesheet>