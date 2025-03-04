const std = @import("std");
const assert = std.debug.assert;

pub inline fn maybe(ok: bool) void {
    assert(ok or !ok);
}

pub fn Timer(timers: comptime_int) type {
    return struct {
        var ns_total: [timers]i128 = undefined;
        var ns_count: [timers]i128 = undefined;
        var ns_temp: [timers]i128 = undefined;
        /// Start timer with provided id. Will crash if you try to start an already running timer.
        pub fn start(timer_id: u32) void {
            assert(timer_id < timers);
            assert(ns_temp[timer_id] == 0);
            ns_temp[timer_id] = std.time.nanoTimestamp();
        }
        /// Stop timer with provided id and add elapsed to total time, also increments count by 1.
        /// If you try to stop a timer which wasn't started it will crash.
        pub fn stop(timer_id: u32) void {
            assert(timer_id < timers);
            assert(ns_temp[timer_id] != 0);
            ns_total[timer_id] += std.time.nanoTimestamp() - ns_temp[timer_id];
            ns_count[timer_id] += 1;
            ns_temp[timer_id] = 0;
        }
        /// Reset the count and total time to 0 for the timer with the provided id.
        /// Will crash if the timer is currently running.
        pub fn reset(timer_id: u32) void {
            assert(timer_id < timers);
            assert(ns_temp[timer_id] == 0);
            ns_total[timer_id] = 0;
            ns_count[timer_id] = 0;
            ns_temp[timer_id] = 0;
        }
        /// Total time elapsed in nanoseconds for timer with provided id.
        /// A timer has to be stoped to have its time count to the total.
        pub fn totalNs(timer_id: u32) i128 {
            assert(timer_id < timers);
            return ns_total[timer_id];
        }
        /// Total number of times the timer with provided id has written its time to total.
        pub fn totalCount(timer_id: u32) i128 {
            assert(timer_id < timers);
            return ns_count[timer_id];
        }
        /// Return wether the timer is currently running.
        /// Realised by checking wether the temporary buffer has a time other than 0.
        pub fn isRunning(timer_id: u32) bool {
            assert(timer_id < timers);
            return ns_temp[timer_id] != 0;
        }
    };
}
