# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#


.macro extract_nth_bit($regD, $regS, $regT)
	li 	$regD, 1
	sllv	$regD, $regD, $regT
	and	$regD, $regD, $regS
	srlv	$regD, $regD, $regT
	.end_macro
	
.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	li 	$maskReg, 1
	sllv 	$maskReg, $maskReg, $regS
	not 	$maskReg, $maskReg
	
	and 	$regD, $regD, $maskReg
	
	sllv	$regT, $regT, $regS
	
	or 	$regD, $regD, $regT
	.end_macro


