/**
 git commit -am  "<commit message>"
 http://stackoverflow.com/questions/2419249/git-commit-all-files-using-single-command
 
 160722 * ref: [Multiple constructors]: scaled data on screen
 160728 * colors, links etc.
 1607xx * TODO: information: speed, distances
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



int link_buttons_N = 6; // buttons below

// --------------------------
// map scaling:
// --------------------------
float mapminx;
float mapminy;
float mapmaxx;
float mapmaxy;
// --------------------------
// map scaling 2.0:
float x_len, y_len; // long and lat changed to meters
float x_scale = 35; // long degree and lat degree in kilometers
float y_scale = 111.5; // long degree and lat degree in kilometers
float s_len = 0.1;  // border size in kilometers
float c_len_x, c_len_y; // centerizing the smaller distance, x or y
float max_len; // max x_len or y_len + s_len;
// --------------------------




boolean dev_random_loc = false; // true; //true; // for android inside developing
float dev_random_size = 500; // larger, smaller steps


float speed6last = 10; 
float trip4start = 10; 

float distance2lastpoint = 20; // 30; // tested 160724 - smaller enough.. later use accuracy threshold for filtering.. if jumps during breaks.
float accurary_threshold = 40; // 50;


PImage webImg;
String url_meripinta = "http://cdn.fmi.fi/legacy-fmi-fi-content/products/sea-level-observation-graphs/yearly-plot.php?station=12&lang=fi";
boolean meripintaladattu = false;  // on first press, load the image
boolean meripintanayta= false;  // show on center or not...

int number_of_imagelinks = 3;
String[] url_image = new String[number_of_imagelinks];
String[] url_reference = new String[number_of_imagelinks];
boolean[] url_loaded = new boolean[number_of_imagelinks];
boolean[] url_image_show = new boolean[number_of_imagelinks];

// --------------------------
// current location - not filtered:
float cx, cy;
float c_lat, c_lon;
// --------------------------
// meiko 60.146613,24.3355331
// --------------------------

// --------------------------
int dw, dh; // width of the square
float scale_coor, x_scale_coor, y_scale_coor; 

// --------------------------
int zoomi =15; // google
int zoomi_yrno = 7; // yrno
int zoomi2;
String maptype = "NAU"; // "TOP" "HYB" "SAT" 
// peruskartta: ei "&l=HYB"
// --------------------------
// zoomin valinta: maptypen valinta, google fonecta.. 
// kun android toimii: jakaminen.. 
// --------------------------

int min_spotsize = 19; // 9 is the minimum --> white line 1

// --------------------------
// constants
// --------------------------
int w_line, w_ellipse, w_infotextsize, r_default; // These constants are based on the width of the screen.
float scale_const = 100 * 1/ 11.3 / 10000 * 2; // how much space between spots and borders? In degrees!

float x_scale_const; //  = 100 * 1/ 11.3 / 10000 * 2;
float y_scale_const;

float x_degree_in_km = 35;     // this can be updated
float y_degree_in_km = 111.5;  // this can be updated


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
  
  r_default = w_ellipse; // in mousepress, very small spots hard to press.
  
  w_line = w_ellipse - 4; // simpler, if steps are scaled // round(dw/22);  
  w_infotextsize = round(dw/40); 


  x_scale_const = scale_const; // scale based on the latitude, helsinki 35km
  y_scale_const = scale_const; // calculate the value. typically just the same, about 111.4km - make calculations later


  textAlign(CENTER, CENTER);  
  textAlign(LEFT, CENTER);  

  textSize(10);

  //println(url_meripinta);

  // in JAVA mode: "png" , but in Android... just URL:
  // webImg = loadImage(url_meripinta, "png");
  // webImg = loadImage(url_meripinta);


  // not implemented yet... similarly as meripinta:
  // Images which are shown directly in app: (LATER: select the closest station... 160805: now fxed to helsinki
  url_image[0] = "http://cdn.fmi.fi/legacy-fmi-fi-content/products/sea-level-observation-graphs/yearly-plot.php?station=12&lang=fi";
  url_image[1] = "http://cdn.fmi.fi/legacy-fmi-fi-content/products/wave-height-graphs/wave-plot.php?station=2&lang=fi";
  url_image[2] = "http://cdn.fmi.fi/legacy-fmi-fi-content/products/global-ultraviolet-index/plot.php?location=helsinki&lang=fi&day=0";

  url_reference[0] = "http://ilmatieteenlaitos.fi/";
  url_reference[1] = "http://ilmatieteenlaitos.fi/";
  url_reference[2] = "http://ilmatieteenlaitos.fi/";


  for (int i=0; i<number_of_imagelinks; i++) {
    url_loaded[i] = false;
    url_image_show[i] = false;
  }
}





void draw() {

  // Route cleared
  stroke(0);
  strokeWeight(2);
  fill(0, 70, 0);
  rect(0, 0, dw, dw);


  if (androidi) { 
    if (asetettu) {
      c_lat = (float)latitude;
      c_lon = (float)longitude;
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
        float dd = dist(cx, cy, sp.get(sp.size ()-1).lon, sp.get(sp.size ()-1).lat);
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
    if (sp.get(i).lon<mapminx) { 
      mapminx = sp.get(i).lon;
    }
    if (sp.get(i).lon>mapmaxx) { 
      mapmaxx = sp.get(i).lon;
    }
    if (sp.get(i).lat<mapminy) { 
      mapminy = sp.get(i).lat;
    }
    if (sp.get(i).lat>mapmaxy) { 
      mapmaxy = sp.get(i).lat;
    }
  }
  //println(mapmaxx - mapminx);


//  float map_dist_x = (mapmaxx - mapminx) * x_degree_in_km;
//  float map_dist_y = (mapmaxy - mapminy) * y_degree_in_km;
//  // think more:  scale_coor = max((mapmaxx - mapminx)* x_scale_const, (mapmaxy - mapminy) * y_scale_const); // the scaling is based on the x or y in [m]
//  //if 
//  scale_coor = max((mapmaxx - mapminx), (mapmaxy - mapminy)); // the scaling is based on the x or y in [m]
//  // scale_coor = scale_coor + 2 * scale_const;  // scale_const 
//  // Fix later
//  x_scale_coor = scale_coor;
//  y_scale_coor = scale_coor;

//  float x_len, y_len; // long and lat changed to meters
//float x_scale = 35; // long degree and lat degree in kilometers
//float y_scale = 111.5; // long degree and lat degree in kilometers
//float s_len = 0.1;  // border size in kilometers
//float c_len_x, c_len_y; // centerizing the smaller distance, x or y
//float max_len; // max x_len or y_len + s_len;

  x_len = x_scale * (mapmaxx - mapminx);
  y_len = y_scale * (mapmaxy - mapminy);
  
  max_len = max(x_len,y_len); //  + s_len*2;
  
  c_len_x = (max_len - x_len) / 2;
  c_len_y = (max_len - y_len) / 2;

  max_len = max_len + s_len*2;


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
    drawLocation(c_lat, c_lon);
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
  for ( int i=0; i<link_buttons_N; i++) {
    fill(20*i, 40, 0);
    rect(i*dw/link_buttons_N, dh-150, (i+1)*dw/link_buttons_N, 150);
    fill(200);
    // not working, i numeric?

    // text(20,dw+150 
    // text("B", dh-75, i*dw/5+dw/10);
    fill(0);
    switch(i) {
    case 0: 
      text("NAU", i*dw/link_buttons_N+dw/link_buttons_N/2, dh-75);  // Does not execute
      break;
    case 1: 
      text("TOP", i*dw/link_buttons_N+dw/link_buttons_N/2, dh-75);  // Prints "Bravo"
      break;
    default:
      text(i, i*dw/link_buttons_N+dw/link_buttons_N/2, dh-75);   // Does not execute
      break;
    }
  }


  // "NAU"; // "TOP" "HYB" "SAT" + GOOGle

  if ((meripintanayta) && (meripintaladattu)) {
    // https://forum.processing.org/one/topic/image-and-xml-in-processing-for-android.html   // permissions: INTERNET
    imageMode(CENTER);
    // image is scaled.. note the order of int variable scaling
    image(webImg, dw/2, dw/2,dw,round((dw*webImg.height)/webImg.width));
  }

  
  if (max_len>0) {
  strokeWeight(3);
  stroke(100,255,255);
  fill(100,255,255);
  line(dw/2-x_len/2*dw/max_len,dw-20,dw/2+x_len/2*dw/max_len,dw-20);
  textAlign(CENTER,BOTTOM);
  text(round(x_len*1000)+ "m",dw/2,dw-20);
  
  line(20,dw/2-y_len/2*dw/max_len,20,dw/2+y_len/2*dw/max_len);
  textAlign(LEFT,CENTER);
  
  
  // text align is also messed up!! 
  
  // this works okay
  //textAlign(CENTER,LEFT);
  pushMatrix();
  // translate(0,0);
  // rotate(-HALF_PI); // goes another direction
  rotate(HALF_PI);   // translate and scale should work pretty well for dot mappinG!!! 160805
  //text(round(y_len*1000)+ "m",0,0);
  //text(round(y_len*1000)+ "m",20,-dw/2);
  //text(round(y_len*1000)+ "m",20,-dw/2);
  //text(round(y_len*1000)+ "me",-dw/2,20);
  //text(round(y_len*1000)+ "met",dw/2,20);
  //text(round(y_len*1000)+ "mete",-dw/2,-20);
  // text(round(y_len*1000)+ "m",40,dw/2);
  
  // textAlign(LEFT,CENTER);
  textAlign(CENTER,LEFT);
  text(round(y_len*1000)+ "m",dw/2,-20-6); // -6 just added to make similar
  
  
  translate(dw/2,20); // coordinate rotated 90 degrees
  text(round(y_len*1000)+ "m",0,0);
  popMatrix();
  }
  
  if (dev_random_loc) {
    fill(0,255,0);
    text("DEV MODE - note that GREEN BALL not working correctly",dw/2,40);
  }


  drawInfobox();
}
//*-----------------------------------  //*-----------------------------------
// <------ DRAW
//*-----------------------------------
//*-----------------------------------

//*-----------------------------------
void mousePressed() {
  // just check the most recent and then break loop! 160723



  // only one star possible
  // OK. otherwise false clicks. 1) activate the ball, and just the most recent one, if many -- loop TODO backwards, and then break;



  if (mouseY<dw) {

    // ACTIVE pointers cleared, one only, if map area is pressed. Star is used for link buttons etc.
    for (int i=sp.size ()-1; i>=0; i--) {

      if (sp.get(i).active) {
        sp.get(i).set_star();
        sp.get(i).active = false;
        sp.get(i).c = color(0, 0, 0);
      }
    }

    // NOTE: i>=0
    for (int i=sp.size ()-1; i>=0; i--) { // backwards, only the last one is activated.. otherwise too many links to www
      //Spot ss = sp.get(i);
      sp.get(i).color_update();
      // println(sp.size());
      if (sp.get(i).active) {
        println("breaks");
        break;
      }
    }


    if (mouseX<100) {
      zoomi = round(map(mouseY, 0, dw, 12, 17));
      zoomi_yrno = round(map(mouseY, 0, dw, 5, 8));
    }

    if ((mouseY<100) && (mouseX>dw-100)) {
      // webImg = loadImage(url_meripinta, "png");
      // in JAVA mode: "png" , but in Android... just URL:
      // webImg = loadImage(url_meripinta, "png");
      if (!meripintaladattu) {
        webImg = loadImage(url_meripinta);
        meripintaladattu = true;
      } 
      meripintanayta = !meripintanayta;
    }
  }


  if ((mouseY>dw) && (mouseY<dw+100)) {
    // full scale:
    scalewithlaststepN = round(map(mouseX, 0, dw, 1, max(1, sp.size())));
  }

  // alalaita nappi
  if (dh - mouseY<150) {
    for (int i=0; i<sp.size (); i++) {
      if (sp.get(i).active) {
        // see GIST or Onenote
        //    link("https://www.google.fi/maps/@" + sp.get(i).x + "," + sp.get(i).y +","+zoomi+"z", "MAP");
        // link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).y+"&lat="+sp.get(i).x+"&z="+zoomi+"&l=NAU");

        if (mouseX<dw/link_buttons_N) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).lon+"&lat="+sp.get(i).lat+"&z="+zoomi+"&l=NAU");
        } else if (mouseX<dw/link_buttons_N*2) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).lon+"&lat="+sp.get(i).lat+"&z="+zoomi+"&l=TOP");
        } else if (mouseX<dw/link_buttons_N*3) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).lon+"&lat="+sp.get(i).lat+"&z="+zoomi+"&l=HYB");
        } else if (mouseX<dw/link_buttons_N*4) {
          link("https://www.fonecta.fi/kartat/?lon="+sp.get(i).lon+"&lat="+sp.get(i).lat+"&z="+zoomi+"&l=SAT");
        } else if (mouseX<dw/link_buttons_N*5) {
          link("http://www.yr.no/kart/#lat=" +sp.get(i).lat+ "&lon=" +sp.get(i).lon+ "&zoom="+zoomi_yrno);
        } else {
          // just else enough
          link("https://www.google.fi/maps/@" + sp.get(i).lat + "," + sp.get(i).lon +","+zoomi+"z", "MAP");
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
  float lat, lon, r;
  float a; // accuracy
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
  float distance2previous;
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
  //  Spot() {
  //    r = 40;
  //    x = width*0.25 + random(100);
  //    y = height*0.5 + random(100);
  //    //println(x);
  //    c = color(0, 0, 0);
  //    clicktime = millis();
  //    clickhour = gettime();  
  //    strokeweight = 1;
  //  }
  // --------------------------
  // Second version of the Spot constructor;
  // the fields are assigned with parameters
  // --------------------------
  // TODO: add accuracy, height, etc.
  // --------------------------
  Spot(float latpos, float lonpos, float radius_, int id_) {
    lat = latpos;   // latitude
    lon = lonpos;   // longitude
    
    if (dev_random_loc) {
      lat = lat + random(1000)/(1000*dev_random_size) - 1/(1000*dev_random_size)/2/4;  //going to one direction randomly
      lon = lon + random(1000)/(1000*dev_random_size) - 1/(1000*dev_random_size)/2/4;  //going to one direction randomly
    } 
    
    r = radius_;
    c = color(0, 0, 0);
    clicktime = millis();
    clickhour = gettime();

    strokeweight = 1;
    id = id_;

    // accuracy not stored to spots
    // --------------------------
    // distance.. just make text boxes without info in Java mode.
    // --------------------------

    if (androidi) {  
      // AndroidREM
      uic = new Location("uic");
      uic.setLatitude(lat);  // it was not, need to change drawing 160805 -- enough just here 160728 -- latitude is y dir.
      uic.setLongitude(lon);
    }
  }
  void display() {
    
    // stroke(strokeweight);
    strokeWeight(strokeweight);

    if (star) {
      strokeWeight(2);
      stroke(255, 255, 0);
    } else {
      strokeWeight(1);
      stroke(0);
    }


// last could look different
//    if (id == size()) {
//      fill(c, 150);
//      ellipse(xs, ys, r+8, r+8);
//    }
   fill(c, 250); // max(10, 250 - (sp.size ()-id*3)));//,max(10,255 - dist_mouse));
    ellipse(xs, ys, r, r);

    fill(200);

    if (scalewithlaststepN<30) {
      textAlign(LEFT, CENTER);
      text(clickhour + "id:" + id + "\n dist: " + round(distance2previous) + "m", xs+r, ys);
    }

    fill(255);
    textAlign(CENTER, CENTER);
    text(rest_time, xs, ys);
  }


  void screen_location_update() {
    // xs = round((scale_const + x - mapminx)/scale_coor*dw);
    // ys = dw - round((scale_const +y - mapminy)/scale_coor*dw);

//    xs = round((scale_const + lon - mapminx)/x_scale_coor*dw);
//    ys = dw - round((scale_const + lat - mapminy)/y_scale_coor*dw);
//    
    
     xs = round(((lon - mapminx) * x_scale + s_len + c_len_x) / max_len * dw);
     ys = dw - round((((lat - mapminy) * y_scale + s_len + c_len_y) / max_len * dw));
    

    if ((xs+r>=0) && (xs-r<=dw) && (ys+r>=0) && (ys-r<=dw)) {
      draw_spot = true;
    } else {
      draw_spot = false;
    }
  }

  void color_update() {
    if (draw_spot) {
      dist_mouse = dist(mouseX, mouseY, xs, ys);
      if (dist_mouse<r_default) {  // easier to press
        c = color(255, 0, 0);
        active = true;
        println("active set");
      }
    }
  }

  void set_star() {
    if (active) {
      // double click.. first set active, then star can be actived..
      dist_mouse = dist(mouseX, mouseY, xs, ys);
      if (dist_mouse<r_default) {
        star = !star;
      }
    }
  }

  void resting() {
    rest_time++;
  }

  
  void set_distance2previous(Spot o) {
    distance2previous = sqrt(pow((lat-o.lat)*y_scale,2) + pow((lon-o.lon)*x_scale,2))*1000;
  }


  boolean overlaps(Spot o) {
    float d = dist(xs, ys, o.xs, o.ys);
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
      trippi = dist(lon, lat, o.lon, o.lat) * paivantasaajalla;
    }
    // round;
    trippi = round(trippi / 1)*1;  // to last step, green ball

    return trippi;
  }


  void linedraw(Spot o) {


    int xx = xs; //round((scale_const +x - mapminx)/scale_coor*dw);
    int yy = ys; // dw-round((scale_const +y - mapminy)/scale_coor*dw);
    int oxx = o.xs; //round((scale_const +o.x - mapminx)/scale_coor*dw);
    int oyy = o.ys; // dw-round((scale_const +o.y - mapminy)/scale_coor*dw);

    if ((draw_spot) || (o.draw_spot)) {
      float ww = min(o.r, r);
      w_line = round(ww-4); // r min is 9, this is 5, and inner 1. 160728
      strokeWeight(w_line);
      stroke(0, max(10, 100 - (sp.size ()-id*4)));
      line(xx, yy, oxx, oyy);
      strokeWeight(w_line-4); // innerline - white
      stroke(255, 255, 255, max(10, 150 - (sp.size ()-id*5)));
      line(xx, yy, oxx, oyy);
    }
  }

  void aseta() {
    // strokeweight = 3;
  }

  void check_if_overlaps(Spot o) {
    float d = dist(xs, ys, o.xs, o.ys);   // 160805 fixed, earlier it was used x and y which were longitude and latitude
    // changed 160805  < --> >
    if ((r + o.r)>d) {
      o.r--;
      r=r-1;
      if (o.r<min_spotsize) {
        o.r = min_spotsize;
      }
      if (r<min_spotsize) r=min_spotsize;
    } else {
      if (o.r<w_ellipse) o.r++;
      if (r<w_ellipse) r++;
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
void drawLocation(float lat, float lon) {


  // longitude, pituuspiiri --> x
  // int xx = round((scale_const + lon - mapminx)/scale_coor*dw);
  // int yy = dw - round((scale_const + lat - mapminy)/scale_coor*dw);
  // lon_min = mapminx
  int xx = round(((lon - mapminx) * x_scale + s_len + c_len_x) / max_len * dw);
  int yy = dw - round(((lat - mapminy) * y_scale + s_len + c_len_y) / max_len * dw);



  if (accuracy>30) {
    noStroke();
    fill(0, 255, 0, (int)(255/accuracy));
    ellipse(xx, yy, (int)accuracy*4, (int)accuracy*4);  // later scale to use right scale... 
    fill(0, 255, 0, (int)(255/accuracy));
    ellipse(xx, yy, round((int)accuracy/2), round((int)accuracy/2));
  }
  noFill();
  stroke(0, 255, 0);
  ellipse(xx, yy, (int)accuracy, (int)accuracy);
  ellipse(xx, yy, (int)accuracy*2, (int)accuracy*2);
  ellipse(xx, yy, (int)accuracy*3, (int)accuracy*3);

  stroke(0);
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
  text("Matka (linnuntie):" + nfs(round(trip4start), 0) + " m", 20, dw+rivikoko*4); 

  textSize(round(dw/35));
  
  textAlign(CENTER,CENTER);
  
  String spots_zoomed = min(sp.size(),scalewithlaststepN) + "/" + sp.size();
  text(spots_zoomed, dw/2,dw+rivikoko);
  textAlign(LEFT, CENTER);
  if (androidi) {

    // e.g. altitude is double, round is not working for that..
    if ((sp.size()>0)) {
      // androidREM

      if (location.getProvider() == "none")
        text("Location data is unavailable. \n" +
          "Please check your location settings.", 0, 0, width, height);
      else
        text("Location data:\n" + 
        "Latitude: " + latitude + "\n" + 
        "Longitude: " + longitude + "\n" + 
        "Altitude: " + round((float)altitude) + "\n" +
        "Accuracy: " + accuracy + "\n" +
        "Distance to sp(0): "+ round((float)location.getLocation().distanceTo(sp.get(0).uic)) + " m\n" +  
        "Provider: " + location.getProvider() + "\n" + 
        "Zoom: " + zoomi +", "+zoomi2+", " + zoomi_yrno, dw/3, dw, dw - dw/3, dh-dw);

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
        // just added, now just call and compare 1 before it.
        // note, index e.g. 0 and 1 .. size is 2 !! 160805
        sp.get(sp.size ()-1).set_distance2previous(sp.get(sp.size ()-1-1)); // distance from the first record, resting is resting in that point
        // sp.get(i).check_if_overlaps(sp.get(i-1));
      } else {
        // one time step stayed same location.
        sp.get(sp.size()-1).resting();
        
      }
    } else {
      sp.add(new Spot((float)latitude, (float)longitude, w_ellipse, sp.size ()));
      sp.get(0).distance2previous = 0; // no previous spot
    }
  }
}

