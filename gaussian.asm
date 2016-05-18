########## Data Segment ##########
	.data
matrix: .space 80800		# 100 * 101 * 8
solution: .space 800		# 100 * 8
	
filename: .space 20
	
msg1: .asciiz "Enter matrix size: "
msg2: .asciiz "Enter matrix input filename: "
msg3: .asciiz "Enter solution vector output filename: "
msg4: .asciiz "The produced solution vector should be written to the output file: "

newline: .asciiz "\n"
whitespace: .asciiz " "

########## Code Segment ##########
	.text
	.globl main
main:
	# Take matrix size input
	li $v0, 4
	la $a0, msg1
	syscall

	li $v0, 5
	syscall
	
	addu $s0, $zero, $v0				# $s0 = n
	addiu $s1, $s0, 1				# $s1 = n+1
	addiu $s2, $s0, -1				# $s2 = n-1
	
	# Taking matrix input
	xor $t1, $t1, $t1				# loop 1 var
inp1:	
	slt $t0, $t1, $s0
	beq $t0, $zero, endinp1

	xor $t2, $t2, $t2				# loop 2 var
	inp2:
		slt $t0, $t2, $s1
		beq $t0, $zero, endinp2
		
		###########	
		mul $t3, $t1, $s1
		addu $t3, $t3, $t2
		sll $t3, $t3, 3				# address of matrix[i][j]
		
		li $v0, 7
		syscall
		s.d $f0, matrix($t3)			# storing the double value
		###########
		
		addiu $t2, $t2, 1	
		j inp2
	endinp2:

	addiu $t1, $t1, 1
	j inp1
endinp1:
	
	# do procedure gaussian
	jal gaussian
	
	# do procedure solve
	jal solve
	
	# printing result
	xor $t1, $t1, $t1				# loop 1 var
out:	
	slt $t0, $t1, $s0
	beq $t0, $zero, endout
	
	##########
	sll $t2, $t1, 3
	l.d $f12, solution($t2)
	
	li $v0, 3
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	#########
	
	addiu $t1, $t1, 1
	j out
endout:
	
	# Terminate program
EXIT: 
	li $v0,10
	syscall
########## Program terminates ##########
	
# procedure: gaussian
gaussian:
	xor $t3, $t3, $t3			# var k
gauss3:
	slt $t0, $t3, $s2
	beq $t0, $zero, endgauss3
	
	addiu $t1, $t3, 1			# var i = k + 1
	gauss1:
		slt $t0, $t1, $s0
		beq $t0, $zero, endgauss1
		
		# $f4 = mat[i][k]
		mul $t4, $s1, $t1
		addu $t4, $t4, $t3
		sll $t4, $t4, 3
		l.d $f4, matrix($t4)
		
		# $s6 = mat[k][k]
		mul $t4, $s1, $t3
		addu $t4, $t4, $t3
		sll $t4, $t4, 3
		l.d $f6, matrix($t4)
		
		# $f2 = factor = mat[i][k] / mat[k][k]
		div.d $f2, $f4, $f6
		
		xor $t2, $t2, $t2				# var j
		gauss2:
			slt $t0, $t2, $s1
			beq $t0, $zero, endgauss2
			
			# $f4 = mat[i][j]
			mul $t4, $s1, $t1
			addu $t4, $t4, $t2
			sll $t4, $t4, 3
			l.d $f4, matrix($t4)
			
			# $f6 = factor * mat[k][j]
			mul $t4, $s1, $t3
			addu $t4, $t4, $t2
			sll $t4, $t4, 3
			l.d $f6, matrix($t4)
			mul.d $f6, $f2, $f6
			
			# $f4 = mat[i][j] - factor*mat[k][j];
			sub.d $f4, $f4, $f6
			
			# mat[i][j] = $f2
			mul $t4, $s1, $t1
			addu $t4, $t4, $t2
			sll $t4, $t4, 3
			s.d $f4, matrix($t4)
			
			addiu $t2, $t2, 1	
			j gauss2
		endgauss2:
		
		addiu $t1, $t1, 1	
		j gauss1
	endgauss1:
	
	addiu $t3, $t3, 1
	j gauss3
endgauss3:
	
	jr $ra

# procedure solve
solve:
	addu $t1, $zero, $s2				# loop 1 var
sol1:	
	sge $t0, $t1, $zero			# slt $t0, $t1, $zero
	beq $t0, $zero, endsol1
	
	# $f2 = mat[i][n]
	mul $t3, $s1, $t1
	addu $t3, $t3, $s0
	sll $t3, $t3, 3
	l.d $f2, matrix($t3)
	
	# solution[i] = $f2
	sll $t3, $t1, 3
	s.d $f2, solution($t3)
	
	addiu $t2, $t1, 1 				# loop 2 var
	sol2:
		slt $t0, $t2, $s0
		beq $t0, $zero, endsol2
		
		# $f4 = ans[i]
		sll $t3, $t1, 3
		l.d $f4, solution($t3)
		
		# $f6 = mat[i][j]
		mul $t3, $s1, $t1
		addu $t3, $t3, $t2
		sll $t3, $t3, 3
		l.d $f6, matrix($t3)
		
		# $f8 = ans[j]
		sll $t3, $t2, 3
		l.d $f8, solution($t3)
		
		# $f2 = sol[i]-mat[i][j]*sol[j];
		mul.d $f2, $f6, $f8
		sub.d $f2, $f4, $f2
		
		#sol[i] = $f2
		sll $t3, $t1, 3
		s.d $f2, solution($t3)
		
		addiu $t2, $t2, 1
		j sol2
	endsol2:
	
	# $f4 = ans[i]
	sll $t3, $t1, 3
	l.d $f4, solution($t3)
	
	# $f6 = mat[i][i]
	mul $t3, $s1, $t1
	addu $t3, $t3, $t1
	sll, $t3, $t3, 3
	l.d $f6, matrix($t3)
	
	# ans[i] = ans[i]/mat[i][i]
	div.d $f2, $f4, $f6
	
	sll $t3, $t1, 3
	s.d $f2, solution($t3)
	
	addiu $t1, $t1, -1
	j sol1
endsol1:

	jr $ra
