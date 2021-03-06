/**
 
 160722 * ref: [Multiple constructors]: scaled data on screen
 160723 * TODO: information: speed, distances
 1607xx * pinch, distance, mark interesting place. time spent in ball, if more than 1.
 
 
 */


// not needed in JAVA mode, but in Android mode
// https://developer.android.com/reference/java/util/ArrayList.html
import java.util.*;

// 

// --------------------------
// Android stuff:
boolean androidi = false;
// --------------------------
// Ketai can be imported in JAVA mode too...
import ketai.sensors.*; 
KetaiLocation location;
// --------------------------
double longitude, latitude, altitude, accuracy;
// --------------------------
ArrayList <Spot> sp = new ArrayList <Spot>();

// --------------------------
// for JAVA debugging
// --------------------------
boolean walk = true;
int dev_suuntax = 1;
int dev_suuntay = 1;
int dev_speed = 5; //1; //20; // debugging speed
// --------------------------

// --------------------------
// map scaling:
// --------------------------
float mapminx;
float mapminy;
float mapmaxx;
float mapmaxy;
// --------------------------


float speed6last = 10; 
float trip4start = 10; 

// --------------------------
// current location - not filtered:
float cx, cy;
// --------------------------
// meiko 60.146613,24.3355331
// --------------------------

// --------------------------
int dw, dh; // width of the square
float scale_coor; 
// --------------------------
int zoomi =15; // google
String maptype = "NAU"; // "TOP" "HYB" "SAT" 
// peruskartta: ei "&l=HYB"
// --------------------------
// zoomin valinta: maptypen valinta, google fonecta.. 
// kun android toimii: jakaminen.. 
// --------------------------

// --------------------------
// constants
// --------------------------
int w_line = 14;
int w_ellipse = 20;
float scale_const = 100 * 1/ 11.3 / 100000;
int scalewithlaststepN = 12; // number of steps shown in the square

float paivantasaajalla = 6390*3.142*2/360*1000; // metria

// --------------------------
int spots;

// --------------------------




// --------------------------
// SETUP
// --------------------------
void setup() {


  if (androidi) {
    size(displayWidth, displayHeight);
    orientation(PORTRAIT); // PAKKO OLLA -- XML ei riitä!!
    dw = displayWidth;
    dh = displayHeight;
  } else {
  } 
  size(550, 800);  
  dw = 550; // width;
  dh = 800;

  background(60);
  frameRate(25);
  // meiko
  cx = 60.146613;
  cy = 24.3355331;



  //noLoop();
  // Run the constructor without parameters
  //  sp1 = new Spot();
  // Run the constructor with three parameters
  //sp2 = new Spot(width*0.5, height*0.5, 120);

  textAlign(CENTER, CENTER);  
  textAlign(LEFT, CENTER);  

  textSize(10);
}





