# Author:  Lyall Jonathan Di Trapani  ----------------------------------
team = sim.team
module 'team'


test_init_func = (val_name, tests) ->
    for [round_num, station_num, exp_val] in tests
        label = "R#{round_num} S#{station_num} -> #{exp_val}"
        func = team["initial_#{val_name}"]
        act_val = func(round_num, station_num, 100)
        equal act_val, exp_val, label


test 'initial_dice_count (round_num, station_num -> dice_count)', ->
    tests = [
        [1, 1, 1]
        [1, 2, 1]
        [1, 3, 1]
        [2, 1, 2]
        [2, 2, 2]
        [2, 3, 1]
        [6, 4, 2]
        [6, 3, 1]
    ]
    test_init_func('dice_count', tests)


test 'initial_min (round_num, station_num -> min)', ->
    tests = [
        [1, 1, 1]
        [3, 3, 1]
        [4, 2, 1]
        [5, 4, 1]
        [4, 3, 4]
        [6, 3, 4]
    ]
    test_init_func('min', tests)


test 'initial_wip (round_num, station_num, inducted_wip -> WIP)', ->
    tests = [
        [1, 1, 0]
        [4, 1, 0]
        [5, 1, 100]
        [6, 1, 100]
        [5, 2, 4]
        [3, 3, 4]
        [4, 3, 9]
        [4, 2, 4]
    ]
    test_init_func('wip', tests)


test 'make_station (station_num)', ->
    station = team.make_station 1, 1, 100
    equal station.num, 1
    equal station.wip, 0
    equal station.dice.min, 1
    station = team.make_station 5, 3, 100
    equal station.wip, 9
    equal station.dice.dice_count, 1
    equal station.dice.min, 4
    station = team.make_station 5, 1, 100
    equal station.num, 1, 's1.num = 1'
    equal station.wip, 100, 's1.wip = 100'
    equal station.dice.dice_count, 2, 's1.dice.dice_count = 2'


make_test_team = (num_stations, round_num, inducted_wip) ->
    t = new team.Team num_stations, round_num, inducted_wip
    for station in t.stations
        if station.num == 1
            station.dice.random = () -> 0.99    # S1 always rolls a 6
        else
            station.dice.random = () -> 0.3     # Others always roll a 2
    t


test 'Team and attach previous', ->
    t = make_test_team 5, 1, 100
    equal t.stations.length, 5, 'team is correct length'
    equal typeof t.get_station(1).prev, 'undefined'
    equal t.get_station(2).prev.num, 1
    equal t.get_station(5).prev.num, 4


test 'Team.roll() on round 5 when station 1 has 0 WIP', ->
    t = make_test_team 5, 4, 0
    get_count = () -> t.get_station(3).dice.dice_count
    equal get_count(), 1, 'R4: station 3 has 1 dice'
    t.roll()
    t = make_test_team 5, 5, 0
    t.roll()
    equal get_count(), 2, 'R5: station 3 now has 2 dice'
    t = make_test_team 5, 6, 0
    t.roll()
    equal get_count(), 2, 'R6: station 3 now has 2 dice'
    equal t.get_station(1).wip, 0, 'R6: station 1 has WIP = 0'


test 'Team.roll() on rounds 3 and 4: S1.capacity == S3.capacity', ->
    run_test = (round, same) ->
        t = make_test_team 5, round, 100
        t.roll()
        s1_capacity = t.get_station(1).capacity
        s3_capacity = t.get_station(3).capacity
        if same
            label = "R#{round}: stations 1 and 3 both have capacity " +
                    "of #{s1_capacity}"
            equal s1_capacity, s3_capacity, label
        else
            label = "R#{round}: stations 1 and 3 have diff capacity "
            notEqual s1_capacity, s3_capacity, label
    run_test(2, false)
    run_test(3, true)
    run_test(4, true)
    run_test(5, false)


