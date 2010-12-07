// dLib.js
//
// A small library to help with canvas animation.
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
var dLib = (function () {

    var VERSION = '0.9.0';

    var canvas, context, sizeX, sizeY;
    var lastPoint = {};

    // *****
    // * +shapes+ is used internally by the core Core.draw() method: Core.draw()
    // * steps through the array and calls update() and draw() on each shape.
    // * Push shape objects onto this array in factory methods.
    var shapes = [];

    // *****
    // * Private methods    
    var appendTag = function (what, to) {
        return document.getElementsByTagName(to)[0].
            appendChild(document.createElement(what));
    };

    // *****
    // * Modules
    var helpers = {};
    var behavior = {};

    // *****
    // * dLib.Core: main functionality, exported under dLib
    var core = {
        VERSION: VERSION,

        // *****
        // * Sets up +canvas+ and +context+ objects for drawing and inserts
        // * them into the DOM
        setup: function (width, height) {
            width = width || 
                    getComputedStyle(document.getElementsByTagName('body')[0], "").
                    getPropertyValue('width');
            height = height || window.outerHeight - 150;
            canvas = appendTag("canvas", "body");
            canvas.setAttribute('width', width);
            canvas.setAttribute('height', height);
            canvas.setAttribute('id', 'canvas');
            //canvas.setAttribute('style', "border: 1px #000 solid");
            sizeX = parseInt(width); sizeY = parseInt(height);
            context = canvas.getContext('2d');
            return canvas;
        },

        // *****
        // * Returns a random integer between 0 and +max+
        randInt: function (max) {
            return Math.floor(Math.random()*max);
        },

        // *****
        // * Returns a random rgba string usable in the Canvas API
        randFill: function () {
            context || this.setup();
            var fill = "rgba(" + this.randInt(255) + ',' + 
                                 this.randInt(255) + ',' + 
                                 this.randInt(255) + ',1.0)';
            return fill;
        },

        // *****
        // * Circle factory class. Generates a circle, sets up its
        // * draw() method, and pushes it onto the +shapes+ array
        newCircle: function (startX, startY, startRad, startFill) {
            var circle = {
                x: startX,
                y: startY,
                radius: startRad,
                fill: startFill,
                draw: function() {
                    if (context !== undefined) {
                        context.beginPath();
                        context.arc(this.x, this.y, this.radius, 0, Math.PI*2, true); 
                        //context.arc(10, 20, 30, 0, Math.PI*2, true); 
                        context.closePath();
                        context.fillStyle = this.fill;
                        context.fill();
                    }
                }
            };
            shapes.push(circle);
            return circle;
        },

        // *****
        // * Text factory class. Generates a piece of text, sets up its
        // * draw method, and pushes it onto the +shapes+ array
        newText: function(str, startX, startY, startSize, startFill, startFont) {
            var text = {
                x: startX,
                y: startY,
                size: startSize,
                font: startFont,
                fill: startFill,
                text: str,
                draw: function () {
                    if (context !== undefined) {
                        context.font = ["normal", this.size, this.font].join(" ");
                        context.fillStyle = this.fill;
                        context.fillText(this.text, this.x, this.y);
                    }
                }
            };
            shapes.push(text);
            return text;
        },

        // *****
        // * Creates and draws a random circle of +max+ radius
        randCircle: function (max) {
            maxRadius =  max || 100;
            context || this.setup();
            var randInt = this.randInt;
            var circle =  this.newCircle(randInt(sizeX),
                                  randInt(sizeY),
                                  randInt(maxRadius),
                                  this.randFill());
            circle.draw();
            return circle;
        },

        // *****
        // * Creates and draws a random rectangle with width and
        // * height less than +max+
        randRect: function (max) {
            max = max || 100;
            context || this.setup();
            var randInt = this.randInt;
            context.fillRect(randInt(sizeX), randInt(sizeY), 
                             randInt(max), randInt(max));
            return this;
        },

        // *****
        // * Draws a rectangle to the canvas
        drawRect: function (x, y, width, height) {
            context.fillRect(x, y, width, height);
            return this;
        },

        // *****
        // * Draws a circle to the canvas
        drawCircle: function (x, y, radius) {
            context.arc(x, y, radius, 0, Math.PI*2, true);
            return this;
        },

        // *****
        // *
        drawPath: function (toPoint, fromPoint) {
            if (fromPoint === undefined) {
                fromPoint = lastPoint;
            }
            if (fromPoint.x === undefined || fromPoint.y === undefined) {
                throw "Oops";
            }
            if (fromPoint !== lastPoint) { 
                context.beginPath();
                context.moveTo(fromPoint.x, fromPoint.y);
            }

            context.lineTo(toPoint.x, toPoint.y);
            lastPoint.x = toPoint.x; lastPoint.y = toPoint.y;
            context.stroke();
            return this;
        },


        // *****
        // Rotates the canvas by +angle+ degrees
        rotate: function (angle) {
            context.translate(85, 0);  
            context.rotate(angle * Math.PI / 180);    
            context.rotate(angle);
            //context.save();
            return this;
        },

        // ******
        // * Generates a straight path between +lastPoint+ and a random
        // * point on the canvas
        randPath: function () {
            if (lastPoint.x === undefined || lastPoint.y === undefined) {
                lastPoint.x = this.randInt(sizeX);
                lastPoint.y = this.randInt(sizeY);
                console.log("In randPath(): lastPoint set to: " + 
                             lastPoint.x +", "+lastPoint.y);
            }
            this.drawPath(this.randPointNear(lastPoint));
            return this;
        },

        // *****
        // * Accessor for +lastPoint+. Used for creating paths over
        // * draw() iterations
        lastPoint: function () { return lastPoint; },

        // *****
        // * Return the +canvas+ size as a hash
        canvasSize: function () { return {x:sizeX, y: sizeY}},

        // *****
        // * Accessor for +shapes+, returns a copy
        shapes: function () { return shapes.slice(); },

        // *****
        // * Accessor for +context+
        context: function () { return context; },

        // *****
        // * Generates a random point within a square bounding box
        // * with +distance+ sides of +point+. Both +point+ and the
        // * return value respond to x and y
        randPointNear: function (point, distance) {
            dist = distance || 50;
            var start = { 
                 x: (point.x - dist) > 0 ? (point.x - dist) : 0, 
                 y: (point.y - dist) > 0 ? (point.y - dist) : 0 
            };
            return {  
                 x: (start.x + this.randInt(dist * 2)) % sizeX, 
                 y: (start.y + this.randInt(dist * 2)) % sizeY 
            };
        },

        // *****
        // * Update the document (or other DOM object) with
        // * +mouseX+ and +mouseY+. Needs to be set as an event
        // * handler.
        trackMouse: function (obj) {
            return function (e) {
                if (!e) var e = window.event;
                if (e.pageX || e.pageY) {
                    obj.mouseX = e.pageX;
                    obj.mouseY = e.pageY;
                } else if (e.clientX || e.clientY) 	{
                    obj.mouseX = e.clientX + document.body.scrollLeft
		        + document.documentElement.scrollLeft;
                    obj.mouseY = e.clientY + document.body.scrollTop
		        + document.documentElement.scrollTop;
                }
            };
        },

        // *****
        // * Clears the canvas and then steps through all the 
        // * objects in the +shapes+ array and
        // * calls update() and draw() on them if defined.
        draw: function () {
            var i = 0;
            var shape;

            context.clearRect(0, 0, sizeX, sizeY);

            for (i = 0; i < shapes.length; ++i) {
                shape = shapes[i];
                if (shape.update !== undefined) {
                    shape.update();
                }
                if (shape.draw !== undefined) {
                    shape.draw();
                }
            }
        }
    };

    return core;
})();
