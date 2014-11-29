//////////////////////////////////////////////////////////////////////////
/*
  
  This is Processing sketch that converts html and text file to a header file
  that places the contents in progmem. This way you can develop you web pag(s)
  with something like Dreamweaver then conver the HTML to a header file and load it into Progmem.
  
*/

//////////////////////////////////////////////////////////////////////////


//import libraries

//library can be found here:
//http://www.sojamo.de/libraries/controlP5/
import controlP5.*;

//File Handler variables
PrintWriter output;
PrintWriter LoopFileOutput;

//store HTML lines in this array
String[] HTMLlines;
int LineNumber;

//File names and text status variables
String HTMLPath="None Chosen";
String OutputPath = "None Chosen";
String Status = " ";

//variable to access ControlP5 class
ControlP5 cp5;

void setup() {
 
  //set up the screen size and layout the buttons
  
  size(550, 650);
  cp5 = new ControlP5(this);
  
  
  cp5.addButton("HTMLSelect")
    .setSize(130, 35)
    .setPosition(43, 180)
    .setLabel("Select an HTML file");
  
  
  
  cp5.addTextfield("ArduinoName")
    .setLabel("Arduino Header File Name")
    .setPosition(43, 269)
    .setSize(300, 30);
    
  
  cp5.addButton("OutputSelect")
    .setLabel("Select Directory")
    .setPosition(43, 347)
    .setSize(130, 35);
  
  
  
  cp5.addButton("Run")
    .setPosition(43, 440)
    .setSize(130, 35);
  
    
  cp5.addButton("Exit")
    .setPosition(43, 550)
    .setSize(130, 35);
  
}

void draw() {
  //continuosly draw background and update text statuses
  background(10, 30, 30);
  drawText();

}

void drawText() {
  
  textSize(12);
  text("HTML to Progmem Conversion Program", 43, 50);
  text("- After program runs, an Arduino header file will be produced", 43, 90);
  text("- add the file to sketch folder with your Arduino .ino file", 43, 105);
  text("- be sure to add '#include file.h to your Arduino sketch", 43, 120);
  
  text("1. Select an HTML File", 43, 160);
  textSize(8);
  text(HTMLPath, 43, 227);
  textSize(12);
  text("2. Choose a file name for the Arduino header file (no spaces or special char)", 43,255);
  text("3. Select a directory to store the header file", 43, 335);
  textSize(8);
  text(OutputPath, 43, 392);
  textSize(12);
  text("4. Only run if steps 1 to 3 have been completed", 43, 425);
  textSize(13);
  
  text(Status, 43, 490);
}

//Button Functions

public void HTMLSelect() {
  selectInput("Select an HTML file: ", "HTMLProcess");

} 

void HTMLProcess(File selection) {
  
  if (selection == null) {
    HTMLPath = "None Chosen";
  } else {
    HTMLPath = selection.getAbsolutePath();
  }
}

public void OutputSelect() {
  selectFolder("Select an output Folder: ", "OutputProcess");
}

void OutputProcess(File selection) {
  if (selection == null) {
    OutputPath = "None Chosen";
  } else {
    OutputPath = selection.getAbsolutePath();
  }

}

public void Run() {
  
  
  String ArduinoFileName = cp5.get(Textfield.class,"ArduinoName").getText();
  String thePattern = "[^A-Za-z0-9]+";
  String [] m = match(ArduinoFileName, thePattern);
  
  println("Found: " + m);
  println("HTML Path:" + HTMLPath);
  println(".h Name:" + ArduinoFileName);
  
  if (m != null) {
    Status = "NOT A VALID FILE NAME";
  } else {
    try {
      Status = "Running";
      HTMLlines = loadStrings(HTMLPath);
      try {
        
        output = createWriter(OutputPath + "/" + ArduinoFileName + ".h");
        WriteHeader();
        WriteBody();
        
        output.flush();
        output.close();
        
        //retore the screen size
        size(550, 650);
        Status = "File Conversion Complete";
      } catch (Exception e) {
        
        //restore the screen size
        size(550, 650);
        e.printStackTrace();
        Status = "ERROR WRITING FILE!";
        HTMLPath = "Choose new file";
      }
        
    } catch (Exception e) {
      size(550, 650);
      println(e);
      e.printStackTrace();
      Status = "ERROR LOADING HTML FILE!";
      HTMLPath = "Choose new file";
    }
  } 

}

void Exit() {
  exit();
}

// Functions to Write Arduino Sketch
void WriteHeader() {
  output.println("#include <avr/pgmspace.h>");
  output.println("\n\n");
  output.println("prog_uchar varName[] PROGMEM ={");
}
void WriteBody() {
  for (int i = 0; i < HTMLlines.length; i++) {
    //output.print('"');
    // Replave all the current \" instances with |@ so the " 
    // does not get messes up.
    HTMLlines[i] = HTMLlines[i].replace("\\\"","|@"); 
    // Replace " with \" to create quotes inside the string   
    HTMLlines[i] = HTMLlines[i].replace("\"","\\\"");
    // Put the original \" instances back.
    HTMLlines[i] = HTMLlines[i].replace("|@","\\\"");
    // Write the lines starting with a tab then " and ending with a NewLins char and a "  
    output.println("\t\"" + HTMLlines[i] + "\\n\"");
    //output.println("\\n\"");
  }
  output.print("};\n");
}

    

