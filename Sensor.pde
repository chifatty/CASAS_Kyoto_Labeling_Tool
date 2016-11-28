class Sensor {
  String _name ;
  int _x;
  int _y;
  int _rad;
  boolean _state;
  
  Sensor(String name, int x, int y){
    _name = name ;
    _x = x ;
    _y = y ;
    _rad = 20;
    _state = false;
  }
  
  void mark(boolean state) {
    _state = state;
  }
  
  void display(){
    if (_state) {
      pushStyle();  // Start a new style
      switch(this._name.charAt(0)){
          case 'M':  //motion sensor
              fill(255, 0, 0); //red
              break ;
          case 'D':  //door sensor
              fill(0, 0, 255); //blue
              break ;
          case 'L':  //light sensor
              fill(255, 255, 0); //yellow
              break ;
      }
      ellipse(_x, _y, _rad, _rad) ;
      popStyle();  // Restore original style
    }
  }
}