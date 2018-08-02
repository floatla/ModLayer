<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:param name="error" />
<xsl:param name="nota_id" />
<xsl:param name="mensaje" />


<xsl:variable name="htmlHeadExtra"></xsl:variable>


<xsl:variable name="dinamicHead">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Feeds RSS | <xsl:value-of select="$config/system/applicationID" /></title>
	<xsl:apply-templates select="$config/skin/header/*[not(name()='title')]" mode="htmlhead"/>
</xsl:variable>




<xsl:template name="content">

		<section class="content">
	
			<article class="viewitem">
				<h2 class="gray-title large" style="padding:0">Contenidos por Rss</h2>
				<p><strong>RSS</strong> son las siglas de <strong>Really Simple Syndication</strong>, un formato <a class="mw-redirect" title="XML" href="http://es.wikipedia.org/wiki/XML">XML</a> para indicar o compartir contenido en la web. Se utiliza para difundir <a title="Información" href="http://es.wikipedia.org/wiki/Informaci%C3%B3n">información</a>&#xa0;<a title="Presente (tiempo)" href="http://es.wikipedia.org/wiki/Presente_%28tiempo%29">actualizada</a> frecuentemente a usuarios que se han suscrito a la fuente de contenidos. El formato permite distribuir contenidos sin necesidad de un navegador, utilizando un software diseñado para leer estos contenidos RSS (<a title="Agregador" href="http://es.wikipedia.org/wiki/Agregador">agregador</a>). A pesar de eso, es posible utilizar el mismo navegador para ver los contenidos RSS. Las últimas versiones de los principales navegadores permiten leer los RSS sin necesidad de software adicional. RSS es parte de la familia de los formatos <a class="mw-redirect" title="XML" href="http://es.wikipedia.org/wiki/XML">XML</a> desarrollado específicamente para todo tipo de sitios que se actualicen con frecuencia y por medio del cual se puede compartir la información y usarla en otros sitios web o programas. A esto se le conoce como <a title="Redifusión web" href="http://es.wikipedia.org/wiki/Redifusi%C3%B3n_web">redifusión web</a> o <em>sindicación web</em> (una traducción incorrecta, pero de uso muy común).</p>

				<h2 class="techo">Contenido disponible</h2>
				<p>
					Podrá acceder a todas las notas publicadas en las distintas secciones del sitio. Es un servicio sin cargo de actualización constante.
				</p>


				<p>
					Para ver el feed RSS ingrege en la siguiente dirección:

					<span class="feed-url">
						<a href="{$config/system/domain}/rss/feed/">
							<xsl:value-of select="$config/system/domain" />/rss/feed/
						</a>
					</span>
				</p>
			</article>
			

		</section>
	
	
</xsl:template>


</xsl:stylesheet>