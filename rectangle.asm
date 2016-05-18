# ======================================
# Lab no. 2
# Title: Drawing Rectangles
#
# Coded by:
# Rafed Muhammad Yasir
# BSSE 0733
# ======================================

########## Data Segment ##########
	.data
prompt_length: .asciiz "Enter maximum length of the rectangle: "
prompt_rect_num: .asciiz "Enter the number of rectangles to be displayed: "

space: .asciiz " "
newline: .asciiz "\n"
dot: .asciiz "."

########## Code Segment ##########
	.text
	.globl main
main:

# Taking input of maximum length
	li $v0, 4
	la $a0, prompt_length
	syscall

	li $v0, 5
	syscall
	
	addu $s4, $zero, $v0
	addiu $s4, $s4, -1
	
# Taking input of number of rectangles in $s0
	li $v0, 4
	la $a0, prompt_rect_num
	syscall

	li $v0, 5
	syscall
	addu $s0, $v0, $zero
	
# Loop to print rectangles	
	xor $t1, $t1, $t1	# Loop variable
L1:
	slt $t0, $t1, $s0
	beq $t0, $zero, E1
	
		# Generating length in range
		xor $a0, $a0, $a0
		addu $a1, $zero, $s4
		li $v0, 42
		syscall	
		
		addiu $a0, $a0, 2
		
		# Storing length in stack
		addiu $sp, $sp, -4
		sw $a0, 0($sp)
		
		# Generating random x ordinate
		xor $a0, $a0, $a0
		addiu $a1, $zero, 80
		li $v0, 42
		syscall	
		# Storing x in stack
		addiu $sp, $sp, -4
		sw $a0, 0($sp)
		
		# Generating random y ordinate
		xor $a0, $a0, $a0
		addiu $a1, $zero, 7
		li $v0, 42
		syscall	
		addiu $a0, $a0, 2
		# Storing y in stack
		addiu $sp, $sp, -4
		sw $a0, 0($sp)
	
		jal RECT
		
		li $v0, 32
		addiu $a0, $zero, 1500
		syscall
	
	addiu $t1, $t1, 1
	j L1
E1:

# Terminate program
EXIT: 
	li $v0,10
	syscall

########## Program terminates ##########

# Procedure for printing rectangle
RECT:
	# Loading y-ordinate from stack
	lw $s3, 0($sp)
	addiu $sp, $sp, 4
	
	# Loading x-ordinate from stack
	lw $s2, 0($sp)
	addiu $sp, $sp, 4
	
	# Loading length from stack
	lw $s1, 0($sp)
	addiu $sp, $sp, 4
	
	xor $t2, $t2, $t2		# Loop variable
	forY:
		slt $t0, $t2, $s3
		beq $t0, $zero, endforY
		
		xor $t3, $t3, $t3	# Loop variable
		forX:
			slt $t0, $t3, $s2
			beq $t0, $zero, endforX
			
			# Printing space
			li $v0, 4
			la $a0, space
			syscall
			
			addiu $t3, $t3, 1
			j forX
		endforX:
		
		xor $t3, $t3, $t3	# Loop variable
		forLength:
			slt $t0, $t3, $s1
			beq $t0, $zero, endforLength
			
			# Printing dots
			li $v0, 4
			la $a0, dot
			syscall
			
			addiu $t3, $t3, 1
			j forLength
		endforLength:
		
		li $v0, 4
		la $a0, newline
		syscall
		
		addiu $t2, $t2, 1
		j forY
	endforY:
	
	jr $ra
