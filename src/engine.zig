const std = @import("std");

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub const Engine = struct {
    pub fn loop() void {
        // if (stdin.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable) |user_input| {
        //     _ = user_input;
        //     return parse(board, buf);
        // } else {
        //     unreachable;
        // }
    }
};
