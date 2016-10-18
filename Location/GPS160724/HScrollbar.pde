
class HScrollbar
{
  int swidth, sheight;    // width and height of bar
  int xpos, ypos;         // x and y position of bar
  float spos, newspos;    // x position of slider
  float spos1, newspos1;    // x position of slider
  float spos2, newspos2;    // x position of slider
  boolean rangeslider;    // if range slider
  int sposMin, sposMax, sposMaxRange;   // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  int roundpixeltocorrect; // = 2;
  HScrollbar (int xp, int yp, int sw, int sh, int l, boolean ra) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp; // -sheight/2;
    roundpixeltocorrect = 2;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    sposMaxRange = xpos + swidth;
    loose = l;
    rangeslider = ra;

    if (ra) {
      spos1 = sposMin;
      newspos1 = spos1;

      spos2 = sposMaxRange;
      newspos2 = spos2;
    } else {

      spos = xpos + swidth/2 - sheight/2;
      newspos = spos;
    }
  }

  void update() {
    if (over()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {


      if (rangeslider) {
        // float place = constrain(mouseX-sheight/2, sposMin, sposMax);
        float place =  constrain(mouseX, sposMin, sposMaxRange);
        println(place);

        if ((abs(place - newspos1)<abs(place - newspos2))) {

          if ((abs(newspos1 - place)<slidernearthreshold) && (place<newspos2)) {
            newspos1 = place;
            
          } else if ((place<newspos2) && (place>newspos1)) {
             // sliding
            newspos1 = newspos1 + (mouseX - pmouseX); 
            newspos2 = newspos2 + (mouseX - pmouseX);
           
          }
        } else {
          if ((abs(newspos2 - place)<slidernearthreshold) && (place>newspos1)) {
            newspos2 = place;
          } else if ((place<newspos2) && (place>newspos1)) {
             // sliding
            newspos1 = newspos1 + (mouseX - pmouseX); 
            newspos2 = newspos2 + (mouseX - pmouseX); 
          }
        }
        
         if (newspos1<slidermargin + roundpixeltocorrect) {
              newspos1 = slidermargin;
          }
          if (newspos2>dw-slidermargin - roundpixeltocorrect) {
              newspos2 = dw-slidermargin;
          }
          
             if (spos1<slidermargin + roundpixeltocorrect) {
              spos1 = slidermargin;
          }
          if (spos2>dw-slidermargin - roundpixeltocorrect) {
              spos2 = dw-slidermargin;
          }
        
        // or 
        if (place < newspos1) {
          newspos1 = place;  
        }
        if (place > newspos2) {
          newspos2 = place;  
        }
        
      } else {
        newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
      }
    }

    if (rangeslider) {
      if (abs(newspos1 - spos1) > 1) {
        spos1 = spos1 + (newspos1-spos1)/loose;
      }
      if (abs(newspos2 - spos2) > 1) {
        spos2 = spos2 + (newspos2-spos2)/loose;
      }
    } else {
      if (abs(newspos - spos) > 1) {
        spos = spos + (newspos-spos)/loose;
      }
    }
  }

  int constrain(int val, int minv, int maxv) {
    return min(max(val, minv), maxv);
  }

  boolean over() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    rectMode(CORNER);
    fill(255);
    stroke(0);
    strokeWeight(1);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(255, 102, 0);
    } else {
      fill(102, 102, 102);
    }
    if (rangeslider) {
      rect(spos1, ypos, spos2 - spos1, sheight);
      fill(0, 0, 0);
      textAlign(LEFT,TOP);
      text(spos1, 20, 20);
      text(spos2, 20, 50);
      //println(spos1 + spos2);
    } else {
      rect(spos, ypos, sheight, sheight);
    }
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
  
    float getPos1() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos1; // * ratio;
  }
  float getPos2() {
   // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos2; // * ratio;
  }
  
}
