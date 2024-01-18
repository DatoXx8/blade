#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

#include "nn.h"
#include "tensor.h"

dense_t dense_alloc(uint64_t previous_size, uint64_t size) {
    dense_t dense = {
        .previous_size = previous_size,
        .size = size,
        .weights = calloc(1, sizeof(tensor_t)),
        .weights_grad = calloc(1, sizeof(tensor_t)),
        .biases = calloc(1, sizeof(tensor_t)),
        .biases_grad = calloc(1, sizeof(tensor_t)),

        .multiply_temp = calloc(1, sizeof(tensor_t)),
    };
    *dense.weights = tensor_alloc(1, 1, previous_size, size);
    *dense.weights_grad = tensor_alloc(1, 1, previous_size, size);
    *dense.biases = tensor_alloc(1, 1, 1, size);
    *dense.biases_grad = tensor_alloc(1, 1, 1, size);

    *dense.multiply_temp = tensor_alloc(1, 1, previous_size, 1);

    return(dense);
}
void dense_free(dense_t *dense) {
    tensor_free(dense->weights);
    tensor_free(dense->weights_grad);
    tensor_free(dense->biases);
    tensor_free(dense->biases_grad);
    free(dense->weights);
    free(dense->weights_grad);
    free(dense->biases);
    free(dense->biases_grad);

    tensor_free(dense->multiply_temp);
    free(dense->multiply_temp);
}
/* [1, 1, 1, a] x [1, 1, a, b] -> [1, 1, 1, b]. */
void dense_forward(tensor_t *previous_activation, dense_t *dense, tensor_t *activation) {

    tensor_set_unary(activation, 0);

    tensor_reshape_move(dense->weights, 1, 1, dense->previous_size, 1);
    tensor_index_move(dense->weights, 0, 0, 0, 0);
    tensor_reshape_move(activation, 1, 1, 1, 1);
    tensor_index_move(activation, 0, 0, 0, 0);

    for(uint64_t i = 0; i < dense->size; i++) {
        tensor_index_move(dense->weights, 0, 0, 0, i);
        tensor_index_move(activation, 0, 0, 0, i);
        tensor_sum_reduce(activation, dense->weights);
        tensor_copy_binary(dense->multiply_temp, previous_activation);
        tensor_multiply_binary(dense->multiply_temp, dense->weights);
        tensor_sum_reduce(activation, dense->multiply_temp);
    }

    tensor_reshape_move(dense->weights, 1, 1, dense->previous_size, dense->size);
    tensor_index_move(dense->weights, 0, 0, 0, 0);
    tensor_reshape_move(activation, 1, 1, 1, dense->size);
    tensor_index_move(activation, 0, 0, 0, 0);
    tensor_add_binary(activation, dense->biases);
}
/* TODO: Implement this. */
void dense_backward(tensor_t *previous_grad, dense_t *dense, tensor_t *grad, tensor_t *activation) {
    tensor_copy_binary(dense->biases_grad, activation);
}
void dense_print_shape(dense_t *dense, uint64_t padding, uint64_t offset, const char *name) {
    if(strcmp(name, "") != 0) {
        printf("%*s%s dense_shape\n", (int) (offset), "", name);
    } else {
        printf("%*sdense_shape\n", (int) (offset), "");
    }
    tensor_cpu_realize(dense->weights);
    printf("%*s Weights shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", dense->weights->view->sizes[_a], dense->weights->view->sizes[_z], dense->weights->view->sizes[_y], dense->weights->view->sizes[_x], dense->weights->view->offset);
    tensor_cpu_realize(dense->weights_grad);
    printf("%*s Weigrad shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", dense->weights_grad->view->sizes[_a], dense->weights_grad->view->sizes[_z], dense->weights_grad->view->sizes[_y], dense->weights_grad->view->sizes[_x], dense->weights_grad->view->offset);
    tensor_cpu_realize(dense->biases);
    printf("%*s Biases  shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", dense->biases->view->sizes[_a], dense->biases->view->sizes[_z], dense->biases->view->sizes[_y], dense->biases->view->sizes[_x], dense->biases->view->offset);
    tensor_cpu_realize(dense->biases_grad);
    printf("%*s Biagrad shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", dense->biases_grad->view->sizes[_a], dense->biases_grad->view->sizes[_z], dense->biases_grad->view->sizes[_y], dense->biases_grad->view->sizes[_x], dense->biases_grad->view->offset);
}
void dense_print_vals(dense_t *dense, uint64_t padding, uint64_t offset, const char *name) {
    if(strcmp(name, "") != 0) {
        printf("%*s%s dense_vals\n", (int) (offset), "", name);
    } else {
        printf("%*sdense_vals\n", (int) (offset), "");
    }
    tensor_cpu_realize(dense->biases);
    view_print(dense->biases->view, padding, padding + offset, "biases");
    tensor_cpu_realize(dense->weights);
    view_print(dense->weights->view, padding, padding + offset, "weights");
}
void dense_print_grad(dense_t *dense, uint64_t padding, uint64_t offset, const char *name) {
    if(strcmp(name, "") != 0) {
        printf("%*s%s dense_grad\n", (int) (offset), "", name);
    } else {
        printf("%*sdense_grad\n", (int) (offset), "");
    }
    tensor_cpu_realize(dense->biases_grad);
    view_print(dense->biases_grad->view, padding, padding + offset, "biases_grad");
    tensor_cpu_realize(dense->weights_grad);
    view_print(dense->weights_grad->view, padding, padding + offset, "weights_grad");
}

