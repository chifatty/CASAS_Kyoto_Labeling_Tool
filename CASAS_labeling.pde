import java.io.*;
import java.util.*;
import java.text.*;

int current_index = -1;
PImage bg_image;
String display_time = "";
String file_name = "";
Map<String, Sensor> sensors = new HashMap<String, Sensor>();
Map<String, Partition> partitions = new HashMap<String, Partition>();
ArrayList<SensorEvent> sensor_events = new ArrayList<SensorEvent>();
BufferedReader sensor_data_reader = null;
BufferedReader sensor_label_reader = null;
BufferedWriter sensor_label_writer = null;

final int limit = 40; 

boolean reading_progress = false;

void setup() {
  size(942, 576);
  
  loadPartitions();
  loadSensors();
  
  bg_image = loadImage("sensorlayout.jpg");  
  selectInput("Select a file to read from:", "inputFileSelected");
  frameRate(30);
}


void draw() {
  background(bg_image);
  
  textSize(16);
  fill(0, 102, 153, 204);
  text(display_time, 741, 30); 
  
  for (Map.Entry<String, Partition> p : partitions.entrySet()){
    p.getValue().display();
  }
  
  for (Map.Entry<String, Sensor> s : sensors.entrySet()){
    s.getValue().display();
  }
  
  readProgress();
}


void exit() {
  println("exit");
  try {
    for (int i = 0; i < sensor_events.size(); i++ ) {
      saveLabel(sensor_events.get(i));
    }
    sensor_label_writer.flush();
    sensor_label_writer.close();
    File label_file = new File(file_name + ".label");
    File tmp_output = new File(file_name + ".label.tmp");
    label_file.delete();
    tmp_output.renameTo(label_file);
  }
  catch (NullPointerException e) {
  }
  catch (IOException e) {
     e.printStackTrace();
  }
  super.exit(); // Stops the program 
}


void loadPartitions() {
  JSONObject partition_config;
  partition_config = loadJSONObject("partitions.json");
  Set<String> names = partition_config.keys();
  for (String name : names) {
    Partition p = new Partition(name, partition_config);
    partitions.put(name, p);
  }
}


void loadSensors() {
  JSONObject sensor_config;
  sensor_config = loadJSONObject("sensors.json");
  Set<String> names = sensor_config.keys();
  for (String name : names) {
    JSONObject pos = sensor_config.getJSONObject(name);
    Sensor s = new Sensor(name, pos.getInt("x"), pos.getInt("y"));
    sensors.put(name, s);
  }
}


void inputFileSelected(File selection) {
  if (selection == null)
    return;
  file_name = selection.toString();
  try {
    sensor_data_reader = new BufferedReader(new FileReader(selection));
  } 
  catch (Exception e) {
    // e.printStackTrace();
  }
  try {
    File label_file = new File(file_name + ".label");
    sensor_label_reader = new BufferedReader(new FileReader(label_file));
  }
  catch (Exception e) {
    // e.printStackTrace();
  }
  try {
    File tmp_output = new File(file_name + ".label.tmp");
    sensor_label_writer = new BufferedWriter(new FileWriter(tmp_output));
  }
  catch (Exception e) {
    // e.printStackTrace();
  }
  
  if (sensor_data_reader != null && sensor_label_reader != null && sensor_label_writer !=null) {
    reading_progress = true;
  }
}


/**
* Process one read line of the data file
* Expected format is dateTABsensorTABvalue
* Date in the format: yyyy-MM-dd hh:mm:ss.S
*
*/

SensorEvent processLine(String str) throws ParseException {
  
  if (str == null)
    return null;
  String[] pieces = str.split("\t");
  if (pieces.length < 3)
    return null;
  String time = pieces[0];
  String name = pieces[1];
  String state = pieces[2];
  String label = pieces.length == 4 ? pieces[3] : "";
  if (!sensors.containsKey(name))
    return null;
  return new SensorEvent(time, name, state, label);
}


SensorEvent readNextSensorEvent(BufferedReader reader) {
  try {
    String line = reader.readLine();
    SensorEvent event = processLine(line.trim());
    while (event == null && line != null) {
      line = reader.readLine();
      event = processLine(line.trim());
    }
    return event;
  }
  catch (Exception e) {
    reader = null;
    return null;
  }
}


