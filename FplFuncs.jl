module FplFuncs

using DataFrames
using StatsBase
using Statistics


function fpl_get_dicts(df_players::DataFrame)
    id_to_player = Dict()
    for (k, v) in zip(df_players.id, df_players.second_name)
        id_to_player[k] = v
    end
    id_to_cost = Dict()
    for (k, v) in zip(df_players.id, df_players.now_cost)
        id_to_cost[k] = v
    end
    id_to_element_type = Dict()
    for (k, v) in zip(df_players.id, df_players.element_type)
        id_to_element_type[k] = v
    end
    id_to_team = Dict()
    for (k, v) in zip(df_players.id, df_players.team)
        id_to_team[k] = v
    end
    id_to_fitness = Dict()
    for (k, v) in zip(df_players.id, df_players.fitness)
        id_to_fitness[k] = v
    end
    return id_to_player, id_to_cost, id_to_element_type, id_to_team, id_to_fitness
end


function fpl_generate_formation()
    """Generates a random formation"""
    n_keepers = 1
    n_defenders = rand(3:5)
    n_midfielders = rand(2:5)
    n_attackers = rand(1:3)
    while sum((n_keepers, n_defenders, n_midfielders, n_attackers)) != 11
        n_defenders = rand(3:5)
        n_midfielders = rand(2:5)
        n_attackers = rand(1:3)
    end
    return n_keepers, n_defenders, n_midfielders, n_attackers
end


function fpl_generate_squad_initial(df_players::DataFrame)
    """Generates a random squad"""
    goalkeepers = df_players[df_players.element_type .== 1, :]
    defenders = df_players[df_players.element_type .== 2, :]
    midfielders = df_players[df_players.element_type .== 3, :]
    attackers = df_players[df_players.element_type .== 4, :]

    gk_ids = sample(goalkeepers.id, 2, replace=false)
    defender_ids = sample(defenders.id, 5, replace=false)
    midfielder_ids = sample(midfielders.id, 5, replace=false)
    attacker_ids = sample(attackers.id, 3, replace=false)
    vec = vcat(gk_ids, defender_ids, midfielder_ids, attacker_ids)
    return vec
end


function fpl_generate_team_from_squad(squad_vector,
    id_to_element_type::Dict{Any,Any})
    """Sorts a team into the first 11 parts"""
    gk, d, m, a = fpl_generate_formation()
    team_gks = sample(squad_vector[1:2], 1)
    team_defs = sample(squad_vector[3:7], d, replace=false)
    team_mids = sample(squad_vector[8:12], m, replace=false)
    team_atts = sample(squad_vector[13:15], a, replace=false)

    team_vec = vcat(team_gks, team_defs, team_mids, team_atts)
    sub_vec = zeros(4)
    sub_counter = 1
    for id in squad_vector
        position = id_to_element_type[id]
        if position == 1
            if !(id in team_gks)
                sub_vec[sub_counter] = id
                sub_counter += 1
            end
        elseif position == 2
            if !(id in team_defs)
                sub_vec[sub_counter] = id
                sub_counter += 1
            end
        elseif position == 3
            if !(id in team_mids)
                sub_vec[sub_counter] = id
                sub_counter += 1
            end
        else
            if !(id in team_atts)
                sub_vec[sub_counter] = id
                sub_counter += 1
            end
        end
    end
    vec = vcat(team_vec, sub_vec)
    vec = floor.(Int64, vec)
    return vec
end


function fpl_print_squad_names(squad_vector, id_to_player::Dict{Any, Any})
    for i in squad_vector
        println(i, " ", id_to_player[i])
    end
end


function fpl_squad_cost(squad_vector, id_to_cost::Dict{Any, Any})
    sum = 0
    for id in squad_vector
        sum += id_to_cost[id]
    end
    return sum
end


function fpl_team_fitness(squad_vector, id_to_fitness::Dict{Any, Any})
    fit = 0
    for id in squad_vector[1:11]
        fit += id_to_fitness[id]
    end
    fit_subs = 0
    for id in squad_vector[12:15]
        fit_subs += id_to_fitness[id] / 2
    end
    return fit + 0.5 * fit_subs
end


