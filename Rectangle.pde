class Rectangle {
  
  int _x;
  int _y;
  int _width;
  int _height;
  
  Rectangle(int x, int y, int width, int height) {
    _x = x;
    _y = y;
    _width = width;
    _height = height;
  }
  
  boolean overlap(int x, int y) {
    if (x >= _x && y >= _y && (_x + _width) >= x && (_y + _height) >= y)
      return true;
    else
      return false;
  }
  
  void display() {
    rect(_x, _y, _width, _height);
  }
  
}