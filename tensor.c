#include "tensor.h"

#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <CL/cl.h>
#include <string.h>

/*
 * Ok, so this wasn't working cuz I didn't have a working way of setting freed lazyop pointers to NULL.
 * I don't know how, but when I started implementing a fix to that it suddenly fixed itself about halfway through.
 * This is beyond magical to me but I'll take it.
 */

buffer_t buffer_alloc(uint64_t a, uint64_t z, uint64_t y, uint64_t x) {
    buffer_t buffer = {0};
    buffer.sizes = calloc(4, sizeof(uint64_t));
    buffer.sizes[_x] = x;
    buffer.sizes[_y] = y;
    buffer.sizes[_z] = z;
    buffer.sizes[_a] = a;
    buffer.strides = calloc(4, sizeof(uint64_t));
    buffer.strides[_x] = 1;
    buffer.strides[_y] = x;
    buffer.strides[_z] = x * y;
    buffer.strides[_a] = x * y * z;
    buffer.values = calloc(x * y * z * a, sizeof(double));
    return(buffer);
}
void buffer_free(buffer_t *buffer) {
    free(buffer->sizes);
    free(buffer->strides);
    free(buffer->values);
}
void buffer_print(buffer_t *buffer, uint64_t padding, uint64_t offset, const char *name) {
    printf("%*s%s [%lu, %lu, %lu, %lu] full:\n", (int) (offset), "", name, buffer->sizes[_a], buffer->sizes[_z], buffer->sizes[_y], buffer->sizes[_x]);
    printf("%*s[\n", (int) (offset), "");
    for(uint64_t a = 0; a < buffer->sizes[_a]; a++) {
        printf("%*s[\n", (int) (offset + padding), "");
        for(uint64_t z = 0; z < buffer->sizes[_z]; z++) {
            printf("%*s[\n", (int) (offset + 2 * padding), "");
            for(uint64_t y = 0; y < buffer->sizes[_y]; y++) {
                printf("%*s[", (int) (offset + 3 * padding), "");
                for(uint64_t x = 0; x < buffer->sizes[_x]; x++) {
                    printf("%+lf ", BUFFER_AT_P(buffer, a, z, y, x));
                }
                printf("]\n");
            }
            printf("%*s]\n", (int) (offset + 2 * padding), "");
        }
        printf("%*s]\n", (int) (offset + padding), "");
    }
    printf("%*s]\n", (int) (offset), "");
}
void buffer_preview(buffer_t *buffer, uint64_t padding, uint64_t offset, const char *name) {
    printf("%*s%s [%lu, %lu, %lu, %lu] preview:\n", (int) (offset), "", name, buffer->sizes[_a], buffer->sizes[_z], buffer->sizes[_y], buffer->sizes[_x]);
    printf("%*s[\n", (int) (offset), "");
    for(uint64_t a = 0; a < buffer->sizes[_a]; a++) {
        if(a >= 3) {
            printf("%*s...\n", (int) (offset + padding), "");
            break;
        }
        printf("%*s[\n", (int) (offset + padding), "");
        for(uint64_t z = 0; z < buffer->sizes[_z]; z++) {
            if(z >= 3) {
                printf("%*s...\n", (int) (offset + 2 * padding), "");
                break;
            }
            printf("%*s[\n", (int) (offset + 2 * padding), "");
            for(uint64_t y = 0; y < buffer->sizes[_y]; y++) {
                if(y >= 3) {
                    printf("%*s...\n", (int) (offset + 3 * padding), "");
                    break;
                }
                printf("%*s[", (int) (offset + 3 * padding), "");
                for(uint64_t x = 0; x < buffer->sizes[_x]; x++) {
                    if(x >= 3) {
                        printf("...");
                        break;
                    }
                    printf("%+lf ", BUFFER_AT_P(buffer, a, z, y, x));
                }
                printf("]\n");
            }
            printf("%*s]\n", (int) (offset + 2 * padding), "");
        }
        printf("%*s]\n", (int) (offset + padding), "");
    }
    printf("%*s]\n", (int) (offset), "");
}


