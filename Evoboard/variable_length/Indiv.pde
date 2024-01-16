import processing.pdf.*;
import java.awt.geom.*;

class Individual {

  List<Point> points = new ArrayList<Point>();
  float fitness = 0;

  Individual() {
  }

  Individual(List<Point> initialPoints) {
    for (int i = 0; i < initialPoints.size(); i++) {
      points.add(initialPoints.get(i).getCopy());
    }
  }

  void randomize() {
    //int numPoints = numPointsMin; 
    int numPoints = int(random(numPointsMin, numPointsMax));
    do {
      points.clear();
      for (int i = 0; i < numPoints; i++) {
        points.add(getNewPoint());
      }
    } while (!isValid());
  }
  
  Individual crossover(Individual partner) {
    // Based on a typical one-point crossover
    while (true) {
      int part1Begin = int(random(0, points.size()));
      int part1Length = int(random(0, points.size()));
      int part2Begin = int(random(0, partner.points.size()));
      int part2Length = int(random(0, partner.points.size()));
      
      Individual child = new Individual();
      for (int i = part1Begin; i < part1Begin + part1Length; i++) {
        int constrainedIndex = i % points.size();
        child.points.add(points.get(constrainedIndex).getCopy());
      }
      for (int i = part2Begin; i < part2Begin + part2Length; i++) {
        int constrainedIndex = i % partner.points.size();
        child.points.add(partner.points.get(constrainedIndex).getCopy());
      }
      
      if (child.isValid()) {
        return child;
      }
    }
  }

  void mutate() {
    Individual indivMutated = getCopy();
    boolean mutationPerformed = false;

    // remove
    if (random(1) < mutationRateRemove && indivMutated.points.size() > numPointsMin) {
      indivMutated.points.remove(int(random(0, indivMutated.points.size())));
      mutationPerformed = true;
    }

    // modify
    for (int i = 0; i < indivMutated.points.size(); i++) {
      if (random(1) < mutationRateModify) {
        if (random(1) < 0.5) {
          indivMutated.points.get(i).x = constrain(indivMutated.points.get(i).x + (random(1) < 0.5 ? -1 : 1), 1, numPositions - 1);
        } else {
          indivMutated.points.get(i).y = constrain(indivMutated.points.get(i).y + (random(1) < 0.5 ? -1 : 1), 1, numPositions - 1);
        }
        mutationPerformed = true;
      }
    }

    // add
    if (random(1) < mutationRateAdd && indivMutated.points.size() < numPointsMax) {
      int addPosition = int(random(0, indivMutated.points.size() + 1));
      indivMutated.points.add(addPosition, getNewPoint());
      mutationPerformed = true;
    }

    if (mutationPerformed && indivMutated.isValid()) {
      points.clear();
      for (int i = 0; i < indivMutated.points.size(); i++) {
        points.add(indivMutated.points.get(i).getCopy());
      }
    }
  }

  private Point getNewPoint() {
    // Avoid using the first and last coordinate to create a margin around the design
    int posX = int(random(1, numPositions - 1));
    int posY = int(random(1, numPositions - 1));
    return new Point(posX, posY);
  }

  void setFitness(float fitness) {
    this.fitness = fitness;
  }

  float getFitness() {
    return fitness;
  }

  Individual getCopy() {
    Individual copy = new Individual(points);
    copy.fitness = fitness;
    return copy;
  }

  boolean isValid() {
    if (points.size() < numPointsMin || points.size() > numPointsMax) {
      return false;
    }
    for (int i1 = 0; i1 < points.size(); i1++) {
      for (int i2 = 0; i2 < points.size(); i2++) {
        if (i1 != i2) {
          if (points.get(i1).x == points.get(i2).x && points.get(i1).y == points.get(i2).y) {
            return false;
          }
        }
      }
    }
    for (int i1 = 0; i1 < points.size(); i1++) {
      for (int i2 = 0; i2 < points.size(); i2++) {
        if (linesIntersect(points.get(i1), points.get((i1 + 1) % points.size()), points.get(i2), points.get((i2 + 1) % points.size()))) {
          return false;
        }
      }
    }
    return true;
  }

