clear;
close all;

% AI Coursework Part 2
% Genetic algorithm for improving the behaviour of a simulated ant.

% Hyperparameters
CrossoverProbability = 0.8;
MutationProbability = 0.2;
PopulationSize = 10;
Generations = 500;
Digits = 30;

% Generate random population of ant chromosomes:
% Using value encoding
Population = zeros(PopulationSize, Digits);
for i = 1:PopulationSize
	TempChromosome = zeros(1, Digits);
	% Setting digits for a state at a time
	for j = 1:10
		Digit = randi(4, 1);
		TempChromosome((j-1)*3 + 1) = Digit;
		Digit = randi([0,9], [1,2]);
		TempChromosome(((j-1)*3 + 2):((j-1)*3 + 3)) = Digit;
	end
	Population(i, :) = TempChromosome;
end

% Add an extra column for fitness
Population = [Population zeros(PopulationSize, 1)];
BestFitnessHistory = zeros(Generations, 1);

% Prepare this array to be used in rank selection
RankSelection = zeros(sum(1:PopulationSize), 1);
Temp = 0;
for i = 1:PopulationSize
    for j = 1:i
        Temp = Temp + 1;
        RankSelection(Temp) = i;
    end
end

% Repeat through all the generations
for i = 1:Generations
	% Evaluate fitness scores and rank them
	for j = 1:PopulationSize
		Controller = '';
		for k = 1:Digits
			Controller = [Controller int2str(Population(j, k))];
		end
		[Fitness, Trail] = simulate_ant('muir_world.txt', Controller);
		Population(j, end) = Fitness;
	end
	Population = sortrows(Population, Digits+1);
	
	% Record best fitness and plot fitness history
	BestFitnessHistory(i) = Population(PopulationSize, end);
	display(sprintf('Generation: %d  |  Best Fitness: %f',i, BestFitnessHistory(i)));
	plot(BestFitnessHistory(1:i));
	xlabel('Generation');
	ylabel('Best Fitness');
	pause(0.01);
	
	% Elite selection, keep the best 2
	PopulationNew = zeros(PopulationSize, Digits);
	PopulationNew(1:2,:) = Population(PopulationSize-1:PopulationSize,1:Digits);
	PopulationNewNum = 2;
	
	% Repeat until the new population is filled up
	while (PopulationNewNum < PopulationSize)
		% Use rank selection to choose 2 chromosomes
		Selection = RankSelection(randi(sum(1:PopulationSize), 1));
		TempChromosome_1 = Population(Selection, 1:Digits);
		Selection = RankSelection(randi(sum(1:PopulationSize), 1));
		TempChromosome_2 = Population(Selection, 1:Digits);
		
		% Perform multi-point crossover of 'TempChromosome_1' and
		% 'TempChromosome_2' with a probability of 'CrossoverProbability'
		if (rand < CrossoverProbability)
			CrossPoint_1 = randi(Digits-2, 1);
			CrossPoint_2 = randi([CrossPoint_1+1,Digits-1], 1);
			CrossChromosome_1 = [TempChromosome_1(1:CrossPoint_1) TempChromosome_2(CrossPoint_1+1:CrossPoint_2) TempChromosome_1(CrossPoint_2+1:end)];
			CrossChromosome_2 = [TempChromosome_2(1:CrossPoint_1) TempChromosome_1(CrossPoint_1+1:CrossPoint_2) TempChromosome_2(CrossPoint_2+1:end)];
			TempChromosome_1 = CrossChromosome_1;
			TempChromosome_2 = CrossChromosome_2;
		end
		
		% Perform mutation, with a probability of 'MutationProbability', by
		% adding 1 to the digit's value
		% i.e. 2->3, 5->6 (with looparound, 9->0 or 4->1)
		if (rand < MutationProbability)
			MutPoint = randi(Digits, 1);
			TempChromosome_1(MutPoint) = TempChromosome_1(MutPoint) + 1;
			if (mod(MutPoint,3) == 1)
				if (TempChromosome_1(MutPoint) > 4) TempChromosome_1(MutPoint) = 1; end
			else
				if (TempChromosome_1(MutPoint) > 9) TempChromosome_1(MutPoint) = 0; end
			end
		end
		if (rand < MutationProbability)
			MutPoint = randi(Digits, 1);
			TempChromosome_2(MutPoint) = TempChromosome_2(MutPoint) + 1;
			if (mod(MutPoint,3) == 1)
				if (TempChromosome_2(MutPoint) > 4) TempChromosome_2(MutPoint) = 1; end
			else
				if (TempChromosome_2(MutPoint) > 9) TempChromosome_2(MutPoint) = 0; end
			end
		end
		
		% Add to the new population as long as there is space left
		PopulationNewNum = PopulationNewNum + 1;
		PopulationNew(PopulationNewNum, :) = TempChromosome_1;
		if (PopulationNewNum < PopulationSize)
			PopulationNewNum = PopulationNewNum + 1;
			PopulationNew(PopulationNewNum, :) = TempChromosome_2;
		end
	end
	
	% Replace old population with new population, fitness not updated
	Population(:, 1:Digits) = PopulationNew;
end

% Evaluate final fitness scores and rank them
for j = 1:PopulationSize
	Controller = '';
	for k = 1:Digits
		Controller = [Controller int2str(Population(j, k))];
	end
	[Fitness, Trail] = simulate_ant('muir_world.txt', Controller);
	Population(j, end) = Fitness;
end
Population = sortrows(Population, Digits+1);

% Display the best fitness score
display(sprintf('Best Fitness: %f', Population(PopulationSize, end)));