void readProgress() {
  if (!reading_progress)
    return;
  if (sensor_data_reader == null || sensor_label_reader == null || sensor_label_writer == null) {
    reading_progress = false;
    return;
  }
  
  pushStyle();
  noStroke();
  fill(color(128));
  rect(300, 238, 330, 65);
  textSize(32);
  fill(color(255));
  text("Reading Progress ...", 305, 280);
  popStyle();
  
  SensorEvent sensor_event = null;
  SensorEvent labeled_event = null;
 
  current_index++;
  
  if (current_index == sensor_events.size() && sensor_data_reader != null) {
    labeled_event = readNextSensorEvent(sensor_label_reader);
    if (labeled_event != null) {
      sensor_events.add(labeled_event);
      sensor_event = readNextSensorEvent(sensor_data_reader);
    }
  }
  
  if (labeled_event == null) {
    current_index--;
    reading_progress = false;
    return;
  }
  
  labeled_event.readLabel(partitions);
  display_time = labeled_event.getTime();
  Sensor s = sensors.get(labeled_event.getName());
  // println(sensor_events.size(), labeled_event.getTime(), labeled_event.getName(), labeled_event.getState());
  if (labeled_event.getState().equals("OFF") || labeled_event.getState().equals("CLOSE"))
    s.mark(false);
  else if (labeled_event.getState().equals("ON") || labeled_event.getState().equals("OPEN"))  
    s.mark(true);  
  
  if (sensor_events.size() > limit) {
    current_index--;
    saveLabel(sensor_events.get(0));
    sensor_events.remove(0); 
  }
}


void forward() {
  int previous_index = current_index;
  SensorEvent current_event = null;
  SensorEvent previous_event = null;
  
  current_index++;
  if (current_index == sensor_events.size() && sensor_data_reader != null) {
    current_event = readNextSensorEvent(sensor_data_reader);
    if (current_event != null)
      sensor_events.add(current_event);
  }
  
  if (current_event == null) {
    if (sensor_events.size() == 0)
        return;
    if (current_index == sensor_events.size()) {
      current_index--;
      previous_index--;
    }
    current_event = sensor_events.get(current_index);
  }
  
  if (previous_index >= 0) {
    previous_event = sensor_events.get(previous_index);
    previous_event.label(partitions);
  }
  
  current_event.readLabel(partitions);
  current_event.label(partitions);
  display_time = current_event.getTime();
  Sensor s = sensors.get(current_event.getName());
  // println(sensor_events.size(), current_event.getTime(), current_event.getName(), current_event.getState());
  if (current_event.getState().equals("OFF") || current_event.getState().equals("CLOSE"))
    s.mark(false);
  else if (current_event.getState().equals("ON") || current_event.getState().equals("OPEN"))  
    s.mark(true);  
  
  if (sensor_events.size() > limit) {
    current_index--;
    saveLabel(sensor_events.get(0));
    sensor_events.remove(0); 
  }
}


void backward() {
  if (current_index <= 0)
    return;
  SensorEvent event = sensor_events.get(current_index);
  Sensor s = sensors.get(event.getName());
  if (event.getState().equals("OFF") || event.getState().equals("CLOSE"))
    s.mark(true);
  else if (event.getState().equals("ON") || event.getState().equals("OPEN"))  
    s.mark(false);
  current_index = max(current_index - 1, 0);
  event = sensor_events.get(current_index);
  event.readLabel(partitions);
  display_time = event.getTime();
  
}

void saveLabel(SensorEvent event) {
  if (sensor_label_writer == null)
    return;
  try{
    sensor_label_writer.write(event.toString());
    sensor_label_writer.newLine();
  }
  catch(IOException e){
    e.printStackTrace();
  }
}


void mouseClicked() {
  if (reading_progress)
    return;
  for (Map.Entry<String, Partition> p : partitions.entrySet()){
    p.getValue().select(mouseX, mouseY);
  }
  if (sensor_events.size() != 0) {
    SensorEvent current_event = sensor_events.get(current_index);
    current_event.label(partitions);
  }
}

void mouseMoved() {
  if (reading_progress)
    return;
  for (Map.Entry<String, Partition> p : partitions.entrySet()){
    p.getValue().hover(mouseX, mouseY);
  }
}

void keyPressed() {
  if (reading_progress)
    return;
  if (key == CODED) {
    if (keyCode == RIGHT) {
      forward();
    } else if (keyCode == LEFT) {
      backward();
    } 
  } 
}