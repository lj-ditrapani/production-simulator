# Author:  Lyall Jonathan Di Trapani -----------------------------------
# Summary table code

# H/Avg/L, S3 missed op, and utilization are derived tables
#               summary wip/produced -> summary H/Avg/L
# S3 total_capacity & total_produced -> summary S3 missed op
#                  round utilization -> summary utilization


NUM_ROUNDS = 6
map = sim.map


class sim.Summary
    # 4 summary tables:
    # wip/produced, H/Avg/L, s3 missed op, utilization
    constructor: (num_teams, num_stations) ->
        # Creates 2D arrays for summary wip, produced, missed_op, util
        @wip = make_zero_grid num_teams, NUM_ROUNDS
        @produced = make_zero_grid num_teams, NUM_ROUNDS
        @missed_op = make_zero_grid num_teams, NUM_ROUNDS
        @utilization = make_zero_grid num_stations, NUM_ROUNDS

    update: (round_num, teams) ->
        # wip/prod, H/Avg/L wip/prod, s3 missed op, utilization
        if round_num > NUM_ROUNDS or round_num < 1
            return
        @update_wip_prod round_num, teams 
        @update_missed_op round_num, teams 
        @update_utilization round_num, teams 

    update_wip_prod: (round_num, teams) ->
        s = this
        update_team_values = (team_index) ->
            round_index = round_num - 1
            team = teams[team_index]
            total_wip = team.get_total_wip()
            s.wip[team_index][round_index] = total_wip
            total_produced = team.get_total_produced()
            s.produced[team_index][round_index] = total_produced
        map update_team_values, [0...teams.length]

    update_missed_op: () ->
        #missed_op = @missed_op:

    update_utilization: () ->

    display: (teams) ->
        @display_wip_prod()
        @display_average()
        @display_missed_op teams
        @display_utilization teams

    display_wip_prod: () ->
        reset_table 'wip_prod'
        funcs = ['get_wip', 'get_prod']
        attrs = {className: 'wip'}
        bound = @wip.length
        make_body(this, null, 'wip_prod', bound, funcs, 'T', attrs)

    display_average: () ->
        # H/Avg/L X rounds
        reset_table 'average'
        funcs = ['get_avg_wip', 'get_avg_prod']
        attrs = {className: 'wip'}
        make_body(this, null, 'average', 3, funcs, '', attrs)

    display_missed_op: (teams) ->
        # teams X rounds (Station 3 only!)
        reset_table 'missed_op'
        bound = teams.length
        funcs = ['get_missed_op']
        make_body(this, teams, 'missed_op', bound, funcs, 'T', {})

    display_utilization: (teams) ->
        # station X round (average utilization across teams
        reset_table 'summary_util'
        name = 'summary_util'
        bound = teams[0].stations.length
        funcs = ['get_utilization']
        make_body(this, teams, name, bound, funcs, 'S', {})

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

    get_missed_op: (teams, i, j, label) ->
        @missed_op[i][j]

    get_utilization: (teams, i, j, label) ->
        @utilization[i][j]

make_zero_grid = (height, width) ->
    ###
    grid = []
    make_rows = (i) ->
        grid.push (0 for j in [0...width])
    map make_row, [0...height]
    ###
    ((0 for j in [0...width]) for i in [0...height])


reset_table = (name) ->
    dom.removeAllChildren $ name + '_thead'
    dom.removeAllChildren $ name + '_tbody'
    ths = [dom.create 'th' ]
    make_th = if name in ['wip_prod', 'average']
        (i) ->
            ths.push dom.create 'th', ["W" + (i + 1)]
            ths.push dom.create 'th', ["P" + (i + 1)]
    else
        (i) ->
            ths.push dom.create 'th', ["R" + (i + 1)]
    map make_th, [0...NUM_ROUNDS]
    h_row = dom.create 'tr', ths
    dom.add $ name + '_thead', [h_row]


make_body = (summary, teams, name, bound, funcs, letter, attrs) ->
        make_row = (i) ->
            labels = ['High', 'Avg', 'Low']
            label = if letter == ''
                labels[i]
            else
                letter + (i + 1)
            tds = [dom.create 'td', {className: 'team'}, [label]]
            make_td = (j) ->
                value = summary[funcs[0]](teams, i, j, label)
                tds.push dom.create 'td', attrs, [dom.t value]
                if funcs.length > 1
                    value = summary[funcs[1]](teams, i, j, label)
                    tds.push dom.create 'td', [dom.t value]
            map make_td, [0...NUM_ROUNDS]
            dom.create 'tr', tds
        rows = map make_row, [0...bound]
        dom.add $(name + '_tbody'), rows


sim.summary_mod = {make_zero_grid: make_zero_grid}
