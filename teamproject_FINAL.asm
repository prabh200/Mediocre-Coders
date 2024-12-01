#
# Before running this program, enable the  "Bitmap Display" and "Keyboard and MMIO Display Simulator" tools
# 	and click "Connect to MIPS" on both tools.
#
# Configure the Bitmap Display with the following:
#
# Unit Width in Pixels: 	8
# Unit Height in Pixels: 	8
# Display Width in Pixels: 	512 
# Display Height in Pixels: 	512
# Base Address for display: 	0x10008000 ($gp)
#
####################################################
# Game Team Project
# By Team Mediocre Coders
#	Raustin Ingal, Prabhjot Gill, Hartej Aujla
# CS-118 2023
#
# - This is a game where you control a rhino character,
# 	avoiding red pixels and collecting all the green pixels to open the exit top right, which brings you to the next level
# - Two playable levels
# - When user wins, number of deaths displayed and prompted to run game again
# - User is informed about program and prompted at start of program
# - When "killed" by red enemy, level completely resets
# - Controls: wasd for movement, q to quit
# - Rhino has a 5x6 pixel "hitbox"
####################################################

### UPDATE RATE
# Change to make game run faster or slower (fast: 25-100, slow: 150-300)
# Might crash on faster speeds
.eqv	SLEEP_DURATION	66	# ms

### Bitmap Display Details
# Unit Width in Pixels: 	8
# Unit Height in Pixels: 	8
# Display Width in Pixels: 	512 
# Display Height in Pixels: 	512
# Base Address for display: 	0x10008000 ($gp)
.eqv	PIXEL_SIZE	8
.eqv	WIDTH		64	# pixels divided by pixel size
.eqv	HEIGHT		64	# pixels divided by pixel size
.eqv	BYTE_WIDTH	256	# width multiplied by 4 for addressing
.eqv	BASE		0x10008000 # gp

# set color codes
.eqv	RED	0x00FF0000	# enemy
.eqv	BLUE	0x000000FF
.eqv	L_BLUE	0x00ADD8E6	# rhino color
.eqv	GREEN	0x0000FF00	# food
.eqv	PURPLE	0x00FF00FF
.eqv	ORANGE	0x00FFA500	
.eqv	WHITE	0x00FFFFFF	# background
.eqv	BLACK	0x00000000	# border
.eqv 	GRAY	0x00808080	# exit before collecting all the food
.eqv	BROWN	0x00964B00	# walls
.eqv 	YELLOW	0x00FFBF00	# amber color for horn

# MMIO ADDRESSES
.eqv	RCR	0xFFFF0000
.eqv	RDR	0xFFFF0004
.eqv	TCR	0xFFFF0008
.eqv	TDR	0xFFFF000C

# syscalls
.eqv	EXIT		10
.eqv	OPEN_FILE	13
.eqv	READ_FILE	14
.eqv	CLOSE_FILE	16
.eqv	SLEEP		32
.eqv 	PRINT_STRING 	4
.eqv	READ_CHAR	12
.eqv	M_OUT		31
.eqv	M_OUT_SYNC	33
.eqv 	READ_STRING	8
.eqv 	PRINT_INT	1
.eqv	MESSAGE_DIALOG	55
.eqv	INPUT_DIALOG_STRING 54
.eqv	CONFIRM_DIALOG	50
.eqv	MESSAGE_DIALOG_STRING 59
.eqv	MESSAGE_DIALOG_INT 56
	
.eqv	READ		0
.eqv	INFORMATION_MESSAGE 1

# MIDI
.eqv	INSTRUMENT	33 # bass
.eqv	VOLUME		80
.eqv 	DURATION	200
# ascii
.eqv	w	119
.eqv	a	97
.eqv	s	115
.eqv 	d	100
.eqv	q	113
.eqv	NEWLINE	10	# newline
.eqv	W	87
.eqv	L	76	# B eqv doesnt work
.eqv	A	65
.eqv	R	82
.eqv	C	67
.eqv 	E	69
.eqv	G	71
.eqv	T	84

