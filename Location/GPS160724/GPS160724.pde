/**
 
 160722 * ref: [Multiple constructors]: scaled data on screen
 160723 * TODO: information: speed, distances
 1607xx * pinch, distance, mark interesting place. time spent in ball, if more than 1.
 
 
 */


// not needed in JAVA mode, but in Android mode
// https://developer.android.com/reference/java/util/ArrayList.html
import java.util.*;

// 
float etaisyys =0;
// --------------------------
// Android stuff:
boolean androidi = true;
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
boolean walk = false; // true;
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

float distance2lastpoint = 20; // 30; // tested 160724 - smaller enough.. later use accuracy threshold for filtering.. if jumps during breaks.
float accurary_threshold = 40; // 50;

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
int zoomi2;
String maptype = "NAU"; // "TOP" "HYB" "SAT" 
// peruskartta: ei "&l=HYB"
// --------------------------
// zoomin valinta: maptypen valinta, google fonecta.. 
// kun android toimii: jakaminen.. 
// --------------------------

// --------------------------
// constants
// --------------------------
int w_line, w_ellipse, w_infotextsize; // These constants are based on the width of the screen.
float scale_const = 100 * 1/ 11.3 / 10000 * 2; // how much space between spots and borders?
int scalewithlaststepN = 24; // number of steps shown in the square

float paivantasaajalla = 6390*3.142*2/360*1000; // metria

// --------------------------
int spots;

// --------------------------
boolean asetettu = false;



// --------------------------
// SETUP
// --------------------------
void setup() {

  // --------------------------
  // androidREM NEg.
  // size(550, 800);  
  // --------------------------

  // --------------------------
  if (androidi) {
    size(displayWidth, displayHeight);
    orientation(PORTRAIT); // only portrait design
    dw = displayWidth;
    dh = displayHeight;
  } else {
    dw = 550; // width;
    dh = 800;

    // start location in debug: 
    // meiko
    cx = 60.146613;
    cy = 24.3355331;
  } 

  background(60);
  frameRate(25);


  // balls
  w_ellipse = round(dw/10); //round(dw/17);
  w_line = w_ellipse - 4; // simpler, if steps are scaled // round(dw/22);  
  w_infotextsize = round(dw/40); 


  textAlign(CENTER, CENTER);  
  textAlign(LEFT, CENTER);  

  textSize(10);
}