view_t view_alloc(void) {
    view_t view = {
        .offset = 0,
        .sizes = calloc(4, sizeof(uint64_t)),
        .strides = calloc(4, sizeof(uint64_t)),
        .buffer = NULL, 
    };
    return(view);
}
void view_configure(view_t *view, buffer_t *buffer, uint64_t a_start, uint64_t z_start, uint64_t y_start, uint64_t x_start, uint64_t a_size, uint64_t z_size, uint64_t y_size, uint64_t x_size) {
    assert(a_start + a_size <= buffer->sizes[_a]);
    assert(z_start + z_size <= buffer->sizes[_z]);
    assert(y_start + y_size <= buffer->sizes[_y]);
    assert(x_start + x_size <= buffer->sizes[_x]);
    view->buffer = buffer;
    view->offset = buffer->strides[_a] * a_start + buffer->strides[_z] * z_start + buffer->strides[_y] * y_start + buffer->strides[_x] * x_start;
    view->sizes[_a] = a_size;
    view->sizes[_z] = z_size;
    view->sizes[_y] = y_size;
    view->sizes[_x] = x_size;
    view->strides[_a] = buffer->strides[_a];
    view->strides[_z] = buffer->strides[_z];
    view->strides[_y] = buffer->strides[_y];
    view->strides[_x] = buffer->strides[_x];
}
void view_reshape(view_t *view, uint64_t a_size, uint64_t z_size, uint64_t y_size, uint64_t x_size) {
    view->sizes[_a] = a_size;
    view->sizes[_z] = z_size;
    view->sizes[_y] = y_size;
    view->sizes[_x] = x_size;
}
/* `NOTE`: Does `NOT` free underlying buffer */
void view_free(view_t *view) {
    free(view->sizes);
    free(view->strides);
}
void view_print(view_t *view, uint64_t padding, uint64_t offset, const char *name) {
    printf("%*s%s buffer shape [%lu, %lu, %lu, %lu] view_shape [%lu, %lu, %lu, %lu] offset %lu full:\n", (int) (offset), "", name, view->buffer->sizes[_a], view->buffer->sizes[_z], view->buffer->sizes[_y], view->buffer->sizes[_x], view->sizes[_a], view->sizes[_z], view->sizes[_y], view->sizes[_x], view->offset);
    printf("%*s[\n", (int) (offset), "");
    for(uint64_t a = 0; a < view->sizes[_a]; a++) {
        printf("%*s[\n", (int) (offset + padding), "");
        for(uint64_t z = 0; z < view->sizes[_z]; z++) {
            printf("%*s[\n", (int) (offset + 2 * padding), "");
            for(uint64_t y = 0; y < view->sizes[_y]; y++) {
                printf("%*s[", (int) (offset + 3 * padding), "");
                for(uint64_t x = 0; x < view->sizes[_x]; x++) {
                    printf("%+lf ", VIEW_AT_P(view, a, z, y, x));
                }
                printf("]\n");
            }
            printf("%*s]\n", (int) (offset + 2 * padding), "");
        }
        printf("%*s]\n", (int) (offset + padding), "");
    }
    printf("%*s]\n", (int) (offset), "");
}
void view_preview(view_t *view, uint64_t padding, uint64_t offset, const char *name) {
    printf("%*s%s buffer shape [%lu, %lu, %lu, %lu] view_shape [%lu, %lu, %lu, %lu] offset %lu preview:\n", (int) (offset), "", name, view->buffer->sizes[_a], view->buffer->sizes[_z], view->buffer->sizes[_y], view->buffer->sizes[_x], view->sizes[_a], view->sizes[_z], view->sizes[_y], view->sizes[_x], view->offset);
    printf("%*s[\n", (int) (offset), "");
    for(uint64_t a = 0; a < view->sizes[_a]; a++) {
        if(a >= 3) {
            printf("%*s...\n", (int) (offset + padding), "");
            break;
        }
        printf("%*s[\n", (int) (offset + padding), "");
        for(uint64_t z = 0; z < view->sizes[_z]; z++) {
            if(z >= 3) {
                printf("%*s...\n", (int) (offset + 2 * padding), "");
                break;
            }
            printf("%*s[\n", (int) (offset + 2 * padding), "");
            for(uint64_t y = 0; y < view->sizes[_y]; y++) {
                if(y >= 3) {
                    printf("%*s...\n", (int) (offset + 3 * padding), "");
                    break;
                }
                printf("%*s[", (int) (offset + 3 * padding), "");
                for(uint64_t x = 0; x < view->sizes[_x]; x++) {
                    if(x >= 3) {
                        printf("...");
                        break;
                    }
                    printf("%+lf ", VIEW_AT_P(view, a, z, y, x));
                }
                printf("]\n");
            }
            printf("%*s]\n", (int) (offset + 2 * padding), "");
        }
        printf("%*s]\n", (int) (offset + padding), "");
    }
    printf("%*s]\n", (int) (offset), "");
}


