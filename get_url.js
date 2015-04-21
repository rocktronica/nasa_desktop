var page = require("webpage").create();
var system = require("system");

var apodUrl = "http://apod.nasa.gov/";

page.open(apodUrl, function(status) {
    var imageUrl = page.evaluate(function() {
        return document.querySelectorAll("a[href*='.jpg']")[0].href;
    });

    system.stdout.writeLine(imageUrl);

    phantom.exit();
});
