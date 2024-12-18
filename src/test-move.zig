const std = @import("std");

const assert = @import("./util.zig").assert;

const Board = @import("./board.zig").Board;
const square_count = @import("./board.zig").square_count;
const fen_start = @import("./board.zig").fen_start;
const Movelist = @import("./move.zig").Movelist;
const Move = @import("./move.zig").Move;

const Pcg = @import("./prng.zig").Pcg;

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
        .fifty_move_past = 0,
        .castle = .none,
        .castle_perm_past = 0,
    };

    var movelist_saved: [move_num]Move = [1]Move{move_empty} ** move_num;
    var move_played: usize = 0;
    for (0..move_num) |movelist_idx| {
        movelist.clear();
        movelist.generate(board);

        if (board.result(&movelist) != .none) {
            break;
        }

        const move_idx: u32 = Pcg.rand_below(movelist.move_count);
        movelist_saved[movelist_idx] = movelist.move[move_idx];

        board.make_move(movelist.move[move_idx]);

        move_played = movelist_idx + 1;
    }
    for (0..move_played) |movelist_idx| {
        board.undo_move(movelist_saved[move_played - (movelist_idx + 1)]);
    }

    assert(starting.castle == board.castle);
    assert(starting.en_passant == board.en_passant);
    assert(starting.side_to_move == board.side_to_move);
    assert(starting.fifty_move == board.fifty_move);
    for (0..square_count) |square_idx| {
        assert(starting.squares[square_idx] == board.squares[square_idx]);
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

    var starting: Board = Board.alloc(fen_start);
    var board: Board = Board.alloc(fen_start);
    if (loop_infinite) {
        var loop_idx: u64 = 0;
        // TODO: Decide how to reseed the random number generator here...
        // rng + loop_idx "wastes" the least seeds but it could cause issues
        // when running multiple threads with this because you then run the same tests over and over again
        while (true) {
            std.debug.print("[{}] => ", .{loop_idx});
            simulate_moves(&starting, &board, move_num, rng + loop_idx);
            loop_idx += 1;
        }
    } else {
        for (0..loop_count) |loop_idx| {
            std.debug.print("[{}] => ", .{loop_idx});
            simulate_moves(&starting, &board, move_num, rng + loop_idx);
        }
    }
}
