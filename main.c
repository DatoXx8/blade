#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <CL/cl.h>

// #include "chess.h"
// #include "engine.h"
#include "tensor.h"
#include "nn.h"

/* TODO: Remove all the asserts for function calls at runtime, instead check at NN allocation so it only needs to be done once */

const double learning = 1e-3;
const double epsilon = 0.2; /* Used in the clipping function */
const double alpha = 0.95; /* Discount rate */

#define PROGRAM_FILE "add_numbers.cl"
#define KERNEL_FUNC "add_numbers"
#define ARRAY_SIZE 64

int main(void) {
    uint64_t seed = time(NULL);
    printf("INFO: RNG seed %lu\n", seed);
    srand(seed);

    clock_t start;
    clock_t stop;

    const uint64_t ic = 2;
    const uint64_t is = 4;
    layerconf_t in = {
        .type = input_e,
        .input_size = is,
        .input_channels = ic,
    };
    layerconf_t conv = {
        .type = convolution_e,
        .convolution_filters = 2,
        .convolution_kernel_size = 2,
        .convolution_padding = 0,
        .convolution_stride = 1,
        .activation_type = relu_e,
    };
    layerconf_t reduce = {
        .type = reduce_e,
        .reduce_type = layer_reduce_max,
        .reduce_kernel_size = 2,
        .reduce_stride = 1,
    };
    layerconf_t dense = {
        .type = dense_e,
        .dense_size = 3,
        .activation_type = identity_e,
    };

    const uint64_t layers = 2;
    nnconf_t nnconf = {
        .layers = layers,
        .layerconf = calloc(layers, sizeof(layerconf_t)),
    };
    nnconf.layerconf[0] = in;
    nnconf.layerconf[1] = dense;

    tensor_t input = tensor_alloc(1, ic, is, is);
    nn_t nn = nn_alloc(&nnconf);
    nn_init_random(&nn);

    START_TIMING;

    tensor_random_unary(&input);
    nn_evaluate(&nn, &input);
    TENSOR_PRINT_P(nn.layer[0].activation);
    TENSOR_PRINT_P(nn.layer[1].activation);

    STOP_TIMING;

    PRINT_TIME_IN_SECONDS;
    PRINT_TIME_IN_MILLISECONDS;
    PRINT_TIME_IN_MICROSECONDS;
    

    return(0);
}


// cl_device_id device;
// cl_context context;
// cl_program program;
// cl_kernel kernel;
// cl_command_queue queue;
// cl_int i, j, err;
// uint64_t local_size, global_size;
//
// float data[ARRAY_SIZE];
// float sum[2], total, actual_sum;
// cl_mem input_buffer, sum_buffer;
// cl_int num_groups;
// for(i = 0; i < ARRAY_SIZE; i++) {
//     data[i] = 1.f * i;
// }
// device = create_device();
// context = clCreateContext(NULL, 1, &device, NULL, NULL, &err);
// if(err < 0) {
//     fprintf(stderr, "ERROR: Could not create CL context\n");
//     exit(1);
// }
// program = build_program(context, device, PROGRAM_FILE);
// global_size = 8;
// local_size = 4;
// num_groups = global_size / local_size;
// input_buffer = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, ARRAY_SIZE * sizeof(float), data, &err);
// sum_buffer = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, num_groups * sizeof(float), sum, &err);
// if(err < 0) {
//     fprintf(stderr, "ERROR: Could not create buffer\n");
//     exit(1);
// }
//
// queue = clCreateCommandQueueWithProperties(context, device, 0, &err);
// if(err < 0) {
//     fprintf(stderr, "ERROR: Could not create command queue\n");
//     exit(1);
// }
//
// kernel = clCreateKernel(program, KERNEL_FUNC, &err);
// if(err < 0) {
//     fprintf(stderr, "ERROR: Could not create kernel\n");
//     exit(1);
// }
//
// err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &input_buffer);
// err |= clSetKernelArg(kernel, 1, local_size * sizeof(float), NULL);
// err |= clSetKernelArg(kernel, 2, sizeof(cl_mem), &sum_buffer);
// if(err < 0) {
//     fprintf(stderr, "ERROR: Could not create kernel arguments\n");
//     exit(1);
// }
//
// err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, &local_size, 0, NULL, NULL);
// if(err < 0) {
//     fprintf(stderr, "ERROR: Could not enqueue the buffer\n");
//     exit(1);
// }
//
// err = clEnqueueReadBuffer(queue, sum_buffer, CL_TRUE, 0, sizeof(sum), sum, 0, NULL, NULL);
// if(err < 0) {
//     fprintf(stderr, "ERROR: Could not read the output buffer\n");
//     exit(1);
// }
//
// total = 0;
// for(j = 0; j < num_groups; j++) {
//     total += sum[j];
// }
// actual_sum = 1.0 * ARRAY_SIZE/2*(ARRAY_SIZE - 1);
// printf("Computed sum = %.1f\n", total);
// if(fabs(total - actual_sum) > 0.01*fabs(actual_sum)) {
//     printf("Difference: %f\n", total - actual_sum);
//     printf("INFO: Check failed\n");
// } else {
//     printf("Difference: %f\n", total - actual_sum);
//     printf("INFO: Check passed\n");
// }
//
// clReleaseKernel(kernel);
// clReleaseMemObject(sum_buffer);
// clReleaseMemObject(input_buffer);
// clReleaseCommandQueue(queue);
// clReleaseProgram(program);
// clReleaseContext(context);
