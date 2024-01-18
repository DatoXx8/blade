set -xe

# clang main.c tensor.c cl.c nn.c chess.c engine.c -o blade -O3 -mavx2 -Wall -Wextra -ggdb -lm -lOpenCL
clang main.c tensor.c cl.c nn.c chess.c engine.c -o blade -O0 -Wall -Wextra -ggdb -lm -lOpenCL
./blade
