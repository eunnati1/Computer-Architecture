.data
msg1:	.asciiz "Enter the first number: \n"
msg2:	.asciiz "Enter the second number: \n"
msg:	.asciiz " The product \n"
.text
.globl main
.globl my_mul

main:
addi $sp, $sp, -8
sw $ra, 4($sp)
sw $fp, 0($sp)

la $a0, msg1
li $v0, 4
syscall
li $v0,5
syscall
add $t0, $v0, $0
la $a0, msg2
li $v0, 4
syscall
li $v0,5
syscall
add $a1, $v0, $0
add $a0, $t0,$0
add $fp, $sp, $0

jal my_mul
add $t0, $v0, $0
la $a0, msg
li $v0,4
syscall
add $a0, $t0, $0
li $v0,1
syscall

lw $fp, 0($sp)
lw $ra, 4($sp)

addi $sp, $sp, 8
j exit

my_mul:

addi $sp, $sp,-4
sw $s0, 0($sp)

add $s0, $a1, $0
add $v0,$0,$0

mult_loop:
beq $s0, $0, mult_eol
andi $t2, $s0,1
bne $t2,1,name1
add $v0, $v0, $a0
name1:
sll $a0,$a0,1
srl $s0,$s0,1

j mult_loop

mult_eol:
lw $s0,0($sp)
jr $ra
exit: