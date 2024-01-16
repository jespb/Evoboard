import java.util.*;

class Population {
  
  Individual[] individuals;
  Evaluator evaluator;
  int generations;
  
  Population() {
    individuals = new Individual[populationSize];
    evaluator = new Evaluator(resolution);
    initialize();
  }
  
  void initialize() {
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new Individual();
      individuals[i].randomize();
    }
    
    float[] fitnessValues = evaluator.calculateFitness(individuals);
    for (int i = 0; i < individuals.length; i++) {
      individuals[i].setFitness(fitnessValues[i]);
    }
    
    sortIndividualsByFitness();
    
    generations = 0;
  }
  
  void evolve() {
    Individual[] new_generation = new Individual[individuals.length];
    
    for (int i = 0; i < eliteSize; i++) {
      new_generation[i] = individuals[i].getCopy();
    }
    
    for (int i = eliteSize; i < new_generation.length; i++) {
      if (random(1) <= crossoverRate) {
        Individual parent1 = tournamentSelection();
        Individual parent2 = tournamentSelection();
        Individual child = parent1.crossover(parent2);
        new_generation[i] = child;
      } else {
        new_generation[i] = tournamentSelection().getCopy();
      }
    }
    
    for (int i = eliteSize; i < new_generation.length; i++) {
      new_generation[i].mutate();
    }
    
    float[] fitnessValues = evaluator.calculateFitness(new_generation);
    for (int i = 0; i < new_generation.length; i++) {
      new_generation[i].setFitness(fitnessValues[i]);
    }
    
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new_generation[i];
    }
    
    sortIndividualsByFitness();
    
    generations++;
  }
  
  Individual tournamentSelection() {
    Individual[] tournament = new Individual[tournamentSize];
    for (int i = 0; i < tournament.length; i++) {
      int randomIndex = int(random(0, individuals.length));
      tournament[i] = individuals[randomIndex];
    }
    Individual fittest = tournament[0];
    for (int i = 1; i < tournament.length; i++) {
      if (tournament[i].getFitness() > fittest.getFitness()) {
        fittest = tournament[i];
      }
    }
    return fittest;
  }
  
  void sortIndividualsByFitness() {
    Arrays.sort(individuals, new Comparator<Individual>() {
      public int compare(Individual indiv1, Individual indiv2) {
        return Float.compare(indiv2.getFitness(), indiv1.getFitness());
      }
    });
  }
  
  Individual getIndiv(int index) {
    return individuals[index];
  }
  
  int getSize() {
    return individuals.length;
  }
  
  int getGenerations() {
    return generations;
  }
}
