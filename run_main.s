.section .rodata
    format_s:       .string " %s"
    format_idx:     .string " %hhu"



.text
    .global run_main
    .type run_main @function
    run_main:

    # make new stack frame
    pushq	%rbp		        # save the old frame pointer
	movq	%rsp, %rbp	        # create the new frame pointer
	subq	$288, %rsp	        # allocate memory for 2 strings, each in length of
                                # 127 + '\0' + 1 (pstr.len)
                                # in next nearest alignment to 16 

    # call scanf to get p1.len to %rbp-144
    leaq        -144(%rbp), %rsi          # scanf to stack (p1.len)
    movq        $format_idx, %rdi         # " %hhu"
    movq        $0, %rax
    call        scanf

    # call scanf to get p1.str to %rbp-143
    leaq        -143(%rbp), %rsi          # scanf to stack (p1.str)
    movq        $format_s, %rdi           # " %s"
    movq        $0, %rax
    call        scanf

    # call scanf to get p2.len to %rbp-288
    leaq        -288(%rbp), %rsi          # scanf to stack (p2.len)
    movq        $format_idx, %rdi         # " %hhu"
    movq        $0, %rax
    call        scanf

    # call scanf to get p2.str to %rbp-287
    leaq        -287(%rbp), %rsi          # scanf to stack (p2.str)
    movq        $format_s, %rdi           # " %s"
    movq        $0, %rax
    call        scanf

    # call scanf to get option number
    leaq        -8(%rbp), %rsi               # scanf to stack (option number)
    movq        $format_idx, %rdi            # " %hhu"
    movq        $0, %rax
    call        scanf

    movzbq      -8(%rbp), %rdi
    leaq        -144(%rbp), %rsi
    leaq        -288(%rbp), %rdx
    call        run_func

    # restore old %rbp and release stack frame
    movq    %rbp, %rsp
    pop     %rbp
    ret

    