void operation_print(operation_t *operation) {
    if(operation == NULL) {
        printf("Empty operation\n");
        return;
    }
    switch(operation->type) {
        case(operation_unary): {
            switch(operation->unary_type) {
                case(unary_add): {
                    printf("U add [%lu, %lu, %lu, %lu] %lf\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x], operation->unary_value);
                    break;
                }
                case(unary_multiply): {
                    printf("U mul [%lu, %lu, %lu, %lu] %lf\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x], operation->unary_value);
                    break;
                }
                case(unary_subtract): {
                    printf("U sub [%lu, %lu, %lu, %lu] %lf\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x], operation->unary_value);
                    break;
                }
                case(unary_divide): {
                    printf("U div [%lu, %lu, %lu, %lu] %lf\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x], operation->unary_value);
                    break;
                }
                case(unary_set): {
                    printf("U set [%lu, %lu, %lu, %lu] %lf\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x], operation->unary_value);
                    break;
                }
                case(unary_sqrt): {
                    printf("U sqt [%lu, %lu, %lu, %lu]\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x]);
                    break;
                }
                case(unary_log): {
                    printf("U log [%lu, %lu, %lu, %lu]\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x]);
                    break;
                }
                case(unary_exp): {
                    printf("U exp [%lu, %lu, %lu, %lu]\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x]);
                    break;
                }
                case(unary_max): {
                    printf("U max [%lu, %lu, %lu, %lu] %lf\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x], operation->unary_value);
                    break;
                }
                case(unary_min): {
                    printf("U min [%lu, %lu, %lu, %lu] %lf\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x], operation->unary_value);
                    break;
                }
                case(unary_random): {
                    printf("U ran [%lu, %lu, %lu, %lu]\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x]);
                    break;
                }
                case(unary_negate): {
                    printf("U ngt [%lu, %lu, %lu, %lu]\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x]);
                    break;
                }
                case(unary_reciprocal): {
                    printf("U rcp [%lu, %lu, %lu, %lu]\n", operation->unary_out->sizes[_a], operation->unary_out->sizes[_z], operation->unary_out->sizes[_y], operation->unary_out->sizes[_x]);
                    break;
                }
            }
            break;
        }
        case(operation_binary): {
            switch(operation->binary_type) {
                case(binary_add): {
                    printf("B add [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->binary_in->sizes[_a], operation->binary_in->sizes[_z], operation->binary_in->sizes[_y], operation->binary_in->sizes[_x], operation->binary_out->sizes[_a], operation->binary_out->sizes[_z], operation->binary_out->sizes[_y], operation->binary_out->sizes[_x]);
                    break;
                }
                case(binary_multiply): {
                    printf("B mul [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->binary_in->sizes[_a], operation->binary_in->sizes[_z], operation->binary_in->sizes[_y], operation->binary_in->sizes[_x], operation->binary_out->sizes[_a], operation->binary_out->sizes[_z], operation->binary_out->sizes[_y], operation->binary_out->sizes[_x]);
                    break;
                }
                case(binary_subtract): {
                    printf("B sub [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->binary_in->sizes[_a], operation->binary_in->sizes[_z], operation->binary_in->sizes[_y], operation->binary_in->sizes[_x], operation->binary_out->sizes[_a], operation->binary_out->sizes[_z], operation->binary_out->sizes[_y], operation->binary_out->sizes[_x]);
                    break;
                }
                case(binary_divide): {
                    printf("B div [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->binary_in->sizes[_a], operation->binary_in->sizes[_z], operation->binary_in->sizes[_y], operation->binary_in->sizes[_x], operation->binary_out->sizes[_a], operation->binary_out->sizes[_z], operation->binary_out->sizes[_y], operation->binary_out->sizes[_x]);
                    break;
                }
                case(binary_copy): {
                    printf("B cpy [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->binary_in->sizes[_a], operation->binary_in->sizes[_z], operation->binary_in->sizes[_y], operation->binary_in->sizes[_x], operation->binary_out->sizes[_a], operation->binary_out->sizes[_z], operation->binary_out->sizes[_y], operation->binary_out->sizes[_x]);
                    break;
                }
                case(binary_max): {
                    printf("B max [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->binary_in->sizes[_a], operation->binary_in->sizes[_z], operation->binary_in->sizes[_y], operation->binary_in->sizes[_x], operation->binary_out->sizes[_a], operation->binary_out->sizes[_z], operation->binary_out->sizes[_y], operation->binary_out->sizes[_x]);
                    break;
                }
                case(binary_min): {
                    printf("B min [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->binary_in->sizes[_a], operation->binary_in->sizes[_z], operation->binary_in->sizes[_y], operation->binary_in->sizes[_x], operation->binary_out->sizes[_a], operation->binary_out->sizes[_z], operation->binary_out->sizes[_y], operation->binary_out->sizes[_x]);
                    break;
                }
            }
            break;
        }
        case(operation_move): {
            switch(operation->move_type) {
                case(move_reshape): {
                    printf("M rsp [%lu, %lu, %lu, %lu] to [%lu, %lu, %lu, %lu]\n", operation->move_out->sizes[_a], operation->move_out->sizes[_z], operation->move_out->sizes[_y], operation->move_out->sizes[_x], operation->move_var[_a], operation->move_var[_z], operation->move_var[_y], operation->move_var[_x]);
                    break;
                }
                case(move_index): {
                    printf("M idx [%lu, %lu, %lu, %lu] at [%lu, %lu, %lu, %lu]\n", operation->move_out->sizes[_a], operation->move_out->sizes[_z], operation->move_out->sizes[_y], operation->move_out->sizes[_x], operation->move_var[_a], operation->move_var[_z], operation->move_var[_y], operation->move_var[_x]);
                    break;
                }
                case(move_permute): {
                    printf("M per [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->move_in->sizes[_a], operation->move_in->sizes[_z], operation->move_in->sizes[_y], operation->move_in->sizes[_x], operation->move_out->sizes[_a], operation->move_out->sizes[_z], operation->move_out->sizes[_y], operation->move_out->sizes[_x]);
                    break;
                }
                case(move_expand): {
                    printf("M exp [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->move_in->sizes[_a], operation->move_in->sizes[_z], operation->move_in->sizes[_y], operation->move_in->sizes[_x], operation->move_out->sizes[_a], operation->move_out->sizes[_z], operation->move_out->sizes[_y], operation->move_out->sizes[_x]);
                    break;
                }
                case(move_pad): {
                    printf("M pad [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->move_in->sizes[_a], operation->move_in->sizes[_z], operation->move_in->sizes[_y], operation->move_in->sizes[_x], operation->move_out->sizes[_a], operation->move_out->sizes[_z], operation->move_out->sizes[_y], operation->move_out->sizes[_x]);
                    break;
                }
                case(move_shrink): {
                    printf("M shr [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->move_in->sizes[_a], operation->move_in->sizes[_z], operation->move_in->sizes[_y], operation->move_in->sizes[_x], operation->move_out->sizes[_a], operation->move_out->sizes[_z], operation->move_out->sizes[_y], operation->move_out->sizes[_x]);
                    break;
                }
            }
            break;
        }
        case(operation_reduce): {
            switch(operation->reduce_type) {
                case(reduce_sum): {
                    printf("R sum [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->reduce_in->sizes[_a], operation->reduce_in->sizes[_z], operation->reduce_in->sizes[_y], operation->reduce_in->sizes[_x], operation->reduce_out->sizes[_a], operation->reduce_out->sizes[_z], operation->reduce_out->sizes[_y], operation->reduce_out->sizes[_x]);
                    break;
                }
                case(reduce_max): {
                    printf("R max [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->reduce_in->sizes[_a], operation->reduce_in->sizes[_z], operation->reduce_in->sizes[_y], operation->reduce_in->sizes[_x], operation->reduce_out->sizes[_a], operation->reduce_out->sizes[_z], operation->reduce_out->sizes[_y], operation->reduce_out->sizes[_x]);
                    break;
                }
                case(reduce_min): {
                    printf("R min[%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->reduce_in->sizes[_a], operation->reduce_in->sizes[_z], operation->reduce_in->sizes[_y], operation->reduce_in->sizes[_x], operation->reduce_out->sizes[_a], operation->reduce_out->sizes[_z], operation->reduce_out->sizes[_y], operation->reduce_out->sizes[_x]);
                    break;
                }
                case(reduce_avg): {
                    printf("R avg [%lu, %lu, %lu, %lu] -> [%lu, %lu, %lu, %lu]\n", operation->reduce_in->sizes[_a], operation->reduce_in->sizes[_z], operation->reduce_in->sizes[_y], operation->reduce_in->sizes[_x], operation->reduce_out->sizes[_a], operation->reduce_out->sizes[_z], operation->reduce_out->sizes[_y], operation->reduce_out->sizes[_x]);
                    break;
                }
            }
            break;
        }
        default: {
            printf("Empty operation\n");
        }
    }
}
void operation_unary_config(operation_t *operation, enum unary_e type, view_t *out, double value) {
    operation->type = operation_unary;
    operation->unary_type = type;
    operation->unary_out = out;
    operation->unary_value = value;
}
void operation_binary_config(operation_t *operation, enum binary_e type, view_t *out, view_t *in) {
    operation->type = operation_binary;
    operation->binary_type = type;
    operation->binary_in = in;
    operation->binary_out = out;
}
void operation_move_config(operation_t *operation, enum move_e type, view_t *out, view_t *in, uint64_t move_a, uint64_t move_z, uint64_t move_y, uint64_t move_x) {
    operation->type = operation_move;
    operation->move_type = type;
    operation->move_in = in;
    operation->move_out = out;
    operation->move_var[_a] = move_a;
    operation->move_var[_z] = move_z;
    operation->move_var[_y] = move_y;
    operation->move_var[_x] = move_x;
}
void operation_reduce_config(operation_t *operation, enum reduce_e type, view_t *out, view_t *in) {
    operation->type = operation_reduce;
    operation->reduce_type = type;
    operation->reduce_in = in;
    operation->reduce_out = out;
}


void operation_cpu_realize_unary(operation_t *operation) {
    /* Switch case inner: 2e6 ops took 57.4s */
    /* Switch case outer: 2e6 ops took 7s */
    /* I didn't expect the difference to be THAT huge */
    switch(operation->unary_type) {
        case(unary_add): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) += operation->unary_value;
                        }
                    }
                }
            }
            break;
        }
        case(unary_multiply): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) *= operation->unary_value;
                        }
                    }
                }
            }
            break;
        }
        case(unary_subtract): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) -= operation->unary_value;
                        }
                    }
                }
            }
            break;
        }
        case(unary_divide): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) /= operation->unary_value;
                        }
                    }
                }
            }
            break;
        }
        case(unary_set): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) = operation->unary_value;
                        }
                    }
                }
            }
            break;
        }
        case(unary_sqrt): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) = sqrt(VIEW_AT_P(operation->unary_out, a, z, y, x));
                        }
                    }
                }
            }
            break;
        }
        case(unary_log): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) = log(VIEW_AT_P(operation->unary_out, a, z, y, x));
                        }
                    }
                }
            }
            break;
        }
        case(unary_exp): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) = exp(VIEW_AT_P(operation->unary_out, a, z, y, x));
                        }
                    }
                }
            }
            break;
        }
        case(unary_max): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            if(VIEW_AT_P(operation->unary_out, a, z, y, x) < operation->unary_value) {
                                VIEW_AT_P(operation->unary_out, a, z, y, x) = operation->unary_value;
                            }
                        }
                    }
                }
            }
            break;
        }
        case(unary_min): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            if(VIEW_AT_P(operation->unary_out, a, z, y, x) > operation->unary_value) {
                                VIEW_AT_P(operation->unary_out, a, z, y, x) = operation->unary_value;
                            }
                        }
                    }
                }
            }
            break;
        }
        case(unary_random): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) = RAND_U;
                        }
                    }
                }
            }
            break;
        }
        case(unary_negate): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) = - VIEW_AT_P(operation->unary_out, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
        case(unary_reciprocal): {
            for(uint64_t a = 0; a < operation->unary_out->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->unary_out->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->unary_out->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->unary_out->sizes[_x]; x++) {
                            VIEW_AT_P(operation->unary_out, a, z, y, x) = 1 / VIEW_AT_P(operation->unary_out, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
    }
}
inline void operation_cpu_realize_binary(operation_t *operation) {
    switch(operation->binary_type) {
        case(binary_add): {
            for(uint64_t a = 0; a < operation->binary_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->binary_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->binary_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->binary_in->sizes[_x]; x++) {
                            VIEW_AT_P(operation->binary_out, a, z, y, x) += VIEW_AT_P(operation->binary_in, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
        case(binary_multiply): {
            for(uint64_t a = 0; a < operation->binary_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->binary_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->binary_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->binary_in->sizes[_x]; x++) {
                            VIEW_AT_P(operation->binary_out, a, z, y, x) *= VIEW_AT_P(operation->binary_in, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
        case(binary_subtract): {
            for(uint64_t a = 0; a < operation->binary_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->binary_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->binary_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->binary_in->sizes[_x]; x++) {
                            VIEW_AT_P(operation->binary_out, a, z, y, x) -= VIEW_AT_P(operation->binary_in, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
        case(binary_divide): {
            for(uint64_t a = 0; a < operation->binary_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->binary_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->binary_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->binary_in->sizes[_x]; x++) {
                            VIEW_AT_P(operation->binary_out, a, z, y, x) /= VIEW_AT_P(operation->binary_in, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
        case(binary_copy): {
            for(uint64_t a = 0; a < operation->binary_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->binary_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->binary_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->binary_in->sizes[_x]; x++) {
                            VIEW_AT_P(operation->binary_out, a, z, y, x) = VIEW_AT_P(operation->binary_in, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
        case(binary_max): {
            for(uint64_t a = 0; a < operation->binary_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->binary_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->binary_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->binary_in->sizes[_x]; x++) {
                            if(VIEW_AT_P(operation->binary_out, a, z, y, x) < VIEW_AT_P(operation->binary_in, a, z, y, x)) {
                                VIEW_AT_P(operation->binary_out, a, z, y, x) = VIEW_AT_P(operation->binary_in, a, z, y, x);
                            }
                        }
                    }
                }
            }
            break;
        }
        case(binary_min): {
            for(uint64_t a = 0; a < operation->binary_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->binary_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->binary_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->binary_in->sizes[_x]; x++) {
                            if(VIEW_AT_P(operation->binary_out, a, z, y, x) > VIEW_AT_P(operation->binary_in, a, z, y, x)) {
                                VIEW_AT_P(operation->binary_out, a, z, y, x) = VIEW_AT_P(operation->binary_in, a, z, y, x);
                            }
                        }
                    }
                }
            }
            break;
        }
    }
}
void operation_cpu_realize_move(operation_t *operation) {
    switch(operation->move_type) {
        case(move_reshape): {
            operation->move_out->sizes[_a] = operation->move_var[_a];
            operation->move_out->sizes[_z] = operation->move_var[_z];
            operation->move_out->sizes[_y] = operation->move_var[_y];
            operation->move_out->sizes[_x] = operation->move_var[_x];
            break;
        }
        case(move_index): {
            operation->move_out->offset = operation->move_out->strides[_a] * operation->move_var[_a] + operation->move_out->strides[_z] * operation->move_var[_z] + operation->move_out->strides[_y] * operation->move_var[_y] + operation->move_out->strides[_x] * operation->move_var[_x];
            break;
        }
        case(move_permute): {
            break;
        }
        case(move_expand): {
            break;
        }
        case(move_pad): {
            break;
        }
        case(move_shrink): {
            break;
        }
    }
}
void operation_cpu_realize_reduce(operation_t *operation) {
    double temp;
    switch(operation->reduce_type) {
        case(reduce_sum): {
            temp = 0;
            for(uint64_t a = 0; a < operation->reduce_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->reduce_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->reduce_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->reduce_in->sizes[_x]; x++) {
                            temp += VIEW_AT_P(operation->reduce_in, a, z, y, x);
                        }
                    }
                }
            }
            break;
        }
        case(reduce_max): {
            temp = - INFINITY; /* It should never be the case that there isn't at least one value bigger than -Inf */
            for(uint64_t a = 0; a < operation->reduce_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->reduce_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->reduce_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->reduce_in->sizes[_x]; x++) {
                            if(VIEW_AT_P(operation->reduce_in, a, z, y, x) > temp) {
                                temp = VIEW_AT_P(operation->reduce_in, a, z, y, x);
                            }
                        }
                    }
                }
            }
            break;
        }
        case(reduce_min): {
            temp = INFINITY; /* It should never be the case that ther isn't at least one value smaller than Inf */
            for(uint64_t a = 0; a < operation->reduce_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->reduce_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->reduce_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->reduce_in->sizes[_x]; x++) {
                            if(VIEW_AT_P(operation->reduce_in, a, z, y, x) < temp) {
                                temp = VIEW_AT_P(operation->reduce_in, a, z, y, x);
                            }
                        }
                    }
                }
            }
            break;
        }
        case(reduce_avg): {
            temp = 0;
            for(uint64_t a = 0; a < operation->reduce_in->sizes[_a]; a++) {
                for(uint64_t z = 0; z < operation->reduce_in->sizes[_z]; z++) {
                    for(uint64_t y = 0; y < operation->reduce_in->sizes[_y]; y++) {
                        for(uint64_t x = 0; x < operation->reduce_in->sizes[_x]; x++) {
                            temp += VIEW_AT_P(operation->reduce_in, a, z, y, x);
                        }
                    }
                }
            }
            double size = operation->reduce_in->sizes[_a] * operation->reduce_in->sizes[_z] * operation->reduce_in->sizes[_y] * operation->reduce_in->sizes[_x];
            temp /= size;
            break;
        }
    }
    VIEW_AT_P(operation->reduce_out, 0, 0, 0, 0) = temp;
}


void operation_cpu_realize(operation_t *operation) {
    if(operation == NULL) {
        return;
    }
    switch(operation->type) {
        case(operation_unary): {
            operation_cpu_realize_unary(operation);
            break;
        }
        case(operation_binary): {
            operation_cpu_realize_binary(operation);
            break;
        }
        case(operation_move): {
            operation_cpu_realize_move(operation);
            break;
        }
        case(operation_reduce): {
            operation_cpu_realize_reduce(operation);
            break;
        }
    }
}
void operation_gpu_realize(operation_t *operation) {
}


/* Value straight from my ass. */
const uint64_t initial_lazyop_capacity = 8;
lazyop_t lazyop_alloc(void) {
    lazyop_t lazyop = {
        .operation = calloc(1, sizeof(operation_t)),
        // .operation_length = 0,
        // .operation_capacity = 1,
        .parents_length = 0,
        .parents_capacity = initial_lazyop_capacity,
        .parent = calloc(initial_lazyop_capacity, sizeof(lazyop_t *)),
        .children_length = 0,
        .children_capacity = initial_lazyop_capacity,
        .child = calloc(initial_lazyop_capacity, sizeof(lazyop_t *)),
        .base = NULL,
    };
    return(lazyop);
}
/* `NOTE`: This is `NOT` recursive and hence does `NOT` free all the parent ops. If you lose a pointer it will leak. */
void lazyop_free(lazyop_t *lazyop) {
    free(lazyop->operation);
    free(lazyop->parent);
    free(lazyop->child);
}
void lazyop_add_parent(lazyop_t *lazyop, lazyop_t *parent) {
    if(lazyop->parents_length == lazyop->parents_capacity) {
        lazyop->parents_capacity *= 2;
        lazyop->parent = realloc(lazyop->parent, lazyop->parents_capacity * sizeof(lazyop_t *));
    }
    if(parent->children_length == parent->children_capacity) {
        parent->children_capacity *= 2;
        parent->child = realloc(parent->child, parent->children_capacity * sizeof(lazyop_t *));
    }
    lazyop->parent[lazyop->parents_length++] = parent;
    parent->child[parent->children_length++] = lazyop;
}
void lazyop_remove_parent(lazyop_t *parent) {
    uint64_t found;
    for(uint64_t i = 0; i < parent->children_length; i++) {
        found = 0;
        for(uint64_t j = 0; j < parent->child[i]->parents_length; j++) {
            if(parent == parent->child[i]->parent[j]) {
                found = 1;
            }
            if(found) {
                if(j == parent->child[i]->parents_length - 1) {
                    parent->child[i]->parent[j] = NULL;
                } else {
                    parent->child[i]->parent[j] = parent->child[i]->parent[j + 1];
                }
            }
        }
        parent->child[i]->parents_length--;
        parent->child[i] = NULL;
    }
    parent->children_length = 0;
}
void lazyop_unary_config(lazyop_t *lazyop, lazyop_t *parent, enum unary_e type, view_t *out, double value) {
    if(parent) {
        if(parent->base) {
            lazyop->base = parent->base;
            parent->base = NULL;
        }
        lazyop_add_parent(lazyop, parent);
    }
    operation_unary_config(lazyop->operation, type, out, value);
}
void lazyop_binary_config(lazyop_t *lazyop, lazyop_t *out_parent, lazyop_t *in_parent, enum binary_e type, view_t *out, view_t *in) {
    if(in_parent) {
        lazyop_add_parent(lazyop, in_parent);
    }
    if(out_parent) {
        if(out_parent->base) {
            lazyop->base = out_parent->base;
            out_parent->base = NULL;
        }
        lazyop_add_parent(lazyop, out_parent);
    }
    operation_binary_config(lazyop->operation, type, out, in);
}
void lazyop_move_config(lazyop_t *lazyop, lazyop_t *out_parent, lazyop_t *in_parent, enum move_e type, view_t *out, view_t *in, uint64_t move_a, uint64_t move_z, uint64_t move_y, uint64_t move_x) {
    if(in_parent) {
        lazyop_add_parent(lazyop, in_parent);
    }
    if(out_parent) {
        if(out_parent->base) {
            lazyop->base = out_parent->base;
            out_parent->base = NULL;
        }
        lazyop_add_parent(lazyop, out_parent);
    }
    operation_move_config(lazyop->operation, type, out, in, move_a, move_z, move_y, move_x);
}
void lazyop_reduce_config(lazyop_t *lazyop, lazyop_t *out_parent, lazyop_t *in_parent, enum reduce_e type, view_t *out, view_t *in) {
    if(in_parent) {
        lazyop_add_parent(lazyop, in_parent);
    }
    if(out_parent) {
        // if(out_parent->base) {
        //     lazyop->base = out_parent->base;
        //     out_parent->base = NULL;
        // }
        lazyop_add_parent(lazyop, out_parent);
    }
    operation_reduce_config(lazyop->operation, type, out, in);
}
void lazyop_cpu_realize(lazyop_t *lazyop) {
    while(lazyop->parents_length > 0) {
        lazyop_cpu_realize(lazyop->parent[lazyop->parents_length - 1]);
    }
    operation_cpu_realize(lazyop->operation);
    if(lazyop->base) {
        tensor_t *tensor = lazyop->base;
        tensor->lazyop = NULL;
    }
    lazyop_remove_parent(lazyop);
    lazyop_free(lazyop);
    free(lazyop);
}
void lazyop_gpu_realize(lazyop_t *lazyop, cl_device_id *device, cl_context *context, cl_command_queue *queue) {
}
void lazyop_print(lazyop_t *lazyop, uint64_t padding, uint64_t offset, const char *name) {
    if(strcmp(name, "")) {
        printf("%*s%s \n", (int) (offset), "", name);
    } else {
        printf("%*s", (int) (offset), "");
    }
    printf("<%p> ", lazyop);
    if(lazyop != NULL) {
        if(lazyop->base) {
            printf("base of <%p> ", lazyop->base);
        }
        operation_print(lazyop->operation);
        for(uint64_t i = 0; i < lazyop->parents_length; i++) {
            lazyop_print(lazyop->parent[i], padding, offset + padding, "");
        }
    } else {
        printf("\n");
    }
}


tensor_t tensor_alloc(uint64_t a, uint64_t z, uint64_t y, uint64_t x) {
    tensor_t tensor = {
        .view = calloc(1, sizeof(view_t)),
        .lazyop = NULL,
    };
    *tensor.view = view_alloc();
    tensor.view->buffer = calloc(1, sizeof(buffer_t));
    *tensor.view->buffer = buffer_alloc(a, z, y, x);
    view_configure(tensor.view, tensor.view->buffer, 0, 0, 0, 0, a, z, y, x);
    return(tensor);
}
void tensor_free(tensor_t *tensor) {
    buffer_free(tensor->view->buffer);
    view_free(tensor->view);
    lazyop_free(tensor->lazyop);
    free(tensor->view->buffer);
    free(tensor->view);
    free(tensor->lazyop);
}
void tensor_add_unary(tensor_t *tensor, double value) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_add, tensor->view, value);
}
void tensor_subtract_unary(tensor_t *tensor, double value) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_subtract, tensor->view, value);
}
void tensor_multiply_unary(tensor_t *tensor, double value) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_multiply, tensor->view, value);
}
void tensor_divide_unary(tensor_t *tensor, double value) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_divide, tensor->view, value);
}
void tensor_set_unary(tensor_t *tensor, double value) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_set, tensor->view, value);
}
void tensor_sqrt_unary(tensor_t *tensor) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_sqrt, tensor->view, 0);
}
void tensor_log_unary(tensor_t *tensor) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_log, tensor->view, 0);
}
void tensor_exp_unary(tensor_t *tensor) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_exp, tensor->view, 0);
}
void tensor_max_unary(tensor_t *tensor, double value) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_max, tensor->view, value);
}
void tensor_min_unary(tensor_t *tensor, double value) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_min, tensor->view, value);
}
void tensor_random_unary(tensor_t *tensor) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_random, tensor->view, 0);
}
void tensor_negate_unary(tensor_t *tensor) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_negate, tensor->view, 0);
}
void tensor_reciprocal_unary(tensor_t *tensor) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_unary_config(tensor->lazyop, parent, unary_reciprocal, tensor->view, 0);
}

