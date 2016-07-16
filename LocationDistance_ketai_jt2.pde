/**
 * <p>Ketai Sensor Library for Android: http://KetaiProject.org</p>
 *
 * <p>KetaiLocation Features:
 * <ul>
 * <li>Uses GPS location data (latitude, longitude, altitude (if available)</li>
 * <li>Updates if location changes by 1 meter, or every 10 seconds</li>
 * <li>If unavailable, defaults to system provider (cell tower or WiFi network location)</li>
 * </ul>
 * More information:
 * http://developer.android.com/reference/android/location/Location.html</p>
 * <p>Updated: 2012-03-10 Daniel Sauter/j.duran</p>
 */


// https://developer.android.com/reference/java/util/ArrayList.html
import java.util.*;
import ketai.sensors.*; 

double longitude, latitude, altitude, accuracy;
KetaiLocation location;
Location uic;
Location uic2;

float etaisyys;
// float 



boolean asetettu = false;


ArrayList <Drawing> drawings = new ArrayList <Drawing>();
int zoomi = 16;
int zoomi2;

void setup() {






  //*
  //********
  //syys = -1;





  //creates a location object that refers to UIC
  uic = new Location("uic"); // Example location: the University of Illinois at Chicago
  //uic.setLatitude(41.874698);
  //uic.setLongitude(-87.658777);
  // helsinki: 60.166977,24.945141
  uic.setLatitude(60.166977);
  uic.setLongitude(24.945141);


  uic2 = new Location("uic2"); // Example location: the University of Illinois at Chicago


  orientation(PORTRAIT);
  // orientation(LANDSCAPE);
  textAlign(CENTER, CENTER);
  textSize(36);


  colorMode(HSB);
}

void draw() {
  background(78, 93, 75);


  for (int i=0; i<drawings.size (); i++) {
    drawings.get(i).display();
  }




  if (location.getProvider() == "none")
    text("Location data is unavailable. \n" +
      "Please check your location settings.", 0, 0, width, height);
  else
    text("Location data:\n" + 
    "Latitude: " + latitude + "\n" + 
    "Longitude: " + longitude + "\n" + 
    "Altitude: " + altitude + "\n" +
    "Accuracy: " + accuracy + "\n" +
    "Distance to UIC: "+ location.getLocation().distanceTo(uic) + " m\n" + 
    "Distance to START: "+ etaisyys + " m\n" + 
    "Provider: " + location.getProvider() + "\n" + 
    "Zoom: " + zoomi +", "+zoomi2, 20, 0, width, height);
}

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


  if ((!asetettu) && (accuracy<=50)) {
    uic2.setLatitude(latitude);
    uic2.setLongitude(longitude); 
    asetettu = true;
  }
  if (asetettu) {
    etaisyys = location.getLocation().distanceTo(uic2);
    etaisyys = round(etaisyys / 50)*50;

    if (accuracy>50) {
      float pyoristys = 100;
      etaisyys = round(etaisyys / pyoristys)*pyoristys;
    }


    drawings.add(new Drawing((float)latitude, (float)longitude, (float)altitude, (float)accuracy));
  }
}


class Drawing {
  // Note that in drawings, we need floats: cast double values to float as (float)variablename // 160716
  float x, y, r, h, a;
  color c;

  Drawing(float ax, float ay, float ah, float accu) {
    x=ax;
    y=ay;
    a=accu;
    h=ah;
    r=random(2, 20);
    c=color(random(100, 200), 255, 255);
  }

  void display() {
    fill(c, 100);
    ellipse(x, y, r, r);
  }
}
public void mousePressed() { 
  if ((mouseY<100) && (mouseX<width/2)) {
    link("https://www.fonecta.fi/kartat/helsinki?lon="+longitude+"&lat="+latitude+"&z="+zoomi+"&l=NAU", "FB");
  } else if ((mouseY<100) && (mouseX>width/2)) { 
    link("https://www.fonecta.fi/kartat/?lon="+longitude+"&lat="+latitude+"&z="+zoomi+"&l=NAU", "FB");
  } else {
    zoomi = round(map(mouseX, 0, width, 12, 17));
  }
}

