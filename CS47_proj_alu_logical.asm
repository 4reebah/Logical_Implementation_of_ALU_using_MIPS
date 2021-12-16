.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
 au_logical:
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2,  8($sp)
	addi	$fp, $sp, 24
	
	beq	$a2, '+', add_logical 
	beq	$a2, '-', sub_logical
	beq	$a2, '*', mul_signed
	beq	$a2, '/', div_signed
	
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2,  8($sp)
	addi	$sp, $sp, 24
	jr 	$ra

 add_logical:	
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2,  8($sp)
	addi	$fp, $sp, 24
	
	li 	$a2, 0x00000000		# set $a2 to 0x00000000
	jal 	add_sub_logical
	
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2,  8($sp)
	addi	$sp, $sp, 24
	jr $ra

 sub_logical:		
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2,  8($sp)
	addi	$fp, $sp, 24
	
	li 	$a2, 0xFFFFFFFF		# set $a2 to 0xFFFFFFFF	
	not	$a1, $a1		# invert a1	
	
	jal 	add_sub_logical
 	
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2,  8($sp)
	addi	$sp, $sp, 24
	jr $ra

 add_sub_logical:
	addi	$sp, $sp, -32
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$a2,  16($sp)
	sw	$s0,  12($sp)
	sw	$s1,  8($sp)
	addi	$fp, $sp, 32
	
	add	$s0, $zero, $zero	# index = 0
	add 	$s1, $zero, $zero	# S = 0
		 
	extract_nth_bit($t0, $a2, $s0)		# calling macro for $a2
	
	loop:
		beq	$s0, 32, add_sub_logical_end
	 	extract_nth_bit($t1, $a0, $s0)		# extracting n bit for $a0 (A)
		extract_nth_bit($t2, $a1, $s0)		# extracting n bit for $a1 (B)
		
		xor 	$t3, $t1, $t2			# xor of A and B
		xor	$t4, $t0, $t3			# xor (A and B) and CI --> Y value
		
		and 	$t5, $t1, $t2			# and of A and B
		and 	$t6, $t0, $t3			# and of (A and B) and CI
		or 	$t0, $t5, $t6			# or of (A and B) + CI --> CO value 
		
		
		insert_to_nth_bit($s1, $s0, $t4, $t7)	# insert Y bit into S
		
		addi	$s0, $s0, 1			# i++
		j loop
		
 add_sub_logical_end:  
	move 	$v0, $s1
	move 	$v1, $t0 
	 	 
	lw	$fp, 32($sp)
	lw	$ra, 28($sp)
	lw	$a0, 24($sp)
	lw	$a1, 20($sp)
	lw	$a2,  16($sp)
	lw	$s0,  12($sp)
	lw	$s1,  8($sp)
	addi	$sp, $sp, 32
	jr 	$ra

twos_complement: 
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	not	$a0, $a0
	li	$a1, 1
	jal	add_logical	

	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra

 twos_complement_if_neg:
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)	
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	li 	$t0,  31
	move 	$t2,  $a0
	extract_nth_bit($t1, $t2, $t0) 	
	
	beqz 	$t1,  postive_value	# if MSB is 0, go to twos complement
	jal 	twos_complement		# else, go to postive_value
	j 	twos_complement_if_neg_end
	
	postive_value:
		move 	$v0,  $a0
	
 twos_complement_if_neg_end:
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
	

