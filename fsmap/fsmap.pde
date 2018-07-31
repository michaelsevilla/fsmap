import java.util.Map;

JSONObject config;
Legend legend;
Timeline timeline;

int NYEAR = 20;   // number of years
int IYEAR = 2;    // interval between years
int YEARS = 2000; // first year in the timeline
int YEARE = 2020; // last year in the timeline
int TPADX = 100;  // padding for the timeline
int TPART = 10;   // partitions in timeline (e.g., annotated circles)
HashMap<String, Integer> TTYPES;  // number of technique types

PFont bold, norm;
ArrayList<FS> fss = new ArrayList<FS>();

color[] colors = {
  color(237, 0, 255),   // pink
  color(255, 5, 5),     // red
  color(33, 10, 250),   // blue
  color(246, 255, 0),   // yellow
  color(0, 255, 253),   // turqoise
  color(106, 34, 1),    // brown
  color(255, 167, 3),   // orange  
  color(3, 143, 255)    // light blue
};

abstract class Rect {
  int x, y, size;
  color fill;
  boolean over = false;
  //int rfact = config.getJSONObject("round_radius").getInt("val");

  protected void drawRect() {
    fill(fill);
    rect(x, y, size, size, 10);
  }  

  protected boolean over() {
    return mouseX > x && mouseX < x+size && mouseY > y && mouseY < y+size;
  }
}

class Technique extends Rect {
  String type, name, desc;
  int xdesc = config.getJSONObject("technique_desc_boxx").getInt("val");
  int ydesc = config.getJSONObject("technique_desc_boxy").getInt("val");
  int xname = config.getJSONObject("technique_desc_namex").getInt("val");
  int yname = config.getJSONObject("technique_desc_namey").getInt("val");
  
  Technique(String t, String n, String d) {
    type = t;
    name = n;
    desc = d;
    fill = (color) TTYPES.get(t);
  }
  
  public void draw() {
      drawRect();
      if (over()) {
        // draw box
        fill(color(255));
        stroke(fill);
        strokeWeight(5);
        rect(xdesc, 10, 600, 50, 5);
        stroke(color(0));
        strokeWeight(1);
    
        // write out description
        fill(fill);
        textFont(bold);
        text(name, xdesc+10, ydesc+20);
        fill(color(0));
        textFont(norm);
        text(desc, xdesc+10, ydesc+40);
    
        // for name, draw circle and write name
        fill(fill);
        textFont(bold, 30);         
        ellipse(xname, yname, 40, 40);
        text(type, xname+25, yname+10);
        textFont(norm);
      }    
  }
}

class FS extends Rect {
  String name, desc;
  int year;
  int xdesc = config.getJSONObject("fs_desc_boxx").getInt("val");
  int ydesc = config.getJSONObject("fs_desc_boxy").getInt("val");
  boolean top;
  
  ArrayList<Technique> techniques = new ArrayList<Technique>();
  FS(String n, color c, String d) {
    fill = c;
    name = n;
    desc = d;
  }
  
  public void add(Technique t) {
    t.size = 20;
    t.x = x;
    t.y = y + techniques.size()*20;
    techniques.add(t);
  }

  public void draw() {
    // draw line to year
    drawRect();
    int connection = top ? y + size : y;
    line(x + size/2, connection, yearx(year), height/2);    
    
    // draw name
    fill(color(0));
    textFont(bold);
    text(name, x+size/2-5, y+size/2);
    textFont(norm);

    if (over()) {
      // draw box
      fill(color(255)); 
      strokeWeight(5);
      rect(xdesc, ydesc, 180, 50, 5);
      strokeWeight(1);      
  
      // write out description
      fill(color(0));
      textFont(bold);
      text("File System Name:", xdesc+10, ydesc+20);
      textFont(norm);
      text(desc, xdesc+10, ydesc+40);
    }

    // draw techniques
    for (int i = 0; i < techniques.size(); i++)
      techniques.get(i).draw();
  }
}

// given a year, return the xaxis location
int yearx(int year) {
  if (year < YEARS || year > YEARE) {
    System.err.println("ERROR: year of a filesystem (" + year + ") not in timeline range");
    exit();
  }

  int timelineLength = width - 2*TPADX;
  int ticks = YEARE - YEARS;
  int ticki = timelineLength / ticks;
  return TPADX + ticki * (year - YEARS);
}

