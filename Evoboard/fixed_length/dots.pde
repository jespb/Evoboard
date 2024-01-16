int populationSize = 100;
int eliteSize = 1;
int tournamentSize = 2;
float crossoverRate = 0.7;
float mutationRate = 0.05;
int resolution = 128;
int max_generations = 100;
FloatList fitnessByGeneration = new FloatList();

int numPoints = 11;
int numPositions = 21;

Population pop;
PVector[][] cells;
boolean phenotypeMode = true;
boolean showFitness = true;

PGraphics phenotypeCanvas = null;

void settings() {
  size(int(displayWidth * 0.9), int(displayHeight * 0.8), JAVA2D);
  smooth(8);
}

void setup() {
  pop = new Population();
  cells = calculateGrid(populationSize, 0, 0, width, height, 30, 10, 30, true);
  textSize(constrain(cells[0][0].z * 0.15, 11, 14));
  textAlign(CENTER, TOP);
}

void draw() {
  pop.evolve();

  println("Current generation: " + pop.getGenerations());
  background(phenotypeMode ? 235 : 0);
  float cellDim = cells[0][0].z;
  int row = 0, col = 0;
  for (int i = 0; i < pop.getSize(); i++) {
    noFill();
    if (phenotypeMode) {
      image(pop.getIndiv(i).getPhenotype(resolution), cells[row][col].x, cells[row][col].y, cellDim, cellDim);
    } else {
      strokeWeight(max(cellDim * 0.01, 1));
      stroke(255, 50);
      //pop.getIndiv(i).render(getGraphics(), cells[row][col].x + cellDim / 2, cells[row][col].y + cellDim / 2, cellDim, cellDim);
    }
    if (showFitness) {
      fill(phenotypeMode ? 80 : 200);
      text(nf(pop.getIndiv(i).getFitness(), 0, 4), cells[row][col].x + cellDim / 2, cells[row][col].y + cellDim + 2);
    }
    col += 1;
    if (col >= cells[row].length) {
      row += 1;
      col = 0;
    }
  }

  pop.sortIndividualsByFitness();

  fitnessByGeneration.append(pop.getIndiv(0).getFitness());

  if (pop.getGenerations() == max_generations) {
    println("GENERATION | FITNESS ");

    int gen = 1;

    for (Float ftns : fitnessByGeneration) {
      println(gen + " | " + ftns);
      gen++;
    }

    exit();
  }
}


void keyReleased() {
  if (key == 'e') {
    pop.getIndiv(0).export();
  } else if (key == ' ') {
    phenotypeMode = !phenotypeMode;
  } else if (key == 'f') {
    showFitness = !showFitness;
  }
}

// Calculate grid of square cells
PVector[][] calculateGrid(int cells, float x, float y, float w, float h, float margin_min, float gutter_h, float gutter_v, boolean align_top) {
  int cols = 0, rows = 0;
  float cell_size = 0;
  while (cols * rows < cells) {
    cols += 1;
    cell_size = ((w - margin_min * 2) - (cols - 1) * gutter_h) / cols;
    rows = floor((h - margin_min * 2) / (cell_size + gutter_v));
  }
  if (cols * (rows - 1) >= cells) {
    rows -= 1;
  }
  float margin_hor_adjusted = ((w - cols * cell_size) - (cols - 1) * gutter_h) / 2;
  if (rows == 1 && cols > cells) {
    margin_hor_adjusted = ((w - cells * cell_size) - (cells - 1) * gutter_h) / 2;
  }
  float margin_ver_adjusted = ((h - rows * cell_size) - (rows - 1) * gutter_v) / 2;
  if (align_top) {
    margin_ver_adjusted = min(margin_hor_adjusted, margin_ver_adjusted);
  }
  PVector[][] positions = new PVector[rows][cols];
  for (int row = 0; row < rows; row++) {
    float row_y = y + margin_ver_adjusted + row * (cell_size + gutter_v);
    for (int col = 0; col < cols; col++) {
      float col_x = x + margin_hor_adjusted + col * (cell_size + gutter_h);
      positions[row][col] = new PVector(col_x, row_y, cell_size);
    }
  }
  return positions;
}
