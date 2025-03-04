const std = @import("std");

const Board = @import("./board.zig").Board;
const Piece = @import("./board.zig").Piece;
const Movelist = @import("./move.zig").Movelist;
const move_count_max = @import("./move.zig").move_count_max;
const Move = @import("./move.zig").Move;

const Uci = @import("./uci.zig").Uci;

// TODO: Follow Zig style guide https://ziglang.org/documentation/master/#Style-Guide (NEEDED!!!)
//
// TODO: Figure out how to make the directory structure for tests nicer
//  Seems to only be possible via simulation_test_uci.root_module.addImport(name: []const u8, module: *Module)
//
// TODO: Figure out if it makes sense to do all the logic for castling perms and the like in the moves / movegen or just have
//  moves be a from and to square and then do the logic in the makeMove function
//
//  Move as just u16 and do the state handling in makeMove
//
//  Magic bitboard but per move direction of piece not just for the whole thing
//
//  Make OpenCL kernel that unpacks bitboards to floats (12 * u64 + 1 u8 for 50 move vs 13 * 64 * 32 + 1 u8 for 15 move)
//
//  IDEAS: Have a mixture of experts type things for different size nets decided by a very small net (nnue net run on the cpu?)

pub fn main() !void {
    var board: Board = Board.alloc("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    var movelist: Movelist = .{ .move = undefined, .move_count = 0 };

    movelist.generate(&board);

    board.print();
    movelist.print();

    try Uci.write(movelist.move[3], board.side_to_move);
    const move: Move = Uci.read(board);
    move.print();
}