function fpl_most_from_one_squad(squad_vector, id_to_team::Dict{Any, Any})
    teams = zero(squad_vector)
    for (i, id) in enumerate(squad_vector)
        teams[i] = id_to_team[id]
    end
    uq_teams = unique(teams)
    max = 0
    for team in uq_teams
        bool = teams .== team
        count = sum(bool)
        if count > max
            max = count
        end
    end
    return max
end


function fpl_validate_player_types(squad_vector, id_to_element_type::Dict{Any, Any})
    types = zeros(size(squad_vector, 1))
    for (i, id) in enumerate(squad_vector)
        types[i] = id_to_element_type[id]
    end
    counts = zeros(4)
    for t in collect(1:4)
        counts[t] = sum(types .== t)
    end
    if sum(counts) > 15
        return false
    end
    if !(0 < counts[1] < 3)
        return false
    elseif !(0 < counts[2] < 6)
        return false
    elseif !(0 < counts[3] < 6)
        return false
    elseif !(0 < counts[4] < 4)
        return false
    end

    team = squad_vector[1:11]
    team_types = zeros(11)
    counts = zeros(4)
    for (i, id) in enumerate(team)
        team_types[i] = id_to_element_type[id]
    end
    for t in collect(1:4)
        counts[t] = sum(team_types .== t)
    end
    if sum(counts) != 11
        return false
    end
    if counts[1] != 1
        return false
    elseif !(3 <= counts[2] <= 5)
        return false
    elseif !(2 <= counts[3] <= 5)
        return false
    elseif !(1 <= counts[4] <= 3)
        return false
    else
        return true
    end
end


function fpl_players_unique(squad_vector)
    found = []
    for id in squad_vector
        if id in found
            return false
        else
            append!(found, id)
        end
    end
    return true
end


function fpl_get_player_types(squad_vector, id_to_element_type::Dict{Any, Any})
    types = zeros(size(squad_vector, 1))
    for (i, id) in enumerate(squad_vector)
        types[i] = id_to_element_type[id]
    end
    counts = zeros(4)
    for t in collect(1:4)
        counts[t] = sum(types .== t)
    end
    println("Squad types: ", counts)
    team = squad_vector[1:11]
    team_types = zeros(11)
    counts = zeros(4)
    for (i, id) in enumerate(team)
        team_types[i] = id_to_element_type[id]
    end
    for t in collect(1:4)
        counts[t] = sum(team_types .== t)
    end
    return counts
end


function fpl_print_player_types(squad_vector::Array{Int64, 1}, id_to_element_type::Dict{Any, Any})
    counts = fpl_get_player_types(squad_vector, id_to_element_type)
    println(counts)
end


function fpl_validate_squad(squad_vector::Array{Int64,1},
    id_to_cost::Dict{Any, Any},
    id_to_team::Dict{Any, Any},
    id_to_element_type::Dict{Any, Any}
    )
    if fpl_squad_cost(squad_vector, id_to_cost) <= 100
        cost_flag = true
    else
        cost_flag = false
    end
    if fpl_most_from_one_squad(squad_vector, id_to_team) <= 3
        team_flag = true
    else
        team_flag = false
    end
    types_flag = fpl_validate_player_types(squad_vector, id_to_element_type)
    players_unique_flag = fpl_players_unique(squad_vector)        
    
    valid = cost_flag * team_flag * types_flag * players_unique_flag
    return valid
end


function fpl_validate_squad(squad_vector::Array{Int64,1},
                            id_to_cost::Dict{Any, Any},
                            id_to_team::Dict{Any, Any},
                            id_to_element_type::Dict{Any, Any},
                            chosen_team::Array{Int64, 1},
                            n_changes::Int)
    valid_flag = fpl_validate_squad(squad_vector, id_to_cost, id_to_team, id_to_element_type)
    changes_flag = fpl_check_changes(chosen_team, squad_vector, n_changes)
    valid = valid_flag * changes_flag
    return valid
end


function fpl_check_changes(chosen_team, new_vector, n_changes=1::Int)
    counter = 0
    for id in new_vector
        if id in chosen_team
            counter += 1
        end
    end
    # If we find 11 players, rem is 4, 4 changes
    changes = 15 - counter
    if changes > n_changes
        return false
    else
        return true
    end
end


