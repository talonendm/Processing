import processing.pdf.*;
int valittu = 1;
int valittu_bak = 1;

color[] colors = new color[3];
int cv=0;

float[] be;
boolean makepdf = false;
boolean helplines = true;
int mox, moy;
ArrayList <bezi> bez = new ArrayList <bezi>();

void setup() {
  size(400, 400);

  if (makepdf == true) {
    beginRecord(PDF, "everything2.pdf");
  }

  colors[0] = color(255, 0, 0);
  colors[1] = color(0, 255, 0);
  colors[2] = color(0, 0, 255);


  be = new float[8];
  be[0] = 100;
  be[1] = 200;
  be[3] = 200;
  be[4] = 250;
  be[5] = 400;
  be[6] = 250;
  be[7] = 400;

  textMode(SHAPE); // http://vormplus.be/blog/article/processing-month-day-19-exporting-pdf-files-for-lasercutting
  textSize(9);
  strokeWeight(1); //strokeWeight(0.001);
  stroke(0);
  noFill();
  textSize(14);
}

void draw() {
  background(255);
  // ellipse(mouseX, mouseY, 10, 10);
  // text("A",mouseX,mouseY);



  for (int i=0; i<bez.size (); i++) {
    bez.get(i).display(i);
    // println(sp.size());
  }


  bezmain();
}

void mousePressed() {
  // endRecord();
  // exit();
  bez();
} 

void keyPressed() {

  valittu = 0;
  mox = mouseX;
  moy = mouseY;
  if (key == '1') {
    valittu = 1;
    valittu_bak = valittu;
  }
  if (key == '2') {
    valittu = 2;
    valittu_bak = valittu;
  }
  if (key == '3') {
    valittu = 3;
    valittu_bak = valittu;
  }
  if (key == '4') {
    valittu = 4;
    valittu_bak = valittu;
  }
  if (key == 'q') {
    if (makepdf==true) {
      endRecord();
    }
    exit();
  }

  if (key == 'p') {

    if (bez.size ()>0) {
      beginRecord(PDF, "bezall.pdf");    
      for (int i=0; i<bez.size (); i++) {
        bez.get(i).display(i);
        // println(sp.size());
      }

      endRecord();
      print("saved");
    }  else {
      print("no bezs");
    }
  }

  if (key == 'h') {
    helplines = !helplines;
  }

  if (key == 'c') {
    cv++;
    if (cv>2) {
      cv=0;
    }
  }


  if (key == 's') {
    bez.add(new bezi(int(be), colors[cv]));
  }

  if (key == 'l') {
    // find closest value  
    valittu = valittu_bak;


    float lahinetaisyys = 10000;
    int vi = -1;
    for (int i=0; i<bez.size (); i++) {

      //  be[valittu*2-2] = mouseX;
      //  be[valittu*2-1] = mouseY;


      int zx = bez.get(i).be[valittu*2-2];
      int zy = bez.get(i).be[valittu*2-1];

      float et = dist(mouseX, mouseY, zx, zy);
      print("dist:"+ et + " for point " + i + "/n");
      if (et<lahinetaisyys) {
        lahinetaisyys = et;
        vi = i;
      }

      // println(sp.size());
    }
    print("closest point for" + valittu + "point is index:" + vi + ", ");
    print(lahinetaisyys);


    if (vi>-1) {
      mox = bez.get(vi).be[valittu*2-2];
      moy = bez.get(vi).be[valittu*2-1];

      print("mox changed\n..");
    }
  }


  bez();
}

void bez() {
  if (valittu>0) { 
    be[valittu*2-2] = mox;
    be[valittu*2-1] = moy;
    print("bezier(" + be[0]+","+be[1]+","+be[2]+","+be[3]+","+be[4]+","+be[5]+","+be[6]+","+be[7]+");\n");
  }
}

void bezmain() {
  fill(255, 0, 0);
  stroke(255, 102, 0);
  int apu[] = int(be); // subset(be,0,4);
  line(apu[0], apu[1], apu[2], apu[3]);
  line(apu[4], apu[5], apu[6], apu[7]);
  text("1", apu[0], apu[1]);
  text("2", apu[2], apu[3]);
  text("3", apu[4], apu[5]);
  text("4", apu[6], apu[7]);

  text(apu[0]+","+apu[1]+","+apu[2]+","+apu[3]+","+apu[4]+","+apu[5]+","+apu[6]+","+apu[7], 10, 10);


  text(bez.size(), width-50, height-20);

  // line(90);
  stroke(0, 0, 0);

  fill(colors[cv], 70);
  //  bezier(be(1:8));
  bezier(apu[0], apu[1], apu[2], apu[3], apu[4], apu[5], apu[6], apu[7]);
}