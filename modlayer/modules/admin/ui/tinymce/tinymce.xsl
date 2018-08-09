<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />


<!-- Tiny Mce: Added for different instances with different options in the same page -->
<xsl:template name="tiny_mce.src">
	<xsl:call-template name="include.js">
		<xsl:with-param name="url">
			<xsl:value-of select="$adminPath"/>/ui/tinymce/tinymce.min.js
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="tiny_mce.simple">
	<xsl:param name="elements">summary</xsl:param>
	<xsl:param name="width">500</xsl:param>
	<xsl:param name="height">200</xsl:param>
	<xsl:param name="css"><xsl:value-of select="$adminPath"/>/ui/css/editor.css</xsl:param>

	<!-- Encapsulate tinymce.init into a function to load on demand (for hidden areas) -->
	<xsl:param name="funcname" />
	<xsl:variable name="autosave" select="$config/module/options/group[@name='settings']/option[@name='autosave']" />
	
	<script type="text/javascript">
		<xsl:if test="$funcname != ''">function <xsl:value-of select="$funcname" />(){</xsl:if>
		tinymce.init({
			mode : "exact",
			menubar:false,
		    selector: "<xsl:value-of select="$elements" />",
			<!-- width: '<xsl:value-of select="$width" />', -->
			height: '<xsl:value-of select="$height" />',
			plugins: [
				"autolink link <xsl:if test="$autosave/@value = 'true'">autosave</xsl:if>",
				"searchreplace wordcount visualblocks visualchars code insertdatetime nonbreaking",
				"contextmenu paste textcolor"
			],
			setup: function (editor) {
				editor.on('change', function () {
				    editor.save();
				});
			},
			toolbar: "bold italic", 
			image_advtab: true,
			language : 'es',

			convert_urls : false,
			content_css: "<xsl:value-of select="$css"/>?v=<xsl:value-of select="$horaActual"/>",
			valid_elements : "-p,a[href|target=_blank],-strong/b,em/i,br,p[style]",
			entity_encoding : "raw"
		 });
		 <xsl:if test="$funcname != ''">}</xsl:if>
	</script>
</xsl:template>


