const std = @import("std");

const assert = @import("./util.zig").assert;

const Board = @import("./board.zig").Board;
const square_count = @import("./board.zig").square_count;
const fen_start = @import("./board.zig").fen_start;
const Movelist = @import("./move.zig").Movelist;
const Move = @import("./move.zig").Move;

var state: u64 = 0;
const mult: u64 = 6364136223846793005;
const incr: u64 = 1442695040888963407;

/// This implementation was tested using PractRand [https://www.pcg-random.org/posts/how-to-test-with-practrand.html] up to 1 TB and it found no statistical anomalies.
pub const Pcg = struct {
    fn rotate_32(x: u32, pivot: u5) u32 {
        return x >> pivot | x << ((-%pivot) & 31);
    }
    pub fn init(x: u64) void {
        state = x;
    }
    pub fn rand() u32 {
        var x: u64 = state;
        const pivot: u5 = @truncate(x >> 59);

        state = state *% mult +% incr;
        x ^= x >> 18;
        return Pcg.rotate_32(@truncate(x >> 27), pivot);
    }
    pub fn rand_below(top: u32) u32 {
        if (top == 0 or top == 1) {
            return 0;
        }
        var x: u32 = Pcg.rand();
        var m: u64 = @as(u64, x) *% @as(u64, top);
        var l: u32 = @truncate(m);
        if (l < top) {
            var t: u32 = -%top;
            if (t > top) {
                t -= top;
                if (t >= top) {
                    t %= top;
                }
            }
            while (l < t) {
                x = Pcg.rand();
                m = @as(u64, x) *% @as(u64, top);
                l = @truncate(m);
            }
        }
        return @truncate(m >> 32);
    }
};

/// Ensure that playing random moves and then undoing them results in the starting position
fn simulate_moves(starting: *Board, board: *Board, comptime move_num: u32, rng: u64) void {
    std.debug.print("rng={}", .{rng});
    Pcg.init(rng);
    var movelist: Movelist = Movelist.init();
    starting.copy_to(board);

    const move_empty: Move = .{
        .from = 0,
        .to = 0,
        .en_passant_capture = false,
        .en_passant_square = 0,
        .en_passant_square_past = 0,
        .captured = .empty,
        .promoted = .empty,
    };

    var movelist_saved: [move_num]Move = [1]Move{move_empty} ** move_num;
    for (0..move_num) |movelist_idx| {
        movelist.clear();
        movelist.generate(board);
        const move_idx: u32 = Pcg.rand_below(movelist.move_count);
        movelist_saved[movelist_idx] = movelist.move[move_idx];
        board.make_move(movelist.move[move_idx]);
    }
    for (0..move_num) |movelist_idx| {
        board.undo_move(movelist_saved[move_num - (movelist_idx + 1)]);
    }
    assert(starting.castle == board.castle);
    assert(starting.en_passant == board.en_passant);
    assert(starting.side_to_move == board.side_to_move);
    assert(starting.fifty_move == board.fifty_move);
    for (0..square_count) |square_idx| {
        assert(starting.squares[square_idx] == board.squares[square_idx]);
    }
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
    const rng: u64 = switch (rng_saved == null) {
        true => @bitCast(std.time.microTimestamp()),
        false => rng_saved.?,
    };

    const move_num: u32 = 20;
    comptime {
        assert(move_num > 0);
    }

    var starting: Board = Board.alloc(fen_start);
    var board: Board = Board.alloc(fen_start);
    if (loop_infinite) {
        var loop_idx: u64 = 0;
        // TODO: Decide how to reseed the random number generator here...
        // rng + loop_idx "wastes" the least seeds but it could cause issues
        // when running multiple threads with this because you then run the same tests over and over again
        while (true) {
            std.debug.print("{} => ", .{loop_idx});
            simulate_moves(&starting, &board, move_num, rng + loop_idx);
            loop_idx += 1;
        }
    } else {
        for (0..loop_count) |loop_idx| {
            std.debug.print("{} => ", .{loop_idx});
            simulate_moves(&starting, &board, move_num, rng + loop_idx);
        }
    }
}
