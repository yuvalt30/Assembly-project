.section .rodata
    format_c:       .string " %c"
    format_idx:     .string " %hhu"
    format0:        .string "first pstring length: %d, second pstring length: %d\n"
    format2:        .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
    format3_4:      .string "length: %d, string: %s\n"
    format5:        .string "compare result: %d\n"
    format_invalid: .string "invalid option!\n"

    .align 8 # Align address to multiple of 8
.L10:
    
    .quad .L0 # Case opt: 50 : pstrlen of 2 pstr
    .quad .L7 # Case opt: 51 : invalid input
    .quad .L2 # Case opt: 52 :  
    .quad .L3 # Case opt: 53 :
    .quad .L4 # Case opt: 54 :
    .quad .L5 # Case opt: 55 :
    .quad .L7 # Case opt: 56 : invalid input
    .quad .L7 # Case opt: 57 : invalid input
    .quad .L7 # Case opt: 58 : invalid input
    .quad .L7 # Case opt: 59 : invalid input
    .quad .L0 # Case opt: 60 : pstrlen of 2 pstr

.text
    .global run_func
    .type run_func @function
    run_func:
    
    # Set up the jump table access
    leaq    -50(%rdi),%rcx      # Compute xi = x-50
    cmpq    $10,%rcx            # Compare xi:10
    ja      .L7                 # goto default-case if invalid input  (opt > 60 or opt < 50 (unsigned))
    jmp     *.L10(,%rcx,8)      # Goto jump-table[xi]


# Case 50 or 60
.L0: # print pstrlen of 2 pstrs
     # call pstrlen for p1.len
    pushq	%rbp		   # save the old frame pointer
    movq    %rsi, %rdi     # p1 is 1st argument
    pushq   %rdx           # save p2
    call    pstrlen

    # call pstrlen for p2.len
    pop     %rdi           # restore p2 to 1st arg
    pushq   %rax           # save p1.len
    call    pstrlen

    # call printf
    movq    %rax, %rdx     # p2.len in 3rd argument
    popq    %rsi           # p1.len in 2nd argument
    movq    $format0, %rdi # print format is 1st argument
    movq	$0, %rax
    call printf

    popq	%rbp		# restore old frame pointer
    ret

.L2: # replaceChar in the 2 pstrs
    # make new stack frame
    pushq	%rbp		# save the old frame pointer
	movq	%rsp, %rbp	# create the new frame pointer
	subq	$16, %rsp	# allocate memory in stack for 2 args
    movq    $0, -16(%rbp)
    movq    $0, -8(%rbp)

    # save p1, p2
    pushq    %rsi      # save p1
    pushq    %rdx      # save p2

    # call scanf to get oldCAhr
    leaq    -8(%rbp), %rsi      # scanf to stack (oldChar)
    movq    $format_c, %rdi     # " %c"
    movq	$0, %rax
    call    scanf

    # call scanf to get newCAhr
    leaq    -16(%rbp), %rsi     # scanf to stack (newChar)
    movq    $format_c, %rdi     # " %c"
    movq	$0, %rax
    call    scanf

    # call replaceChar for p1
    movq    -16(%rbp), %rdx       # move newChar to 3rd arg
    movq    -8(%rbp), %rsi        # move oldChar to 2nd arg
    movq    -24(%rbp), %rdi       # move p1 to 1st arg
    call    replaceChar
    pushq   %rax                  # save modified p1

    # call replaceChar for p2
    movq    -16(%rbp), %rdx       # move newChar to 3rd arg
    movq    -8(%rbp), %rsi        # move oldChar to 2nd arg
    movq    -32(%rbp), %rdi       # move p2 to 1st arg
    call    replaceChar
    pushq   %rax                  # save modified p2

    # call printf
    movq    $format2, %rdi        # move format to 1st arg
    movq    -16(%rbp), %rdx       # move newChar to 3rd arg
    movq    -8(%rbp), %rsi        # move oldChar to 2nd arg
    movq    -40(%rbp), %rcx       # move modified p1's address to 4th arg
    movq    -48(%rbp), %r8        # move modified p2's address to 5th arg
    leaq    1(%rcx), %rcx         # jump over pstr's first byte
    leaq    1(%r8), %r8           # jump over pstr's first byte
    movq    $0, %rax
    call    printf

    # restore old %rbp and release stack frame
    movq    %rbp, %rsp
    pop     %rbp
    ret 


