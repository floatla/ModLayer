
$(document).ready(function(){

    var choose = document.getElementById('choose');
    FileAPI.event.on(choose, 'change', function (evt){
        var files = FileAPI.getFiles(evt); // Retrieve file list
        FU.onFiles(files);
    });
 
    /* Drag n Drop */
    if( FileAPI.support.dnd ){
        // $('#drop-area').css({"height" : $(window).width() + 'px'});
        $(document).dnd(function (over){
            $('#drop-zone').toggle(over);
        }, function (files){
            FU.onFiles(files);
        });
    }

    if(FU.handler === 'undefined'){
        modlayer.displayMessage('No se definió la función <i>"handler"</i> para el upload. Evite errores.');
    }
});





var FU = {

    accept : [],
    files: [],
    index: 0,
    active: false,
    handler: null,
    data : {},

    onFiles : function(files)
    {
        FileAPI.each(files, function (file)
        {
            // console.log(file);
            FU.add(file);
        });
    },

    add : function(file)
    {
        var isok = false;
        if(FU.accept.indexOf(file.type) !== -1){ isok = true; }
        var d = $(document.createElement('div')).attr({'class':'row', 'file_name': file.name});
        var p = $(document.createElement('p')).html(file.name);
        var b = $(document.createElement('div')).attr('class', 'progress-bar');
        var pr = $(document.createElement('span')).attr('class', 'percent').html((isok) ? '0%' : 'No permitido');

        d.append(p, d, b, pr);
        d.appendTo('#upload-progress');

        if(isok){
            FU.upload(file);
        }
    },

    upload : function(file)
    {
        if( file ){
            file.xhr = FileAPI.upload({
                url: adminpath + module + '/upload/',
                headers: { 'x-upload': 'modlayer-fileapi' },
                data: FU.data,
                files: { file: file },
                upload: function (){},
                progress: function (evt){
                    var c = $(".row[file_name='"+file.name+"']");
                    $(".progress-bar",c).css('width', evt.loaded/evt.total*100+'%');
                    $(".percent",c).html(evt.loaded/evt.total*100+'%');
                },
                complete: function (err, xhr){
                    var state = err ? 'error' : 'done';
                    var c = $(".row[file_name='"+file.name+"']");
                    $(".progress-bar",c).fadeOut();
                    $(".percent",c).html((err ? (xhr.statusText || err) : state));

                    // FU._getEl(file).removeClass('b-file_upload');
                    // FU._getEl(file, '.js-progress').animate({ opacity: 0 }, 200, function (){ $(this).hide() });
                    // FU._getEl(file, '.js-info').append(', <b class="b-file__'+state+'">'+(err ? (xhr.statusText || err) : state)+'</b>');

                    // FU.index++;
                    // FU.active = false;

                    // FU.start();
                    // FU.uploadComplete(xhr);
                    executeFunctionByName(FU.handler, window, xhr);
                }
            });
        }
    },

    uploadComplete : function(xhr)
    {
        FU.handler(xhr);
    }

}


function executeFunctionByName(functionName, context /*, args */) {
    var args = [].slice.call(arguments).splice(2);
    var namespaces = functionName.split(".");
    var func = namespaces.pop();
    for(var i = 0; i < namespaces.length; i++) {
        context = context[namespaces[i]];
    }
    return context[func].apply(context, args);
}