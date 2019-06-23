/*
  Playing around with hex drawing, as described at:
  http://www.redblobgames.com/grids/hexagons/
  
  Grid shapes are described in arrays of arrays:
  {skip_count, fill_count, skip_count ...}
*/


import processing.net.*;
import java.util.regex.*;

boolean DRAW_LABELS = false;
boolean POINTY_TOP = true;
boolean DARK_MODE = false;

// model vars
HexForm honeycomb = null;
HashMap<Integer,String> labels = null;

// network vars
int port = 4444;
Server _server; 
StringBuffer _buf = new StringBuffer();

color defaultHexLine() {
  return DARK_MODE ? color(255,255,255) : color(0,0,0);
}

color defaultHexFill() {
  return DARK_MODE ? color(0,0,0) : color(255,255,255);
}

void setup() {
  size(500,550);
  frameRate(30);
  
  //  println(PFont.list());
  PFont f = createFont("Helvetica", 12, true);
  textFont(f, 12);
  
  labels = loadLabels("mapping.csv");
  
  honeycomb = makeSimpleGrid(6,8,100,100);  
  //honeycomb = makeHexForm(SNOWFLAKE, 50, 50);
  
  _server = new Server(this, port);
  println("server listening:" + _server);
}

void drawCheckbox(int x, int y, boolean checked) {
  int size = 20;
  stroke(0);
  fill(255);  
  rect(x,y,size,size);
  if (checked) {    
    line(x,y,x+size,y+size);
    line(x+size,y,x,y+size);
  }  
}

void drawBottomControls() {
  // draw a bottom white region
  fill(255,255,255);
  rect(0,500,500,50);
  
  // draw checkboxes
  stroke(0);
  fill(255);
  drawCheckbox(20,510, DRAW_LABELS); // label checkbox
  drawCheckbox(190,510, POINTY_TOP); // pointy-top checkbox
  drawCheckbox(360,510, DARK_MODE); // dark mode
    
  // draw text labels
  fill(0);
  textAlign(LEFT);  
  text("Draw Labels", 50, 525);
  text("Pointy Top", 220, 525);
  text("Dark Mode", 390, 525);
}

void mouseClicked() {  
  //println("click! x:" + mouseX + " y:" + mouseY);
  if (mouseX > 20 && mouseX < 40 && mouseY > 510 && mouseY < 530) {
    // clicked draw labels button
    DRAW_LABELS = !DRAW_LABELS;
  } else if (mouseX > 190 && mouseX < 210 && mouseY > 510 && mouseY < 530) {
    // clicked pointy-top button
    POINTY_TOP = !POINTY_TOP;    
  } else if (mouseX > 360 && mouseX < 380 && mouseY > 510 && mouseY < 530) {
    DARK_MODE = !DARK_MODE;
  }  
}

void draw() {
  background(200);
  
  drawBottomControls();
  
  if (POINTY_TOP) {
    rotate(radians(30));
    translate(80,-140);
  }

  honeycomb.draw();
  pollServer();
}

/*
 * Network server
 */
void pollServer() {
  try {
    Client c = _server.available();
    // append any available bytes to the buffer
    if (c != null) {
      _buf.append(c.readString());
    }
    // process as many lines as we can find in the buffer
    int ix = _buf.indexOf("\n");
    while (ix > -1) {
      String msg = _buf.substring(0, ix);
      msg = msg.trim();
      //println(msg);
      processCommand(msg);
      _buf.delete(0, ix+1);
      ix = _buf.indexOf("\n");
    }
  } catch (Exception e) {
    println("exception handling network command");
    e.printStackTrace();
  }  
}

Pattern cmd_pattern = Pattern.compile("^\\s*(\\d+)\\s+(\\d+),(\\d+),(\\d+)\\s*$");

void processCommand(String cmd) {
  Matcher m = cmd_pattern.matcher(cmd);
  if (!m.find()) {
    println("ignoring input!");
    return;
  }
  int cell = Integer.valueOf(m.group(1));
  int r    = Integer.valueOf(m.group(2));
  int g    = Integer.valueOf(m.group(3));
  int b    = Integer.valueOf(m.group(4));
  
  //println(String.format("setting cell:%d to r:%d g:%d b:%d", cell, r, g, b));
  honeycomb.setCellColor(cell, color(r,g,b));  
}

/*
 * Load label mapping file
 */
HashMap<Integer,String> loadLabels(String labelFile) {
  HashMap<Integer,String> labels = new HashMap<Integer,String>();  
  Table table = loadTable(labelFile);
      
  println(table.getRowCount() + " total rows in table"); 

  for (TableRow row : table.rows()) {
    int id = row.getInt(0);
    String coord = row.getString(1);
    labels.put(id, coord);    
 //   println(coord + " has an ID of " + id);
  }
  return labels;
}  

