/** --------------------------------------------------------------------
 * Author:  Lyall Jonathan Di Trapani
 * Main simulation code
 */

window.onload = function() {
    $('num_teams').value = sim.num_teams;
    init_finals(sim.num_teams);
    setup();
};

// Global variables, only written to on setup
var teams = [];         // Only individual stations are updated
var sim = {
    num_teams: 3,       // Number of teams
    num_rolls: 20,      // Max number of rolls for round
    round_num: 1,       // Current round number
    roll_num: 0,        // Current roll number
    total_wip_tds: [],  // Table data elements for total WIPs
    final_wip: [],
    final_produced: [],
    inducted_wip: 100,  // How much total wip to induce on rounds >= 5
    lock_num_rolls: false       // Do not allow stepping past num_rolls
};

function show_div(name) {
    div = $(name)
    div.className = 'visible'
    names = ['config', 'run', 'results']
    names = remove(names, name)
    for (var i in names) {
        $(names[i]).className = 'invisible';
    }
}

function remove(list, el_to_remove) {
    var new_list = [];
    for (var i in list) {
        el = list[i];
        if (el === el_to_remove) {
            continue;
        }
        else {
            new_list.push(el);
        }
    }
    return new_list;
}

function setup() {
    /* Set-up simulation round based on configuration */
    var num_teams = parseInt($('num_teams').value);
    if (num_teams != sim.num_teams) {
        sim.num_teams = num_teams;
        init_finals(num_teams);
    }
    var num_stations = parseInt($('num_stations').value);
    sim.round_num = parseInt($('round_number').value);
    Station.prototype.round_num = sim.round_num;
    dom.set_text($('round_number_label'), sim.round_num);
    sim.num_rolls = parseInt($('num_rolls').value);
    sim.roll_num = 0;
    dom.set_text($('roll_number_label'), sim.roll_num);
    sim.inducted_wip = parseInt($('inducted_wip').value);
    generate_sim(num_teams, num_stations);
}

function generate_sim(num_teams, num_stations) {
    /* create stations, teams, and tables for simulation */
    teams = make_teams(num_teams, num_stations);
    fp.map(attach_prev_stations, teams);
    sim.total_wip_tds = make_total_wip_tds(num_teams);
    display();
    make_table('roll', num_teams, num_stations);
    make_table('wip', num_teams, num_stations);
    make_table('total_rolled', num_teams, num_stations);
    make_table('total_produced', num_teams, num_stations);
    display_final_table();
}

function make_teams(num_teams, num_stations) {
    function make_team(team_num) {
        return fp.map(make_station, fp.range(num_stations));
    }
    return fp.map(make_team, fp.range(num_teams));
}

function make_station(index) {
    var station_num = index + 1;
    // dice_count, min, max, wip
    var args = [1, 1, 6, 4];
    args = fix_args(args, sim.round_num, station_num);
    var s = new Station(station_num, args[0], args[1], args[2], args[3]);
    // roll_td, wip_td, total_rolled_td, total_produced_td
    var r = dom.create('td', {}, []);
    var w = dom.create('td', {}, []);
    var tr = dom.create('td', {}, []);
    var tp = dom.create('td', {}, []);
    s.add_tds(r, w, tr, tp)
    return s;
}

function fix_args(args, round_num, station_num) {
    if ((round_num >= 2) && (station_num != 3)) {
        args[0] = 2;    // If not station 3, us 2 dice
    }
    if ((round_num >= 4) && (station_num == 3)) {
        args[1] = 4;    // min roll = 4
        args[3] = 9;    // wip = 9
    }
    if ((round_num >= 5) && (station_num == 1)) {
        args[3] = sim.inducted_wip;
    }
    return args;
}

function attach_prev_stations(team) {
    for (var i in team) {
        if (i != 0) {
            team[i].prev = team[i - 1];
        }
    }   
}

function make_total_wip_tds(num_teams) {
    /* Create table data elements for total team WIP values */
    function f(i) {
        return dom.create('td', {}, []);
    }
    return fp.map(f, fp.range(num_teams));
}

function init_finals(num_teams) {
    sim.final_wip = [];
    sim.final_produced = [];
    function make_team_finals_for(name) {
        var team_vals = [];
        for (var j in fp.range(5)) {        // 5 rounds!
            team_vals.push(0);
        }
        sim['final_' + name].push(team_vals);
    }
    function make_team_finals(i) {
        fp.map(make_team_finals_for, ['wip', 'produced']);
    }
    fp.map(make_team_finals, fp.range(num_teams));
}

