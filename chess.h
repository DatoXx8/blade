#ifndef CHESS_H_
#define CHESS_H_

#include <stdbool.h>
#include <stdint.h>

#define starting_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

#define black ((int64_t) -1)
#define draw ((int64_t) 0)
#define white ((int64_t) 1)
#define no_result ((int64_t) 2)

#define r_1 ((int64_t) 0)
#define r_2 ((int64_t) 1)
#define r_3 ((int64_t) 2)
#define r_4 ((int64_t) 3)
#define r_5 ((int64_t) 4)
#define r_6 ((int64_t) 5)
#define r_7 ((int64_t) 6)
#define r_8 ((int64_t) 7)
#define f_a ((int64_t) 0)
#define f_b ((int64_t) 1)
#define f_c ((int64_t) 2)
#define f_d ((int64_t) 3)
#define f_e ((int64_t) 4)
#define f_f ((int64_t) 5)
#define f_g ((int64_t) 6)
#define f_h ((int64_t) 7)

#define black_king ((int64_t) -6)
#define black_queen ((int64_t) -5)
#define black_rook ((int64_t) -4)
#define black_bishop ((int64_t) -3)
#define black_knight ((int64_t) -2)
#define black_pawn ((int64_t) -1)
#define no_piece ((int64_t) 0)
#define white_pawn ((int64_t) 1)
#define white_knight ((int64_t) 2)
#define white_bishop ((int64_t) 3)
#define white_rook ((int64_t) 4)
#define white_queen ((int64_t) 5)
#define white_king ((int64_t) 6)

#define number_of_squares ((int64_t) 64)
#define no_square ((int64_t) -1)
#define max_moves ((int64_t) 219)
#define board_bottom ((int64_t) 0)
#define board_top ((int64_t) 63)

/* TODO: Implement castling */

typedef struct {
    int64_t from_square;
    int64_t to_square;
    int64_t captured_piece;
    int64_t promoted_piece;
    int64_t en_passant_square;
    int64_t past_en_passant_square;
    int64_t fifty_move; /* Actually has to be 100 cuz it counts half moves */
    int64_t past_fifty_move;
    bool is_en_passant;
} move_t;
typedef struct {
    move_t *movelist;
    move_t *temporary;
    int64_t square[number_of_squares];
    int64_t side_to_move;
    int64_t fifty_move;
    // int64_t total_moves;
    int64_t en_passant_square;
    int64_t white_king_square;
    int64_t black_king_square;
} board_t;

extern int64_t rank(int64_t square);
extern int64_t file(int64_t square);
extern void square_name(int64_t square, char *name);
extern int64_t square_index(char *name);

extern void move_set(move_t *move, int64_t from_square, int64_t to_square, int64_t captured_piece, int64_t promoted_piece, int64_t en_passant_square, int64_t past_en_passant_square, int64_t fifty_move, int64_t past_fifty_move, bool is_en_passant);
extern void move_copy(move_t *move1, move_t *move2);
extern void move_reset(move_t *move);
extern bool move_is_empty(move_t *move);
extern void move_print(move_t *move);

extern int64_t movelist_count(move_t *movelist);
extern void movelist_reset(move_t *movelist);
extern void movelist_print(move_t *movelist);

extern board_t board_alloc(void);
extern void board_free(board_t *board);
extern void board_copy(board_t *board1, board_t *board2);
extern void board_print(board_t *board);
extern void board_debug(board_t *board);
extern void board_from_fen(board_t *board, char *fen);
extern void board_pseudolegal_moves(board_t *board);
extern void board_legal_moves(board_t *board);
extern bool board_check(board_t *board);
extern int64_t board_score(board_t *board);

extern void board_make_move(board_t *board, move_t *move);
extern void board_undo_move(board_t *board, move_t *move);

extern void board_user_move(board_t *board);
extern void user_game(board_t *board);
extern void random_game(board_t *board);

#endif // !CHESS_H_
