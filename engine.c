#include <stdio.h>
#include <stdlib.h>

#include "engine.h"
#include "chess.h"

double activity_eval(board_t *board) {
    double eval = 0;
    int64_t direction, offset;
    for(int64_t square = board_bottom; square <= board_top; square++) {
        switch(board->square[square]) {
            case no_piece: {
                break;
            }
            case white_pawn: {
                if(rank(square) < r_7) {
                    if(board->square[square + 8] == no_piece) {
                        eval += white_pawn_activity;
                        if(rank(square) == r_2) {
                            if(board->square[square + 16] == no_piece) {
                                eval += white_pawn_activity;
                            }
                        }
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] < no_piece) {
                            eval += white_pawn_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] < no_piece) {
                            eval += white_pawn_capture;
                        }
                    }
                } else {
                    if(board->square[square + 8] == no_piece) {
                        eval += white_pawn_activity;
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] < no_piece) {
                            eval += white_pawn_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] < no_piece) {
                            eval += white_pawn_capture;
                        }
                    }
                }
                break;
            }
            case black_pawn: {
                if(rank(square) > r_2) {
                    if(board->square[square - 8] == no_piece) {
                        eval += black_pawn_activity;
                        if(rank(square) == r_7) {
                            if(board->square[square - 16] == no_piece) {
                                eval += black_pawn_activity;
                            }
                        }
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] > no_piece) {
                            eval += black_pawn_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] > no_piece) {
                            eval += black_pawn_capture;
                        }
                    }
                } else {
                    if(board->square[square - 8] == no_piece) {
                        eval += black_pawn_activity;
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] > no_piece) {
                            eval += black_pawn_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] > no_piece) {
                            eval += black_pawn_capture;
                        }
                    }
                }
                break;
            }
            case white_knight: {
                if(rank(square) > r_1) {
                    if(file(square) > f_b) {
                        if(board->square[square - 10] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square - 10] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square - 6] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square - 6] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                }
                if(rank(square) > r_2) {
                    if(file(square) > f_a) {
                        if(board->square[square - 17] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square - 17] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 15] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square - 15] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                }
                if(rank(square) < r_7) {
                    if(file(square) > f_a) {
                        if(board->square[square + 15] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square + 15] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 17] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square + 17] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(file(square) > f_b) {
                        if(board->square[square + 6] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square + 6] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square + 10] < no_piece) {
                            eval += white_knight_capture;
                        } else if(board->square[square + 10] == no_piece) {
                            eval += white_knight_activity;
                        }
                    }
                }
                break;
            }
            case black_knight: {
                if(rank(square) > r_1) {
                    if(file(square) > f_b) {
                        if(board->square[square - 10] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square - 10] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square - 6] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square - 6] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                }
                if(rank(square) > r_2) {
                    if(file(square) > f_a) {
                        if(board->square[square - 17] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square - 17] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 15] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square - 15] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                }
                if(rank(square) < r_7) {
                    if(file(square) > f_a) {
                        if(board->square[square + 15] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square + 15] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 17] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square + 17] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(file(square) > f_b) {
                        if(board->square[square + 6] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square + 6] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square + 10] > no_piece) {
                            eval += black_knight_capture;
                        } else if(board->square[square + 10] == no_piece) {
                            eval += black_knight_activity;
                        }
                    }
                }
                break;
            }
            case white_bishop: {
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_bishop_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -7;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_bishop_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 7;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_bishop_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 9;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_bishop_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case black_bishop: {
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_bishop_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -7;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_bishop_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 7;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_bishop_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 9;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_bishop_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_bishop_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case white_rook: {
                direction = -8;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(board->square[square + offset] == no_piece) {
                        eval += white_rook_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -1;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_rook_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 1;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_rook_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 8;
                offset = direction;
                while(square + offset <= board_top) {
                    if(board->square[square + offset] == no_piece) {
                        eval += white_rook_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case black_rook: {
                direction = -8;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(board->square[square + offset] == no_piece) {
                        eval += black_rook_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -1;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_rook_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 1;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_rook_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 8;
                offset = direction;
                while(square + offset <= board_top) {
                    if(board->square[square + offset] == no_piece) {
                        eval += black_rook_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_rook_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case white_queen: {
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -7;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 7;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 9;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -8;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -1;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 1;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 8;
                offset = direction;
                while(square + offset <= board_top) {
                    if(board->square[square + offset] == no_piece) {
                        eval += white_queen_activity;
                    } else if(board->square[square + offset] < no_piece) {
                        eval += white_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case black_queen: {
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -7;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 7;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 9;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                        break;
                    } else if(board->square[square + offset] > no_piece){
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -8;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = -1;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 1;
                offset = direction;
                while(square + offset <= board_top) {
                    if(file(square + offset) == f_a) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                direction = 8;
                offset = direction;
                while(square + offset <= board_top) {
                    if(board->square[square + offset] == no_piece) {
                        eval += black_queen_activity;
                    } else if(board->square[square + offset] > no_piece) {
                        eval += black_queen_capture;
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case white_king: {
                eval += white_king_life;
                if(file(square) > f_a) {
                    if(board->square[square - 1] == no_piece) {
                        eval += white_king_activity;
                    } else if(board->square[square - 1] < no_piece) {
                        eval += white_king_capture;
                    }
                }
                if(file(square) < f_h) {
                    if(board->square[square + 1] == no_piece) {
                        eval += white_king_activity;
                    } else if(board->square[square + 1] < no_piece) {
                        eval += white_king_capture;
                    }
                }
                if(rank(square) > r_1) {
                    if(board->square[square - 8] == no_piece) {
                        eval += white_king_activity;
                    } else if(board->square[square - 8] < no_piece) {
                        eval += white_king_capture;
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] == no_piece) {
                            eval += white_king_activity;
                        } else if(board->square[square - 9] < no_piece) {
                            eval += white_king_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] == no_piece) {
                            eval += white_king_activity;
                        } else if(board->square[square - 7] < no_piece) {
                            eval += white_king_capture;
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(board->square[square + 8] == no_piece) {
                        eval += white_king_activity;
                    } else if(board->square[square + 8] < no_piece) {
                        eval += white_king_capture;
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] == no_piece) {
                            eval += white_king_activity;
                        } else if(board->square[square + 7] < no_piece) {
                            eval += white_king_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] == no_piece) {
                            eval += white_king_activity;
                        } else if(board->square[square + 9] < no_piece) {
                            eval += white_king_capture;
                        }
                    }
                }
                break;
            }
            case black_king: {
                eval += black_king_life;
                if(file(square) > f_a) {
                    if(board->square[square - 1] == no_piece) {
                        eval += black_king_activity;
                    } else if(board->square[square - 1] > no_piece) {
                        eval += black_king_capture;
                    }
                }
                if(file(square) < f_h) {
                    if(board->square[square + 1] == no_piece) {
                        eval += black_king_activity;
                    } else if(board->square[square + 1] > no_piece) {
                        eval += black_king_capture;
                    }
                }
                if(rank(square) > r_1) {
                    if(board->square[square - 8] == no_piece) {
                        eval += black_king_activity;
                    } else if(board->square[square - 8] > no_piece) {
                        eval += black_king_capture;
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] == no_piece) {
                            eval += black_king_activity;
                        } else if(board->square[square - 9] > no_piece) {
                            eval += black_king_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] == no_piece) {
                            eval += black_king_activity;
                        } else if(board->square[square - 7] > no_piece) {
                            eval += black_king_capture;
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(board->square[square + 8] == no_piece) {
                        eval += black_king_activity;
                    } else if(board->square[square + 8] > no_piece) {
                        eval += black_king_capture;
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] == no_piece) {
                            eval += black_king_activity;
                        } else if(board->square[square + 7] > no_piece) {
                            eval += black_king_capture;
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] == no_piece) {
                            eval += black_king_activity;
                        } else if(board->square[square + 9] > no_piece) {
                            eval += black_king_capture;
                        }
                    }
                }
                break;
            }
            default: {
                fprintf(stderr, "ERROR: Invalid piece %ld at square %ld in activity evaluation\n", board->square[square], square);
                exit(1);
            }
        }
    }
    return(eval);
}
double alpha_beta(board_t *board, double alpha, double beta, uint64_t depth, uint64_t *best_index) {
    /* Algorithm on wikipedia */
    return(0);
}
uint64_t pick_move(board_t *board, agent_t *agent) {
    switch(agent->type) {
        case(human_e): {
            char from_square[3];
            int64_t from;
            char to_square[3];
            int64_t to;
            board_print(board);
            printf("Input your move: ");
            scanf("%s %s", from_square, to_square);
            printf("\n");
            from = from_square[0] - 'a' + 8 * (from_square[1] - '1');
            to = to_square[0] - 'a' + 8 * (to_square[1] - '1');
            for(int64_t i = 0; i < movelist_count(board->movelist); i++) {
                if(board->movelist[i].from_square == from && board->movelist[i].to_square == to) {
                    return(i);
                }
            }
            break;
        }
        case(simple_e): {
            uint64_t best_index;
            alpha_beta(board, -10000, 10000, SEARCH_DEPTH, &best_index);
            return(best_index);
            break;
        }
        case(nn_e): {
            break;
        }
        case(random_e): {
            return(rand() % movelist_count(board->movelist));
        }
    }
    fprintf(stderr, "ERROR: Unable to choose a move\n");
    exit(1);
}
void play_game(board_t *board, agent_t *a1, agent_t *a2) {
    while(true) {
    }
}
