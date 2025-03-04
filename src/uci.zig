const std = @import("std");
const assert = std.debug.assert;

const Rank = @import("./board.zig").Rank;
const File = @import("./board.zig").File;
const Piece = @import("./board.zig").Piece;
const Board = @import("./board.zig").Board;
const Castle = @import("./board.zig").Castle;
const Color = @import("./board.zig").Color;

const Move = @import("./move.zig").Move;

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub const Uci = struct {
    pub const uci_string_len = 5;
    pub fn encode(move: Move, side_to_move: Color) [uci_string_len]u8 {
        return [uci_string_len]u8{
            switch (File.of(move.fromSq())) {
                .fa => 'a',
                .fb => 'b',
                .fc => 'c',
                .fd => 'd',
                .fe => 'e',
                .ff => 'f',
                .fg => 'g',
                .fh => 'h',
            },
            switch (Rank.of(move.fromSq())) {
                .r1 => '1',
                .r2 => '2',
                .r3 => '3',
                .r4 => '4',
                .r5 => '5',
                .r6 => '6',
                .r7 => '7',
                .r8 => '8',
            },
            switch (File.of(move.toSq())) {
                .fa => 'a',
                .fb => 'b',
                .fc => 'c',
                .fd => 'd',
                .fe => 'e',
                .ff => 'f',
                .fg => 'g',
                .fh => 'h',
            },
            switch (Rank.of(move.toSq())) {
                .r1 => '1',
                .r2 => '2',
                .r3 => '3',
                .r4 => '4',
                .r5 => '5',
                .r6 => '6',
                .r7 => '7',
                .r8 => '8',
            },
            switch (side_to_move) {
                .white => switch (move.flag()) {
                    .promote_queen => 'Q',
                    .promote_rook => 'R',
                    .promote_knight => 'N',
                    .promote_bishop => 'B',
                    else => '\x00',
                },
                .black => switch (move.flag()) {
                    .promote_queen => 'q',
                    .promote_rook => 'r',
                    .promote_knight => 'n',
                    .promote_bishop => 'b',
                    else => '\x00',
                },
            },
        };
    }
    pub fn write(move: Move, side_to_move: Color) !void {
        try stdout.print("{s}\n", .{encode(move, side_to_move)});
    }
    /// Split because this part is tested sepperately
    pub fn parse(board: Board, buffer: [uci_string_len]u8) Move {
        assert(buffer[0] >= 'a');
        assert(buffer[0] <= 'h');
        assert(buffer[1] >= '1');
        assert(buffer[1] <= '8');
        assert(buffer[2] >= 'a');
        assert(buffer[2] <= 'h');
        assert(buffer[3] >= '1');
        assert(buffer[3] <= '8');

        const from = buffer[0] - 'a' + 8 * (buffer[1] - '1');
        const to = buffer[2] - 'a' + 8 * (buffer[3] - '1');

        const flags: Move.Flag = switch (buffer[4]) {
            'N', 'n' => .promote_knight,
            'B', 'b' => .promote_bishop,
            'R', 'r' => .promote_rook,
            'Q', 'q' => .promote_queen,
            else => switch (board.side_to_move) {
                .white => if (from == 4 and to == 6 and board.squares[4] == .white_king)
                    .castle_kingside
                else if (from == 4 and to == 2 and board.squares[4] == .white_king)
                    .castle_queenside
                else
                    .none,
                .black => if (from == 60 and to == 62 and board.squares[60] == .black_king)
                    .castle_kingside
                else if (from == 60 and to == 58 and board.squares[60] == .black_king)
                    .castle_queenside
                else
                    .none,
            },
        };

        return Move.create(from, to, flags);
    }
    /// Need board for context to return well formed moves
    pub fn read(board: Board) Move {
        var buf: [uci_string_len]u8 = undefined;

        if (stdin.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable) |user_input| {
            _ = user_input;
            return parse(board, buf);
        } else {
            unreachable;
        }
    }
};
