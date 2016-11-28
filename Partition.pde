class Partition {
  String _name;
  ArrayList<Rectangle> _rects;
  boolean _selected;
  boolean _hovered;
  color _color1;
  color _color2;
  color _color3;
  
  Partition(String name, JSONObject partition_data) {
    _name = name;
    _rects = new ArrayList<Rectangle>();
    _selected = _hovered = false;
    _color1 = color(204, 102, 0, 0);
    _color2 = color(204, 102, 0, 80);
    _color3 = color(204, 102, 0, 150);
    JSONArray rects = partition_data.getJSONArray(name);
    for (int i = 0; i < rects.size(); i++) {
      JSONObject rect = rects.getJSONObject(i);
      JSONObject top_left = rect.getJSONObject("top_left");
      int x = top_left.getInt("x");
      int y = top_left.getInt("y");
      int width = rect.getInt("width");
      int height = rect.getInt("height");
      _rects.add(new Rectangle(x, y, width, height));
    }
  }
  
  boolean overlap(int x, int y) {
    for (Rectangle r : _rects) {
      if (r.overlap(x, y))
        return true;
    }
    return false;
  }
  
  String getName() {
    return _name;
  }
  
  boolean isSelected() {
    return _selected;
  }
  
  void mark(boolean selected) {
    _selected = selected;
  }
  
  void select(int x, int y) {
    if (overlap(x, y)) {
      _selected = !_selected;
      if (_selected == false)
        _hovered = false;
    }
  }
  
  void hover(int x, int y) {
    if (overlap(x, y)) {
      _hovered = true;
    }
    else {
      _hovered = false;
    }
  }
  
  void display() {
    pushStyle();  // Start a new style
    colorMode(RGB, 255);
    if (_selected)
      fill(_color3);
    else if (_hovered)
      fill(_color2);
    else 
      fill(_color1);
    noStroke();
    for (Rectangle r : _rects) {
      r.display();
    }
    popStyle();  // Restore original style
  }
}