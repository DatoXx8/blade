#ifndef NN_H_
#define NN_H_

#include <stdint.h>

#include "tensor.h"

enum activation_e {
    activation_identity = 0, activation_sigmoid, activation_relu, activation_silu, activation_gelu, activation_tanh
};

extern void tensor_activate(tensor_t *activation, enum activation_e type);
extern void tensor_activation_derivative(tensor_t *activation_derivative, enum activation_e type, tensor_t *activation);

/* TODO: Implement norms. */

typedef struct {

} norm_t;

enum layer_e {
    layer_input = 0, layer_dense, layer_convolution, layer_reduce, layer_residual
};

typedef struct {
    tensor_t *weights;
    tensor_t *weights_grad;
    tensor_t *biases;
    tensor_t *biases_grad;
    uint64_t previous_size;
    uint64_t size;

    /* Calculation stuff. */
    tensor_t *multiply_temp;
    tensor_t *activation_derivative;
} dense_t;

typedef struct {
    tensor_t *weights;
    tensor_t *weights_grad;
    tensor_t *biases;
    tensor_t *biases_grad;
    uint64_t input_size;
    uint64_t channels;
    uint64_t filters;
    uint64_t kernel_size;
    uint64_t padding;
    uint64_t stride;

    /* Calculation stuff. */
    tensor_t *padded_in;
    tensor_t *multiply_temp;
    tensor_t *sum_temp;
} convolution_t;

enum layer_reduce_e {
    layer_reduce_max = 0, layer_reduce_min, layer_reduce_avg
};

typedef struct {
    uint64_t kernel_size;
    uint64_t stride;
    enum layer_reduce_e type;

    /* Calculation stuff. */
} reduce_t;

/* Just a layer number from which the activation will be added? */
typedef struct {
} residual_t;

typedef struct {
    enum layer_e type;

    uint64_t input_channels;
    uint64_t input_size;

    uint64_t dense_previous_size; /* Should never be set directly. */
    uint64_t dense_size;

    uint64_t convolution_previous_size; /* Should never be set directly. */
    uint64_t convolution_channels; /* Should never be set directly. */
    uint64_t convolution_filters;
    uint64_t convolution_kernel_size;
    uint64_t convolution_padding;
    uint64_t convolution_stride;
    
    uint64_t reduce_previous_size; /* Should never be set directly. */
    uint64_t reduce_channels; /* Should never be set directly. */
    uint64_t reduce_kernel_size;
    uint64_t reduce_stride;
    enum layer_reduce_e reduce_type;
    enum activation_e activation_type;
} layerconf_t;

typedef struct {
    enum layer_e type;
    enum activation_e activation_type;
    dense_t *dense;
    convolution_t *convolution;
    reduce_t *reduce;
    residual_t *residual;
    norm_t *norm;
    tensor_t *activation;
    tensor_t *activation_grad;
} layer_t;

typedef struct {
    uint64_t layers;
    layerconf_t *layerconf;
} nnconf_t;

typedef struct {
    uint64_t layers;
    layer_t *layer;
} nn_t;

extern dense_t dense_alloc(uint64_t previous_size, uint64_t size);
extern void dense_free(dense_t *dense);
extern void dense_forward(tensor_t *previous_activation, dense_t *dense, tensor_t *activation);
extern void dense_backward(tensor_t *previous_grad, tensor_t *previous_activation, dense_t *dense, enum activation_e type, tensor_t *grad, tensor_t *activation);
extern void dense_print_shape(dense_t *dense, uint64_t padding, uint64_t offset, const char *name);
extern void dense_print_vals(dense_t *dense, uint64_t padding, uint64_t offset, const char *name);
extern void dense_print_grad(dense_t *dense, uint64_t padding, uint64_t offset, const char *name);

extern convolution_t convolution_alloc(uint64_t input_size, uint64_t channels, uint64_t filters, uint64_t kernel_size, uint64_t padding, uint64_t stride);
extern void convolution_free(convolution_t *convolution);
extern void convolution_forward(tensor_t *previous_activation, convolution_t *convolution, tensor_t *activation);
extern void convolution_backward();
extern void convolution_print_shape(convolution_t *convolution, uint64_t padding, uint64_t offset, const char *name);
extern void convolution_print_vals(convolution_t *convolution, uint64_t padding, uint64_t offset, const char *name);
extern void convolution_print_grad(convolution_t *convolution, uint64_t padding, uint64_t offset, const char *name);
#define CONVOLUTION_OUTPUT_SIZE(size, padding, kernel_size, stride) (((size) + 2 * (padding) - (kernel_size)) / (stride) + 1)

extern reduce_t reduce_alloc(uint64_t size, uint64_t stride, enum layer_reduce_e type);
// extern void reduce_free(reduce_t *reduce);
extern void reduce_forward(tensor_t *previous_activation, reduce_t *reduce, tensor_t *activation);
extern void reduce_backward();
extern void reduce_print_shape(reduce_t *reduce, uint64_t padding, uint64_t offset, const char *name);
extern void reduce_print_vals(reduce_t *reduce, uint64_t padding, uint64_t offset, const char *name);
extern void reduce_print_grad(reduce_t *reduce, uint64_t padding, uint64_t offset, const char *name);
#define REDUCE_OUTPUT_SIZE(size, kernel_size, stride) (((size) - (kernel_size)) / (stride) + 1)

extern layer_t layer_alloc(layerconf_t *layerconf);
extern void layer_free(layer_t *layer);
extern void layer_activation_derivative(layer_t *layer);

extern nn_t nn_alloc(nnconf_t *nnconf);
extern void nn_free(nn_t *nn);
extern void nn_init_random(nn_t *nn);
extern void nn_zero_grad(nn_t *nn);
extern void nn_evaluate(nn_t *nn, tensor_t *input);
extern void nn_backward(nn_t *nn, tensor_t *input, tensor_t *output);
extern void nn_learn(nn_t *nn, double learning);
extern void nn_step(nn_t *nn, tensor_t *input, tensor_t *output, double learning);
extern void nn_print_shape(nn_t *nn, uint64_t padding, uint64_t offset, const char *name);
extern void nn_print_vals(nn_t *nn, uint64_t padding, uint64_t offset, const char *name);
extern void nn_print_grad(nn_t *nn, uint64_t padding, uint64_t offset, const char *name);
#define NN_INPUT(nn) ((nn).layer[0].activation)
#define NN_INPUT_P(nn) ((nn)->layer[0].activation)
#define NN_OUTPUT(nn) ((nn).layer[(nn).layers - 1].activation)
#define NN_OUTPUT_P(nn) ((nn)->layer[(nn)->layers - 1].activation)

#endif
