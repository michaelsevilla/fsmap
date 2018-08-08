// TODO: better errors for incorrectly formatted input
// TODO: 

import java.util.Map;

JSONObject config;
PFont bold, norm;
Legend legend;
Timeline timeline;

HashMap<String, Integer> ttypes;
ArrayList<FS> fss;

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
  int xdesc, ydesc, xname, yname;

  public Technique(String t, String n, String d) {
    type = t;
    name = n;
    desc = d;
    fill = (color) ttypes.get(t);
    xdesc = config.getJSONObject("technique_desc_boxx").getInt("val");
    ydesc = config.getJSONObject("technique_desc_boxy").getInt("val");
    xname = config.getJSONObject("technique_desc_namex").getInt("val");
    yname = config.getJSONObject("technique_desc_namey").getInt("val");
  }
  
  public void draw() {
    drawRect();
    if (over()) {
      // draw box
      fill(color(255));
      stroke(fill);
      strokeWeight(5);
      rect(xdesc, 10, 700, 50, 5);
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
  int year, xdesc, ydesc;
  boolean top;
  ArrayList<Technique> techniques = new ArrayList<Technique>();
  
  FS(String n, color c, String d) {
    fill = c;
    name = n;
    desc = d;
    xdesc = config.getJSONObject("fs_desc_boxx").getInt("val");
    ydesc = config.getJSONObject("fs_desc_boxy").getInt("val");
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
    line(x + size/2, connection, timeline.yearx(year), height/2);    
    
    // draw name
    fill(color(0));
    textFont(bold);
    text(name, x+size/2-5, y+size/2);
    textFont(norm);

    if (over()) {
      // draw box
      fill(color(255)); 
      strokeWeight(5);
      rect(xdesc, ydesc, 200, 50, 5);
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

class Timeline {
  int start, end, pad;
  public Timeline() {
    start = config.getJSONObject("timeline_start").getInt("val");
    end = config.getJSONObject("timeline_end").getInt("val");
    pad = config.getJSONObject("timeline_pad").getInt("val");
  }

  public void draw() {
    strokeWeight(5);
    line(pad, height/2, width - pad, height/2);
    strokeWeight(1);
  
    int timelineLength = width - 2*pad;
    int ticks = end - start;
    int ticki = timelineLength / ticks;
    stroke(color(0));
    for (int i = 0; i < ticks + 1; i++) {
      fill(color(255)); 
      if (i%2 == 0) {
        ellipse(pad + i*ticki, height/2, 45, 45);
        fill(color(0));
        String year = i < 10 ? "\'0" + i : "\'" + i;
        text(year, pad + i*ticki - 10, height/2 + 5);
      } else {
        ellipse(pad + i*ticki, height/2, 20, 20);
      }
    }
  }
  
  // given a year, return the xaxis location
  public int yearx(int year) {
    if (year < start || year > end) {
      System.err.println("ERROR: year of a filesystem (" + year + ") not in timeline range");
      exit();
    }
  
    int timelineLength = width - 2*pad;
    int ticks = end - start;
    int ticki = timelineLength / ticks;
    return pad + ticki * (year - start);
  }  
}

class LegendEntry extends Rect {
  String desc, type;
  int xdesc, ydesc;
  
  public LegendEntry(String t, String d) {
    type = t; 
    desc = d;
    fill = (color) ttypes.get(t);
    xdesc = config.getJSONObject("legend_desc_boxx").getInt("val");
    ydesc = config.getJSONObject("legend_desc_boxy").getInt("val");
  }
  
  public void draw() {
    drawRect();
    textFont(norm, 14);
    fill(color(0));
    text(type, x+20, y+12);
    
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
  int xdesc, ydesc, xshift, eInCol, ePerCol;
  
  Legend() {
    x = 25;
    y = height/2+175;
    xdesc = 500;
    ydesc = y-5;
    xshift = 0;
    eInCol = 1;
    ePerCol = config.getJSONObject("legend_elem_per_col").getInt("val");
  }

  public void draw() {
    fill(0);
    textFont(bold);
    text("Legend:", x, y);
    
    for (int i = 0; i < les.size(); i++)
      les.get(i).draw();
  }

  public void add(LegendEntry e) {
    e.size = 15;
    e.x = x + xshift;
    e.y = y - 13 + eInCol*18;
    les.add(e);

    if (eInCol % ePerCol == 2) {
      xshift += 160;
      eInCol = 0;
    } else {
      eInCol++;
    }
  }  
}

/*
 * Parse configurations and inputs 
 */
public void parseFileSystems(String fname) {
  fss = new ArrayList<FS>();  
  timeline = new Timeline();
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
  legend = new Legend();
  ttypes = new HashMap<String, Integer>();

  JSONArray techniques = loadJSONArray(fname);
  for (int i = 0; i < techniques.size(); i++) {
    String t = techniques.getJSONObject(i).getString("tech");
    String d = techniques.getJSONObject(i).getString("desc");
    ttypes.put(t, colors[i]);
    legend.add(new LegendEntry(t, d));
  }
}

public void parseConfig(String fname) {
  config = loadJSONObject(fname);
  bold = createFont("fonts/CALIBRIB.TTF", 16);
  norm = createFont("fonts/Calibri.ttf", 16);
  frameRate(config.getJSONObject("screen_frame_rate").getInt("val"));
}

/*
 * main (parsing must be done in this order!)
 */
void setup() {
  size(1220, 450);
  parseConfig("input/config.json");
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
