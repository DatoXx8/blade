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
    white_kingside = 0,
    white_queenside = 1,
    black_kingside = 2,
    black_queenside = 3,
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

pub fn nameOfSq(sq: u8) [2]u8 {
    return [2]u8{ 'a' + sq % 8, '1' + sq / 8 };
}
pub const Board = struct {
    pub const fen_start = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    pub const square_count = 64;
    pub const square_invalid = square_count;
    pub const game_len_max = 4096;

    /// Game state information that can't be calculated from other information
    pub const History = struct {
        /// Index of the square on which en passant is possible, `square_invalid` if not possible
        en_passant_sq: u8,
        /// Counted in half-moves
        fifty_move: u8,
        /// Only the lowest 4 bits matter and are 1 if that type of castling is allowed
        /// For which bit corresponds to which castling type see the Castle enum
        castle: u8,
        captured: Piece,
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
        @memset(this.squares[0..], .empty);

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
        const castle_info_char_max: usize = 5;

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
                ' ' => break,
                else => unreachable,
            }
        }
        offset += offset_temp;

        if (fen[offset] == '-') {
            this.history[0].en_passant_sq = square_invalid;
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
        this.history[0].captured = .empty;
    }
    pub fn makeMove(this: *@This(), move: Move) void {
        // Less than 101 because of a kinda stupid way the move generation works
        assert(this.history[this.history_len - 1].fifty_move < 101);

        var history_new: History = undefined;

        history_new.captured = this.squares[move.toSq()];

        if (move.flag() == .en_passant) {
            history_new.fifty_move = 0;
            history_new.castle = this.history[this.history_len - 1].castle;
            history_new.en_passant_sq = square_invalid;
            if (this.side_to_move == .white) {
                this.squares[move.toSq()] = .white_pawn;
                this.squares[move.toSq() - 8] = .empty;
            } else {
                this.squares[move.toSq()] = .black_pawn;
                this.squares[move.toSq() + 8] = .empty;
            }
            this.squares[move.fromSq()] = .empty;
        } else if (move.flag() == .castle_kingside) {
            history_new.fifty_move = this.history[this.history_len - 1].fifty_move + 1;
            history_new.en_passant_sq = square_invalid;
            if (this.side_to_move == .white) {
                this.squares[4] = .empty;
                this.squares[5] = .white_rook;
                this.squares[6] = .white_king;
                this.squares[7] = .empty;
                history_new.castle = this.history[this.history_len - 1].castle & 0b00001100;
            } else {
                this.squares[60] = .empty;
                this.squares[61] = .black_rook;
                this.squares[62] = .black_king;
                this.squares[63] = .empty;
                history_new.castle = this.history[this.history_len - 1].castle & 0b00000011;
            }
        } else if (move.flag() == .castle_queenside) {
            history_new.fifty_move = this.history[this.history_len - 1].fifty_move + 1;
            history_new.en_passant_sq = square_invalid;
            if (this.side_to_move == .white) {
                // TODO: This also needs to be made 960 compatible
                this.squares[0] = .empty;
                this.squares[1] = .empty;
                this.squares[2] = .white_king;
                this.squares[3] = .white_rook;
                this.squares[4] = .empty;
                history_new.castle = this.history[this.history_len - 1].castle & 0b00001100;
            } else {
                // TODO: This also needs to be made 960 compatible
                this.squares[56] = .empty;
                this.squares[57] = .empty;
                this.squares[58] = .black_king;
                this.squares[59] = .black_rook;
                this.squares[60] = .empty;
                history_new.castle = this.history[this.history_len - 1].castle & 0b00000011;
            }
        } else {
            if (this.squares[move.fromSq()] == .white_pawn or this.squares[move.fromSq()] == .black_pawn or
                this.squares[move.toSq()] != .empty)
            {
                history_new.fifty_move = 0;
            } else {
                history_new.fifty_move = this.history[this.history_len - 1].fifty_move + 1;
            }

            // TODO: Make this 960 compatible. I guess comparing if the rook is above or below the king square works.
            if (this.squares[move.fromSq()] == .white_king) {
                history_new.castle = this.history[this.history_len - 1].castle & 0b00001100;
            } else if (this.squares[move.fromSq()] == .white_rook) {
                if (File.of(move.fromSq()) == .fa) {
                    history_new.castle = this.history[this.history_len - 1].castle & 0b00001101;
                } else if (File.of(move.fromSq()) == .fh) {
                    history_new.castle = this.history[this.history_len - 1].castle & 0b00001110;
                }
            } else if (this.squares[move.fromSq()] == .black_king) {
                history_new.castle = this.history[this.history_len - 1].castle & 0b00000011;
            } else if (this.squares[move.fromSq()] == .black_rook) {
                if (File.of(move.fromSq()) == .fa) {
                    history_new.castle = this.history[this.history_len - 1].castle & 0b00000111;
                } else if (File.of(move.fromSq()) == .fh) {
                    history_new.castle = this.history[this.history_len - 1].castle & 0b00001011;
                }
            } else {
                history_new.castle = this.history[this.history_len - 1].castle;
            }

            if (this.side_to_move == .white and move.toSq() == 16 + move.fromSq() and this.squares[move.fromSq()] == .white_pawn) {
                history_new.en_passant_sq = move.fromSq() + 8;
            } else if (this.side_to_move == .black and move.fromSq() == 16 + move.toSq() and this.squares[move.fromSq()] == .black_pawn) {
                history_new.en_passant_sq = move.fromSq() - 8;
            } else {
                history_new.en_passant_sq = square_invalid;
            }

            this.squares[move.toSq()] = switch (move.flag()) {
                .none => this.squares[move.fromSq()],
                .promote_queen => if (this.side_to_move == .white) .white_queen else .black_queen,
                .promote_rook => if (this.side_to_move == .white) .white_rook else .black_rook,
                .promote_bishop => if (this.side_to_move == .white) .white_bishop else .black_bishop,
                .promote_knight => if (this.side_to_move == .white) .white_knight else .black_knight,
                else => unreachable,
            };
            this.squares[move.fromSq()] = .empty;
        }

        this.side_to_move = if (this.side_to_move == .white) .black else .white;
        this.history[this.history_len] = history_new;
        this.history_len += 1;
    }
    pub fn undoMove(this: *@This(), move: Move) void {
        assert(this.squares[move.fromSq()] == .empty);

        if (move.flag() == .en_passant) {
            if (this.side_to_move == .black) {
                this.squares[move.toSq()] = .empty;
                this.squares[move.toSq() - 8] = .black_pawn;
                this.squares[move.fromSq()] = .white_pawn;
            } else {
                this.squares[move.toSq()] = .empty;
                this.squares[move.toSq() + 8] = .white_pawn;
                this.squares[move.fromSq()] = .black_pawn;
            }
        } else if (move.flag() == .castle_kingside) {
            // TODO: This also needs to be made 960 compatible
            if (this.side_to_move == .black) {
                this.squares[4] = .white_king;
                this.squares[5] = .empty;
                this.squares[6] = .empty;
                this.squares[7] = .white_rook;
            } else {
                this.squares[60] = .black_king;
                this.squares[61] = .empty;
                this.squares[62] = .empty;
                this.squares[63] = .black_rook;
            }
        } else if (move.flag() == .castle_queenside) {
            // TODO: This also needs to be made 960 compatible
            if (this.side_to_move == .black) {
                this.squares[0] = .white_rook;
                this.squares[1] = .empty;
                this.squares[2] = .empty;
                this.squares[3] = .empty;
                this.squares[4] = .white_king;
            } else {
                this.squares[56] = .black_rook;
                this.squares[57] = .empty;
                this.squares[58] = .empty;
                this.squares[59] = .empty;
                this.squares[60] = .black_king;
            }
        } else {
            this.squares[move.fromSq()] = switch (move.flag()) {
                .none => this.squares[move.toSq()],
                .promote_queen,
                .promote_rook,
                .promote_bishop,
                .promote_knight,
                => if (this.side_to_move == .white) .black_pawn else .white_pawn,
                else => unreachable,
            };
            this.squares[move.toSq()] = this.history[this.history_len - 1].captured;
        }

        this.side_to_move = if (this.side_to_move == .white) .black else .white;
        this.history_len -= 1;
    }
    pub fn copyTo(this: @This(), target: *Board) void {
        target.side_to_move = this.side_to_move;
        target.squares = this.squares;
        target.history = this.history;
        target.history_len = this.history_len;
    }
    /// Check if the square it index `square_idx` is attacked by a piece of opposite color to `color`
    pub fn isSquareAttacked(this: @This(), square_idx: u8, color: Color) bool {
        assert(square_idx < square_count);

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
        var square_king: u8 = square_invalid;
        for (0..square_count) |square_idx| {
            if (this.squares[square_idx] == king_target) {
                square_king = @truncate(square_idx);
            }
        }
        assert(square_king != square_invalid);

        return this.isSquareAttacked(square_king, color);
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
            if (this.history[this.history_len - 1].fifty_move >= 100) {
                return .draw;
            } else {
                return .none;
            }
        }
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
        if (this.history[this.history_len - 1].en_passant_sq != square_invalid) {
            std.debug.print("En passant: {s} = {}\n", .{
                nameOfSq(this.history[this.history_len - 1].en_passant_sq),
                this.history[this.history_len - 1].en_passant_sq,
            });
        } else {
            std.debug.print("En passant: ---\n", .{});
        }
        std.debug.print("Fifty move: {}\n", .{this.history[this.history_len - 1].fifty_move});
        std.debug.print("Castle rights: {s}{s}{s}{s}\n", .{
            if (this.history[this.history_len - 1].castle & (1 << @intFromEnum(Castle.white_kingside)) == 1) "K" else "-",
            if (this.history[this.history_len - 1].castle & (1 << @intFromEnum(Castle.white_queenside)) == 1) "Q" else "-",
            if (this.history[this.history_len - 1].castle & (1 << @intFromEnum(Castle.black_kingside)) == 1) "k" else "-",
            if (this.history[this.history_len - 1].castle & (1 << @intFromEnum(Castle.black_queenside)) == 1) "q" else "-",
        });
    }
};