void draw() {

  fill(0, 70, 0);
  rect(0, 0, dw, dw);


  if ((walk) && (frameCount % dev_speed)==0) {

    if (random(1)<0.01) {
      dev_suuntax = - dev_suuntax;
    }
    if (random(1)<0.01) {
      dev_suuntay = - dev_suuntay;
    }


    cx = cx + dev_suuntax * random(2)/100000;
    cy = cy + dev_suuntay * random(2)/100000;


    if (sp.size ()>0) {
      float dd = dist(cx, cy, sp.get(sp.size ()-1).x, sp.get(sp.size ()-1).y);
      // println(dd + "/n");
      if (dd>0.00004) {
        sp.add(new Spot(cx, cy, w_ellipse, sp.size ()));
      } else {
        // one time step stayed same location.
        sp.get(sp.size()-1).resting();
      }
    } else {
      sp.add(new Spot(cx, cy, w_ellipse, sp.size ()));
    }
  }
  //  sp1.display();
  //  sp2.display();

  mapminx = 1000000;
  mapminy = 1000000;
  mapmaxx = 0;
  mapmaxy = 0;
  // last places, use those as center... current place on border - ok
  for (int i=max (0, sp.size () - scalewithlaststepN); i<sp.size (); i++) {
    if (sp.get(i).x<mapminx) { 
      mapminx = sp.get(i).x;
    }
    if (sp.get(i).x>mapmaxx) { 
      mapmaxx = sp.get(i).x;
    }
    if (sp.get(i).y<mapminy) { 
      mapminy = sp.get(i).y;
    }
    if (sp.get(i).y>mapmaxy) { 
      mapmaxy = sp.get(i).y;
    }
  }
  //println(mapmaxx - mapminx);
  scale_coor = max((mapmaxx - mapminx), (mapmaxy - mapminy));
  scale_coor = scale_coor + 2* scale_const;
  // print(scale_coor);
  for (int i=1; i<sp.size (); i++) {
    sp.get(i).linedraw(sp.get(i-1));
    // println(sp.size());
  }

  for (int i=0; i<sp.size (); i++) {
    sp.get(i).display();
    // println(sp.size());
  }

  for (int i=0; i<sp.size (); i++) {
    sp.get(i).color_update(mouseX, mouseY);
    // println(sp.size());
  }

  // actually it would be enough to compare before add, if overlaps with mouse.
  for (int i=0; i<sp.size (); i++) {
    for (int j=0; j<sp.size (); j++) {
      if ((i!=j) && (sp.get(i).overlaps(sp.get(j)))) {
        //   println("osuu");// sp.set(i).strokeweight = 2;
        //   sp.get(i).aseta();
      }
      // println(sp.size());
    }
  }

  //*-----------------------------------
  // green ball
  //*-----------------------------------
  drawLocation(cx, cy);
  //*-----------------------------------
  
  if ((sp.size()>0)) {
    trip4start = sp.get(0).matkaAlusta(sp.get(sp.size()-1));
  }
  // ALABOKSI    
  fill(0, 20, 0);
  rect(0, dw, dw, dh-dw);

  drawInfobox();
}
// <------ DRAW

void mousePressed() {
  //  sp.add(new Spot((float)latitude, (float)longitude, (float)altitude, (float)accuracy));
  // sp.add(new Spot());

  //  sp.add(new Spot(mouseX,mouseY,w_ellipse,sp.size ()));

  // just check the most recent and then break loop! 160723
  for (int i=0; i<sp.size (); i++) {
    if (sp.get(i).active) {
      // see GIST or Onenote
       //    link("https://www.google.fi/maps/@" + sp.get(i).x + "," + sp.get(i).y +","+zoomi+"z", "MAP");
       link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).y+"&lat="+sp.get(i).x+"&z="+zoomi+"&l=NAU");
    }
  }

  // backwards 
  for (int i=sp.size ()-1; i>0; i--) {
    if (sp.get(i).active) {
      sp.get(i).set_star();
      break;
    }
  }
}


String gettime() {
  String aika = "";
  aika = aika + hour() +":"+ minute()+":" + second();
  return aika;
}

class Spot {
  float x, y, radius;

  boolean active; // mouse over bubble
  int id;
  color c;
  int clicktime;
  String clickhour;
  float dist_mouse = 0;
  int strokeweight = 2;
  int rest_time = 1;
  boolean star = false;

  // --------------------------

  Location uic;

  // --------------------------
  // First version of the Spot constructor;
  // the fields are assigned default values
  Spot() {
    radius = 40;
    x = width*0.25 + random(100);
    y = height*0.5 + random(100);
    //println(x);
    c = color(0, 0, 0);
    clicktime = millis();
    clickhour = gettime();  
    strokeweight = 1;
  }

