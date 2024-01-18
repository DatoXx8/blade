#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>

#include "chess.h"

int64_t rank(int64_t square)  {
    return(square / 8);
}
int64_t file(int64_t square) {
    return(square % 8);
}
void square_name(int64_t square, char *name) {
    name[0] = 'a' + file(square);
    name[1] = '1' + rank(square);
}
int64_t square_index(char *name) {
    return((name[0] - 'a') + 8 * (name[1] - '1'));
}

void move_set(move_t *move, int64_t from_square, int64_t to_square, int64_t captured_piece, int64_t promoted_piece, int64_t en_passant_square, int64_t past_en_passant_square, int64_t fifty_move, int64_t past_fifty_move, bool is_en_passant) {
    move->from_square = from_square;
    move->to_square = to_square;
    move->captured_piece = captured_piece;
    move->promoted_piece = promoted_piece;
    move->en_passant_square = en_passant_square;
    move->past_en_passant_square = past_en_passant_square;
    move->fifty_move = fifty_move;
    move->past_fifty_move = past_fifty_move;
    move->is_en_passant = is_en_passant;
}
void move_copy(move_t *move1, move_t *move2) {
    move1->from_square = move2->from_square;
    move1->to_square = move2->to_square;
    move1->captured_piece = move2->captured_piece;
    move1->promoted_piece = move2->promoted_piece;
    move1->en_passant_square = move2->en_passant_square;
    move1->past_en_passant_square = move2->past_en_passant_square;
    move1->fifty_move = move2->fifty_move;
    move1->past_fifty_move = move2->past_fifty_move;
    move1->is_en_passant = move2->is_en_passant;
}
void move_reset(move_t *move) {
    move->from_square = 0;
    move->to_square = 0;
    move->captured_piece = 0;
    move->promoted_piece = 0;
    move->en_passant_square = 0;
    move->past_en_passant_square = 0;
    move->fifty_move = 0;
    move->past_fifty_move = 0;
    move->is_en_passant = 0;
}
bool move_is_empty(move_t *move) {
    return(move->to_square == move->from_square);
}
const char piece_names[] = "kqrbnp_PNBRQK";
void move_print(move_t *move) {
    char square[2];
    square_name(move->from_square, square);
    printf("%2ld %s, ", move->from_square, square);
    square_name(move->to_square, square);
    printf("%2ld %s, ", move->to_square, square);
    printf("%ld %c, ", move->captured_piece, piece_names[move->captured_piece + 6]);
    printf("%ld %c, ", move->promoted_piece, piece_names[move->promoted_piece + 6]);
    square_name(move->en_passant_square, square);
    printf("%2ld %s, ", move->en_passant_square, square);
    square_name(move->past_en_passant_square, square);
    printf("%2ld %s, ", move->past_en_passant_square, square);
    printf("%ld, ", move->fifty_move);
    printf("%ld, ", move->past_fifty_move);
    printf("%b\n", move->is_en_passant);
}

int64_t movelist_count(move_t *movelist) {
    for(int64_t i = 0; i < max_moves; i++) {
        if(move_is_empty(&movelist[i])) {
            return(i);
        }
    }
    return(max_moves);
}
void movelist_reset(move_t *movelist) {
    for(int64_t i = 0; i < max_moves; i++) {
        move_reset(&movelist[i]);
    }
}
void movelist_print(move_t *movelist) {
    char square[2];
    int64_t count = movelist_count(movelist);
    for(int64_t i = 0; i < count; i++) {
        square_name(movelist[i].from_square, square);
        printf("[%3ld] => %2ld %s, ", i, movelist[i].from_square, square);
        square_name(movelist[i].to_square, square);
        printf("%2ld %s, ", movelist[i].to_square, square);
        printf("%ld %c, ", movelist[i].captured_piece, piece_names[movelist[i].captured_piece + 6]);
        printf("%ld %c, ", movelist[i].promoted_piece, piece_names[movelist[i].promoted_piece + 6]);
        square_name(movelist[i].en_passant_square, square);
        printf("%2ld %s, ", movelist[i].en_passant_square, square);
        square_name(movelist[i].past_en_passant_square, square);
        printf("%2ld %s, ", movelist[i].past_en_passant_square, square);
        printf("%ld, ", movelist[i].fifty_move);
        printf("%ld, ", movelist[i].past_fifty_move);
        printf("%b\n", movelist[i].is_en_passant);
    }
}