#################################################
.data	
	file_plain_ascii: .space 		5000	# enough for 65 x 64 
	
	pixel_check_array: .space 		32	# 8 addresses, but only 7 needed
	food_counter: .word			5
	deaths_counter: .space 			8
	
	level1_food: .word			5 	# 5 food on level 1
	level2_food: .word			6	# 5 food on level 2	
	
	current_level: .word			1	# current level, initialized at 1
	rhino_initial_column: .word 		2
	rhino_initial_row: .word 		55
	
	menu_filename: .asciiz			"menu_ascii.txt"
	level1_filename:			"level1_ascii.txt"
	level2_filename:			"level2_ascii.txt"
	
	### Enemy variables (all enemies have horizontal paths)
	# left_x: leftmost pixel on path (from the left)
	# right_x: rightmost pixel on path (from the left)
	# y: height (from the top)
	# position: stores address of enemy
	# direction: stores direction, initializes direction (L/R)
	
	# LEVEL 1 enemy 1
	L1_E1_left_x: .word 7
	L1_E1_right_x: .word 49
	L1_E1_y: .word 23
	L1_E1_position: .space 8
	L1_E1_direction: .byte 'R'
	#.align 2
	# LEVEL 1 enemy 2
	L1_E2_left_x: .word 7
	L1_E2_right_x: .word 45
	L1_E2_y: .word 37
	L1_E2_position: .space 8
	L1_E2_direction: .byte 'R'
	#.align 2
	# LEVEL 2 enemy 1
	L2_E1_left_x: .word 3
	L2_E1_right_x: .word 60
	L2_E1_y: .word 7
	L2_E1_position: .space 8
	L2_E1_direction: .byte 'L' 
	.align 2
	# LEVEL 2 enemy 2
	L2_E2_left_x: .word 4
	L2_E2_right_x: .word 59
	L2_E2_y: .word 23
	L2_E2_position: .space 8
	L2_E2_direction: .byte 'R' 
	.align 2
	# LEVEL 2 enemy 3
	L2_E3_left_x: .word 3
	L2_E3_right_x: .word 60
	L2_E3_y: .word 38
	L2_E3_position: .space 8
	L2_E3_direction: .byte 'L' 
	.align 2
	# LEVEL 2 enemy 4
	L2_E4_left_x: .word 3
	L2_E4_right_x: .word 48
	L2_E4_y: .word 46
	L2_E4_position: .space 8
	L2_E4_direction: .byte 'R' 
	.align 2
	
	exit_program_message: .asciiz "\nExiting program.\n"	# displayed when exiting program
	error_message: .asciiz "\nFile not found. Exiting.\n"	# displayed if file cannot be found.
	load_level_message: .asciiz "\nLoading level #"	
	greeting1: .asciiz "\nHello, What is your name?"
	greeting2: .asciiz "\nHello, "
	goodbye: .asciiz "\nThank you for trying our game! Goodbye, "
	name: .space 64
	describe_program: .asciiz "Welcome to our game made in MIPS!\nDid you know that most species of rhinos are endangered, mainly due to poachers hunting for their horns?\nIn this game, you play as a rhino and your goal is to eat shrubs (green) while avoiding poachers (red). \nYou can escape from the poachers by eating all the shrubs in the level, then going to the exit in the top right. \nThere are 2 levels to complete before you win the game.\n\nControls: (Turn off caps lock!)\n	Movement: w a s d\n	Quit game: q\n\nBefore running the program, please open the \"Bitmap Display\" and \"Keyboard and Display MMIO Simulator\" tools on MARS and \"Connect to MIPS\" on both.\nChange Bitmap Display settings to the following:\nUnit Width in Pixels: 8\nUnit Height in Pixels: 8\nDisplay Width in Pixels: 512\nDisplay Height in Pixels: 512\nBase address for display: 0x10008000 ($gp)\n\n"
	question2: .asciiz "Would you like to play our game? "
	congrats: .asciiz "\nCongratulations on your rhino escaping extinction from the poachers! \nNumber of deaths: "
	question3: .asciiz "\nDo you want to play the game again? "
#################################################
.text
#greet user and ask for name

	#greet user and ask for name
	li $v0 INPUT_DIALOG_STRING
	la $a0, greeting1
	la $a1, name
	li $a2, 63
	syscall
	
	#greeting user and name
	li $v0, MESSAGE_DIALOG_STRING 
	la $a0, greeting2
	la $a1, name
	syscall
	
	#describes program
	li $v0, MESSAGE_DIALOG    
	la $a0, describe_program
	li $a1, INFORMATION_MESSAGE
	syscall  
	
	#asks user if they want to use program
	li $v0, CONFIRM_DIALOG   
	la $a0, question2
	syscall  
	# move answer into $t1 (0 is yes)
	move $t1, $a0	

	#conditional statement
	beq $t1, $zero, drawLevel
	j Exit
	
drawLevel:

	##### WIN BRANCH IF GREATER THAN 2 LEVELS
	li $t0, 3
	lw $t1, current_level
	blt $t1, $t0, continueLevelLoad
	##### PRINT DEATHS, RESET DEATHS, SET CURRENT LEVEL TO 1 IF USER SAYS YES
	# reset current level to 1
	li $t0, 1
	sw $t0, current_level
	
	#prints congrats message w/ # of deaths
	li $v0, MESSAGE_DIALOG_INT  
	la $a0, congrats
	lw $a1, deaths_counter
	syscall  

	#asks user if they want to use program
	li $v0, CONFIRM_DIALOG   
	la $a0, question3
	syscall  
	# move answer into $t1 (0 is yes)
	move $t1, $a0	

	#conditional statement
	beq $t1, $zero, drawLevel
	j Exit
	
	continueLevelLoad:
	# output level load message
	li $v0, PRINT_STRING					# Load print string service
	la $a0, load_level_message
	syscall
	li $v0, PRINT_INT					# Load print int service
	lw $a0, current_level
	syscall

	# branch load file depending on current_level var
	lw $t0, current_level
	li $t1, 1
	beq $t0, $t1, fileLevelChoose1
	li $t1, 2
	beq $t0, $t1, fileLevelChoose2
	j Exit # error case
	
	fileLevelChoose1:
	la $a0, level1_filename
	j afterFileLevelChoose
	
	fileLevelChoose2:
	la $a0, level2_filename
	j afterFileLevelChoose
	
	afterFileLevelChoose:
	jal FileStore	# opens and reads file $a0 and stores ascii to file_plain_ascii, then closes file, changes $s0-4

	jal TranslateAndPrintAscii # translates ascii in file_plain_ascii and displays to bitmap
	
	### PLAY SOUND
	li $v0, M_OUT_SYNC
	# $a0 already set by caller
	li $a1, DURATION
	li $a2, INSTRUMENT
	li $a3, VOLUME
	syscall

	jal resetFoodCounter # resets food_counter variable

	jal resetEnemies # resets variables of each enemy depending on the current level

	jal resetRhino # reset rhino's position to bottom left
	
