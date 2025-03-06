#
#	Name:	Beauchamp, Joshua
#	Project:	4
#	Due:	04-26-24
#	Course:	cs-2640-02-sp24
#
#	Description:
#		The program utilizes a linked list to store all the element names on the
#		periodic table. It will read in the names through a text file, and add the
#		most recently read name to the head of the linked list. Once all names are 
#		read in, the program recursively traverses through the list, outputting the
#		length of each element name along with the name itself. The program also
#		outputs the total amount of elements read into the linked list from the file.

	.data
ptfname:	.asciiz	"enames.dat"
title:	.asciiz	"Elements by J. Beauchamp v0.1"
total:	.asciiz	" elements"
colon:	.asciiz	":"
input:	.space	80	# The buffer for readint the file
head:	.word	0	# The head of the linked list
	.text
main:
	la	$a0, title
	li	$v0,4
	syscall

	jal	printnl
	jal	printnl

	addiu	$sp, $sp, -8
	sw	$s0, 4($sp)	# s0:file descriptor (fd)
	sw 	$ra, 0($sp)

	la 	$a0, ptfname	# $a0 = filename
	li	$a1, 0		# $a1 = read only
	jal	open		# s0 = fopen(ptfname) for reading
	beq	$v0, -1, nofile	# If there is no file, end
	move	$s0, $v0

	# Counter for total amount of elements read
	li	$t2, 0

	# While a line can be read from the file
while:	move 	$a0, $s0
	la 	$a1, input
	jal 	fgetln		# Gets the current line in the data file
	blez	$v0, endw

	# Increment counter
	add	$t2, $t2, 1

	# Duplicate the string in memory and return the address
	la	$a0, input
	jal	cstrdup

	# Moves the string address into $a0 as procedure for getnode
	# Load the head of the linked list as $a1 for the second parameter
	move	$a0, $v0
	lw	$a1, head
	jal	getnode

	# head = the newly made node
	sw	$v0, head

	b 	while
endw:	move	$a0, $s0
	jal	close		# close file

nofile:
	# Prints out the total amount of elements
	move	$a0, $t2
	li	$v0, 1
	syscall
	la	$a0, total
	li	$v0, 4
	syscall

	jal	printnl
	jal	printnl

	# Output the entered elements
	lw	$a0, head
	la	$a1, print
	jal	traverse

	# Clear the stack
	lw	$s0, 4($sp)
	lw 	$ra, 0($sp)
	addiu	$sp, $sp, 8

	# Exits the program
	jal	printnl
	li	$v0, 10
	syscall

# End of main


# ------------------
#  GETNODE PROCEDURE
# ------------------
# Procedure that returns an address to a new node
# that is initialized with data and next
# Assume $a0 is the string
# Assume $a1 is the list
getnode:
	# Save original string and return address onto stack
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)
	addiu	$sp, $sp, -4
	sw	$a0, ($sp)

	# Allocate 8 bytes of memory for node
	li	$a0, 8
	jal	malloc
	lw	$a0, ($sp)	# Load string back into $a0 
	addiu	$sp, $sp, 4

	# Store the string address in the first 4 bytes and the 
	# address of the next node in the last four bytes of the 
	# newly allocated node in the heap
	sw	$a0, 0($v0)
	sw	$a1, 4($v0)

	# Return back to call address
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4

	jr	$ra

# End of getnode procedure


# -------------------
#  TRAVERSE PROCEDURE
# -------------------
# Procedure that traverses the list and recursively calls itself,
# passing the data of the node visited and traverses from last node to 
# first node
# Assume $a0 is the head
# Assume $a1 is the print procedure
traverse:
	# Stores $a0, and $ra onto stack
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)
	addiu	$sp, $sp, -4
	sw	$a0, ($sp)

	# If node is empty, end the traversal
	beqz	$a0, endif

	# Loads the next portion of the current node as
	# the parameter for the next recursive traversal
	lw	$a0, 4($a0)	# Load the next node portion as parameter
	jal	traverse		# Recursive call to itself
	lw	$a0, 0($sp)	# Loads current node into $a0

	# Loads the string address of node and outputs it
	lw	$a0, 0($a0)
	jalr	$a1
