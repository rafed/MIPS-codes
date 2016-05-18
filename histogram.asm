# ======================================
# Lab no. 4
# Title: Drawing Histogram
#
# Coded by:
# Rafed Muhammad Yasir
# BSSE 0733
# ======================================

########## Data Segment ##########
	.data
prompt: .asciiz "Enter a string of characters: "
show: .asciiz "String Histogram:\n"

string: .space 500
counter: .space 26

star: .byte '*'
space: .asciiz " "
newline: .asciiz "\n"

########## Code Segment ##########
	.text
	.globl main
main:

# Taking input of string
	li $v0, 4
	la $a0, prompt
	syscall

	li $v0, 8
	la $a0, string
	li $a1, 500
	syscall
	
# Count the letters
	jal CCount
	
# Make histogram
	jal histogram
	
# Print histogram
	li $v0, 4
	la $a0, show
	syscall
	
	jal RECT

# Terminate program
EXIT: 
	li $v0,10
	syscall
########## Program terminates ##########

CCount:
	xor $s5, $s5, $s5		# size of string
	la $s0, string
loop:   lb $t0, 0($s0)
	beqz $t0, out
	addiu $s0, $s0, 1
	addiu $s5, $s5, 1
	j loop
out:    

	xor $t1, $t1, $t1		# Loop variable
L1:
	beq $t1, $s5, E1
	
	lb $t0, string($t1)		# Take a character
	
	bgt $t0, 90, cont1		# If character is uppercase make it lowercase
	    addi $t0, $t0, 32
	    sb $t0, string($t1)		# Store changed chracter
	cont1:
	
	addiu $t1, $t1, 1
	j L1
E1:
	
	
	xor $t1, $t1, $t1		# Loop variable
L2:
	bgt $t1, $s5, E2
	
	lb $t0, string($t1)		# Take a character
	addi $t0, $t0, -97		# Getting counter array index
	lb $t2, counter($t0)
	addi $t2, $t2, 1		# counter[string[i]-'a']++;
	sb $t2, counter($t0)
	
	addiu $t1, $t1, 1
	j L2
E2:	
	jr $ra
	
histogram:
	xor $s0, $s0, $s0		# characters
	xor $s1, $s1, $s1		# highest bar in histogram
	
	xor $t1, $t1, $t1		# Loop variable
L3:
	beq $t1, 26, E3

	lb $s2, counter($t1)		# Take a counted value
	
	beq $s2, $zero, cont2
	    addiu $s0, $s0, 1		# characters++
	cont2:
	
	ble $s2, $s1, cont3
	    addu $s1, $zero, $s2
	cont3:

	addiu $t1, $t1, 1
	j L3
E3:
	addiu $s1, $s1, 1		# 1 extra space for character in array
	
	mul $a0, $s0, $s1		# Size of the array as argument
	li $v0, 9
	syscall				# Declaring 2d array
	
	addu $s6, $zero, $v0		# Storing the 2d array in $s6

# Prining to array	
	
	xor $t5, $t5, $t5		# currentLetterIndex
	
	xor $t1, $t1, $t1		# Loop variable
L4:
	beq $t1, 26, E4
	
	lb $t0, counter($t1)
	beq $t0, $zero, cont4
	    mul $t2, $s1, $t5
	    # addiu $t2, $t2, 0		not needed really
	    addu $t2, $t2, $s6		# 2d array position
	    
	    addiu $t3, $t1, 97
	    sb $t3, 0($t2)		# arr[currentLetter][0] = i+97;
	    
	    addiu $t2, $zero, 1		# Loop variable
	L5:
	    bgt $t2, $t0, E5
	    
	    mul $t3, $s1, $t5
	    addu $t3, $t3, $t2
	    addu $t3, $t3, $s6		# Indexing 2d array
	    
	    lb $t4, star($zero)
	    sb $t4, 0($t3)		# Putting star in 2d array
	    
	    addiu $t2, $t2, 1
	    j L5
	E5: 
	    bge $t2, $s1 cont5
	    	mul $t3, $s1, $t5
	    	addu $t3, $t3, $t2
	    	addu $t3, $t3, $s6
	    	
	    	lb $t4, space($zero)
	    	sb $t4, 0($t3)
	    	
	    	addiu $t2, $t2, 1
	        j E5
	    cont5:
	    
	    addiu $t5, $t5, 1		# Increment currentLetterIndex
	cont4:
	
	addiu $t1, $t1, 1
	j L4
E4:
	
	mul $a0, $s0, $s1		# Size of the reverse array as argument
	li $v0, 9
	syscall				# Declaring reverse 2d array
	
	addu $s7, $zero, $v0		# Storing the reverse 2d array in $s7

# Printing to reverse 2d array	
	xor $t1, $t1, $t1		# Loop variable
L6:
	beq $t1, $s0, E6
	
	
	xor $t2, $t2, $t2
	L7:
		beq $t2, $s1, E7
		
		# Loading byte from 2d array
		mul $t3, $t1, $s1
		addu $t3, $t3, $t2
		addu $t3, $t3, $s6
		lb $t3, 0($t3)
		
		#storing to reverse 2d array # revArr[highest-j-1][i] = arr[i][j];
		addu $t4, $zero, $s1
		subu $t4, $t4, $t2
		addiu $t4, $t4, -1
		mul $t4, $t4, $s0
		addu $t4, $t4, $t1
		addu $t4, $t4, $s7
		
		sb $t3, 0($t4)
		
		addiu $t2, $t2, 1
		j L7
	E7:
	
	addiu $t1, $t1, 1
	j L6
E6:
	jr $ra

# Procedure for printing rectangle
RECT:
	xor $t1, $t1, $t1		# Loop variable
PL1:
	beq $t1, $s1, PE1

	xor $t2, $t2, $t2		# Loop variable
	PL2:
		beq $t2, $s0, PE2
		
		mul $t0, $s0, $t1
		addu $t0, $t0, $t2
		addu $t0, $t0, $s7
		
		lb $a0, 0($t0)
		li $v0, 11
		syscall
		
		li $v0, 4
		la $a0, space
		syscall			# Printing whitespace
		
		addiu $t2, $t2, 1
		j PL2
	PE2:
	
	li $v0, 4
	la $a0, newline
	syscall				# Printing newline

	addiu $t1, $t1, 1
	j PL1	
PE1:	
	jr $ra