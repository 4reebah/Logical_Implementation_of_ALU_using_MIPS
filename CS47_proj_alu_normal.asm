.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
	
au_normal:	
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2,  8($sp)
	addi	$fp, $sp, 24
	
	li $t0, 43	# ascii for addition
	li $t1, 45	# ascii for subtraction
	li $t2, 42	# ascii for multiplication
	li $t3, 47	# ascii for division
	
	beq $a2, $t0, addition
	beq $a2, $t1, subtraction
	beq $a2, $t2, multiplication
	beq $a2, $t3, division
	
addition:
	add $v0, $a0, $a1
	j end

subtraction:
	sub $v0, $a0, $a1
	j end
	
multiplication:
	mult $a0, $a1
	mflo $v0
	mfhi $v1
	j end
division:
	div $a0, $a1
	mflo $v0
	mfhi $v1
	j end

end:
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2,  8($sp)
	addi	$sp, $sp, 24
	jr	$ra


