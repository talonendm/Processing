PImage webImg;

void setup() {
  
  size(800,600);
  
  String url = "http://cdn.fmi.fi/legacy-fmi-fi-content/products/sea-level-observation-graphs/yearly-plot.php?station=12&lang=fi";
  // Load image from a web server
  webImg = loadImage(url, "png");
}

void draw() {
  background(0);
  image(webImg, 0, 0);
}