function display_final_table() {
    dom.removeAllChildren($('final_tbody'));
    dom.removeAllChildren($('final_thead'));
    var ths = [dom.create('th', {}, [])];
    function make_th(i) {
        ths.push(dom.create('th', {}, ["W" + (i + 1)]));
        ths.push(dom.create('th', {}, ["P" + (i + 1)]));
    }
    fp.map(make_th, fp.range(5));
    var h_row = dom.create('tr', {}, ths);
    dom.add($('final_thead'), [h_row]);
    function make_row(i) {
        var attrs = {className: 'team'};
        var tds = [dom.create('td', attrs, ['T' + (i + 1)])];
        function make_td(j) {
            var wip = sim.final_wip[i][j];
            var produced = sim.final_produced[i][j];
            tds.push(dom.create('td', {}, [dom.t(wip)]));
            tds.push(dom.create('td', {}, [dom.t(produced)]));
        }
        fp.map(make_td, fp.range(5)); // 5 rounds!
        return dom.create('tr', {}, tds);
    }
    var rows = fp.map(make_row, fp.range(teams.length));
    dom.add($('final_tbody'), rows);
}

function make_table(name, num_teams, num_stations) {
    var table = $(name + '_table');
    dom.removeAllChildren(table);
    function make_row(index) {
        // Returns a tr element with all td children
        var team = teams[index];
        var tds = fp.map(function(s) { return s[name + '_td']; }, team);
        var attrs = {className: 'team'};
        tds.unshift(dom.create('td', attrs, ['T' + (index + 1)]));
        // if wip, then add total wip td to tds
        if (name == 'wip') {
            tds.push(sim.total_wip_tds[index]);
        }
        return dom.create('tr', {}, tds);
    }
    // returns list of row nodes
    var rows = fp.map(make_row, fp.range(num_teams));
    function make_th(i) {
        return dom.create('th', {}, ['S' + (i + 1)]);
    }
    var ths = fp.map(make_th, fp.range(num_stations));
    ths.unshift(dom.create('th', {}, []));
    if (name == 'wip') {
        ths.push(dom.create('th', {}, ['Total']));
    }
    var h_row = dom.create('tr', {}, ths);
    var head = dom.create('thead', {}, [h_row]);
    var body = dom.create('tbody', {}, rows);
    dom.add(table, [head, body]);
}

function step_() {
    /* Execute one step (roll) of the current round & display results
     * step is reserved in firefox, must use step_ */
    if (sim.lock_num_rolls && sim.roll_num == sim.num_rolls) {
        return;
    }
    // step data
    step_data();
    // step display
    display();
    display_final_table();
}

function step_data() {
    /* Execute one step (roll) of the current round (do not display) */
    // If on round 5 & no more wip to induce, move a dice from s1 to s3
    if (sim.round_num >= 5) {
        for (var i in teams) {
            var team = teams[i];
            var s1 = team[0];
            if (s1.wip == 0) {
                var s3 = team[2];
                s1.dice_count = 1;
                s3.dice_count = 2;
            }
        }
    }
    // roll all
    team_map('roll_dice', teams);
    // fix s1 roll == s3 roll if necessary (round # == 3 or 4)
    if (sim.round_num == 3 || sim.round_num == 4) {
        for (var i in teams) {
            var team = teams[i];
            var s1 = team[1 - 1];   // station 1
            var s3 = team[3 - 1];   // station 3
            s1.roll = s3.roll;
        }
        
    }
    // update stations of teams (wip, produced, tr, tp)
    team_map('update', teams);
    // display roll, total_rolled, total_produced, curr_wip, total_wips
    sim.roll_num += 1;
    // udpate final_wip, fr, fp
    if (sim.roll_num == sim.num_rolls) {
        update_finals();
    }
}

function get_total_wip(team) {
    function add(sum, station) {
        return sum + station.wip;
    }
    return fp.reduce(add, team.slice(1), 0);
}

function update_finals() {
    if (sim.round_num > 5 || sim.round_num < 1) {
        return;
    }
    function get_total_produced(team) {
        return team[team.length - 1].total_produced;
    }
    function update_team_finals(team_index) {
        var round_index = sim.round_num - 1;
        var team = teams[team_index];
        var total_wip = get_total_wip(team);
        sim.final_wip[team_index][round_index] = total_wip;
        var total_produced = get_total_produced(team);
        sim.final_produced[team_index][round_index] = total_produced;
    }
    fp.map(update_team_finals, fp.range(teams.length));
}

function simulate() {
    /* Run all steps in simulation and display final results */
    for (var i in fp.range(sim.roll_num, sim.num_rolls)) {
        step_data();
    }
    display();
    display_final_table();
}

function display() {
    /* Display state of stations and totals in all tables
     * tables: roll, total_rolled, total_produced, curr_wip, total_wips
     */
    dom.set_text($('roll_number_label'), sim.roll_num);
    team_map('display', teams);
    // display wip totals (do not count station 1 wip!)
    function f(i) {
        var team = teams[i];
        dom.set_text(sim.total_wip_tds[i], get_total_wip(team));
    }
    fp.map(f, fp.range(sim.total_wip_tds.length));
}

function team_map(f, teams) {
    function call_f(station) {
        return station[f]();
    }
    function station_map(team) {
        return fp.map(call_f, team);
    }
    return fp.map(station_map, teams);
}
