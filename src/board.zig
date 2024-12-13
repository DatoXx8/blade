const assert = @import("./util.zig").assert;

const Move = @import("./move.zig").Move;
const Movelist = @import("./move.zig").Movelist;
const move_count_max = @import("./move.zig").move_count_max;

pub const Color = enum(u1) {
    white,
    black,
};
pub const Result = enum(u4) {
    white,
    black,
    draw,
    none,
};
pub const Piece = enum(u4) {
    empty,
    white_pawn,
    white_knight,
    white_bishop,
    white_rook,
    white_queen,
    white_king,
    black_pawn,
    black_knight,
    black_bishop,
    black_rook,
    black_queen,
    black_king,
    pub fn is_white(this: @This()) bool {
        return this == .white_pawn or this == .white_knight or
            this == .white_bishop or this == .white_rook or
            this == .white_queen or this == .white_king;
    }
    pub fn is_black(this: @This()) bool {
        return this == .black_pawn or this == .black_knight or
            this == .black_bishop or this == .black_rook or
            this == .black_queen or this == .black_king;
    }
    pub fn is_white_diagonal(this: @This()) bool {
        return this == .white_bishop or this == .white_queen;
    }
    pub fn is_black_diagonal(this: @This()) bool {
        return this == .black_bishop or this == .black_queen;
    }
    pub fn is_white_slide(this: @This()) bool {
        return this == .white_rook or this == .white_queen;
    }
    pub fn is_black_slide(this: @This()) bool {
        return this == .black_rook or this == .black_queen;
    }
};

/// TODO: This
/// Accessed through (castle << @intFromEnum(...))
pub const Castle = enum(u4) {
    none,
    white_kingside,
    white_queenside,
    black_kingside,
    black_queenside,
};

pub const File = enum(u8) {
    fa = 0,
    fb = 1,
    fc = 2,
    fd = 3,
    fe = 4,
    ff = 5,
    fg = 6,
    fh = 7,
    pub fn of(square_idx: u8) File {
        return @enumFromInt(square_idx % 8);
    }
};
pub const Rank = enum(u8) {
    r1 = 0,
    r2 = 1,
    r3 = 2,
    r4 = 3,
    r5 = 4,
    r6 = 5,
    r7 = 6,
    r8 = 7,
    pub fn of(square_idx: u8) Rank {
        return @enumFromInt(square_idx / 8);
    }
};

