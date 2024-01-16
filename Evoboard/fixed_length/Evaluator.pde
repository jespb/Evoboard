import java.nio.file.*;

// This class enables the evaluation of individuals (harmonographs).
class Evaluator {
  
  // ----- RMSE
  PImage target_image; // Image of the target image
  int[] target_pixels_brightness; // Array with the brigness values of the target images
  
  // ----- communication with python
  // These files are used to communicate with the Python script that evaluates the evolved images
  File fileImagesList;
  File fileImagesFitness;
  
  Evaluator(int resolution) {

    
    fileImagesList = new File(sketchPath("images_list.txt"));
    fileImagesFitness = new File(sketchPath("images_fitness.txt"));
    if (fileImagesList.exists()) {
      fileImagesList.delete();
    }
    if (fileImagesFitness.exists()) {
      fileImagesFitness.delete();
    }
  }
  
  // Calculate the fitness of a given individual (this is the fitness function)
  float[] calculateFitness(Figure[] indivs) {

    PImage[] images = new PImage[indivs.length];
    for (int i = 0; i < indivs.length; i++) {
      images[i] = indivs[i].getPhenotype(resolution);
    }
    
    // ================ RMSE
    
    // float[] similarity_scores = new float[indivs.length];
    // for (int i = 0; i < indivs.length; i++) {
    //   int[] phenotype_pixels_brightness = getPixelsBrightness(images[i]);
    //   similarity_scores[i] = getSimilarityRMSE(target_pixels_brightness, phenotype_pixels_brightness, 255);
    // }
    // return similarity_scores;
    
    // ================ PYTHON
    
    Path pathOutputDir = Paths.get(dataPath("images_to_evaluate_" + System.nanoTime()));
    String[] outputImagesPaths = new String[images.length];
    for (int i = 0; i < images.length; i++) {
      Path pathOutputImage = pathOutputDir.resolve(i + ".png");
      outputImagesPaths[i] = pathOutputImage.toString();
      images[i].save(outputImagesPaths[i]);
    }
    saveStrings(fileImagesList.getPath(), outputImagesPaths);

    // Wait until the Python script writes the fitness values to file
    long curr_millis = System.currentTimeMillis();
    boolean print_msg = true;
    while (!fileImagesFitness.exists()) {
      if (print_msg) {
        println("Waiting for fitness");
        print_msg = false;
      }
      delay(100);
    }
    delay(100);
    float secs_waiting = (System.currentTimeMillis() - curr_millis) / 1000f;

    // Load fitness values from the file
    String[] lines = loadStrings(fileImagesFitness.getPath());
    assert lines.length == images.length;
    float[] fitness = new float[images.length];
    for (int i = 0; i < lines.length; i++) {
      fitness[i] = Float.parseFloat(lines[i]);
    }
    fileImagesFitness.delete();
    delay(100);

    // Delete the files saved to disk since they are no longer needed
    String[] files_to_delete = pathOutputDir.toFile().list();
    for (String filename : files_to_delete) {
      File f = new File(pathOutputDir.toString(), filename);
      f.delete();
    }
    pathOutputDir.toFile().delete();

    println("Fitness values loaded (waited " + secs_waiting + " secs)");

    // Return the fitness values
    return fitness;
  }
  
  // Calculate the brighness values of a given image
  int[] getPixelsBrightness(PImage image) {
    int[] pixels_brightness = new int[image.pixels.length];
    for (int i = 0; i < image.pixels.length; i++) {
      pixels_brightness[i] = image.pixels[i] & 0xFF; // Use the blue channel to estimate brighness (very fast to calculate)
    }
    return pixels_brightness;
  }
  
  // Calculate the normalised similarity between two samples (pixels brighenss values)
  float getSimilarityRMSE(int[] sample1, int[] sample2, double max_rmse) {
    float rmse = 0;
    float diff;
    for (int i = 0; i < sample1.length; i++) {
      diff = sample1[i] - sample2[i];
      rmse += diff * diff;
    }
    rmse = sqrt(rmse / sample1.length);
    rmse /= max_rmse; // Normalise rmse
    return 1 - rmse; // Invert the result since we want the similarity and not the difference
  }
}
