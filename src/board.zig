const assert = @import("./util.zig").assert;

const Move = @import("./move.zig").Move;
const Movelist = @import("./move.zig").Movelist;
const move_count_max = @import("./move.zig").move_count_max;

pub const Color = enum(u1) {
    white,
    black,
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
        if (move.castle == .none) {
            assert(this.squares[move.to] == move.captured);
            if (move.en_passant) {
                assert(false);
            } else {
                if (move.promoted == .empty) {
                    this.squares[move.to] = this.squares[move.from];
                } else {
                    this.squares[move.to] = move.promoted;
                }
                this.squares[move.from] = .empty;
            }
        } else {
            assert(false);
        }
        this.side_to_move = switch (this.side_to_move) {
            .white => .black,
            .black => .white,
        };
        // This is 0 in case en passant is not possible
        this.en_passant = move.en_passant_square;
        this.castle = move.castle_perm;
    }
    pub fn undo_move(this: *@This(), move: Move) void {
        if (move.castle == .none) {
            assert(this.squares[move.from] == .empty);
            if (move.en_passant) {
                assert(false);
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
        } else {
            assert(false);
        }
        this.side_to_move = switch (this.side_to_move) {
            .white => .black,
            .black => .white,
        };
        this.en_passant = move.en_passant_square_past;
        this.castle = move.castle_perm_past;
    }
    pub fn print(this: *const @This(), writer: anytype) !void {
        // Print this way to have a1 be the bottom left square with index 0
        try writer.print("   a b c d e f g h\n", .{});
        for (0..8) |row_idx| {
            try writer.print("{} ", .{8 - row_idx});
            for (0..8) |column_idx| {
                const square_idx: usize = (8 - (row_idx + 1)) * 8 + column_idx;
                try writer.print(" {s}", .{
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
            try writer.print("\n", .{});
        }
        try writer.print("To move: {s}\n", .{
            switch (this.side_to_move) {
                .white => "w",
                .black => "b",
            },
        });
    }
    pub fn debug(this: *const @This(), writer: anytype) !void {
        try writer.print("      a      b      c      d      e      f      g      h\n", .{});
        for (0..8) |row_idx| {
            try writer.print("{} ", .{8 - row_idx});
            for (0..8) |column_idx| {
                const square_idx: usize = (8 - (row_idx + 1)) * 8 + column_idx;
                try writer.print("({d:2} {s}) ", .{ square_idx, switch (this.squares[square_idx]) {
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
            try writer.print("\n", .{});
        }
        try writer.print("To move: {s}\n", .{
            switch (this.side_to_move) {
                .white => "w",
                .black => "b",
            },
        });
        if (this.en_passant != 0) {
            try writer.print("En passant: {c}{c} = {}\n", .{
                'a' + (this.en_passant % 8),
                '1' + @divFloor(this.en_passant, 8),
                this.en_passant,
            });
        } else {
            try writer.print("En passant: ---\n", .{});
        }
        try writer.print("Fifty move: {}\n", .{this.fifty_move});
        if (this.castle == 0) {
            try writer.print("Castle rights: ---\n", .{});
        } else {
            try writer.print("Castle rights: {s}{s}{s}{s}\n", .{
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
