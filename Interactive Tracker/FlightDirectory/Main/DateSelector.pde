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
    
    search1 = new Search(width/2-350, height-500, 24, 2);
    search2 = new Search(width/2, height-500, 24, 3);
    done = new Widget(width/2-50, height-300, 10, 100, 50, #01204E);
  }


  void draw(){
    search1.draw();
    search2.draw();
    done.draw();
  }



}