loop:
	###DRAW RHINO
	move $a0, $s6
	jal drawRhino # draws position of rhino using $a0 as top left position of rhino's rectangle hitbox
	
	# read keyboard input from RDR
	li $t0, RDR
	lw $s7, 0($t0)
	
	# wait $a0 ms between loops
	li $v0, SLEEP
	li $a0, SLEEP_DURATION
	syscall

	###### branch based on last user input, calculates which pixels to check and stores in pixel_check_array
	move $t2, $s6 			# $t2 has positions to check
	la $t1, pixel_check_array	# $t1 = base address of array of pixels to check
	
	# $s7 has last input from user
	beq $s7, w, checkUp
	beq $s7, a, checkLeft
	beq $s7, s, checkDown
	beq $s7, d, checkRight
	beq $s7, q, Exit	# user exits
	j afterChecks
			checkUp:
			# check base-byte_width, and the next 4 pixels to the right, stored to array
			# pixel 1
			subi $t2, $t2, BYTE_WIDTH	# pixel 1 address $t2: base-byte_width
			sw $t2, 0($t1)			# stored to 1st address in array
			# pixel 2
			addi $t2, $t2, 4		# pixel 2 address $t2: base-byte_width+4
			sw $t2, 4($t1)			# stored to 2nd address in array
			# pixel 3
			addi $t2, $t2, 4		# pixel 3 address $t2: base-byte_width+8
			sw $t2, 8($t1)			# stored to 3rd address in array
			# pixel 4
			addi $t2, $t2, 4		# pixel 4 address $t2: base-byte_width+12
			sw $t2, 12($t1)			# stored to 4th address in array
			# pixel 5
			addi $t2, $t2, 4		# pixel 5 address $t2: base-byte_width+16
			sw $t2, 16($t1)			# stored to 5th address in array
			# set loop terminator
			sw $zero, 20($t1)
		
			j performChecks
	
		checkLeft:
			# check base-4, base-4+byte_width, base-4+byte_width*2, base-4+byte_width*3, base-4+byte_width*4, base-4+byte_width*5, stored to array
			# pixel 1
			subi $t2, $t2, 4		# pixel 1 address $t2: base-4
			sw $t2, 0($t1)			# stored to 1st address in array
			# pixel 2
			addi $t2, $t2, BYTE_WIDTH	# pixel 2 address $t2: base-4+byte_width
			sw $t2, 4($t1)			# stored to 2nd address in array
			# pixel 3
			addi $t2, $t2, BYTE_WIDTH	# pixel 3 address $t2: base-4+byte_width*2
			sw $t2, 8($t1)			# stored to 3rd address in array
			# pixel 4
			addi $t2, $t2, BYTE_WIDTH	# pixel 4 address $t2: base-4+byte_width*3
			sw $t2, 12($t1)			# stored to 4th address in array
			# pixel 5
			addi $t2, $t2, BYTE_WIDTH	# pixel 5 address $t2: base-4+byte_width*4
			sw $t2, 16($t1)			# stored to 5th address in array
			# pixel 6
			addi $t2, $t2, BYTE_WIDTH	# pixel 6 address $t2: base-4+byte_width*5
			sw $t2, 20($t1)			# stored to 6th address in array
			# set loop terminator
			sw $zero, 24($t1)
			j performChecks
	
		checkDown:
			# check base+byte_width*6, and the next 4 pixels, stored to array
			# pixel 1
			li $t3, BYTE_WIDTH
			mul $t3, $t3, 6
			add $t2, $t2, $t3	# pixel 1 address $t2: base+byte_width*6
			sw $t2, 0($t1)		# stored to 1st address in array
			# pixel 2
			addi $t2, $t2, 4	# pixel 2 address $t2: base+byte_width*6+4
			sw $t2, 4($t1)		# stored to 2nd address in array
			# pixel 3
			addi $t2, $t2, 4	# pixel 3 address $t2: base+byte_width*6+8
			sw $t2, 8($t1)		# stored to 3rd address in array
			# pixel 4
			addi $t2, $t2, 4	# pixel 4 address $t2: base+byte_width*6+12
			sw $t2, 12($t1)		# stored to 4th address in array
			# pixel 5
			addi $t2, $t2, 4	# pixel 5 address $t2:base+byte_width*6+16
			sw $t2, 16($t1)		# stored to 5th address in array
			# set loop terminator
			sw $zero, 20($t1)
			j performChecks
		 
		checkRight:
			# check base+20, base+20+byte_width, base+20+byte_width*2, base+20+byte_width*3, base+20+byte_width*4, base+20+byte_width*5, stored to array
			# pixel 1
			addi $t2, $t2, 20		# pixel 1 address $t2: base+20
			sw $t2, 0($t1)			# stored to 1st address in array
			# pixel 2
			addi $t2, $t2, BYTE_WIDTH	# pixel 2 address $t2: base+20+byte_width
			sw $t2, 4($t1)			# stored to 2nd address in array
			# pixel 3
			addi $t2, $t2, BYTE_WIDTH	# pixel 3 address $t2: base+20+byte_width*2
			sw $t2, 8($t1)			# stored to 3rd address in array
			# pixel 4
			addi $t2, $t2, BYTE_WIDTH	# pixel 4 address $t2: base+20+byte_width*3
			sw $t2, 12($t1)			# stored to 4th address in array
			# pixel 5
			addi $t2, $t2, BYTE_WIDTH	# pixel 5 address $t2: base+20+byte_width*4
			sw $t2, 16($t1)			# stored to 5th address in array
			# pixel 6
			addi $t2, $t2, BYTE_WIDTH	# pixel 6 address $t2: base+20+byte_width*5
			sw $t2, 20($t1)			# stored to 6th address in array
			# set loop terminator
			sw $zero, 24($t1)
			j performChecks
	
			performChecks:
				# checks for each address in an array of pixels calculated from checkX
				# for loop until value is 0
				## CHECK FOR BROWN/BLACK WALL, RED ENEMY, FOOD GREEN
				
				la $s5, pixel_check_array	# $s5 = base address of array of pixels to check
				
				checkloop:
				lw $t1, 0($s5)			# $t1 = pixel address to check
				beq $t1, $zero, moveValid	# exit condition
				lw $t2, 0($t1)			# $t2 = color value stored in address $t1
				
				### CHECK BROWN/BLACK PIXEL COLOR WALL
				li $t3, BROWN			# $t3 = color to check
				beq $t2, $t3, afterChecks	# no moving if wall detected
				li $t3, BLACK			# $t3 = color to check
				beq $t2, $t3, afterChecks	# no moving if wall detected
				
				### CHECK FOR RED ENEMY
				li $t3, RED			# $t3 = color to check
				beq $t2, $t3, deathFromEnemy	# "kill" player
				
				### CHECK FOR FOOD
				li $t3, GREEN			# $t3 = color to check
				beq $t2, $t3, foodEaten		# decrements food counter, opens exit if food_counter=0 after
				
				### CHECK FOR EXIT
				checkExit:
				li $t3, ORANGE
				beq $t2, $t3, nextLevel
				
				# check next address in pixel_check_array
				addi $s5, $s5, 4
				j checkloop
				
				deathFromEnemy:
					######## USER DIES HERE
					# increment death counter
					lw $t0, deaths_counter
					addi $t0, $t0, 1
					sw $t0, deaths_counter
					### PLAY SOUND
						li $v0, M_OUT_SYNC
						# $a0 already set by caller
						li $a1, DURATION
						li $a2, INSTRUMENT
						li $a3, VOLUME
						syscall
					
					### RELOAD LEVEL (redraws level, rhino, resets food counter, resets enemies)
					j drawLevel
					
				foodEaten:
					# loads food_counter variable and decrements it by 1
					lw $t0, food_counter
					subi $t0, $t0, 1
					sw $t0, food_counter
					
					### PLAY SOUND
						li $v0, M_OUT_SYNC
						# $a0 already set by caller
						li $a1, DURATION
						li $a2, INSTRUMENT
						li $a3, VOLUME
						syscall
					
					beq $t0, $zero, openExit	# open exit if food_counter = 0
					
					j checkExit
				
				openExit:
					# change pixels from columns 57 to 62 and rows 1 to 6 (6x6 square top right corner)
					li $t0, ORANGE	# color to change exit to
					li $t1, BASE
					# calc top left pixel of exit in $t1
					addi $t1, $t1, 228	# column 57 (228=4*57)
					addi $t1, $t1, BYTE_WIDTH	# row 1
					move $t2, $t1 # store top left pixel of exit to $t2
					
					# draws 6x6 square over exit
					li $t3, 6   # Outer loop counter
					outerExitLoop:					
						li $t4, 6   # Inner loop counter
						innerExitLoop:
							sw $t0, 0($t2)
							addi $t2, $t2, 4
			
							# Inner loop decrement and branch
        						subi $t4, $t4, 1
							bnez $t4, innerExitLoop
			
						outerExitLoopDecrement:
							subi $t2, $t2, 24	# reset back to leftmost column
							addi $t2, $t2, BYTE_WIDTH
        						subi $t3, $t3, 1
        						bnez $t3, outerExitLoop
        				j checkExit		
				
				nextLevel:
				# Goes to next level
					# increments current_level variable by 1
					lw $t0, current_level	# value of current_level to $t0
					la $t1, current_level	# address of current_level var to $t1
					addi $t0, $t0, 1
					sw $t0, 0($t1)
				
				# generate next level
				j drawLevel
			
				# called when checks for walls/enemies passed
				moveValid:
					# $s7 has last input from user
					move $t2, $s6 			# $t2 is top left pixel of rhino
					la $t1, WHITE			# $t1 = background color
					beq $s7, w, moveUp
					beq $s7, a, moveLeft
					beq $s7, s, moveDown
					beq $s7, d, moveRight
					j Exit 
					
				moveUp:		
					# overwrite base+byte_width*5, and the next 4 pixels to the right
						# (previous bottom row of pixels)
					# pixel 1
					li $t3, BYTE_WIDTH
					mul $t3, $t3, 5
					add $t2, $t2, $t3		# pixel 1 address $t2: base+byte_width*5
					sw $t1, 0($t2)
					# pixel 2
					sw $t1, 4($t2)			# pixel 2 address $t2: base+byte_width*5+4
					# pixel 3
					sw $t1, 8($t2)			# pixel 3 address $t2: base+byte_width*5+8
					# pixel 4
					sw $t1, 12($t2)			# pixel 4 address $t2: base+byte_width*5+12
					# pixel 5
					sw $t1, 16($t2)			# pixel 5 address $t2: base+byte_width*5+16
					
					sub $s6, $s6, $s4 # go up 1 row
					j afterChecks

				moveLeft:
					# base+16, base+16+byte_width, base+16+byte_width*2, base+16+byte_width*3, base+16+byte_width*4, base+16+byte_width*5
						# (previous right row of pixels)
					# pixel 1
					addi $t2, $t2, 16		# pixel 1 address $t2: base+16
					sw $t1, 0($t2)		
					# pixel 2
					addi $t2, $t2, BYTE_WIDTH	# pixel 2 address $t2: base+16+byte_width
					sw $t1, 0($t2)		
					# pixel 3
					addi $t2, $t2, BYTE_WIDTH	# pixel 3 address $t2: base+16+byte_width*2
					sw $t1, 0($t2)		
					# pixel 4
					addi $t2, $t2, BYTE_WIDTH	# pixel 4 address $t2: base+16+byte_width*3
					sw $t1, 0($t2)		
					# pixel 5
					addi $t2, $t2, BYTE_WIDTH	# pixel 5 address $t2: base+16+byte_width*4
					sw $t1, 0($t2)		
					# pixel 6
					addi $t2, $t2, BYTE_WIDTH	# pixel 6 address $t2: base+16+byte_width*5
					sw $t1, 0($t2)		
			
					subi $s6, $s6, 4 # move 1 unit left
					j afterChecks
	
				moveDown:	
					# overwrite base, and the next 4 pixels to the right
						# (previous top row of pixels)
					# pixel 1
					sw $t1, 0($t2)
					# pixel 2
					sw $t1, 4($t2)
					# pixel 3
					sw $t1, 8($t2)
					# pixel 4
					sw $t1, 12($t2)	
					# pixel 5
					sw $t1, 16($t2)	
			
					add $s6, $s6, $s4  # add a row
					j afterChecks
	
				moveRight:
					# base, base+byte_width, base+byte_width*2, base+byte_width*3, base+byte_width*4, base+byte_width*5
						# (previous left row of pixels)
					# pixel 1	
					sw $t1, 0($t2)			# pixel 1 address $t2: base
					# pixel 2
					addi $t2, $t2, BYTE_WIDTH	# pixel 2 address $t2: base+byte_width
					sw $t1, 0($t2)		
					# pixel 3
					addi $t2, $t2, BYTE_WIDTH	# pixel 3 address $t2: base+byte_width*2
					sw $t1, 0($t2)		
					# pixel 4
					addi $t2, $t2, BYTE_WIDTH	# pixel 4 address $t2: base+byte_width*3
					sw $t1, 0($t2)		
					# pixel 5
					addi $t2, $t2, BYTE_WIDTH	# pixel 5 address $t2: base+byte_width*4
					sw $t1, 0($t2)		
					# pixel 6
					addi $t2, $t2, BYTE_WIDTH	# pixel 6 address $t2: base+16+byte_width*5
					sw $t1, 0($t2)		
				
					addi $s6, $s6, 4 # move 1 unit to right
					j afterChecks
	afterChecks:
		###### UPDATE ENEMIES
		##### branch based on level
		lw $t0, current_level	# value of current_level to $t0
		li $t1, 1
		beq $t0, $t1, updateEnemiesL1
		li $t1, 2
		beq $t0, $t1, updateEnemiesL2
		j Exit # error case
		
		updateEnemiesL1:
			#### UPDATE ENEMY 1
			# left_x, right_x, y, position, direction
			subi $sp, $sp, 4
			la $t0, L1_E1_left_x
			sw $t0, 0($sp)		
			subi $sp, $sp, 4
			la $t0, L1_E1_right_x
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L1_E1_y
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L1_E1_position
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L1_E1_direction
			sw $t0, 0($sp)
			
			jal updateEnemy
				
			addi $sp, $sp, 20	# restore stack
			
			#### UPDATE ENEMY 2
			# left_x, right_x, y, position, direction
			subi $sp, $sp, 4
			la $t0, L1_E2_left_x
			sw $t0, 0($sp)		
			subi $sp, $sp, 4
			la $t0, L1_E2_right_x
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L1_E2_y
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L1_E2_position
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L1_E2_direction
			sw $t0, 0($sp)
			
			jal updateEnemy
				
			addi $sp, $sp, 20	# restore stack
			
			j afterUpdateEnemies
	
		updateEnemiesL2:
		
			#### UPDATE ENEMY 1
			# left_x, right_x, y, position, direction
			subi $sp, $sp, 4
			la $t0, L2_E1_left_x
			sw $t0, 0($sp)		
			subi $sp, $sp, 4
			la $t0, L2_E1_right_x
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E1_y
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E1_position
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E1_direction
			sw $t0, 0($sp)
			
			jal updateEnemy
				
			addi $sp, $sp, 20	# restore stack
			
			#### UPDATE ENEMY 2
			# left_x, right_x, y, position, direction
			subi $sp, $sp, 4
			la $t0, L2_E2_left_x
			sw $t0, 0($sp)		
			subi $sp, $sp, 4
			la $t0, L2_E2_right_x
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E2_y
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E2_position
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E2_direction
			sw $t0, 0($sp)
			
			jal updateEnemy
				
			addi $sp, $sp, 20	# restore stack
			
			#### UPDATE ENEMY 3
			# left_x, right_x, y, position, direction
			subi $sp, $sp, 4
			la $t0, L2_E3_left_x
			sw $t0, 0($sp)		
			subi $sp, $sp, 4
			la $t0, L2_E3_right_x
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E3_y
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E3_position
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E3_direction
			sw $t0, 0($sp)
			
			jal updateEnemy
				
			addi $sp, $sp, 20	# restore stack
			
			#### UPDATE ENEMY 4
			# left_x, right_x, y, position, direction
			subi $sp, $sp, 4
			la $t0, L2_E4_left_x
			sw $t0, 0($sp)		
			subi $sp, $sp, 4
			la $t0, L2_E4_right_x
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E4_y
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E4_position
			sw $t0, 0($sp)
			subi $sp, $sp, 4
			la $t0, L2_E4_direction
			sw $t0, 0($sp)
			
			jal updateEnemy
				
			addi $sp, $sp, 20	# restore stack
			
			j afterUpdateEnemies
			
	afterUpdateEnemies:	
	j loop # end of loop