void tensor_add_binary(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_binary_config(out->lazyop, parent, in->lazyop, binary_add, out->view, in->view);
}
void tensor_subtract_binary(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_binary_config(out->lazyop, parent, in->lazyop, binary_subtract, out->view, in->view);
}
void tensor_multiply_binary(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_binary_config(out->lazyop, parent, in->lazyop, binary_multiply, out->view, in->view);
}
void tensor_divide_binary(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_binary_config(out->lazyop, parent, in->lazyop, binary_divide, out->view, in->view);
}
void tensor_max_binary(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_binary_config(out->lazyop, parent, in->lazyop, binary_max, out->view, in->view);
}
void tensor_min_binary(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_binary_config(out->lazyop, parent, in->lazyop, binary_min, out->view, in->view);
}
void tensor_copy_binary(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_binary_config(out->lazyop, parent, in->lazyop, binary_copy, out->view, in->view);
}

/* Reshapes the view. All the uint arguments are the sizes. */
void tensor_reshape_move(tensor_t *tensor, uint64_t a, uint64_t z, uint64_t y, uint64_t x) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_move_config(tensor->lazyop, parent, NULL, move_reshape, tensor->view, NULL, a, z, y, x);
}
/* Moves the view. All the uint arguments are the indices to move the upper left corner to. */
void tensor_index_move(tensor_t *tensor, uint64_t a, uint64_t z, uint64_t y, uint64_t x) {
    lazyop_t *parent = tensor->lazyop;
    tensor->lazyop = calloc(1, sizeof(lazyop_t));
    *tensor->lazyop = lazyop_alloc();
    if(!parent) {
        tensor->lazyop->base = tensor;
    }
    lazyop_move_config(tensor->lazyop, parent, NULL, move_index, tensor->view, NULL, a, z, y, x);
}
void tensor_permute_move(tensor_t *out, tensor_t *in) {
}
void tensor_expand_move(tensor_t *out, tensor_t *in) {
}
void tensor_pad_move(tensor_t *out, tensor_t *in) {
}
void tensor_shrink_move(tensor_t *out, tensor_t *in) {
}