void draw() {

  // Route cleared
  stroke(0);
  strokeWeight(2);
  fill(0, 70, 0);
  rect(0, 0, dw, dw);


  if (androidi) { 
    if (asetettu) {
      cx = (float)latitude;
      cy = (float)longitude;
    }
  } else {
    // JAVA Movements -->
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
        asetettu = true;
      }
    }
  }
  // Java movements <<----

  // -------------------------------------------------------
  // Route scaling each round:
  mapminx = 10000;
  mapminy = 10000;
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
  // -------------------------------------------------------



  // 1 -------------------------------------------------------
  // 160725 - screen coordinates updated each round.
  // -------------------------------------------------------
  for (int i=0; i<sp.size (); i++) {
    sp.get(i).screen_location_update();
  }
  for (int i=1; i<sp.size (); i++) {
    sp.get(i).check_if_overlaps(sp.get(i-1));
  }


  // 2 -------------------------------------------------------
  // Draw lines: ( later TODO: Check if points in the screen / update information to step object. Also coordinates and boolean, if screen or not! ISSUE
  // -------------------------------------------------------
  for (int i=1; i<sp.size (); i++) {
    sp.get(i).linedraw(sp.get(i-1));
    // println(sp.size());
  }
  // -------------------------------------------------------


  // 3 -------------------------------------------------------
  // Draw steps:
  // -------------------------------------------------------
  for (int i=0; i<sp.size (); i++) {
    sp.get(i).display();
    // println(sp.size());
  }
  // 4 -------------------------------------------------------
  // OK. otherwise false clicks. 1) activate the ball, and just the most recent one, if many -- loop TODO backwards, and then break;
  if (mouseY<dw) {
    for (int i=sp.size ()-1; i>0; i--) { // backwards, only the last one is activated.. otherwise too many links to www
      sp.get(i).color_update(mouseX, mouseY);
      // println(sp.size());
      break;
    }
  }
  // -------------------------------------------------------

  // -------------------------------------------------------
  // actually it would be enough to compare before add, if overlaps with mouse.
  // -------------------------------------------------------
  //  for (int i=0; i<sp.size (); i++) {
  //    for (int j=0; j<sp.size (); j++) {
  //      if ((i!=j) && (sp.get(i).overlaps(sp.get(j)))) {
  //        //   println("osuu");// sp.set(i).strokeweight = 2;
  //        //   sp.get(i).aseta();
  //      }
  //      // println(sp.size());
  //    }
  //  }
  // -------------------------------------------------------

  //*-----------------------------------
  // green ball
  //*-----------------------------------
  if (asetettu) {
    drawLocation(cx, cy);
  }
  //*-----------------------------------

  if ((sp.size()>0)) {
    trip4start = sp.get(0).matkaAlusta(sp.get(sp.size()-1));
  }
  // ALABOKSI    
  stroke(0);
  strokeWeight(1);
  fill(0, 20, 0);
  rect(0, dw+100, dw, dh-dw-250);
  fill(0, 30, 0);
  rect(0, dw, dw, 100);


  textAlign(CENTER, CENTER);
  for ( int i=0; i<5; i++) {
    fill(20*i, 40, 0);
    rect(i*dw/5, dh-150, (i+1)*dw/5, 150);
    fill(0);
    // not working, i numeric?
    switch(i) {
    case '0': 
      text("NAU", dh-75, i*dw/5+dw/10);  // Does not execute
      break;
    case '1': 
      text("TOP", dh-75, i*dw/5+dw/10);  // Prints "Bravo"
      break;
    default:
      text(i, dh-75, i*dw/5+dw/10);   // Does not execute
      break;
    }
  }


  // "NAU"; // "TOP" "HYB" "SAT" + GOOGle

  drawInfobox();
}
//*-----------------------------------  //*-----------------------------------
// <------ DRAW
//*-----------------------------------
//*-----------------------------------

//*-----------------------------------
void mousePressed() {
  // just check the most recent and then break loop! 160723


  // backwards 
  for (int i=sp.size ()-1; i>0; i--) {
    if (sp.get(i).active) {
      sp.get(i).set_star();
      break;
    }
  }

  if ((mouseY>dw) && (mouseY<dw+100)) {
    scalewithlaststepN = round(map(mouseX, 0, dw, 10, max(10, sp.size()-1)));
  }

  // alalaita nappi
  if (dh - mouseY<150) {
    for (int i=0; i<sp.size (); i++) {
      if (sp.get(i).active) {
        // see GIST or Onenote
        //    link("https://www.google.fi/maps/@" + sp.get(i).x + "," + sp.get(i).y +","+zoomi+"z", "MAP");
        // link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).y+"&lat="+sp.get(i).x+"&z="+zoomi+"&l=NAU");

        if (mouseX<dw/5) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).y+"&lat="+sp.get(i).x+"&z="+zoomi+"&l=NAU");
        } else if (mouseX<dw/5*2) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).y+"&lat="+sp.get(i).x+"&z="+zoomi+"&l=TOP");
        } else if (mouseX<dw/5*3) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).y+"&lat="+sp.get(i).x+"&z="+zoomi+"&l=HYB");
        } else if (mouseX<dw/5*4) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).y+"&lat="+sp.get(i).x+"&z="+zoomi+"&l=SAT");
        } else if (mouseX>dw/5*4) {
          // just else enough
          link("https://www.google.fi/maps/@" + sp.get(i).x + "," + sp.get(i).y +","+zoomi+"z", "MAP");
        }
      }
      // "NAU"; // "TOP" "HYB" "SAT" + GOOGle
    }
  }
}

//*-----------------------------------

//*-----------------------------------
String gettime() {
  String aika = "";
  aika = aika + hour() +":"+ minute()+":" + second();
  return aika;
}
//*-----------------------------------

//*-----------------------------------
// SPOT
//*-----------------------------------
class Spot {
  float x, y, r;

