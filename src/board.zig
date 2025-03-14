const std = @import("std");
const assert = std.debug.assert;

const Move = @import("./move.zig").Move;
const Movelist = @import("./move.zig").Movelist;
const move_count_max = @import("./move.zig").move_count_max;

pub const Color = enum(u8) {
    white,
    black,
};
pub const Result = enum(u8) {
    white,
    black,
    draw,
    none,
};
pub const Piece = enum(u8) {
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
    pub fn isWhite(this: @This()) bool {
        return this == .white_pawn or this == .white_knight or
            this == .white_bishop or this == .white_rook or
            this == .white_queen or this == .white_king;
    }
    pub fn isBlack(this: @This()) bool {
        return this == .black_pawn or this == .black_knight or
            this == .black_bishop or this == .black_rook or
            this == .black_queen or this == .black_king;
    }
    pub fn isWhiteDiagonal(this: @This()) bool {
        return this == .white_bishop or this == .white_queen;
    }
    pub fn isBlackDiagonal(this: @This()) bool {
        return this == .black_bishop or this == .black_queen;
    }
    pub fn isWhiteSlide(this: @This()) bool {
        return this == .white_rook or this == .white_queen;
    }
    pub fn isBlackSlide(this: @This()) bool {
        return this == .black_rook or this == .black_queen;
    }
};

