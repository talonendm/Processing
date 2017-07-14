class bezi
{
  int[] be;
  color c, c2;
  bezi (int[] _be, color _c) {
    be = _be;
    c = _c;
    c2 = color(230, 230, 230);
  }
  void display(int ind) {

    if (helplines) {
      //  noFill();
      fill(c2);
      stroke(c2);
      //be int be[] = int(be); // subset(be,0,4);
      line(be[0], be[1], be[2], be[3]);
      line(be[4], be[5], be[6], be[7]);
      text(ind+".1", be[0], be[1]);
      text(ind+".2", be[2], be[3]);
      text(ind+".3", be[4], be[5]);
      text(ind+".4", be[6], be[7]);

      // text(be[0]+","+be[1]+","+be[2]+","+be[3]+","+be[4]+","+be[5]+","+be[6]+","+be[7],10,10);
    }
    // line(90);
    stroke(c);
    noFill(); 
    strokeWeight(0.001);
    // fill(0,255,0,70);
    //  bezier(be(1:8));
    bezier(be[0], be[1], be[2], be[3], be[4], be[5], be[6], be[7]);
  }
}