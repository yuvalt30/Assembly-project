.section .rodata
    format_invalid:    .string "invalid input!\n"
.text

    .global pstrlen
    .type pstrlen @function
    pstrlen:

    movzbq    (%rdi), %rax      # move pstr 1st byte to %rax
    ret

    
    .global replaceChar
    .type replaceChar @function
    replaceChar:

    movq        $0, %rcx         # i = 0
    movzbq      (%rdi), %r8      # move pstr.len to %r8
    leaq        1(%rdi), %rdi    # move to first char in pstr.str
.LOOP52:
 
    leaq        (%rdi, %rcx), %r9      # %r9 = pstr.str[i]
    cmpb        (%r9), %sil
    je          .OLDCHAR

.MIDLOOP52:
    leaq        1(%rcx), %rcx       # i++
    # pstr.len > 0, so while (i != pstr.len) therefore i < pstr.len jump to .LOOP1
    cmpq        %rcx, %r8
    jne         .LOOP52
    leaq        -1(%rdi), %rax
    ret

.OLDCHAR:
    movb        %dl,(%r9)
    jmp         .MIDLOOP52


 .global pstrijcpy
    .type pstrijcpy @function
    pstrijcpy:

    # make new stack frame
    pushq       %rbp		# save the old frame pointer
	movq        %rsp, %rbp	# create the new frame pointer
	pushq       %rdi        # save dst

    movzbq      %dl, %rdx         # make all bytes zero except LSB in %rdx (= i)
    movzbq      %cl, %rcx         # make all bytes zero except LSB in %rcx (= j)
    movzbq      (%rdi), %r8       # move dst->len to %r8
    movzbq      (%rsi), %r9       # move src->len to %r9
    leaq        1(%rdi), %rdi     # move to dst->str
    leaq        1(%rsi), %rsi     # move to src->str

    cmpb        %r8b, %cl         # if(j >= dst->len) : invalid
    jge         .INVALID53
    cmpb        %r9b, %cl         # if(j >= src->len) : invalid
    jge         .INVALID53
    
.LOOP53:     # assumption: begin with i <= j
    leaq        (%rdi, %rdx), %r10      # %r10 = dst->str + i
    leaq        (%rsi, %rdx), %r11      # %r11 = src->str + i
    movb        (%r11), %al             # temp = src->str[i]
    movb        %al, (%r10)             # dst->str[i] = temp
    leaq        1(%rdx), %rdx           # i++
    cmpb        %cl, %dl                # if i <= j : iterate   (asumption: i,j <= 127)
    jle         .LOOP53

    popq        %rax                    # restore dst as return val    

# restore old %rbp and release stack frame
    movq        %rbp, %rsp
    pop         %rbp
    ret 

.INVALID53:
    movq        $format_invalid, %rdi   # string is 1st arg
    movq        $0, %rax
    call        printf
    popq        %rax                    # restore dst as return val    
    
# restore old %rbp and release stack frame
    movq        %rbp, %rsp
    pop         %rbp
    ret 


 .global swapCase
    .type swapCase @function
    swapCase:

    movq        $0, %rcx        # i = 0
    movzbq      (%rdi), %r8     # move pstr->len to %r8
    leaq        1(%rdi), %rdi   # move to pstr->str

.LOOP54:
    leaq        (%rdi, %rcx), %r9        # %r9 = pstr->str + i
    cmpb        $65, (%r9)                # if pstr->str[i] < 'A' : continue
    jl          .CONTINUE54
    cmpb        $122, (%r9)               # if pstr->str[i] > 'z' : continue
    jg          .CONTINUE54
    cmpb        $90, (%r9)                # if 'A' <= str[i] <= 'Z' : toLower 
    jle         .TOLOWER
    cmpb        $97, (%r9)                # if 'a' <= str[i] <= 'z' : toUpper 
    jge         .TOUPPER

.CONTINUE54:
    leaq        1(%rcx), %rcx             # i++
    cmpb        %r8b, %cl                 # if i < str.len
    jl          .LOOP54
    jmp         .EXIT54

.TOUPPER:
    movb        (%r9), %al          # %al = str[i]
    addb        $-32, %al           # %al -= 32 (toUpper)
    movb        %al, (%r9)          # str[i] = %al
    jmp         .CONTINUE54

.TOLOWER:
    movb        (%r9), %al          # %al = str[i]
    addb        $32, %al            # %al += 32 (toUpper)
    movb        %al, (%r9)          # str[i] = %al
    jmp         .CONTINUE54

.EXIT54:
    leaq        -1(%rdi), %rax      # go back to pstr and as return val
    ret


 .global pstrijcmp
    .type pstrijcmp @function
    pstrijcmp:
 
    movzbq      %dl, %rdx         # make all bytes zero except LSB in %rdx (= i)
    movzbq      %cl, %rcx         # make all bytes zero except LSB in %rcx (= j)
    movzbq      (%rdi), %r8       # move p1->len to %r8
    movzbq      (%rsi), %r9       # move p2->len to %r9
    leaq        1(%rdi), %rdi     # move to p1->str
    leaq        1(%rsi), %rsi     # move to p2->str

    cmpb        %r8b, %cl         # if(j >= p1->len) : invalid
    jge         .INVALID55
    cmpb        %r9b, %cl         # if(j >= p2->len) : invalid
    jge         .INVALID55

.LOOP55:     # assumption: begin with i <= j
    leaq        (%rdi, %rdx), %r10      # %r10 = p1->str + i
    leaq        (%rsi, %rdx), %r11      # %r11 = p2->str + i
    movb        (%r10), %al             # %al = p1->str[i]
    cmpb        %al, (%r11)             # p2->str[i] ? p1->str[i]
    jl          .RET1                   # p2->str[i] < p1->str[i]
    jg          .RETMINUS1              # p2->str[i] > p1->str[i]

    leaq        1(%rdx), %rdx           # i++
    cmpb        %cl, %dl                # if i <= j : iterate   (asumption: i,j <= 127)
    jle         .LOOP55

    movq        $0, %rax
    ret 

.INVALID55:
    movq        $format_invalid, %rdi        # string is 1st arg
    movq        $0, %rax
    call        printf
    movq        $-2, %rax                    # return -2    
    ret 

.RET1:
    movq        $1, %rax
    ret 


.RETMINUS1:
    movq        $-1, %rax
    ret









# multiplication
# %rdi = x, %rsi = y

    xor     %rax,%rax

.LOOP:
    movzbq  $1,%rcx
    andq     %rdi,%rcx
    je      .ZERO
    addq    %rsi,%rax     

.ZERO:
    shl     $1,%rsi
    shr     $1,%rdi
    je      .END
    jmp     .LOOP

.END:
    ret


# merge
# rdi = arr1, rsi arr2, rdx n, rcx rslt

    leaq        (%rcx, %rdx, 4), %rdx       # rdx = rslt + n
.LOOP:
    cmpq        %rdx,%rcx
    je          .END
    movq        (%rdi), %r8                  # r8 = arr1
    compq       (%rsi), %r8
    jg         .ARR2SMALL
    movq        %r8, (%rcx)
    leaq        4(%rcx), %rcx
    leaq        4(%rdi), %rdi
    jmp         .LOOP


.ARR2SMAL:
    movq        (%rsi), %r9
    movq        %r9, (%rcx)
    leaq        4(%rcx), %rcx
    leaq        4(%rsi), %rsi
    jmp         .LOOP

.END:
    ret

