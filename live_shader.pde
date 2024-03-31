import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import themidibus.*;
import javax.sound.midi.MidiMessage; 


boolean showDebug = false;

//TODO load different CC numbers for different shaders
int DIST_CC = 41;
int SIZE_CC = 42;
int COLOR_1_CC = 43;
int TIME_CC = 44;
int COLOR_2_CC = 51;
int SPEED_CC = 61;
int TRIGGER_CUE = 14;


int lastClr1CC = 0;
int lastClr2CC = 0;
int lastSpeedCC = 5; 
int lastTimeCC = 33;
int lastSizeCC = 16;
int lastDistCC = 10;

float lastDist = 3.3;
boolean cueNext = false;
boolean autoCue = false;
int CUE_INTERVAL = 250;
HashMap<Integer,Integer> cueMap;

MidiBus myBus;

String[] shaderNames = {
  "timecube.glsl",
  "expandcollapse.glsl",
  "interference.glsl",
  "neon.glsl",
  "portal.glsl",
  "triskportal.glsl",
  "digification.glsl"
};
String shaderName;

PShader[] shaders;
PShader currShader; 

void setup(){
  size(2560,1600,P3D);
  shaders = new PShader[shaderNames.length];

  for(int i = 0; i < shaderNames.length; i++){
    shaders[i] = loadShader(shaderNames[i]);
    shaders[i].set("iResolution",float(width),float(height));
    
    println("Loaded " + shaderNames[i]);
  }
  
  setShader(0);
  
  MidiBus.list();

  myBus = new MidiBus(this,1,4);
  
  shapeMode(CENTER);
 
  cueMap = new HashMap();
    
  frameRate(120);
  noStroke();
  
  surface.setLocation(0 , displayHeight / 2);
}

void draw(){
  background(0);
  
  currShader.set("iTime",float(millis()) / 1000);
  
  
  drawBackground();
}



void drawBackground(){
  pushMatrix();
  translate(0,0,-50);
  
  shader(currShader);
  
  fill(0);
  rect(-100,-100,width * 1.3,width * 1.3);
  
  resetShader();

  popMatrix();
  
}



void keyPressed(){
    if (key == ESC) {
    key = 0;  // Empêche d'utiliser la touche ESC
  }

  if (key == CODED) {
    if (keyCode == RIGHT) {
    }
    
    if (keyCode == LEFT) {
    }
  }
  if(key == 'd'){ //toggle debug mode
    showDebug = !showDebug;
    if(!showDebug){noCursor();}
    else{cursor();}
    println("Debug " + (showDebug ? "On" : "Off"));
  }
  
  
  if(key == 'r'){
    println("Resetting....\n\n");
  
  }
  
  else{
    int num = int(key) - 49;
        println(num);

    if(num >= 0 && num < shaders.length){
      
      setShader(num);
    
    }
  }
}

void setShader(int num){
  currShader = shaders[num];
  shaderName = shaderNames[num];
  println("Shader " + num + ": " + shaderName + " loaded");
}

void handleCC(int cc){


  
  if(shaderName == "digification.glsl"){
    if(cc == TIME_CC){   
      float timeFactor = map2(lastTimeCC,0,127,.042,42,SQRT, EASE_OUT);
      currShader.set("timeFactor",timeFactor);
    }
    
    if(cc == SIZE_CC){
      float sizeFactor = map(lastSizeCC,0,127,0.2,5);
      currShader.set("sizeFactor",sizeFactor);
    }
    
    if(cc == COLOR_1_CC){
      float clrFactor = map(lastClr1CC,0,127,0.000001,1.5);
      currShader.set("clrFactor",clrFactor);
    }
  }

  if(shaderName == "timecube.glsl"){
    if(cc == TIME_CC){
      float timeFactor = map2(lastTimeCC,0,127,.03,3,LINEAR, EASE_IN_OUT);
      currShader.set("timeFactor",timeFactor);
    }
    
    if(cc == SIZE_CC){
      float iterations = map2(lastSizeCC,0,127,5,200,SQRT, EASE_OUT);
      currShader.set("iterations",iterations);
    }

    if(cc == DIST_CC){
      float dist = map(lastDistCC,0,127,1,30);
      
      float progress = 0.3;
    
      float cameraDist = lerp(lastDist,dist,progress);

      lastDist = cameraDist;

      currShader.set("cameraDist",cameraDist);
    }

    if(cc == SPEED_CC){
      float flashSpeedFactor = map(lastSpeedCC,0,127,.1,10);
      currShader.set("flashSpeedFactor",flashSpeedFactor);
    }
    
    if(cc == COLOR_1_CC){
      float clrFactor = map(lastClr1CC,0,127,0.0003,3000);
      currShader.set("clrFactor",clrFactor);
    }    
    if(cc == COLOR_2_CC){
      float clrThreshold = map(lastClr2CC,0,127,0.05,.5);
      currShader.set("clrThreshold",clrThreshold);
    }
  }
}

  
void controllerChange(int channel, int number, int value) {  
  println("CC"+number+": " + value);
  
  if(number == COLOR_1_CC) {
    lastClr1CC = value;
  }  
  if(number == COLOR_2_CC) {
    lastClr2CC = value;
  }
  if(number == SIZE_CC){
    lastSizeCC = value;
  }
  if(number == TIME_CC){
    lastTimeCC = value;
  } 
  if(number == SPEED_CC){
    lastSpeedCC = value;
  }
  if(number == DIST_CC){
    lastDistCC = value;
  }
  
  if(autoCue || cueNext){

    int time = millis();
    cueMap.put(number,time);

    new java.util.Timer().schedule( 
        new java.util.TimerTask() {
            @Override
            public void run() {
              int lastTime = cueMap.get(number);

              if(millis() - lastTime > CUE_INTERVAL){
                  handleCC(number);
              }
              println(number + " " + time);
            }
        }, 
        CUE_INTERVAL 
  );
  }
  else{
    handleCC(number);
  }
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);

  println(note + ": " + vel);

  //workaround for Trigger Finger pads not sending CCs correctly
  if(vel > 0){
    //Tap once to cue next CC, tap twice to cue all CCs until tapped again
    if(note == TRIGGER_CUE){
      if(autoCue){
        autoCue = false;
        cueNext = false;
        return;
      }
      if(cueNext){
        autoCue = true;
        return;
      }

      cueNext = true;
    }

  }
}