twos_complement_64_bit:
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 28

	not 	$a0, $a0	# invert $a0
	not	$a1, $a1	# invert $a1
	move	$s0, $a1 	# move contents of a1 into s0
	
	li 	$a1, 1
	jal	add_logical
	
	lo_add:
		move 	$s1, $v0	#save low value 
		move 	$a0, $v1
		move 	$a1, $s0
		jal	add_logical
	hi_add:
		move	$v1, $v0
		move 	$v0, $s1

	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 28
	jr 	$ra
 
 bit_replicator:
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)	
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	beq 	$a0,  0x0, load_zeros
	li 	$v0,  0xFFFFFFFF
	j 	bit_replicator_end	

	load_zeros:
		li 	$v0,  0x00000000
 bit_replicator_end:				
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra

 mul_unsigned:
	addi	$sp, $sp, -44
	sw	$fp, 44($sp)
	sw	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 44
	
	li 	$s0,  0 	# I = 0
	li 	$s1,  0		# H = 0
	move	$s2,  $a0 	# L = multiplier
	move 	$s3,  $a1 	# M = multiplicand
	
	li	$s0, 0		# index = 0
	li	$s1, 0		# hi = 0
	move	$s2, $a0	# L = multiplier
	move	$s3, $a1 	# M = multiplicand
	
	mul_unsigned_loop: 
		beq 	$s0, 32, mul_unsigned_end
		
		extract_nth_bit($t0, $s2, $zero)
		move	$a0, $t0

		jal 	bit_replicator
		move	$s4, $v0
		
		and	$s5, $s3, $s4
		
		move 	$a0, $s1
		move 	$a1, $s5
		jal 	add_logical
		
		move 	$s1, $v0 	# s1 = v0
		
		srl $s2, $s2, 1		# right shift R
		
		extract_nth_bit($t1, $s1, $zero)
		
		li $t2, 31
		insert_to_nth_bit($s2, $t2, $t1, $t3)	# L[31] = H[0]
		
		
		srl	$s1, $s1, 1
		addi 	$s0, $s0, 1
	j mul_unsigned_loop

 mul_unsigned_end: 
	move 	$v0, $s2
	move 	$v1, $s1

	lw	$fp, 44($sp)
	lw	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra

 mul_signed:
 	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 36
 
 	move	$s0, $a0	# N1 = s0
	move	$s1, $a1	# N2 = s2

	# saving N1 and N2 for determining the sign at the end
	move	$s2, $a0
	move	$s3, $a1
	
	# twos_complement for N1 and N2
	jal	twos_complement_if_neg
	move	$s0, $v0
	move	$a0, $s1
	jal	twos_complement_if_neg	
	move	$s1, $v0
	
	
	# mul_unsigned on N1 and N2
	move	$a0, $s0
	move	$a1, $s1
	jal	mul_unsigned
	move	$a0, $v0	# Rlo
	move	$a1, $v1	# Rhi
	
	li	$t0, 31
	extract_nth_bit($t1, $s2, $t0)	# a0[31]
	extract_nth_bit($t2, $s3, $t0)	# a1[31]
	
	xor	$t3, $t1, $t2		# xor of a0 and a1
	
	bne	$t3, 1, mul_signed_end
	jal	twos_complement_64_bit
 	
 mul_signed_end:
 	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)	
	lw 	$s3, 8($sp)
	addi	$sp, $sp, 36
	jr 	$ra
 	
	
 div_unsigned:
	addi	$sp, $sp, -40
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)	
	sw 	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 40
	
	li 	$s0, 0	# index = 0
	li	$s1, 0	# quotient = 0
	li 	$s2, 0	# remainder = 0 
	
	move 	$s3, $a1	# D = a3
	jal	twos_complement_if_neg
	move	$s4, $v0	# Q = s4
	move	$a0, $s3	
	jal	twos_complement_if_neg
	move	$s3, $v0	# absolute value of a1 stored into s3
	
	move	$s1, $s4	# Quotient = DVDND
	
	div_unsigned_loop:
		beq	$s0, 32, div_unsigned_end
		sll	$s2, $s2, 1				# left-shift remainder by 1
		
		li 	$t0, 31
		move	$t1, $s1				# temp var for DVDND
		extract_nth_bit($t2, $t1, $t0)			# extract MSB of DVDND
		insert_to_nth_bit($s2, $zero, $t2, $t3) 	# Set MSB of a0 into LSB of s1
		
		sll	$s1, $s1, 1				# left shift DVDND by 1
		
		# subtraction 
		move	$a0, $s2	# move remainder of a0 into a3
		move 	$a1, $s3	# contents of s1 (R) into a3
		jal	sub_logical 	# S = a0 - a1 = s1 - a1
		move 	$t3, $v0	# save result (S = R - D)
		
		bltz   	$t3, jump_add	# if 1, then jump_add
		
		move	$s2, $t3
		li	$t2, 1
		insert_to_nth_bit($s1, $zero, $t2, $t4)
		
		jump_add:	
		
		addi	$s0, $s0, 1	# i++
		j	div_unsigned_loop
		   
 div_unsigned_end:
	move $v0, $s1
	move $v1, $s2

	lw	$fp, 40($sp)
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)	
	lw 	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 40
	jr 	$ra

 div_signed:
 	addi	$sp, $sp, -40
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)	
	sw 	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 40
 	move	$t0, $a0
 	move 	$t1, $a1
 	li	$t2, 31
 	
 	extract_nth_bit($s0, $t0, $t2)
 	extract_nth_bit($s1, $t1, $t2)
 	
 	xor	$s2, $s0, $s1
 	jal	div_unsigned
 	
 	move	$s3, $v0
 	move	$s4, $v1
 	
 	beqz	$s2, inv_remainder
 	move	$a0, $s3
 	jal	twos_complement 
 	move	$s3, $v0
 	
 	inv_remainder:
 		beqz	$s0, div_signed_end
 		move 	$a0, $s4
 		jal	twos_complement
 		move 	$s4, $v0
 div_signed_end:
 	move	$v0, $s3
 	move	$v1, $s4
 	
 	lw	$fp, 40($sp)
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)	
	lw 	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 40
	jr 	$ra
 	
 		
