
# cpp.cos.cs.2640.tvnguyen7
#  fileio.s - file i/o library

# void fgetln (int fd, cstring buf) - get a line of text from a file into buf, full path
#	*no* buffer overflow check
#	(\n included, null terminated)
# parameters
# 	a0: fd (file descriptor)
#	a1: buf
# return:
#	v0: number of characters read, -1->error, 0->eof
#
	.globl	fgetln
fgetln:	move	$t0, $a1		# save a1
	li	$a2, 1		# 1 byte at a time
__do:	li	$v0, 14
	syscall
	blez	$v0, __eof		# eof or error
	lb 	$t1, ($a1)
	addiu 	$a1, $a1, 1
	bne 	$t1, '\n', __do
__eof:	sub 	$v0, $a1, $t0	# number of characters read
	beqz	$v0, __endif
	sb 	$zero, ($a1)	# null byte
__endif:	move	$a1, $t0		# restore a1
	jr	$ra

# int fd = open(cstring filename, int mode)
#
# parameter:
# 	a0: file name
#	a1: 0->rdonly, 1->wronly, 2->rdwr
# return:
# 	v0: fd (file descriptor),  -1 if error
#
	.globl	open
open:	li	$v0, 13
	syscall
	jr	$ra

# void fclose(int fd) - close file
#
# parameter:
# 	a0: fd
#
	.globl	close
close:
	li 	$v0, 16
	syscall
	jr	$ra
