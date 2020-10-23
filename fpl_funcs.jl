function generate_formation()
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


function generate_squad_initial(goalkeepers,)
    """Generates a random squad"""
    gk_ids = sample(goalkeepers.id, 2, replace=false)
    defender_ids = sample(defenders.id, 5, replace=false)
    midfielder_ids = sample(midfielders.id, 5, replace=false)
    attacker_ids = sample(attackers.id, 3, replace=false)
    vec = vcat(gk_ids, defender_ids, midfielder_ids, attacker_ids)
    return vec
end


function generate_team_from_squad(squad_vector)
    """Sorts a team into the first 11 parts"""
    gk, d, m, a = generate_formation()
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


function print_squad_names(squad_vector)
    for i in squad_vector
        println(i, " ", id_to_player[i])
    end
end


function squad_cost(squad_vector)
    sum = 0
    if 0 in squad_vector
        println(squad_vector)
    end
    for id in squad_vector
        sum += id_to_cost[id]
    end
    return sum
end


function team_fitness(squad_vector)
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


function most_from_one_squad(squad_vector)
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


function validate_player_types(squad_vector)
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


function players_unique(squad_vector)
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


function get_player_types(squad_vector)
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


function print_player_types(squad_vector::Array{Int64, 1})
    counts = get_player_types(squad_vector)
    println(counts)
end


function validate_squad(squad_vector::Array{Int64,1})
    if squad_cost(squad_vector) <= 100
        cost_flag = true
    else
        cost_flag = false
    end
    if most_from_one_squad(squad_vector) <= 3
        team_flag = true
    else
        team_flag = false
    end
    types_flag = validate_player_types(squad_vector)
    players_unique_flag = players_unique(squad_vector)        
    
    valid = cost_flag * team_flag * types_flag * players_unique_flag
    return valid
end


function validate_squad(squad_vector::Array{Int64,1}, chosen_team::Array{Int64, 1}, n_changes::Int)
    valid_flag = validate_squad(squad_vector)
    changes_flag = check_changes(chosen_team, squad_vector, n_changes)
    valid = valid_flag * changes_flag
    return valid
end


function iterate_valid_team()
    valid = 0
    while valid == 0
        squad = generate_squad_initial()
        squad = generate_team_from_squad(squad)
        valid = validate_squad(squad)
        if valid == 1
            return squad
        end
    end
end


function select_best_rows(pool, fitnesses, n_rows)
    weights = fitnesses / sum(fitnesses)
    selected = sample(collect(1:size(pool, 1)), Weights(weights), n_rows, replace=true)
    selected_rows = pool[selected, :]
    selected_fitnesses = fitnesses[selected]
    return selected_rows, selected_fitnesses
end


function breed(parent1, parent2, parent3)
    c1, c2 = sort(sample(collect(2:14), 2))
    new = vcat(parent1[1:c1], parent2[c1+1:c2], parent3[c2+1:15])
    return new
end


function subs_swap(squad_vector::Array{Int64, 1})
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


function mutate(squad)
    n_to_mutate = sample(1:3)
    pos_to_mutate = sample(collect(1:15), n_to_mutate, replace=false)
    for ind in pos_to_mutate
        id = squad[ind]
        if id_to_element_type[id] == 1
            squad[ind] = sample(goalkeepers.id)
        else
            squad[ind] = sample(df.id)
        end
    end
    return squad
end


function iterate_breed(parents)
    valid = 0
    its = 0
    while valid == 0 & its < 1000
        parent_inds = sample(collect(1:50), 3, replace=false)
        p1 = parents[parent_inds[1], :]
        p2 = parents[parent_inds[2], :]
        p3 = parents[parent_inds[3], :]
        new_squad = breed(p1, p2, p3)
        mutate_chance = rand()
        if mutate_chance < 0.3
            new_squad = mutate(new_squad)
        end
        sub_chance = rand()
        if sub_chance < 0.3
            new_squad = subs_swap(new_squad)
        end
        valid = validate_squad(new_squad)
        if valid
            return new_squad
        end
        its += 1
    end
    error("Max iterations exceeded")
end


function iterate_breed(parents, chosen_team::Array{Int64,1}, n_changes::Int)
    valid = 0
    its = 0
    while valid == 0 & its < 1000
        parent_inds = sample(collect(1:50), 3, replace=false)
        p1 = parents[parent_inds[1], :]
        p2 = parents[parent_inds[2], :]
        p3 = parents[parent_inds[3], :]
        new_squad = breed(p1, p2, p3)
        mutate_chance = rand()
        if mutate_chance < 0.3
            new_squad = mutate(new_squad)
        end
        sub_chance = rand()
        if sub_chance < 0.3
            new_squad = subs_swap(new_squad)
        end
        valid = validate_squad(new_squad, chosen_team, n_changes)
        if valid
            return new_squad
        end
        its += 1
    end
    error("Max iterations exceeded")
end