  // Second version of the Spot constructor;
  // the fields are assigned with parameters
  Spot(float xpos, float ypos, float r, int id_) {
    x = xpos;
    y = ypos;
    radius = r;
    c = color(0, 0, 0);
    clicktime = millis();
    clickhour = gettime();
    
    strokeweight = 1;
    id = id_;

    // --------------------------
    // distance.. just make text boxes without info in Java mode.
    // --------------------------

    
      
    if (androidi) {  
      // AndroidREM
      /*
       uic = new Location("uic");
       uic.setLatitude(xpos);
       uic.setLongitude(ypos);
      */
    } else {
        
    }
  }
  void display() {
    fill(c, max(10, 250 - (sp.size ()-id*3)));//,max(10,255 - dist_mouse));
    // stroke(strokeweight);
    strokeWeight(strokeweight);

    if (star) {
      stroke(255, 255, 0);
    } else {
      stroke(0);
    }
    //ellipse(x, y, radius*2*3, radius*2);

    int xx = round( (scale_const +x - mapminx)/scale_coor*dw);
    int yy = dw - round((scale_const + y - mapminy)/scale_coor*dw);


    ellipse(xx, yy, radius, radius);


    if (scalewithlaststepN<30) {
      textAlign(LEFT, CENTER);
      text(clickhour, xx+radius, yy);
    }

    fill(255);
    textAlign(CENTER, CENTER);
    text(rest_time, xx, yy);
  }
  void color_update(int mx, int my) {

    int xx = round((scale_const + x - mapminx)/scale_coor*dw);
    int yy = dw - round((scale_const +y - mapminy)/scale_coor*dw);

    dist_mouse = dist(mx, my, xx, yy);
    if (dist_mouse<radius) {
      c = color(255, 0, 0);
      active = true;
      //radius = 60;
    } else {
      c = color(10, 10, 0);
      active = false;
      //radius = 20;
    }
  }

  void set_star() {
    star = !star;
  }

  void resting() {
    rest_time++;
  }

  boolean overlaps(Spot other) {
    float d = dist(x, y, other.x, other.y);
    if ((radius + other.radius)<d) {
      aseta();
      other.strokeweight = 2; 
      return true;
    } else {
      other.strokeweight = 4;
      return false;
    }
  }
  float matkaAlusta(Spot o) {
    // not correct (for JAVA debugging)
    float trippi = 0;
    if (androidi) {
      // AndroidREM
      // trippi = location.getLocation().distanceTo(o.uic);     
    } else {
      trippi = dist(x,y,o.x,o.y) * paivantasaajalla;
    }
    // round;
    trippi = round(trippi / 5)*5;
    
    return trippi;
  }
  
  
  void linedraw(Spot o) {
    strokeWeight(w_line);
    stroke(0, 80);

    int xx = round((scale_const +x - mapminx)/scale_coor*dw);
    int yy = dw-round((scale_const +y - mapminy)/scale_coor*dw);
    int oxx = round((scale_const +o.x - mapminx)/scale_coor*dw);
    int oyy = dw-round((scale_const +o.y - mapminy)/scale_coor*dw);
    line(xx, yy, oxx, oyy);
    strokeWeight(w_line-4);
    stroke(255, 255, 255, max(10, 150 - (sp.size ()-id*3)));
    line(xx, yy, oxx, oyy);
  }

  void aseta() {
    // strokeweight = 3;
  }
}


void keyPressed() {
  if (key == 'w') {
    walk = !walk;
  }
  if (key == 'a') {
    scalewithlaststepN = scalewithlaststepN + 10;
  }
  if (key == 's') {
    scalewithlaststepN = scalewithlaststepN - 10;
    if (scalewithlaststepN<10) {
      scalewithlaststepN = 10;
    }
  }
  
}


void drawLocation(float x, float y) {

  int xx = round((scale_const +x - mapminx)/scale_coor*dw);
  int yy = dw - round((scale_const +y - mapminy)/scale_coor*dw);

  fill(0, 255, 0);
  ellipse(xx, yy, 20, 20);
}
void drawInfobox() {
   textSize(18);
   fill(255);
   textAlign(LEFT,CENTER);
   text("Nopeus:" + speed6last, 20,dw+20);
   text("Matka (linnuntie):" + nfs(round(trip4start),0) + " m", 20,dw+40); 
}



// Android stuff: