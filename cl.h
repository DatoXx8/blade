#ifndef CL_H_
#define CL_H_

#include "CL/cl.h"
#include "stdlib.h"
#include "stdio.h"

extern cl_device_id create_device(void);
extern cl_program build_program(cl_context ctx, cl_device_id dev, const char *filename);

#endif