# Exit program
Exit:
	li $v0, MESSAGE_DIALOG_STRING     
	la $a0, goodbye
	la $a1, name
	syscall  
	
# output exit program message
	li $v0, PRINT_STRING				# Load print string service
	la $a0, exit_program_message			# Load address of exit message
	syscall
	
	li $v0, EXIT
	syscall

###################
# SUBROUTINES
###################

drawRhino:
		# $s6 = rhino's base position
		# $t0 = color
		# $t1 = current pixel address
		move $t1, $a0
		
		#### ROW 1
		li $t0, WHITE 
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, YELLOW
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		#### ROW 2
		# calc row 2 pos 1
		move $t1, $s6
		addi $t1, $t1, BYTE_WIDTH
		
		li $t0, WHITE 
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, YELLOW
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		#### ROW 3
		# calc row 3 pos 1
		move $t1, $s6
		li $t0, BYTE_WIDTH
		mul $t0, $t0, 2
		add $t1, $t1, $t0
		
		li $t0, WHITE 
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, BLACK
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		#### ROW 4
		# calc row 4 pos 1
		move $t1, $s6
		li $t0, BYTE_WIDTH
		mul $t0, $t0, 3
		add $t1, $t1, $t0
		
		li $t0, WHITE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE 
		sw $t0, 0($t1)
		
		#### ROW 5
		# calc row 5 pos 1
		move $t1, $s6
		li $t0, BYTE_WIDTH
		mul $t0, $t0, 4
		add $t1, $t1, $t0
		
		li $t0, L_BLUE 
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		#### ROW 6
		# calc row 6 pos 1
		move $t1, $s6
		li $t0, BYTE_WIDTH
		mul $t0, $t0, 5
		add $t1, $t1, $t0
		
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, L_BLUE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		addi $t1, $t1, 4
		li $t0, WHITE
		sw $t0, 0($t1)
		
		jr $ra