convolution_t convolution_alloc(uint64_t channels, uint64_t filters, uint64_t kernel_size, uint64_t padding, uint64_t stride) {
    convolution_t convolution = {
        .channels = channels,
        .filters = filters,
        .kernel_size = kernel_size,
        .padding = padding,
        .stride = stride,
        .weights = calloc(1, sizeof(tensor_t)),
        .weights_grad = calloc(1, sizeof(tensor_t)),
        .biases = calloc(1, sizeof(tensor_t)),
        .biases_grad = calloc(1, sizeof(tensor_t)),

        .multiply_temp = calloc(1, sizeof(tensor_t)),
        .padded_in = calloc(1, sizeof(tensor_t)),
        .sum_temp = calloc(1, sizeof(tensor_t)),
    };
    *convolution.weights = tensor_alloc(channels, filters, kernel_size, kernel_size);
    *convolution.weights_grad = tensor_alloc(channels, filters, kernel_size, kernel_size);
    *convolution.biases = tensor_alloc(1, filters, 1, 1);
    *convolution.biases_grad = tensor_alloc(1, filters, 1, 1);

    *convolution.multiply_temp = tensor_alloc(channels, 1, kernel_size, kernel_size);
    *convolution.sum_temp = tensor_alloc(1, 1, 1, 1);

    return(convolution);
}
void convolution_free(convolution_t *convolution) {
    tensor_free(convolution->weights);
    tensor_free(convolution->weights_grad);
    tensor_free(convolution->biases);
    tensor_free(convolution->biases_grad);
    tensor_free(convolution->multiply_temp);
    tensor_free(convolution->sum_temp);
    free(convolution->weights);
    free(convolution->weights_grad);
    free(convolution->biases);
    free(convolution->biases_grad);
    free(convolution->multiply_temp);
    free(convolution->sum_temp);
}
/* TODO: Implement padding. */
/* NOTE: Not tested but the output looks about right (meaning not zero and not a obvious combination of the input and bias terms). */
void convolution_forward(tensor_t *previous_activation, convolution_t *convolution, tensor_t *activation) {
    uint64_t max_y = previous_activation->view->buffer->sizes[_y] - convolution->kernel_size + 1;
    uint64_t max_x = previous_activation->view->buffer->sizes[_x] - convolution->kernel_size + 1;
    uint64_t out_y;
    uint64_t out_x;
    uint64_t a_a = activation->view->buffer->sizes[_a];
    uint64_t z_a = activation->view->buffer->sizes[_z];
    uint64_t y_a = activation->view->buffer->sizes[_y];
    uint64_t x_a = activation->view->buffer->sizes[_x];
    uint64_t a_pa = previous_activation->view->buffer->sizes[_a];
    uint64_t z_pa = previous_activation->view->buffer->sizes[_z];
    uint64_t y_pa = previous_activation->view->buffer->sizes[_y];
    uint64_t x_pa = previous_activation->view->buffer->sizes[_x];

    tensor_set_unary(activation, 0);

    tensor_reshape_move(convolution->weights, convolution->channels, 1, convolution->kernel_size, convolution->kernel_size);
    tensor_reshape_move(previous_activation, a_pa, 1, convolution->kernel_size, convolution->kernel_size);
    tensor_reshape_move(activation, 1, 1, 1, 1);
    tensor_reshape_move(convolution->biases, 1, 1, 1, 1);

    for(uint64_t filter = 0; filter < convolution->filters; filter++) {
        out_y = 0;
        tensor_index_move(convolution->biases, 0, filter, 0, 0);
        tensor_index_move(convolution->weights, 0, filter, 0, 0);
        for(uint64_t y = 0; y < max_y; y += convolution->stride) {
            out_x = 0;
            for(uint64_t x = 0; x < max_x; x += convolution->stride) {
                tensor_index_move(previous_activation, 0, 0, y, x);
                tensor_index_move(activation, 0, filter, out_y, out_x++);
                tensor_copy_binary(convolution->multiply_temp, previous_activation);
                tensor_multiply_binary(convolution->multiply_temp, convolution->weights);
                tensor_sum_reduce(convolution->sum_temp, convolution->multiply_temp);
                tensor_copy_binary(activation, convolution->biases);
                tensor_add_binary(activation, convolution->sum_temp);
            }
            out_y++;
        }
    }

    tensor_reshape_move(activation, a_a, z_a, y_a, x_a);
    tensor_index_move(activation, 0, 0, 0, 0);
    tensor_reshape_move(previous_activation, a_pa, z_pa, y_pa, x_pa);
    tensor_index_move(previous_activation, 0, 0, 0, 0);
    tensor_reshape_move(convolution->biases, 1, convolution->filters, 1, 1);
    tensor_index_move(convolution->biases, 0, 0, 0, 0);
    tensor_reshape_move(convolution->weights, convolution->channels, convolution->filters, convolution->kernel_size, convolution->kernel_size);
    tensor_index_move(convolution->weights, 0, 0, 0, 0);
}
/* TODO: Implement padding. */
/* TODO: Implement this. */
void convolution_backward(tensor_t *previous_grad, convolution_t *convolution, tensor_t *grad, tensor_t *activation) {
}
void convolution_print_shape(convolution_t *convolution, uint64_t padding, uint64_t offset, const char *name) {
    if(strcmp(name, "") != 0) {
        printf("%*s%s convolution_shape\n", (int) (offset), "", name);
    } else {
        printf("%*sconvolution_shape\n", (int) (offset), "");
    }
    tensor_cpu_realize(convolution->weights);
    printf("%*s Weights shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", convolution->weights->view->sizes[_a], convolution->weights->view->sizes[_z], convolution->weights->view->sizes[_y], convolution->weights->view->sizes[_x], convolution->weights->view->offset);
    tensor_cpu_realize(convolution->weights_grad);
    printf("%*s Weigrad shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", convolution->weights_grad->view->sizes[_a], convolution->weights_grad->view->sizes[_z], convolution->weights_grad->view->sizes[_y], convolution->weights_grad->view->sizes[_x], convolution->weights_grad->view->offset);
    tensor_cpu_realize(convolution->biases);
    printf("%*s Biases  shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", convolution->biases->view->sizes[_a], convolution->biases->view->sizes[_z], convolution->biases->view->sizes[_y], convolution->biases->view->sizes[_x], convolution->biases->view->offset);
    tensor_cpu_realize(convolution->biases_grad);
    printf("%*s Biagrad shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", convolution->biases_grad->view->sizes[_a], convolution->biases_grad->view->sizes[_z], convolution->biases_grad->view->sizes[_y], convolution->biases_grad->view->sizes[_x], convolution->biases_grad->view->offset);
    tensor_cpu_realize(convolution->multiply_temp);
    printf("%*s Multemp shape [%lu, %lu, %lu, %lu] off %lu\n", (int) (offset + padding), "", convolution->multiply_temp->view->sizes[_a], convolution->multiply_temp->view->sizes[_z], convolution->multiply_temp->view->sizes[_y], convolution->multiply_temp->view->sizes[_x], convolution->multiply_temp->view->offset);
}
void convolution_print_vals(convolution_t *convolution, uint64_t padding, uint64_t offset, const char *name) {
    if(strcmp(name, "") != 0) {
        printf("%*s%s convolution_vals\n", (int) (offset), "", name);
    } else {
        printf("%*sconvolution_vals\n", (int) (offset), "");
    }
    tensor_cpu_realize(convolution->biases);
    view_print(convolution->biases->view, padding, padding + offset, "biases");
    tensor_cpu_realize(convolution->weights);
    view_print(convolution->weights->view, padding, padding + offset, "weights");
    tensor_cpu_realize(convolution->multiply_temp);
    view_print(convolution->multiply_temp->view, padding, padding + offset, "multiply");
}
void convolution_print_grad(convolution_t *convolution, uint64_t padding, uint64_t offset, const char *name) {
    if(strcmp(name, "") != 0) {
        printf("%*s%s convolution_vals\n", (int) (offset), "", name);
    } else {
        printf("%*sconvolution_vals\n", (int) (offset), "");
    }
    tensor_cpu_realize(convolution->biases);
    view_print(convolution->biases_grad->view, padding, padding + offset, "biases");
    tensor_cpu_realize(convolution->weights);
    view_print(convolution->weights_grad->view, padding, padding + offset, "weights");
}

