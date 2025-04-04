class DateSelector{
  int x, y;
  String date1, date2;
  Widget done;
  Search search1, search2;

  DateSelector(){
    x=450;
    y=500;
    date1="01/01/2017";
    date2="31/12/2017";
    
    search1 = new Search(width/2-280-50, y+height/10, 24, 2);
    search2 = new Search(width/2+50, y+height/10, 24, 3);
    done = new Widget(width/2-100, y+height/4, 10, 200, 100, #01204E);
  }


  void draw(){
    textSize(40);
    stroke(0);
    fill(0);
    text(":", width/2-3, y+height/10+(33));
    search1.draw();
    search2.draw();
    done.draw();
  }


}