pub const Castle = enum(u8) {
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

pub const Board = struct {
    pub const fen_start = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    pub const square_count = 64;
    pub const game_len_max = 4096;

    /// Game state information that can't be calculated from other information
    pub const History = struct {
        /// Index of the square on which en passant is possible, 0 if not possible, because that value can not be a valid square for en passant
        en_passant_sq: u8,
        /// Counted in half-moves
        fifty_move: u8,
        /// Only the lowest 4 bits matter and are 1 if that type of castling is allowed
        /// For which bit corresponds to which castling type see the Castle enum
        castle: u8,
    };

    squares: [square_count]Piece,
    side_to_move: Color,
    history: [game_len_max]History,
    /// Obviously equivalent to game length (If not starting the engine in the middle of the game)
    history_len: u16,
    pub fn alloc(fen: ?[]const u8) Board {
        var board: Board = undefined;
        board.readFen(if (fen) |f| f else fen_start);
        return board;
    }
    pub fn readFen(this: *@This(), fen: []const u8) void {
        var offset: usize = 0;
        // NOTE: At most 1 letter per square + 7 '/' charachters
        const piece_info_char_max: usize = 71;
        // HACK: Necessary to have a1 be the square at index 0 and preserving an intuitive represenation when printing
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
                    unreachable;
                },
            }
            offset += 1;
        }

        switch (fen[offset]) {
            'w' => this.side_to_move = .white,
            'b' => this.side_to_move = .black,
            else => unreachable,
        }

        offset += 2;
        var offset_temp: usize = 0;
        const castle_info_char_max: usize = 4;

        this.history_len = 1;
        this.history[0].castle = 0;
        for (0..castle_info_char_max) |char_idx| {
            offset_temp = char_idx + 1;
            switch (fen[offset + char_idx]) {
                'K' => this.history[0].castle |= 1 << @intFromEnum(Castle.white_kingside),
                'k' => this.history[0].castle |= 1 << @intFromEnum(Castle.black_kingside),
                'Q' => this.history[0].castle |= 1 << @intFromEnum(Castle.white_queenside),
                'q' => this.history[0].castle |= 1 << @intFromEnum(Castle.black_queenside),
                '-' => break,
                else => unreachable,
            }
        }

        offset += offset_temp + 1;
        if (fen[offset] == '-') {
            this.history[0].en_passant_sq = 0;
            offset += 2;
        } else {
            assert(fen[offset] >= 'a');
            assert(fen[offset] <= 'h');
            assert(fen[offset + 1] >= '1');
            assert(fen[offset + 1] <= '8');
            this.history[0].en_passant_sq = fen[offset] - 'a' + (fen[offset + 1] - '1') * 8;
            offset += 3;
        }

        this.history[0].fifty_move = 0;
        for (offset..fen.len) |char_idx| {
            if (fen[char_idx] == ' ') {
                break;
            }
            this.history[0].fifty_move *= 10;
            this.history[0].fifty_move += fen[char_idx] - '0';
        }
    }
    pub fn makeMove(this: *@This(), move: Move) void {
        // Less than 101 because of a kinda stupid way the move generation works
        assert(this.fifty_move < 101);

        // TODO: Refactor this sucker...
        if (Rank.of(move.from) == .r1) {
            if (File.of(move.from) == .fa and this.squares[move.from] == .white_rook) {
                this.castle = this.castle & (0xff ^ (1 << @intFromEnum(Castle.white_queenside)));
            } else if (File.of(move.from) == .fh and this.squares[move.from] == .white_rook) {
                this.castle = this.castle & (0xff ^ (1 << @intFromEnum(Castle.white_kingside)));
            }
        } else if (Rank.of(move.from) == .r8) {
            if (File.of(move.from) == .fa and this.squares[move.from] == .black_rook) {
                this.castle = this.castle & (0xff ^ (1 << @intFromEnum(Castle.black_queenside)));
            } else if (File.of(move.from) == .fh and this.squares[move.from] == .black_rook) {
                this.castle = this.castle & (0xff ^ (1 << @intFromEnum(Castle.black_kingside)));
            }
        }
        if (this.squares[move.from] == .white_king) {
            this.castle = this.castle & (0xff ^ (1 << @intFromEnum(Castle.white_kingside)) ^ (1 << @intFromEnum(Castle.white_queenside)));
        } else if (this.squares[move.from] == .black_king) {
            this.castle = this.castle & (0xff ^ (1 << @intFromEnum(Castle.black_kingside)) ^ (1 << @intFromEnum(Castle.black_queenside)));
        }

        if (move.en_passant_capture) {
            this.squares[move.to] = this.squares[move.from];
            this.squares[move.from] = .empty;
            if (this.side_to_move == .white) {
                this.squares[move.to - 8] = .empty;
            } else {
                this.squares[move.to + 8] = .empty;
            }

            this.fifty_move = 0;
        } else if (move.castle != .none) {
            switch (move.castle) {
                .none => assert(false),
                .white_kingside => {
                    this.squares[4] = .empty;
                    this.squares[5] = .white_rook;
                    this.squares[6] = .white_king;
                    this.squares[7] = .empty;
                },
                .white_queenside => {
                    this.squares[4] = .empty;
                    this.squares[3] = .white_rook;
                    this.squares[2] = .white_king;
                    this.squares[0] = .empty;
                },
                .black_kingside => {
                    this.squares[60] = .empty;
                    this.squares[61] = .black_rook;
                    this.squares[62] = .black_king;
                    this.squares[63] = .empty;
                },
                .black_queenside => {
                    this.squares[60] = .empty;
                    this.squares[59] = .black_rook;
                    this.squares[58] = .black_king;
                    this.squares[56] = .empty;
                },
            }
        } else {
            this.fifty_move = switch (move.promoted != .empty or move.captured != .empty or
                this.squares[move.from] == .white_pawn or this.squares[move.from] == .black_pawn) {
                true => 0,
                false => this.fifty_move + 1,
            };

            if (move.promoted == .empty) {
                this.squares[move.to] = this.squares[move.from];
            } else {
                this.squares[move.to] = move.promoted;
                this.fifty_move = 0;
            }
            this.squares[move.from] = .empty;
        }
        this.side_to_move = switch (this.side_to_move) {
            .white => .black,
            .black => .white,
        };
        // This is 0 in case en passant is not possible
        this.en_passant = move.en_passant_square;
    }
    pub fn undoMove(this: *@This(), move: Move) void {
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
        } else if (move.castle != .none) {
            switch (move.castle) {
                .none => assert(false),
                .white_kingside => {
                    this.squares[4] = .white_king;
                    this.squares[5] = .empty;
                    this.squares[6] = .empty;
                    this.squares[7] = .white_rook;
                },
                .white_queenside => {
                    this.squares[4] = .white_king;
                    this.squares[3] = .empty;
                    this.squares[2] = .empty;
                    this.squares[0] = .white_rook;
                },
                .black_kingside => {
                    this.squares[60] = .black_king;
                    this.squares[61] = .empty;
                    this.squares[62] = .empty;
                    this.squares[63] = .black_rook;
                },
                .black_queenside => {
                    this.squares[60] = .black_king;
                    this.squares[59] = .empty;
                    this.squares[58] = .empty;
                    this.squares[56] = .black_rook;
                },
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
        this.castle = move.castle_perm_past;
        this.fifty_move = move.fifty_move_past;
    }
    pub fn copyTo(this: @This(), target: *Board) void {
        target.side_to_move = this.side_to_move;
        target.squares = this.squares;
        target.history = this.history;
        target.history_len = this.history_len;
    }
    /// Check if the square it index `square_idx` is attacked by a piece of opposite color to `color`
    pub fn isSquareAttacked(this: @This(), square_idx: u8, color: Color) bool {
        assert(square_idx < 64);

        if (color == .white) {
            if (File.of(square_idx) != .fa and this.squares[square_idx - 1] == .black_king) {
                return true;
            }
            if (File.of(square_idx) != .fh and this.squares[square_idx + 1] == .black_king) {
                return true;
            }
            if (Rank.of(square_idx) != .r8) {
                if (this.squares[square_idx + 8] == .black_king) {
                    return true;
                }
                if (File.of(square_idx) != .fa) {
                    if (this.squares[square_idx + 7] == .black_pawn) {
                        return true;
                    }
                    if (File.of(square_idx) != .fb and this.squares[square_idx + 6] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_idx + 7] == .black_king) {
                        return true;
                    }
                }
                if (File.of(square_idx) != .fh) {
                    if (this.squares[square_idx + 9] == .black_pawn) {
                        return true;
                    }
                    if (File.of(square_idx) != .fg and this.squares[square_idx + 10] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_idx + 9] == .black_king) {
                        return true;
                    }
                }
                if (Rank.of(square_idx) != .r7) {
                    if (File.of(square_idx) != .fa and this.squares[square_idx + 15] == .black_knight) {
                        return true;
                    }
                    if (File.of(square_idx) != .fh and this.squares[square_idx + 17] == .black_knight) {
                        return true;
                    }
                }
            }
            if (Rank.of(square_idx) != .r1) {
                if (this.squares[square_idx - 8] == .black_king) {
                    return true;
                }
                if (File.of(square_idx) != .fa) {
                    if (File.of(square_idx) != .fb and this.squares[square_idx - 10] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_idx - 9] == .black_king) {
                        return true;
                    }
                }
                if (File.of(square_idx) != .fh) {
                    if (File.of(square_idx) != .fg and this.squares[square_idx - 6] == .black_knight) {
                        return true;
                    }
                    if (this.squares[square_idx - 7] == .black_king) {
                        return true;
                    }
                }
                if (Rank.of(square_idx) != .r2) {
                    if (File.of(square_idx) != .fa and this.squares[square_idx - 17] == .black_knight) {
                        return true;
                    }
                    if (File.of(square_idx) != .fh and this.squares[square_idx - 15] == .black_knight) {
                        return true;
                    }
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx + 7 * diagonal_idx > 63 or File.of(square_idx + 7 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_idx + 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + 7 * diagonal_idx].isBlackDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx + 9 * diagonal_idx > 63 or File.of(square_idx + 9 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_idx + 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + 9 * diagonal_idx].isBlackDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx < 7 * diagonal_idx or File.of(square_idx - 7 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_idx - 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - 7 * diagonal_idx].isBlackDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx < 9 * diagonal_idx or File.of(square_idx - 9 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_idx - 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - 9 * diagonal_idx].isBlackDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_idx + 8 * vertical_idx > 63) {
                    break;
                }
                if (this.squares[square_idx + 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + 8 * vertical_idx].isBlackSlide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_idx < 8 * vertical_idx) {
                    break;
                }
                if (this.squares[square_idx - 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - 8 * vertical_idx].isBlackSlide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                    break;
                }
                if (this.squares[square_idx + horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + horizontal_idx].isBlackSlide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (square_idx < horizontal_idx or File.of(square_idx - horizontal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_idx - horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - horizontal_idx].isBlackSlide()) {
                    return true;
                } else {
                    break;
                }
            }
        } else {
            if (File.of(square_idx) != .fa and this.squares[square_idx - 1] == .white_king) {
                return true;
            }
            if (File.of(square_idx) != .fh and this.squares[square_idx + 1] == .white_king) {
                return true;
            }
            if (Rank.of(square_idx) != .r8) {
                if (this.squares[square_idx + 8] == .white_king) {
                    return true;
                }
                if (File.of(square_idx) != .fa) {
                    if (File.of(square_idx) != .fb and this.squares[square_idx + 6] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_idx + 7] == .white_king) {
                        return true;
                    }
                }
                if (File.of(square_idx) != .fh) {
                    if (File.of(square_idx) != .fg and this.squares[square_idx + 10] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_idx + 9] == .white_king) {
                        return true;
                    }
                }
                if (Rank.of(square_idx) != .r7) {
                    if (File.of(square_idx) != .fa and this.squares[square_idx + 15] == .white_knight) {
                        return true;
                    }
                    if (File.of(square_idx) != .fh and this.squares[square_idx + 17] == .white_knight) {
                        return true;
                    }
                }
            }
            if (Rank.of(square_idx) != .r1) {
                if (this.squares[square_idx - 8] == .white_king) {
                    return true;
                }
                if (File.of(square_idx) != .fa) {
                    if (File.of(square_idx) != .fb and this.squares[square_idx - 10] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_idx - 9] == .white_king) {
                        return true;
                    }
                    if (this.squares[square_idx - 9] == .white_pawn) {
                        return true;
                    }
                }
                if (File.of(square_idx) != .fh) {
                    if (File.of(square_idx) != .fg and this.squares[square_idx - 6] == .white_knight) {
                        return true;
                    }
                    if (this.squares[square_idx - 7] == .white_king) {
                        return true;
                    }
                    if (this.squares[square_idx - 7] == .white_pawn) {
                        return true;
                    }
                }
                if (Rank.of(square_idx) != .r2) {
                    if (File.of(square_idx) != .fa and this.squares[square_idx - 17] == .white_knight) {
                        return true;
                    }
                    if (File.of(square_idx) != .fh and this.squares[square_idx - 15] == .white_knight) {
                        return true;
                    }
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx + 7 * diagonal_idx > 63 or File.of(square_idx + 7 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_idx + 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + 7 * diagonal_idx].isWhiteDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx + 9 * diagonal_idx > 63 or File.of(square_idx + 9 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_idx + 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + 9 * diagonal_idx].isWhiteDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx < 7 * diagonal_idx or File.of(square_idx - 7 * diagonal_idx) == .fa) {
                    break;
                }
                if (this.squares[square_idx - 7 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - 7 * diagonal_idx].isWhiteDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |diagonal_idx_usize| {
                const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                if (square_idx < 9 * diagonal_idx or File.of(square_idx - 9 * diagonal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_idx - 9 * diagonal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - 9 * diagonal_idx].isWhiteDiagonal()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_idx + 8 * vertical_idx > 63) {
                    break;
                }
                if (this.squares[square_idx + 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + 8 * vertical_idx].isWhiteSlide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |vertical_idx_usize| {
                const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                if (square_idx < 8 * vertical_idx) {
                    break;
                }
                if (this.squares[square_idx - 8 * vertical_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - 8 * vertical_idx].isWhiteSlide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                    break;
                }
                if (this.squares[square_idx + horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx + horizontal_idx].isWhiteSlide()) {
                    return true;
                } else {
                    break;
                }
            }
            for (0..8) |horizontal_idx_usize| {
                const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                if (square_idx < horizontal_idx or File.of(square_idx - horizontal_idx) == .fh) {
                    break;
                }
                if (this.squares[square_idx - horizontal_idx] == .empty) {
                    continue;
                } else if (this.squares[square_idx - horizontal_idx].isWhiteSlide()) {
                    return true;
                } else {
                    break;
                }
            }
        }
        return false;
    }
    /// Check if the player `color` is in check
    pub fn isCheck(this: @This(), color: Color) bool {
        const king_target: Piece = switch (color) {
            .white => .white_king,
            .black => .black_king,
        };
        var square_king: u8 = 64;
        for (0..square_count) |square_idx| {
            if (this.squares[square_idx] == king_target) {
                square_king = @truncate(square_idx);
                break;
            }
        }
        assert(square_king < 64);

        return this.isSquareAttacked(square_king, color);
    }
    pub fn print(this: @This()) void {
        // Print this way to have a1 be the bottom left square with index 0
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
    pub fn result(this: @This(), movelist: Movelist) Result {
        if (movelist.move_count == 0) {
            if (this.isCheck(this.side_to_move)) {
                return switch (this.side_to_move) {
                    .white => .white,
                    .black => .black,
                };
            } else {
                return .draw;
            }
        } else {
            if (this.fifty_move >= 100) {
                return .draw;
            } else {
                return .none;
            }
        }
    }
    pub fn debug(this: @This()) void {
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
                if (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.white_kingside))) == 1) "K" else "-",
                if (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.white_queenside))) == 1) "Q" else "-",
                if (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.black_kingside))) == 1) "k" else "-",
                if (@as(u1, @truncate(this.castle >> @intFromEnum(Castle.black_queenside))) == 1) "q" else "-",
            });
        }
    }
};
