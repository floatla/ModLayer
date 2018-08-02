define([
	'jquery'
	, 'Util'
	, 'jForm'
	, 'Language'
], function(
	$
	, Util
	, jForm
	, Language
){

	var Autosave = {

		ch : '',
		back : 0,
		storage : [],

		BindActions : function()
		{
			var self = this;
			$(document).ready(function(){

				self.ask();
				$('input').bind('focus', function(){
					var name  = $(this).attr('name');
					var value = $(this).val();
					self.store(name, value);
				});
				$('input').bind('blur', function(){
					self.check($(this));
				});
				$('form[name=edit]').bind('submit', function(){
					self.unSet();
					return false;
				});
			});
		},

		store : function(name, value)
		{	
			var temp = {"name" : name, "value" : value};
			if(!this.get(name)){
				this.storage.push(temp);	
			}
			else{
				for(i in this.storage)
					if(name == this.storage[i].name) 
						this.storage[i].value = value;
			}
		},

		get : function(name)
		{
			var item = this.storage.filter(function(el) {return el.name == name;})
			return (item.length > 0) ? item[0] : false;
		},

		check : function(elem)
		{
			var name  = elem.attr('name');
			var value = elem.val();

			var item = this.get(name);
			if(!item) return false;

			if(item.value !== value){
				this.store(name, value);
				this.save();
			}
		},

		save : function()
		{
			var self = this;
			var form = $('form[name=edit]').clone();
			form.unbind('submit');

			var options = { 
				success: self.parse,  // post-submit callback 
				url: adminpath + module + '/autosave/'
			}; 

			// form.ajaxSubmit(options);
			form.ajaxForm(options);
			// bind to the form's submit event 
			form.submit(); 
		},

		parse : function(json, statusText, xhr, $form)
		{
			if(json.code != 200)
				window.appUI.RenderMessage(json.message);
		},

		ask : function()
		{
			var self = this;
			var id = $('input[name=item_id]').val();
			Util.ajaxCall(
				{
					m: module,
					action:'BackGetAutoSave',
					id: id
				},
				{
					callback: self.ask_callback,
					context: self
				}
			);
		},

		ask_callback : function(data, textStatus, jqXHR)
		{
			var self = this;
			if(data.code == 200)
			{
				if(confirm(Language.translate("mod_language/item_editor/autosave_confirm")))
				{
					setTimeout(function(){
						self.loadContent(data.item);
					}, 500);
					// this.loadContent(data.item);
				}
			}
		},

		loadContent : function(data)
		{
			for(x in data){
				value = data[x];
				// console.log(x);
				if(x != 'modToken'){
					
					var ed = tinyMCE.get(x);
					if(typeof ed == 'object' && !Util.isNull(ed)){
						ed.setContent(value);
					}
					else{
						// $('*[name="'+x+']"').attr({'value' : value});
						$("*[name="+x+"]").val(value);
					}
					
				}
			}
			this.clear();
		},

		clear : function()
		{
			var self = this;
			var id = $('input[name=item_id]').val();
			Util.ajaxCall(
				{
					m: module,
					action:'BackUnsetAutoSave',
					id: id
				},
				{
					callback: self.clear_callback,
					context: self
				}
			);
			return true;
		},

		clear_callback : function(data, textStatus, jqXHR)
		{
			// console.log(data);
		},

		unSet : function()
		{
			var self = this;
			var id = $('input[name=item_id]').val();
			Util.ajaxCall(
				{
					m: module,
					action:'BackUnsetAutoSave',
					id: id
				},
				{
					callback: self.unSet_callback,
					context: self
				}
			);
		},

		unSet_callback : function(data, textStatus, jqXHR) 
		{
			$('form[name=edit]').unbind('submit');
			// $('form[name=edit]').ajaxSubmit(formOptions);
			$('form[name=edit]').submit();
		}
	}

	return Autosave;

});


var ch, adminpath, module, back;



// var autosave = {

// 	storage : [],

	
// }