class SensorEvent {
  String _time;
  String _name;
  String _state;
  String _label;
  
  SensorEvent(String time, String name, String state) {
    _time = time;
    _name = name ;
    _state = state;
    _label = ""; 
  }
  
  SensorEvent(String time, String name, String state, String label) {
    _time = time;
    _name = name ;
    _state = state;
    _label = label; 
  }
  
  String getTime() {
    return _time;
  }
  
  String getName() {
    return _name;
  }
  
  String getState() {
    return _state;
  }
  
  void label(Map<String, Partition> partitions) {
    JSONArray label = new JSONArray();
    for (Map.Entry<String, Partition> p : partitions.entrySet()){
      if (p.getValue().isSelected()) {
        label.append(p.getValue().getName());
      }
    }
    _label = label.toString().replace(" ", "").replace("\n", "");
    println("writeLabel:  " + this.toString());
  }
  
  
  void readLabel(Map<String, Partition> partitions) {
    if (_label == "")
      return;
    JSONArray label = parseJSONArray(_label);
    for (Map.Entry<String, Partition> p : partitions.entrySet()) {
      p.getValue().mark(false);
    }
    for (int i = 0; i < label.size(); i++) {
      partitions.get(label.getString(i)).mark(true);
    }
    _label = label.toString().replace(" ", "").replace("\n", "");
    println("readLabel:  " + this.toString());
  }
  
  
  String toString() {
    String result = "";
    result += _time;
    result += "\t";
    result += _name;
    result += "\t";
    result += _state;
    result += "\t";
    result += _label;
    return result;
  }
}