test 'Team.update() on round 1', ->
    get_state = (s) -> [
        s.active_count, s.wip, s.capacity, s.produced, 
        s.total_produced, s.total_capacity
    ]
    t = make_test_team 5, 1, 100
    s1 = t.get_station(1)
    s2 = t.get_station(2)
    deepEqual get_state(s1), [0, 0, 0, 0, 0, 0], 'Initial S1'
    deepEqual get_state(s2), [0, 4, 0, 0, 0, 0], 'Initial S2'
    t.update()
    deepEqual get_state(s1), [1, 0, 6, 6, 6, 6], 'S1 after step 1'
    deepEqual get_state(s2), [1, 8, 2, 2, 2, 2], 'S2 after step 1'
    t.update()
    deepEqual get_state(s1), [2, 0, 6, 6, 12, 12], 'S1 after step 2'
    deepEqual get_state(s2), [2, 12, 2, 2, 4, 4], 'S2 after step 2'


test 'Team.get_total_wip', ->
    t = make_test_team 5, 1, 100
    equal t.get_total_wip(), 4 * 4
    t.update()
    equal t.get_total_wip(), 4 * 4 + 6 - 2


test 'make_teams', ->
    num_teams = 3
    teams = team.make_teams(num_teams, 
                            5, 
                            1, 
                            100)
    equal teams.length, num_teams, '3 teams were created'
    equal teams[0].get_station(1).num, 1, 'Has get_station method'


make_test_teams = (num_teams, num_stations, round_num) ->
    teams = team.make_teams num_teams, num_stations, round_num, 100
    check_dimensions teams, num_teams, num_stations
    teams


check_dimensions = (teams, num_teams, num_stations) ->
    equal teams.length, num_teams, 'teams length is correct'
    equal teams[teams.length - 1].stations.length, 
          num_stations, 
          'The number of stations is correct'


check_teams_attr = (teams, station_nums, attr, exp_val) ->
    check_stations_attr = (team) ->
        for i in station_nums
            station = team.get_station i
            if attr in ['dice_count', 'min', 'range']
                equal station.dice[attr], exp_val
            else
                equal station[attr], exp_val
    sim.map check_stations_attr, teams


check_attrs = (teams, attr_sets) ->
    for [station_nums, attr, exp_val] in attr_sets
        check_teams_attr teams, station_nums, attr, exp_val


test 'make teams for round 1', ->
    teams = make_test_teams 2, 5, 1
    attr_sets = [
        [[1,2,3,4,5], 'dice_count', 1]
        [[1], 'wip', 0]
        [[2,3,4,5], 'wip', 4]
        [[1,2,3,4,5], 'min', 1]
        [[1,2,3,4,5], 'range', 6]
    ]
    check_attrs teams, attr_sets


test 'make teams for round 2', ->
    teams = make_test_teams 3, 6, 2
    attr_sets = [
        [[1,2,4,5,6], 'dice_count', 2]
        [[1], 'wip', 0]
        [[2,3,4,5,6], 'wip', 4]
        [[1,2,3,4,5,6], 'min', 1]
        [[1,2,3,4,5,6], 'range', 6]
        [[3], 'dice_count', 1]
    ]
    check_attrs teams, attr_sets


test 'make teams for round 3', ->
    teams = make_test_teams 2, 4, 3
    attr_sets = [
        [[1,2,4], 'dice_count', 2]
        [[1], 'wip', 0]
        [[2,3,4], 'wip', 4]
        [[1,2,3,4], 'min', 1]
        [[1,2,3,4], 'range', 6]
        [[3], 'dice_count', 1]
    ]
    check_attrs teams, attr_sets


test 'make teams for round 4', ->
    teams = make_test_teams 2, 4, 4
    attr_sets = [
        [[1,2,4], 'dice_count', 2]
        [[1], 'wip', 0]
        [[2,4], 'wip', 4]
        [[1,2,4], 'min', 1]
        [[1,2,4], 'range', 6]
        [[3], 'dice_count', 1]
        [[3], 'min', 4]
        [[3], 'wip', 9]
        [[3], 'range', 3]
    ]
    check_attrs teams, attr_sets


test 'get_table_row(name) name = capacity|wip|total_cap|total_prod', ->
    t = make_test_team 4, 1, 100
    tds = t.get_table_row 'total_capacity'
    equal tds.length, 4
    tds = t.get_table_row 'wip'
    equal tds.length, 5
    

test 'get_total_produced', ->
    t = make_test_team 4, 1, 100
    equal t.get_total_produced(), 0
    for value in [2, 4, 6]
        t.update()
        equal t.get_total_produced(), value
