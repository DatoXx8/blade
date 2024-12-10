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
};

pub const move_count_max: u8 = 219;
pub const Movelist = struct {
    move_count: u8,
    move: [move_count_max]Move,
    pub fn generate(this: *@This(), board: *const Board) void {
        assert(this.move_count == 0);
        if (board.side_to_move == .white) {
            for (0..square_count) |square_idx| {
                if (board.squares[square_idx].is_black() or board.squares[square_idx] == .empty) {
                    continue;
                }
                switch (board.squares[square_idx]) {
                    .white_pawn => {
                        if (Rank.of(square_idx) == .r7) {
                            if (board.squares[square_idx + 8] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7],
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7],
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7],
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7],
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9],
                                    .promoted = .white_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9],
                                    .promoted = .white_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9],
                                    .promoted = .white_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9],
                                    .promoted = .white_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        } else {
                            if (board.squares[square_idx + 8] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                if (Rank.of(square_idx) == .r2 and board.squares[square_idx + 16] == .empty) {
                                    this.add(.{
                                        .castle = .none,
                                        .to = square_idx + 16,
                                        .from = square_idx,
                                        .captured = .empty,
                                        .promoted = .empty,
                                        .en_passant_capture = false,
                                        .en_passant_square = square_idx + 8,
                                    });
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx + 7].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fa and square_idx + 7 == board.en_passant) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx + 9].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fh and square_idx + 9 == board.en_passant) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                    },
                    .white_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) > .r2 and !board.squares[square_idx - 17].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) < .r7 and !board.squares[square_idx - 17].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                        if (File.of(square_idx) > .fb) {
                            if (Rank.of(square_idx) > .r1 and !board.squares[square_idx - 10].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 10,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) < .r8 and !board.squares[square_idx + 6].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 6,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                        if (File.of(square_idx) < .fg) {
                            if (Rank.of(square_idx) > .r1 and !board.squares[square_idx - 6].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 6,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) < .r8 and !board.squares[square_idx + 10].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 10,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                    },
                    .white_bishop => {
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 9 * diagonal_idx) == .fh or square_idx - 9 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 7 * diagonal_idx) == .fa or square_idx - 7 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .white_rook => {
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx].is_black(),
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx - horizontal_idx) == .fh or square_idx - horizontal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx - 8 * vertical_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                    },
                    .white_queen => {
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx].is_black(),
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx - horizontal_idx) == .fh or square_idx - horizontal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx - 8 * vertical_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 9 * diagonal_idx) == .fh or square_idx - 9 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 7 * diagonal_idx) == .fa or square_idx - 7 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .white_king => {
                        // TODO: This could probably be refactored to be outside of the for loop
                        if (@as(u1, @truncate(board.castle << Castle.white_kingside)) == 1 and
                            board.squares[5] == .empty and board.squares[6] == .empty)
                        {
                            this.add(.{
                                .castle = .white_kingside,
                                .to = 6,
                                .from = 4,
                                .captured = .empty,
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (@as(u1, @truncate(board.castle << Castle.white_queenside)) == 1 and
                            board.squares[1] == .empty and board.squares[2] == .empty and
                            board.squares[3] == .empty)
                        {
                            this.add(.{
                                .castle = .white_kingside,
                                .to = 2,
                                .from = 4,
                                .captured = .empty,
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].is_white()) {
                            this.add(.{
                                .castle = .none,
                                .to = square_idx - 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx - 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].is_white()) {
                            this.add(.{
                                .castle = .none,
                                .to = square_idx + 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx + 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                    },
                    else => assert(false),
                }
            }
        } else {
            for (0..square_count) |square_idx| {
                if (board.squares[square_idx].is_white() or board.squares[square_idx] == .empty) {
                    continue;
                }
                switch (board.squares[square_idx]) {
                    .black_pawn => {
                        if (Rank.of(square_idx) == .r2) {
                            if (board.squares[square_idx - 8] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9],
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9],
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9],
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9],
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7],
                                    .promoted = .black_queen,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7],
                                    .promoted = .black_rook,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7],
                                    .promoted = .black_bishop,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7],
                                    .promoted = .black_knight,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        } else {
                            if (board.squares[square_idx - 8] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                if (Rank.of(square_idx) == .r7 and board.squares[square_idx - 16] == .empty) {
                                    this.add(.{
                                        .castle = .none,
                                        .to = square_idx - 16,
                                        .from = square_idx,
                                        .captured = .empty,
                                        .promoted = .empty,
                                        .en_passant_capture = false,
                                        .en_passant_square = square_idx - 8,
                                    });
                                }
                            }
                            if (File.of(square_idx) != .fa and board.squares[square_idx - 9].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fa and square_idx - 9 == board.en_passant) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                });
                            }
                            if (File.of(square_idx) != .fh and board.squares[square_idx - 7].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            // Could explicitly check that the pawn is on the 4th rank but that is unnecessary
                            if (File.of(square_idx) != .fh and square_idx - 7 == board.en_passant) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = true,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                    },
                    .black_knight => {
                        if (File.of(square_idx) != .fa) {
                            if (Rank.of(square_idx) > .r2 and !board.squares[square_idx - 17].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) < .r7 and !board.squares[square_idx - 17].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 17,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 17],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                        if (File.of(square_idx) > .fb) {
                            if (Rank.of(square_idx) > .r1 and !board.squares[square_idx - 10].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 10,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) < .r8 and !board.squares[square_idx + 6].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 6,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                        if (File.of(square_idx) < .fg) {
                            if (Rank.of(square_idx) > .r1 and !board.squares[square_idx - 6].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 6,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 6],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) < .r8 and !board.squares[square_idx + 10].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 10,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 10],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                    },
                    .black_bishop => {
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 9 * diagonal_idx) == .fh or square_idx - 9 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 7 * diagonal_idx) == .fa or square_idx - 7 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .black_rook => {
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx].is_white(),
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx - horizontal_idx) == .fh or square_idx - horizontal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx - 8 * vertical_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                    },
                    .black_queen => {
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx + horizontal_idx) == .fa or square_idx + horizontal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + horizontal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + horizontal_idx].is_white(),
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |horizontal_idx| {
                            if (File.of(square_idx - horizontal_idx) == .fh or square_idx - horizontal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - horizontal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - horizontal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - horizontal_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - horizontal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx + 8 * vertical_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 8 * vertical_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |vertical_idx| {
                            if (square_idx - 8 * vertical_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 8 * vertical_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 8 * vertical_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 8 * vertical_idx,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 8 * vertical_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 9 * diagonal_idx) == .fa or square_idx + 9 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 9 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx + 7 * diagonal_idx) == .fh or square_idx + 7 * diagonal_idx > 63) {
                                break;
                            }
                            if (board.squares[square_idx + 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx + 7 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx + 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 9 * diagonal_idx) == .fh or square_idx - 9 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 9 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 9 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 9 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                        for (0..8) |diagonal_idx| {
                            if (File.of(square_idx - 7 * diagonal_idx) == .fa or square_idx - 7 * diagonal_idx < 0) {
                                break;
                            }
                            if (board.squares[square_idx - 7 * diagonal_idx] == .empty) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .empty,
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            } else if (board.squares[square_idx - 7 * diagonal_idx].is_white()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7 * diagonal_idx,
                                    .from = square_idx,
                                    .captured = .board.squares[square_idx - 7 * diagonal_idx],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                                break;
                            } else {
                                break;
                            }
                        }
                    },
                    .black_king => {
                        // TODO: This could probably be refactored to be outside of the for loop
                        if (@as(u1, @truncate(board.castle << Castle.black_kingside)) == 1 and
                            board.squares[61] == .empty and board.squares[62] == .empty)
                        {
                            this.add(.{
                                .castle = .black_kingside,
                                .to = 62,
                                .from = 60,
                                .captured = .empty,
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (@as(u1, @truncate(board.castle << Castle.black_queenside)) == 1 and
                            board.squares[57] == .empty and board.squares[58] == .empty and
                            board.squares[59] == .empty)
                        {
                            this.add(.{
                                .castle = .black_kingside,
                                .to = 58,
                                .from = 60,
                                .captured = .empty,
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 8].is_black()) {
                            this.add(.{
                                .castle = .none,
                                .to = square_idx - 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx - 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 8].is_black()) {
                            this.add(.{
                                .castle = .none,
                                .to = square_idx + 8,
                                .from = square_idx,
                                .captured = board.squares[square_idx + 8],
                                .promoted = .empty,
                                .en_passant_capture = false,
                                .en_passant_square = 0,
                            });
                        }
                        if (File.of(square_idx) != .fa) {
                            if (!board.squares[square_idx - 1].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 9].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 7].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                        if (File.of(square_idx) != .fh) {
                            if (!board.squares[square_idx + 1].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 1,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 1],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r1 and !board.squares[square_idx - 7].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx - 7,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx - 7],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                            if (Rank.of(square_idx) != .r8 and !board.squares[square_idx + 9].is_black()) {
                                this.add(.{
                                    .castle = .none,
                                    .to = square_idx + 9,
                                    .from = square_idx,
                                    .captured = board.squares[square_idx + 9],
                                    .promoted = .empty,
                                    .en_passant_capture = false,
                                    .en_passant_square = 0,
                                });
                            }
                        }
                    },
                    else => assert(false),
                }
            }
        }
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
                .en_passant = false,
                .captured = .empty,
                .promoted = .empty,
                .castle = .none,
            };
        }
        this.move_count = 0;
    }
};
