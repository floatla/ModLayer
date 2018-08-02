<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="accept" />
<xsl:param name="maxsize" />
<xsl:param name="maxsize_bytes" />

<xsl:template name="fileapi">

	<!-- 
		$handler : es el callback javascript para manejar 
		la respuesta una vez que se hace el upload 
	-->
	<xsl:param name="handler">undefined</xsl:param>
	
	<!-- 
		$formAction : si esta definido, se imprime un form con el atributo @action 
		con el valor de este parámetro.
		Se utiliza para editar datos de los archivos subidos por POST.
	-->
	<xsl:param name="formAction" />
	<!-- 
		$postParams : datos que se enviarán por post junto al subir el archivo.
		Se utilizan en dos lugares distintos. Con formato JSON para el upload por POST y 
		con formato HTML si se habilita la opción de editar los datos de los archivos subidos.
		Se debe utilizar la siguiente nomenclatura: name=value separados por | ej. -> name=test|id=4|category_id=15
	-->
	<xsl:param name="postParams">undefined</xsl:param>

	
	

	<!-- 
		Obtener datos de configuración 
	-->
	<xsl:choose>
		<xsl:when test="not($config/module/options/group[@name='accept']/option[@name='mime-type'])">
			<div class="alert">
				<xsl:value-of select="$language/file_api/error_config"/>
			</div>
		</xsl:when>
		<xsl:otherwise>
			<!-- <script src="{$adminPath}/ui/fileapi/FileAPI.init.js">&#xa0;</script> -->

			<!-- <script> 
				 FU.maxsize = <xsl:value-of select="$maxsize_bytes" />; 
				 FU.accept = [ 
			<xsl:for-each select="$config/module/options/group[@name='accept']/option[@name='mime-type']"> 
				'<xsl:value-of select="@value"  />' 
				<xsl:if test="position() != last()">,</xsl:if> 
			</xsl:for-each>]; 
				 FU.handler = "<xsl:value-of select="$handler"/>"; 
				 FU.data = {<xsl:call-template name="post.json"><xsl:with-param name="params" select="$postParams" /></xsl:call-template>}; 
			</script> -->

			<!-- <script>window.FileAPI = { staticPath: '<xsl:value-of select="$adminPath"/>/ui/fileapi/' };</script> -->
			<!-- <script src="{$adminPath}/ui/fileapi/FileAPI.min.js">&#xa0;</script> -->
			<!-- <script src="{$adminPath}/ui/fileapi/FileAPI.id3.js">&#xa0;</script>
			<script src="{$adminPath}/ui/fileapi/FileAPI.exif.js">&#xa0;</script> -->
			<link rel="stylesheet" type="text/css" href="{$adminPath}/ui/fileapi/FileAPI.css"/>

			<span class="right" style="font-size:11px;">
				<xsl:value-of select="$language/file_api/max_size"/>&#xa0;<xsl:value-of select="$maxsize"  /></span>
		    <!-- "js-fileapi-wrapper" required class -->
		    <div class="js-fileapi-wrapper upload-btn">
		        <div class="btn upload-btn__txt">
		        	<xsl:value-of select="$language/file_api/select_files"/>
		        </div>
		        &#xa0;<xsl:value-of select="$language/file_api/drag_files"/>
		        <input id="choose" name="files" type="file" multiple="multiple" class="button__input" /> <!-- accept="image/*" -->
		    </div>

			<div id="drop-zone" class="b-dropzone" style="display:none;">
				<div class="b-dropzone__bg">&#xa0;</div>
				<div class="b-dropzone__txt"><xsl:value-of select="$language/file_api/drop_files"/></div>
			</div>
			
			<div id="upload-progress"><xsl:comment/></div>
			
			<xsl:choose>
				<xsl:when test="$formAction != ''">
					<form name="update" action="{$formAction}" method="POST" data-count="0">
						<xsl:if test="$postParams!=''">
							<xsl:call-template name="post.html">
								<xsl:with-param name="params" select="$postParams"/>
							</xsl:call-template>
						</xsl:if>
						<div id="upload-container"><xsl:comment /></div>
						<div class="send">
							<button type="submit" class="btn lightblue"><xsl:value-of select="$language/item_editor/btn_save"/></button>
						</div>
					</form>	
				</xsl:when>
				<xsl:otherwise>
					<div id="upload-container"><xsl:comment /></div>
				</xsl:otherwise>
			</xsl:choose>
			

		</xsl:otherwise>
	</xsl:choose>

	<script type="text/javascript">
		window.FileAPI = { staticPath: '<xsl:value-of select="$adminPath"/>/ui/fileapi/' };
		requirejs(['admin/ui/fileapi/FileAPI.service'], function(FU){ 
			
			var upload = new FU();

			upload.SetMaxsize(<xsl:value-of select="$maxsize_bytes" />); 
			upload.AcceptedFormats([<!--  
			 --><xsl:for-each select="$config/module/options/group[@name='accept']/option[@name='mime-type']"> <!-- 
				 -->'<xsl:value-of select="@value"  />' <!-- 
				 --><xsl:if test="position() != last()">,</xsl:if> <!-- 
			 --></xsl:for-each>]); 
			<!-- upload.SetHandler(UploadHandler);  -->
			upload.SetPostParams({<xsl:call-template name="post.json"><xsl:with-param name="params" select="$postParams" /></xsl:call-template>});
			
			upload.BindActions(UploadHandler);
		});
	</script>
</xsl:template>


<xsl:template name="post.json"><!--
--><xsl:param name="params" /><!--
	--><xsl:choose><!--
		--><xsl:when test="contains($params, '|')"><!--
			--><xsl:call-template name="post.split.json"><!--
				--><xsl:with-param name="param" select="substring-before($params, '|')" /><!--
			--></xsl:call-template>,<!--
			--><xsl:call-template name="post.json"><!--
				--><xsl:with-param name="params" select="substring-after($params, '|')" /><!--
			--></xsl:call-template><!--
		--></xsl:when><!--
		--><xsl:otherwise><!--
			--><xsl:call-template name="post.split.json"><!--
				--><xsl:with-param name="param" select="$params" /><!--
			--></xsl:call-template><!--
		--></xsl:otherwise><!--
	--></xsl:choose><!--
--></xsl:template>

<xsl:template name="post.split.json"><!--
--><xsl:param name="param" /><!--
	-->"<xsl:value-of select="substring-before($param, '=')"/>" : "<xsl:value-of select="substring-after($param, '=')" />"<!--
--></xsl:template>


<xsl:template name="post.html">
<xsl:param name="params" />
	<xsl:choose>
		<xsl:when test="contains($params, '|')">
			<xsl:call-template name="post.split.html">
				<xsl:with-param name="param" select="substring-before($params, '|')" />
			</xsl:call-template>
			<xsl:call-template name="post.html">
				<xsl:with-param name="params" select="substring-after($params, '|')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="post.split.html">
				<xsl:with-param name="param" select="$params" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="post.split.html">
<xsl:param name="param" />
	<input type="hidden" name="{substring-before($param, '=')}" value="{substring-after($param, '=')}" />
</xsl:template>


</xsl:stylesheet>
