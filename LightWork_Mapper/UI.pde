// //<>// //<>//
//  UI.pde
//  Lightwork-Mapper
//
//  Created by Leo Stefansson and Tim Rolls
//  
//  This class builds the UI for the application
//
//////////////////////////////////////////////////////////////

import controlP5.*;

Textarea cp5Console;
Println console;

void buildUI(int mult) {

  int uiWidth =500 *mult;
  int uiSpacing = 20 *mult;
  int buttonHeight = 25 *mult;
  int buttonWidth =225 *mult;

  PFont pfont = createFont("OpenSans-Regular.ttf", 12*mult, true); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont, 12*mult);
  cp5.setFont(font);
  cp5.setColorBackground(#333333);
  cp5.setPosition((int)((height / 2)*camAspect+uiSpacing), uiSpacing);

  topPanel.setFont(font);
  topPanel.setColorBackground(#333333);
  topPanel.setPosition(uiSpacing, uiSpacing);


  /* add a ScrollableList, by default it behaves like a DropdownList */
  topPanel.addScrollableList("camera")
    .setPosition(0, 0)
    .setSize(buttonWidth, 300)
    .setBarHeight(buttonHeight)
    .setItemHeight(buttonHeight)
    .addItems(enumerateCams())
    .setOpen(false)    
    //.close();
    ;

  topPanel.addButton("refresh")
    .setPosition(buttonWidth+50, 0)
    .setSize(buttonWidth/2, buttonHeight)
    ;


  List driver = Arrays.asList("PixelPusher", "Fadecandy"); //"ArtNet"  removed for now - throws errors
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("driver")
    .setPosition(0, 0)
    .setSize(buttonWidth, 300)
    .setBarHeight(buttonHeight)
    .setItemHeight(buttonHeight)
    .addItems(driver)
    .setType(ControlP5.DROPDOWN)
    .setOpen(false)
    .bringToFront() 
    //.close();
    ;

  //Group network = cp5.addGroup("network")
  //  .setPosition(0, 400)
  //  .setBackgroundHeight(100)
  //  .setWidth(buttonWidth+uiSpacing)
  //  .setBarHeight(buttonHeight)
  //  .setBackgroundColor(color(255, 50))
  //  ;

  cp5.addTextfield("ip")
    .setPosition(0, 350)
    .setSize(buttonWidth, buttonHeight)
    .setAutoClear(false)
    .setValue(network.getIP())
    //.setGroup("network")
    ;

  cp5.addTextfield("leds_per_strip")
    .setPosition(0, 450)
    .setSize(buttonWidth, buttonHeight)
    .setAutoClear(false)
    .setValue(str(network.getNumLedsPerStrip()))
    //.setGroup("network")
    ;

  cp5.addTextfield("strips")
    .setPosition(0, 550)
    .setSize(buttonWidth, buttonHeight)
    .setAutoClear(false)
    .setValue(str(network.getNumStrips()))
    //.setGroup("network")
    ;

  cp5.addButton("connect")
    .setPosition(0, 650)
    .setSize(buttonWidth, buttonHeight)
    .setSize(buttonWidth/2, buttonHeight*2)
    ;

  cp5.addSlider("cvContrast")
    .setBroadcast(false)
    .setPosition(0, 850)
    .setSize(buttonWidth, buttonHeight)
    .setRange(0, 5)
    .setValue(cvContrast)
    .setBroadcast(true)

    ;

  ////set labels to bottom
  cp5.getController("cvContrast").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("cvContrast").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  cp5.addSlider("cvThreshold")
    .setBroadcast(false)
    .setPosition(0, 950)
    .setSize(buttonWidth, buttonHeight)
    .setRange(0, 100)
    .setValue(cvThreshold)
    .setBroadcast(true)
    ;

  //set labels to bottom
  cp5.getController("cvThreshold").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("cvThreshold").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  //capture console events to ui
  cp5.enableShortcuts();
  cp5Console = cp5.addTextarea("cp5Console")
    .setPosition(0, height-200-uiSpacing)
    .setSize(buttonWidth, 200)
    .setFont(createFont("", 12*mult))
    .setLineHeight(16*mult)
    .setColor(color(200))
    .setColorBackground(color(#333333))
    .setColorForeground(color(255, 100))
    ;
  ;

  console = cp5.addConsole(cp5Console);//

  topPanel.addFrameRate().setPosition(0, height-(buttonHeight+uiSpacing));
}

//////////////////////////////////////////////////////////////
// Event Handlers
//////////////////////////////////////////////////////////////

void camera(int n) {
  Map m = topPanel.get(ScrollableList.class, "camera").getItem(n);
  //println(m);
  String label=m.get("name").toString();
  //println(label);
  switchCamera(label);
}

// TODO: investigate why UI switching throws errors, but keypress switching doesn't
void driver(int n) { 
  String label = cp5.get(ScrollableList.class, "driver").getItem(n).get("name").toString().toUpperCase();

  if (label.equals("PIXELPUSHER")) {
    network.shutdown();
    network.setMode(device.PIXELPUSHER);
    println("network: PixelPusher");
  }
  if (label.equals("FADECANDY")) {
    network.shutdown();
    network.setMode(device.FADECANDY);
    println("network: Fadecandy");
  }
  if (label.equals("ARTNET")) {
    network.shutdown();
    network.setMode(device.ARTNET);
    println("network: ArtNet");
  }
}

public void ip(String theText) {
  // automatically receives results from controller input
  println("IP set to : "+theText);
  network.setIP(theText);
}

public void leds_per_strip(String theText) {
  // automatically receives results from controller input
  println("Leds per strip set to : "+theText);
  network.setNumLedsPerStrip(int(theText));
}

public void connect() {

  if (network.getMode()!=device.NULL) {
    network.connect(this);
  } else {
    println("Please select a driver type from the dropdown before attempting to connect");
  }

  if (network.getMode()==device.PIXELPUSHER) {
    network.fetchPPConfig();
    cp5.get(Textfield.class, "ip").setValue(network.getIP());
    cp5.get(Textfield.class, "leds_per_strip").setValue(str(network.getNumLedsPerStrip()));
    cp5.get(Textfield.class, "strips").setValue(str(network.getNumStrips()));
  }
}

public void refresh() {
  String[] cameras = enumerateCams();
  topPanel.get(ScrollableList.class, "camera").setItems(cameras);
}


public void cvThreshold(int value) {
  cvThreshold = value;
  //opencv.threshold(cvThreshold);
  //println("set Open CV threshold to "+cvThreshold);
}

public void cvContrast(float value) {
  cvContrast =value;
  //opencv.contrast(cvContrast);
  //println("set Open CV contrast to "+cvContrast);
}


//////////////////////////////////////////////////////////////
// Camera Switching
//////////////////////////////////////////////////////////////

//get the list of currently connected cameras
String[] enumerateCams() {
  //parse out camera names
  String[] list = Capture.list();
  for (int i=0; i<list.length; i++) {
    String item = list[i]; 
    String[] temp = splitTokens(item, ",=");
    list[i] = temp[1];
  }

  //This operation removes duplicates from the camera names, leaving only individual device names
  //the set format automatically removes duplicates without having to iterate through them
  Set<String> set = new HashSet<String>();
  Collections.addAll(set, list);
  String[] cameras = set.toArray(new String[0]);

  return cameras;
}

//UI camera switching
void switchCamera(String name) {
  cam.stop();
  cam=null;
  cam =new Capture(this, camWidth, camHeight, name, 30);
  cam.start();
}