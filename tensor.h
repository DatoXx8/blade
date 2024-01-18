#ifndef TENSOR_H_
#define TENSOR_H_

/* TODO: Figure out ternary, movement and buffer ops from Tinygrad (probably only useful for GPU) */

#include <stdint.h>
/* #include <math.h> */
#include <CL/cl.h>

#define START_TIMING start = clock() /* Requires `clock_t start` to be defined */
#define STOP_TIMING stop = clock() /* Requires `clock_t stop` to be defined */
#define PRINT_TIME_IN_SECONDS printf("TIME: %lfs\n", ((double) (stop - start)) / (CLOCKS_PER_SEC))
#define PRINT_TIME_IN_MILLISECONDS printf("TIME: %lfms\n", ((double) (stop - start) * 1000) / (CLOCKS_PER_SEC))
#define PRINT_TIME_IN_MICROSECONDS printf("TIME: %lfµs\n", ((double) (stop - start) * 1000 * 1000) / (CLOCKS_PER_SEC))

/* Only 4d buffers supported */
#define _a 0
#define _z 1
#define _y 2
#define _x 3
typedef struct {
    uint64_t *sizes;
    uint64_t *strides;
    double *values;
} buffer_t;

extern buffer_t buffer_alloc(uint64_t a, uint64_t z, uint64_t y, uint64_t x);
extern void buffer_free(buffer_t *buffer);
extern void buffer_print(buffer_t *buffer, uint64_t padding, uint64_t offset, const char *name);
extern void buffer_preview(buffer_t *buffer, uint64_t padding, uint64_t offset, const char *name);

#define BUFFER_AT(buffer, a, z, y, x) (buffer.values[buffer.strides[_a] * a + buffer.strides[_z] * z + buffer.strides[_y] * y + buffer.strides[_x] * x])
#define BUFFER_AT_P(buffer, a, z, y, x) (buffer->values[buffer->strides[_a] * a + buffer->strides[_z] * z + buffer->strides[_y] * y + buffer->strides[_x] * x])

typedef struct {
    uint64_t offset;
    uint64_t *sizes;
    uint64_t *strides;
    buffer_t *buffer;
} view_t;

extern view_t view_alloc(void);
extern void view_configure(view_t *view, buffer_t *buffer, uint64_t a_start, uint64_t z_start, uint64_t y_start, uint64_t x_start, uint64_t a_size, uint64_t z_size, uint64_t y_size, uint64_t x_size);
extern void view_move(view_t *view, uint64_t a, uint64_t z, uint64_t y, uint64_t x);
extern void view_reshape(view_t *view, uint64_t a, uint64_t z, uint64_t y, uint64_t x);
extern void view_free(view_t *view);
extern void view_print(view_t *view, uint64_t padding, uint64_t offset, const char *name);
extern void view_preview(view_t *view, uint64_t padding, uint64_t offset, const char *name);

#define VIEW_AT(view, a, z, y, x) (view.buffer->values[view.strides[_a] * a + view.strides[_z] * z + view.strides[_y] * y + view.strides[_x] * x + view.offset])
#define VIEW_AT_P(view, a, z, y, x) (view->buffer->values[view->strides[_a] * a + view->strides[_z] * z + view->strides[_y] * y + view->strides[_x] * x + view->offset])

/* NOTE: U stands for uniform. Values range from -1 to 1 inclusive. */
#define RAND_U (((double) rand() / RAND_MAX) * 2 - 1)
/* NOTE: Here values near 0 are more likely. Values range from -1 to 1 inclusive. */
#define RAND (RAND_U * RAND_U)

enum operation_e {
    operation_unary = 0, operation_binary, operation_move, operation_reduce
};
enum unary_e {
    unary_add = 0, unary_multiply, unary_subtract, unary_divide, unary_set, unary_sqrt, unary_log, unary_exp, unary_max, unary_min, unary_random, unary_negate, unary_reciprocal
};
enum binary_e {
    binary_add = 0, binary_multiply, binary_subtract, binary_divide, binary_max, binary_min, binary_copy/* , binary_mod, binary_complete */
};
enum move_e {
    move_reshape = 0, move_index, move_permute, move_expand, move_pad, move_shrink/* , move_stride, move_as_strided */
};
enum reduce_e {
    reduce_sum = 0, reduce_max, reduce_min, reduce_avg
};

#define no_operation -1
/* TODO: Implement fusing operations */
typedef struct {
    enum operation_e type;
    enum unary_e unary_type;
    double unary_value;
    view_t *unary_out;
    enum binary_e binary_type;
    view_t *binary_out;
    view_t *binary_in;
    enum move_e move_type;
    uint64_t move_var[4];
    view_t *move_out;
    view_t *move_in;
    enum reduce_e reduce_type;
    view_t *reduce_out;
    view_t *reduce_in;
} operation_t;

extern void operation_print(operation_t *operation);

extern void operation_unary_config(operation_t *operation, enum unary_e type, view_t *out, double value);
extern void operation_binary_config(operation_t *operation, enum binary_e type, view_t *out, view_t *in);
extern void operation_move_config(operation_t *operation, enum move_e type, view_t *out, view_t *in, uint64_t move_a, uint64_t move_z, uint64_t move_y, uint64_t move_x);
extern void operation_reduce_config(operation_t *operation, enum reduce_e type, view_t *out, view_t *in);

extern void operation_cpu_realize_unary(operation_t *operation);
extern void operation_cpu_realize_binary(operation_t *operation);
extern void operation_cpu_realize_move(operation_t *operation);
extern void operation_cpu_realize_reduce(operation_t *operation);

