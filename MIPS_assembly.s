		.data
		NNUMBERS: .word 50
		CONTROL: .word32 0x10000
		DATA:    .word32 0x10008
		printf1: .asciiz "The first fibonacci numbers:\n"
		printf2: .asciiz "Sum of products of adjacent numbers: "
		
		.text
		lwu r21,CONTROL(r0)
		lwu r22,DATA(r0)
						
main:		ld      r30,NNUMBERS(r0) ;r30=NNUMBERS
        	jal     fib         ;Jump to fibonnaci()
		
return:		daddi  r24,r0,4     ; ascii output
		daddi  r25,r0,printf1   
		sd     r25,(r22)     
		sd     r24,(r21)    ;"The first fibonacci numbers:\n"
		
		daddi   r14,r0,256 ;r14=256 pointer to fibonacci[i]
		daddi   r24,r0,1    ;r24=1 unsigned integer output
		daddu   r26,r0,r0   ;r26 counter for print fibonnaci

loop3:		ld      r15,0(r14) ;r15=fib[i]
 		sd      r15,(r22)  ;data=fib[i]
		sd      r24,(r21)  ;Print fib[i] unsigned integer
                ld      r17,8(r14)
 		sd      r17,(r22)  ;data=fib[i]
		sd      r24,(r21)  ;Print fib[i] unsigned integer
                ld      r18,16(r14)
 		sd      r18,(r22)  ;data=fib[i]
		sd      r24,(r21)  ;Print fib[i] unsigned integer
                ld      r19,24(r14)
		sd      r19,(r22)  ;data=fib[i]
		sd      r24,(r21)  ;Print fib[i] unsigned integer
                ld      r20,32(r14) 
		sd      r20,(r22)  ;data=fib[i]
		;sd      r24,(r21)  ;Print fib[i] unsigned integer       		
		daddi   r26,r26,5  ;counter+=5
		slt     r16,r26,r30;if counter<NNUMBERS set r5
		sd      r24,(r21)  ;Print fib[i] unsigned integer     	
		bne     r16,r0,loop3	
		daddi   r14,r14,40  ;r14=r14+8


		daddi  r6,r0,256   ;r6=100hex Pointer to fib[i]
		daddi  r7,r0,264   ;r7=108hex Pointer to fib[i+1]
		daddu  r12,r0,r0   ;reset r12 ;counter
		mtc1   r0,f0       ;set f0=0 
		add.d  f6,f0,f0    ;reset f6 ;accumulator
		dsra   r28,r30,1   ;r28=r30/2 	
				
loop2:		ld      r8,0(r6)   ;r8=fib[i]
		ld      r9,0(r7)   ;r9=fib[i+1]
		mtc1    r8,f1      ;move to float register
		mtc1    r9,f2      ;move to float register
		cvt.d.l f3,f1      ;Convert to float
		cvt.d.l f4,f2      ;Convert to float
	   
		mul.d  f5,f4,f3    ;fib[i]*fib[i+1]
		;add.d  f6,f6,f5    ;sum=sum+fib[i]*fib[i+1]
		daddi  r12,r12,1   ;counter++
		slt    r13,r12,r28 ;if r12<NNUMBERS/2 set r13
		daddi  r6,r6,16    ;*fib[i]+=16
		daddi  r7,r7,16    ;*fib[i+1]+=16
		

		bne    r13,r0,loop2;branch if r13!=0
		add.d  f6,f6,f5    ;sum=sum+fib[i]*fib[i+1]
		
		daddi  r24,r0,4     ; ascii output
		daddi  r25,r0,printf2  
		sd     r25,(r22)
		sd     r24,(r21)

		daddi  r24,r0,3    ;Control=floating point output
		s.d    f6,(r22)    ;data=sum
		sd     r24,(r21)   ;Print sum as float

		halt


fib:		daddu  r3,r0,r0    ;r3=0   ;r3 is used to pass values to mem[r4]
		daddi  r4,r0,256   ;r4=100hex ;position of fib[0] 
		sd     r3,0(r4)    ;MEM[100(hex)]= 0
		daddi  r3,r3,1     ;r3=1 
		daddi  r4,r4,8     ;r4=108hex 
		sd     r3,0(r4)    ;MEM[108(hex)]=1
	        beq    r30,r3,return ;return if NNUMBERS=1
		daddi  r4,r4,8     ;r4=116hex 
		sd     r3,0(r4)    ;MEM[116(hex)]=1
		daddi  r4,r4,8     ;r4=124hex
    		daddi  r1,r0,1     ;r1=1 contains fib[i-1]
		daddi  r2,r0,1     ;r2=1 contains fib[i]
		daddu  r5,r0,r0    ;r5 flag for branching
		daddu  r29,r0,r0   ;r29 counter
					
loop1:		daddi r29,r29,1    ;counter++
       	 	slt   r5,r29,r30    ;if r4<NNUMBERS set r5
        	dadd  r3,r2,r1     ;r3=r2+r1 
		sd    r3,0(r4)     ;MEM[r4]= r3
		daddi r4,r4,8      ;r4=r4+8 
		dadd  r1,r2,r0     ;r2->r1             
		;dadd  r2,r3,r0     ;r3->r2 
		;slt   r5,r29,r30    ;if r4<NNUMBERS set r5
		bne   r5,r0,loop1  ;branch if s5!=0
		dadd  r2,r3,r0     ;r3->r2  
		jr    r31
			



