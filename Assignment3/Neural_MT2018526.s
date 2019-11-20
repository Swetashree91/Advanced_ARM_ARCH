	AREA     Neural_logic_gates, CODE, READONLY
		EXPORT __main
		IMPORT printMsg
     		 
		ENTRY 
__main  FUNCTION
	      VLDR.F32 S11,=1; x1
		  VLDR.F32 S12,=1; x2
		  VLDR.F32 S13,=1; x3
				
NAND_LOGIC      VLDR.F32  S14,=0.6	;W1
				VLDR.F32  S15,=-0.8	;W2       0
				VLDR.F32  S16,=-0.8	;W3
				VLDR.F32  S17,=0.3	;BIAS
				B Z_CALC
							
NOR_LOGIC       VLDR.F32  S14,=0.5	;W1
				VLDR.F32  S15,=-0.7	;W2       1
				VLDR.F32  S16,=-0.7	;W3
				VLDR.F32  S17,=0.1	;BIAS
				B Z_CALC
				
AND_LOGIC       VLDR.F32  S14,=-0.1	;W1
				VLDR.F32  S15,=0.2	;W2        2
				VLDR.F32  S16,=0.2	;W3
				VLDR.F32  S17,=-0.2	;BIAS
				B Z_CALC
				
OR_LOGIC        VLDR.F32  S14,=-0.1	;W1
				VLDR.F32  S15,=0.7	;W2        3
				VLDR.F32  S16,=0.7	;W3
				VLDR.F32  S17,=-0.1	;BIAS
				B Z_CALC
				
XOR_LOGIC       VLDR.F32  S14,=-5	;W1
				VLDR.F32  S15,=20	;W2          4
				VLDR.F32  S16,=10	;W3
				VLDR.F32  S17,=1	;BIAS
				B Z_CALC
				B XNOR_LOGIC
				
XNOR_LOGIC      VLDR.F32  S14,=-5	;W1
				VLDR.F32  S15,=20	;W2          5
				VLDR.F32  S16,=10	;W3
				VLDR.F32  S17,=1	;BIAS
				B Z_CALC
				B NOT_LOGIC
				
NOT_LOGIC       VLDR.F32  S14,=0.5	;W1
				VLDR.F32  S15,=-0.7	;W2        6
				VLDR.F32  S16,=0	;W3
				VLDR.F32  S17,=0.1	;BIAS
				B Z_CALC
				
Z_CALC    	    VMUL.F32  S18,S11,S14  ;w1*x1
                VADD.F32  S19,S19,S18  ;
		        VMUL.F32  S18,S12,S15  ;w2*x2
				VADD.F32  S19,S19,S18  ;
				VMUL.F32  S18,S13,S16  ;w3*x3 
				VADD.F32  S19,S19,S18  ;(w1*x1 + w2*x2 + w3*x3)
                VADD.F32  S19,S19,S17  ;(w1*x1 + w2*x2 + w3*x3) + bias
				B SIGMOID					 	
        	 
SIGMOID		VMOV.F32 S1, S19; x:Number to find e^x
	        VMOV.F32 S2, #30; Number of iterations for e^x expansion
			VMOV.F32 S3, #1;  count
			VMOV.F32 S4, #1;  temp variable
			VMOV.F32 S5, #1;  result initialized to 1
			VMOV.F32 S7, #1;  register to hold 1
			VMOV.F32 S10,#1;

Loop 		VCMP.F32 S2, S3; Comparison done for excuting taylor series expansion of e^x for s2 number of terms
			VMRS.F32 APSR_nzcv,FPSCR; to copy fpscr to apsr
			BLT Loop1;
			VDIV.F32 S6, S1, S3; temp1=x/count
			VMUL.F32 S4, S4, S6; temp=temp*temp1;
			VADD.F32 S5, S5, S4; result=result+temp;
			VADD.F32 S3, S3, S7; count++
			B Loop;
			
Loop1	 	VADD.F32 S8,S5,S10;  (1+e^z)
			VDIV.F32 S9,S5,S8;	  g(z) = 1/(1+e^-z) == (e^z)/(1+e^z)
			B OUTPUT;
	 
OUTPUT 	 	VLDR.F32 S20,=0.5
			VCMP.F32 S9,S20
			VMRS.F32 APSR_nzcv,FPSCR;Used to copy fpscr to apsr
			ITE HI			; if g(z) > 0.5 , print 1 else print 0
			MOVHI R0,#1
			MOVLS R0,#0		
			BL printMsg
			ADD R5,R5,#1;	
			CMP R5,#1
			BEQ NOR_LOGIC
			CMP R5,#2
			BEQ AND_LOGIC
			CMP R5,#3
			BEQ OR_LOGIC
			CMP R5,#4
			BEQ XOR_LOGIC
			CMP R5,#5
			BEQ XNOR_LOGIC
			CMP R5,#6
			BEQ NOT_LOGIC
			
			B stop
			
stop        B   stop	
		  
ENDFUNC
END