board_t board_alloc(void) {
    board_t board = {0};
    board.movelist = calloc(max_moves, sizeof(move_t));
    board.temporary = calloc(max_moves, sizeof(move_t));
    return(board);
}
void board_free(board_t *board) {
    free(board->movelist);
    free(board->temporary);
}
void board_copy(board_t *board1, board_t *board2) {
    board1->fifty_move = board2->fifty_move;
    board1->side_to_move = board2->side_to_move;
    board1->black_king_square = board2->black_king_square;
    board1->white_king_square = board2->white_king_square;
    board1->en_passant_square = board2->en_passant_square;
    for(int64_t i = 0; i < max_moves; i++) {
        board1->movelist[i] = board2->movelist[i];
        board1->temporary[i] = board2->temporary[i];
    }
    for(int64_t i = board_bottom; i <= board_top; i++) {
        board1->square[i] = board2->square[i];
    }
}
void board_print(board_t *board) {
    char name[2];
    printf("  a b c d e f g h\n");
    for(int64_t i = 0; i < 8; i++) {
        printf("%ld", i + 1);
        for(int64_t j = 0; j < 8; j++) {
            printf(" %c", piece_names[board->square[i * 8 + j] + 6]);
        }
        printf("\n");
    }
    square_name(board->white_king_square, name);
    printf("  INFO: %2ld %s, ", board->white_king_square, name);
    square_name(board->black_king_square, name);
    printf("%2ld %s, ", board->black_king_square, name);
    square_name(board->en_passant_square, name);
    printf("%2ld %s, ", board->en_passant_square, name);
    printf("%02ld, ", board->side_to_move);
    printf("%ld\n", board->fifty_move);
}
void board_debug(board_t *board) {
    char name[2];
    printf("      a      b      c      d      e      f      g      h\n");
    for(int64_t i = 0; i < 8; i++) {
        printf("%ld ", i + 1);
        for(int64_t j = 0; j < 8; j++) {
            printf("[%2ld %c] ", i * 8 + j, piece_names[board->square[i * 8 + j] + 6]);
        }
        printf("\n\n");
    }
    square_name(board->white_king_square, name);
    printf("  INFO: %2ld %s, ", board->white_king_square, name);
    square_name(board->black_king_square, name);
    printf("%2ld %s, ", board->black_king_square, name);
    square_name(board->en_passant_square, name);
    printf("%2ld %s, ", board->en_passant_square, name);
    printf("%02ld, ", board->side_to_move);
    printf("%ld\n", board->fifty_move);
}
void board_from_fen(board_t *board, char *fen) {
    /* janky cuz FEN notation is kinda janky aswell */
    for(int64_t i = board_bottom; i <= board_top; i++) {
        board->square[i] = no_piece;
    }
    int64_t board_index = 56;
    while(*fen != ' ') {
        switch(*fen) {
            case 'k': {
                board->black_king_square = board_index;
                board->square[board_index] = black_king;
                board_index++;
                break;
            }
            case 'q': {
                board->square[board_index] = black_queen;
                board_index++;
                break;
            }
            case 'r': {
                board->square[board_index] = black_rook;
                board_index++;
                break;
            }
            case 'b': {
                board->square[board_index] = black_bishop;
                board_index++;
                break;
            }
            case 'n': {
                board->square[board_index] = black_knight;
                board_index++;
                break;
            }
            case 'p': {
                board->square[board_index] = black_pawn;
                board_index++;
                break;
            }
            case 'P': {
                board->square[board_index] = white_pawn;
                board_index++;
                break;
            }
            case 'N': {
                board->square[board_index] = white_knight;
                board_index++;
                break;                
            }
            case 'B': {
                board->square[board_index] = white_bishop;
                board_index++;
                break;
            }
            case 'R': {
                board->square[board_index] = white_rook;
                board_index++;
                break;
            }
            case 'Q': {
                board->square[board_index] = white_queen;
                board_index++;
                break;
            }
            case 'K': {
                board->white_king_square = board_index;
                board->square[board_index] = white_king;
                board_index++;
                break;
            }
            case '1': {
                board->square[board_index] = no_piece;
                board_index += 1;
                break;
            }
            case '2': {
                board_index += 2;
                break;
            }
            case '3': {
                board_index += 3;
                break;
            }
            case '4': {
                board_index += 4;
                break;
            }
            case '5': {
                board_index += 5;
                break;
            }
            case '6': {
                board_index += 6;
                break;
            }
            case '7': {
                board_index += 7;
                break;
            }
            case '8': {
                board_index += 8;
                break;
            }
            case '/': {
                board_index -= 16;
                break;
            }
            default: {
                fprintf(stderr, "ERROR: Could not read provided FEN\n");
                exit(1);
            }
        }
        fen++;
    }
    fen++;
    if(*fen == 'w') {
        board->side_to_move = white;
        fen += 2;
    } else if(*fen == 'b') {
        board->side_to_move = black;
        fen += 2;
    } else {
        fprintf(stderr, "ERROR: Could not read provided FEN");
        exit(1);
    }
    while(*fen != ' ') {
        switch(*fen) {
            case 'K': {
                /* No castling yet! */
                break;
            }
            case 'Q': {
                /* No castling yet! */
                break;
            }
            case 'k': {
                /* No castling yet! */
                break;
            }
            case 'q': {
                /* No castling yet! */
                break;
            }
        }
        fen++;
    }
    fen++;
    if(*fen == '-') {
        fen += 2;
    } else {
        board->en_passant_square = square_index(fen);
        fen += 3;
    }
    board->fifty_move = 0;
    while(*fen != ' ') {
        board->fifty_move *= 10;
        board->fifty_move += *fen - '0';
        fen++;
    }
}
void board_make_move(board_t *board, move_t *move) {
    if(move->is_en_passant) {
        fprintf(stderr, "ERROR: En passant is not supported yet\n");
        exit(1);
    }
    if(board->side_to_move == white) {
        if(move->from_square == board->white_king_square) {
            board->white_king_square = move->to_square;
        }
    } else {
        if(move->from_square == board->black_king_square) {
            board->black_king_square = move->to_square;
        }
    }
    if(move->promoted_piece == no_piece) {
        board->square[move->to_square] = board->square[move->from_square];
        board->square[move->from_square] = no_piece;
    } else {
        board->square[move->to_square] = move->promoted_piece;
        board->square[move->from_square] = no_piece;
    }
    board->fifty_move = move->fifty_move;
}
void board_undo_move(board_t *board, move_t *move) {
    if(move->is_en_passant) {
        fprintf(stderr, "ERROR: En passant is not supported yet\n");
        exit(1);
    }
    if(board->side_to_move == white) {
        if(move->to_square == board->white_king_square) {
            board->white_king_square = move->from_square;
        }
    } else {
        if(move->to_square == board->black_king_square) {
            board->black_king_square = move->from_square;
        }
    }
    if(move->promoted_piece == no_piece) {
        board->square[move->from_square] = board->square[move->to_square];
        board->square[move->to_square] = move->captured_piece;
    } else {
        board->square[move->to_square] = move->captured_piece;
        if(board->side_to_move == white) {
            board->square[move->from_square] = white_pawn;
        } else {
            board->square[move->from_square] = black_pawn;
        }
    }
    board->fifty_move = move->past_fifty_move;
}
void board_pseudolegal_moves(board_t *board) {
    movelist_reset(board->temporary);
    int64_t movelist_index = 0;
    int64_t direction, offset;
    for(int64_t square = board_bottom; square <= board_top; square++) {
        switch(board->square[square]) {
            case no_piece: {
                break;
            }
            case white_pawn: {
                if(board->side_to_move == black) {
                    break;
                }
                if(rank(square) < r_7) {
                    if(board->square[square + 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 8, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        if(rank(square) == r_2) {
                            if(board->square[square + 16] == no_piece) {
                                move_set(&board->temporary[movelist_index++], square, square + 16, no_piece, no_piece, square + 8, board->en_passant_square, 0, board->fifty_move, false);
                            }
                        }
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 7, board->square[square + 7], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 9, board->square[square + 9], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                } else {
                    if(board->square[square + 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 8, no_piece, white_queen, 0, board->en_passant_square, 0, board->fifty_move, false);
                        // move_set(&board->temporary[movelist_index++], square, square + 8, no_piece, white_rook, 0, board->en_passant_square, 0, board->fifty_move, false);
                        // move_set(&board->temporary[movelist_index++], square, square + 8, no_piece, white_knight, 0, board->en_passant_square, 0, board->fifty_move, false);
                        // move_set(&board->temporary[movelist_index++], square, square + 8, no_piece, white_bishop, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 7, board->square[square + 7], white_queen, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square + 7, board->square[square + 7], white_rook, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square + 7, board->square[square + 7], white_knight, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square + 7, board->square[square + 7], white_bishop, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 9, board->square[square + 9], white_queen, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square + 9, board->square[square + 9], white_rook, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square + 9, board->square[square + 9], white_knight, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square + 9, board->square[square + 9], white_bishop, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                break;
            }
            case black_pawn: {
                if(board->side_to_move == white) {
                    break;
                }
                if(rank(square) > r_2) {
                    if(board->square[square - 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 8, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        if(rank(square) == r_7) {
                            if(board->square[square - 16] == no_piece) {
                                move_set(&board->temporary[movelist_index++], square, square - 16, no_piece, no_piece, square - 8, board->en_passant_square, 0, board->fifty_move, false);
                            }
                        }
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 9, board->square[square - 9], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 7, board->square[square - 7], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                } else {
                    if(board->square[square - 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 8, no_piece, black_queen, 0, board->en_passant_square, 0, board->fifty_move, false);
                        // move_set(&board->temporary[movelist_index++], square, square - 8, no_piece, black_rook, 0, board->en_passant_square, 0, board->fifty_move, false);
                        // move_set(&board->temporary[movelist_index++], square, square - 8, no_piece, black_knight, 0, board->en_passant_square, 0, board->fifty_move, false);
                        // move_set(&board->temporary[movelist_index++], square, square - 8, no_piece, black_bishop, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 9, board->square[square - 9], black_queen, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square - 9, board->square[square - 9], black_rook, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square - 9, board->square[square - 9], black_knight, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square - 9, board->square[square - 9], black_bishop, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 7, board->square[square - 7], black_queen, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square - 7, board->square[square - 7], black_rook, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square - 7, board->square[square - 7], black_knight, 0, board->en_passant_square, 0, board->fifty_move, false);
                            // move_set(&board->temporary[movelist_index++], square, square - 7, board->square[square - 7], black_bishop, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                break;
            }
            case white_knight: {
                if(board->side_to_move == black) {
                    break;
                }
                if(rank(square) > r_1) {
                    if(file(square) > f_b) {
                        if(board->square[square - 10] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 10, board->square[square - 10], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 10] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 10, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square - 6] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 6, board->square[square - 6], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 6] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 6, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) > r_2) {
                    if(file(square) > f_a) {
                        if(board->square[square - 17] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 17, board->square[square - 17], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 17] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 17, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 15] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 15, board->square[square - 15], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 15] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 15, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) < r_7) {
                    if(file(square) > f_a) {
                        if(board->square[square + 15] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 15, board->square[square + 15], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 15] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 15, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 17] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 17, board->square[square + 17], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 17] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 17, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(file(square) > f_b) {
                        if(board->square[square + 6] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 6, board->square[square + 6], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 6] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 6, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square + 10] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 10, board->square[square + 10], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 10] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 10, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                break;
            }
            case black_knight: {
                if(board->side_to_move == white) {
                    break;
                }
                if(rank(square) > r_1) {
                    if(file(square) > f_b) {
                        if(board->square[square - 10] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 10, board->square[square - 10], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 10] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 10, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square - 6] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 6, board->square[square - 6], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 6] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 6, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) > r_2) {
                    if(file(square) > f_a) {
                        if(board->square[square - 17] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 17, board->square[square - 17], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 17] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 17, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 15] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 15, board->square[square - 15], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 15] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 15, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) < r_7) {
                    if(file(square) > f_a) {
                        if(board->square[square + 15] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 15, board->square[square + 15], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 15] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 15, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 17] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 17, board->square[square + 17], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 17] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 17, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(file(square) > f_b) {
                        if(board->square[square + 6] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 6, board->square[square + 6], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 6] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 6, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_g) {
                        if(board->square[square + 10] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 10, board->square[square + 10], no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 10] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 10, no_piece, no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                break;
            }
            case white_bishop: {
                if(board->side_to_move == black) {
                    break;
                }
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case black_bishop: {
                if(board->side_to_move == white) {
                    break;
                }
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case white_rook: {
                if(board->side_to_move == black) {
                    break;
                }
                direction = -8;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(board->square[square + offset] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case black_rook: {
                if(board->side_to_move == white) {
                    break;
                }
                direction = -8;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(board->square[square + offset] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case white_queen: {
                if(board->side_to_move == black) {
                    break;
                }
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case black_queen: {
                if(board->side_to_move == white) {
                    break;
                }
                direction = -9;
                offset = direction;
                while(square + offset >= board_bottom) {
                    if(file(square + offset) == f_h) {
                        break;
                    }
                    if(board->square[square + offset] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
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
                        move_set(&board->temporary[movelist_index++], square, square + offset, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + offset] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + offset, board->square[square + offset], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        break;
                    } else {
                        break;
                    }
                    offset += direction;
                }
                break;
            }
            case white_king: {
                if(board->side_to_move == black) {
                    break;
                }
                if(file(square) > f_a) {
                    if(board->square[square - 1] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 1, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square - 1] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 1, board->square[square - 1], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                }
                if(file(square) < f_h) {
                    if(board->square[square + 1] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 1, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + 1] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 1, board->square[square + 1], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                }
                if(rank(square) > r_1) {
                    if(board->square[square - 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 8, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square - 8] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 8, board->square[square - 8], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 9, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 9] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 9, board->square[square - 9], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 7, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 7] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 7, board->square[square - 7], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(board->square[square + 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 8, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + 8] < no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 8, board->square[square + 8], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 7, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 7] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 7, board->square[square + 7], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 9, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 9] < no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 9, board->square[square + 9], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                break;
            }
            case black_king: {
                if(board->side_to_move == white) {
                    break;
                }
                if(file(square) > f_a) {
                    if(board->square[square - 1] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 1, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square - 1] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 1, board->square[square - 1], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                }
                if(file(square) < f_h) {
                    if(board->square[square + 1] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 1, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + 1] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 1, board->square[square + 1], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                }
                if(rank(square) > r_1) {
                    if(board->square[square - 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 8, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square - 8] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square - 8, board->square[square - 8], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                    if(file(square) > f_a) {
                        if(board->square[square - 9] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 9, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 9] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 9, board->square[square - 9], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square - 7] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 7, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square - 7] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square - 7, board->square[square - 7], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                if(rank(square) < r_8) {
                    if(board->square[square + 8] == no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 8, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                    } else if(board->square[square + 8] > no_piece) {
                        move_set(&board->temporary[movelist_index++], square, square + 8, board->square[square + 8], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                    }
                    if(file(square) > f_a) {
                        if(board->square[square + 7] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 7, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 7] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 7, board->square[square + 7], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                    if(file(square) < f_h) {
                        if(board->square[square + 9] == no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 9, no_piece, no_piece, 0, board->en_passant_square, board->fifty_move + 1, board->fifty_move, false);
                        } else if(board->square[square + 9] > no_piece) {
                            move_set(&board->temporary[movelist_index++], square, square + 9, board->square[square + 9], no_piece, 0, board->en_passant_square, 0, board->fifty_move, false);
                        }
                    }
                }
                break;
            }
            default: {
                fprintf(stderr, "ERROR: Invalid piece %ld at square %ld in pseudolegal move generation\n", board->square[square], square);
                exit(1);
            }
        }
    }
}
bool board_check(board_t *board) {
    int64_t king_square, direction, offset;
    if(board->side_to_move == white) {
        king_square = board->white_king_square;
        if(rank(king_square) > r_1) {
            if(board->square[king_square - 8] == black_king) {
                return(true);
            }
        }
        if(rank(king_square) < r_8) {
            if(board->square[king_square + 8] == black_king) {
                return(true);
            }
        }
        if(file(king_square) > f_a) {
            if(board->square[king_square - 1] == black_king) {
                return(true);
            }
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 9] == black_king) {
                    return(true);
                }
            }
            if(rank(king_square) > r_2) {
                if(board->square[king_square - 17] == black_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_7) {
                if(board->square[king_square + 15] == black_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 7] == black_king) {
                    return(true);
                }
                if(board->square[king_square + 7] == black_pawn) {
                    return(true);
                }
            }
        }
        if(file(king_square) > f_b) {
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 10] == black_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 6] == black_knight) {
                    return(true);
                }
            }
        }
        if(file(king_square) < f_g) {
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 6] == black_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 10] == black_knight) {
                    return(true);
                }
            }
        }
        if(file(king_square) < f_h) {
            if(board->square[king_square + 1] == black_king) {
                return(true);
            }
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 7] == black_king) {
                    return(true);
                }
            }
            if(rank(king_square) > r_2) {
                if(board->square[king_square - 15] == black_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_7) {
                if(board->square[king_square + 17] == black_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 9] == black_king) {
                    return(true);
                }
                if(board->square[king_square + 9] == black_pawn) {
                    return(true);
                }
            }
        }
        direction = -9;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(file(king_square + offset) == f_h) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = -7;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(file(king_square + offset) == f_a) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = 7;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(file(king_square + offset) == f_h) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = 9;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(file(king_square + offset) == f_a) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = -8;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_rook) {
                return(true);
            } else {
                break;
            }
        }
        direction = -1;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(file(king_square + offset) == f_h) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_rook) {
                return(true);
            } else {
                break;
            }
        }
        direction = 1;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(file(king_square + offset) == f_a) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_rook) {
                return(true);
            } else {
                break;
            }
        }
        direction = 8;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == black_queen || board->square[king_square + offset] == black_rook) {
                return(true);
            } else {
                break;
            }
        }
    } else {
        king_square = board->black_king_square;
        if(rank(king_square) > r_1) {
            if(board->square[king_square - 8] == white_king) {
                return(true);
            }
        }
        if(rank(king_square) < r_8) {
            if(board->square[king_square + 8] == white_king) {
                return(true);
            }
        }
        if(file(king_square) > f_a) {
            if(board->square[king_square - 1] == white_king) {
                return(true);
            }
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 9] == white_king) {
                    return(true);
                }
                if(board->square[king_square - 9] == white_pawn) {
                    return(true);
                }
            }
            if(rank(king_square) > r_2) {
                if(board->square[king_square - 17] == white_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_7) {
                if(board->square[king_square + 15] == white_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 7] == white_king) {
                    return(true);
                }
            }
        }
        if(file(king_square) > f_b) {
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 10] == white_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 6] == white_knight) {
                    return(true);
                }
            }
        }
        if(file(king_square) < f_g) {
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 6] == white_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 10] == white_knight) {
                    return(true);
                }
            }
        }
        if(file(king_square) < f_h) {
            if(board->square[king_square + 1] == white_king) {
                return(true);
            }
            if(rank(king_square) > r_1) {
                if(board->square[king_square - 7] == white_king) {
                    return(true);
                }
                if(board->square[king_square - 7] == white_pawn) {
                    return(true);
                }
            }
            if(rank(king_square) > r_2) {
                if(board->square[king_square - 15] == white_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_7) {
                if(board->square[king_square + 17] == white_knight) {
                    return(true);
                }
            }
            if(rank(king_square) < r_8) {
                if(board->square[king_square + 9] == white_king) {
                    return(true);
                }
            }
        }
        direction = -9;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(file(king_square + offset) == f_h) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = -7;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(file(king_square + offset) == f_a) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = 7;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(file(king_square + offset) == f_h) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = 9;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(file(king_square + offset) == f_a) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_bishop) {
                return(true);
            } else {
                break;
            }
        }
        direction = -8;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_rook) {
                return(true);
            } else {
                break;
            }
        }
        direction = -1;
        offset = direction;
        while(king_square + offset >= board_bottom) {
            if(file(king_square + offset) == f_h) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_rook) {
                return(true);
            } else {
                break;
            }
        }
        direction = 1;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(file(king_square + offset) == f_a) {
                break;
            }
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_rook) {
                return(true);
            } else {
                break;
            }
        }
        direction = 8;
        offset = direction;
        while(king_square + offset <= board_top) {
            if(board->square[king_square + offset] == no_piece) {
                offset += direction;
            } else if(board->square[king_square + offset] == white_queen || board->square[king_square + offset] == white_rook) {
                return(true);
            } else {
                break;
            }
        }
    }
    return(false);
}
void board_legal_moves(board_t *board) {
    movelist_reset(board->movelist);
    int64_t movelist_index = 0;
    board_pseudolegal_moves(board);
    int64_t count = movelist_count(board->temporary);
    for(int64_t i = 0; i < count; i++) {
        board_make_move(board, &board->temporary[i]);
        if(! board_check(board)) {
            move_copy(&board->movelist[movelist_index++], &board->temporary[i]);
        }
        board_undo_move(board, &board->temporary[i]);
    }
}
/* Requires legalmoves to be recent */
int64_t board_score(board_t *board) {
    if(movelist_count(board->movelist) == 0) {
        if(board_check(board)) {
            return(-board->side_to_move);
        } else {
            return(draw);
        }
    }
    if(board->fifty_move >= 100) {
        return(draw);
    }
    return(no_result);
}

void board_user_move(board_t *board) {
    while(true) {
        printf("Your move: ");    
        char from[3];
        char to[3];
        scanf("%s %s", from, to);
        printf("\n");
        int64_t from_square = square_index(from);
        int64_t to_square = square_index(to);
        int64_t count = movelist_count(board->movelist);
        for(int64_t i = 0; i < count; i++) {
            if(board->movelist[i].to_square == to_square && board->movelist[i].from_square == from_square) {
                board_make_move(board, &board->movelist[i]);
                return;
            }
        }
        printf("Invalid move: %s %s\n", from, to);
    }
}
void user_game(board_t *board) {
    board_from_fen(board, starting_fen);
    while(true) {
        board_print(board);
        board_legal_moves(board);
        if(board_score(board) != no_result) {
            break;
        }
        board_user_move(board);
        board->side_to_move = -board->side_to_move;
    }
}
void random_game(board_t *board) {
    board_from_fen(board, starting_fen);
    while(true) {
        board_print(board);
        board_legal_moves(board);
        if(board_score(board) != no_result) {
            break;
        }
        board_make_move(board, &board->movelist[rand() % movelist_count(board->movelist)]);
        board->side_to_move = -board->side_to_move;
    }
}
