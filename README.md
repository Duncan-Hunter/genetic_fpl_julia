# genetic_fpl_julia
![graph](https://raw.githubusercontent.com/Duncan-Hunter/genetic_fpl_julia/main/banner.png?token=AIN2UDQF7VCAZJXJFI56IU27TMJH6)

Using genetic algorithms to optimise fantasy football, using Julia and the fantasy football API.

At the moment, it's quite prone to getting stuck in local maximums as opposed to the global, take the results with a pinch of salt.

#### Usage

Update the fantasy football data by running 
```bash
python get_data.py
```

This is used to get up to date EP_next (Expected Points). Custom modelling can be done with some extension.

Then open genetic_algo.ipynb using IJulia.

#### For optimising your team:
 - Edit the cell with chosen_team defined to edit to your team.
 - IDs for players can be found in player_idlist.csv
 - Use n_changes arg to set the number of allowed changes. Set to 15 to set up a new team, or use the from scatch method.