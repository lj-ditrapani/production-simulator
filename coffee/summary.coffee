# Author:  Lyall Jonathan Di Trapani -----------------------------------
# Summary table code

# H/Avg/L, S3 missed op, utilization, and efficiency are derived tables
#               summary wip/produced -> summary H/Avg/L
# S3 total_capacity & total_produced -> summary S3 missed op
#          current round utilization -> summary utilization
#           current round efficiency -> summary efficiency


NUM_ROUNDS = 6
map = sim.map


class sim.Summary
  # 4 summary tables:
  # wip/produced, H/Avg/L, s3 missed op, utilization
  constructor: (num_teams, num_stations) ->
    # Creates 2D arrays for summary wip, produced, missed_op3, util
    @NUM_STATIONS = num_stations
    @wip = make_zero_grid num_teams, NUM_ROUNDS
    @produced = make_zero_grid num_teams, NUM_ROUNDS
    @missed_op3 = make_zero_grid num_teams, NUM_ROUNDS
    @utilization = make_zero_grid num_stations, NUM_ROUNDS
    @efficiency = make_zero_grid num_stations, NUM_ROUNDS

  update: (round_num, teams, step_num) ->
    # wip/prod, H/Avg/L wip/prod, s3 missed op, utilization
    if round_num > NUM_ROUNDS or round_num < 1
      return
    @update_wip round_num, teams
    @update_prod round_num, teams
    @update_missed_op3 round_num, teams
    @update_utilization round_num, teams, step_num
    @update_efficiency round_num, teams

  update_wip: (round_num, teams) ->
    s = this
    round_index = round_num - 1
    update_team_wip = (team_index) ->
      team = teams[team_index]
      total_wip = team.get_total_wip()
      s.wip[team_index][round_index] = total_wip
    map update_team_wip, [0...teams.length]

  update_prod: (round_num, teams) ->
    s = this
    round_index = round_num - 1
    update_team_prod = (team_index) ->
      team = teams[team_index]
      total_produced = team.get_total_produced()
      s.produced[team_index][round_index] = total_produced
    map update_team_prod, [0...teams.length]

  update_missed_op3: (round_num, teams) ->
    round_index = round_num - 1
    for team_index in [0...teams.length]
      val = teams[team_index].get_missed_op3()
      @missed_op3[team_index][round_index] = val

  update_utilization: (round_num, teams, step_num) ->
    round_index = round_num - 1
    for station_index in [0...@NUM_STATIONS]
      station_num = station_index + 1
      val = compute_utilization station_num, teams, step_num
      @utilization[station_index][round_index] = val

  update_efficiency: (round_num, teams) ->
    round_index = round_num - 1
    for station_index in [0...@NUM_STATIONS]
      val = compute_efficiency (station_index + 1), teams
      @efficiency[station_index][round_index] = val

  display: (teams) ->
    @display_wip()
    @display_prod()
    @display_average_wip()
    @display_average_prod()
    @display_missed_op3 teams
    @display_utilization teams
    @display_efficiency teams

  display_wip: () ->
    reset_table 'wip'
    func = 'get_wip'
    attrs = {className: 'wip'}
    bound = @wip.length
    make_body(this, null, 'wip', bound, func, 'T', attrs)

  display_prod: () ->
    reset_table 'prod'
    func = 'get_prod'
    attrs = {className: 'produced'}
    bound = @produced.length
    make_body(this, null, 'prod', bound, func, 'T', attrs)

  display_average_wip: () ->
    # H/Avg/L X rounds
    reset_table 'average_wip'
    func = 'get_avg_wip'
    attrs = {className: 'wip'}
    make_body(this, null, 'average_wip', 3, func, '', attrs)

  display_average_prod: () ->
    # H/Avg/L X rounds
    reset_table 'average_prod'
    func = 'get_avg_prod'
    attrs = {className: 'produced'}
    make_body(this, null, 'average_prod', 3, func, '', attrs)

  display_missed_op3: (teams) ->
    # teams X rounds (Station 3 only!)
    reset_table 'missed_op3'
    bound = teams.length
    func = 'get_missed_op3'
    make_body(this, teams, 'missed_op3', bound, func, 'T', {})

  display_utilization: (teams) ->
    # station X round (average utilization across teams)
    name = 'summary_util'
    reset_table name
    func = 'get_utilization'
    make_body(this, teams, name, @NUM_STATIONS, func, 'S', {})

  display_efficiency: (teams) ->
    # station X round (average efficiency across teams)
    name = 'summary_efficiency'
    reset_table name
    func = 'get_efficiency'
    make_body(this, teams, name, @NUM_STATIONS, func, 'S', {})

  get_wip: (teams, i, j, label) ->
    @wip[i][j]

  get_prod: (teams, i, j, label) ->
    @produced[i][j]

  get_avg_wip: (none, i, round_index, label) ->
    @get_avg @wip, round_index, label

  get_avg_prod: (none, i, round_index, label) ->
    @get_avg @produced, round_index, label

  get_avg: (table, round_index, label) ->
    values = []
    for i in [0...table.length]
      values.push table[i][round_index]
    switch label
      when 'High'
        Math.max.apply null, values
      when 'Avg'
        sum = 0
        for v in values
          sum += v
        Math.round(1.0 * sum / values.length)
      when 'Low'
        Math.min.apply null, values

  get_missed_op3: (teams, i, j, label) ->
    @missed_op3[i][j]

  get_utilization: (teams, i, j, label) ->
    @utilization[i][j]

  get_efficiency: (teams, i, j, label) ->
    @efficiency[i][j]


make_zero_grid = (height, width) ->
  ((0 for j in [0...width]) for i in [0...height])


compute_utilization = (station_num, teams, step_num) ->
  sum = 0
  for team in teams
    sum += team.get_utilization station_num, step_num
  Math.round(sum / teams.length)


compute_efficiency = (station_num, teams) ->
  sum = 0
  for team in teams
    sum += team.get_efficiency station_num
  Math.round(sum / teams.length)


reset_table = (name) ->
  ljd.removeAllChildren ljd.$(name + '_thead')
  ljd.removeAllChildren ljd.$(name + '_tbody')
  ths = [ljd.create 'th' ]
  make_th = if name in ['wip_prod', 'average']
    (i) ->
      ths.push ljd.create 'th', ["W" + (i + 1)]
      ths.push ljd.create 'th', ["P" + (i + 1)]
  else
    (i) ->
      ths.push ljd.create 'th', ["R" + (i + 1)]
  map make_th, [0...NUM_ROUNDS]
  h_row = ljd.create 'tr', ths
  ljd.add ljd.$(name + '_thead'), [h_row]


make_body = (summary, teams, name, bound, func, letter, attrs) ->
  make_row = (i) ->
    labels = ['High', 'Avg', 'Low']
    label = ->
      if letter == ''
        labels[i]
      else
        letter + (i + 1)
    tds = [ljd.create 'td', {className: 'team'}, [label()]]
    make_td = (j) ->
      value = summary[func](teams, i, j, label())
      tds.push ljd.create 'td', attrs, [ljd.t value]
    map make_td, [0...NUM_ROUNDS]
    ljd.create 'tr', tds
  rows = map make_row, [0...bound]
  ljd.add ljd.$(name + '_tbody'), rows


sim.summary_mod = {make_zero_grid: make_zero_grid}