endif:
	lw	$ra, 4($sp)
	addiu	$sp, $sp, 8

	jr	$ra

# End of traverse procedure


# ----------------
#  PRINT PROCEDURE
# ----------------
# Outputs the string length and the string og the node
# Assume $a0 is the string
print:
	# Stores element string onto stack for outputting later
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)
	addiu	$sp, $sp, -4
	sw	$a0, ($sp)

	# Outputs the length of the element string
	jal	cstrlen
	move	$a0, $v0
	li	$v0, 1
	syscall

	# Outputs colon symbol to separate string and length
	la	$a0, colon
	li	$v0, 4
	syscall

	# Pops $a0 out of the stack and outputs the original string
	lw	$a0, ($sp)
	addiu	$sp, $sp, 4
	li	$v0, 4
	syscall

	# Pop the return address and restore the stack
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4

	jr	$ra

# End of print procedure


# -----------------
# CSTRLEN PROCEDURE
# -----------------
# Start of string length procedure
# Assume $a0 stores the string
# Returning the length counting everything, but the /0 character 
cstrlen:

	li	$v0, 0	# The length of the string
whilelen:
	lb	$t4, 0($a0)	# loads the string into $t4
	beqz	$t4, endwhilelen	# checks for zero byte character
	addi	$v0, $v0, 1	# increments the counter
	addiu	$a0, $a0, 1	# increments address to next character

	b	whilelen
endwhilelen:

	jr	$ra
# End of string length procedure


# -----------------
# CSTRDUP PROCEDURE
# -----------------
# Start of duplication procedure
# Assume $a0 is the string
# Returning the address of the duplicated string in $v0
cstrdup:

	# Pushes the return address onto stack to return back to main
	# without losing its value to other called procedures
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)

	# Pushes the string onto stack to save its original value
	addiu	$sp, $sp, -4
	sw	$a0, 0($sp)
	
	# Calls strlen to get the length of the string and its size in memory
	jal	cstrlen
	addi	$a0, $v0, 1	# Adds 1 to length to account for "/0" character

	# Calls malloc to get the address of the string duplication in memory
	jal	malloc

	# Pops the string out of the stack to start duplication it in the memory location
	lw	$a0, 0($sp)
	addiu	$sp, $sp, 4

	move	$t6, $a0		# The source string that the user inputted
	move	$t7, $v0		# The memory location pointer from malloc

cstrdupLoop:
	lb	$t5, ($t6)	# Loads current character of string into $t5
	sb	$t5, ($t7)	# Stores current charcter of string from $t5 in memory
	beqz	$t5, cstrdupEnd	# If the current character is the null terminator, end loop
	addi	$t7, $t7, 1	# Increment to the next character in the string
	addi	$t6, $t6, 1	# Increment to the next byte in memory
	b cstrdupLoop		# Loops back to beginning of duplication loop
cstrdupEnd:

	# Pops the original return address out of stack to return to main
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4

	jr	$ra
# End of duplication procedure


# -----------------
# MALLOC PROCEDURE
# -----------------
# Start of memory allocation procedure
# Assume that $a0 stores the size of the string
# Returning the address of the beginning block of the string in memory in $v0
malloc:

	# Pushes the length of the string onto stack to save its original value
	addiu	$sp, $sp, -4
	sw	$a0, 0($sp)

	# Ensures that the number of bytes is a multiple of 4
	addi	$a0, $a0, 3
	srl	$a0, $a0, 2
	sll	$a0, $a0, 2

	# Creates the memory allocation with the amount of bytes, which is $a0,
	# and returns the address of this block of memory in $v0
	li	$v0, 9
	syscall

	# Pops the original length of the string of out of memory so that it can be used in cstrdup
	lw	$a0, 0($sp)
	addiu	$sp, $sp, 4

	jr	$ra
# End of memory allocation procedure


# -----------------
# PRINTNL PROCEDURE
# -----------------

	# Procedure that prints a newline character
printnl:	
	li	$a0, '\n'
	li	$v0, 11
	syscall

	jr	$ra

# End of print new line procedure