void tensor_sum_reduce(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_reduce_config(out->lazyop, parent, in->lazyop, reduce_sum, out->view, in->view);
}
void tensor_max_reduce(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_reduce_config(out->lazyop, parent, in->lazyop, reduce_max, out->view, in->view);
}
void tensor_min_reduce(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_reduce_config(out->lazyop, parent, in->lazyop, reduce_min, out->view, in->view);
}
void tensor_avg_reduce(tensor_t *out, tensor_t *in) {
    lazyop_t *parent = out->lazyop;
    out->lazyop = calloc(1, sizeof(lazyop_t));
    *out->lazyop = lazyop_alloc();
    if(!parent) {
        out->lazyop->base = out;
    }
    lazyop_reduce_config(out->lazyop, parent, in->lazyop, reduce_avg, out->view, in->view);
}

void tensor_cpu_realize(tensor_t *out) {
    if(out->lazyop != NULL) {
        lazyop_cpu_realize(out->lazyop);
    }
}
void tensor_gpu_realize(tensor_t *out, cl_device_id *device, cl_context *context, cl_command_queue *queue) {
}

void tensor_print(tensor_t *tensor, uint64_t padding, uint64_t offset, const char *name) {
    tensor_cpu_realize(tensor);
    // lazyop_print(tensor->lazyop, padding, offset, name);
    view_preview(tensor->view, padding, offset, name);
}