ErrorOpeningFile:
	li $v0, PRINT_STRING					# Load print string service
	la $a0, error_message				# Load address of error message
	syscall
	j Exit

FileStore:
# Open file
	li   $v0, OPEN_FILE       # system call for open file
	#la   $a0, menu_filename
	li   $a1, READ        # Open for reading (flags are 0: read, 1: write)
	li   $a2, 0        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	blt $v0, $zero, ErrorOpeningFile
	move $s2, $v0      # save the file descriptor 

# Read opened file
	li   $v0, READ_FILE      # system call for read file
	move $a0, $s2      	# file descriptor 
	la   $a1, file_plain_ascii
	li   $a2, 4200      	# maximum length of input
	syscall            	# read to file
	 
# Close the file 
	li   $v0, CLOSE_FILE       # system call for close file
	move $a0, $s2      # file descriptor to close
	syscall            # close file

	jr $ra
	
# translates the ascii stored in variable file_plain_ascii, and stores to bitmap
TranslateAndPrintAscii:
		
		la $s0, file_plain_ascii	# load base address of string before starting loop
		li $s1, 0 # counter
		li $s3, HEIGHT
		li $s4, BYTE_WIDTH
	TranslateWhileLoop:
		lb $a0, 0($s0)			# load character from string to $a0
		beq $a0, $zero, ReturnFromSubroutine	# exit while loop if character empty
	
	# skip translating if not valid ascii
		li $t0, W
		beq $a0, $t0, TranslateAscii
		li $t0, L
		beq $a0, $t0, TranslateAscii
		li $t0, C
		beq $a0, $t0, TranslateAscii
		li $t0, E
		beq $a0, $t0, TranslateAscii
		li $t0, R
		beq $a0, $t0, TranslateAscii
		li $t0, C
		beq $a0, $t0, TranslateAscii
		li $t0, G
		beq $a0, $t0, TranslateAscii
		li $t0, T
		beq $a0, $t0, TranslateAscii
		
		j EndTranslateWhileLoop

	TranslateAscii:	# translate current char to ascii
	
		# branch here to color change depending on char input
		lb $a0, 0($s0)			# load current character from string to $a0
		
		# save $ra to stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal asciiLookup	# $v0 = corresponding color hex for ascii char
		
		# load $ra from stack	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
	### print to display
		# calculate corresponding position in bitmap display
		li $t3, BASE
		mul $t2, $s1, 4 	# multiply counter by 4, $s1 = counter
		add $s3, $t3, $t2 #  $s3 stores current address in bitmap display
	
		move $t0, $v0
		sw $t0, 0($s3)
	
		addi $s1, $s1, 1 # increment counter

	EndTranslateWhileLoop:
	# increment to read next character in plain ascii
		addi $s0, $s0, 1
		j TranslateWhileLoop 
		
	ReturnFromSubroutine:
		jr $ra