reduce_t reduce_alloc(uint64_t kernel_size, uint64_t stride, enum layer_reduce_e type) {
    reduce_t reduce = {
        .kernel_size = kernel_size,
        .stride = stride,
        .type = type,
    };
    return(reduce);
}
// void reduce_free(reduce_t *reduce) {
//     /* Nothin' here. */
// }
void reduce_forward(tensor_t *previous_activation, reduce_t *reduce, tensor_t *activation) {
    uint64_t max_y = previous_activation->view->buffer->sizes[_y] - reduce->kernel_size + 1;
    uint64_t max_x = previous_activation->view->buffer->sizes[_x] - reduce->kernel_size + 1;
    uint64_t out_y;
    uint64_t out_x;
    uint64_t a_a = activation->view->buffer->sizes[_a];
    uint64_t z_a = activation->view->buffer->sizes[_z];
    uint64_t y_a = activation->view->buffer->sizes[_y];
    uint64_t x_a = activation->view->buffer->sizes[_x];
    uint64_t a_pa = previous_activation->view->buffer->sizes[_a];
    uint64_t z_pa = previous_activation->view->buffer->sizes[_z];
    uint64_t y_pa = previous_activation->view->buffer->sizes[_y];
    uint64_t x_pa = previous_activation->view->buffer->sizes[_x];

    tensor_set_unary(activation, 0);

    tensor_reshape_move(activation, 1, 1, 1, 1);
    tensor_reshape_move(previous_activation, 1, 1, reduce->kernel_size, reduce->kernel_size);

    for(uint64_t filter = 0; filter < activation->view->sizes[_z]; filter++) {
        out_y = 0;
        for(uint64_t y = 0; y < max_y; y += reduce->stride) {
            out_x = 0;
            for(uint64_t x = 0; x < max_x; x += reduce->stride) {
                tensor_index_move(previous_activation, 0, filter, y, x);
                tensor_index_move(activation, 0, filter, out_y, out_x++);
                switch(reduce->type) {
                    case(layer_reduce_max): {
                        tensor_max_reduce(activation, previous_activation);
                        break;
                    }
                    case(layer_reduce_min): {
                        tensor_min_reduce(activation, previous_activation);
                        break;
                    }
                    case(layer_reduce_avg): {
                        tensor_avg_reduce(activation, previous_activation);
                        break;
                    }
                }
            }
            out_y++;
        }
    }

    tensor_reshape_move(activation, a_a, z_a, y_a, x_a);
    tensor_index_move(activation, 0, 0, 0, 0);
    tensor_reshape_move(previous_activation, a_pa, z_pa, y_pa, x_pa);
    tensor_index_move(previous_activation, 0, 0, 0, 0);
}
/* TODO: Implement this. */
void reduce_backward(tensor_t *previous_grad, reduce_t *reduce, tensor_t *grad, tensor_t *activation) {
}
void reduce_print_shape(reduce_t *reduce, uint64_t padding, uint64_t offset, const char *name) {
    printf("%*s%s reduce shape\n", (int) (offset), "", name);
    printf("%*stype: %d\n", (int) (offset + padding), "", reduce->type);
    printf("%*sstride: %lu\n", (int) (offset + padding), "", reduce->stride);
    printf("%*skernel size: %lu\n", (int) (offset + padding), "", reduce->kernel_size);
}
// void reduce_print_vals(reduce_t *reduce, uint64_t padding, uint64_t offset, const char *name) {
// }
// void reduce_print_grad(reduce_t *reduce, uint64_t padding, uint64_t offset, const char *name) {
// }

