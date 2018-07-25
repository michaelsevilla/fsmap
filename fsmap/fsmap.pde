// TODO: sort list
import java.util.Map;

int LINE1 = 30;   // y shify for the 1st line of text
int LINE2 = 50;   // y shift for the 2nd line of text
int LINEX0 = 10;  // left align of the text
int LINEX1 = 200; // left align of the text
int LINEX2 = 500; // left align of the text
int RFACT = 10;   // radius of rounded portion of rect
int NYEAR = 20;   // number of years
int IYEAR = 2;    // interval between years
int YEARS = 2000; // first year in the timeline
int YEARE = 2020; // last year in the timeline
int TPADX = 100;  // padding for the timeline
int TPART = 10;   // partitions in timeline (e.g., annotated circles)
HashMap<String, Integer> TTYPES;  // number of technique types

int TIMELINE0 = 100;

PFont bold, norm;
ArrayList<FS> fss = new ArrayList<FS>();

abstract class rect {
  int x, y, size;
  color fill;
  boolean over = false;

  protected void drawRect() {
    fill(fill);
    rect(x, y, size, size, RFACT);
  }  

  protected boolean over() {
    return mouseX > x && mouseX < x+size && mouseY > y && mouseY < y+size;
  }
}

class Technique extends rect {
  String type, name, desc;
  Technique(String t, String n, String d) {
    type = t;
    name = n;
    desc= d;
    fill = (color) TTYPES.get(t);
  }

  public void drawDesc() {
    // draw box
    fill(color(255));
    stroke(fill);
    strokeWeight(5);
    rect(LINEX2, 10, 600, 50, 5);
    stroke(color(0));
    strokeWeight(1);

    // write description
    fill(fill);
    textFont(bold);
    text(name, LINEX2+10, LINE1);
    fill(color(0));
    textFont(norm);
    text(desc, LINEX2+10, LINE2);

    // draw circle
    fill(fill);
    ellipse(LINEX1+20, LINE1+5, 40, 40);

    // write out technique
    textFont(bold); 
    textSize(30);
    text(type, LINEX1+50, LINE2-5);
    textFont(norm);
  }
}

class FS extends rect {
  String name, desc;
  int year;
  boolean top;
  ArrayList<Technique> techniques = new ArrayList<Technique>();
  FS(String n, color c, String d) {
    fill = c;
    name = n;
    desc = d;
  }

  private void drawToYear() {
    int connection = top ? y + size : y;
    line(x + size/2, connection, yearx(year), height/2);
  }

  private void drawFSName() {
    fill(color(0));
    textFont(bold);
    text(name, x+size/2-5, y+size/2);
    textFont(norm);
  }

  private void drawFSDesc() {
    // draw box
    fill(color(255));
    strokeWeight(5);
    rect(LINEX0, 10, LINEX1-20, 50, 5);
    strokeWeight(1);      

    // write description
    fill(color(0));
    textFont(bold);
    text("File System Name:", LINEX0+10, LINE1);
    textFont(norm);
    text(desc, LINEX0+10, LINE2);
  }

  public void addtech(Technique t) {
    t.size = 20;
    t.x = x;
    t.y = y + techniques.size()*20;
    techniques.add(t);
  }

  public void draw() {
    drawToYear();
    drawRect();
    drawFSName();

    if (over())
      drawFSDesc();

    for (int i = 0; i < techniques.size(); i++) {
      Technique t = techniques.get(i);
      t.drawRect();
      if (t.over())
        t.drawDesc();
    }
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

void drawTimeline() {
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

void drawLegend() {
  int xshift = LINEX0+15;  

  fill(0);
  textFont(bold);
  text("Legend:", xshift-10, height/2+175);

  int i = 1; // elements in column
  int n = 3; // elements per column
  for (Map.Entry t : TTYPES.entrySet()) {
    fill((color) t.getValue());
    ellipse(xshift, height/2+172+i*20, 18, 18);

    textFont(norm);
    fill(color(0));
    text((String) t.getKey(), xshift+15, height/2+175+i*20);

    if (i % n == 2) {
      xshift += 175;
      i = 0;
    } else {
      i++;
    }
  }
}

public void parse(String fname) {
  JSONArray data = loadJSONArray(fname);
  int xaxis = 0;  
  for (int j = 0; j < data.size(); j++) {
    JSONObject d = data.getJSONObject(j); 
    FS fs = new FS(d.getString("filesystem"), color(255), d.getString("description"));
    fs.size = 90;
    fs.year = Integer.parseInt(d.getString("year"));

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
      fs.addtech(new Technique(t.getString(0), t.getString(1), t.getString(2)));
    }
  }
}

void setup() {
  size(1150, 450);
  frameRate(15);
  bold = createFont("CALIBRIB.TTF", 16);
  norm = createFont("Calibri.ttf", 16);
  textFont(norm);

  TTYPES = new HashMap<String, Integer>();
  TTYPES.put("Lock Management", color(237, 0, 255)); //pink
  TTYPES.put("Relaxing Consistency", color(33, 10, 250));  // blue
  TTYPES.put("Caching Inodes", color(33, 10, 250));  // blue
  TTYPES.put("Journal Formats", color(33, 10, 250));  // blue
  TTYPES.put("Journal Safety", color(33, 10, 250));  // blue
  TTYPES.put("Caching Paths", color(33, 10, 250));  // blue
  TTYPES.put("Metadata Distribution", color(33, 10, 250));  // blue
  TTYPES.put("Load Balancing", color(33, 10, 250));  // blue
  
  parse("input.json");  
}

void draw() {
  background(color(200));
  for (FS fs : fss)
    fs.draw();
  drawTimeline();
  drawLegend();
}
