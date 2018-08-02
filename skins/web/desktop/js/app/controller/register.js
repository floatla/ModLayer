define(function (require) {
    var $     = require('jquery');
    var user  = require('app/model/user');

    $(function () {
        user.Register();
    });
});
