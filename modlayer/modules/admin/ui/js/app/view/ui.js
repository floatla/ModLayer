define([
		  'jquery'
		, 'Modal'
		, 'Sidepanel'
		, 'cookie'
		, 'tooltipster'
		, 'Util'
		, 'admin/ui/select2/js/select2.min'
	], function (
		$
		, Modal
		, Sidepanel
		, cookie
		, tooltipster
		, Util
		, select2
	) {
	
	var ui = {

		init : function()
		{
			/* Dropdown y Filtros */
			$('.dropdown .trigger, .filter .trigger').on('click', function(e){ 
				e.stopPropagation();
				// ui.closeMenus();
				var $element = $(this).parent();
				$element.toggleClass('open');
			});
			$('.filter').on('click', function(e){
				e.stopPropagation();
			});

			$('html').on('click', function(){
				ui.closeMenus();
			});

			$('.closeNav').on('click', function(){
				ui.closeMainNav();
			});

			$('body').focus();
			$.timeago.settings.strings = timeagoStr;
			$("abbr.timeago").timeago();
			
			$(".tooltip").tooltipster({'delay': 100});

			$(".select2").select2();

			if($('.list-header').length > 0){
				$('section.content').addClass('with-header');
			}

			$("*[data-action='link']").on('click', function(e){
				e.preventDefault();
				alert($(this).attr('href'));
			});

			$('.datefield').datetimepicker({
				dateFormat:      'yy-mm-dd',
				timeFormat:      'HH:mm:ss',
				changeYear:      true,
				changeMonth:     true,
				yearRange:       '1995:2025',
				dayNames:        ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
				dayNamesShort:   ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'],
				dayNamesMin:     ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
				monthNames:      ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
				monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
				closeText: "Cerrar",
				prevText: "&#x3C;Ant",
				nextText: "Sig&#x3E;",
				currentText: "Hoy",
				dayNamesMin: [ "Dom","Lun","Mar","Mie","Jue","Vie","Sab" ],
				weekHeader: "Sm",
				firstDay: 1,
				isRTL: false,
				showMonthAfterYear: false,
				yearSuffix: "",
				timeOnlyTitle: 'Horario',
				timeText: 'Horario',
				hourText: 'Hora',
				minuteText: 'Minutos',
				secondText: 'Segundos'
			});

			$('.dateonly').datepicker({
				dateFormat:      'yy-mm-dd',
				changeYear:      true,
				changeMonth:     true,
				yearRange:       '1995:2025',
				dayNames:        ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
				dayNamesShort:   ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'],
				dayNamesMin:     ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
				monthNames:      ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
				monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
				prevText: "&#x3C;Ant",
				nextText: "Sig&#x3E;",
				dayNamesMin: [ "Dom","Lun","Mar","Mie","Jue","Vie","Sab" ],
				weekHeader: "Sm",
				firstDay: 1,
				isRTL: false,
				showMonthAfterYear: false,
				yearSuffix: ""
			});

			$('.date-filter .close').click(function(){
				$(this).parent().find('.dateonly').val('');
				$(this).hide();
			});
			
		},

		closeMenus : function()
		{
			$('.dropdown, .filter, [data-role="dropdown"]').removeClass('open');
		},

		esc : function()
		{
			Modal.close();
			Sidepanel.close();
		},

		closeMainNav : function()
		{
			$('#navpanel').addClass('hidden');
			$.cookie('mainNav', 'hidden', {path: adminpath});
			var openbo = $(document.createElement('div')).attr('class', 'openNav').on('click', function(){
				ui.openMainNav();
			});
			$('#navpanel').append(openbo);
		},

		openMainNav : function()
		{
			$('#navpanel').removeClass('hidden');
			$('.openNav').remove();
			$.cookie('mainNav', 'visible', {path: adminpath});
		},

		RenderMessage : function(message)
		{
			// alert(message);
			html = '<div class="modal-header"><h3>Mensaje del sistema</h3></div>';
			html += '<div class="modal-body">';
			html += '<div class="innerHeight">';
			html += '<p>'+message+'</p>';
			html += '</div>';
			html += '</div>';
			
			// Modal.options.height = 'auto';
			Modal.loadHTML(html);

		},

		CreateNew : function()
		{
			window.location.href = adminpath+module+'/add/';
		},

		focusSearch : function()
		{
			$("input[name='q']").val('').focus();
		},

		SaveEditForm : function()
		{
			$("form[name='edit']").submit();
		},

		toggleFullScreen : function()
		{
			if(!this.fullscreen){
				var docElm = $('body')[0];
		        if      (docElm.requestFullscreen)       {docElm.requestFullscreen();}
		        else if (docElm.mozRequestFullScreen)    {docElm.mozRequestFullScreen();}
		        else if (docElm.webkitRequestFullScreen) {docElm.webkitRequestFullScreen();}
		        $('body').css({"width":"100%"});
		        this.fullscreen = true;
	    	}else{

	    		if      (document.exitFullscreen)         {document.exitFullscreen();}
	            else if (document.mozCancelFullScreen)    {document.mozCancelFullScreen();}
	            else if (document.webkitCancelFullScreen) {document.webkitCancelFullScreen();}
	            $('body').css({"width":"auto"});
	            this.fullscreen = false;
	    	}
		},

		SetOrder : function(evt, item_id)
		{
			var parent = $(evt.from);
			var orderModule = parent.attr('module');
			
			var list = []
			$('li', parent).each(function(i, v){
				var id = $(this).attr('item_id');
				list.push(id);
			});

			Util.ajaxCall(
			{
				m: module,
				action: 'BackSetOrder',
				item_id: item_id,
				relationModule: orderModule,
				list : JSON.stringify(list)
			},
			{
				callback: this.setOrderCallback,
				context: ui
			});
		},

		setOrderCallback : function(json)
		{
			if(typeof json == 'object')
			{
				if(json.code != 200) {
					ui.RenderMessage(json.message);
				}
			}
			else
			{
				ui.RenderMessage(json);
			}
			// console.log(json);
		},

		ClosePanel : function()
		{
			Sidepanel.close();
		},

		OpenPanel : function(url)
		{
			Sidepanel.load(url);
		},

		Translate : function(xpath)
		{
			return Language.translate(xpath);
		}
	}

	return ui;
});