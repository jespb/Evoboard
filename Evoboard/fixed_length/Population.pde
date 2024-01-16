import java.util.*; // Needed to sort arrays

// This class stores and manages a population of individuals
class Population {
  
  Figure[] individuals; // Array to store the individuals in the population
  Evaluator evaluator; // Object to calculate fitness of individuals
  int generations; // Integer to keep count of how many generations have been created
  
  Population() {
    individuals = new Figure[populationSize];
    evaluator = new Evaluator(resolution);
    initialize();
  }
  
  // Create the initial individuals
  void initialize() {
    // Fill population with random individuals
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new Figure();
      individuals[i].randomize();
    }
    
    // Evaluate individuals
    float[] fitnessValues = evaluator.calculateFitness(individuals);
    for (int i = 0; i < individuals.length; i++) {
      individuals[i].setFitness(fitnessValues[i]);
    }
    
    // Sort individuals in the population by fitness (fittest first)
    sortIndividualsByFitness();
    
    // Reset generations counter
    generations = 0;
  }
  
  // Create the next generation
  void evolve() {
    // Create a new a ,array to store the individuals that will be in the next generation
    Figure[] new_generation = new Figure[individuals.length];
    
    // Copy the elite to the next generation (we assume that the individuals are already sorted by fitness)
    for (int i = 0; i < eliteSize; i++) {
      new_generation[i] = individuals[i].getCopy();
    }
    
    // Create (breed) new individuals with crossover
    for (int i = eliteSize; i < new_generation.length; i++) {
      if (random(1) <= crossoverRate) {
        Figure parent1 = tournamentSelection();
        Figure parent2 = tournamentSelection();
        //Figure child = parent1.onePointCrossover(parent2);
        Figure child = parent1.uniformCrossover(parent2);
        new_generation[i] = child;
      } else {
        new_generation[i] = tournamentSelection().getCopy();
      }
    }
    
    // Mutate new individuals
    for (int i = eliteSize; i < new_generation.length; i++) {
      new_generation[i].mutate();
    }
    
    // Evaluate new individuals
    float[] fitnessValues = evaluator.calculateFitness(new_generation);
    for (int i = 0; i < new_generation.length; i++) {
      new_generation[i].setFitness(fitnessValues[i]);
    }
    
    // Replace the individuals in the population with the new generation individuals
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new_generation[i];
    }
    
    // Sort individuals in the population by fitness
    sortIndividualsByFitness();
    
    // Increment the number of generations
    generations++;
  }
  
  // Select one individual using a tournament selection 
  Figure tournamentSelection() {
    // Select a random set of individuals from the population
    Figure[] tournament = new Figure[tournamentSize];
    for (int i = 0; i < tournament.length; i++) {
      int randomIndex = int(random(0, individuals.length));
      tournament[i] = individuals[randomIndex];
    }
    // Get the fittest individual from the selected individuals
    Figure fittest = tournament[0];
    for (int i = 1; i < tournament.length; i++) {
      if (tournament[i].getFitness() > fittest.getFitness()) {
        fittest = tournament[i];
      }
    }
    return fittest;
  }
  
  // Sort individuals in the population by fitness in descending order (fittest first)
  void sortIndividualsByFitness() {
    Arrays.sort(individuals, new Comparator<Figure>() {
      public int compare(Figure indiv1, Figure indiv2) {
        return Float.compare(indiv2.getFitness(), indiv1.getFitness());
      }
    });
  }
  
  // Get an individual from the popultioon located at the given index
  Figure getIndiv(int index) {
    return individuals[index];
  }
  
  // Get the number of individuals in the population
  int getSize() {
    return individuals.length;
  }
  
  // Get the number of generations that have been created so far
  int getGenerations() {
    return generations;
  }
}
