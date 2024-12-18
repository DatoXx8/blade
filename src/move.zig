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
    castle: Castle,
    // TODO: Figure out if there is a way to remove these
    en_passant_square_past: u8,
    fifty_move_past: u8,
    castle_perm_past: u8,
    pub fn print(this: *const @This()) void {
        const std = @import("std");
        std.debug.print("({d:2} to {d:2}, en_passant ({}, sq {d:2}, past {d:2}), captured {s}, promoted {s}, castle {s}, {})\n", .{
            this.from,
            this.to,
            this.en_passant_capture,
            this.en_passant_square,
            this.en_passant_square_past,
            switch (this.captured) {
                .empty => "-",
                .white_pawn => "P",
                .white_knight => "N",
                .white_bishop => "B",
                .white_rook => "R",
                .white_queen => "Q",
                .white_king => "K",
                .black_pawn => "p",
                .black_knight => "n",
                .black_bishop => "b",
                .black_rook => "r",
                .black_queen => "q",
                .black_king => "k",
            },
            switch (this.promoted) {
                .empty => "-",
                .white_pawn => "P",
                .white_knight => "N",
                .white_bishop => "B",
                .white_rook => "R",
                .white_queen => "Q",
                .white_king => "K",
                .black_pawn => "p",
                .black_knight => "n",
                .black_bishop => "b",
                .black_rook => "r",
                .black_queen => "q",
                .black_king => "k",
            },
            switch (this.castle) {
                .none => "-",
                .white_kingside => "K",
                .white_queenside => "Q",
                .black_kingside => "k",
                .black_queenside => "q",
            },
            this.castle_perm_past,
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
            if (@as(u1, @truncate(board.castle >> @intFromEnum(Castle.white_kingside))) == 1 and
                board.squares[5] == .empty and board.squares[6] == .empty and board.squares[7] == .white_rook and
                !board.isSquareAttacked(5, .white) and !board.isSquareAttacked(6, .white))
            {
                temporary.add(.{
                    .to = 6,
                    .from = 4,
                    .captured = .empty,
                    .promoted = .empty,
                    .en_passant_capture = false,
                    .en_passant_square = 0,
                    .en_passant_square_past = board.en_passant,
                    .fifty_move_past = board.fifty_move,
                    .castle_perm_past = board.castle,
                    .castle = .white_kingside,
                });
            }
            if (@as(u1, @truncate(board.castle >> @intFromEnum(Castle.white_queenside))) == 1 and board.squares[0] == .white_rook and
                board.squares[1] == .empty and board.squares[2] == .empty and
                board.squares[3] == .empty and !board.isSquareAttacked(1, .white) and
                !board.isSquareAttacked(2, .white) and !board.isSquareAttacked(3, .white))
            {
                temporary.add(.{
                    .to = 2,
                    .from = 4,
                    .captured = .empty,
                    .promoted = .empty,
                    .en_passant_capture = false,
                    .en_passant_square = 0,
                    .en_passant_square_past = board.en_passant,
                    .fifty_move_past = board.fifty_move,
                    .castle_perm_past = board.castle,
                    .castle = .white_queenside,
                });
            }

            for (0..square_count) |square_idx_size| {
                // TODO: Refactor this usize and u8 bs
                const square_idx: u8 = @truncate(square_idx_size);
                if (board.squares[square_idx].isBlack() or board.squares[square_idx] == .empty) {
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle_perm_past = board.castle,
                                    .castle = .none,
                                });
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                        .fifty_move_past = board.fifty_move,
                                        .castle = .none,
                                        .castle_perm_past = board.castle,
                                    });
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                    },
                    .white_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 17].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 15].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 15].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 17].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fb and File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 10].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 6].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fg and File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 6].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 10].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                break;
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                break;
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .white_king => {
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].isWhite()) {
                            temporary.add(.{
                                .to = square_idx - 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx - 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                                .fifty_move_past = board.fifty_move,
                                .castle = .none,
                                .castle_perm_past = board.castle,
                            });
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].isWhite()) {
                            temporary.add(.{
                                .to = square_idx + 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx + 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                                .fifty_move_past = board.fifty_move,
                                .castle = .none,
                                .castle_perm_past = board.castle,
                            });
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                    },
                    else => unreachable,
                }
            }
        } else {
            if (@as(u1, @truncate(board.castle >> @intFromEnum(Castle.black_kingside))) == 1 and
                board.squares[61] == .empty and board.squares[62] == .empty and board.squares[63] == .black_rook and
                !board.isSquareAttacked(61, .black) and !board.isSquareAttacked(62, .black))
            {
                temporary.add(.{
                    .to = 62,
                    .from = 60,
                    .captured = .empty,
                    .promoted = .empty,
                    .en_passant_capture = false,
                    .en_passant_square = 0,
                    .en_passant_square_past = board.en_passant,
                    .fifty_move_past = board.fifty_move,
                    .castle_perm_past = board.castle,
                    .castle = .black_kingside,
                });
            }
            if (@as(u1, @truncate(board.castle >> @intFromEnum(Castle.black_queenside))) == 1 and board.squares[60] == .black_rook and
                board.squares[57] == .empty and board.squares[58] == .empty and
                board.squares[59] == .empty and !board.isSquareAttacked(57, .black) and
                !board.isSquareAttacked(58, .black) and !board.isSquareAttacked(59, .black))
            {
                temporary.add(.{
                    .to = 58,
                    .from = 60,
                    .captured = .empty,
                    .promoted = .empty,
                    .en_passant_capture = false,
                    .en_passant_square = 0,
                    .en_passant_square_past = board.en_passant,
                    .fifty_move_past = board.fifty_move,
                    .castle_perm_past = board.castle,
                    .castle = .black_queenside,
                });
            }

            for (0..square_count) |square_idx_size| {
                // TODO: Refactor this usize and u8 bs
                const square_idx: u8 = @truncate(square_idx_size);
                if (board.squares[square_idx].isWhite() or board.squares[square_idx] == .empty) {
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                        .fifty_move_past = board.fifty_move,
                                        .castle = .none,
                                        .castle_perm_past = board.castle,
                                    });
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                    },
                    .black_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 17].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 15].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r2 and Rank.of(square_idx) != .r1 and !board.squares[square_idx - 15].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 15,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 15],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r7 and Rank.of(square_idx) != .r8 and !board.squares[square_idx + 17].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 17,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fb and File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 10].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 6].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fg and File.of(square_idx) != .fh) {
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 6].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 6,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 10].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 10,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                break;
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
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
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                break;
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].isWhite()) {
                                temporary.add(.{
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .black_king => {
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].isBlack()) {
                            temporary.add(.{
                                .to = square_idx - 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx - 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                                .fifty_move_past = board.fifty_move,
                                .castle = .none,
                                .castle_perm_past = board.castle,
                            });
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].isBlack()) {
                            temporary.add(.{
                                .to = square_idx + 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx + 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                                .en_passant_square_past = board.en_passant,
                                .fifty_move_past = board.fifty_move,
                                .castle = .none,
                                .castle_perm_past = board.castle,
                            });
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].isBlack()) {
                                temporary.add(.{
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                    .en_passant_square_past = board.en_passant,
                                    .fifty_move_past = board.fifty_move,
                                    .castle = .none,
                                    .castle_perm_past = board.castle,
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

            board.makeMove(temporary.move[move_idx]);

            if (!board.isCheck(color_check)) {
                this.add(temporary.move[move_idx]);
            }

            board.undoMove(temporary.move[move_idx]);
        }
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
            .fifty_move_past = 0,
            .castle = .none,
            .castle_perm_past = 0,
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
                .fifty_move_past = 0,
                .castle = .none,
                .castle_perm_past = 0,
            };
        }
        this.move_count = 0;
    }
    pub fn print(this: *const @This()) void {
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
