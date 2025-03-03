const std = @import("std");
const assert = std.debug.assert;

const Board = @import("./board.zig").Board;
const Movelist = @import("./move.zig").Movelist;
const Move = @import("./move.zig").Move;

const Uci = @import("./uci.zig").Uci;

const Pcg = @import("./prng.zig").Pcg;

/// Ensure that playing random moves and then undoing them results in the starting position
fn simulateUci(board: *Board, comptime move_num: u32, rng: u64) void {
    std.debug.print("rng={}", .{rng});

    Pcg.init(rng);
    board.readFen(Board.fen_start);
    var movelist: Movelist = .{ .move = undefined, .move_count = 0 };

    for (0..move_num) |_| {
        movelist.clear();
        movelist.generate(board);

        if (board.result(movelist) != .none) {
            break;
        }

        for (0..movelist.move_count) |move_idx| {
            const expected: Move = movelist.move[move_idx];
            const encoded: [5]u8 = Uci.encode(expected, board.side_to_move);
            const decoded: Move = Uci.parse(board.*, encoded);
            // board.debug();
            // expected.print();
            // decoded.print();
            // std.debug.print("\n", .{});

            assert(decoded.fromSq() == expected.fromSq());
            assert(decoded.toSq() == expected.toSq());
            assert(decoded.flag() == expected.flag());
        }

        const move_idx: u32 = Pcg.randBelow(movelist.move_count);
        board.makeMove(movelist.move[move_idx]);
    }

    std.debug.print(" passed\n", .{});
}

// TODO: Move tests to seperate directory

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    var rng_saved: ?u64 = null;
    var loop_infinite: bool = false;
    var loop_count: u64 = 1;
    // Skip the executable call
    _ = args.next();
    if (args.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "rng=")) {
            const offset = "rng="[0..].len;
            rng_saved = try std.fmt.parseInt(u64, arg[offset..], 10);
        } else if (std.mem.startsWith(u8, arg, "loop=")) {
            const offset = "loop="[0..].len;
            loop_count = std.fmt.parseInt(u64, arg[offset..], 10) catch 0;
            if (loop_count == 0) {
                loop_infinite = true;
            }
            // Iff the loop is infinite then the loop count has to be 0
            assert(loop_infinite == (loop_count == 0));
        } else {
            std.log.err("Found unrecognised option `{s}`, expected `rng=<number>` or `loop=[number].\n", .{arg});
            assert(false);
        }
    }
    const rng: u64 = if (rng_saved) |rng_val| rng_val else @bitCast(std.time.microTimestamp());

    const move_num: u32 = 200;
    comptime {
        assert(move_num > 0);
    }

    var board: Board = Board.alloc(Board.fen_start);
    if (loop_infinite) {
        var loop_idx: u64 = 0;
        // TODO: Decide how to reseed the random number generator here...
        // rng + loop_idx "wastes" the least seeds but it could cause issues
        // when running multiple threads with this because you then run the same tests over and over again
        while (true) {
            std.debug.print("[{}] => ", .{loop_idx});
            simulateUci(&board, move_num, rng + loop_idx);
            loop_idx += 1;
        }
    } else {
        for (0..loop_count) |loop_idx| {
            std.debug.print("[{}] => ", .{loop_idx});
            simulateUci(&board, move_num, rng + loop_idx);
        }
    }
}
