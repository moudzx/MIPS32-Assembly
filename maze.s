.data
.align 2
prompt_id:      .asciiz "Enter 8-digit ID: "
invalid_id:     .asciiz "Invalid ID! Must be 8 digits.\n"
wall_char:      .asciiz "X"
space:          .asciiz " "
newline:        .asciiz "\n"
maze_title:     .asciiz "\nMemory Maze (16x16):\n"
decode_title:   .asciiz "\nDecoded Coordinates (hex x y):\n"
.align 2
primes:         .word 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53
.align 2
maze:           .space 1024
id_buffer:      .space 9
hexdigits:      .asciiz "0123456789ABCDEF"

.text
.globl main

main:
    li      $v0, 4
    la      $a0, prompt_id
    syscall
    li      $v0, 8
    la      $a0, id_buffer
    li      $a1, 9
    syscall
    jal     validate_id
    beqz    $v0, id_invalid
    la      $a0, id_buffer
    jal     atoi
    move    $s0, $v0
    move    $a0, $s0
    jal     generate_maze
    jal     print_maze
    move    $a0, $s0
    jal     decode_maze
    li      $v0, 10
    syscall

id_invalid:
    li      $v0, 4
    la      $a0, invalid_id
    syscall
    j       main

validate_id:
    li      $t0, 0
    la      $t1, id_buffer
validate_loop:
    lb      $t2, 0($t1)
    beq     $t2, 10, validate_done
    beq     $t2, 0, validate_done
    blt     $t2, '0', validate_fail
    bgt     $t2, '9', validate_fail
    addi    $t0, $t0, 1
    addi    $t1, $t1, 1
    j       validate_loop
validate_done:
    li      $v0, 1
    beq     $t0, 8, validate_return
validate_fail:
    li      $v0, 0
validate_return:
    jr      $ra

atoi:
    li      $v0, 0
    li      $t0, 10
atoi_loop:
    lb      $t1, 0($a0)
    beq     $t1, 10, atoi_done
    beq     $t1, 0, atoi_done
    subu    $t1, $t1, '0'
    mul     $v0, $v0, $t0
    add     $v0, $v0, $t1
    addi    $a0, $a0, 1
    j       atoi_loop
atoi_done:
    jr      $ra

rotate_left:
    andi    $a1, $a1, 31
    beqz    $a1, rotate_left_no
    sllv    $t0, $a0, $a1
    li      $t1, 32
    sub     $t1, $t1, $a1
    srlv    $t1, $a0, $t1
    or      $v0, $t0, $t1
    jr      $ra
rotate_left_no:
    move    $v0, $a0
    jr      $ra

rotate_right:
    andi    $a1, $a1, 31
    beqz    $a1, rotate_right_no
    srlv    $t0, $a0, $a1
    li      $t1, 32
    sub     $t1, $t1, $a1
    sllv    $t1, $a0, $t1
    or      $v0, $t0, $t1
    jr      $ra
rotate_right_no:
    move    $v0, $a0
    jr      $ra

generate_maze:
    addi    $sp, $sp, -32
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)
    sw      $s3, 16($sp)
    sw      $s4, 20($sp)
    sw      $s5, 24($sp)
    sw      $s6, 28($sp)
    move    $s0, $a0
    la      $s1, primes
    li      $s2, 0
gen_x:
    bge     $s2, 16, gen_done
    li      $s3, 0
gen_y:
    bge     $s3, 16, gen_next_x
    mul     $t0, $s2, 16
    add     $t0, $t0, $s3
    sll     $t0, $t0, 2
    la      $t1, maze
    add     $t0, $t0, $t1
    sll     $t2, $s3, 2
    add     $t2, $s1, $t2
    lw      $t3, 0($t2)
    sll     $t4, $s2, 2
    add     $t4, $s1, $t4
    lw      $t5, 0($t4)
    div     $s0, $t3
    mfhi    $t6
    beqz    $t6, is_wall
    div     $s0, $t5
    mfhi    $t6
    bnez    $t6, not_wall
is_wall:
    li      $t7, -1
    sw      $t7, 0($t0)
    j       next_cell
