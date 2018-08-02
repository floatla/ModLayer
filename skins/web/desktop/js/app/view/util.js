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
		}
	}

	return Utility;

});