class Timeline {
  public void draw() {
    strokeWeight(5);
    line(TPADX, height/2, width - TPADX, height/2);
    strokeWeight(1);
  
    int timelineLength = width - 2*TPADX;
    int ticks = YEARE - YEARS;
    int ticki = timelineLength / ticks;
    stroke(color(0));
    for (int i = 0; i < ticks + 1; i++) {
      fill(color(255)); 
      if (i%2 == 0) {
        ellipse(TPADX + i*ticki, height/2, 45, 45);
  
        fill(color(0));
        String year = i < 10 ? "\'0" + i : "\'" + i;
        text(year, TPADX + i*ticki - 10, height/2 + 5);
      } else {
        ellipse(TPADX + i*ticki, height/2, 20, 20);
      }
    }
  }
}

class LegendEntry extends Rect {
  String desc, type;
  int xdesc = config.getJSONObject("legend_desc_boxx").getInt("val");
  int ydesc = config.getJSONObject("legend_desc_boxy").getInt("val");
  
  LegendEntry(String t, String d) {
    type = t; 
    desc = d;
    fill = (color) TTYPES.get(t);
  }
  
  public void draw() {
    drawRect();
    
    if (over()) {
      // draw box
      fill(color(255));
      stroke(fill);
      strokeWeight(5);
      rect(xdesc, ydesc, 600, 50, 5);
      stroke(color(0));
      strokeWeight(1);
  
      // write out description
      fill(color(0));
      textFont(norm);
      text(desc, xdesc+10, ydesc+20);
    }
  }  
}

class Legend extends Rect {
  ArrayList<LegendEntry> les = new ArrayList<LegendEntry>();
  int xshift = 0;
  
  // box holding the description
  int xdesc;
  int ydesc;   
  
  Legend() {
    x = 25;
    y = height/2+175;
    xdesc = 500;
    ydesc = y-5;
  }

  void draw() {
    fill(0);
    textFont(bold);
    text("Legend:", x, y);
    
    for (int i = 0; i < les.size(); i++) {
      les.get(i).draw();
    }
  }

  int i = 1; // elements in column
  int n = 3; // elements per column
  public void add(LegendEntry e) {
    e.size = 15;
    e.x = x + xshift;
    e.y = y - 13 + i*18;
    les.add(e);

    if (i % n == 2) {
      xshift += 175;
      i = 0;
    } else {
      i++;
    }
  }  
};

public void parseFileSystems(String fname) {
  JSONArray data = loadJSONArray(fname);
  int xaxis = 0;  
  for (int j = 0; j < data.size(); j++) {
    JSONObject d = data.getJSONObject(j); 
    FS fs = new FS(d.getString("filesystem"), color(255), d.getString("description"));
    fs.size = 90;
    fs.year = Integer.parseInt(d.getString("year"));
    fs.fill = color(200);

    // alternating top and bottom
    if (j%2 == 0) {
      fs.y = height/4-fs.size/2;
      fs.top = true;
      xaxis++;
    } else {
      fs.y = height*3/4 - fs.size/2;
      fs.top = false;
    }
    fs.x = xaxis*(fs.size + 10) - 80;
    fss.add(fs);

    JSONArray techniques = d.getJSONArray("techniques");
    for (int i = 0; i < techniques.size(); i++) {
      JSONArray t = techniques.getJSONArray(i);
      assert(t.size() == 3);
      fs.add(new Technique(t.getString(0), t.getString(1), t.getString(2)));
    }
  }
}

public void parseTechniques(String fname) {
  TTYPES = new HashMap<String, Integer>();
  JSONArray techniques = loadJSONArray(fname);
  for (int i = 0; i < techniques.size(); i++) {
    String t = techniques.getJSONObject(i).getString("tech");
    String d = techniques.getJSONObject(i).getString("desc");
    TTYPES.put(t, colors[i]);
    legend.add(new LegendEntry(t, d));
  }
}

void setup() {
  size(1150, 450);
  frameRate(15);
  bold = createFont("fonts/CALIBRIB.TTF", 16);
  norm = createFont("fonts/Calibri.ttf", 16);

  legend = new Legend(); 
  timeline = new Timeline();
  config = loadJSONObject("input/config.json");
  parseTechniques("input/techniques.json");
  parseFileSystems("input/filesystems.json");
}

void draw() {
  background(color(255));
  for (FS fs : fss)
    fs.draw();
  timeline.draw();
  legend.draw();
}
