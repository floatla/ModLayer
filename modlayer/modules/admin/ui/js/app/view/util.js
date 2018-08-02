define(['jquery'], function($) {

	// function Utility() {}

	Utility = {

		Create : function(tag, attrs) {
			var t = $(document.createElement(tag));
			if(typeof attrs == 'object') {t.attr(attrs);}
			return t;
		},

		isObject : function(object){
			return typeof object == 'object';
		},

		isNull : function(input) {
			return input == null;
		},

		ajaxCall : function(options, callOptions)
		{
			var defaults = {
				m: 'element',
				action: null
			};
			options = $.extend(defaults, options);
			
			if(options.action == null){return false;}

			var dataStr = '';
			for(x in options){
				dataStr += x+'='+options[x]+'&';
			}

			var ajaxOptions = {
				type: "POST",
				async: true,
				cache: false,
				context: this,
				beforeSend: false,
				complete: false,
				callback: false,
				success: callOptions.callback,
				error: this.onError,
				url: adminpath,
				data: dataStr
			}

			callOptions = $.extend(ajaxOptions, callOptions);

			try {
				$.ajax(callOptions);
			}
			catch(e){
				alert(e);
			}

		},

		onError : function(err){
			window.appUI.RenderMessage(err.responseText);
		},

		callback_default: function(response){
			this.displayError("Uncaught Ajax Response:\n"+response);
		},

		parseQueryString : function(query)
		{
			var Params = {};
			if ( ! query ) {return Params;}// return empty object
			var Pairs = query.split(/[;&]/);
			for ( var i = 0; i < Pairs.length; i++ ) {
				var KeyVal = Pairs[i].split('=');
				if ( ! KeyVal || KeyVal.length != 2 ) {continue;}
				var key = unescape( KeyVal[0] );
				var val = unescape( KeyVal[1] );
				val = val.replace(/\+/g, ' ');
				Params[key] = val;
			}
			return Params;
		},

		getFormData : function($form){
			var unindexed_array = $form.serializeArray();
			var indexed_array = {};
			$.map(unindexed_array, function(n, i){
				indexed_array[n['name']] = n['value'];
			});
			return indexed_array;
		},

		trim : function(str){
			return str.substring(0,str.length-1);
		},

		escapeRegExChars: function (value) {
			return value.replace(/[|\\{}()[\]^$+*?.]/g, "\\$&");
		}

		
	}

	return Utility;

});