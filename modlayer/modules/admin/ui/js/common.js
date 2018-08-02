requirejs.config({
    // baseUrl: 'js/lib',
    paths: {
          'jquery' :         'admin/ui/js/lib/jquery-2.2.1.min'
        , 'backbone' :       'admin/ui/js/lib/backbone'
        , 'underscore' :     'admin/ui/js/lib/underscore'
        , 'select2' :        'admin/ui/js/lib/select2.min'
        , 'keyboard' :       'admin/ui/js/lib/backend.keyboard'
        , 'jquery-ui' :      'admin/ui/js/lib/jquery-ui'
        , 'autocomplete' :   'admin/ui/js/lib/jquery.autocomplete'
        , 'cookie' :         'admin/ui/js/lib/jquery.cookie'
        , 'jForm' :          'admin/ui/js/lib/jquery.form.min'
        , 'nestedSortable' : 'admin/ui/js/lib/jquery.mjs.nestedSortable'
        , 'timeago' :        'admin/ui/js/lib/jquery.timeago'
        , 'tooltipster' :    'admin/ui/js/lib/jquery.tooltipster.min'
        , 'modernizr' :      'admin/ui/js/lib/modernizr'
        , 'sortable' :       'admin/ui/js/lib/Sortable.min'
        , 'X2JS' :           'admin/ui/js/lib/xml2json'
        , 'datetime_es' :    'admin/ui/js/lib/datepicker-es'
        , 'jscolor' :        'admin/ui/js/lib/jscolor.min'


        , 'Language' :       'admin/ui/js/app/controller/language'
        , 'Util' :           'admin/ui/js/app/view/util'
        , 'UI' :             'admin/ui/js/app/view/ui'
        , 'Modal' :          'admin/ui/js/app/view/modal'
        , 'Sidepanel' :      'admin/ui/js/app/view/sidepanel'
        , 'Keyboard' :       'admin/ui/js/app/view/keyboard'
        , 'FileAPI' :        'admin/ui/fileapi/FileAPI.min'
        , 'FileAPI.id3' :    'admin/ui/fileapi/FileAPI.id3'
        , 'FileAPI.exif' :   'admin/ui/fileapi/FileAPI.exif'
        , 'datetime' :       'admin/ui/datetime/jquery-ui-timepicker-addon'

        , 'jCrop' :          'image/ui/js/jquery.jcrop'

        
    },
    shim: {
        backbone: {
            deps: ['jquery', 'underscore'],
            exports: 'Backbone'
        },
        underscore: {
            exports: '_'
        },
        Modal: {
            deps: ['jquery', 'Util'],
            exports: 'Modal'
        },
        cookie : {
            deps: ['jquery'],
            exports: 'cookie'
        },
        nestedSortable : {
            deps: ['jquery', 'jquery-ui'],
            exports : 'nestedSortable'   
        },
        datetime : {
            deps: ['jquery', 'jquery-ui'],
            exports : 'datetime'   
        },
        tooltipster: {
            deps: ['jquery'],
            exports: 'tooltipster'
        },
        timeago: {
            deps: ['jquery'],
            exports: 'timeago'
        },
        autocomplete: {
            deps: ['jquery'],
            exports: 'autocomplete'
        },
        jCrop: {
            deps: ['jquery'],
            exports: 'jCrop'
        },
        FileAPI : {
            deps: ['jquery'],
            exports: 'FileAPI'
        },
        "FileAPI.id3" : {
            deps: ['FileAPI'],
            exports: 'FileAPI.id3'
        },
        "FileAPI.exif" : {
            deps: ['FileAPI'],
            exports: 'FileAPI.exif'
        }

    },
    enviroment : 'dev'
});

require(['admin/ui/js/app/controller/main']);