layer_t layer_alloc(layerconf_t *layerconf) {
    layer_t layer = {0};
    switch(layerconf->type) {
        case(input_e): {
            layer.type = input_e;
            layer.activation_type = identity_e;
            layer.activation = calloc(1, sizeof(tensor_t));
            *layer.activation = tensor_alloc(1, layerconf->input_channels, layerconf->input_size, layerconf->input_size);
            layer.activation_grad = calloc(1, sizeof(tensor_t)); // NOT NECESSARY
            *layer.activation_grad = tensor_alloc(1, layerconf->input_channels, layerconf->input_size, layerconf->input_size); // NOT NECESSARY
            break;
        }
        case(dense_e): {
            layer.type = dense_e;
            layer.activation_type = layerconf->activation_type;
            layer.activation = calloc(1, sizeof(tensor_t));
            *layer.activation = tensor_alloc(1, 1, 1, layerconf->dense_size);
            layer.activation_grad = calloc(1, sizeof(tensor_t));
            *layer.activation_grad = tensor_alloc(1, 1, 1, layerconf->dense_size);
            layer.dense = calloc(1, sizeof(dense_t));
            *layer.dense = dense_alloc(layerconf->dense_previous_size, layerconf->dense_size);
            break;
        }
        case(convolution_e): {
            layer.type = convolution_e;
            layer.activation_type = layerconf->activation_type;
            uint64_t new_size = CONVOLUTION_OUTPUT_SIZE(layerconf->convolution_previous_size, layerconf->convolution_padding, layerconf->convolution_kernel_size, layerconf->convolution_stride);
            layer.activation = calloc(1, sizeof(tensor_t));
            *layer.activation = tensor_alloc(1, layerconf->convolution_filters, new_size, new_size);
            layer.activation_grad = calloc(1, sizeof(tensor_t));
            *layer.activation_grad = tensor_alloc(1, layerconf->convolution_filters, new_size, new_size);
            layer.convolution = calloc(1, sizeof(convolution_t));
            *layer.convolution = convolution_alloc(layerconf->convolution_channels, layerconf->convolution_filters, layerconf->convolution_kernel_size, layerconf->convolution_padding, layerconf->convolution_stride);
            break;
        }
        case(reduce_e): {
            layer.type = reduce_e;
            layer.activation_type = layerconf->activation_type;
            uint64_t new_size = REDUCE_OUTPUT_SIZE(layerconf->reduce_previous_size, layerconf->reduce_kernel_size, layerconf->reduce_stride);
            layer.activation = calloc(1, sizeof(tensor_t));
            *layer.activation = tensor_alloc(1, layerconf->reduce_channels, new_size, new_size);
            layer.activation_grad = calloc(1, sizeof(tensor_t));
            *layer.activation_grad = tensor_alloc(1, layerconf->reduce_channels, new_size, new_size);
            layer.reduce = calloc(1, sizeof(reduce_t));
            *layer.reduce = reduce_alloc(layerconf->reduce_kernel_size, layerconf->reduce_stride, layerconf->reduce_type);
            break;
        }
        case(residual_e): {
            fprintf(stderr, "ERROR: Residual connections not yet implemented!\n");
            exit(1);
            break;
        }
    }
    return(layer);
}
/* TODO: Fix this. Doesn't really work cuz something still leaks. */
void layer_free(layer_t *layer) {
    switch(layer->type) {
        case(input_e): {
            tensor_free(layer->activation);
            free(layer->activation);
            layer->activation = NULL;
            tensor_free(layer->activation_grad);
            free(layer->activation_grad);
            layer->activation_grad = NULL;
            break;
        }
        case(dense_e): {
            tensor_free(layer->activation);
            free(layer->activation);
            layer->activation = NULL;
            tensor_free(layer->activation_grad);
            free(layer->activation_grad);
            layer->activation_grad = NULL;
            dense_free(layer->dense);
            free(layer->dense);
            layer->dense = NULL;
            break;
        }
        case(convolution_e): {
            tensor_free(layer->activation);
            free(layer->activation);
            layer->activation = NULL;
            tensor_free(layer->activation_grad);
            free(layer->activation_grad);
            layer->activation_grad = NULL;
            convolution_free(layer->convolution);
            free(layer->convolution);
            layer->convolution = NULL;
            break;
        }
        case(reduce_e): {
            tensor_free(layer->activation);
            free(layer->activation);
            layer->activation = NULL;
            tensor_free(layer->activation_grad);
            free(layer->activation_grad);
            layer->activation_grad = NULL;
            // reduce_free(layer->reduce);
            free(layer->reduce);
            layer->reduce = NULL;
            break;
        }
        case(residual_e): {
            fprintf(stderr, "ERROR: Residual connections not yet implemented!\n");
            exit(1);
            break;
        }
    }
}
void layer_activate(layer_t *layer) {
    switch(layer->activation_type) {
        case(identity_e): {
            break;
        }
        case(sigmoid_e): {
            tensor_negate_unary(layer->activation);
            tensor_exp_unary(layer->activation);
            tensor_add_unary(layer->activation, 1);
            tensor_reciprocal_unary(layer->activation);
            break;
        }
        case(relu_e): {
            tensor_max_unary(layer->activation, 0);
            break;
        }
        case(silu_e): {
            /* Not sure how to this one... */
            fprintf(stderr, "ERROR: SiLU is not yet implemented!\n");
            exit(1);
            break;
        }
        case(gelu_e): {
            /* Not sure how to this one either... */
            fprintf(stderr, "ERROR: GeLU is not yet implemented!\n");
            exit(1);
            break;
        }
        case(tanh_e): {
            fprintf(stderr, "ERROR: Tanh is not yet implemented!\n");
            exit(1);
            break;
        }
    }
}
void layer_activate_derivative(layer_t *layer) {
    switch(layer->activation_type) {
        case(identity_e): {
            tensor_set_unary(layer->activation_grad, 1);
            exit(1);
            break;
        }
        case(sigmoid_e): {
            fprintf(stderr, "ERROR: Sigmoid derivative is not yet implemented!\n");
            exit(1);
            break;
        }
        case(relu_e): {
            fprintf(stderr, "ERROR: ReLU derivative is not yet implemented!\n");
            exit(1);
            break;
        }
        case(silu_e): {
            fprintf(stderr, "ERROR: SiLU derivative is not yet implemented!\n");
            exit(1);
            break;
        }
        case(gelu_e): {
            fprintf(stderr, "ERROR: GeLU derivative is not yet implemented!\n");
            exit(1);
            break;
        }
        case(tanh_e): {
            fprintf(stderr, "ERROR: Tanh derivative is not yet implemented!\n");
            exit(1);
            break;
        }
    }
}

