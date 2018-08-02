define(['jquery', 'Util', 'X2JS'], function ($, Util, X2JS) {

	var language = {

		path : null,
		data : {},
		expression : '',
		loaded : false,

		load : function()
		{
			return $.ajax({
				url: adminpath + 'langxml/', //dynamic url
				type: "GET",
				async : true,
				data: "module=" + module,
				dataType: 'xml',
				success: function(xml){
				    var x2js = new X2JS();
					language.data = x2js.xml2json(xml);
					language.loaded = true;
				}
			});
		},

		translate : function(s)
		{
			var ok = false;
			if(Util.isNull(language.data.xml)) { 
				var result = language.load();
				return s;
			}
			var o = s, m = s.replace('language', 'mod_language');

			ok = language.parse(m);
			if(ok) return ok;
			
			ok = language.parse(o);
			if(ok) return ok;

			return s;
		},

		parse : function(s)
		{
			// var s = language.expression;
			var o = language.data.xml;
			var a = s.split('/');
			for (var i = 0, n = a.length; i < n; ++i) {
				var k = a[i];
				if (k in o) {
					o = o[k];
				} else {
					// return s;
					return false;
				}
			}
			return o;
		}
	}
	return language;

});