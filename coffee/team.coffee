# Author:  Lyall Jonathan Di Trapani  ----------------------------------
team = {}
sim.team = team


team.initial_dice_count = (round_num, station_num) ->
    if round_num == 1 or station_num == 3
        1
    else
        2


team.initial_min = (round_num, station_num) ->
    if round_num >= 4 and station_num == 3
        4
    else
        1


team.initial_wip = (round_num, station_num, inducted_wip) ->
    if round_num >= 5 and station_num == 1
        inducted_wip
    else if station_num == 1
        0
    else if round_num >= 4 and station_num == 3
        9
    else
        4


team.make_station = (round_num, station_num, inducted_wip) ->
    dice_count = team.initial_dice_count round_num, station_num
    min = team.initial_min round_num, station_num
    wip = team.initial_wip round_num, station_num, inducted_wip
    station = new sim.Station station_num, dice_count, min, wip
    # Attach the 'table data' cells that belong to this station
    station.add_tds.apply station, (dom.create 'td' for i in [1..5])
    station


class team.Team
    constructor: (num_stations, @round_num, inducted_wip) ->
        closure = (station_num) ->
            team.make_station round_num, station_num, inducted_wip
        @stations = sim.map(closure, [1..num_stations])
        # Attach previous stations
        for i in [1...num_stations]
            @stations[i].prev = @stations[i - 1]
        @total_wip_td = dom.create 'td'

    get_station: (num) ->
        @stations[num - 1]

    roll: () ->
        # If on round >= 5 & no more wip to induce (station 1 WIP = 0), 
        # move resources from s1 to s3, so station 3 has 2 dice
        s1 = @get_station(1)
        s3 = @get_station(3)
        if @round_num >= 5 and s1.wip == 0
            s3.set_dice_count 2
        # Row we can roll the dice for each station, creating a new
        # capacity for this step
        for station in @stations
            station.roll_dice()
        # fix s1 roll == s3 roll if necessary (round # == 3 or 4)
        if @round_num == 3 or @round_num == 4
            s1.capacity = s3.capacity

    update: () ->
        @roll()
        for station in @stations
            station.update(@round_num)

    display: (step_num) ->
        for station in @stations
            station.display(step_num, @round_num)
        dom.set_text @total_wip_td, @get_total_wip()

    get_total_wip: () ->
        sum = (list) ->
            result = 0
            for x in list
                result += x
            result
        sum(s.wip for s in @stations[1..])

    get_missed_op: () ->
        s3 = @get_station(3)
        s3.total_capacity - s3.total_produced

    get_utilization: (station_num, step_num) ->
        @get_station(station_num).get_utilization step_num

    get_total_produced: () ->
        @stations[@stations.length - 1].total_produced

    get_table_row: (name) ->
        row = (station.get_td name for station in @stations)
        if name == 'wip'
            row.push @total_wip_td
        row


team.make_teams = (num_teams, num_stations, round_num, inducted_wip) ->
    closure = () -> new team.Team num_stations, round_num, inducted_wip
    closure() for i in [0...num_teams]