nn_t nn_alloc(nnconf_t *nnconf) {
    assert(nnconf->layerconf[0].type == input_e); /* Input layer has to be an input layer. */
    nn_t nn = {
        .layers = nnconf->layers,
        .layer = calloc(nnconf->layers, sizeof(layer_t)),
    };
    for(uint64_t i = 0; i < nnconf->layers; i++) {
        switch(nnconf->layerconf[i].type) {
            case(input_e): {
                break;
            }
            case(dense_e): {
                nnconf->layerconf[i].dense_previous_size = nn.layer[i - 1].activation->view->sizes[_z] * nn.layer[i - 1].activation->view->sizes[_y] * nn.layer[i - 1].activation->view->sizes[_x];
                break;
            }
            case(convolution_e): {
                nnconf->layerconf[i].convolution_channels = nn.layer[i - 1].activation->view->sizes[_z];
                nnconf->layerconf[i].convolution_previous_size = nn.layer[i - 1].activation->view->sizes[_y]; // Assumes previous layers activation is of shape [1, a, b, b]
                break;
            }
            case(reduce_e): {
                nnconf->layerconf[i].reduce_channels = nn.layer[i - 1].activation->view->sizes[_z]; // Assumes previous layers activation is of shape [1, a, b, b]
                nnconf->layerconf[i].reduce_previous_size = nn.layer[i - 1].activation->view->sizes[_y]; // Assumes previous layers activation is of shape [1, a, b, b]
                break;
            }
            case(residual_e): {
                fprintf(stderr, "ERROR: Residual connections not yet implemented!\n");
                exit(1);
                break;
            }
        }
        nn.layer[i] = layer_alloc(&nnconf->layerconf[i]);
    }
    return(nn);
}
void nn_free(nn_t *nn) {
    for(uint64_t i = 0; i < nn->layers; i++) {
        layer_free(&nn->layer[i]);
    }
    free(nn->layer);
}
void nn_init_random(nn_t *nn) {
    for(uint64_t i = 0; i < nn->layers; i++) {
        switch(nn->layer[i].type) {
            case(input_e): {
                break;
            }
            case(dense_e): {
                tensor_random_unary(nn->layer[i].dense->biases);
                tensor_random_unary(nn->layer[i].dense->weights);
                tensor_cpu_realize(nn->layer[i].dense->biases);
                tensor_cpu_realize(nn->layer[i].dense->weights);
                break;
            }
            case(convolution_e): {
                tensor_random_unary(nn->layer[i].convolution->biases);
                tensor_random_unary(nn->layer[i].convolution->weights);
                tensor_cpu_realize(nn->layer[i].convolution->biases);
                tensor_cpu_realize(nn->layer[i].convolution->weights);
                break;
            }
            case(reduce_e): {
                break;
            }
            case(residual_e): {
                fprintf(stderr, "ERROR: Residual connections not yet implemented!\n");
                exit(1);
                break;
            }
        }
    }
}
void nn_zero_grad(nn_t *nn) {
    for(uint64_t i = 0; i < nn->layers; i++) {
        switch(nn->layer[i].type) {
            case(input_e): {
                break;
            }
            case(dense_e): {
                tensor_set_unary(nn->layer[i].activation_grad, 0);
                tensor_set_unary(nn->layer[i].dense->biases_grad, 0);
                tensor_set_unary(nn->layer[i].dense->weights_grad, 0);
                break;
            }
            case(convolution_e): {
                tensor_set_unary(nn->layer[i].activation_grad, 0);
                tensor_set_unary(nn->layer[i].convolution->biases_grad, 0);
                tensor_set_unary(nn->layer[i].convolution->weights_grad, 0);
                break;
            }
            case(reduce_e): {
                tensor_set_unary(nn->layer[i].activation_grad, 0);
                break;
            }
            case(residual_e): {
                fprintf(stderr, "ERROR: Residual connections not yet implemented!\n");
                exit(1);
                break;
            }
        }
    }
}
/* Input needs to be reshaped, such that input->view->sizes[_a] == 1. Choose the sample using tensor_index_move along the a-axis. */
void nn_evaluate(nn_t *nn, tensor_t *input) {
    // assert(nn->layer[0].activation->view->buffer->sizes[_a] == 1);
    // assert(input->view->sizes[_a] == 1);
    // assert(nn->layer[0].activation->view->buffer->sizes[_z] == input->view->buffer->sizes[_z]);
    // assert(nn->layer[0].activation->view->buffer->sizes[_y] == input->view->buffer->sizes[_y]);
    // assert(nn->layer[0].activation->view->buffer->sizes[_x] == input->view->buffer->sizes[_x]);

    for(uint64_t i = 0; i < nn->layers; i++) {
        switch(nn->layer[i].type) {
            case(input_e): {
                tensor_copy_binary(NN_INPUT_P(nn), input);
                break;
            }
            case(dense_e): {
                dense_forward(nn->layer[i - 1].activation, nn->layer[i].dense, nn->layer[i].activation);
                layer_activate(&nn->layer[i]);
                break;
            }
            case(convolution_e): {
                convolution_forward(nn->layer[i - 1].activation, nn->layer[i].convolution, nn->layer[i].activation);
                layer_activate(&nn->layer[i]);
                break;
            }
            case(reduce_e): {
                reduce_forward(nn->layer[i - 1].activation, nn->layer[i].reduce, nn->layer[i].activation);
                layer_activate(&nn->layer[i]);
                break;
            }
            case(residual_e): {
                fprintf(stderr, "ERROR: Residual connections not yet implemented!\n");
                exit(1);
                break;
            }
        }
    }
    tensor_cpu_realize(NN_OUTPUT_P(nn));
}
void nn_backward(nn_t *nn, tensor_t *input, tensor_t *output);
