const std = @import("std");
const assert = std.debug.assert;

const Board = @import("./board.zig").Board;
const File = @import("./board.zig").File;
const Rank = @import("./board.zig").Rank;
const Color = @import("./board.zig").Color;
const Piece = @import("./board.zig").Piece;
const Castle = @import("./board.zig").Castle;

pub const Move = struct {
    pub const Flag = enum(u4) {
        none,
        castle_kingside,
        castle_queenside,
        promote_knight,
        promote_bishop,
        promote_rook,
        promote_queen,
        en_passant,
    };
    data: u16,
    pub fn create(from: u8, to: u8, flags: Flag) Move {
        return .{ .data = from + (to << 6) + (@as(u16, @intFromEnum(flags)) << 12) };
    }
    pub fn fromSq(this: @This()) u8 {
        return @truncate(this.data & 0b111111);
    }
    pub fn toSq(this: @This()) u8 {
        return @truncate(this.data & (0b111111 << 6) >> 6);
    }
    pub fn flag(this: @This()) Flag {
        return @enumFromInt(this.data & (0b1111 << 12) >> 12);
    }
    pub fn print(this: @This()) void {
        std.debug.print("({d:2} to {d:2}, flag {}\n", .{ this.fromSq(), this.toSq(), this.flag() });
    }
};

