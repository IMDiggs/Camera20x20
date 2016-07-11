// libs
import processing.serial.*;
import processing.video.*;

// create instances
OPC opc;
Capture cam;

// reading serial values
Serial myPort;
String serialValue;

// control application flow
boolean buttonPressed;
boolean timerIsRunning;
int timeStartSecond;

// drawing
PImage dot;
float avg_r;
float avg_g;
float avg_b;
float filter = 20;

// user input
boolean spacePressed;


void setup() {
  timerIsRunning = false;

  String portName = Serial.list()[2];
  myPort = new Serial(this, portName, 9600);
  myPort.clear();

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      print(i);
      println(cameras[i]);
    }
  }  
  cam = new Capture(this, cameras[0]);
  cam.start();     
  noStroke();
  background(0);
  size(640, 480);

  opc = new OPC(this, "127.0.0.1", 7890);

  float horizontalSpacing = width / 32.0;
  float verticalSpacing  = height / 25.0;


  opc.ledGrid(0, 20, 3, width/2, height/8, horizontalSpacing, verticalSpacing, 0, false);
  opc.ledGrid(64, 20, 3, width/2, (height/8)*2, horizontalSpacing, verticalSpacing, 0, false);
  opc.ledGrid(128, 20, 3, width/2, (height/8)*3, horizontalSpacing, verticalSpacing, 0, false);
  opc.ledGrid(192, 20, 3, width/2, (height/8)*4, horizontalSpacing, verticalSpacing, 0, false);
  opc.ledGrid(256, 20, 3, width/2, (height/8)*5, horizontalSpacing, verticalSpacing, 0, false);
  opc.ledGrid(320, 20, 3, width/2, (height/8)*6, horizontalSpacing, verticalSpacing, 0, false);
  opc.ledGrid(384, 20, 2, width/2, (height/8)*7-verticalSpacing/2, horizontalSpacing, verticalSpacing, 0, false);
}
void draw() {
  if ( myPort.available() > 0) {
    serialValue = myPort.readStringUntil(10);
  } 
  if (cam.available() == true) {
    cam.read();
    cam.loadPixels();

    for (int x = 0; x < cam.width; x+=filter) {
      for (int y = 0; y < cam.height; y+=filter ) {

        avg_r = avg_g = avg_b = 255.0;

        for (int r = x; r < x+filter; r++) {
          for (int c = y; c < y+filter; c++ ) {
            int loc = r + c*cam.width;

            if (loc < cam.pixels.length) {
              avg_r += red   (cam.pixels[loc]);
              avg_g += green (cam.pixels[loc]);
              avg_b += blue  (cam.pixels[loc]);
            }
          }
        }

        color col = color(avg_r/(filter*filter), avg_g/(filter*filter), avg_b/(filter*filter));
        fill( col );
        rect(x, y+10, filter, filter);
      }
    }
    
    
    // detect if the button is pressed
    if (serialValue != null) {
      serialValue = trim(serialValue);
      println(serialValue);
      if (serialValue.equals("1")) {
        // button in up state
        buttonPressed = true;
      } else if(serialValue.equals("0")) {
        // button in down state
        buttonPressed = false;
      }
    }
  }

  
  if(buttonPressed){
    if(!timerIsRunning){
      println("timer started");
      timeStartSecond = second();
      timerIsRunning = true;
    }
  }
   
  if(timerIsRunning){
    fill(255);
    int timerState = 0;    
    int currentSecond = second();
  
    // gather the timer state
    if(currentSecond < timeStartSecond + 2){
      timerState = 3;
    } else if(currentSecond < timeStartSecond + 3){
      timerState = 2;
    } else if(currentSecond < timeStartSecond + 4){
      timerState = 1;        
    } else {
      timerState = 0;
    }
    
//    print("timer state:");
//    println(timerState);
//    print("seconds:");
//    println(currentSecond);

    if(timerState == 3){
      rect((6*20)+120, (4*20)+30, (8*20), (2*20));
      rect((7*20)+100, (10*20)+10, (8*20), (2*20));
      rect((7*20)+100, (15*20)+10, (8*20), (2*20));
      rect((13*20)+100, (5*20)+10, (2*20), (12*20));
    } else if(timerState == 2){
      rect((6*20)+120, (4*20)+30, (8*20), (2*20));
      rect((7*20)+100, (10*20)+10, (8*20), (2*20));
      rect((7*20)+100, (15*20)+10, (8*20), (2*20));
      rect((13*20)+100, (5*20)+10, (2*20), (7*20));
      rect((7*20)+100, (10*20)+10, (2*20), (7*20));
    } else if(timerState == 1){
      rect((10*20)+120, (4*20)+30, (2*20), (12*20));
    } else {
      timerIsRunning = false;
      println("DONE!");
      rect((1*20)+100, (1*20)+10, (20*20), (20*20));
      println("done drawing");
//      delay(5000);
    }
    
  }

//  println("second: "+s+"  curSec: "+curSec+"  button state: "+val+ "  timerStart: "+timerStart);
}

void keyPressed() {
  if (key == ' ') {
    spacePressed=true;
  }
}