not_wall:
    sll     $t7, $s2, 16
    or      $t7, $t7, $s3
    xor     $t7, $t7, $s0
    andi    $t8, $s0, 31
    addi    $sp, $sp, -16
    sw      $t0, 0($sp)
    sw      $s2, 4($sp)
    sw      $s3, 8($sp)
    sw      $t7, 12($sp)
    move    $a0, $t7
    move    $a1, $t8
    jal     rotate_left
    lw      $t0, 0($sp)
    lw      $s2, 4($sp)
    lw      $s3, 8($sp)
    lw      $t7, 12($sp)
    addi    $sp, $sp, 16
    sw      $v0, 0($t0)
next_cell:
    addi    $s3, $s3, 1
    j       gen_y
gen_next_x:
    addi    $s2, $s2, 1
    j       gen_x
gen_done:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    lw      $s3, 16($sp)
    lw      $s4, 20($sp)
    lw      $s5, 24($sp)
    lw      $s6, 28($sp)
    addi    $sp, $sp, 32
    jr      $ra

print_hex:
    move    $t0, $a0
    la      $t1, hexdigits
    li      $t2, 28
    li      $t3, 8
ph_loop:
    blez    $t3, ph_done
    srl     $t4, $t0, $t2
    andi    $t4, $t4, 0xF
    add     $t4, $t1, $t4
    lb      $a0, 0($t4)
    li      $v0, 11
    syscall
    addi    $t3, $t3, -1
    addi    $t2, $t2, -4
    j       ph_loop
ph_done:
    jr      $ra

print_maze:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    li      $v0, 4
    la      $a0, maze_title
    syscall
    li      $t0, 0
pm_xloop:
    bge     $t0, 16, pm_done
    li      $t1, 0
pm_yloop:
    bge     $t1, 16, pm_nextx
    mul     $t2, $t0, 16
    add     $t2, $t2, $t1
    sll     $t2, $t2, 2
    la      $t3, maze
    add     $t2, $t2, $t3
    lw      $t4, 0($t2)
    li      $t5, -1
    beq     $t4, $t5, pm_wall
    addi    $sp, $sp, -8
    sw      $t0, 0($sp)
    sw      $t1, 4($sp)
    move    $a0, $t4
    jal     print_hex
    lw      $t0, 0($sp)
    lw      $t1, 4($sp)
    addi    $sp, $sp, 8
    li      $v0, 4
    la      $a0, space
    syscall
    j       pm_nextcell
pm_wall:
    li      $v0, 4
    la      $a0, wall_char
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
pm_nextcell:
    addi    $t1, $t1, 1
    j       pm_yloop
pm_nextx:
    li      $v0, 4
    la      $a0, newline
    syscall
    addi    $t0, $t0, 1
    j       pm_xloop
pm_done:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra

decode_maze:
    addi    $sp, $sp, -32
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)
    sw      $s3, 16($sp)
    sw      $s4, 20($sp)
    sw      $s5, 24($sp)
    sw      $s6, 28($sp)
    move    $s0, $a0
    li      $v0, 4
    la      $a0, decode_title
    syscall
    li      $s1, 0
dm_xloop:
    bge     $s1, 16, dm_done
    li      $s2, 0
dm_yloop:
    bge     $s2, 16, dm_nextx
    mul     $t0, $s1, 16
    add     $t0, $t0, $s2
    sll     $t0, $t0, 2
    la      $t1, maze
    add     $t0, $t0, $t1
    lw      $s3, 0($t0)
    li      $t2, -1
    beq     $s3, $t2, dm_skip
    beqz    $s3, dm_skip
    andi    $t2, $s0, 31
    move    $a0, $s3
    move    $a1, $t2
    jal     rotate_right
    xor     $v0, $v0, $s0
    srl     $s4, $v0, 16
    andi    $s5, $v0, 0xFFFF
    move    $a0, $s3
    jal     print_hex
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 1
    move    $a0, $s4
    syscall
    li      $v0, 4
    la      $a0, space
    syscall
    li      $v0, 1
    move    $a0, $s5
    syscall
    li      $v0, 4
    la      $a0, newline
    syscall
dm_skip:
    addi    $s2, $s2, 1
    j       dm_yloop
dm_nextx:
    addi    $s1, $s1, 1
    j       dm_xloop
dm_done:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    lw      $s3, 16($sp)
    lw      $s4, 20($sp)
    lw      $s5, 24($sp)
    lw      $s6, 28($sp)
    addi    $sp, $sp, 32
    jr      $ra