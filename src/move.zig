const Board = @import("./board.zig").Board;
const File = @import("./board.zig").File;
const Rank = @import("./board.zig").Rank;
const Color = @import("./board.zig").Color;
const Piece = @import("./board.zig").Piece;
const Castle = @import("./board.zig").Castle;
const square_count = @import("./board.zig").square_count;

const assert = @import("./util.zig").assert;

pub const Move = struct {
    from: u8,
    to: u8,
    en_passant_capture: bool,
    /// Kind of a misleading name, but this is the square on which en passant will be possible *after* this move.
    en_passant_square: u8,
    captured: Piece,
    promoted: Piece,
    // TODO: Figure out if there is a way to remove these
    en_passant_square_past: u8,
    pub fn print(this: *@This()) void {
        const std = @import("std");
        std.debug.print("({d:2} to {d:2}, en_passant ({}, sq {d:2}, past {d:2}), {}, {})\n", .{
            this.from,
            this.to,
            this.en_passant_capture,
            this.en_passant_square,
            this.en_passant_square_past,
            this.captured,
            this.promoted,
        });
    }
};

pub const move_count_max: u8 = 219;
pub const Movelist = struct {
    move_count: u8,
    move: [move_count_max]Move,

    pub fn generate(this: *@This(), board: *Board) void {
        assert(this.move_count == 0);

        var temporary: Movelist = Movelist.init();
        if (board.side_to_move == .white) {
            for (0..square_count) |square_idx_size| {
                // TODO: Refactor this usize and u8 bs
                const square_idx: u8 = @truncate(square_idx_size);
                if (board.squares[square_idx].is_black() or board.squares[square_idx] == .empty) {
                    continue;
                }
                switch (board.squares[square_idx]) {
                    .white_pawn => {
                        if (Rank.of(square_idx) == .r7) {
                            if (board.squares[square_idx + 8] == .empty) {
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        } else {
                            if (board.squares[square_idx + 8] == .empty) {
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                if (Rank.of(square_idx) == .r2 and board.squares[square_idx + 16] == .empty) {
                                    temporary.add(.{
                                        .to = square_idx + 16,
                                        .from = square_idx,
                                        .captured = .empty,
                                        .promoted = .empty,
                                        .en_passant_capture = false,
                                        .en_passant_square = square_idx + 8,
                                        .en_passant_square_past = board.en_passant,
                                    });
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            // Could explicitly check that the pawn is on the 5th rank but that is unnecessary
                            if (File.of(square_idx) != .fa and square_idx + 7 == board.en_passant) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            // Could explicitly check that the pawn is on the 5th rank but that is unnecessary
                            if (File.of(square_idx) != .fh and square_idx + 9 == board.en_passant) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                    },
                    .white_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 17].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 15].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 15].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 17].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fb and File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 10].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 6].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fg and File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 6].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 10].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else {
                                break;
                            }
                        }
                    },
                    .white_queen => {
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .white_king => {
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].is_white()) {
                            temporary.add(.{
                                .to = square_idx - 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx - 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                            });
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].is_white()) {
                            temporary.add(.{
                                .to = square_idx + 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx + 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                            });
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                    },
                    else => unreachable,
                }
            }
        } else {
            for (0..square_count) |square_idx_size| {
                // TODO: Refactor this usize and u8 bs
                const square_idx: u8 = @truncate(square_idx_size);
                if (board.squares[square_idx].is_white() or board.squares[square_idx] == .empty) {
                    continue;
                }
                switch (board.squares[square_idx]) {
                    .black_pawn => {
                        if (Rank.of(square_idx) == .r2) {
                            if (board.squares[square_idx - 8] == .empty) {
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        } else {
                            if (board.squares[square_idx - 8] == .empty) {
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                if (Rank.of(square_idx) == .r7 and board.squares[square_idx - 16] == .empty) {
                                    temporary.add(.{
                                        .to = square_idx - 16,
                                        .from = square_idx,
                                        .captured = .empty,
                                        .promoted = .empty,
                                        .en_passant_capture = false,
                                        .en_passant_square = square_idx - 8,
                                        .en_passant_square_past = board.en_passant,
                                    });
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fa and square_idx - 9 == board.en_passant) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fh and square_idx - 7 == board.en_passant) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                    },
                    .black_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 17].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 15].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 15].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 17].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fb and File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 10].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 6].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fg and File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 6].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 10].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else {
                                break;
                            }
                        }
                    },
                    .black_queen => {
                        for (0..8) |horizontal_idx_usize| {
                            const horizontal_idx: u8 = @truncate(horizontal_idx_usize + 1);
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx_usize| {
                            const diagonal_idx: u8 = @truncate(diagonal_idx_usize + 1);
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_white()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .black_king => {
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].is_black()) {
                            temporary.add(.{
                                .to = square_idx - 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx - 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                            });
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].is_black()) {
                            temporary.add(.{
                                .to = square_idx + 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx + 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                            });
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].is_black()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].is_black()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                });
                            }
                        }
                    },
                    else => unreachable,
                }
            }
        }

        for (0..temporary.move_count) |move_idx| {
            const color_check: Color = board.side_to_move;
            board.make_move(temporary.move[move_idx]);
            if (!board.is_check(color_check)) {
                this.add(temporary.move[move_idx]);
            } else {
                @import("std").debug.print("Skip => ", .{});
                temporary.move[move_idx].print();
            }
            board.undo_move(temporary.move[move_idx]);
        }
        this.print();
    }
    pub fn init() Movelist {
        const move_empty: Move = .{
            .from = 0,
            .to = 0,
            .en_passant_capture = false,
            .en_passant_square = 0,
            .en_passant_square_past = 0,
            .captured = .empty,
            .promoted = .empty,
        };
        const movelist: Movelist = .{
            .move = [1]Move{move_empty} ** move_count_max,
            .move_count = 0,
        };
        return movelist;
    }
    pub fn add(this: *@This(), move: Move) void {
        assert(this.move_count < move_count_max);
        this.move[this.move_count] = move;
        this.move_count += 1;
    }
    pub fn clear(this: *@This()) void {
        for (0..this.move_count) |move_idx| {
            this.move[move_idx] = .{
                .from = 0,
                .to = 0,
                .en_passant_capture = false,
                .en_passant_square = 0,
                .en_passant_square_past = 0,
                .captured = .empty,
                .promoted = .empty,
            };
        }
        this.move_count = 0;
    }
    pub fn print(this: *@This()) void {
        const std = @import("std");
        std.debug.print("Move count {} of {}\n", .{ this.move_count, move_count_max });
        for (0..this.move_count) |move_idx| {
            std.debug.print("[{d:3}] => ", .{
                move_idx,
            });
            this.move[move_idx].print();
        }
    }
};
