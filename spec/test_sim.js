/** --------------------------------------------------------------------
 * Author:  Lyall Jonathan Di Trapani
 * sim unit tests
 */

// Create a special test name space
function test_name_space() {

window.onload = function()
{
    var names = [
        'test_are_arrays_equal',
        'test_map',
        'test_range',
        'test_range2',
        'test_reduce',
        'test_Station_roll_die',
        'test_Station_roll_dice',
        'test_Station_update_roll_high',
        'test_Station_update_roll_low',
        'test_make_teams_r1',
        'test_make_teams_r2',
        'test_make_teams_r3',
        'test_make_teams_r4'];
    for (i in names) {
        run_test(eval(names[i]), names[i]);
    }
};

function test_are_arrays_equal() {
    var t1 = are_arrays_equal([1,2,3], [1,2,3]);
    var t2 = ! are_arrays_equal([1,2,3], [1,2,3,4]);
    return t1 && t2;
}

function are_arrays_equal(a, b) {
    function num_keys(a) {
        var i = 0;
        for (key in a) {
            i++;
        }
        return i;
    }
    if (a == b) {
        return true;
    }   
    if (num_keys(a) != num_keys(b)) {
        return false;
    }
    for (key in a) {     
        if (a[key] != b[key]) {
            return false;
        }
    }
    return true;
}

function test_map() {
    function square(x) { return x * x; }
    var result = fp.map(square, [1,2,3,4,5]);
    return are_arrays_equal(result, [1,4,9,16,25]);
}

function test_range() {
    return are_arrays_equal(fp.range(6), [0,1,2,3,4,5]);
}

function test_range2() {
    return are_arrays_equal(fp.range(4, 6), [4,5]);
}

function test_reduce() {
    function add(a, b) { return a + b; }
    var sum = fp.reduce(add, fp.range(20), 7);
    return sum == 7 + 190;
}

function make_station(dice_count, wip) {
    function r() { return 0.999;};
    //         Station(dice_count, min, max, wip, random)
    return new Station(2, dice_count, 1, 6, wip, r);
}

function run_test(test, name) {
    if (test()) {
        var s = 'pass';
    }
    else {
        var s = 'FAIL';
    }
    addOut(s + ' (' + name + ')');
}

function test_Station_roll_die() {
    function r() { return 0.999;};
    return make_station(1, 4).roll_die() == 6;
}

function test_Station_roll_dice() {
    var s = make_station(2, 4);
    s.roll_dice();
    return s.roll == 12;
}

function test_Station_update_roll_high() {
    return run_update_test(4, 3, 4, 5 + 4);
}

function test_Station_update_roll_low() {
    return run_update_test(20, 8 + 3, 12, 5 + 12);
}

function run_update_test(start_wip, exp_wip, exp_prod, exp_tp) {
    var s = make_station(2, start_wip);
    var prev = {produced: 3};
    s.prev = prev;
    s.total_rolled = 7;
    s.total_produced = 5;
    s.roll_dice();
    s.update();
    var wip = s.wip == exp_wip;
    var prod = s.produced == exp_prod;
    var tp = s.total_produced == exp_tp;
    var tr = s.total_rolled == 7 + 12;
    return wip && prod && tp && tr;
}

function test_make_teams_r1() {
    var round_num = 1;
    var num_teams = 2;
    var num_stations = 5;
    var teams = run_team_test(round_num, num_teams, num_stations);
    var a = check_dimensions(teams, num_teams, num_stations);
    var b = check_teams_attr(teams, [1,2,3,4,5], 'dice_count', 1);
    var c = check_teams_attr(teams, [1,2,3,4,5], 'wip', 4);
    var d = check_teams_attr(teams, [1,2,3,4,5], 'min', 1);
    var e = check_teams_attr(teams, [1,2,3,4,5], 'range', 6);
    return a && b && c && d && e;
}

function test_make_teams_r2() {
    var round_num = 2;
    var num_teams = 3;
    var num_stations = 6;
    var teams = run_team_test(round_num, num_teams, num_stations);
    var a = check_dimensions(teams, num_teams, num_stations);
    var b = check_teams_attr(teams, [1,2,4,5,6], 'dice_count', 2);
    var c = check_teams_attr(teams, [1,2,3,4,5,6], 'wip', 4);
    var d = check_teams_attr(teams, [1,2,3,4,5,6], 'min', 1);
    var e = check_teams_attr(teams, [1,2,3,4,5,6], 'range', 6);
    var f = check_teams_attr(teams, [3], 'dice_count', 1);
    return a && b && c && d && e && f;
}

function test_make_teams_r3() {
    var round_num = 3;
    var num_teams = 2;
    var num_stations = 4;
    var teams = run_team_test(round_num, num_teams, num_stations);
    var a = check_dimensions(teams, num_teams, num_stations);
    var b = check_teams_attr(teams, [1,2,4], 'dice_count', 2);
    var c = check_teams_attr(teams, [1,2,3,4], 'wip', 4);
    var d = check_teams_attr(teams, [1,2,3,4], 'min', 1);
    var e = check_teams_attr(teams, [1,2,3,4], 'range', 6);
    var f = check_teams_attr(teams, [3], 'dice_count', 1);
    return a && b && c && d && e && f;
}

function test_make_teams_r4() {
    var round_num = 4;
    var num_teams = 2;
    var num_stations = 4;
    var teams = run_team_test(round_num, num_teams, num_stations);
    var a = check_dimensions(teams, num_teams, num_stations);
    var b = check_teams_attr(teams, [1,2,4], 'dice_count', 2);
    var c = check_teams_attr(teams, [1,2,4], 'wip', 4);
    var d = check_teams_attr(teams, [1,2,4], 'min', 1);
    var e = check_teams_attr(teams, [1,2,4], 'range', 6);
    var f = check_teams_attr(teams, [3], 'dice_count', 1);
    var g = check_teams_attr(teams, [3], 'min', 4);
    var h = check_teams_attr(teams, [3], 'wip', 9);
    var e = check_teams_attr(teams, [3], 'range', 3);
    return a && b && c && d && e && f && g && h && e;
}

function run_team_test(round_num, num_teams, num_stations) {
    sim.round_num = round_num;
    return make_teams(num_teams, num_stations);
}

function check_dimensions(teams, num_teams, num_stations) {
    var a = teams.length == num_teams;
    var b = teams[teams.length - 1].length == num_stations;
    return a && b;
}

function check_teams_attr(teams, station_nums, attr, exp_val) {
    for (var i in teams) {
        var team = teams[i];
        if (!check_stations_attr(team, station_nums, attr, exp_val)) {
            return false;
        }
    }
    return true;
}

function check_stations_attr(team, station_nums, attr, exp_val) {
    for (var i in station_nums) {
        var station_num = station_nums[i];
        var station = team[station_num - 1];
        if (station[attr] != exp_val) {
            return false;
        }
    }
    return true;
}


}

test_name_space();
