/*
 * @name Objects
 * @description Create a Jitter class, instantiate an object,
 * and move it around the screen. Adapted from Getting Started with
 * Processing by Casey Reas and Ben Fry.
 
 * 160720:
 * objects example edited.
 * [ https://github.com/processing/p5.js/issues/193 ]
 * window.onresize added and canvas variable
 * see: ftp://talonen.asuscomm.com/sda1/public/objects/index.html
 
 
 */
var bug;  // Declare object
var canvas;

function setup() {
  // createCanvas(710, 400);

  canvas = createCanvas(window.innerWidth, window.innerHeight);
  // Create object
  bug = new Jitter();
}

function draw() {
  background(50, 89, 100);
  bug.move();
  bug.display();
}

window.onresize = function() {
  var w = window.innerWidth;
  var h = window.innerHeight;  
  canvas.size(w,h);
  width = w;
  height = h;
};

// 160720
// https://p5js.org/examples/demos/Hello_P5_Interactivity_1.php
// When the user clicks the mouse
function mousePressed() {
  // Check if mouse is inside the circle
  // var d = dist(mouseX, mouseY, 360, 200);
  //if (d < 100) {
    // Pick new random color values
  //  r = random(255);
  //  g = random(255);
  //  b = random(255);
  // }
  bug = new Jitter();
  
}


// Jitter class
function Jitter() {
  this.x = random(width);
  this.y = random(height);
  this.diameter = random(10, 30);
  this.speed = 3;

  this.move = function() {
    this.x += random(-this.speed, this.speed);
    this.y += random(-this.speed, this.speed);
  };

  this.display = function() {
    ellipse(this.x, this.y, this.diameter, this.diameter);
  }
};