  // Get phenotype of this individual
  PImage getPhenotype(int resolution) {
    if (phenotypeCanvas == null || phenotypeCanvas.width != resolution) {
      phenotypeCanvas = createGraphics(resolution, resolution);
      phenotypeCanvas.smooth(8);
    }
    phenotypeCanvas.beginDraw();
    phenotypeCanvas.background(255);
    render(phenotypeCanvas, 0, 0, resolution, color(0));
    phenotypeCanvas.endDraw();
    return phenotypeCanvas.copy();
  }
  
  void render(PGraphics canvas, float x, float y, float size, color c) {
    float scaling = size / (float) (numPositions - 1);
    canvas.pushMatrix();
    canvas.translate(x, y);
    canvas.fill(c);
    canvas.stroke(c);
    canvas.strokeWeight(size * 0.05);
    canvas.strokeCap(ROUND);
    canvas.strokeJoin(ROUND);
    canvas.beginShape();
    for (Point p : points) {
      canvas.vertex(p.x * scaling, p.y * scaling);
    }
    canvas.endShape(CLOSE);
    canvas.popMatrix();
  }
  
  void renderOutline(PGraphics canvas, float x, float y, float size) {
    float scaling = size / (float) (numPositions - 1);
    canvas.pushMatrix();
    canvas.translate(x, y);
    canvas.strokeCap(ROUND);
    canvas.strokeJoin(ROUND);
    canvas.beginShape();
    for (Point p : points) {
      canvas.vertex(p.x * scaling, p.y * scaling);
    }
    canvas.endShape(CLOSE);
    canvas.popMatrix();
  }

  // Export image (png), vector (pdf) and parameters (txt) of this harmonograph
  void export() {
    String output_filename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" +
      nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
    String output_path = sketchPath("outputs/" + output_filename);
    println("Exporting harmonograph to: " + output_path);

    getPhenotype(2000).save(output_path + ".png");

    PGraphics pdf = createGraphics(500, 500, PDF, output_path + ".pdf");
    pdf.beginDraw();
    render(pdf, 0, 0, pdf.width, color(0));
    pdf.dispose();
    pdf.endDraw();

    String[] output_text_lines = new String[points.size()];
    for (int i = 0; i < points.size(); i++) {
      output_text_lines[i] = points.get(i).x + "," + points.get(i).y;
    }
    saveStrings(output_path + ".txt", output_text_lines);
  }
}

class Point {

  float x, y;

  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }

  boolean equalsTo(Point other) {
    return x == other.x && y == other.y;
  }

  Point getCopy() {
    return new Point(x, y);
  }
}

boolean linesIntersect(Point p1, Point p2, Point p3, Point p4) {
  if (p1.equalsTo(p3) || p1.equalsTo(p4) || p2.equalsTo(p3) || p2.equalsTo(p4)) {
    return false;
  }
  return Line2D.linesIntersect(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
}

void drawGrid(PGraphics pg, float x, float y, float w, float h, int cols, int rows, color c) {
  float colWidth = w / (float) cols;
  float rowHeight = h / (float) rows;
  float bitola = min(colWidth, colWidth);

  pg.pushStyle();
  pg.pushMatrix();
  pg.translate(x, y);

  // Draw grid limits
  pg.stroke(c);
  pg.strokeWeight(bitola * 0.05);
  pg.noFill();
  pg.rect(0, 0, w, h);

  // Draw grid cells
  pg.noStroke();
  pg.fill(c);
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      if ((row + col % 2) % 2 == 0) {
        pg.rect(col * colWidth, row * rowHeight, colWidth, rowHeight);
      }
    }
  }

  // Draw indexes of the coordinates
  pg.fill(c);
  pg.textSize(bitola * 0.33);
  pg.textAlign(CENTER, BOTTOM);
  for (int col = 0; col < cols + 1; col++) {
    pg.text(col, col * colWidth, -pg.textSize * 0.66);
  }
  pg.textAlign(RIGHT, CENTER);
  for (int row = 0; row < rows + 1; row++) {
    pg.text(row, -pg.textSize * 0.66, row * rowHeight);
  }

  pg.popMatrix();
  pg.popStyle();
}