<xsl:template name="TinyMce">
	<xsl:param name="elements">content</xsl:param>
	<xsl:param name="selector">mceAdvanced</xsl:param>
	<xsl:param name="width">500</xsl:param>
	<xsl:param name="height">200</xsl:param>
	<xsl:param name="item_id">0</xsl:param>
	<xsl:param name="item_module">0</xsl:param>
	<xsl:param name="css"><xsl:value-of select="$adminPath"/>/ui/css/editor.css</xsl:param>

	<!-- 
		Encapsulate tinymce.init into a function to load on demand (for hidden areas) 
	-->
	<xsl:param name="funcname" />

	<!-- 
		Module configuration Params 
		being sended to plugin
	-->
	<xsl:variable name="options" select="$config/module/options" />
	<xsl:variable name="multimedias" select="$options/group[@name='multimedias']" />
	<xsl:variable name="relations" select="$options/group[@name='relations']" />

	
	<xsl:variable name="m_plugins" select="$options/group[@name='tinymce']/option[@name='plugins']" />
	<xsl:variable name="m_toolbar" select="$options/group[@name='tinymce']/option[@name='toolbar']" />
	<xsl:variable name="m_extradata" select="$options/group[@name='tinymce']/option[@name='extradata']" />
	<xsl:variable name="m_css" select="$options/group[@name='tinymce']/option[@name='css']" />


	<xsl:variable name="toolbar"><!-- 
		 -->styleselect | bold italic forecolor table | removeformat | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link  fullscreen | <!-- 
		 --><xsl:if test="$config/module/@name = 'article'"> m_assets</xsl:if><!-- 
		 --><xsl:if test="$multimedias/option[@name='image']"> m_image</xsl:if><!-- 
		 --><xsl:if test="$multimedias/option[@name='audio']"> m_audio</xsl:if><!-- 
		 --><xsl:if test="$multimedias/option[@name='document']"> m_document</xsl:if><!-- 
		 --><xsl:if test="$relations/option[@name='clip']"> m_clip</xsl:if><!-- 
		 --><xsl:if test="$relations/option[@name='poll']"> m_poll</xsl:if><!-- 
		 --><xsl:if test="$m_toolbar/@value"><xsl:value-of select="$m_toolbar/@value"/></xsl:if><!-- 
	 --></xsl:variable>


	<script type="text/javascript">
		var ModConf = {
			id       : <xsl:value-of select="$item_id" />,
			module   : '<xsl:value-of select="$item_module" />',
			image    : <!-- 
		 --><xsl:choose>
				<xsl:when test="$multimedias/option[@name='image']">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>,
			document : <!-- 
		 --><xsl:choose>
				<xsl:when test="$multimedias/option[@name='document']">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>,
			audio    : <!-- 
		 --><xsl:choose>
				<xsl:when test="$multimedias/option[@name='audio']">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>,
			clip     : <!-- 
		 --><xsl:choose>
				<xsl:when test="$relations/option[@name='clip']">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>,
			poll     : <!-- 
		 --><xsl:choose>
				<xsl:when test="$relations/option[@name='poll']">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>,
			assets   : <!-- 
		 --><xsl:choose>
				<xsl:when test="$config/module/@name = 'article'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>,
			autosave : <!-- 
		 --><xsl:choose>
				<xsl:when test="$options/group[@name='settings']/option[@name='autosave']/@value = 'true'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>

			
		}
		<xsl:if test="$funcname != ''">function <xsl:value-of select="$funcname" />(){</xsl:if>
		tinymce.init({
			mode : "exact",
			selector: "<xsl:value-of select="$elements" />",
			<!-- width: '<xsl:value-of select="$width" />', -->
			height: '<xsl:value-of select="$height" />',
			menubar: 'edit insert view format tools',
			plugins: [
				"<xsl:if test="$m_plugins/@value"><xsl:value-of select="$m_plugins/@value"/></xsl:if> modlayer advlist autolink link lists charmap preview hr anchor",
				"searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime nonbreaking",
				"contextmenu directionality emoticons paste textcolor table"
			],
			paste_as_text: true,
			toolbar: "<xsl:value-of select="$toolbar" /> ModConf.clip",
			setup: function (editor) {
				editor.on('change', function () {
				    editor.save();
				});
				<!-- editor.on('load', function () {
				    assets.place(editor);
				}); -->
			},
			<xsl:if test="$m_extradata/text()"><xsl:apply-templates select="$m_extradata" mode="replaceTags"/></xsl:if>
			style_formats: [
				{"title": "Titulos", "items": [
					{"title": "Header 1", "format": "h1"},
					{"title": "Header 2", "format": "h2"},
					{"title": "Header 3", "format": "h3"},
					{"title": "Header 4", "format": "h4"},
					{"title": "Techo", "selector": "h1,h2,h3,h4", "classes": "head"}
				]},
				{"title": "Inline", "items": [
					{"title": "Bold", "icon": "bold", "format": "bold"},
					{"title": "Italic", "icon": "italic", "format": "italic"},
					{"title": "Underline", "icon": "underline", "format": "underline"},
					{"title": "Strikethrough", "icon": "strikethrough", "format": "strikethrough"},
					{"title": "Superscript", "icon": "superscript", "format": "superscript"},
					{"title": "Subscript", "icon": "subscript", "format": "subscript"},
					{"title": "Code", "icon": "code", "format": "code"}
				]},
				{"title": "Blocks", "items": [
					{"title": "Recuadro Centrado", "block": "recuadro", "classes" : "recuadro-center"},
					{"title": "Recuadro Izquierda", "block": "recuadro", "classes" : "recuadro-left"},
					{"title": "Recuadro Derecha", "block": "recuadro", "classes" : "recuadro-right"},
					{"title": "Parrafo", "format": "p"},
					{"title": "Bloque de cita", "format": "blockquote"},
					{"title": "Sin formato", "format": "pre"},
					{"title": "Caja de Clip (para limpiar formato)", "block": "m_clip"}
				]}
			],
			table_default_attributes: {
				class: 'inline-table'
			},
			language : 'es',
			extended_valid_elements : "external[*],slideshow[item_id|type|ids],embed[*],m_poll[*],img[*],m_audio[*],m_document[*],m_clip[*],script[*],m_image[id|size|align|image_type|caption],m_gallery_embed[*],recuadro[class]",
			custom_elements: "external,m_image,m_gallery_embed,m_document,m_clip,m_audio,m_poll,recuadro",
			valid_children : "+m_audio",
			object_resizing : false,
			convert_urls : false,
			content_css: "<xsl:value-of select="$css"/>?v=<xsl:value-of select="$horaActual"/><!-- 
			 	 --><xsl:if test="$m_css/text()">,<xsl:apply-templates select="$m_css" mode="replaceTags"/></xsl:if><!-- 
			 -->",
			item_id : <xsl:value-of select="$item_id"/>,
			item_module : "<xsl:value-of select="$item_module"/>",
			modconf : ModConf,
			autosave_ask_before_unload: true,
			entity_encoding : "raw"
		});
		<xsl:if test="$funcname != ''">}</xsl:if>
	</script>
</xsl:template>

</xsl:stylesheet>