pub const move_count_max: u8 = 219;
pub const Movelist = struct {
    move_count: u8,
    move: [move_count_max]Move,

    pub fn generate(this: *@This(), board: *Board) void {
        assert(this.move_count == 0);

        if (board.side_to_move == .white) {
            if (@as(u1, @truncate(board.history[board.history_len - 1].castle >> @intFromEnum(Castle.white_kingside))) == 1 and
                board.squares[5] == .empty and board.squares[6] == .empty and board.squares[7] == .white_rook and
                !board.isSquareAttacked(5, .white) and !board.isSquareAttacked(6, .white))
            {
                this.add(Move.create(4, 6, .castle_kingside));
            }
            if (@as(u1, @truncate(board.history[board.history_len - 1].castle >> @intFromEnum(Castle.white_queenside))) == 1 and
                board.squares[0] == .white_rook and
                board.squares[1] == .empty and board.squares[2] == .empty and
                board.squares[3] == .empty and !board.isSquareAttacked(1, .white) and
                !board.isSquareAttacked(2, .white) and !board.isSquareAttacked(3, .white))
            {
                this.add(Move.create(4, 2, .castle_queenside));
            }

            for (0..Board.square_count) |square_idx_size| {
                // TODO: Refactor this usize and u8 bs
                const square_idx: u8 = @truncate(square_idx_size);
                if (board.squares[square_idx].isBlack() or board.squares[square_idx] == .empty) {
                    continue;
                }

                switch (board.squares[square_idx]) {
                    .white_pawn => {
                        if (Rank.of(square_idx) == .r7) {
                            if (board.squares[square_idx + 8] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 8, .promote_queen));
                                this.add(Move.create(square_idx, square_idx + 8, .promote_rook));
                                this.add(Move.create(square_idx, square_idx + 8, .promote_knight));
                                this.add(Move.create(square_idx, square_idx + 8, .promote_bishop));
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 7, .promote_queen));
                                this.add(Move.create(square_idx, square_idx + 7, .promote_rook));
                                this.add(Move.create(square_idx, square_idx + 7, .promote_knight));
                                this.add(Move.create(square_idx, square_idx + 7, .promote_bishop));
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 9, .promote_queen));
                                this.add(Move.create(square_idx, square_idx + 9, .promote_rook));
                                this.add(Move.create(square_idx, square_idx + 9, .promote_knight));
                                this.add(Move.create(square_idx, square_idx + 9, .promote_bishop));
                            }
                        } else {
                            if (board.squares[square_idx + 8] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 8, .none));
                                if (Rank.of(square_idx) == .r2 and board.squares[square_idx + 16] == .empty) {
                                    this.add(Move.create(square_idx, square_idx + 16, .none));
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 7, .none));
                            }
                            // Could explicitly check that the pawn is on the 5th rank but that is unnecessary
                            if (File.of(square_idx) != .fa and square_idx + 7 == board.history[board.history_len - 1].en_passant_sq) {
                                this.add(Move.create(square_idx, square_idx + 7, .en_passant));
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 9, .none));
                            }
                            // Could explicitly check that the pawn is on the 5th rank but that is unnecessary
                            if (File.of(square_idx) != .fh and square_idx + 9 == board.history[board.history_len - 1].en_passant_sq) {
                                this.add(Move.create(square_idx, square_idx + 9, .en_passant));
                            }
                        }
                    },
                    .white_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 17].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 17, .none));
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 15].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 15, .none));
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 15].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 15, .none));
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 17].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 17, .none));
                            }
                        }
                        if (File.of(square_idx) != .fb and File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 10].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 10, .none));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 6].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 6, .none));
                            }
                        }
                        if (File.of(square_idx) != .fg and File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 6].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 6, .none));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 10].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 10, .none));
                            }
                        }
                    },
                    .white_bishop => {
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 9 * diagonal_idx or File.of(square_idx - 9 * diagonal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 7 * diagonal_idx or File.of(square_idx - 7 * diagonal_idx) == .fa) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .white_rook => {
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                            } else if (board.squares[square_idx + horizontal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (square_idx < horizontal_idx or File.of(square_idx - horizontal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                            } else if (board.squares[square_idx - horizontal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx + 8 * vertical_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx < 8 * vertical_idx) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx - 8 * vertical_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .white_queen => {
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 9 * diagonal_idx or File.of(square_idx - 9 * diagonal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 7 * diagonal_idx or File.of(square_idx - 7 * diagonal_idx) == .fa) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                            } else if (board.squares[square_idx + horizontal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (square_idx < horizontal_idx or File.of(square_idx - horizontal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                            } else if (board.squares[square_idx - horizontal_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx + 8 * vertical_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx < 8 * vertical_idx) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx - 8 * vertical_idx].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .white_king => {
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].isWhite()) {
                            this.add(Move.create(square_idx, square_idx - 8, .none));
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].isWhite()) {
                            this.add(Move.create(square_idx, square_idx + 8, .none));
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 1, .none));
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 9, .none));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 7, .none));
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 1, .none));
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 7, .none));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 9, .none));
                            }
                        }
                    },
                    else => unreachable,
                }
            }
        } else {
            if (@as(u1, @truncate(board.history[board.history_len - 1].castle >> @intFromEnum(Castle.black_kingside))) == 1 and
                board.squares[61] == .empty and board.squares[62] == .empty and board.squares[63] == .black_rook and
                !board.isSquareAttacked(61, .black) and !board.isSquareAttacked(62, .black))
            {
                this.add(Move.create(60, 62, .castle_kingside));
            }
            if (@as(u1, @truncate(board.history[board.history_len - 1].castle >> @intFromEnum(Castle.black_queenside))) == 1 and board.squares[60] == .black_rook and
                board.squares[57] == .empty and board.squares[58] == .empty and
                board.squares[59] == .empty and !board.isSquareAttacked(57, .black) and
                !board.isSquareAttacked(58, .black) and !board.isSquareAttacked(59, .black))
            {
                this.add(Move.create(60, 58, .castle_queenside));
            }

            for (0..Board.square_count) |square_idx_size| {
                // TODO: Refactor this usize and u8 bs
                const square_idx: u8 = @truncate(square_idx_size);
                if (board.squares[square_idx].isWhite() or board.squares[square_idx] == .empty) {
                    continue;
                }

                switch (board.squares[square_idx]) {
                    .black_pawn => {
                        if (Rank.of(square_idx) == .r2) {
                            if (board.squares[square_idx - 8] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 8, .promote_queen));
                                this.add(Move.create(square_idx, square_idx - 8, .promote_rook));
                                this.add(Move.create(square_idx, square_idx - 8, .promote_knight));
                                this.add(Move.create(square_idx, square_idx - 8, .promote_bishop));
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 9, .promote_queen));
                                this.add(Move.create(square_idx, square_idx - 9, .promote_rook));
                                this.add(Move.create(square_idx, square_idx - 9, .promote_knight));
                                this.add(Move.create(square_idx, square_idx - 9, .promote_bishop));
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 7, .promote_queen));
                                this.add(Move.create(square_idx, square_idx - 7, .promote_rook));
                                this.add(Move.create(square_idx, square_idx - 7, .promote_knight));
                                this.add(Move.create(square_idx, square_idx - 7, .promote_bishop));
                            }
                        } else {
                            if (board.squares[square_idx - 8] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 8, .none));
                                if (Rank.of(square_idx) == .r7 and board.squares[square_idx - 16] == .empty) {
                                    this.add(Move.create(square_idx, square_idx - 16, .none));
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 9, .none));
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fa and square_idx - 9 == board.history[board.history_len - 1].en_passant_sq) {
                                this.add(Move.create(square_idx, square_idx - 9, .en_passant));
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 7, .none));
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fh and square_idx - 7 == board.history[board.history_len - 1].en_passant_sq) {
                                this.add(Move.create(square_idx, square_idx - 7, .en_passant));
                            }
                        }
                    },
                    .black_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 17].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 17, .en_passant));
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 15].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 15, .en_passant));
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 15].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 15, .en_passant));
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 17].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 17, .en_passant));
                            }
                        }
                        if (File.of(square_idx) != .fb and File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 10].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 10, .en_passant));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 6].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 6, .en_passant));
                            }
                        }
                        if (File.of(square_idx) != .fg and File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 6].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 6, .en_passant));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 10].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 10, .en_passant));
                            }
                        }
                    },
                    .black_bishop => {
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 9 * diagonal_idx or File.of(square_idx - 9 * diagonal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 7 * diagonal_idx or File.of(square_idx - 7 * diagonal_idx) == .fa) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .black_rook => {
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                            } else if (board.squares[square_idx + horizontal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (square_idx < horizontal_idx or File.of(square_idx - horizontal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                            } else if (board.squares[square_idx - horizontal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx + 8 * vertical_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx < 8 * vertical_idx) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx - 8 * vertical_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .black_queen => {
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 9 * diagonal_idx or File.of(square_idx - 9 * diagonal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 9 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (square_idx < 7 * diagonal_idx or File.of(square_idx - 7 * diagonal_idx) == .fa) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 7 * diagonal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                            } else if (board.squares[square_idx + horizontal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (square_idx < horizontal_idx or File.of(square_idx - horizontal_idx) == .fh) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                            } else if (board.squares[square_idx - horizontal_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - horizontal_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx + 8 * vertical_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx + 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx_usize| {
                            const vertical_idx: u8 = @truncate(vertical_idx_usize + 1);
                            if (square_idx < 8 * vertical_idx) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                            } else if (board.squares[square_idx - 8 * vertical_idx].isWhite()) {
                                this.add(Move.create(square_idx, square_idx - 8 * vertical_idx, .none));
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .black_king => {
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].isBlack()) {
                            this.add(Move.create(square_idx, square_idx - 8, .none));
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].isBlack()) {
                            this.add(Move.create(square_idx, square_idx + 8, .none));
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 1, .none));
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 9, .none));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 7, .none));
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 1, .none));
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].isBlack()) {
                                this.add(Move.create(square_idx, square_idx - 7, .none));
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].isBlack()) {
                                this.add(Move.create(square_idx, square_idx + 9, .none));
                            }
                        }
                    },
                    else => unreachable,
                }
            }
        }

        var movelist_count_legal: u8 = 0;
        for (0..this.move_count) |move_idx| {
            const color_check: Color = board.side_to_move;

            board.makeMove(this.move[move_idx]);

            if (!board.isCheck(color_check)) {
                this.move[movelist_count_legal] = this.move[move_idx];
                movelist_count_legal += 1;
            }

            board.undoMove(this.move[move_idx]);
        }
        this.move_count = movelist_count_legal;
    }
    pub fn add(this: *@This(), move: Move) void {
        assert(this.move_count < move_count_max);
        this.move[this.move_count] = move;
        this.move_count += 1;
    }
    pub fn clear(this: *@This()) void {
        for (0..this.move_count) |move_idx| {
            this.move[move_idx] = undefined;
        }
        this.move_count = 0;
    }
    pub fn print(this: @This()) void {
        std.debug.print("Move count {} of {}\n", .{ this.move_count, move_count_max });
        for (0..this.move_count) |move_idx| {
            std.debug.print("[{d:3}] => ", .{
                move_idx,
            });
            this.move[move_idx].print();
        }
    }
};
