#include <stdio.h>
#include <stdint.h>

#define WALL 0xFFFFFFFF

static const uint32_t primes[16] = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53};
static uint32_t maze[16][16];
static char id_buffer[9];

static uint32_t rotate_left(uint32_t value, uint32_t shift) {
    shift &= 31;
    if (shift == 0) return value;
    return (value << shift) | (value >> (32 - shift));
}

static uint32_t rotate_right(uint32_t value, uint32_t shift) {
    shift &= 31;
    if (shift == 0) return value;
    return (value >> shift) | (value << (32 - shift));
}

static int validate_id() {
    int count = 0;
    for (int i = 0; i < 9; i++) {
        char c = id_buffer[i];
        if (c == '\n' || c == '\0') break;
        if (c < '0' || c > '9') return 0;
        count++;
    }
    return count == 8;
}

static uint32_t atoi_id(const char *s) {
    uint32_t result = 0;
    while (*s && *s != '\n') {
        result = result * 10 + (uint32_t)(*s - '0');
        s++;
    }
    return result;
}

static void generate_maze(uint32_t id) {
    for (uint32_t x = 0; x < 16; x++) {
        for (uint32_t y = 0; y < 16; y++) {
            if (id % primes[y] == 0 || id % primes[x] == 0) {
                maze[x][y] = WALL;
            } else {
                uint32_t cell = ((x << 16) | y) ^ id;
                maze[x][y] = rotate_left(cell, id & 31);
            }
        }
    }
}

static void print_maze() {
    printf("\nMemory Maze (16x16):\n");
    for (uint32_t x = 0; x < 16; x++) {
        for (uint32_t y = 0; y < 16; y++) {
            if (maze[x][y] == WALL) {
                printf("X        ");
            } else {
                printf("%08X ", maze[x][y]);
            }
        }
        putchar('\n');
    }
}

static void decode_maze(uint32_t id) {
    printf("\nDecoded Coordinates (hex x y):\n");
    uint32_t shift = id & 31;
    for (uint32_t x = 0; x < 16; x++) {
        for (uint32_t y = 0; y < 16; y++) {
            uint32_t raw = maze[x][y];
            if (raw == WALL || raw == 0) continue;
            uint32_t decoded = rotate_right(raw, shift) ^ id;
            uint32_t dx = decoded >> 16;
            uint32_t dy = decoded & 0xFFFF;
            printf("%08X %u %u\n", raw, dx, dy);
        }
    }
}

int main() {
    while (1) {
        printf("Enter 8-digit ID: ");
        fgets(id_buffer, (int)sizeof(id_buffer), stdin);
        if (!validate_id()) {
            printf("Invalid ID! Must be 8 digits.\n");
            continue;
        }
        uint32_t id = atoi_id(id_buffer);
        generate_maze(id);
        print_maze();
        decode_maze(id);
        break;
    }
    return 0;
}