function fpl_iterate_valid_team(df_players::DataFrame,
                                id_to_element_type::Dict{Any, Any},
                                id_to_cost::Dict{Any, Any},
                                id_to_team::Dict{Any, Any})
    valid = 0
    while valid == 0
        squad = fpl_generate_squad_initial(df_players)
        squad = fpl_generate_team_from_squad(squad, id_to_element_type)
        valid = fpl_validate_squad(squad, id_to_cost, id_to_team, id_to_element_type)
        if valid == 1
            return squad
        end
    end
end


function fpl_select_best_rows(pool, fitnesses, n_rows)
    weights = fitnesses / sum(fitnesses)
    selected = sample(collect(1:size(pool, 1)), Weights(weights), n_rows, replace=true)
    selected_rows = pool[selected, :]
    selected_fitnesses = fitnesses[selected]
    return selected_rows, selected_fitnesses
end


function fpl_breed(parent1, parent2, parent3)
    c1, c2 = sort(sample(collect(2:14), 2))
    new = vcat(parent1[1:c1], parent2[c1+1:c2], parent3[c2+1:15])
    return new
end


function fpl_subs_swap(squad_vector::Array{Int64, 1})
    gk_chance = rand()
    if gk_chance < 0.1
        tmp = squad_vector[1]
        squad_vector[1] = squad_vector[12]
        squad_vector[12] = tmp
    end
    for i in collect(1:3)
        sub = squad_vector[12+i]
        sub_chance = rand()
        if sub_chance < 0.1
            pos_to_swap = sample(collect(2:11))
            squad_vector[12+i] = squad_vector[pos_to_swap]
            squad_vector[pos_to_swap] = sub
        end
    end
    return squad_vector
end


function fpl_mutate(squad,
    df_players::DataFrame,
    id_to_element_type::Dict{Any, Any}
    )
    goalkeepers = df_players[df_players.element_type .== 1, :]
    n_to_mutate = sample(1:3)
    pos_to_mutate = sample(collect(1:15), n_to_mutate, replace=false)
    for ind in pos_to_mutate
        id = squad[ind]
        if id_to_element_type[id] == 1
            squad[ind] = sample(goalkeepers.id)
        else
            squad[ind] = sample(df_players.id)
        end
    end
    return squad
end


function fpl_iterate_breed(parents,
    df_players::DataFrame,
    id_to_cost::Dict{Any, Any},
    id_to_team::Dict{Any, Any},
    id_to_element_type::Dict{Any, Any}
    )
    valid = 0
    its = 0
    while valid == 0 & its < 1000
        parent_inds = sample(collect(1:50), 3, replace=false)
        p1 = parents[parent_inds[1], :]
        p2 = parents[parent_inds[2], :]
        p3 = parents[parent_inds[3], :]
        new_squad = fpl_breed(p1, p2, p3)
        mutate_chance = rand()
        if mutate_chance < 0.3
            new_squad = fpl_mutate(new_squad,
            df_players,
            id_to_element_type
            )
        end
        sub_chance = rand()
        if sub_chance < 0.3
            new_squad = fpl_subs_swap(new_squad)
        end
        valid = fpl_validate_squad(new_squad,
        id_to_cost,
        id_to_team,
        id_to_element_type
        )
        if valid
            return new_squad
        end
        its += 1
    end
    error("Max iterations exceeded")
end


function fpl_iterate_breed(parents,
    df_players::DataFrame,
    id_to_cost::Dict{Any, Any},
    id_to_team::Dict{Any, Any},
    id_to_element_type::Dict{Any, Any},
    chosen_team::Array{Int64,1},
    n_changes::Int
    )
    valid = 0
    its = 0
    while valid == 0 & its < 1000
        parent_inds = sample(collect(1:50), 3, replace=false)
        p1 = parents[parent_inds[1], :]
        p2 = parents[parent_inds[2], :]
        p3 = parents[parent_inds[3], :]
        new_squad = fpl_breed(p1, p2, p3)
        mutate_chance = rand()
        if mutate_chance < 0.3
            new_squad = fpl_mutate(new_squad,
            df_players,
            id_to_element_type
            )
        end
        sub_chance = rand()
        if sub_chance < 0.3
            new_squad = fpl_subs_swap(new_squad)
        end
        valid = fpl_validate_squad(new_squad,
        id_to_cost,
        id_to_team,
        id_to_element_type,
        chosen_team,
        n_changes
        )
        if valid
            return new_squad
        end
        its += 1
    end
    error("Max iterations exceeded")
end

end