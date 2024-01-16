import processing.pdf.*;
import java.awt.geom.*;

class Figure {

  Point[] points = new Point[numPoints];
  float fitness = 0; // Fitness value

  Figure() {
  }

  // Initialise the individual with the given points
  Figure(Point[] initialPoints) {
    for (int i = 0; i < points.length; i++) {
      points[i] = initialPoints[i].getCopy();
    }
  }

  void randomize() {
    do {
      for (int i = 0; i < points.length; i++) {
        // Avoid using the first and last coordinate to create a margin around the design
        points[i] = new Point(int(random(1, numPositions - 1)), int(random(1, numPositions - 1)));
      }
    } while (!isValid());
  }

  // One-point crossover operator
  Figure onePointCrossover(Figure partner) {
    while (true) {
      Figure child = new Figure();
      int crossoverPoint = int(random(1, points.length - 1));
      for (int i = 0; i < points.length; i++) {
        if (i < crossoverPoint) {
          child.points[i] = points[i].getCopy();
        } else {
          child.points[i] = partner.points[i].getCopy();
        }
      }
      if (child.isValid()) {
        return child;
      }
    }
  }

  // Uniform crossover operator
  Figure uniformCrossover(Figure partner) {
    while (true) {
      Figure child = new Figure();
      for (int i = 0; i < points.length; i++) {
        if (random(1) < 0.5) {
          child.points[i] = points[i].getCopy();
        } else {
          child.points[i] = partner.points[i].getCopy();
        }
      }
      if (child.isValid()) {
        return child;
      }
    }
  }

  // Mutation operator
  void mutate() {
    boolean shouldMutate = false;
    while (true) {
      boolean mutationPerformed = false;
      Figure mutatedVersion = getCopy();
      for (int i = 0; i < points.length; i++) {
        if (random(1) <= mutationRate) {
          shouldMutate = true;

          // Replace gene with a random one
          mutatedVersion.points[i] = new Point(int(random(1, numPositions - 1)), int(random(1, numPositions - 1)));

          // Adjust the value of the gene
          /*if (random(1) < 0.5) {
            mutatedVersion.points[i].x = constrain(mutatedVersion.points[i].x + (random(1) < 0.5 ? -1 : 1), 1, numPositions - 1);
          } else {
            mutatedVersion.points[i].y = constrain(mutatedVersion.points[i].y + (random(1) < 0.5 ? -1 : 1), 1, numPositions - 1);
          }*/
          mutationPerformed = true;
        }
      }
      if (mutatedVersion.isValid() && shouldMutate && mutationPerformed) {
        for (int i = 0; i < points.length; i++) {
          points[i] = mutatedVersion.points[i].getCopy();
        }
        break;
      }
    }
  }

  // Set the fitness value
  void setFitness(float fitness) {
    this.fitness = fitness;
  }

  // Get the fitness value
  float getFitness() {
    return fitness;
  }

  // Get a clean copy
  Figure getCopy() {
    Figure copy = new Figure(points);
    copy.fitness = fitness;
    return copy;
  }

  boolean isValid() {
    for (int i1 = 0; i1 < points.length; i1++) {
      for (int i2 = 0; i2 < points.length; i2++) {
        if (linesIntersect(points[i1], points[(i1 + 1) % points.length], points[i2], points[(i2 + 1) % points.length])) {
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

  // Draw the figure encoded by this individual
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
    for (int i = 0; i < points.length; i++) {
      canvas.vertex(points[i].x * scaling, points[i].y * scaling);
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

    String[] output_text_lines = new String[points.length];
    for (int i = 0; i < points.length; i++) {
      output_text_lines[i] = points[i].x + "," + points[i].y;
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
