#ifndef ENGINE_H_
#define ENGINE_H_

#include "nn.h"
#include "chess.h"

#define white_pawn_activity 0.01
#define white_pawn_capture 0.02
#define white_knight_activity 0.025
#define white_knight_capture 0.01
#define white_bishop_activity 0.03
#define white_bishop_capture 0.01
#define white_rook_activity 0.05
#define white_rook_capture 0.01
#define white_queen_activity 0.1
#define white_queen_capture 0.005
#define white_king_activity -0.1
#define white_king_capture 0.2
#define white_king_life 10

#define black_pawn_activity (-(white_pawn_activity))
#define black_pawn_capture (-(white_pawn_capture))
#define black_knight_activity (-(white_knight_activity))
#define black_knight_capture (-(white_knight_capture))
#define black_bishop_activity (-(white_bishop_activity))
#define black_bishop_capture (-(white_bishop_capture))
#define black_rook_activity (-(white_rook_activity))
#define black_rook_capture (-(white_rook_capture))
#define black_queen_activity (-(white_queen_activity))
#define black_queen_capture (-(white_queen_capture))
#define black_king_activity (-(white_king_activity))
#define black_king_capture (-(white_king_capture))
#define black_king_life (-(white_king_life))

#define SEARCH_DEPTH 5
enum player_e {
    human_e, random_e, simple_e, nn_e
};
typedef struct {
    enum player_e type;
    nn_t *nn;
} agent_t;

extern double activity_eval(board_t *board);
extern uint64_t simple_move(board_t *board);
extern uint64_t pick_move(board_t *board, agent_t *agent);
extern double alpha_beta(board_t *board, double alpha, double beta, uint64_t depth, uint64_t *best_index);

#endif
