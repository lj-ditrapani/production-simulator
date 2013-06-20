# Author:  Lyall Jonathan Di Trapani -----------------------------------
# Main simulation code


NUM_ROUNDS = 6


ready = () ->
    $('num_teams').value = sim.num_teams
    sim.init_finals sim.num_teams
    sim.setup()


# Global variables, only written to on setup
window.sim = {
    num_teams: 3,       # Number of teams
    num_steps: 20,      # Max number of steps for round
    round_num: 1,       # Current round number
    step_num: 0,        # Current step number
    teams: [],          # Only individual stations are updated
    total_wip_tds: [],  # Table data elements for total WIPs
    final_wip: [],
    final_produced: [],
    inducted_wip: 85,   # How much total wip to induce on rounds >= 5
    lock_num_steps: false,      # Do not allow stepping past num_steps
}


map = (f, list) ->
    f x for x in list


sim.show_div = (name) ->
    div = $ name
    div.className = 'visible'
    names = ['config', 'run', 'results']
    names = remove names, name
    for name in names
        $(name).className = 'invisible'


remove = (list, el_to_remove) ->
    el for el in list when el != el_to_remove


sim.step_ = () ->
    # Execute one step (roll) of the current round & display results
    # step is reserved in firefox, must use step_
    if sim.lock_num_steps and sim.step_num == sim.num_steps
        return
    step_data()
    # display capacity, total_capacity, total_produced, 
    #         curr_wip, total_wips
    display()
    display_final_table()


step_data = () ->
    # Execute one step (roll) of the current round (do not display)
    # roll all
    for t in sim.teams
        t.roll()
    # update stations of teams (wip, produced, tr, tp)
    for t in sim.teams
        t.update()
    sim.step_num += 1
    # udpate final_wip, fr, fp
    if sim.step_num == sim.num_steps
        update_finals()


sim.setup = () ->
    # Set-up simulation round based on configuration
    num_teams = parseInt($('num_teams').value)
    if num_teams != sim.num_teams
        sim.num_teams = num_teams
        sim.init_finals num_teams
    num_stations = parseInt $('num_stations').value
    sim.round_num = parseInt $('round_number').value
    dom.set_text($('round_number_label'), sim.round_num)
    sim.num_steps = parseInt($('num_steps').value)
    sim.step_num = 0
    dom.set_text $('step_number_label'), sim.step_num
    sim.inducted_wip = parseInt $('inducted_wip').value
    generate_sim num_teams, num_stations


generate_sim = (num_teams, num_stations) ->
    # create stations, teams, and tables for simulation
    sim.teams = sim.team.make_teams num_teams, 
                                    num_stations, 
                                    sim.round_num, 
                                    sim.inducted_wip
    sim.total_wip_tds = make_total_wip_tds num_teams
    display()
    make_table 'capacity', num_teams, num_stations
    make_table 'wip', num_teams, num_stations
    make_table 'total_capacity', num_teams, num_stations
    make_table 'total_produced', num_teams, num_stations
    display_final_table()


make_total_wip_tds = (num_teams) ->
    # Create table data elements for total team WIP values
    f = (i) -> dom.create 'td'
    map f, [0...num_teams]


sim.init_finals = (num_teams) ->
    sim.final_wip = []
    sim.final_produced = []
    make_team_finals_for = (name) ->
        team_vals = (0 for j in [0...NUM_ROUNDS])
        sim['final_' + name].push team_vals
    make_team_finals = (i) ->
        map make_team_finals_for, ['wip', 'produced']
    map make_team_finals, [0...num_teams]


display_final_table = () ->
    dom.removeAllChildren $ 'final_tbody'
    dom.removeAllChildren $ 'final_thead'
    ths = [dom.create 'th' ]
    make_th = (i) ->
        ths.push dom.create 'th', ["W" + (i + 1)]
        ths.push dom.create 'th', ["P" + (i + 1)]
    map make_th, [0...NUM_ROUNDS]
    h_row = dom.create 'tr', ths
    dom.add $ 'final_thead' , [h_row]
    make_row = (i) ->
        attrs = {className: 'team'}
        tds = [dom.create 'td', attrs, ['T' + (i + 1)] ]
        make_td = (j) ->
            wip = sim.final_wip[i][j]
            produced = sim.final_produced[i][j]
            tds.push dom.create 'td', [dom.t wip]
            tds.push dom.create 'td', [dom.t produced]
        map make_td, [0...NUM_ROUNDS]
        dom.create 'tr', tds
    rows = map make_row, [0...sim.teams.length]
    dom.add $('final_tbody'), rows


make_table = (name, num_teams, num_stations) ->
    table = $ name + '_table'
    dom.removeAllChildren table
    make_row = (index) ->
        # Returns a tr element with all td children
        team = sim.teams[index]
        tds = map ((s) -> s[name + '_td']), team.stations
        attrs = {className: 'team'}
        tds.unshift dom.create 'td', attrs, ['T' + (index + 1)]
        # if wip, then add total wip td to tds
        if name == 'wip'
            tds.push sim.total_wip_tds[index]
        dom.create 'tr', tds
    # returns list of row nodes
    rows = map make_row, [0...num_teams]
    make_th = (i) ->
        dom.create 'th', ['S' + (i + 1)]
    ths = map make_th, [0...num_stations]
    ths.unshift dom.create 'th'
    if name == 'wip'
        ths.push dom.create 'th', ['Total']
    h_row = dom.create 'tr', ths
    head = dom.create 'thead', [h_row]
    body = dom.create 'tbody', rows
    dom.add table, [head, body]


update_finals = () ->
    if sim.round_num > NUM_ROUNDS or sim.round_num < 1
        return
    get_total_produced = (team) ->
        team.stations[team.stations.length - 1].total_produced
    update_team_finals = (team_index) ->
        round_index = sim.round_num - 1
        team = sim.teams[team_index]
        total_wip = team.get_total_wip()
        sim.final_wip[team_index][round_index] = total_wip
        total_produced = get_total_produced team
        sim.final_produced[team_index][round_index] = total_produced
    map update_team_finals, [0...sim.teams.length]


sim.simulate = () ->
    # Run all steps in simulation and display final results
    for i in [sim.step_num...sim.num_steps]
        step_data()
    display()
    display_final_table()


display = () ->
    # Display state of stations and totals in all tables
    # tables: capacity, total_capacity, total_produced, 
    #         curr_wip, total_wips
    dom.set_text($('step_number_label'), sim.step_num)
    for team in sim.teams
        team.display()
    # display wip totals (do not count station 1 wip!)
    f = (i) ->
        team = sim.teams[i]
        dom.set_text sim.total_wip_tds[i], team.get_total_wip()
    map f, [0...sim.total_wip_tds.length]


sim.ready = ready
sim.map = map
sim.remove = remove