asciiLookup:
	li $t0, W
	beq $a0, $t0, WtoWhite
	li $t0, L
	beq $a0, $t0, LtoBlack
	li $t0, C
	beq $a0, $t0, CtoBlue
	li $t0, E
	beq $a0, $t0, EtoGray
	li $t0, R
	beq $a0, $t0, RtoRed
	li $t0, G
	beq $a0, $t0, GtoGreen
	li $t0, T
	beq $a0, $t0, TtoBrown
	
	li $v0, BLACK
	j asciiLookupEnd
	
	WtoWhite:
		li $v0, WHITE
		j asciiLookupEnd
	LtoBlack:
		li $v0, BLACK
		j asciiLookupEnd
	CtoBlue:
		li $v0, BLUE
		j asciiLookupEnd
	EtoGray:
		li $v0, GRAY
		j asciiLookupEnd
	RtoRed:
		li $v0, RED
		j asciiLookupEnd
	GtoGreen:
		li $v0, GREEN
		j asciiLookupEnd
	TtoBrown:
		li $v0, BROWN
		j asciiLookupEnd
	
	asciiLookupEnd:
	jr $ra

### changes direction to R if position is at address calculated from left_x and y
### changes direction to L if position is at address calculated from right_x and y
### branches to death label (and restores stack) if rhino is not in movement path
###	else: returns from subrotuine
updateEnemy:
	### address key: address and stack
		# left_x: 16($sp)
		# right_x: 12($sp)
		# y: 8($sp)
		# position: 4($sp)
		# direction: 0($sp)
		
			### check if at left - change direction if needed
			# $t2 = address of leftmost limit
			li $t2, BASE
			lw $t7, 16($sp)
			lw $t0, 0($t7)					# t0 = left_x value
			mul $t0, $t0, 4
			lw $t7, 8($sp)
			lw $t1, 0($t7)						# t1 = y value
			mul $t1, $t1, BYTE_WIDTH
			add $t2, $t2, $t0
			add $t2, $t2, $t1
			
			# $t3 = current E1 address
			lw $t7, 4($sp)
			lw $t3, 0($t7)					# $t3 = position value
			# branch if enemy not at left
			bne $t2, $t3, check_right
			
			# change direction to 'R' (right) if at left
			lw $t4, 0($sp)				# t4 = address of direction
			li $t5, 'R'
			sb $t5, 0($t4)
			
			### check if at right - change direction if needed
			check_right:
			# $t2 = address of rightmost limit
			li $t2, BASE
			lw $t7, 12($sp)
			lw $t0, 0($t7)					# t0 = right_x value
			mul $t0, $t0, 4
			lw $t7, 8($sp)
			lw $t1, 0($t7)						# t1 = y value
			mul $t1, $t1, BYTE_WIDTH
			add $t2, $t2, $t0
			add $t2, $t2, $t1
			
			# $t3 = current E1 address
			lw $t7, 4($sp)
			lw $t3, 0($t7)					# t3 = position value
			
			# branch if enemy not at right
			bne $t2, $t3, check_rhino	
			
			# change direction to 'L' (left) if at right
			lw $t4, 0($sp)				# $t4 = direction address
			li $t5, 'L'
			sb $t5, 0($t4)
			
			### check for rhino, then branch or move
			check_rhino:
				# branch based on direction to check which direction to check for
				lw $t7, 0($sp)
				lb $t0, 0($t7)			# $t0 = direction value
				li $t1, 'L'
				beq $t0, $t1, check_rhino_L
				li $t1, 'R'
				beq $t0, $t1, check_rhino_R
				j Exit # error case
				
				check_rhino_L:
					# check for the 6 rightmost pixels of the rhino
					# $t1 = position that enemy is checking for to the left
					lw $t7, 4($sp)
					lw $t5, 0($t7)			# $t5 = position value
					subi $t1, $t5, 4
					# update position variable
					lw $t0, 4($sp)			# $t0 = position address
					sw $t1, 0($t0)
					
					# pixel 1
					move $t2, $s6			# get rhino's top left base address
					addi $t2, $t2, 16		# pixel 1 address $t2: base+16
					beq $t1, $t2, deathStackRestore
					# pixel 2
					addi $t2, $t2, BYTE_WIDTH	# pixel 2 address $t2: base+16+byte_width
					beq $t1, $t2, deathStackRestore	
					# pixel 3
					addi $t2, $t2, BYTE_WIDTH	# pixel 3 address $t2: base+16+byte_width*2
					beq $t1, $t2, deathStackRestore	
					# pixel 4
					addi $t2, $t2, BYTE_WIDTH	# pixel 4 address $t2: base+16+byte_width*3
					beq $t1, $t2, deathStackRestore	
					# pixel 5
					addi $t2, $t2, BYTE_WIDTH	# pixel 5 address $t2: base+16+byte_width*4
					beq $t1, $t2, deathStackRestore	
					# pixel 6
					addi $t2, $t2, BYTE_WIDTH	# pixel 6 address $t2: base+16+byte_width*5
					beq $t1, $t2, deathStackRestore
					j moveEnemy
				
				check_rhino_R:
					# check for the 6 leftmost pixels of the rhino
					# $t1 = position that enemy is checking for to the right
					lw $t7, 4($sp)
					lw $t5, 0($t7)			# $t5 = position value
					addi $t1, $t5, 4
					# update position variable
					lw $t0, 4($sp)			# $t0 = position address
					sw $t1, 0($t0)
					
					# pixel 1
					move $t2, $s6			# pixel 1 address $t2: base
					beq $t1, $t2, deathStackRestore
					# pixel 2
					addi $t2, $t2, BYTE_WIDTH	# pixel 2 address $t2: base+byte_width
					beq $t1, $t2, deathStackRestore
					# pixel 3
					addi $t2, $t2, BYTE_WIDTH	# pixel 3 address $t2: base+byte_width*2
					beq $t1, $t2, deathStackRestore	
					# pixel 4
					addi $t2, $t2, BYTE_WIDTH	# pixel 4 address $t2: base+byte_width*3
					beq $t1, $t2, deathStackRestore	
					# pixel 5
					addi $t2, $t2, BYTE_WIDTH	# pixel 5 address $t2: base+byte_width*4
					beq $t1, $t2, deathStackRestore	
					# pixel 6
					addi $t2, $t2, BYTE_WIDTH	# pixel 6 address $t2: base+byte_width*5
					beq $t1, $t2, deathStackRestore
					j moveEnemy
					
				deathStackRestore: # restore $sp if death
				addi $sp, $sp, 20
				j deathFromEnemy
			
				moveEnemy:					
					# position already changed from check_rhino_X
					lw $t7, 4($sp)
					lw $t0, 0($t7)			# $t0 = position value
					li $t2, RED
					sw $t2, 0($t0)	# print red pixel to new position
					
					# redraw background of old pixel (should be in $t5)
					li $t1, WHITE
					sw $t1, 0($t5)	# print white pixel to old position
					jr $ra
					
