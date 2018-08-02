define([
		'jquery'
		, 'Util'
		, 'UI'
		, 'Language'
		, 'jForm'
	], 
	function (
		$
		, Util
		, UI
		, Language
		, jForm
	) {

	var ImageUpload = {

		bucketPath : '',
		default_categories : [],
		count : 0,

		uploadComplete : function(xhr)
		{
			var self = this;
			r = $.parseJSON(xhr.response);

	        if(r.code == 200){
	            // console.log(r);
	            self.editImage(r);
	        }
	        else
	        {
	            UI.RenderMessage(r.message);
	        }
		},

		editImage : function(json)
		{
			var self = this;
			var container    = $('#upload-container');
			var image        = Util.Create('div', {'class' : 'image-uploaded floatFix', 'id' : 'item'+json.id});
			var imageBox     = Util.Create('div', {'class' : 'preview'});
			var textBox      = Util.Create('div', {'class' : 'data'});
			var img          = Util.Create('img', {'src' : self.bucketPath + json.id.substr(json.id.length - 1)+'/'+json.id+'w200h200.'+json.extension});
			var inputId      = Util.Create('input', {
									"type": "hidden",
									"name": "ids[]",
									"class": "text",
									"value": json.id
								});

			var inputTitle   = Util.Create('input', {
									"type": "text",
									"name": "title_"+json.id,
									"class": "text",
									"value": json.name
								});
			var inputCredit   = Util.Create('input', {
									"type": "text",
									"name": "credit_"+json.id,
									"class": "text",
									"value": ''
								});
			var inputSummary =  Util.Create('textarea', {
									"type": "text",
									"name": "summary_"+json.id
								});
			var text1        = Util.Create('label').html(Language.translate('mod_language/modal/upload/image_title'));
			var text2        = Util.Create('label').html(Language.translate('mod_language/modal/upload/image_epigraph'));
			var text3        = Util.Create('label').html(Language.translate('mod_language/modal/upload/image_credits'));

			var left         = Util.Create('div', {'class' : 'left'});
			var right        = Util.Create('div', {'class' : 'right'});

			left.append(text1, inputTitle, text3, inputCredit);
			right.append(text2, inputSummary);
			image.append(imageBox.append(img), textBox.append(inputId, left, right));

			var categories = Util.Create('div', {"class" : "categories"});

			if(json.categories.length > 0){
				for(x in json.categories){
					var category        = json.categories[x];
					var categoriesTitle = Util.Create('div').addClass('boxtitle').html(parent.appLanguage.translate(category.title));
					var list            = Util.Create('ul');
					for(i in category.subcategories){
						var subcategory = category.subcategories[i];
						var item  = Util.Create('li');
						var input = Util.Create('input', {
										"type" : "checkbox",
										"name" : "categories_"+json.id+"[]",
										"value" : subcategory.category_id,
										"id" : "item_"+json.id+"_"+subcategory.category_id
									});
						var label = Util.Create('label' , {
										"for" : "item_"+json.id+"_"+subcategory.category_id
									})
									.html(subcategory.name);
						
						if(subcategory.selected == "1" || $.inArray(subcategory.category_id, self.default_categories) != '-1'){
							$(input).attr("checked", "checked");
						}
						if($.inArray(subcategory.category_id, self.default_categories) != '-1')
						{
							$(input).attr("disabled", "disabled");	
						}
						$(item).append(input, label);
						$(list).append(item);
					}
					$(categories).append(categoriesTitle, list);
				}
				image.append(categories);
			}

			container.append(image);

			self.count++;
			$('form[name=update]').attr('data-count', self.count);

			

			if($("form[name='update'] input[name='item_id']").length > 0 && self.count == 1)
			{
				var htmlstr = '<span style="display:inline-block;margin:0 10px 0 0;"><input type="checkbox" name="add_relation" value="1" id="adr"/> <label for="adr">'+Language.translate('mod_language/modal/upload/relate_on_save')+'</label></span>';
				$('.send').prepend(htmlstr);

				$("form[name='update']").submit(function(){
					if($("input[name=add_relation]").is(":checked"))
					{
						$('.send button').hide();
						$('.modal-controls').append('<img src="' + adminmod + '/ui/imgs/icons/ripple.svg" alt="" />');
						var options = { 
							success:       checkResponse
						};
						$(this).ajaxSubmit(options);
						return false;
					}
					else
					{
						return true;
					}
				});
				 
			}
		
		}
	}

	// post-submit callback 
	function checkResponse(json, statusText, xhr, $form)
	{
		if(json.code == 200)
		{
			parent.MultimediaService.updateView(json.item_id, json.typeid);
			parent.appUI.ClosePanel();
		}
	} 

	return ImageUpload;

	

});