/*
 * Hex model
 */
int[][] SNOWFLAKE = {
  {3, 2, 3, 2},
  {2, 8},
  {3, 7},
  {2, 8},
  {2, 9},
  {0, 12},
  {0, 13},
  {0, 12},
  {2, 9},
  {2, 8},
  {3, 7},
  {2, 8},
  {3, 2, 3, 2}
};

HexForm makeHexForm(int[][] BLOB, int start_x, int start_y) {
  
  HexForm form = new HexForm();
  
  int y = start_y;
  for (int i=0; i<BLOB.length; i++) {
    int[] row = BLOB[i];
    
    int x = start_x;    
    // if we're on an even row, must offset by 1/2 hex width
    // XXX odd or even needs to be a parameter!
    if (i % 2 == 1) {
      x += int(0.5 * hexWidth());
    }    
    
    for (int j=0; j<row.length; j++) {
      int val = row[j];      
      
      if (j % 2 == 0 ) { // skip
        x += hexWidth() * val;        
      } else { // draw
        for (int k=0; k<val; k++) {
          form.add(new Hex(x,y));
          x += hexWidth();
        }        
      }
    }    
    y += vertDistance();
  }
  println("hex form contains " + form.size() + " cells");
  return form;  
}

HexForm makeSimpleGrid(int rows, int colsz, int start_x, int start_y) {
  HexForm form = new HexForm();
  
  int y = start_y;
  int cols = 2;
  for (int i=0; i<rows; i++) {
    int x = start_x;
    if (i ==6) { continue;}
    if (i == 7) {continue;}
    if (i == 2) {continue;}
    if (i == 3) {continue;}
    if (i == 4) {continue;}
    if (i == 5) {continue;}
    
    // if we're on an odd row, must offset by 1/2 hex width
    // XXX need to parameterize this! But by what heuristic?
//    if (i % 2 == 0) {
//      x += int(hexWidth());
//    }
    for (int j=0; j<cols; j++) {
      print("CREATE HEX\n",j);
      form.add(new Hex(x,y));
      x += hexWidth()+50;
    }
    y += vertDistance();
  }
  return form;  
}

class HexForm {
  ArrayList<Hex> hexes;
  //HashMap<String,Hex> hexesById;
  
  HexForm() {
    hexes = new ArrayList<Hex>();
    //hexesById = new HashMap<String, Hex>();
  }
  
  void add(Hex h) {
    int hexId = hexes.size();
    if (labels != null) {
      h.setId(labels.get(hexId));
    } else {
      h.setId(String.valueOf(hexId));
    }
    hexes.add(h);
  }
  
  int size() {
    return hexes.size();
  }
  
  void draw() {
    for (Hex h : hexes) {
      h.draw();
    }
  }
  
  // XXX probably need a better API here!
  void setCellColor(int i, color c) {
    if (i >= hexes.size()) {
      println("invalid offset for HexForm.setColor: i only have " + hexes.size() + " hexes");
      return;
    }
    hexes.get(i).setColor(c);
  }
    
}

/*
 *  Hex shape primitives
 */
int HEX_SIZE = 20;

public float hexWidth() {
  return sqrt(3)/2 * hexHeight();
}
  
public float hexHeight() {
  return HEX_SIZE * 2;    
}
  
public float vertDistance() {
  return 0.75 * hexHeight();
}

class Hex {
  String id = null; // optional
  int x;
  int y;
  Integer c; // can store color/int or null
  
  Hex(int x, int y) {
    print("CreateHex\n");
    this.x = x;
    this.y = y;
    this.c = null;
  }

  void setId(String id) {
    this.id = id;
  }
  
  void setColor(color c) {
    this.c = c;
  }

  void polygon(float x, float y, float radius, int npoints) {
    float angle = TWO_PI / npoints;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
        float sx = x + cos(a) * radius;
        float sy = y + sin(a) * radius;
        vertex(sx, sy);
  }
  endShape(CLOSE);
}

  void draw() {
    color fill_color = (this.c != null) ? c : defaultHexFill();  
    fill(fill_color);
    stroke(defaultHexLine());

    beginShape();
//    for (int i=0; i<6; i++) {
//      float angle = (2 * PI) / 6 * (i + 0.5);
//      int x_i = int(x + HEX_SIZE * cos(angle));
//      int y_i = int(y + HEX_SIZE * sin(angle));
//      vertex(x_i, y_i);
//    print("TRI",x, y,"\n");
    polygon(x, y, 30, 3);	

    
    endShape(CLOSE);
    
    // draw text label
    if (DRAW_LABELS && this.id != null) {
      fill(defaultHexLine());
      textAlign(CENTER);
      text(this.id, this.x, this.y);
    }
    noFill();
    
    
  }
}