resetEnemies:
	##### branch based on level
	lw $t0, current_level	# value of current_level to $t0
	li $t1, 1
	beq $t0, $t1, resetEnemiesL1
	li $t1, 2
	beq $t0, $t1, resetEnemiesL2
	j Exit # error case
	
	resetEnemiesL1:
		### reset L1E1 position
		# calc E1 position to $t2
		li $t2, BASE
		lw $t0, L1_E1_left_x
		mul $t0, $t0, 4
		lw $t1, L1_E1_y
		mul $t1, $t1, BYTE_WIDTH
		add $t2, $t2, $t0
		add $t2, $t2, $t1
		la $t3, L1_E1_position
		sw $t2, 0($t3)
		
		### reset L1E2 position
		# calc E2 position to $t2
		li $t2, BASE
		lw $t0, L1_E2_left_x
		mul $t0, $t0, 4
		lw $t1, L1_E2_y
		mul $t1, $t1, BYTE_WIDTH
		add $t2, $t2, $t0
		add $t2, $t2, $t1
		la $t3, L1_E2_position
		sw $t2, 0($t3)
		
		j afterResetEnemies
	
	resetEnemiesL2:
		### reset L2E1 position to right_x
		# calc E1 position to $t2
		li $t2, BASE
		lw $t0, L2_E1_right_x
		mul $t0, $t0, 4
		lw $t1, L2_E1_y
		mul $t1, $t1, BYTE_WIDTH
		add $t2, $t2, $t0
		add $t2, $t2, $t1
		la $t3, L2_E1_position
		sw $t2, 0($t3)
		### reset L2E2 position to left_x
		# calc E2 position to $t2
		li $t2, BASE
		lw $t0, L2_E2_left_x
		mul $t0, $t0, 4
		lw $t1, L2_E2_y
		mul $t1, $t1, BYTE_WIDTH
		add $t2, $t2, $t0
		add $t2, $t2, $t1
		la $t3, L2_E2_position
		sw $t2, 0($t3)
		### reset L2E3 position to right_x
		# calc E3 position to $t2
		li $t2, BASE
		lw $t0, L2_E3_right_x
		mul $t0, $t0, 4
		lw $t1, L2_E3_y
		mul $t1, $t1, BYTE_WIDTH
		add $t2, $t2, $t0
		add $t2, $t2, $t1
		la $t3, L2_E3_position
		sw $t2, 0($t3)
		
		### reset L2E4 position to left_x
		# calc E4 position to $t2
		li $t2, BASE
		lw $t0, L2_E4_left_x
		mul $t0, $t0, 4
		lw $t1, L2_E4_y
		mul $t1, $t1, BYTE_WIDTH
		add $t2, $t2, $t0
		add $t2, $t2, $t1
		la $t3, L2_E4_position
		sw $t2, 0($t3)
	
		j afterResetEnemies

	afterResetEnemies:
	jr $ra
	
resetFoodCounter:
	### RESET FOOD COUNTER
	la $t2, food_counter
	
	##### branch based on level
	lw $t0, current_level	# value of current_level to $t0
	li $t1, 1
	beq $t0, $t1, resetFoodL1
	li $t1, 2
	beq $t0, $t1, resetFoodL2
	j Exit # error case
	
	resetFoodL1:
	lw $t1, level1_food
	sw $t1, 0($t2)
	j afterResetFoodCounter
	
	resetFoodL2:
	lw $t1, level2_food
	sw $t1, 0($t2)
	j afterResetFoodCounter
	
	afterResetFoodCounter:	
	jr $ra

resetRhino:
	### RESETS STARTING POSITION OF RHINO, STORED IN $s6
	li $s6, BASE
	lw $t0, rhino_initial_column
	mul $t0, $t0, 4
	lw $t1, rhino_initial_row
	mul $t1, $t1, BYTE_WIDTH
	add $s6, $s6, $t0
	add $s6, $s6, $t1
	jr $ra
