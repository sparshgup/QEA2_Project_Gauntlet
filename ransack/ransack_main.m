clear all; close all;

rng(1,'philox')
[map_x, map_y] = get_map();
state = SackState.FromGlobal(map_x, map_y);
state.sack_multi();ls 
