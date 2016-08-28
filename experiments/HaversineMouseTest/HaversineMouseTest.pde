

float lat;
float lon;

//Helsinki, Finland Map Lat Long Coordinates - Latitude and Longitude
//www.latlong.net › Countries › Finland › Cities
//Helsinki, Finland. Latitude and longitude coordinates are: 60.192059, 24.945831.
//Latitude‎: ‎60.192059  DMS Lat‎: ‎60° 11' 31.4124'' N
//Longitude‎: ‎24.945831  DMS Long‎: ‎24° 56' 44.9916'' E

// http://www.movable-type.co.uk/scripts/latlong.html

//Enter the co-ordinates into the text boxes to try out the calculations. A variety of formats are accepted, principally:

//deg-min-sec suffixed with N/S/E/W (e.g. 40°44′55″N, 73 59 11W), or
//signed decimal degrees without compass direction, where negative indicates west/south (e.g. 40.7486, -73.9864):
//Point 1:  
//60.1699 N
// ,  
//24.9384 E
//Point 2:  
//60.1699 N
// ,  
//25.9384 E 
//Distance:  55.31 km (to 4 SF*)
//Initial bearing:  089°33′58″
//Final bearing:  090°26′02″
//Midpoint:  60°10′15″N, 025°26′18″E


HaversineAlgorithm h;

void setup() {
  size(400,400);

  lat =60.192059;  // leveyspiiri, pohjosessa ollaan
  lon = 24.9384; 
  
  HaversineAlgorithm h = new HaversineAlgorithm();
} 

void draw() {
  background(0);
  text(mouseX+ ", " +mouseY,50,50);
  HaversineAlgorithm h = new HaversineAlgorithm();
  text(h.HaversineInM(lat,lon,lat,lon + 1),50,80);
  text((float)h.HaversineInKM(lat,lon,lat,lon+1),50,100);
  text((float)h.HaversineInKM(lat,lon,lat+1,lon),50,120);
  text((float)h.HaversineInKM(lat,lon,lat+1,lon+1),50,140);
  text((float)h.HaversineInKM(lat,lon,lat + ((float)mouseX-200)/100,lon+((float)mouseY-200)/100),50,160);
  text((float)h.HaversineInKM(lat,lon,lat + ((float)mouseX-200)/100,lon),50,180);
  text((float)h.HaversineInKM(lat,lon,lat,lon+((float)mouseY-200)/100),50,200);
}

public class HaversineAlgorithm {
    // http://stackoverflow.com/questions/365826/calculate-distance-between-2-gps-coordinates
    static final double _eQuatorialEarthRadius = 6378.1370D;
    static final double _d2r = (Math.PI / 180D);

    // http://stackoverflow.com/questions/13773710/can-a-class-have-no-constructor
    // HaversineAlgorithm() {
    // }

    int HaversineInM(double lat1, double long1, double lat2, double long2) {
        return (int) (1000D * HaversineInKM(lat1, long1, lat2, long2));
    }

    double HaversineInKM(double lat1, double long1, double lat2, double long2) {
        double dlong = (long2 - long1) * _d2r;
        double dlat = (lat2 - lat1) * _d2r;
        double a = Math.pow(Math.sin(dlat / 2D), 2D) + Math.cos(lat1 * _d2r) * Math.cos(lat2 * _d2r)
                * Math.pow(Math.sin(dlong / 2D), 2D);
        double c = 2D * Math.atan2(Math.sqrt(a), Math.sqrt(1D - a));
        double d = _eQuatorialEarthRadius * c;

        return d;
    }

}
