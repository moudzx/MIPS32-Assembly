
<h1>Output: </h1>
<code>#!/bin/bash </code><br>
// Assembly <br>
<code>sudo apt install spim</code> <br>
<code>spim -f maze.s </code><br>
// C  <br>
<code>gcc maze.c && ./a.out </code><br><br>
<img width="1255" height="698" alt="Output" src="https://github.com/user-attachments/assets/2b39c347-e7e1-4c43-b2a8-4cd9aeb66b08" />


<h2> Explanation: </h2>
<ul>
Ask the user for an 8-digit ID <br>
Create a 16*16 Maze (<code>int32_t grid[16][16]</code>) <br>
for each cell in the grid <br>
if cell == wall : it's marked "X" <br>
else it's position value is encrypted and stored in the grid array as a 32-bit cipher <br>
 <br> <br> <br>
 
<li><h3>Wall generation:</h3>
// walls are determined by (ID % prime_number) == 0 for sequential primes < 50 <br> <br>
sequential primes < 50 are exactly 15 primes <br>
for the sake of simplicity, let's consider instead the first 16 primes <br>
prime[16] = {first 16 primes} <br> <br>
walk through the grid cell by cell <br>
cell(0,0) uses prime[0]=2 <br>
cell(0,1) uses prime[1]=3 <br>
... <br>
cell(0,15) uses prime[15]=47 <br>
cell(1,0) uses prime[0]=2 <br>
... <br>
cell(x,y) uses prime[y] <br> <br>
this will generate a vertical wall for each column that statisfies the formula <br>
combine it with prime[x] to generate horizontal walls <br> <br> <br> <br></li>
<li><h3>Encrypting the grid:</h3>
<code>cell_value = rotate_left(((x<<16 | y) XOR ID), ID % 32) </code> <br> <br>
step by step: <br> <br>
if cell is not a wall <br> <br>
the cell value is a 32 bit integer (4 bytes) <br>
x is at [0;16[ so max binary value <br>
00000000 00000000 00000000 00001111 = x <br> <br>
x<<16 is a left shift by 16 bits (2 bytes) <br>
00000000 00001111 00000000 00000000 = x<<16 <br> <br>
x<<16 | y is the union of the 2 numbers <br>
y is also at [0;16[, if (x,y)=(15,15) then <br>
00000000 00001111 00000000 00001111 = x<<16 | y <br> <br>
XOR this result with the ID (32-bit integer) <br>
XOR (exclusive or): A XOR B = 1 if exactly one of A or B is 1, else 0 <br>
let's pretend that <br>
11111111 00001111 11111111 00001111 = ID <br>
00000000 00001111 00000000 00001111 = x<<16 | y <br>
then <br>
11111111 00000000 11111111 00000000 = (x<<16 | y) XOR ID <br> <br> <br>
rotate this result left by ID % 32 <br>
rotation means bits that fall off the left end come back on the right <br>
note: ID % 32 == ID & 31 <br>
store this result in the grid array <br> <br> <br></li>
 
<li><h3>Decrypting the grid:</h3>
<code>temp = rotate_right(code, ID % 32) XOR ID</code><br>
<code>x = (temp >> 16) & 0xFFFF</code> <br>
<code>y = temp & 0xFFFF</code> <br>
//the four buffers requirement is vague, i skipped it. <br>
 <br>
step by step: <br> <br>
reverse the rotation <br>
temp = rotate the code right by ID % 32 <br> <br>
reserve the XOR <br>
XOR is its own reverse <br>
temp = temp XOR ID <br> <br>
extract x and y <br>
x is the first 16 bits <br>
y is the last 16 bits <br> <br>
x = (position >> 16) & 0xFFFF <br>
shift right 16 bits, mask to 16 bits <br> <br>
y = position & 0xFFFF <br>
just take low 16 bits <br> <br> <br> </li>

<li><h3>Reverse engineering to find the ID:</h3>
//not implemented in code <br>
<code>cell_value = rotate_left(((x<<16 | y) XOR ID), ID % 32) </code> <br> <br>
the key is to find the rotating value R = ID % 32 <br>
which has only 32 possibilities <br>
so brute force is easy <br> <br>
once R is determined, we can compute <br>
(x<<16 | y) XOR ID = rotate_right(cell_value, R) <br>
ID = rotate_right(cell_value, R) XOR (x<<16 | y) <br> <br> <br> </li>
</ul>
