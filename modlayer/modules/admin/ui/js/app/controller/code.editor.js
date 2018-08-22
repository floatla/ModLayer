define([
		'jquery'
		, 'admin/ui/codemirror/lib/codemirror'
		, 'admin/ui/codemirror/addon/hint/show-hint'
		, 'admin/ui/codemirror/addon/hint/xml-hint'
		, 'admin/ui/codemirror/mode/xml/xml'
	], 
	function (
		$
		, CodeMirror
	) {

	var Editor = {

		tags : {
			"!top": ["top"],
			"!attrs": {
				id: null,
				class: ["A", "B", "C"]
			},
			object: {
				attrs: {
					id: null,
				},
				children: ["allow", "params"]
			},
			module: {
				attrs: {
					name: null,
				}
			},
			allow : {
				attrs: {},
				children: ["module"]
			},
			tr : {
				attrs: {},
				children: ["td"]
			},
			td: {
				attrs: {
					width: null,
					height: null
				},
				children: ["object"]
			},
			params: {
				attrs: {},
				children: ["param"]
			},
			param: {
				attrs: {
					name: null,
					value: null
				}
			},
		},

		Render : function(id)
		{
			var self = this;
			var completeAfter = function(cm, pred) {
				var cur = cm.getCursor();
				if (!pred || pred()) setTimeout(function() {
					if (!cm.state.completionActive)
					cm.showHint({completeSingle: false});
				}, 100);
				return CodeMirror.Pass;
			}

			var completeIfAfterLt = function(cm) {
				return completeAfter(cm, function() {
					var cur = cm.getCursor();
					return cm.getRange(CodeMirror.Pos(cur.line, cur.ch - 1), cur) == "<";
				});
			}

			var completeIfInTag = function(cm) {
				return completeAfter(cm, function() {
					var tok = cm.getTokenAt(cm.getCursor());
					if (tok.type == "string" && (!/['"]/.test(tok.string.charAt(tok.string.length - 1)) || tok.string.length == 1)) return false;
					var inner = CodeMirror.innerMode(cm.getMode(), tok.state).state;
					return inner.tagName;
				});
			}

			CodeMirror.fromTextArea(document.getElementById(id), {
				mode: "xml",
				lineNumbers: true,
				extraKeys: {
					"'<'": completeAfter,
					"'/'": completeIfAfterLt,
					"' '": completeIfInTag,
					"'='": completeIfInTag,
					"Ctrl-Space": "autocomplete"
				},
				hintOptions: {schemaInfo: self.tags}
			});
		}
	}

	return Editor;
});