.L3:    # pstrijcpy
    # make new stack frame
    pushq	%rbp		# save the old frame pointer
	movq	%rsp, %rbp	# create the new frame pointer
	subq	$16, %rsp	# allocate memory in stack for 2 args

   # save p1, p2
    pushq    %rsi      # save p1 to %rbp-24
    pushq    %rdx      # save p2 to %rbp-32

    # call scanf to get i to %rbp-8
    leaq    -8(%rbp), %rsi # scanf to stack (i)
    movq    $format_idx, %rdi # " %d"
    movq	$0, %rax
    call    scanf

    # call scanf to get j to %rbp-16

    leaq    -16(%rbp), %rsi # scanf to stack (j)
    movq    $format_idx, %rdi # " %d"
    movq	$0, %rax
    call    scanf

    # call pstrijcpy
    movq    -24(%rbp), %rdi    # p1 1st arg
    movq    -32(%rbp), %rsi    # p2 2nd arg
    movb    -16(%rbp), %cl     # j 4th arg
    movb    -8(%rbp), %dl      # i 3rd arg
    call    pstrijcpy

    # call prinrtf for modified p1
    movzbq  (%rax), %rsi       # move p1.len (p1's 1st byte) to 2nd arg
    leaq    1(%rax), %rdx      # move modified p1->str (dst) to 3rd arg (jump over it's 1st byte)
    movq    $format3_4, %rdi   # move print format 1st arg
    movq    $0, %rax
    call    printf

    # call printf for p2
    movq    -32(%rbp), %rdx      # move p2 to 3rd arg
    movzbq  (%rdx), %rsi         # move p2.len (p2's 1st byte) to 2nd arg
    leaq    1(%rdx), %rdx        # jump over p2's 1st byte
    movq    $format3_4, %rdi     # move print format 1st arg
    movq    $0, %rax
    call    printf

    # restore old %rbp and release stack frame
    movq    %rbp, %rsp
    pop     %rbp
    ret 


.L4:    # swapcase in 2 pstrs
    # make new stack frame
    pushq	%rbp		# save the old frame pointer
	movq	%rsp, %rbp	# create the new frame pointer

    # call swapcase p1
    movq    %rsi, %rdi      # p1 1st arg
    pushq   %rdx            # save p2
    call    swapCase

    # call swapcase p2
    popq    %rdi            # restore p2 to 1st arg
    pushq   %rax            # save modified p1
    call    swapCase

    # call printf for p1
    movq    $format3_4, %rdi    # print format 1st arg
    popq    %rdx                # restore modified p1 to 3rd arg
    movzbq  (%rdx), %rsi        # move p1.len (p1's 1st byte) to 2nd arg
    leaq    1(%rdx), %rdx       # jump over p1.len
    pushq   %rax                # save modified p2
    movq    $0, %rax
    call printf

    # call printf for p2
    movq    $format3_4, %rdi    # print format 1st arg
    popq    %rdx                # restore modified p2 to 3rd arg
    movzbq  (%rdx), %rsi        # move p2.len (p1's 1st byte) to 2nd arg
    leaq    1(%rdx), %rdx       # jump over p1.len
    movq    $0, %rax
    call printf

    # restore old %rbp and release stack frame
    movq    %rbp, %rsp
    pop     %rbp
    ret 


.L5: # pstrijcmp
    # make new stack frame
    pushq	%rbp		# save the old frame pointer
	movq	%rsp, %rbp	# create the new frame pointer
	subq	$16, %rsp	# allocate memory in stack for 2 args

   # save p1, p2
    pushq    %rsi      # save p1 to %rbp-24
    pushq    %rdx      # save p2 to %rbp-32

    # call scanf to get i to %rbp-8
    leaq    -8(%rbp), %rsi # scanf to stack (i)
    movq    $format_idx, %rdi # " %d"
    movq	$0, %rax
    call    scanf

    # call scanf to get j to %rbp-16

    leaq    -16(%rbp), %rsi # scanf to stack (j)
    movq    $format_idx, %rdi # " %d"
    movq	$0, %rax
    call    scanf

    # call pstrijcmp
    movq    -24(%rbp), %rdi    # p1 1st arg
    movq    -32(%rbp), %rsi    # p2 2nd arg
    movb    -16(%rbp), %cl     # j 4th arg
    movb    -8(%rbp), %dl      # i 3rd arg
    call    pstrijcmp


    # call prinrtf for result
    movq    $format5, %rdi   # move print format 1st arg
    movq    %rax, %rsi
    movq    $0, %rax
    call    printf

    # restore old %rbp and release stack frame
    movq    %rbp, %rsp
    pop     %rbp
    ret 






.L7:
    movq    $format_invalid, %rdi   # string is 1st arg
    movq	$0, %rax
    call printf
    ret