  boolean active; // mouse over bubble
  int id;
  color c;
  int clicktime;
  String clickhour;
  float dist_mouse = 0;
  int strokeweight = 2;
  int rest_time = 1;
  boolean star = false;
  float distance2next; // or TO previous, maybe more useful. set this just before adding new spot. TODO: create function which is called before add.
  // --------------------------
  Location uic;
  // --------------------------
  boolean draw_spot = true; // not implemented yet, go the loop through
  int xs, ys; // TODO, scaled coordinates on the screen, round the values, check if in the screen, otherwise no draw. 0-r,0-r,dw+r,dw+r the limits
  // --------------------------

  // --------------------------
  // First version of the Spot constructor;
  // the fields are assigned default values
  // --------------------------
  Spot() {
    r = 40;
    x = width*0.25 + random(100);
    y = height*0.5 + random(100);
    //println(x);
    c = color(0, 0, 0);
    clicktime = millis();
    clickhour = gettime();  
    strokeweight = 1;
  }
  // --------------------------
  // Second version of the Spot constructor;
  // the fields are assigned with parameters
  // --------------------------
  // TODO: add accuracy, height, etc.
  // --------------------------
  Spot(float xpos, float ypos, float radius_, int id_) {
    x = xpos;
    y = ypos;
    r = radius_;
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
      uic = new Location("uic");
      uic.setLatitude(xpos);
      uic.setLongitude(ypos);
    }
  }
  void display() {
    fill(c, 250); // max(10, 250 - (sp.size ()-id*3)));//,max(10,255 - dist_mouse));
    // stroke(strokeweight);
    strokeWeight(strokeweight);

    if (star) {
      stroke(255, 255, 0);
    } else {
      stroke(0);
    }
    //ellipse(x, y, radius*2*3, radius*2);

    int xx = xs; // round( (scale_const +x - mapminx)/scale_coor*dw);
    int yy = ys; //  dw - round((scale_const + y - mapminy)/scale_coor*dw);


    ellipse(xx, yy, r, r);

    fill(0);

    if (scalewithlaststepN<30) {
      textAlign(LEFT, CENTER);
      text(clickhour + "id:" + id, xx+r, yy);
    }

    fill(255);
    textAlign(CENTER, CENTER);
    text(rest_time, xx, yy);
  }


  void screen_location_update() {
    xs = round((scale_const + x - mapminx)/scale_coor*dw);
    ys = dw - round((scale_const +y - mapminy)/scale_coor*dw);

    if ((xs+r>=0) && (xs-r<=dw) && (ys+r>=0) && (ys-r<=dw)) {
      draw_spot = true;
    } else {
      draw_spot = false;
    }
  }

  void color_update(int mx, int my) {

    int xx = xs; // round((scale_const + x - mapminx)/scale_coor*dw);
    int yy = ys; // dw - round((scale_const +y - mapminy)/scale_coor*dw);

    if (draw_spot) {
      dist_mouse = dist(mx, my, xx, yy);
      if (dist_mouse<r) {
        c = color(255, 0, 0);
        active = true;
        //radius = 60;
      } else {
        c = color(10, 10, 0);
        active = false;
        //radius = 20;
      }
    }
  }

  void set_star() {
    star = !star;
  }

  void resting() {
    rest_time++;
  }

  boolean overlaps(Spot o) {
    float d = dist(x, y, o.x, o.y);
    if ((r + o.r)<d) {
      aseta();
      o.strokeweight = 2; 
      return true;
    } else {
      o.strokeweight = 4;
      return false;
    }
  }
  float matkaAlusta(Spot o) {
    // not correct (for JAVA debugging)
    float trippi = 0;
    if (androidi) {
      // AndroidREM
      trippi = location.getLocation().distanceTo(o.uic);
    } else {
      trippi = dist(x, y, o.x, o.y) * paivantasaajalla;
    }
    // round;
    trippi = round(trippi / 5)*5;

    return trippi;
  }


  void linedraw(Spot o) {


    int xx = xs; //round((scale_const +x - mapminx)/scale_coor*dw);
    int yy = ys; // dw-round((scale_const +y - mapminy)/scale_coor*dw);
    int oxx = o.xs; //round((scale_const +o.x - mapminx)/scale_coor*dw);
    int oyy = o.ys; // dw-round((scale_const +o.y - mapminy)/scale_coor*dw);

    if ((draw_spot) || (o.draw_spot)) {
      float ww = min(o.r,r);
      w_line = round(ww-4); // r min is 9, this is 5, and inner 1. 160728
      strokeWeight(w_line);
      stroke(0, 80);
      line(xx, yy, oxx, oyy);
      strokeWeight(w_line-4); // innerline - white
      stroke(255, 255, 255, max(10, 150 - (sp.size ()-id*3)));
      line(xx, yy, oxx, oyy);
    }
  }

  void aseta() {
    // strokeweight = 3;
  }

  void check_if_overlaps(Spot o) {
    float d = dist(x, y, o.x, o.y);
    if ((r + o.r)<d) {
      o.r--;
      if (o.r<9) {
        o.r = 9;
      }
    } else if (o.r<w_ellipse) {
      o.r++;
    }
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

// --------------------------
void drawLocation(float x, float y) {

  int xx = round((scale_const +x - mapminx)/scale_coor*dw);
  int yy = dw - round((scale_const +y - mapminy)/scale_coor*dw);

  fill(0, 255, 0);
  ellipse(xx, yy, 20, 20);
}
// --------------------------

void drawInfobox() {
  int rivikoko = round(dw/30);
  textSize(rivikoko);
  fill(255);
  textAlign(LEFT, CENTER);
  text("Nopeus:" + speed6last, 20, dw+rivikoko);
  text("Matka (linnuntie):" + nfs(round(trip4start), 0) + " m", 20, dw+rivikoko*3); 

  textSize(round(dw/35));
  if (androidi) {

    if ((sp.size()>0)) {
      // androidREM

      if (location.getProvider() == "none")
        text("Location data is unavailable. \n" +
          "Please check your location settings.", 0, 0, width, height);
      else
        text("Location data:\n" + 
        "Latitude: " + latitude + "\n" + 
        "Longitude: " + longitude + "\n" + 
        "Altitude: " + altitude + "\n" +
        "Accuracy: " + accuracy + "\n" +
        "Distance to sp(0): "+ location.getLocation().distanceTo(sp.get(0).uic) + " m\n" +  
        "Provider: " + location.getProvider() + "\n" + 
        "Zoom: " + zoomi +", "+zoomi2, dw/3, dw, dw - dw/3, dh-dw);

      // */
      // <--- androidREM
    }
  }
}


// AndroidREM
// Android stuff:

void onResume()
{
  location = new KetaiLocation(this);
  super.onResume();
}


void onLocationEvent(Location _location)
{
  //print out the location object
  println("onLocation event: " + _location.toString());
  longitude = _location.getLongitude();
  latitude = _location.getLatitude();
  altitude = _location.getAltitude();
  accuracy = _location.getAccuracy();


  if ((!asetettu) && (accuracy<=accurary_threshold)) {
    //    uic2.setLatitude(latitude);
    //    uic2.setLongitude(longitude); 
    asetettu = true;
  }
  if (asetettu) {
    // etaisyys = location.getLocation().distanceTo(uic2);
    etaisyys = 0; //round(etaisyys / 50)*50;

    if (accuracy>accurary_threshold) {
      float pyoristys = 100;
      etaisyys = round(etaisyys / pyoristys)*pyoristys;
    }


    // drawings.add(new Drawing((float)latitude, (float)longitude, (float)altitude, (float)accuracy));
    if (sp.size ()>0) {
      // float dd = dist(cx, cy, sp.get(sp.size ()-1).x, sp.get(sp.size ()-1).y);
      float dd = location.getLocation().distanceTo(sp.get(sp.size () -1).uic); // viimesimpaan, jos etaisyys riittava
      // println(dd + "/n");
      if ((dd>distance2lastpoint) && (accuracy<accurary_threshold)) { // etaisyys kait metreissa?! if (dd>0.00004) {
        sp.add(new Spot((float)latitude, (float)longitude, w_ellipse, sp.size ()));
      } else {
        // one time step stayed same location.
        sp.get(sp.size()-1).resting();
      }
    } else {
      sp.add(new Spot((float)latitude, (float)longitude, w_ellipse, sp.size ()));
    }
  }
}

