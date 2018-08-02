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
        jmmenu:     'lib/jquery.mmenu.min.all',
        youtube :     'lib/youtube',
        videojs :     'lib/video',
        jplayer:       'lib/jplayer/jquery.jplayer',
        Util:       'app/view/util',
        Modal:      'app/view/modal',
        gallery:  'app/controller/gallery'
        // googleHome:  'app/controller/google_dfp_home.js',
        // googlePage:  'app/controller/google_dfp_page.js',
        // googleScript:  'app/controller/google_dfp_script.js',
        // googleSection:  'app/controller/google_dfp_section.js',

    },
    shim: {
        backbone: {
            deps: ['jquery', 'underscore'],
            exports: 'Backbone'
        },
        underscore: {
            exports: '_'
        },
        jmmenu: {
            deps: ['jquery'],
            exports: 'jmmenu'
        }
    },
    enviroment : 'dev'
});

require(['app/controller/main']);

