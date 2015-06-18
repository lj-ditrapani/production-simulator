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
  station.add_tds.apply station, (ljd.create 'td' for i in [1..8])
  station


class team.Team
  constructor: (num_stations,
                @round_num,
                inducted_wip,
                @s1_capacity_constraint) ->
    closure = (station_num) =>
      team.make_station @round_num, station_num, inducted_wip
    @stations = sim.map(closure, [1..num_stations])
    # Attach previous stations
    for i in [1...num_stations]
      @stations[i].prev = @stations[i - 1]
    @total_wip_td = ljd.create 'td'
    @previous_s3_capacity = 4
    @previous_last_station_capacity = 4

  get_station: (num) ->
    @stations[num - 1]

  set_s1_capacity_constraint: (name) ->
    @s1_capacity_constraint = name

  roll: () ->
    # If on round >= 5 & no more wip to induce (station 1 WIP = 0),
    # move resources from s1 to s3, so station 3 has 2 dice
    s1 = @get_station(1)
    s3 = @get_station(3)
    last_station = @get_station(@stations.length)
    if @round_num >= 5 and s1.wip == 0
      s3.set_dice_count 2
    # Row we can roll the dice for each station, creating a new
    # capacity for this step
    for station in @stations
      station.roll_dice()
    # Apply s1 capacity constraint if rount # == 3 or 4
    if @round_num == 3 or @round_num == 4
      if @s1_capacity_constraint == 'S3'
        s1.capacity = @previous_s3_capacity
      else  # s1 capacity constraint == 'last'
        s1.capacity = @previous_last_station_capacity
      @previous_s3_capacity = s3.capacity
      @previous_last_station_capacity = last_station.capacity

  update: () ->
    @roll()
    for station in @stations
      station.update(@round_num)

  display: (step_num) ->
    for station in @stations
      station.display(step_num, @round_num)
    @update_highlighting()
    ljd.setText @total_wip_td, @get_total_wip()

  update_highlighting: () ->
    @clear_highlights_from_stations()
    stations = @get_stations_with_min_total_capacity()
    @highligt_stations(stations, 'total_capacity')
    stations = @get_stations_with_max_missed_op()
    @highligt_stations(stations, 'missed_op')

  get_total_wip: () ->
    sum = (list) ->
      result = 0
      for x in list
        result += x
      result
    sum(s.wip for s in @stations[1..])

  get_missed_op3: () ->
    # Missed opportunity at station 3
    s3 = @get_station(3)
    s3.get_missed_op()

  get_utilization: (station_num, step_num) ->
    @get_station(station_num).get_utilization step_num

  get_efficiency: (station_num) ->
    @get_station(station_num).get_efficiency()

  get_total_produced: () ->
    @stations[@stations.length - 1].total_produced

  get_stations_with_min_total_capacity: () ->
    @get_stations_with_min_max_value('min', 'total_capacity')

  get_stations_with_max_missed_op: () ->
    @get_stations_with_min_max_value('max', 'missed_op')

  get_stations_with_min_max_value: (min_or_max, field_name) ->
    value = @get_min_max_value(min_or_max, field_name)
    @get_stations_with_value(field_name, value)

  get_min_max_value: (min_or_max, field_name) ->
    get_value = "get_#{field_name}"
    values = (station[get_value]() for station in @stations)
    Math[min_or_max].apply Math, values

  get_stations_with_value: (field_name, value) ->
    array = []
    for s in @stations
      s_value = s["get_#{field_name}"]()
      if s_value == value
        array.push s
    array

  clear_highlights_from_stations: () ->
    (s.clear_highlights() for s in @stations)

  highligt_stations: (stations, field_name) ->
    s.highlight(field_name) for s in stations

  get_table_row: (name) ->
    row = (station.get_td name for station in @stations)
    if name == 'wip'
      row.push @total_wip_td
    row


team.make_teams = (num_teams,
                   num_stations,
                   round_num,
                   inducted_wip,
                   s1_capacity_constraint) ->
  closure = () -> new team.Team num_stations,
                                round_num,
                                inducted_wip,
                                s1_capacity_constraint
  closure() for i in [0...num_teams]