extern void operation_cpu_realize(operation_t *operation);
extern void operation_gpu_realize(operation_t *operation);

/* TODO: Fusing operations. */
/* WARNING: Lazyops can and will crash the program if there are loops in the tree structure. */
typedef struct lazyop {
    struct lazyop **child;
    uint64_t children_length;
    uint64_t children_capacity;
    struct lazyop **parent;
    uint64_t parents_length;
    uint64_t parents_capacity;
    /* I am gonna try to make it one operation per lazyop til I implement fusing */
    operation_t *operation;
    // uint64_t operation_length;
    // uint64_t operation_capacity;
    void *base;
} lazyop_t;

extern lazyop_t lazyop_alloc(void);
extern void lazyop_free(lazyop_t *lazyop);
extern void lazyop_add_parent(lazyop_t *lazyop, lazyop_t *parent);
extern void lazyop_remove_parent(lazyop_t *parent);
extern void lazyop_unary_config(lazyop_t *lazyop, lazyop_t *parent, enum unary_e type, view_t *out, double value);
extern void lazyop_binary_config(lazyop_t *lazyop, lazyop_t *out_parent, lazyop_t *in_parent, enum binary_e type, view_t *out, view_t *in);
extern void lazyop_move_config(lazyop_t *lazyop, lazyop_t *out_parent, lazyop_t *in_parent, enum move_e type, view_t *out, view_t *in, uint64_t move_a, uint64_t move_z, uint64_t move_y, uint64_t move_x);
extern void lazyop_reduce_config(lazyop_t *lazyop, lazyop_t *out_parent, lazyop_t *in_parent, enum reduce_e type, view_t *out, view_t *in);
extern void lazyop_cpu_realize(lazyop_t *lazyop);
extern void lazyop_gpu_realize(lazyop_t *lazyop, cl_device_id *device, cl_context *context, cl_command_queue *queue);
extern void lazyop_print(lazyop_t *lazyop, uint64_t padding, uint64_t offset, const char *name);
#define LAZYOP_PRINT(lazyop) lazyop_print(&lazyop, 4, 0, (#lazyop))
#define LAZYOP_PRINT_P(lazyop) lazyop_print(lazyop, 4, 0, (#lazyop))

/* The implementation using views is about 30% slower, however this should allow for far better and more optimisable code. */
/* At least that is the hope, because resizing and reshaping views over the same base buffer is as simple as changing 8 values, namely the sizes and strides. */
/* It is likely that resizing the view a lot makes caching less efficient, but I think it is more likely that not having to copy all the values between different buffers saves more time than initially slowing the cache down.*/
typedef struct {
    view_t *view;
    lazyop_t *lazyop;
} tensor_t;

extern tensor_t tensor_alloc(uint64_t a, uint64_t z, uint64_t y, uint64_t x);
extern void tensor_free(tensor_t *tensor);
extern void tensor_add_unary(tensor_t *tensor, double value);
extern void tensor_subtract_unary(tensor_t *tensor, double value);
extern void tensor_multiply_unary(tensor_t *tensor, double value);
extern void tensor_divide_unary(tensor_t *tensor, double value);
extern void tensor_set_unary(tensor_t *tensor, double value);
extern void tensor_sqrt_unary(tensor_t *tensor);
extern void tensor_log_unary(tensor_t *tensor);
extern void tensor_exp_unary(tensor_t *tensor);
extern void tensor_max_unary(tensor_t *tensor, double value);
extern void tensor_min_unary(tensor_t *tensor, double value);
extern void tensor_random_unary(tensor_t *tensor);
extern void tensor_negate_unary(tensor_t *tensor);
extern void tensor_reciprocal_unary(tensor_t *tensor);

extern void tensor_add_binary(tensor_t *out, tensor_t *in);
extern void tensor_subtract_binary(tensor_t *out, tensor_t *in);
extern void tensor_multiply_binary(tensor_t *out, tensor_t *in);
extern void tensor_divide_binary(tensor_t *out, tensor_t *in);
extern void tensor_max_binary(tensor_t *out, tensor_t *in);
extern void tensor_min_binary(tensor_t *out, tensor_t *in);
extern void tensor_copy_binary(tensor_t *out, tensor_t *in);

extern void tensor_reshape_move(tensor_t *tensor, uint64_t a, uint64_t z, uint64_t y, uint64_t x);
extern void tensor_index_move(tensor_t *tensor, uint64_t a, uint64_t z, uint64_t y, uint64_t x);
extern void tensor_permute_move(tensor_t *out, tensor_t *in);
extern void tensor_expand_move(tensor_t *out, tensor_t *in);
extern void tensor_pad_move(tensor_t *out, tensor_t *in);
extern void tensor_shrink_move(tensor_t *out, tensor_t *in);

extern void tensor_sum_reduce(tensor_t *out, tensor_t *in);
extern void tensor_max_reduce(tensor_t *out, tensor_t *in);
extern void tensor_min_reduce(tensor_t *out, tensor_t *in);
extern void tensor_avg_reduce(tensor_t *out, tensor_t *in);

extern void tensor_cpu_realize(tensor_t *out);
extern void tensor_gpu_realize(tensor_t *out, cl_device_id *device, cl_context *context, cl_command_queue *queue);

extern void tensor_print(tensor_t *tensor, uint64_t padding, uint64_t offset, const char *name);
#define TENSOR_PRINT(tensor) tensor_print(&tensor, 4, 0, (#tensor))
#define TENSOR_PRINT_P(tensor) tensor_print(tensor, 4, 0, (#tensor))

#endif /* TENSOR_H_ */
