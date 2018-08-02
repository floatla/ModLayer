define([
		'jquery'
		, 'Util'
		, 'UI'
		, 'autocomplete'
	], 
	function (
		$
		, Util
		, UI
		, autocomplete
	) {

	var category = {
		"_id"     : 0,
		"_module" : 0,
		"obj"     : null,

		BindActions : function(item_id, module)
		{
			var self = this;
			self._id     = item_id;
			self._module = module;
			$(document).ready(function(){

				$('.AutocompleteCategory').each(function(){

					var Cat = $(this);
					var pID = $(this).attr('parent_id');

					Cat.keypress(function(event){
						if(event.keyCode == 13){
							return false;
						}
					});	

					Cat.devbridgeAutocomplete({
						serviceUrl: adminpath + 'category/autocomplete/',
						params : {
							"parent_id" : pID
						},
						maxHeight : $(window).height() / 2,
						preserveInput : true,
						formatResult: self.FormatResult,
						onSelect: function (suggestion) {
							var args = {
								"item_id" : self._id,
								"item_module" : self._module,
								"name" : suggestion.value,
								"category_id" : suggestion.data.id,
								"parent_id" : pID
							};
							$(this).val('');
							category.setCategory(args);
						}
					});
				});

				$('ul[data-role="categories"] .remove').on('click', function(){
					var catID = $(this).attr('category_id');
					self.delete(catID, self._id);
				});
			});
		},

		FormatResult : function(suggestion, currentValue)
		{
			if (!currentValue) {
	            return suggestion.value;
	        }
	        
	        var pattern = '(' + Util.escapeRegExChars(currentValue) + ')',
	        responseValue = '', parent, image_id, image_type;

	        responseValue = suggestion.value
	            .replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>')
	            .replace(/&/g, '&amp;')
	            .replace(/</g, '&lt;')
	            .replace(/>/g, '&gt;')
	            .replace(/"/g, '&quot;')
	            .replace(/&lt;(\/?strong)&gt;/g, '<$1>');

			if(suggestion.data.parent_name != '')
			{

				// if(suggestion.data.image != 0){
				// 	image_id   = suggestion.data.image.image_id;
				// 	image_type = suggestion.data.image.type;
				// 	person += '<img src="/content/bucket/'+image_id.slice(-1)+'/'+image_id+'w80h80c.'+image_type+'" alt="" class="avatar"/>'; 
				// } else {
				// 	person += '<span class="no-pic"></span>';
				// }

				parent = "<span class='catparent'>" + suggestion.data.parent_name + " » </span>";;
				parent += responseValue;
				return parent;
			}

			// if(suggestion.data.type == 'venue')
			// {
			// 	person = '<div class="venue-suggest floatFix">';
			// 	if(suggestion.data.image != 0){
			// 		image_id   = suggestion.data.image.image_id;
			// 		image_type = suggestion.data.image.type;
			// 		person += '<img src="/content/bucket/'+image_id.slice(-1)+'/'+image_id+'w80h80c.'+image_type+'" alt="" class="pic"/>'; 
			// 	}
			// 	else {
			// 		person += '<span class="no-pic"></span>';
			// 	}
			// 	person += "<h4>" + responseValue + "</h4>";
			// 	person += "<span>" + suggestion.data.address + "</span>";
			// 	if(suggestion.data.region != '')
			// 		person += "<span>" + suggestion.data.region + "</span>";
			// 	person += '</div>';
			// 	return person;
			// }

			// if(suggestion.data.type == 'category')
			// {
			// 	person = '<div class="category-suggest floatFix">';
			// 	person += "<h4>" + responseValue + "</h4>";
			// 	if(suggestion.data.category_description){
			
			// 		person += "<span>" + suggestion.data.category_description + "</span>";
			// 	}
			// 	person += '</div>';
			// 	return person;
			// }

			// if(suggestion.data.type == 'tag')
			// {
			// 	person = '<div class="tag-suggest floatFix">';
			// 	person += "<h4>" + responseValue + "</h4>";
			// 	if(suggestion.data.tag != '')
			// 		person += "<span>" + suggestion.data.tag_description + "</span>";
			// 	person += '</div>';
			// 	return person;
			// }
			return responseValue;

	
		},

		setCategory : function(json)
		{
			// console.log(json);
			var self = this;
			self.obj = json;

			Util.ajaxCall({
					"m": "category",
					"action": 'AjaxSetCategory',
					"item_id": json.item_id,
					"module": json.item_module,
					"category_id" : json.category_id,
					"parent_id" : json.parent_id
				},
				{
					callback: this.setCategoryCallback,
					context: category
				}
			);
		},

		setCategoryCallback : function(json)
		{
			var self = this;
			if(typeof json == 'object')
			{
				if(json.code == 200)
				{
					var row  = Util.Create('li', {'item_id' : self.obj.category_id});
					var span = Util.Create('span');
					var del  = Util.Create('a', {
									'item_id' : self.obj.category_id,
									'class':'right icon remove category-delete',
									'href' : '#',
								}).html('Eliminar')
								.click(function(e){
									e.preventDefault();
									var id = $(this).attr('item_id');
									self.delete(id, self._id);
								});
					// 'onclick' : 'category.delete('+self.obj.category_id+', '+self.obj.item_id+');return false;'
					span.append(del, self.obj.name);
					row.append(span);

					$('.sidebar-box[data-type=category][parent='+self.obj.parent_id+'] ul').append(row);
					if( $('.item-edit').hasClass('state-1'))
						$('.item-edit').removeClass('state-1').addClass('state-3');
				}
				else
				{
					UI.RenderMessage(json.message);
				}
			}
			else
			{
				UI.RenderMessage(json);
			}
		},

		delete : function(category_id, object_id)
		{	
			this.id = category_id;

			Util.ajaxCall(
			{
				m: module,
				action:'BackUnlinkCategory',
				item_id: object_id,
				category_id: category_id
			},
			{
				callback: this.delete_callback,
				context: category
			});
		},

		delete_callback : function(json, textStatus, jqXHR)
		{
			if(typeof json == 'object')
			{
				if(json.code == 200)
				{
					$("*[module='category'] li[item_id="+json.category_id+"]").slideUp('fast', function(){$(this).remove()});
					if( $('.item-edit').hasClass('state-1'))
							$('.item-edit').removeClass('state-1').addClass('state-3');
				}
				else
				{
					UI.RenderMessage(json.message);
				}
			}
			else
			{
				UI.RenderMessage(json);
			}
		}
	}

	return category;

});