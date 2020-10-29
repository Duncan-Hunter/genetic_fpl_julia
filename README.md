# genetic_fpl_julia
![graph](https://raw.githubusercontent.com/Duncan-Hunter/genetic_fpl_julia/main/banner.png?token=AIN2UDQF7VCAZJXJFI56IU27TMJH6)

Using genetic algorithms to optimise Fantasy Premier League (FPL), using Julia and the FPL API.

Squads can be represented as a vector of 15 IDs, with each having an expected points (EP) for the next gameweek provied by the FPL API. The genetic algorithm finds initial solutions that fit the rules of the game, then breeds, mutates and explores substitutions in squads to find the maximum EP available.

The rules of the game:
 - 15 unique players, of which:
    - 2 Goalkeepers
    - 5 Defenders
    - 5 Midfielders
    - 3 Attackers
- Formations which vary between:
    - 1 Goalkeeper
    - 3-5 Defenders
    - 2-5 Midfielders
    - 1-3 Attackers
- No more than 3 players from one team
- Price must be less than £100.

During the algorithm, a pool of solutions ("a generation") is generated. This is done through:
 - Breeding: Select 2 or more teams, and swap the players in them. Teams with better fitness are more likely to be selected.
 - Mutation: Randomly swap players with any other player.
 - Substitutions: As substitutions are free in fantasy football, explore if any subsitutes are better than those currently in the 1st 11.

If during these procedures a new solution is invalid, it is discarded, and a new one created in its place, until we have the desired number of solutions in the generation.

Fitness is defined as the sum of the EP of the 1st 11, + 1/2 the sum of the EP of the subs.

At the moment, it's quite prone to getting stuck in local maximums as opposed to the global, take the results with a pinch of salt.

#### Usage

Update the fantasy football data by running 
```bash
python get_data.py
```

This is used to get up to date EP_next (Expected Points). Custom modelling can be done with some extension.

Then open genetic_algo.ipynb using IJulia, and run cells as desired.

#### For optimising your team:
 - Edit the cell with chosen_team defined to edit to your team.
 - IDs for players can be found in player_idlist.csv
 - Use n_changes arg to set the number of allowed changes. Set to 15 to set up a new team, or use the from scatch method.
 - Other hyperparameters that can be changed include:
    - Size of the solution pool
    - Maximum number of generations
    - Number of epochs after finding a maximum to stop ("early stopping")