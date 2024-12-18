const std = @import("std");

const assert = @import("./util.zig").assert;

const Rank = @import("./board.zig").Rank;
const File = @import("./board.zig").File;
const Move = @import("./move.zig").Move;
const Piece = @import("./board.zig").Piece;
const Board = @import("./board.zig").Board;
const Castle = @import("./board.zig").Castle;

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const Uci = struct {
    pub fn write_move(move: Move) !void {
        try stdout.print("{s}{s}{s}{s}\n", .{
            switch (File.of(move.from)) {
                .fa => "a",
                .fb => "b",
                .fc => "c",
                .fd => "d",
                .fe => "e",
                .ff => "f",
                .fg => "g",
                .fh => "h",
            },
            switch (Rank.of(move.from)) {
                .r1 => "1",
                .r2 => "2",
                .r3 => "3",
                .r4 => "4",
                .r5 => "5",
                .r6 => "6",
                .r7 => "7",
                .r8 => "8",
            },
            switch (File.of(move.to)) {
                .fa => "a",
                .fb => "b",
                .fc => "c",
                .fd => "d",
                .fe => "e",
                .ff => "f",
                .fg => "g",
                .fh => "h",
            },
            switch (Rank.of(move.to)) {
                .r1 => "1",
                .r2 => "2",
                .r3 => "3",
                .r4 => "4",
                .r5 => "5",
                .r6 => "6",
                .r7 => "7",
                .r8 => "8",
            },
        });
    }
    /// Need board for context to return well formed moves
    pub fn read_move(board: *const Board) Move {
        var buf: [5]u8 = undefined;

        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            assert(user_input[0] >= 'a');
            assert(user_input[0] <= 'h');
            assert(user_input[1] >= '1');
            assert(user_input[1] <= '8');
            assert(user_input[2] >= 'a');
            assert(user_input[2] <= 'h');
            assert(user_input[3] >= '1');
            assert(user_input[3] <= '8');
            const from = user_input[0] - 'a' + 8 * (user_input[1] - '1');
            const to = user_input[0] - 'a' + 8 * (user_input[1] - '1');

            const captured_piece: Piece = board.squares[to];
            const promoted_piece: Piece = switch (user_input[4]) {
                'N' => .white_knight,
                'B' => .white_bishop,
                'R' => .white_rook,
                'Q' => .white_queen,
                'n' => .black_knight,
                'b' => .black_bishop,
                'r' => .black_rook,
                'q' => .black_queen,
                else => .empty,
            };

            const en_passant_square: u8 = switch (board.side_to_move) {
                .white => if (Rank.of(from) == .r2 and Rank.of(to) == .r4 and board.square[from] == .white_pawn) from + 8 else 0,
                .black => if (Rank.of(from) == .r7 and Rank.of(to) == .r5 and board.square[from] == .black_pawn) from - 8 else 0,
            };
            const en_passant_capture: bool = board.en_passant == to and board.squares[from] == switch (board.side_to_move) {
                .white => .white_pawn,
                .black => .black_pawn,
            };

            const castle: Castle = switch (board.side_to_move) {
                .white => if (from == 4 and to == 6 and board.square[4] == .white_king)
                    .white_kingside
                else if (from == 4 and to == 2 and board.square[4] == .white_king)
                    .white_queenside
                else
                    .none,
                .black => if (from == 60 and to == 62 and board.square[60] == .black_king)
                    .black_kingside
                else if (from == 60 and to == 58 and board.square[60] == .black_king)
                    .black_queenside
                else
                    .none,
            };

            return .{
                .from = from,
                .to = to,
                .en_passant_capture = en_passant_capture,
                .en_passant_square = en_passant_square,
                .en_passant_square_past = board.en_passant,
                .captured = captured_piece,
                .promoted = promoted_piece,
                .fifty_move_past = board.fifty_move,
                .castle = castle,
                .castle_perm_past = board.castle,
            };
        } else {
            unreachable;
        }
    }
};
