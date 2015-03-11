# Author:  Lyall Jonathan Di Trapani -----------------------------------
# Main simulation code


ready = () ->
    ljd.$('num_teams').value = sim.num_teams
    ljd.$('num_stations').value = sim.num_stations
    sim.summary = new sim.Summary sim.num_teams, sim.num_stations
    sim.setup()


# Global variables, only written to on setup
window.sim = {
    num_teams: 3,       # Number of teams
    num_stations: 6     # Number of stations
    num_steps: 20,      # Max number of steps for round
    round_num: 1,       # Current round number
    step_num: 0,        # Current step number
    teams: [],          # Only individual stations are updated
    inducted_wip: 85,   # How much total wip to induce on rounds >= 5
    lock_num_steps: false,      # Do not allow stepping past num_steps
}


default_values =
    num_teams: 3,       # Number of teams
    num_stations: 6     # Number of stations
    round_num: 1
    num_steps: 20
    inducted_wip: 85,   # How much total wip to induce on rounds >= 5


map = (f, list) ->
    f x for x in list


sim.show_div = (name) ->
    show name
    change_class (name + '_button'), 'selected'
    names = ['config', 'run', 'results', 'summary']
    names = remove names, name
    for name in names
        hide name
        change_class (name + '_button'), ''


sim.hide_docs = () ->
    hide 'doc'
    hide 'hide_docs'
    show 'show_docs'


sim.show_docs = () ->
    hide 'show_docs'
    show 'hide_docs'
    show 'doc'


show = (id) ->
    change_class id, ''


hide = (id) ->
    change_class id, 'invisible'


change_class = (id, className) ->
    ljd.$(id).className = className


remove = (list, el_to_remove) ->
    el for el in list when el != el_to_remove


sim.simulate = () ->
    # Run all steps in simulation and display summary results
    if sim.step_num >= sim.num_steps
        return
    for i in [sim.step_num...sim.num_steps]
        step_data(sim.round_num, sim.teams)
    display(sim.step_num, sim.teams)
    sim.summary.display(sim.teams)


sim.step_ = () ->
    # Execute one step (roll) of the current round & display results
    # step is reserved in firefox, must use step_
    if sim.lock_num_steps and sim.step_num == sim.num_steps
        return
    step_data(sim.round_num, sim.teams)
    # display capacity, total_capacity, total_produced,
    #         curr_wip, total_wips
    display(sim.step_num, sim.teams)
    sim.summary.display(sim.teams)


step_data = (round_num, teams) ->
    # Execute one step (roll) of the current round (do not display)
    for t in teams
        t.update()
    sim.step_num += 1
    # udpate summary wip, produced, H/Avg/L, s3 missed op, utilization
    # efficiency and missed op
    if sim.step_num == sim.num_steps
        sim.summary.update(round_num, teams, sim.step_num)


sim.setup = () ->
    # Set-up simulation round based on configuration
    num_teams = get_input 'num_teams'
    num_stations = get_input 'num_stations'
    if num_teams != sim.num_teams or num_stations != sim.num_stations
        sim.num_teams = num_teams
        sim.num_stations = num_stations
        sim.summary = new sim.Summary num_teams, num_stations
    sim.round_num = get_input 'round_num'
    ljd.setText(ljd.$('round_num_label'), sim.round_num)
    sim.num_steps = get_input 'num_steps'
    sim.step_num = 0
    ljd.setText ljd.$('step_number_label'), sim.step_num
    sim.inducted_wip = get_input 'inducted_wip'
    generate_sim num_teams, num_stations


get_input = (name) ->
    # input validation
    value = parseInt ljd.$(name).value, 10
    if is_value_ok(name, value)
        value
    else
        ljd.$(name).value = default_values[name]
        default_values[name]


is_value_ok = (name, value) ->
    if isNaN(value) or (value <= 0)
        false
    else if (name == 'num_stations') and (value < 3)
        false
    else
        true


generate_sim = (num_teams, num_stations) ->
    # create stations, teams, and tables for simulation
    sim.teams = sim.team.make_teams num_teams,
                                    num_stations,
                                    sim.round_num,
                                    sim.inducted_wip
    display(sim.step_num, sim.teams)
    names = ['capacity', 'produced', 'wip', 'total_capacity',
             'total_produced', 'missed_op', 'utilization', 'efficiency']
    make_table name, num_teams, num_stations for name in names
    sim.summary.display(sim.teams)


make_table = (name, num_teams, num_stations) ->
    # name = capacity | produced wip | total_capacity | total_produced
    #        | missed_op | utilization | efficiency
    table = ljd.$ name + '_table'
    ljd.removeAllChildren table
    make_row = (index) ->
        # Returns a tr element with all td children
        team = sim.teams[index]
        tds = team.get_table_row name
        attrs = {className: 'team'}
        tds.unshift ljd.create 'td', attrs, ['T' + (index + 1)]
        ljd.create 'tr', tds
    # returns list of row nodes
    rows = map make_row, [0...num_teams]
    make_th = (i) ->
        ljd.create 'th', ['S' + (i + 1)]
    ths = map make_th, [0...num_stations]
    ths.unshift ljd.create 'th'
    if name == 'wip'
        ths.push ljd.create 'th', ['Total']
    h_row = ljd.create 'tr', ths
    head = ljd.create 'thead', [h_row]
    body = ljd.create 'tbody', rows
    ljd.add table, [head, body]


display = (step_num, teams) ->
    # Display state of stations and totals in all tables
    # tables: capacity, produced, wip, total_capacity, total_wips,
    # total_produced, missed_op, utilization, and efficiency
    ljd.setText(ljd.$('step_number_label'), step_num)
    for team in teams
        team.display(step_num)


sim.ready = ready
sim.map = map
sim.remove = remove
