requirejs.config({
    // baseUrl: 'js/lib',
    paths: {
        jquery :    'lib/jquery-2.2.1.min',
        backbone :    'lib/backbone',
        underscore :    'lib/underscore',
        jForm :     'lib/jquery.form.min',
        select2 :   'lib/select2.min',
        swiper :    'lib/swiper.min',
        blazy :     'lib/blazy.min',
        youtube :      'lib/youtube',
        videojs :      'lib/video',
        jplayer:       'lib/jplayer/jquery.jplayer',
        Util:       'app/view/util',
        Modal:      'app/view/modal',
        gallery:       'app/controller/gallery.js',
        galleryScript:  'app/controller/gallery_script.js'
    },
    shim: {
        backbone: {
            deps: ['jquery', 'underscore'],
            exports: 'Backbone'
        },
        youtube: {
            deps: ['videojs'],
            exports: 'youtube'
        },
        underscore: {
            exports: '_'
        }
    },
    enviroment : 'dev'
});

require(['app/controller/main']);

