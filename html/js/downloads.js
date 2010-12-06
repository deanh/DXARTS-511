// download.js
//
// Copyright (c) 2010 Harry Dean Hudson Jr., <dean@ero.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// *****
// * Top-level module
var DownloadData = (function () {
    var dateDict = {}; 
    var that = {};
    var territories = {
        "us":"US",
        "uk":"UK",
        "china":"CN",
        "japan":"JP",
        "canada":"CA"
    };

    var numTerritories = 5;
    var numLoaded      = 0;
    var eachDate       = {};

    var setupTerritory = function (ter) {
        var baseUrl = 'data/date_artist_title.';
        $.get(baseUrl + territories[ter] + '.json', function(data) {
            console.log("Loading " + ter + "...");
            that[ter] = data;
            dateDict[ter] = {};
            
            for (i = 0; i < that[ter].length; i++) {
                $.each(that[ter][i], function(k,v) {
                    dateDict[ter][k] = i;
                });
            }
        });
        numLoaded++;
        
        // all territories loaded, fire event
        if (numLoaded >= numTerritories) {
            $().trigger('dataLoaded');
        }
    }

    // Set up the data
    for(var t in territories) {
        setupTerritory(t);
    }

    return {
        territories: territories,
        dateDict: dateDict,
        data: that,
        countByTitle: function (ter, date) {
            var ret = {};
            if (dateDict[ter][date] !== undefined) {
                ret = that[ter][dateDict[ter][date]][date];
            }
            return ret;
        }
    };
})();