pub const fen_start: []const u8 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
pub const square_count: u8 = 64;
pub const Board = struct {
    squares: [square_count]Piece,
    /// Index of the square on which en passant is possible, 0 if not possible, because that value can not be a valid square for en passant
    en_passant: u8,
    /// Counted in half-moves
    fifty_move: u8,
    castle: u8,
    side_to_move: Color,
    pub fn alloc(fen: ?[]const u8) Board {
        var board: Board = .{
            .squares = .{.empty} ** 64,
            .en_passant = 0,
            .fifty_move = 0,
            .castle = 0,
            .side_to_move = .white,
        };
        if (fen) |f| {
            board.read_fen(f);
        } else {
            board.read_fen(fen_start);
        }
        return board;
    }
    pub fn read_fen(this: *@This(), fen: []const u8) void {
        var offset: usize = 0;
        // At most 1 letter per square + 7 '/' charachters
        const piece_info_char_max: usize = 71;
        // Super hacky parsing. Necessary to have a1 be the square at index 0 and preserving an intuitive represenation when printing
        var board_idx: usize = 56;
        for (0..piece_info_char_max) |char_idx| {
            switch (fen[char_idx]) {
                'P' => {
                    this.squares[board_idx] = .white_pawn;
                    board_idx += 1;
                },
                'p' => {
                    this.squares[board_idx] = .black_pawn;
                    board_idx += 1;
                },
                'N' => {
                    this.squares[board_idx] = .white_knight;
                    board_idx += 1;
                },
                'n' => {
                    this.squares[board_idx] = .black_knight;
                    board_idx += 1;
                },
                'B' => {
                    this.squares[board_idx] = .white_bishop;
                    board_idx += 1;
                },
                'b' => {
                    this.squares[board_idx] = .black_bishop;
                    board_idx += 1;
                },
                'R' => {
                    this.squares[board_idx] = .white_rook;
                    board_idx += 1;
                },
                'r' => {
                    this.squares[board_idx] = .black_rook;
                    board_idx += 1;
                },
                'Q' => {
                    this.squares[board_idx] = .white_queen;
                    board_idx += 1;
                },
                'q' => {
                    this.squares[board_idx] = .black_queen;
                    board_idx += 1;
                },
                'K' => {
                    this.squares[board_idx] = .white_king;
                    board_idx += 1;
                },
                'k' => {
                    this.squares[board_idx] = .black_king;
                    board_idx += 1;
                },
                '1' => board_idx += 1,
                '2' => board_idx += 2,
                '3' => board_idx += 3,
                '4' => board_idx += 4,
                '5' => board_idx += 5,
                '6' => board_idx += 6,
                '7' => board_idx += 7,
                '8' => board_idx += 8,
                '/' => {
                    board_idx -= 16;
                    offset += 1;
                    continue;
                },
                ' ' => {
                    offset += 1;
                    break;
                },
                else => {
                    assert(false);
                },
            }
            offset += 1;
        }

        switch (fen[offset]) {
            'w' => this.side_to_move = .white,
            'b' => this.side_to_move = .black,
            else => assert(false),
        }

        offset += 2;
        var offset_temp: usize = 0;
        const castle_info_char_max: usize = 4;
        for (0..castle_info_char_max) |char_idx| {
            offset_temp = char_idx + 1;
            switch (fen[offset + char_idx]) {
                'K' => this.castle |= 1 << @intFromEnum(Castle.white_kingside),
                'k' => this.castle |= 1 << @intFromEnum(Castle.black_kingside),
                'Q' => this.castle |= 1 << @intFromEnum(Castle.white_queenside),
                'q' => this.castle |= 1 << @intFromEnum(Castle.black_queenside),
                '-' => {
                    this.castle = 0;
                    break;
                },
                else => assert(false),
            }
        }

        offset += offset_temp + 1;
        if (fen[offset] == '-') {
            this.en_passant = 0;
            offset += 2;
        } else {
            assert(fen[offset] >= 'a');
            assert(fen[offset] <= 'h');
            assert(fen[offset + 1] >= '1');
            assert(fen[offset + 1] <= '8');
            this.en_passant = fen[offset] - 'a' + (fen[offset + 1] - '1') * 8;
            offset += 3;
        }

        this.fifty_move = 0;
        for (offset..fen.len) |char_idx| {
            if (fen[char_idx] == ' ') {
                break;
            }
            this.fifty_move *= 10;
            this.fifty_move += fen[char_idx] - '0';
        }
    }
    pub fn make_move(this: *@This(), move: Move) void {
        assert(this.fifty_move < 100);
        assert(this.squares[move.to] == move.captured);
        if (move.en_passant_capture) {
            this.squares[move.to] = this.squares[move.from];
            this.squares[move.from] = .empty;
            if (this.side_to_move == .white) {
                this.squares[move.to - 8] = .empty;
            } else {
                this.squares[move.to + 8] = .empty;
            }
        } else {
            if (move.promoted == .empty) {
                this.squares[move.to] = this.squares[move.from];
            } else {
                this.squares[move.to] = move.promoted;
            }
            this.squares[move.from] = .empty;
        }
        this.side_to_move = switch (this.side_to_move) {
            .white => .black,
            .black => .white,
        };
        // This is 0 in case en passant is not possible
        this.en_passant = move.en_passant_square;
        // this.castle = move.castle_perm;
        this.fifty_move += 1;
    }
    pub fn undo_move(this: *@This(), move: Move) void {
        assert(this.squares[move.from] == .empty);
        if (move.en_passant_capture) {
            if (this.side_to_move == .black) {
                this.squares[move.from] = .white_pawn;
                this.squares[move.to] = .empty;
                this.squares[move.to - 8] = .black_pawn;
            } else {
                this.squares[move.from] = .black_pawn;
                this.squares[move.to] = .empty;
                this.squares[move.to + 8] = .white_pawn;
            }
        } else {
            if (move.promoted == .empty) {
                this.squares[move.from] = this.squares[move.to];
            } else {
                this.squares[move.from] = switch (this.side_to_move) {
                    .white => .black_pawn,
                    .black => .white_pawn,
                };
            }
            this.squares[move.to] = move.captured;
        }
        this.side_to_move = switch (this.side_to_move) {
            .white => .black,
            .black => .white,
        };
        this.en_passant = move.en_passant_square_past;
        // this.castle = move.castle_perm_past;
        this.fifty_move -= 1;
    }
    pub fn copy_to(this: *const @This(), target: *Board) void {
        target.castle = this.castle;
        target.en_passant = this.en_passant;
        target.side_to_move = this.side_to_move;
        target.fifty_move = this.fifty_move;
        for (0..square_count) |square_idx| {
            target.squares[square_idx] = this.squares[square_idx];
        }
    }
    /// Check if the player `color` is in check
    pub fn is_check(this: *const @This(), color: Color) bool {
        if (color == .white) {
            var square_king: u8 = 64;
            for (0..square_count) |square_idx| {
                if (this.squares[square_idx] == .white_king) {
                    square_king = @truncate(square_idx);
                    break;
                }
            }
            assert(square_king < 64);

            if (File.of(square_king) != .fa and this.squares[square_king - 1] == .black_king) {
                return true;
            }
            if (File.of(square_king) != .fh and this.squares[square_king + 1] == .black_king) {
                return true;
            }
            if (Rank.of(square_king) != .r8) {
                if (this.squares[square_king + 8] == .black_king) {
                    return true;
                }
                if (File.of(square_king) != .fa) {
                    if (this.squares[square_king + 7] == .black_pawn) {
                        return true;
                    }
                    if (File.of(square_king) != .fb and this.squares[square_king + 6] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_king + 7] == .black_king) {
                        return true;
                    }
                }
                if (File.of(square_king) != .fh) {
                    if (this.squares[square_king + 9] == .black_pawn) {
                        return true;
                    }
                    if (File.of(square_king) != .fg and this.squares[square_king + 10] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_king + 9] == .black_king) {
                        return true;
                    }
                }
                if (Rank.of(square_king) != .r7) {
                    if (File.of(square_king) != .fa and this.squares[square_king + 15] == .black_knight) {
                        return true;
                    }
                    if (File.of(square_king) != .fh and this.squares[square_king + 17] == .black_knight) {
                        return true;
                    }
                }
            }
            if (Rank.of(square_king) != .r1) {
                if (this.squares[square_king - 8] == .black_king) {
                    return true;
                }
                if (File.of(square_king) != .fa) {
                    if (File.of(square_king) != .fb and this.squares[square_king - 10] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_king - 9] == .black_king) {
                        return true;
                    }
                }
                if (File.of(square_king) != .fh) {
                    if (File.of(square_king) != .fg and this.squares[square_king - 6] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_king - 7] == .black_king) {
                        return true;
                    }
                }
                if (Rank.of(square_king) != .r2) {
                    if (File.of(square_king) != .fa and this.squares[square_king - 17] == .black_knight) {
                        return true;
                    }
                    if (File.of(square_king) != .fh and this.squares[square_king - 15] == .black_knight) {
                        return true;
                    }
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king + 7 * diagonal_idx > 63 or File.of(square_king + 7 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_king + 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + 7 * diagonal_idx].is_black_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king + 9 * diagonal_idx > 63 or File.of(square_king + 9 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_king + 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + 9 * diagonal_idx].is_black_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king < 7 * diagonal_idx or File.of(square_king - 7 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_king - 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - 7 * diagonal_idx].is_black_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king < 9 * diagonal_idx or File.of(square_king - 9 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_king - 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - 9 * diagonal_idx].is_black_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_king + 8 * vertical_idx > 63) {
                    break;
                }
                if (this.squares[square_king + 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + 8 * vertical_idx].is_black_slide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_king < 8 * vertical_idx) {
                    break;
                }
                if (this.squares[square_king - 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - 8 * vertical_idx].is_black_slide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (File.of(square_king + horizontal_idx) == .fa or square_king + horizontal_idx > 63) {
                    break;
                }
                if (this.squares[square_king + horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + horizontal_idx].is_black_slide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (square_king < horizontal_idx or File.of(square_king - horizontal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_king - horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - horizontal_idx].is_black_slide()) {
                    return true;
                } else {
                    break;
                }
            }
        } else {
            var square_king: u8 = 64;
            for (0..square_count) |square_idx| {
                if (this.squares[square_idx] == .black_king) {
                    square_king = @truncate(square_idx);
                    break;
                }
            }
            assert(square_king < 64);

            if (File.of(square_king) != .fa and this.squares[square_king - 1] == .white_king) {
                return true;
            }
            if (File.of(square_king) != .fh and this.squares[square_king + 1] == .white_king) {
                return true;
            }
            if (Rank.of(square_king) != .r8) {
                if (this.squares[square_king + 8] == .white_king) {
                    return true;
                }
                if (File.of(square_king) != .fa) {
                    if (File.of(square_king) != .fb and this.squares[square_king + 6] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_king + 7] == .white_king) {
                        return true;
                    }
                }
                if (File.of(square_king) != .fh) {
                    if (File.of(square_king) != .fg and this.squares[square_king + 10] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_king + 9] == .white_king) {
                        return true;
                    }
                }
                if (Rank.of(square_king) != .r7) {
                    if (File.of(square_king) != .fa and this.squares[square_king + 15] == .white_knight) {
                        return true;
                    }
                    if (File.of(square_king) != .fh and this.squares[square_king + 17] == .white_knight) {
                        return true;
                    }
                }
            }
            if (Rank.of(square_king) != .r1) {
                if (this.squares[square_king - 8] == .white_king) {
                    return true;
                }
                if (File.of(square_king) != .fa) {
                    if (File.of(square_king) != .fb and this.squares[square_king - 10] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_king - 9] == .white_king) {
                        return true;
                    }
                    if (this.squares[square_king - 9] == .white_pawn) {
                        return true;
                    }
                }
                if (File.of(square_king) != .fh) {
                    if (File.of(square_king) != .fg and this.squares[square_king - 6] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_king - 7] == .white_king) {
                        return true;
                    }
                    if (this.squares[square_king - 7] == .white_pawn) {
                        return true;
                    }
                }
                if (Rank.of(square_king) != .r2) {
                    if (File.of(square_king) != .fa and this.squares[square_king - 17] == .white_knight) {
                        return true;
                    }
                    if (File.of(square_king) != .fh and this.squares[square_king - 15] == .white_knight) {
                        return true;
                    }
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king + 7 * diagonal_idx > 63 or File.of(square_king + 7 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_king + 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + 7 * diagonal_idx].is_white_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king + 9 * diagonal_idx > 63 or File.of(square_king + 9 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_king + 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + 9 * diagonal_idx].is_white_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king < 7 * diagonal_idx or File.of(square_king - 7 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_king - 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - 7 * diagonal_idx].is_white_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_king < 9 * diagonal_idx or File.of(square_king - 9 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_king - 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - 9 * diagonal_idx].is_white_diagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_king + 8 * vertical_idx > 63) {
                    break;
                }
                if (this.squares[square_king + 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + 8 * vertical_idx].is_white_slide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_king < 8 * vertical_idx) {
                    break;
                }
                if (this.squares[square_king - 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - 8 * vertical_idx].is_white_slide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (File.of(square_king + horizontal_idx) == .fa or square_king + horizontal_idx > 63) {
                    break;
                }
                if (this.squares[square_king + horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king + horizontal_idx].is_white_slide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (square_king < horizontal_idx or File.of(square_king - horizontal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_king - horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_king - horizontal_idx].is_white_slide()) {
                    return true;
                } else {
                    break;
                }
            }
        }
        return false;
    }
    pub fn print(this: *const @This()) void {
        // Print this way to have a1 be the bottom left square with index 0
        const std = @import("std");
        std.debug.print("   a b c d e f g h\n", .{});
        for (0..8) |row_idx| {
            std.debug.print("{} ", .{8 - row_idx});
            for (0..8) |column_idx| {
                const square_idx: usize = (8 - (row_idx + 1)) * 8 + column_idx;
                std.debug.print(" {s}", .{
                    switch (this.squares[square_idx]) {
                        .empty => ".",
                        .white_pawn => "P",
                        .black_pawn => "p",
                        .white_knight => "N",
                        .black_knight => "n",
                        .white_bishop => "B",
                        .black_bishop => "b",
                        .white_rook => "R",
                        .black_rook => "r",
                        .white_queen => "Q",
                        .black_queen => "q",
                        .white_king => "K",
                        .black_king => "k",
                    },
                });
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("To move: {s}\n", .{
            switch (this.side_to_move) {
                .white => "w",
                .black => "b",
            },
        });
    }
    pub fn result(this: *const @This(), movelist: *const Movelist) Result {
        if (movelist.move_count == 0) {
            if (this.is_check(this.side_to_move)) {
                return switch (this.side_to_move) {
                    .white => .white,
                    .black => .black,
                };
            } else {
                return .draw;
            }
        } else {
            return .none;
        }
        //
    }
    pub fn debug(this: *const @This()) void {
        const std = @import("std");
        std.debug.print("      a      b      c      d      e      f      g      h\n", .{});
        for (0..8) |row_idx| {
            std.debug.print("{} ", .{8 - row_idx});
            for (0..8) |column_idx| {
                const square_idx: usize = (8 - (row_idx + 1)) * 8 + column_idx;
                std.debug.print("({d:2} {s}) ", .{ square_idx, switch (this.squares[square_idx]) {
                    .empty => ".",
                    .white_pawn => "P",
                    .black_pawn => "p",
                    .white_knight => "N",
                    .black_knight => "n",
                    .white_bishop => "B",
                    .black_bishop => "b",
                    .white_rook => "R",
                    .black_rook => "r",
                    .white_queen => "Q",
                    .black_queen => "q",
                    .white_king => "K",
                    .black_king => "k",
                } });
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("To move: {s}\n", .{
            switch (this.side_to_move) {
                .white => "w",
                .black => "b",
            },
        });
        if (this.en_passant != 0) {
            std.debug.print("En passant: {c}{c} = {}\n", .{
                'a' + (this.en_passant % 8),
                '1' + @divFloor(this.en_passant, 8),
                this.en_passant,
            });
        } else {
            std.debug.print("En passant: ---\n", .{});
        }
        std.debug.print("Fifty move: {}\n", .{this.fifty_move});
        if (this.castle == 0) {
            std.debug.print("Castle rights: ---\n", .{});
        } else {
            std.debug.print("Castle rights: {s}{s}{s}{s}\n", .{
                // There has to be a significantly nicer way of doing this
                switch (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.white_kingside))) == 1) {
                    true => "K",
                    false => "-",
                },
                switch (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.white_queenside))) == 1) {
                    true => "Q",
                    false => "-",
                },
                switch (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.black_kingside))) == 1) {
                    true => "k",
                    false => "-",
                },
                switch (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.black_queenside))) == 1) {
                    true => "q",
                    false => "-",
                },
            });
        }
    }
};
