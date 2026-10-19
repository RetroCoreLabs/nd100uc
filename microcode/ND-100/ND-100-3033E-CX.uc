%#MODEL nd100
%
% ND-100 MICROCODE, 3033E-CX CARD: BASE BANK (PROM SET 015XX) AND CX OPTION (PROM SET 085XX)
%
% Reconstructed source. The base bank (0 - 3777) is the program of the printed listing "48-BITS
% ND-100 (PROM 015XX)" (scan ND100-MICROCODE.pdf, pages 90-218); the extension bank (4000 and
% up) is the printed listing "CX-OPTION ND-100 (PROM 085XX)" (pages 236-311). Labels, comments
% and operand names are the ones of the print. The instruction words are the ones of the PROM
% chips of the 3033E-CX card: this file assembles with "ndmicroasm nd100-asm" to exactly the
% two chip images 3033E-CX-microcode.CODE and 3033E-CX-microcode_ext.CODE put together (35370
% bytes, see REFERENCE/README.md). Where the print and the chips differ, the chips win:
%   - CYCL: the print gives CYCL,FAST, CYCL,NORM or CYCL,WAIT or no CYCL at all (no CYCL is
%     the same as CYCL,FAST, bits 21-20 = 0). Where a word has no CYCL in the print, none is
%     written here if the chips hold FAST; every other word has the cycle of the chips.
%   - 003514-003517: the print jumps to 5INIT, ENTR, LEAV and ELEAV (base bank copies); the
%     PROMs jump to ILLIN.
%   - Words that are not in the print are written from the chip decoding without comment.
% The printed base listing and the printed CX listing are two programs that were assembled
% apart (the CX listing reaches the base labels through the old label list on pages 84-87).
% Nine names are in both: 5INIT COBVC COMME ELEAV ENTR ENTRB ENTRC LEAV TSTAC. One assembly
% cannot hold a name twice, so the copy in the extension bank (address 4000 and up) is written
% with the suffix _CX (for example ENTR_CX at 6652).
%
%********************************************************************
% 48-BIT N-VERSION
%********************************************************************
% ADDRESS 0 ENTERED AT :
% MASTER CLEAR
% PAGE FAULT
% PROTECT VIOLATION
% ROM OUT OF RANGE
%********************************************************************
0/
          A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,FETCH F,NEXT F,HOLD;
          A,15 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD
          FTCH CONDENABL;
%********************************************************************
% INCREMENT P IF NOT FETCH
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
FTCH:     A,13 ALUF,ORDQ ALUD,Q
          IDBS,BMG COMM,CLIRQ T,NEXT T,HOLD
          COND,IRQ F,JMP F,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          NOINT CONDENABL;
%********************************************************************
% INTERRUPT IS PENDING
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,STP F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          FTCH2 CONDENABL;
%********************************************************************
% CPU IS IN STOP MODE, MULTIPLE SINGLE OR BREAKPOINT MUST BE THE CASE
          AB,BPFLG ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          AB,SINGL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          BRKZZ CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          BRKZZ CONDENABL;
%********************************************************************
% NO INTERRUPT IS PENDING, IT CAN BE MASTER CLEAR OR IOF-PAGEFAULT
NOINT:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,FETCH F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          FTCH2 CONDENABL;
%********************************************************************
% DECREMENT P, IT HAS BEEN INCREMENTED
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          FTCH2;
%********************************************************************
% EXECUTE LEVEL CHANGE OR JMP *
FTCH2:    PIC,RVECT ALUD,NONE
          IDBS,GPR T,MAPJ T,JMP T,HOLD
          FETCH;
%********************************************************************
%********************************************************************
% MAPPING POINT FOR ALL INSTRUCTIONS. NEXT MICROADDRESS IS TAKEN FROM
% MAPPING PROM, OR CONTROLLED BY THE INTERRUPT HARDWARE (INTERRUPT VECTOR)
%********************************************************************
FETCH:    A,P B,Z ALUF,ZERO ALUD,B,YA
          IDBS,ALU MIS,FETCH COMM,RDRQ T,JMP T,PUSH CYCL,FAST;
%********************************************************************
% RETURN FROM P-MODIFYING ROP- OR BOP-INSTRUCTION
PMODX:    ALUD,NONE
          IDBS,DSABL T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% RETURN AFTER JUMPS, OR WHENEVER NEW FETCH OF INSTRUCTION HAS TO BE DONE
INIT:     B,P ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,FETCH COMM,RDRQ T,NEXT T,PUSH CYCL,FAST;
%********************************************************************
% RETURN WITH NEXT INSTRUCTION IN DBR
USDBR:    PIC,RVECT B,P ALUF,B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,MAPJ T,HOLD CYCL,WAIT
          FETCH;
%********************************************************************
% RETURN AFTER STORE-INSTRUCTIONS, WITH NEXT INSTRUCTION IN GPR
STEND:    A,P B,R1 ALUF,A-B ALUD,NONE
          IDBS,ALU COMM,ESRP T,NEXT T,HOLD CYCL,WAIT
          COND,R=P F,JMP F,HOLD;
          PIC,RVECT B,P ALUF,B+1 ALUD,B
          IDBS,GPR T,NEXT T,MAPJ T,HOLD CYCL,FAST
          FETCH CONDENABL;
%********************************************************************
% *+1 HAS BEEN CHANGED
          PIC,LOSTS B,P ALUF,B-1 ALUD,B
          IDBS,AARG COMM,EPIC T,NEXT T,HOLD CYCL,FAST
          10;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
%********************************************************************
% RETURN WITH NEXT INSTRUCTION IN GPR
USGPR:    PIC,RVECT B,P ALUF,B+1 ALUD,B
          IDBS,GPR T,MAPJ T,HOLD CYCL,FAST
          FETCH;
%********************************************************************
% CODE FOR ILLEGAL INTRUCTION
ILLIN:    A,7 ALUD,NONE
          IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT
          INIT;
%********************************************************************
% CODE FOR PRIVILEGED INSTRUCTION IF ON RING 0-1
PRIVI:    A,11 ALUD,NONE
          IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT
          INIT;
%********************************************************************
%********************************************************************
%
% STORE INSTRUCTIONS
%
%********************************************************************
STZ:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFS;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STA:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFS;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STT:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFS;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STX:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFS;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFS;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          WRRQ;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STF:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFS;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          WRRQ;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          WRRQ;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
MIN:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          B,R2 ALUF,D+1 ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,HOLD;
          B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,WRRQ MIS,HOLD T,NEXT T,HOLD CYCL,FAST
          COND,COND F,JMP F,POP;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,WAIT
          STEND CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
%********************************************************************
%********************************************************************
% LOAD INSTRUCTIONS
%
%********************************************************************
LDA:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDT:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          B,T ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDX:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          B,X ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
LDAD:     B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          B,D ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDF:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          B,T ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
NEXT:     B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,HOLD COMM,RDRQ T,JMP T,HOLD CYCL,FAST
          LDAD;
ADD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          A,A B,A ALUF,D+A ALUD,B STS,EA
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
SUB:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          A,A B,A ALUF,A-D ALUD,B STS,EA
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
AND:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          A,A B,A ALUF,ANDDA ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
ORA:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          A,A B,A ALUF,ORDA ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
%********************************************************************
%********************************************************************
% MULTIPLY SINGLE PRECISION
%********************************************************************
MPY:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          B,R7 ALUF,PASSD ALUD,B  % SAVE GPR (NEXT INSTR)
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q  % READ STATUS
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,MASKDQ ALUD,B  % RESET DYN. OVERFLOW
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          20;
          A,A B,R2 ALUF,PASSA ALUD,B  % COPY A-REG.
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R3 ALUF,PASSD ALUD,B  % READ MEM. OPERAND
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          MPY1 CONDENABL;
          B,R2 ALUF,-B ALUD,B  % NEGATIVE A-REG.
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,COND F,JMP;
MPY1:     B,16 ALUF,ZERO ALUD,Q  % LOAD LOOP-COUNTER
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          MPY2 CONDENABL;
          A,R3 ALUF,-A ALUD,NONE  % NEG. MEM.-OPERAND
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
MPY2:     B,R5 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          A,R2 B,R5 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD  % MAKE RESULT IN R5
          IDBS,ALU T,NEXT T,POP LCOUNT
          LCOUNT;
          B,R5 ALUF,PASSB ALUD,SLD
          MIS,APT T,NEXT T,HOLD CYCL,FAST;
          B,R5 MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,NEXT;
          B,R4 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MPY3 CONDENABL;
          B,R4 ALUF,PASSD ALUD,B  % SET DYN. & STAT. OVF.
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          60;
MPY3:     A,STS B,R4 ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,A B,R3 ALUF,XORAB ALUD,NONE  % TEST SIGN
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          MPY4 CONDENABL;
          B,A ALUF,-B ALUD,B  % INVERT RESULT
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
MPY4:     A,R7 ALUF,PASSA ALUD,NONE  % FILL GPR WITH NEXT
          IDBS,ALU COMM,LDGPR T,JMP T,POP CYCL,FAST
          USGPR;
%********************************************************************
%********************************************************************
% JUMP INSTRUCTIONS
%********************************************************************
JMP:      ALUF,D-1
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,FAST
          MREFJ;
JPL:      A,P B,L ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          JMP;
JAZ:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP
          COND,F=0 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD
          CJMP CONDENABL;
%********************************************************************
% CONDITIONAL JUMP IS TRUE
CJMP:     A,R1 B,P ALUF,A+B ALUD,B
          T,JMP T,HOLD CYCL,WAIT
          INIT;
JAF:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP
          COND,F=0 F,JMP F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,RETURN T,HOLD
          CJMP CONDENABL;
JAN:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,F15 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD
          CJMP CONDENABL;
JAP:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,RETURN T,HOLD
          CJMP CONDENABL;
JXZ:      A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP
          COND,F=0 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD
          CJMP CONDENABL;
JPC:      B,X ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,RETURN T,HOLD
          CJMP CONDENABL;
JNC:      B,X ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,F15 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD
          CJMP CONDENABL;
JXN:      A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,F15 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD
          CJMP CONDENABL;
%********************************************************************
%********************************************************************
% ROP GROUP OF INSTRUCTIONS
%********************************************************************
SWAP0:    B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
SW0:      A,SRCE B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,SRCE ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
SWAP1:    B,Z ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SW0;
SWAP2:    B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
SW2:      A,SRCE B,DEST ALUF,INVA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,SRCE ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
SWAP3:    B,Z ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SW2;
RAND0:    A,SRCE B,DEST ALUF,ANDAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RAND3:
RAND1:    A,Z B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RAND2:    A,SRCE B,DEST ALUF,MASKAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
REXO0:    A,SRCE B,DEST ALUF,XORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RORA1:
REXO1:    A,SRCE B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RORA2:
REXO2:    A,SRCE B,R1 ALUF,INVA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,DEST ALUF,ORAB ALUD,B
          T,RETURN T,POP
          USDBR CONDENABL;
REXO3:
RORA3:    A,SRCE B,DEST ALUF,INVA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RORA0:    A,SRCE B,DEST ALUF,ORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD0:    A,SRCE B,DEST ALUF,A+B ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD1:    A,SRCE B,DEST ALUF,A ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD2:    A,SRCE B,DEST ALUF,B-A-1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD3:    A,SRCE B,DEST ALUF,-A-1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD4:    A,SRCE B,DEST ALUF,A+B+1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD5:    A,SRCE B,DEST ALUF,A+1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD6:    A,SRCE B,DEST ALUF,B-A ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RADD7:    A,SRCE B,DEST ALUF,-A ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RAD10:    A,SRCE B,DEST ALUF,A+B ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RAD11:    A,SRCE B,DEST ALUF,A ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RAD12:    A,SRCE B,DEST ALUF,B-A-1 ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RAD13:    A,SRCE B,DEST ALUF,-A-1 ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          USDBR CONDENABL;
RAD14:
RAD15:
RAD16:
RAD17:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USDBR;
%********************************************************************
%********************************************************************
% SHIFT INSTRUCTIONS
%********************************************************************
SHA:      ALUD,NONE
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,FAST
          DUMMY;
          B,A ALUF,PASSB ALUM,IR ALUD,SRB
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          USDBR;
%********************************************************************
% SUBROUTINE TO REMOVE ONE SHIFT COUNT
DUMMY:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD LCOUNT CYCL,FAST;
SHT:      ALUD,NONE
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,FAST
          DUMMY;
          B,T ALUF,PASSB ALUM,IR ALUD,SRB
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          USDBR;
SHD:      ALUD,NONE
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,FAST
          DUMMY;
          B,D ALUF,PASSB ALUM,IR ALUD,SRB
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          USDBR;
SAD:      A,D ALUF,PASSA ALUD,Q
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,FAST
          DUMMY;
          B,A ALUF,PASSB ALUM,IR ALUD,SRD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USDBR;
%********************************************************************
%********************************************************************
% ARGUMENT INSTRUCTIONS
%********************************************************************
SAA:      B,A ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,FAST
          USDBR;
SAT:      B,T ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,FAST
          USDBR;
SAX:      B,X ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,FAST
          USDBR;
SAB:      B,B ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,FAST
          USDBR;
AAA:      A,A B,A ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP
          USDBR;
AAT:      A,T B,T ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP
          USDBR;
AAX:      A,X B,X ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP
          USDBR;
AAB:      A,B B,B ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP
          USDBR;
%********************************************************************
%********************************************************************
% SKIP INSTRUCTIONS
%********************************************************************
SKEQL:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP
          COND,F=0 F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SKIP CONDENABL;
%********************************************************************
% SKIP IS TRUE
SKIP:     B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
SKGRE:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,OVF F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SKLSS CONDENABL;
SKGEQ:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST
          SKIP CONDENABL;
SKMGR:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,CRY F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SKIP CONDENABL;
SKUEQ:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST
          SKIP CONDENABL;
SKLST:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,OVF F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SKGEQ CONDENABL;
SKLSS:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,F15 F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SKIP CONDENABL;
SKMLS:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          COND,CRY F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST
          SKIP CONDENABL;
%********************************************************************
%********************************************************************
% BIT INSTRUCTIONS
%********************************************************************
% BSET BAC
BSETK:    B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,PUSH CYCL,FAST
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          BSET1 CONDENABL;
%********************************************************************
% BSET ZRO
BSET0:    A,REG B,R1 ALUF,INVD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          STSTZ;
          A,R1 B,DEST ALUF,ANDAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          ZTSTS CONDENABL;
%********************************************************************
% SUBROUTINE TO ISOLATE K-FLIP-FLOP
GETK:     ALUF,ANDDQ ALUD,Q
          IDBS,STS T,RETURN T,POP
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% SUBROUTINE TO TRANSFER STS TO Z-REGISTER
STSTZ:    B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,RETURN T,POP CYCL,FAST
          COND,DR=2 F,JMP F,POP;
%********************************************************************
% SUBROUTINE TO TRANSFER Z-REGISTER TO STS
ZTSTS:    A,Z ALUF,PASSA ALUD,Q STS,LO
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
% BSET ONE
BSET1:    A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          STSTZ;
          A,R1 B,DEST ALUF,ORAB ALUD,B
          IDBS,BMG T,RETURN T,POP CYCL,FAST
          ZTSTS CONDENABL;
%********************************************************************
% BSET BCM
BSETC:    A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          STSTZ;
          A,R1 B,DEST ALUF,XORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          ZTSTS CONDENABL;
%********************************************************************
% BSKP BCM
BSKPC:    B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,FAST
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          BSKP0 CONDENABL;
%********************************************************************
% BSKP ONE
BSKP1:    B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          B,DEST ALUF,INVB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          BSKP9;
%********************************************************************
% BSKP BAC
BSKPK:    B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,FAST
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          BSKP1 CONDENABL;
%********************************************************************
% BSKP ZRO
BSKP0:    B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
BSKP9:    A,REG ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SKIP CONDENABL;
%********************************************************************
% BSTA
BSTA:     A,2 B,R2 ALUF,INVD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          BSTA1;
          A,Z B,R2 ALUF,ANDAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          PMODX;
BSTA1:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BSETK;
          A,Z B,R2 ALUF,ANDAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
%********************************************************************
% BSTC
BSTC:     A,2 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          BSTC1;
          A,Z B,R2 ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          PMODX;
BSTC1:    A,R2 ALUF,XORDA ALUD,Q
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSQ ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BSETK;
          A,Z B,R2 ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
%********************************************************************
% BANC
BANC:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,FAST
          GETK;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST
          BLDC CONDENABL;
%********************************************************************
% BORC
BORC:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,FAST
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USDBR CONDENABL;
%********************************************************************
% BLDC
BLDC:     A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          STSTZ;
          A,R1 B,DEST ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,2 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          SETK0 CONDENABL;
SETK1:    A,R2 B,Z ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USDBR;
%********************************************************************
% BAND
BAND:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,FAST
          GETK;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST
          BLDA CONDENABL;
%********************************************************************
% BORA
BORA:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,FAST
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USDBR CONDENABL;
%********************************************************************
% BLDA
BLDA:     A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          STSTZ;
          A,R1 B,DEST ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,2 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          SETK1 CONDENABL;
SETK0:    A,R2 B,Z ALUF,MASKAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USDBR;
%********************************************************************
%********************************************************************
% STORE REGISTER BLOCK
%********************************************************************
SRB:      B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,JMP T,PUSH CYCL,FAST
          RBLOK;
          B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          SRB1 CONDENABL;
%********************************************************************
% OWN LEVEL, SAVE REGISTER BLOCK IN REGISTER FILE
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          A,PIL B,LC ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,POP LCOUNT CYCL,FAST;
SRB1:     A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,REG B,P ALUD,NONE IDBS,REG T,JMP T,PUSH CYCL,WAIT WRRQ;
          A,REG B,X ALUD,NONE IDBS,REG T,JMP T,PUSH CYCL,WAIT WRRQ;
          A,REG B,T ALUD,NONE IDBS,REG T,JMP T,PUSH CYCL,WAIT WRRQ;
          A,REG B,A ALUD,NONE IDBS,REG T,JMP T,PUSH CYCL,WAIT WRRQ;
          A,REG B,D ALUD,NONE IDBS,REG T,JMP T,PUSH CYCL,WAIT WRRQ;
          A,REG B,L ALUD,NONE IDBS,REG T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          377;
          A,REG B,Z ALUF,ANDDQ ALUD,Q
          IDBS,REG T,JMP T,PUSH
          WRRQ;
          ALUF,PASSQ ALUD,NONE IDBS,ALU T,JMP T,PUSH CYCL,WAIT WRRQ;
          A,REG B,B ALUD,NONE IDBS,REG T,JMP T,POP CYCL,WAIT STEND;
%********************************************************************
% SUBROUTINE TO CHECK FOR OWN LEVEL IN SRB, LRB, IRW, IRR
RBLOK:    ALUF,PASSD ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% ENTRY USED BY MOPC IN REGISTER DEPOSIT
OPCRB:    ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% ENTRY USED BY IRR AND IRW
IRWRD:    A,PIL ALUF,XORDQ ALUD,Q
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,RETURN T,POP
          170;
%********************************************************************
%********************************************************************
% LOAD REGISTER BLOCK
%********************************************************************
LRB:      B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,JMP T,PUSH CYCL,FAST
          RBLOK;
          A,P B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,REG B,P ALUD,NONE IDBS,DBR COMM,EWRF T,JMP T,PUSH CYCL,WAIT RDRQ;
          A,REG B,X ALUD,NONE IDBS,DBR COMM,EWRF T,JMP T,PUSH CYCL,WAIT RDRQ;
          A,REG B,T ALUD,NONE IDBS,DBR COMM,EWRF T,JMP T,PUSH CYCL,WAIT RDRQ;
          A,REG B,A ALUD,NONE IDBS,DBR COMM,EWRF T,JMP T,PUSH CYCL,WAIT RDRQ;
          A,REG B,D ALUD,NONE IDBS,DBR COMM,EWRF T,JMP T,PUSH CYCL,WAIT RDRQ;
          A,REG B,L ALUD,NONE IDBS,DBR COMM,EWRF T,JMP T,PUSH CYCL,WAIT RDRQ;
          A,REG B,Z ALUD,NONE IDBS,DBR COMM,EWRF T,JMP T,PUSH CYCL,WAIT RDRQ;
          A,REG B,B ALUF,PASSQ ALUD,NONE
          IDBS,DBR COMM,EWRF T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,POP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USGPR CONDENABL;
%********************************************************************
% OWN LEVEL, UNSAVE REGISTER BLOCK
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          A,PIL B,LC ALUF,PASSD ALUD,B
          IDBS,REG T,NEXT T,POP LCOUNT CYCL,FAST;
          A,R2 B,P ALUF,PASSA ALUD,B  % P IS UNCHANGED
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,Z ALUF,PASSA ALUD,NONE STS,LO  % CHANGE STS
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USGPR;
%********************************************************************
%********************************************************************
% INTER-REGISTER READ
%********************************************************************
IRR:      B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,LOAD CYCL,FAST
          IRWRD;
          A,REG B,Z ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          IRR1 CONDENABL;
%********************************************************************
% OWN LEVEL
          A,Z B,Z ALUF,ANDDA ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          IRR2;
%********************************************************************
% OTHER LEVEL
IRR1:     ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          A,REG B,Z ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,REG B,DEST ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
IRR2:     B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
%********************************************************************
% INTER REGISTER WRITE
%********************************************************************
IRW:      A,P B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,LOAD CYCL,FAST
          IRWRD;
          ALUD,NONE
          IDBS,DSABL T,NEXT T,HOLD CYCL,FAST
          IRW1 CONDENABL;
%********************************************************************
% OWN LEVEL
          A,A B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          IRW2;
          A,R2 B,P ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          CONDENABL;
%********************************************************************
% STS MUST BE LOADED
          A,Z ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
% OTHER LEVEL
IRW1:     A,A ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,REG B,DEST ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,FAST
          IRW2;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377 CONDENABL;
%********************************************************************
% STS MUST BE LOADED
          A,REG B,Z ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
% SUBROUTINE TO CHECK FOR STS AS DESTINATION
IRW2:     B,DEST ALUF,PASSD ALUD,NONE
          IDBS,BARG T,RETURN T,POP
          COND,F=0 F,RETURN F,HOLD;
%********************************************************************
%********************************************************************
% LOAD BYTE
%********************************************************************
LBYT:     A,X B,R1 MIS,ZIN ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          LBYTM;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          LBYTU CONDENABL;
%********************************************************************
% CODE FOR BOTH UPPER AND LOWER BYTE
          B,A ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USGPR;
%********************************************************************
% UPPER BYTE
LBYTU:    ALUF,PASSD ALUD,Q
          IDBS,SWAP T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO CALCULATE ADDRESS IN LBYT AND SBYT
LBYTM:    A,T B,R1 ALUF,A+B ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,X B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,RETURN T,POP
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
%********************************************************************
% STORE BYTE
%********************************************************************
SBYT:     B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          A,A B,R3 ALUF,ANDAB ALUD,B  % ISOLATE BYTE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,X B,R1 MIS,ZIN ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          LBYTM;
          ALUF,PASSD ALUD,Q  % READ WORD
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          SBYTU CONDENABL;
%********************************************************************
% LOWER BYTE
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177400;
%********************************************************************
% BOTH BYTES
SBYT1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,R2 ALUF,ORAB ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
%********************************************************************
% UPPER BYTE
SBYTU:    B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          SBYT1;
%********************************************************************
%********************************************************************
% REGISTER MULTIPLY
%********************************************************************
RMPY:     A,SRCE B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          RMPY1 CONDENABL;
          B,R1 ALUF,-B ALUD,B  % FIRST OP. NEG.
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,COND F,JMP F,HOLD;
RMPY1:    B,16 ALUF,ZERO ALUD,B
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          RMPY2 CONDENABL;
          ALUF,-Q ALUD,NONE  % SEC. OP. NEG.
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
RMPY2:    ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          A,R1 B,R6 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD  % MULTIPLY LOOP
          IDBS,ALU T,NEXT T,POP LCOUNT;
          A,SRCE B,DEST ALUF,XORAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          RMPY3 CONDENABL;
          A,R6 B,A ALUF,PASSA ALUD,B  % ANSWER POSITIVE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USDBR;
RMPY3:    B,D ALUF,-Q ALUD,B STS,EA  % ANSWER NEG.
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,A ALUF,-A-1 ALUD,B CRY,C
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USDBR;
%********************************************************************
%********************************************************************
% REGISTER DIVIDE
%********************************************************************
RDIV:     A,SRCE B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,A B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          RDIV1 CONDENABL;
          B,R1 ALUF,-B ALUD,B  % NEGATIVE DIVISOR
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,COND F,JMP F,HOLD;
RDIV1:    A,SRCE B,A ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          RDIV2 CONDENABL;
          B,D ALUF,-B ALUD,B STS,EA  % NEGATIVE
          IDBS,ALU T,NEXT T,HOLD;  % DIVIDEND
          B,A ALUF,-B-1 ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
RDIV2:    A,R1 B,A ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,NEXT F,HOLD;
          B,R7 ALUF,PASSQ ALUD,B
          T,JMP T,HOLD
          RDIVZ CONDENABL;
          B,D ALUF,PASSB ALUD,Q
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          16;
          B,STS ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          A,7 ALUF,PASSD ALUD,NONE STS,LO
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,0 B,A MIS,ZIN ALUF,PASSB ALUD,SLD STS,ES
          IDBS,AARG COMM,LDGPR T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
%********************************************************************
% DIVIDE LOOP
          A,R1 B,A MIS,ZIN ALUF,B-A-1 ALUM,FDV ALUD,SLD STS,ES CRY,GPR
          IDBS,ALU T,NEXT T,POP LCOUNT;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,A B,D MIS,LIN ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,STS ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          RDIV3 CONDENABL;
          A,R1 B,D ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
RDIV3:    A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          RDIV4 CONDENABL;
%********************************************************************
% CHANGE QUOTIENT SIGN
          ALUF,-Q ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,COND F,JMP F,HOLD;
RDIV4:    B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          RDIV5 CONDENABL;
%********************************************************************
% CHANGE REMAINDER SIGN
          B,D ALUF,-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
RDIV5:    A,A B,R7 ALUF,XORAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,POP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USDBR CONDENABL;
%********************************************************************
% OVERFLOW (OR ERROR IN EXR, DNZ ETC.)
RDIVZ:    B,10 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,ORDQ ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          A,STS ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USDBR;
%********************************************************************
%********************************************************************
% EXECUTE REGISTER
%********************************************************************
EXR:      A,SRCE ALUF,XORDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,ANDDQ ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177700;
          A,SRCE ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          RDIVZ CONDENABL;
%********************************************************************
% OK, NOT EXR(EXR)
          ALUD,NONE
          IDBS,GPR COMM,CLIRQ T,NEXT T,MAPJ T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST;
%********************************************************************
%********************************************************************
% MIX3-INSTRUCTION
%********************************************************************
MIX3:     A,A B,X ALUF,A-1 ALUM,MIC ALUD,SLB
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD;
          A,X B,X ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,POP
          USDBR;
%********************************************************************
%********************************************************************
% FLOATING SUBTRACT INSTRUCTION
%********************************************************************
FSB:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% INVERT SIGN OF MEM. OPERAND
          A,17 B,R2 ALUF,XORDQ ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          FAD2;
%********************************************************************
%********************************************************************
% FLOATING ADD ROUTINE
%********************************************************************
FAD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH
          MREFL;
          B,R2 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% COMMON PART OF FAD & FSB
FAD2:     B,STS ALUF,INVD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          2;
          A,5 B,R6 ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
          A,17 B,R5 ALUF,INVD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,T ALUF,ANDAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,R5 ALUF,ANDAB ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDRQ;
          B,R7 ALUF,PASSD ALUD,B  % SAVE GPR (NEXT INSTR)
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,Q-A ALUD,B  % COMPARE EXPONENTS
          T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,STS B,STS ALUF,ANDDA ALUD,B
          IDBS,STS COMM,CLFF T,JMP T,HOLD CYCL,FAST
          NED1 CONDENABL;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,R5 ALUF,A-1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          EQUAL CONDENABL;
%********************************************************************
% MEMORY OPERAND HAS SMALLEST EXPONENT, SHIFT DOWN MANTISSA
          A,R6 B,R5 ALUF,MASKAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% TEST IF MEMORY OPERAND INSIGNIFICANT, ANSWER = TAD
          B,R3 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          STSST CONDENABL;
          ALUD,NONE
          IDBS,DSABL T,JMP T,PUSH CYCL,FAST
          RDRQ;
          ALUF,PASSD ALUD,Q
          IDBS,DBR COMM,CLFF T,NEXT T,PUSH CYCL,WAIT
          COND,LC=0;
%********************************************************************
% SHIFT DOWN MEMORY OPERAND MANTISSA
          B,R3 MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD STS,ES
          IDBS,ALU T,JMP T,LOAD LCOUNT CYCL,FAST
          DUMM2;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SUBF CONDENABL;
%********************************************************************
% EQUAL SIGNS ON OPERANDS, ADD MANTISSAS
ADDF:     A,D B,D ALUF,A+Q ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
ADDF2:    A,R3 B,A ALUF,A+B ALUD,B STS,EA CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,JMP F,HOLD;
          A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          TGOOD CONDENABL;
%********************************************************************
% ADDITION GAVE CARRY, SHIFT MANTISSA RIGHT
          ALUF,ORDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          1;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          40000;
          A,T ALUF,A+1 ALUD,Q  % CHECK OVERFLOW
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CHKOF;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          STSEX;
%********************************************************************
% TAD-OPERAND HAS SMALLEST EXPONENT, SHIFT DOWN MANTISSA
NED1:     A,R5 B,R4 ALUF,A-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,R4 ALUF,ORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,INVQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% TEST IF TAD-OPERAND INSIGNIFICANT, ANSWER = MEMORY OPERAND
          A,R5 ALUF,A+1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          NORM2 CONDENABL;
%********************************************************************
% EXCHANGE OPERANDS
          A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,A B,R3 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R4 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,D ALUF,PASSA ALUD,B
          IDBS,ALU COMM,CLFF T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
%********************************************************************
% SHIFT DOWN TAD-OPERAND
          B,R3 MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD STS,ES
          IDBS,ALU T,JMP T,LOAD LCOUNT CYCL,FAST
          DUMM2;
          A,R2 B,T ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SUBF CONDENABL;
          A,D B,D ALUF,A+Q ALUD,B STS,EA
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ADDF2;
%********************************************************************
% ANSWER = MEMORY OPERAND
NORM2:    B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          B,D ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R2 B,T ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          STSST;
%********************************************************************
% DIFFERENT SIGNS ON OPERANDS, SUBTRACT MANTISSAS
SUBF:     A,D B,D ALUF,A-Q ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,A ALUF,B-A-1 ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,OOD F,JMP F,HOLD;
          A,STS ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          FAD3 CONDENABL;
          B,STS ALUF,ORDQ ALUD,B  % SET TG-FLIP-FLOP
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          2;
          A,D B,D ALUF,ORDA ALUD,B
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
FAD3:     A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          NOINV;
%********************************************************************
% EQUAL EXPONENTS
EQUAL:    A,R2 B,T ALUF,XORAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SUBF3 CONDENABL;
%********************************************************************
% EQUAL SIGNS, ADD MANTISSAS
          B,R3 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          ADDF;
%********************************************************************
% DIFFERENT SIGNS, SUBTRACT MANTISSAS
SUBF3:    B,R3 ALUF,INVD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          A,D ALUF,A-D-1 ALUD,Q STS,EA
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R3 B,A ALUF,A+B ALUD,B STS,EA CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          INV CONDENABL;
          ALUF,Q+1 ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A ALUF,B ALUD,B CRY,C
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          NOINV;
% INVERT ANSWER AFTER SUBTRACTION
INV:      ALUF,INVQ ALUD,Q
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          100000;
          A,T B,T ALUF,XORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          B,A ALUF,INVB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% NORMALIZE ANSWER AFTER SUBTRACTION
NOINV:    B,R4 ALUF,D-1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD
          21;
          A,2 B,A ALUF,PASSB ALUD,NONE
          IDBS,AARG COMM,LDGPR T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,T B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          FAD4 CONDENABL;
          A,T B,R5 ALUF,A-D ALUD,B
          IDBS,GPR T,NEXT T,HOLD;
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          ALUF,ZERO ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          FAD4 CONDENABL;
%********************************************************************
% ANSWER = 0
ZTAD:     B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,D ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R7 B,T ALUF,ZERO ALUD,B,YA
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          STSEX;
% CONTINUED NORMALIZE AFTER SUBTRACTION
FAD4:     A,16 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,PUSH CYCL,FAST
          COND,F15;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R4 B,LC ALUF,A-D-1 ALUD,Q
          IDBS,BARG T,NEXT T,HOLD;
          A,R5 ALUF,A-Q ALUD,Q  % CHECK IF UNDERFLOW
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CHKUF;
          A,R7 ALUF,PASSA ALUD,NONE  % RESTORE GPR
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          STSEX;
% SUBROUTINE TO CORRECT FOR OVERSHOOT AFTER MANTISSA ALIGNMENT
DUMM2:    B,R3 MIS,LIN ALUF,PASSB ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,T ALUF,XORAB ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          COND,F15 F,NEXT;
%********************************************************************
%********************************************************************
% FLOATING MULTIPLY ROUTINE
%********************************************************************
661/
FMU:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,FAST
          MREFL;
          B,STS ALUF,INVD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          2;
          A,STS B,STS ALUF,ANDDA ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          B,R2 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          A,R2 B,T ALUF,A+B ALUD,Q  % ADD EXPONENTS
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,17 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          A,T B,R2 ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          FMU2 CONDENABL;
%********************************************************************
% UNEQUAL SIGNS ON OPERANDS
          A,17 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
FMU2:     ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,HOLD;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          40000;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          A,T B,R2 ALUF,XNORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          FMU1 CONDENABL;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
%********************************************************************
% OFUF MEANS EITHER OVER- OR UNDER-FLOW AFTER EXPONENT ADD
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          OFUF CONDENABL;
%********************************************************************
% MULTIPLY MANTISSAS
FMU1:     A,16 B,T ALUF,XORDQ ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          ALUF,ZERO ALUD,Q
          IDBS,ALU COMM,CLFF T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST
          17;
          A,D ALUF,A+Q ALUM,FMU ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,A B,R1 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD STS,EA CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST
          16;
          A,D ALUF,A+Q ALUM,FMU ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,A B,R1 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD STS,EA CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT;
          A,D ALUF,A+Q ALUM,FMU ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,A B,R1 ALUF,A+B ALUM,FMU ALUD,B STS,EA CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,NEXT F,HOLD;
          A,R1 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MCRY1 CONDENABL;
%********************************************************************
% NO CARRY IN LAST ADDITION
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ZTAD CONDENABL;
          A,T ALUF,A-1 ALUD,Q  % CHECK UNDERFLOW
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CHKUF;
%********************************************************************
% CHECK TG-BEHAVIOUR
TGOOD:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,OOD F,JMP F,HOLD;
TGTST:    A,STS ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          STSST CONDENABL;
TGSET:    B,STS ALUF,ORDQ ALUD,B  % SET TG
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          2;
          A,D B,D ALUF,ORDA ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          STSST;
%********************************************************************
% THERE WAS CARRY FROM LAST ADDITION IN MULTIPLY LOOP
MCRY1:    B,1 ALUF,ORDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,OOD F,JMP F,HOLD;
%********************************************************************
% SHIFT DOWN MANTISSAS
          A,1 B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          FMU3 CONDENABL;
          A,STS B,STS ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          ALUF,ORDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          1;
FMU3:     A,R7 B,D ALUF,PASSQ ALUD,B,YA  % RESTORE GPR
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          STSEX;
%********************************************************************
%********************************************************************
% FLOATING DIVIDE ROUTINE
%********************************************************************
740/
FDV:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,FAST
          MREFL;
          B,STS ALUF,INVD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          2;
          A,STS B,STS ALUF,ANDDA ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          B,R2 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
%********************************************************************
% SUBTRACT EXPONENTS
          A,T B,R2 ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,17 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          FDV2 CONDENABL;
%********************************************************************
% UNEQUAL SIGNS ON OPERANDS
          A,17 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
FDV2:     B,R3 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F15 F,JMP F,HOLD;
          A,16 ALUF,XORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          FLOVF CONDENABL;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,HOLD COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,NEXT F,HOLD;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          40000;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          A,T B,R2 ALUF,XORAQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          FDV3 CONDENABL;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          FDV3 CONDENABL;
%********************************************************************
% OVERFLOW OR UNDERFLOW IN FLOATING OPERATION
OFUF:     A,T B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          FLOVF CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ZTAD;
%********************************************************************
% DIVIDE MANTISSAS
FDV3:     B,T ALUF,PASSQ ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          16;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,D ALUF,PASSA ALUD,Q
          IDBS,ALU COMM,CLFF T,NEXT T,HOLD CYCL,FAST
          ZTAD CONDENABL;
          A,7 ALUF,PASSD ALUD,NONE STS,LO
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,R4 ALUF,Q-A ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,A MIS,ZIN ALUF,B-A-1 ALUD,SLD STS,ES CRY,C
          IDBS,ALU T,NEXT T,PUSH
          COND,LC=0;
          A,R4 ALUF,Q-A-1 ALUM,FDV ALUD,Q STS,EA CRY,GPR
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,A MIS,ZIN ALUF,B-A-1 ALUM,FDV ALUD,SLD STS,ES CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,17 ALUF,PASSA ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          A,R4 ALUF,Q-A-1 ALUM,FDV ALUD,Q STS,EA CRY,GPR
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,A MIS,ZIN ALUF,B-A-1 ALUM,FDV ALUD,SLD STS,ES CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT;
          A,R5 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
%********************************************************************
% CHECK IF NORMALIZATION IS NECESSARY
          B,D ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          POSDV CONDENABL;
          A,T ALUF,A+1 ALUD,Q  % CHECK OVERFLOW
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CHKOF;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,DZD F,JMP F,HOLD;
%********************************************************************
% CHECK TG-BEHAVIOUR
TGTN2:    A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          DZD0 CONDENABL;
DZD1:     A,D B,D ALUF,MASKDA ALUD,NONE  % SET TG
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          2;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
STSEX:    A,STS ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USGPR;
DZD0:     A,D B,D ALUF,ORDA ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          STSEX;
%********************************************************************
% NORMALIZE ANSWER IN FLOATING DIVIDE
POSDV:    A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,DZD F,JMP F,HOLD;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TGTN2;
%********************************************************************
% FLOATING OVERFLOW
FLOVF:    B,T ALUF,ORDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          77777;
          A,Z B,A ALUF,INVA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,Z B,D ALUF,INVA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,10 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
STSST:    A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          STSEX;
%********************************************************************
% CHECK IF FLOATING UNDERFLOW
CHKUF:    A,T B,R2 ALUF,MASKAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          B,T ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          ZTAD CONDENABL;
%********************************************************************
% CHECK IF FLOATING OVERFLOW
CHKOF:    B,R2 ALUF,INVQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          B,T ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          CONDENABL;
          A,17 ALUF,XORDQ ALUD,Q
          IDBS,BMG T,JMP T,POP
          FLOVF;
%********************************************************************
%********************************************************************
% NORMALIZE INSTRUCTION
%********************************************************************
1037/
NLZ:      A,A ALUF,PASSA ALUD,NONE
          T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,D ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          NLZ1 CONDENABL;
          B,T ALUF,ZERO ALUD,B  % ANSWER =0
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USDBR;
NLZ1:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          40000;
          B,T ALUF,D+Q ALUD,B
          IDBS,GPR,SEXT T,NEXT T,HOLD CYCL,FAST;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F15 F,JMP F,HOLD;
          A,17 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          NLZ2 CONDENABL;
%********************************************************************
% A<0
          A,T B,T ALUF,D+A ALUD,B
          IDBS,GPR T,NEXT T,HOLD;
          B,A ALUF,-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
NLZ2:     B,R4 ALUF,D-1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH
          21;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLB  % NORMALIZE LOOP
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R4 B,LC ALUF,A-D-1 ALUD,Q
          IDBS,BARG T,NEXT T,HOLD;
          A,T B,T ALUF,A-Q ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USDBR;
%********************************************************************
%********************************************************************
% DENORMALIZE INSTRUCTION
%********************************************************************
1061/
DNZ:      A,T ALUF,D+A
          IDBS,GPR,SEXT T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,R2 ALUF,D+Q ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          20;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          40000;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,16 B,D ALUF,ANDDQ ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          DNZ1 CONDENABL;
%********************************************************************
% ANSWER = 0
          B,T ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,D ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USDBR;
DNZ1:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          RDIVZ CONDENABL;
%********************************************************************
% NOT OVERFLOW
          ALUD,NONE
          IDBS,DSABL T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          B,A ALUF,PASSB ALUD,SRD
          T,NEXT T,NEXT MIS,APT T,POP LCOUNT;
          B,A ALUF,PASSB ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A ALUF,PASSB ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,POP;
          B,T ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USDBR CONDENABL;
%********************************************************************
% NEGATIVE ANSWER
          B,A ALUF,-B ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USDBR;
%********************************************************************
%********************************************************************
% IOX-INSTRUCTION
%********************************************************************
1106/
IOX:      B,R1 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          IOXG;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USGPR;
%********************************************************************
%********************************************************************
% IOXT - INSTRUCION
%********************************************************************
IOXT2:    A,T B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          IOXX1;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP
          USGPR;
%********************************************************************
%********************************************************************
% SUBROUTINE USED BY IOX OR MICROPROGRAMMED LOADERS
% TO ISSUE IOXINSTRUCTIONS ON SYSTEM BUS
%********************************************************************
% IOX-ROUTINE FOR 11-BIT IOX-ADDRESS
IOXG:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          3777;
          A,R1 B,R1 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% IOX-ROUTINE FOR 16-BIT IOX ADDRESS
IOXX1:    A,R1 B,7 ALUF,MASKDA ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,OPCTT1 F,NEXT F,HOLD;
%********************************************************************
% CHECK IF DEVICE NUMBERS 30X IS ON THE CPU-BOARD
          ALUF,XORDQ ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD
          300;
          A,R1 B,3 ALUF,MASKDA ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          TERMX CONDENABL;
%********************************************************************
% CHECK IF DEVICE IS IN THE RANGE 10-13
          B,10 ALUF,XORDQ ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,FAST
          CLKX CONDENABL;
%********************************************************************
% DEVICE IS NOT ON CPU-BOARD. ISSUE GENERAL IOX
          A,R1 ALUF,PASSA ALUD,NONE  % ADDRESS -> IOX
          COMM,IOX T,NEXT T,HOLD CYCL,FAST;
          A,A ALUF,PASSA ALUD,NONE  % OUTPUT DATA
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          B,A ALUF,PASSD ALUD,B  % INPUT DATA
          IDBS,DBR T,RETURN T,POP CYCL,WAIT;
%********************************************************************
% DEV.NO. 30X IS ON CPU BOARD. JUMP TO VECTOR
TERMX:    AB,STATUS ALUF,PASSD
          IDBS,REG T,JMP0-3 T,HOLD CYCL,FAST
          TRMVC;
%********************************************************************
% DEV.NO. IS 10-13, JUMP TO VECTOR
CLKX:     AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP0-3 T,HOLD CYCL,FAST
          CLKVC;
%********************************************************************
% SUBROUTINE TO WRITE STATUS-SCRATCH WORD, AND TO WRITE SIOC-REGISTER
WSIOC:    AB,STATUS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
WSIO2:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,SIOC T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% ROUTINES FOR CPU-TERMINAL, ENTERED FROM VECTOR
%********************************************************************
% IOX 300
TRM0:     A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          B,A ALUF,ANDDQ ALUD,B
          IDBS,ARG T,RETURN T,POP
          377 CONDENABL;
          ALUD,NONE
          IDBS,ALU COMM,RSDA T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% IOX 302
TRM2:     A,A B,1 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,PUSH CYCL,FAST;
          B,A MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          340;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R6 B,A ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,4 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          TRM20 CONDENABL;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
TRM20:    A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD
          TRM21 CONDENABL;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          TRM21 CONDENABL;
          A,3 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
TRM21:    A,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,0 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,RETURN T,POP CYCL,FAST
          CONDENABL;
TRM22:    A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% IOX 303
TRM3:     A,R2 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,R2 ALUF,ORDA ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          TRM31 CONDENABL;
          A,R2 B,R2 ALUF,MASKDA ALUD,B
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
TRM31:    B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          74002;
          A,R3 B,R2 ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          175;
          A,R2 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          WSIOC;
%********************************************************************
% IOX 306
TRM6:     ALUF,PASSD ALUD,NONE
          IDBS,IOR T,NEXT T,HOLD
          COND,F15 F,JMP F,HOLD;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          TRM61 CONDENABL;
          A,3 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
TRM61:    A,2 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,0 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,RETURN T,POP CYCL,FAST
          TRM22 CONDENABL;
%********************************************************************
% IOX 307
TRM7:     A,A B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,2 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          WSIOC CONDENABL;
          B,4 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          WSIOC;
%********************************************************************
% ROUTINES FOR DEVICE NUMBERS 10-13, ENTERED FROM VECTOR
%********************************************************************
% IOX 11
CLK1:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,SIOC T,NEXT T,HOLD CYCL,SLOW;
          A,7 ALUF,MASKDQ ALUD,Q
          IDBS,BMG COMM,CLRTC T,JMP T,HOLD
          WSIO2;
%********************************************************************
% IOX 13
CLK3:     A,A B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,15 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          CLK31 CONDENABL;
          B,1 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
CLK31:    A,A B,R2 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          WSIOC CONDENABL;
          B,10 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          WSIOC;
%********************************************************************
%********************************************************************
% IDENT-INTRUCTION
%********************************************************************
IDENT:    A,6 B,R1 ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,R1 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,NEXT F,HOLD;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          43;
          A,R1 B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          A,R1 B,4 ALUF,A-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD
          ID13 CONDENABL;
          A,R1 B,11 ALUF,A-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD
          ID10 CONDENABL;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,FAST
          IDX CONDENABL;
%********************************************************************
% IDENT IS ON LEVEL 12, CHECK IF TERMINAL GAVE INTERRUPT
ID12:     A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD
          IDX CONDENABL;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          IDX CONDENABL;
          A,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG COMM,LDLC T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
% CPU-BOARD TERMINAL READY FOR TRANSFER
IDSPC:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,COND F,NEXT F,HOLD;
          B,LC ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          IDX CONDENABL;
%********************************************************************
% DEVICE ON CPU-BOARD (TERMINAL OR CLOCK) READY FOR TRANSFER AND INT. ENABLED
IDRET:    A,0 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,SIOC T,NEXT T,HOLD CYCL,SLOW;
          AB,STATUS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,POP CYCL,FAST
          USGPR;
%********************************************************************
% IDENT IS ON LEVEL 10, CHECK IF TERMINAL GAVE INTERRUPT
ID10:     A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,NONE
          IDBS,IOR T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          IDX CONDENABL;
          A,2 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG COMM,LDLC T,JMP T,HOLD
          IDSPC;
%********************************************************************
% IDENT IS ON LEVEL 13, CHECK IF CLOCK GAVE INTERRUPT
ID13:     AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          11;
          A,R2 B,11 ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD;
          A,0 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          IDRET CONDENABL;
%********************************************************************
% DEVICE IS NOT ON CPU-BOARD, SEND OUT GENERAL IDENT
IDX:      A,R1 ALUF,PASSA ALUD,NONE  % ADDRESS -> IDENT
          IDBS,ALU COMM,IDENT T,NEXT T,HOLD CYCL,FAST;
          A,A ALUF,PASSA ALUD,NONE  % OUTPUT DATA
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          B,A ALUF,PASSD ALUD,B  % INPUT DATA
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
%********************************************************************
%********************************************************************
% MASKED CLEAR INSTRUCTION
%********************************************************************
MCL:      ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,PUSH CYCL,FAST
          MCMS1;
          B,6 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MCSTS CONDENABL;
          B,7 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MCPID CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MCPIE CONDENABL;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,POP CYCL,WAIT INIT;
%********************************************************************
%********************************************************************
% MASKED SET INSTRUCION
%********************************************************************
MST:      ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,PUSH CYCL,FAST
          MCMS1;
          B,6 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MSSTS CONDENABL;
          B,7 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MSPID CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MSPIE CONDENABL;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,POP CYCL,WAIT INIT;
%********************************************************************
% SUBROUTINE FOR MCL & MST INSTRUCTIONS
MCMS1:    B,17 ALUF,ANDDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,1 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE FOR MCL
MCLEA:    A,A ALUF,MASKAQ ALUD,Q
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE FOR MST
MSET:     A,A ALUF,ORAQ ALUD,Q
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% MCL STS
MCSTS:    ALUF,PASSD ALUD,Q
          IDBS,STS T,NEXT T,HOLD CYCL,FAST;
          A,A ALUF,MASKAQ ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,POP CYCL,FAST
          USDBR;
%********************************************************************
% MCL PID
MCPID:    AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          MCLEA;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          TRPID;
%********************************************************************
% MCL PIE
MCPIE:    AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          MCLEA;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          TRPIE;
%********************************************************************
% MST STS
MSSTS:    A,A ALUF,ORDA ALUD,Q
          IDBS,STS T,JMP T,HOLD CYCL,FAST
          TRSTS;
%********************************************************************
% MST PID
MSPID:    AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          MSET;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          TRPID;
%********************************************************************
% MST PIE
MSPIE:    AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          MSET;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          TRPIE;
%********************************************************************
%********************************************************************
% MONITOR CALL INSTRUCTION
%********************************************************************
MON:      A,4 ALUD,NONE
          IDBS,BMG COMM,SMPID T,NEXT T,POP CYCL,FAST;
          A,16 B,T ALUD,NONE
          IDBS,GPR,SEXT COMM,EWRF T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
%********************************************************************
% LOAD WRITABLE CONTROL STORE INSTRUCTION
%********************************************************************
LDWCS:    B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          IDBS,DSABL T,JMP T,PUSH SLWCS CYCL,WAIT
          7400;
%********************************************************************
%********************************************************************
% PIONF (1504XX) - GROUP OF INSTRUCTIONS
%********************************************************************
PIONF:    ALUF,PASSD ALUD,Q
          IDBS,STS T,JMP0-3 T,HOLD CYCL,FAST
          VECT1;
%********************************************************************
% DIFFERENT PIONF-ROUTINES, ENTERED FROM VECTOR
%********************************************************************
% IOF
IOF2:     PIC,IOF ALUD,NONE
          COMM,EPIC T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% POF
POF2:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDPIL T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% ION
ION2:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDPIL T,NEXT T,HOLD CYCL,SLOW;
          PIC,ION ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,FAST
          CHKIT;
%********************************************************************
% EXAM - INSTRUCTION
EXAM2:    A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          EXPHY;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          B,T ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          EXMO3;
%********************************************************************
% DEPO - INSTRUCTION
DEPO2:    A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          EXPHY;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          EXMO3;
%********************************************************************
% SUBROUTINE USED BY EXAM & DEPO TO SET PHYSICAL EXAMINE MODE
EXPHY:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDIR T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150122;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE USED BY EXAM & DEPO
% MOPC-SPECIFIED ONE
EXMO3:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,WAIT
          150121;
          AB,EXMOD ALUD,NONE
          IDBS,REG COMM,XMM T,JMP T,POP CYCL,SLOW
          USGPR;
%********************************************************************
%********************************************************************
% TRA-INSTRUCTION (1500XX)
%********************************************************************
TRA:      ALUD,NONE
          IDBS,ALU T,JMP0-3 T,POP
          VECT2;
%********************************************************************
% TRA-ROUTINES, ENTERED FROM VECTOR
%********************************************************************
% TRA PID
APID1:    PIC,RSTS B,R5 ALUF,PASSD ALUD,B
          IDBS,PIC COMM,EPIC T,NEXT T,HOLD CYCL,FAST
          COND,IRQ F,JMP F,HOLD;
          PIC,LOSTS B,10 ALUF,ZERO ALUD,Q
          IDBS,BARG COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
          PIC,ION B,R6 ALUF,INVD ALUD,B
          IDBS,BMG COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
          PIC,LMSK B,R6 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
          AB,IIE ALUF,PASSD ALUD,B
          IDBS,REG COMM,CLIRQ T,NEXT T,HOLD CYCL,FAST;
          A,17 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          APID2 CONDENABL;
          A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
APID2:    B,5 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,4 B,R3 ALUF,INVD ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
          PIC,LMSK B,R2 ALUF,INVB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,PUSH CYCL,FAST
          APID3;
          PIC,LMSK B,R3 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,FAST
          APID3 CONDENABL;
          ALUF,ORDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
APID3:    PIC,LOSTS B,10 ALUD,NONE
          IDBS,BARG COMM,EPIC T,NEXT T,HOLD
          COND,LC=0;
          B,R3 ALUF,PASSB ALUM,FMU ALUD,SRB
          IDBS,ALU COMM,CLIRQ T,NEXT T,POP LCOUNT
          COND,IRQ F,JMP F,HOLD;
          AB,PID ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          PIC,LOSTS B,R5 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,NONE
          IDBS,STS T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          PIC,LMSK B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,FAST
          APIE1 CONDENABL;
APID4:    PIC,IOF ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,FAST
          APIE1;
%********************************************************************
% TRA IIC
AIIC1:    PIC,RMSK B,R6 ALUF,PASSD ALUD,B
          IDBS,DSABL COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
          AB,IIE ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          37760;
          PIC,LMSK ALUF,INVQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          25;
          PIC,ION B,13 ALUF,PASSD ALUD,B
          IDBS,BARG COMM,EPIC T,NEXT T,PUSH CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          PIC,LOSTS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,POP CYCL,FAST
          AIIC3 CONDENABL;
          A,R3 ALUF,A-Q ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,HOLD;
          ALUF,Q-1 ALUD,Q
          IDBS,ALU COMM,CLIRQ T,NEXT T,POP CYCL,FAST
          CONDENABL COND,IRQ F,NEXT F,HOLD;
          ALUF,ZERO ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          AIIC2;
AIIC3:    ALUF,Q-D ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          12;
          A,16 ALUD,NONE
          IDBS,BMG COMM,SMPID T,NEXT T,HOLD CYCL,FAST;
AIIC2:    PIC,LOSTS B,R5 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,PUSH CYCL,FAST
          CLR14;
          ALUF,PASSD ALUD,NONE
          IDBS,STS T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          PIC,LMSK B,R6 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,FAST
          APID4 CONDENABL;
%********************************************************************
% TRA PIE
APIE1:    B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
% TRA PVL
APVL1:    B,A ALUF,ORDQ ALUD,B
          IDBS,ARG T,RETURN T,HOLD CYCL,FAST
          153602;
%********************************************************************
% TRA ALD
AALD1:    ALUD,NONE
          IDBS,ALU T,JMPALD T,PUSH
          ALDVC;
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,HOLD;
%********************************************************************
% TRA PANS
AIR16:
AIR17:
APANS:    B,0 ALUF,D-1 ALUD,Q
          IDBS,BARG T,JMP T,HOLD
          AMM2;
%********************************************************************
% TRA PGC (PAGING CONTROL REG.)
APGC1:    B,R6 ALUF,PASSD ALUD,B
          IDBS,STS T,JMP T,PUSH
          PLPCR;
          ALUF,PASSD ALUD,Q
          IDBS,MMR T,NEXT T,HOLD CYCL,SLOW;
          A,R7 B,A ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          7773;
%********************************************************************
% SUBROUTINE FOR TRA PGC AND TRR PCR
PLPC2:    A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDPIL T,JMP T,HOLD CYCL,SLOW
          PRFCH;
%********************************************************************
% TRR PCR
RPCR1:    B,R6 ALUF,PASSD ALUD,B
          IDBS,STS T,JMP T,PUSH
          PLPCR;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PLPC2;
%********************************************************************
% TRA PGS
APGS1:    A,R6 ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          1777;
%********************************************************************
% SUBROUTINE FOR TRA ANY MEMORY MANAGEMENT REGISTER
AMM2:     ALUD,NONE
          IDBS,GPR COMM,LDIR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;  % WAIT-TIME FOR MMM
          B,A ALUF,ANDDQ ALUD,B
          IDBS,MMR T,JMP T,HOLD CYCL,SLOW
          PRFCH;
%********************************************************************
% TRA CSR
ACSR1:    B,7 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,HOLD
          AMM2;
%********************************************************************
% SUBROUTINE FOR TRR PCR AND TRA PGC
PLPCR:    B,2 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD;
          A,A B,R5 ALUF,PASSA ALUD,SLB
          IDBS,GPR COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          B,R5 ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,POP LCOUNT;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDPIL T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% TRR INSTRUCTIONS (1501XX)
%********************************************************************
TRR:      B,A ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP0-3 T,POP
          VECT3;
%********************************************************************
% TRR ROUTINES, ENTERED FROM VECTOR
%********************************************************************
% TRR IIE
RIIE1:    ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7774;
          B,R1 ALUF,ORDQ ALUD,SLB
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          10000;
          PIC,RMSK B,R2 ALUF,INVD ALUD,B
          IDBS,DSABL COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
          AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,R1 ALUF,A+B ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          NOTI2 CONDENABL;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          100017;
          A,R6 B,R2 ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,R2 ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          PIC,LMSK B,R2 ALUF,INVB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
NOTI2:    AB,IIE ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
% TRR PIE
RPIE1:    ALUF,PASSD ALUD,Q
          IDBS,SWAP T,JMP T,PUSH
          PICFM;
          A,Z B,STS ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R1 ALUF,ANDDA ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          100017;
          A,STS ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,IIE ALUF,ANDDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,R1 ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          PIC,LMSK B,R1 ALUF,INVB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,FAST
          CHKIT;
%********************************************************************
% TRR PID
RPID1:    ALUF,PASSD ALUD,Q
          IDBS,SWAP T,JMP T,PUSH
          PICFM;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          140017;
          A,Z B,R1 ALUF,MASKAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH
          CLRXX;
          A,Z ALUF,ANDAQ ALUD,NONE
          IDBS,ALU COMM,SMPID T,JMP T,HOLD CYCL,FAST
          CHKIT;
%********************************************************************
% TRR LMP
RLMP1:    AB,LMP ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,HOLD;
%********************************************************************
% TRR MEMORY MANAGEMENT INTERNAL REGISTER
RIR4:
RCIU1:
RCIL1:
RCCL1:
RIR13:
RIR14:
RIR16:
RIR17:    ALUD,NONE
          IDBS,GPR COMM,LDIR T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PRFCH;
%********************************************************************
% TRR ECCR, USES IOX - NUMBER 100115
RECC1:    B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          100115;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          IOXX1;
%********************************************************************
% SENDS OUT NEW PREFETCH REQUEST IN CASE TRA OR TRR HAS DESTROYED PREFETCH
PRFCH:    A,P ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,FETCH COMM,RDRQ T,RETURN T,HOLD;
%********************************************************************
% TRR PANC
RPANC:    ALUD,NONE
          IDBS,GPR COMM,LDIR T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,SWAP COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,SWAP COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PRFCH;
%********************************************************************
%********************************************************************
% WAIT INSTRUCTION
%********************************************************************
WAIT:     ALUF,PASSD ALUD,NONE
          IDBS,STS T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,WAIT
          STOPW CONDENABL;
%********************************************************************
% INTERRUPT IS ON
          B,17 ALUF,ANDDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% REMOVE CURRENT PID-BIT
          B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          A,LC ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,16 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,PID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          WT14 CONDENABL;
%********************************************************************
% NOT ON LEVEL 14
          A,R1 B,12 ALUF,A-D ALUD,Q
          IDBS,BARG T,NEXT T,HOLD
          COND,F15 F,NEXT F,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          CHKIT CONDENABL;
%********************************************************************
% ON LEVEL 10-15 (EXCEPT 14)
          B,4 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F15 F,NEXT F,HOLD;
          A,LC ALUF,PASSD ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          W1013 CONDENABL;
%********************************************************************
% ON LEVEL 15
          A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
W1013:    PIC,MCLPID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
%********************************************************************
% ROUTINE TO CHECK WHICH INTERRUPT LEVEL SHOULD BE ENTERED
%********************************************************************
CHKIT:    PIC,LOSTS B,10 ALUD,NONE
          IDBS,BARG COMM,EPIC T,NEXT T,HOLD CYCL,FAST
          COND,IRQ F,NEXT F,HOLD;
          AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG COMM,CLIRQ T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,NONE
          IDBS,STS T,RETURN T,HOLD CYCL,FAST
          CONDENABL COND,F15 F,RETURN F,HOLD;
%********************************************************************
% NO HARDWARE INTERRUPT REQUEST IS PENDING
          AB,PIE ALUF,ANDDQ ALUD,SLB
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          CONDENABL COND,F11;
%********************************************************************
% CPU IS IN ION
          ALUF,PASSD
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST
          100013;
%********************************************************************
% LOOP TO FIND HIGHEST ENABLED LEVEL
          B,R3 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,LC ALUF,PASSD ALUD,Q  % NEW LEVEL -> Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          PLINT;
%********************************************************************
% THE WAIT-INSTRUCTION WAS ON LEVEL 14
WT14:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          40000;
          PIC,MCLPID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,FAST
          CHKIT;
%********************************************************************
%********************************************************************
% HARDWARE INTERRUPT HANDLING (EXT. OR INT. INTERRUPTS)
% ENTERED FROM INTERRUPT VECTOR (3740-3757)
%********************************************************************
% INTERNAL INTERRUPTS
EXT14:    B,P ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          27;
          A,16 ALUD,NONE
          IDBS,BMG COMM,SMPID T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% ONLY LEVEL 15 IS HIGHER THAN STATUS 27
          PIC,LOSTS ALUD,NONE
          IDBS,GPR COMM,EPIC T,JMP T,HOLD CYCL,FAST
          PLINT;
%********************************************************************
% HARDWARE INTERRUPT EXCEPT LEVEL 14
XINT:     B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% LEVEL IN Q SHOULD BE ENTERED
PLINT:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          PLV0 CONDENABL;
%********************************************************************
% NEW LEVEL IS NOT LEVEL 0, UPDATE PID
          A,LC ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          AB,PID ALUF,ORDQ ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          AB,PID ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
PLV0:     A,PIL ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,LC ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,HOLD;
          ALUF,ANDDQ ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          140000 CONDENABL;
%********************************************************************
% NEW LEVEL IS UNEQUAL TO OLD LEVEL
          A,LC ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,COND F,JMP F,HOLD;
          A,PIL B,R5 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          LVSWP CONDENABL;
%********************************************************************
% OLD LEVEL IS NOT 14 OR 15
          AB,PVL ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% CHANGE LEVEL ROUTINE. Q = NEW LEVEL
LVSWP:    AB,ACTLV ALUF,ORDQ ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          7;
          B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          A,PIL B,LC ALUF,PASSB ALUD,Q  % SAVE LOOP
          IDBS,ALU COMM,EWRF T,NEXT T,POP LCOUNT CYCL,FAST;
          B,Z ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          170000;
          A,Z B,R6 ALUF,ORAB ALUD,NONE
          IDBS,ALU COMM,LDPIL T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          7;
          AB,ACTLV ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,PUSH CYCL,FAST;
          A,PIL B,LC ALUF,PASSD ALUD,B  % UNSAVE LOOP
          IDBS,REG T,NEXT T,POP LCOUNT CYCL,FAST;
          A,Z ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD
          INIT;
% SUBROUTINE TO CLEAR INTERNAL INTERUPTS
CLR14:    B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          37760;
CLRXX:    PIC,MCLPID B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE USED BY TRR PID AND TRR PIE TO TRANSLATE TO PIC-FORMAT
PICFM:    B,Z ALUF,ANDDQ ALUD,SRB
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          74;
          A,7 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,6 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          PICF2 CONDENABL;
          A,0 B,Z ALUF,ORDA ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,COND F,NEXT F,HOLD;
PICF2:    B,Z MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          0 CONDENABL;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          77760;
          A,Z B,Z ALUF,ORAQ ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE USED BY E-COMMAND & MACL TO SET OUT EXAMINE MODE
EXMO2:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          AB,EXMOD ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          B,15 ALUD,NONE
          IDBS,BARG COMM,XMM T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% MASTER CLEAR ROUTINE
%********************************************************************
MACL:     ALUF,PASSD ALUD,Q
          IDBS,ARG COMM,SIOC T,NEXT T,HOLD CYCL,SLOW
          30120;
          ALUF,PASSD ALUD,Q  % STOP
          IDBS,STS COMM,SSTOP T,JMP T,PUSH CYCL,FAST
          PIOF;
          ALUF,ZERO ALUD,Q
          IDBS,ALU COMM,RSDA T,JMP T,PUSH CYCL,SLOW
          RIIE1;
          PIC,LOSTS B,10 ALUF,ZERO ALUD,Q  % 0 -> PIE
          IDBS,BARG COMM,EPIC T,JMP T,PUSH CYCL,FAST
          TRPIE;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177777;
% INITIALIZE MOPC VARIABLES
          AB,RONLY ALUF,PASSQ ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,CDIGI ALUF,PASSQ ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,PRCHR ALUD,NONE IDBS,ARG COMM,EWRF T,NEXT T,HOLD 443;
          PIC,LMSK ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,MAPJ T,HOLD CYCL,FAST;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,OCTAD ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,OCTA2 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,FAST
          SPAC2;
          AB,BPFLG ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,STS T,JMP T,PUSH
          REX;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150121;
          ALUF,ZERO ALUD,Q
          IDBS,ALU COMM,XMM T,JMP T,PUSH CYCL,SLOW
          EXMO2;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          SELFT;
%********************************************************************
% SELF-TEST PROGRAM FOR CPU
SELFT:    B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,PUSH
          400;
%********************************************************************
% TEST 1 : 0-1+1=0
ST1:      B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          B,R1 ALUF,B+1 ALUD,B
          T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF NOT 0 (400)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          STERR CONDENABL;
%********************************************************************
% TEST 2 : 0 + 1*5 = 5
ST2:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          1000;
          ALUF,ZERO ALUD,Q
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD
          3;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          COND,LC=0;
          ALUF,Q+1 ALUD,Q  % LOOP 5 TIMES
          IDBS,ALU T,NEXT T,POP LCOUNT;
          B,5 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF NOT 5 (1000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          STERR CONDENABL;
%********************************************************************
% TEST 3 : SHIFT DOUBLE LEFT
ST3:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          1400;
          B,3 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD
          COND,LC=0;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          70707;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,PUSH
          30303;
          B,R3 MIS,ROT ALUF,PASSB ALUD,SLD  % LOOP 5 TIMES
          IDBS,ALU T,NEXT T,POP LCOUNT;
          ALUF,Q-D ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          34346;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF Q ERRONEOUS (1400)
          B,R3 ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD
          STERR CONDENABL;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD
          14156;
%********************************************************************
% STER1 IF R3 ERRONEOUS (2000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          STER1 CONDENABL;
%********************************************************************
% TEST 4 : -1 -> R5, 0 -> Q
ST4:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          2400;
          AB,PVL ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177777;
          B,0 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF Q NOT 0 (2400)
          B,R5 ALUF,B+1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          STERR CONDENABL;
%********************************************************************
% STER1 IF R5+1 NOT 0 (3000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          STER1 CONDENABL;
%********************************************************************
% TEST 5 : 170(AARG) -> SWAP = 74000
ST5:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          3400;
          A,17 ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD
          74000;
% STERR IF NOT 74000 (3400)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          STERR CONDENABL;
%********************************************************************
% TEST 6 : LC USED TO GENERATE 1 AMONG 0'S.
% SHIFT RIGHT DOUBLE WITH SHIFT GPR.
ST6:      B,R2 ALUF,B+1 ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          4000;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD
          17;
          ALUF,PASSD ALUD,Q
          IDBS,ARG COMM,LDGPR T,NEXT T,PUSH
          100000;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          A,LC ALUF,Q-D ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,JMP F,POP;
%********************************************************************
% STERR IF BMG(LC) NOT CORRECT (4000)
          ALUF,Q-D ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD
          STERR CONDENABL;
%********************************************************************
% STER1 IF GPR NOT SHIFTED CORRECT (4400)
          B,R1 ALUF,PASSB ALUM,FMU ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD
          STER1 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,LC=0;
          ALUD,NONE  % LOOP BACK
          IDBS,PEA T,NEXT T,HOLD LCOUNT;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,LOAD;
%********************************************************************
% TEST 7 : TEST STS AND REGISTER FILE
ST7:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          5000;
          B,STS ALUD,NONE  % -1 -> REG.FILE
          IDBS,ARG COMM,EWRF T,NEXT T,HOLD
          177777;
          ALUF,ZERO ALUD,NONE STS,LO  % 0 -> STS
          IDBS,ALU COMM,LDPIL T,JMP T,PUSH CYCL,SLOW
          ST77;
          ALUF,PASSD ALUD,Q  % STS -> Q
          IDBS,STS T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD
          10000;
%********************************************************************
% STERR IF STS NOT 10000 (5000)
          A,17 B,STS ALUF,D+1 ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          STERR CONDENABL;
%********************************************************************
% STER1 IF REG.FILE NOT -1 (5400)
          A,17 B,STS ALUF,ZERO ALUD,NONE  % 0 -> REG.FILE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD
          STER1 CONDENABL;
          A,17 B,STS ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% STER2 IF REG.FILE NOT 0 (6000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          STER2 CONDENABL;
          A,R7 ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU COMM,LDPIL T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,PUSH;
%********************************************************************
% TEST 8 : TEST OF PIC
ST8:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          6400;
          ALUD,NONE  % PID -> REG.FILE
          IDBS,ALU T,JMP T,PUSH
          TAPID;
          A,17 B,STS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          ALUF,ZERO ALUD,Q  % 0 -> PID
          IDBS,ALU T,JMP T,LOAD
          TRPID;
          ALUD,NONE  % 176000 -> PID
          IDBS,ARG COMM,SMPID T,NEXT T,HOLD
          140017;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          TAPID;
          ALUF,D-Q ALUD,Q  % CHECK PID
          IDBS,ARG T,NEXT T,POP
          176000;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF PID NOT 176000 (6400)
          A,17 B,STS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD
          STERR CONDENABL;
          B,R6 ALUF,ZERO ALUD,B  % REG.FILE -> PID
          IDBS,ALU T,JMP T,PUSH
          TRPID;
          A,R7 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD
          MACL2;
%********************************************************************
% SUBROUTINE TO PLACE IDB HIGH
ST77:     ALUD,NONE
          IDBS,ARG T,RETURN T,POP
          177777;
%********************************************************************
% DISPLAY ERROR NO. R2+2
STER2:    A,R2 B,R2 ALUF,A+B ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          400;
%********************************************************************
% DISPLAY ERROR NO. R2+1
STER1:    A,R2 B,R2 ALUF,A+B ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          400;
%********************************************************************
% DISPLAY ERROR NO. R2
STERR:    B,R2 ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          DYTP2;
          ALUF,PASSQ ALUD,NONE  % LOOP ON ERROR
          IDBS,ALU COMM,LDPIL T,RETURN T,HOLD;
%********************************************************************
% LAST PART OF MASTER CLEAR ROUTINE
MACL2:    ALUF,PASSD ALUD,Q
          IDBS,ARG COMM,SIOC T,NEXT T,HOLD CYCL,SLOW
          30140;
          AB,STATUS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,MANIR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,TXT1 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,TXT2 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,SINGL ALUF,ZERO ALUD,Q
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          LVSWP;
%********************************************************************
%********************************************************************
% SUBROUTINE USED BY MOPC AND MACL TO CLEAR SEVERAL MOPC VARIABLES
%********************************************************************
SPAC2:    AB,DUMPF ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT;
          AB,SCRAM ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,OCTNR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,CURNR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,UPPNR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,OCTN2 ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,DEPOS ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,RETURN T,POP;
%********************************************************************
%********************************************************************
% STOP CPU. ENTERED FROM WAIT-INSTRUCTION. PRINT #
%********************************************************************
STOPW:    AB,PRCHR ALUD,NONE
          IDBS,ARG COMM,EWRF T,NEXT T,HOLD
          443;
%********************************************************************
%********************************************************************
% FROM INTERRUPT VECTOR IF THE CPU IS IN STOP (3760 OR 3770)
%********************************************************************
STOP:     AB,MACL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD
          STOP2 CONDENABL;
%********************************************************************
% STOP FOLLOWS DIRECTLY AFTER MASTER CLEAR. STAND-BY IS NOT OK
          A,R5 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          AB,MACL ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD
          STOP2 CONDENABL;
%********************************************************************
% PANEL IS LOCKED WHEN POWER-UP, OR LOAD IS PRESSED
ALDLO:    ALUD,NONE  % USE ALD-SWITCH
          IDBS,ALU T,JMPALD T,PUSH
          ALDVC;
%********************************************************************
% LOAD, $ OR &, LOAD CODE IN Q
LOAD1:    A,17 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,15 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD
          INIT CONDENABL;
%********************************************************************
% Q IS NOT 0
          A,7 B,STS ALUF,D-1 ALUD,B
          IDBS,BMG T,JMP T,HOLD
          ETLO1 CONDENABL;
%********************************************************************
%********************************************************************
% MASS STORAGE LOAD, BECAUSE BIT 13 IS 1
%********************************************************************
MASS:     A,1 B,D ALUF,D+Q ALUD,B  % DEV.NO. +2 -> D
          IDBS,BMG T,NEXT T,HOLD;
MAS1:     B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
%********************************************************************
% IOX N+1 (0) CORE ADDRESS
          A,D B,R1 ALUF,A-1 ALUD,B
          T,JMP T,PUSH CYCL,FAST
          IOXG;
%********************************************************************
% IOX N+1 (0) CORE ADDRESS
          A,D B,R1 ALUF,A-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH
          IOXG;
%********************************************************************
% IOX N+3 (0) BLOCK ADDRESS
          A,D B,R1 ALUF,A+1 ALUD,B
          IDBS,ALU T,JMP T,PUSH
          IOXG;
%********************************************************************
% IOX N+7 (2000) WORD COUNTER
          A,D B,R1 ALUF,D+A ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          5;
          A,12 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH
          IOXG;
%********************************************************************
% IOX N+5 (4) ACTIVATE DEVICE
          A,D B,R1 ALUF,D+A+1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
          A,2 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH
          IOXG;
%********************************************************************
% IOX N+4 READ STATUS
MAS2:     A,D B,R1 ALUF,D+A ALUD,B
          IDBS,BMG T,JMP T,PUSH
          IOXG;
          A,A B,4 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,2 B,R7 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD
          MAS2 CONDENABL;
%********************************************************************
% DEVICE FINISHED
          A,A B,R7 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          MAS1 CONDENABL;
%********************************************************************
% NO ERRORS, START IN 0, AND LEAVE MOPC
          B,P ALUF,ZERO ALUD,B
          IDBS,ALU COMM,START T,JMP T,HOLD
          ESCAP;
%********************************************************************
%********************************************************************
% RESTART, ENTERED FROM INTERRUPT VECTOR (3766)
% ONLY IF STAND-BY POWER IS OK, OR RESTART BUTTON PRESSED
%********************************************************************
RSTRT:    ALUF,PASSD ALUD,Q
          IDBS,IOR COMM,CLRTC T,NEXT T,HOLD
          COND,STP F,RETURN F,POP;
          A,15 ALUF,ANDDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD
          CONDENABL COND,F=0 F,JMP F,HOLD;
%********************************************************************
% ONLY IF IN STOP MODE
          AB,MACL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          RSTR1 CONDENABL;
%********************************************************************
% IF LOCKED
          AB,MACL ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMPALD T,PUSH
          ALDVC;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F15 F,NEXT;
%********************************************************************
% LOAD IF BIT 15=1, START IN ADDRESS 20 IF BIT 15=0
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          LOAD1 CONDENABL;
%********************************************************************
% START CPU IN ADDRESS 20
RSTR2:    A,2 B,P ALUF,PASSD ALUD,B
          IDBS,AARG T,JMP T,HOLD
          CONT;
%********************************************************************
% IF UNLOCKED, DO NOTHING JUST AFTER MASTER CLEAR, ELSE START IN 20
RSTR1:    AB,MACL ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD
          INIT CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          RSTR2;
%********************************************************************
%********************************************************************
% LOAD BUTTON IS PRESSED, ENTERED FROM INTERRUPT VECTOR (3764 OR 3774)
%********************************************************************
LOAD:     ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,STP F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          ALDLO CONDENABL;
%********************************************************************
%********************************************************************
% CPU IS NOT IN STOP WHEN LOAD IS PRESSED, OR
% CONTINUE BUTTON IS PRESSED, ENTERED FROM INTERRUPT VECTOR (3765 OR 3775)
%********************************************************************
CONT:     ALUD,NONE
          IDBS,ALU COMM,START T,JMP T,HOLD
          ESCAP;
%********************************************************************
%********************************************************************
% $ OR & IS TYPED TO MOPC
%********************************************************************
DOLOA:
ETLOA:    AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
% USE ALD-SWITCH IF NO OCTAL NUMBER GIVEN
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          ALDLO CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          LOAD1;
%********************************************************************
%********************************************************************
% BINARY LOADER. LOAD CODE BIT 13 IS 0.
%********************************************************************
ETLO1:    B,D ALUF,PASSQ ALUD,B  % DEV.NO. -> D
          IDBS,ALU T,JMP T,PUSH
          DVACT;
SEEK:     A,R5 B,P ALUF,PASSA ALUD,B  % POSSIBLE S.A.
          IDBS,ALU T,NEXT T,HOLD;
SIKI:     A,5 B,L ALUF,D+1 ALUD,B  % READ OCTAL NO.
          IDBS,BMG T,JMP T,PUSH
          ASS8;
          A,R2 B,15 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,L ALUF,A-B ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          SEEK CONDENABL;
%********************************************************************
% LAST CHAR. IS NOT CR
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          EXFOU CONDENABL;
%********************************************************************
% LAST CHAR. IS NOT !
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          SIKI;
%********************************************************************
% EXCLAMATION MARK (!) FOUND
EXFOU:    A,STS B,STS ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          B,L ALUF,ZERO ALUD,B  % READ CORE ADDR.
          IDBS,ALU T,JMP T,PUSH
          BIN;
          A,Z B,X ALUF,PASSA ALUD,B  % READ WORD COUNT
          IDBS,ALU T,JMP T,PUSH
          BIN;
          A,Z B,T ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
%********************************************************************
% LOOP TO STORE PROGRAM IN MEMORY
STLP:     ALUD,NONE  % READ ONE WORD
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          BIN;
          B,T ALUF,B-1 ALUD,B  % DECR. WORD COUNT
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,X B,X ALUF,B+1 ALUD,B,YA  % INCR. CORE ADDR.
          IDBS,ALU MIS,PT COMM,WRRQ T,NEXT T,HOLD
          COND,COND F,JMP F,HOLD;
          A,Z B,L ALUF,A+B ALUD,B,YA  % ACCUMULATE CH.SM.
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          STLP CONDENABL;
%********************************************************************
% ALL WORDS ARE PLACED IN MEMORY
          ALUD,NONE  % READ CHECKSUM
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          BIN;
          A,Z B,L ALUF,XORAB ALUD,NONE  % TEST CH.SM.
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          ILLEG CONDENABL;
%********************************************************************
% CHECKSUM OK, READ ACTION CODE
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          ASS8;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          ESCAP CONDENABL;
%********************************************************************
% ACTION CODE =0, START PROGRAM
          ALUD,NONE
          IDBS,ALU COMM,START T,JMP T,HOLD
          ESCAP;
%********************************************************************
% SUBROUTINE FOR BINARY LOADER TO READ ONE CHARACTER
INCH:     A,D B,R1 ALUF,D+A ALUD,B  % IOX N+2
          IDBS,BMG T,JMP T,PUSH
          IOXG;
          A,A B,10 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          INCH CONDENABL;
%********************************************************************
% READY FOR TRANSFER
          A,D B,R1 ALUF,PASSA ALUD,B  % IOX N
          IDBS,ALU T,JMP T,PUSH
          IOXG;
          A,A B,STS ALUF,ANDAB ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD
          DVACT;
%********************************************************************
% ACTIVATE DEVICE
DVACT:    B,A ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          4005;
          A,D B,R1 ALUF,D+A+1 ALUD,B  % IOX N+3 (4005)
          IDBS,BMG T,JMP T,HOLD
          IOXG;
%********************************************************************
% SUBROUTINE FOR BINARY LOADER TO READ OCTAL NUMBER, RETURNS ON NON-OCTAL CHAR
ASS8:     AB,OCTNR ALUF,ZERO ALUD,B
          IDBS,ALU COMM,EWRF T,JMP T,HOLD
          ASS81;
%********************************************************************
% OCTAL DIGIT FOUND
ASS82:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          OCDIG;
ASS81:    AB,OCTNR ALUF,PASSD ALUD,B  % READ CHARACTER
          IDBS,REG T,JMP T,PUSH
          INCH;
          A,STS B,R2 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD
          COND,F15 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          60;
          A,R2 B,R3 ALUF,A-Q ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R3 B,10 ALUF,A-D ALUD,NONE
          IDBS,BARG T,RETURN T,POP
          CONDENABL COND,F15 F,RETURN F,POP;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          ASS82 CONDENABL;
%********************************************************************
% SUBROUTINE USED BY BINARY LOADER TO READ TWO BYTES AS ONE 16-BIT WORD
BIN:      ALUD,NONE  % READ BYTE 1
          IDBS,ALU T,JMP T,PUSH
          INCH;
          ALUD,NONE  % SWAP BYTES
          IDBS,GPR T,NEXT T,HOLD;
          B,Z ALUF,PASSD ALUD,B
          IDBS,SWAP T,JMP T,PUSH
          INCH;
          A,Z B,Z ALUF,ORDA ALUD,B  % MAKE WORD
          IDBS,GPR T,RETURN T,POP;
%********************************************************************
%********************************************************************
% ENTERED FROM INTERRUPT VECTOR EVERY 20 MS
%********************************************************************
MS20:     B,10 ALUF,PASSD ALUD,Q
          IDBS,BARG COMM,CLRTC T,NEXT T,HOLD CYCL,FAST;
          AB,STATUS ALUF,ORDQ ALUD,Q
          IDBS,REG T,JMP T,PUSH
          WSIOC;
%********************************************************************
% TEST IF 20 MS CLOCK SHOULD ACTIVATE MOPC
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150040;
          ALUF,PASSD ALUD,NONE
          IDBS,MMR T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          MOPC CONDENABL;
%********************************************************************
% MOPC SHOULD BE DRIVEN BY PANEL REQUEST FROM MEMORY MANAGEMENT MODULE
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          INIT;
%********************************************************************
%********************************************************************
% PANEL REQUEST, ENTERED FROM INTERRUPT VECTOR (3762)
%********************************************************************
PRQ:      ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150040;
          ALUD,NONE
          IDBS,MMR T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
%********************************************************************
% MAIN ENTRY POINT OF MOPC
%********************************************************************
MOPC:
MRET1:    AB,PRCHR ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,FAST
          NOUTP CONDENABL;
%********************************************************************
% CHARACTER IS WAITING TO BE OUTPUTTED
          A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD
          OUTPT CONDENABL;
%********************************************************************
% OUTPUT STOPPED BY INPUT
          ALUD,NONE
          IDBS,ALU COMM,RSDA T,JMP T,HOLD CYCL,SLOW
          RONLY;
OUTPT:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT CONDENABL;
%********************************************************************
% UART READY FOR OUTPUT
          AB,PRCHR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,TBSTR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,D-Q ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD
          43;
%********************************************************************
% JUMP TO CR IF OUTPUTTED CHAR. WAS #
          B,12 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,JMP T,HOLD
          CR CONDENABL;
%********************************************************************
% JUMP TO LFEED IF OUTPUTTED CHAR. WAS LF
          AB,PRCHR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD
          LFEED CONDENABL;
          AB,CDIGI ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          OUTP1 CONDENABL;
%********************************************************************
% THERE ARE MORE CHARACTERS LEFT TO BE PRINTED IN ONE OCTAL NUMBER
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          AB,CDIGI ALUF,Q-1 ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          SPAC3 CONDENABL;
%********************************************************************
% GET NEXT DIGIT
          AB,NUMBR MIS,ROT ALUF,PASSD ALUM,MIC ALUD,SLB
          IDBS,REG T,NEXT T,HOLD;
          AB,NUMBR MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,NUMBR MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,NUMBR ALUF,PASSB ALUD,Q
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7;
          ALUF,D+Q ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          60;
%********************************************************************
% PLACE IT IN PRCHR
PRICH:    AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          2036;
%********************************************************************
% GET SPACE, WHICH IS THE LAST CHAR. IN AN OCTAL NUMBER
SPAC3:    A,5 ALUF,PASSD ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          PRICH;
%********************************************************************
% ONE OCTAL NUMBER IS FINISHED
OUTP1:    AB,DUMPF ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,CNT10 ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          2036 CONDENABL;
%********************************************************************
% WE ARE PRESENTLY INSIDE A DUMP COMMAND
          B,2 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          B,12 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          DUMP2 CONDENABL;
          AB,CURNR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          DMP10 CONDENABL;
%********************************************************************
% SOMETHING ELSE THAN MEMORY CONTENT SHOULD BE PRINTED IN THE DUMP NOW
DUMP2:    AB,CNT10 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          DUMP3;
%********************************************************************
% CNT10 = 0 , PRINT ADDRESS
DUMP4:    AB,CURNR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          PROCT;
          AB,CNT10 ALUF,D+1 ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          MRET3;
%********************************************************************
% NEXT OCTAL NUMBER SHOULD POSSIBLY BE PRINTED
DMP10:    AB,UPPNR ALUF,Q-D ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,PRCHR ALUF,ZERO ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SPACE CONDENABL;  % JUMP TO SPACE IF FINISHED WITH DUMP
%********************************************************************
% NOT FINISHED
          AB,SCRAM ALUD,NONE
          IDBS,REG COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% GET VALUE
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          DSPLY;
          AB,CURNR ALUF,D+1 ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% PRINT IT WITH PROCT
          AB,CURNR ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,FAST
          PROCT;
%********************************************************************
% INCREMENT CNT10, CONTROLLING THE NUMBER OF ADDRESSES PER LINE
MRET2:    AB,CNT10 ALUF,D+1 ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
MRET3:    AB,CNT10 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          2036;
DUMP3:    B,1 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
          DUMP5 CONDENABL;
%********************************************************************
% CNT10 = 1, PRINT /
DUMP6:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          57;
DMP61:    AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,CNT10 ALUF,D+1 ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          MRET3;
DUMP5:    B,12 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
          DUMP7 CONDENABL;
%********************************************************************
% CNT10 = 12, PRINT CR
DUMP8:    B,15 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          DMP61;
DUMP7:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          DUMP9 CONDENABL;
%********************************************************************
% CNT10 = 13, PRINT LF
DUMP9:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          412;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,CNT10 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          2036;
%********************************************************************
%********************************************************************
% NO OUTPUT IS WAITING TO GET OUT
%********************************************************************
% COPCM TO CHECK IF MOPC SHOULD USE TERMINAL INPUT
NOUTP:    A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,PUSH
          COPCM;
%********************************************************************
% MOPC USES TERMINAL INPUT
INPUT:    AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          A,6 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,PUSH
          WSIOC;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,NEXT T,HOLD;
          A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
% NO DATA AVAILABLE ?
          B,Z ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          DISPL CONDENABL;
%********************************************************************
% READ CHARACTER
          ALUF,ANDDQ
          IDBS,ARG COMM,RSDA T,NEXT T,HOLD CYCL,FAST
          177;
          B,R2 ALUF,PASSQ ALUD,B
          COMM,TBSTR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R5 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,PUSH CYCL,SLOW
          2132;
          B,R2 ALUF,PASSD
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          COMM,EWRF T,JMP T,HOLD CYCL,FAST
          20;
          ALUD,NONE
          T,RETURN T,POP CYCL,FAST
          CONDENABL COND,F15 F,NEXT F,POP;
          B,R1 ALUF,Q-D ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          60;
          A,R1 B,STS ALUF,A-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          2136 CONDENABL;
          ALUD,NONE
          T,JMP T,HOLD CYCL,FAST
          2301 CONDENABL;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          101;
          B,R5 ALUF,ZERO ALUD,B
          T,JMP T,HOLD CYCL,FAST
          2142 CONDENABL;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          132;
          ALUD,NONE
          T,JMP T,HOLD CYCL,FAST
          2314 CONDENABL;
          A,T ALUF,Q-D
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,L ALUF,D+Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          2306 CONDENABL;
          B,R5 ALUF,D+Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          2410 CONDENABL;
          B,A ALUF,D+Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          2553 CONDENABL;
          B,R7 ALUF,D+Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          2415 CONDENABL;
          B,A ALUF,Q-D
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          ESCAP CONDENABL;
          A,7 B,R1 ALUF,Q-D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          SPACE CONDENABL;
%********************************************************************
% OTHER CHARACTERS ONLY LEGAL IN STOP, AND WITHOUT LETTERS IN FRONT
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          STTS0;
          B,1 ALUF,Q-D ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,R1 ALUF,PASSB ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW EXCL CONDENABL;
          B,1 ALUF,Q-D ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW ZCHAR CONDENABL;
          B,1 ALUF,Q-D ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW QUOTE CONDENABL;
          B,1 ALUF,Q-D ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW CROSS CONDENABL;
          B,2 ALUF,Q-D ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW DOLOA CONDENABL;
          B,10 ALUF,Q-D ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW 1752 CONDENABL;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,FAST DOT CONDENABL;
%********************************************************************
% ILLEGAL MOPC CONDITION, PRINT ?
ILLEG:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          77;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          RONLY;
%********************************************************************
% RETURN IF MOPC INPUT IS ACTIVE
COPCM:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          CONDENABL COND,STP F,NEXT F,HOLD;
%********************************************************************
% INPUT IF STOP
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INPUT CONDENABL;
%********************************************************************
% REFRESH DISPLAY IF MOPC IS IDLE
DISPL:    AB,DISPL ALUD,NONE
          IDBS,REG COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% SEND DATA TO DISPLAY PROCESSOR
          AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          DSPLY;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
%********************************************************************
%********************************************************************
% SUBROUTINE TO SEND DATA TO OPTIONAL DISPLAY. LC = DISPLAY TYPE. Q = ADDRESS
%********************************************************************
DSPLY:    A,LC ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMPAOPR T,HOLD CYCL,FAST
          VECT4;
%********************************************************************
% LC=0, MEMORY EXAMINE
EXAMI:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150122;
          AB,OCTA2 ALUF,PASSD ALUD,B
          IDBS,REG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          B,10 ALUD,NONE
          IDBS,BARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTA2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,PUSH CYCL,SLOW
          DYDAT;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          DYDAT;
%********************************************************************
% LC=1, REGISTER EXAMINE
VC41:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          VC411;
          A,A ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,POP CYCL,FAST;
OPAST:    A,R7 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          DYTP1;
%********************************************************************
% USE IRR-ROUTINE
VC411:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          IRR;
%********************************************************************
% LC=2, AUXILIARY REGISTER EXAMINE
VC42:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,REG B,LC ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          DYTP1;
%********************************************************************
% LC = 3 : INTERNAL REGISTER EXAMINE
VC43:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          C431;
          A,A ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          OPAST;
%********************************************************************
% USE TRA-INSTRUCTION
C431:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          TRA;
%********************************************************************
% LC = 4 : BUS WATCH EXAMINE
VC44:     ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150023;
          AB,OCTA2 ALUF,PASSD ALUD,B
          IDBS,MMR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150022;
          ALUF,PASSD ALUD,Q
          IDBS,MMR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          B,13 ALUD,NONE
          IDBS,BARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTA2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          DYDAT;
%********************************************************************
% LC = 17 : ACTIVITY EXAMINE (ACTIVE LEVELS)
VC417:    AB,ACTLV A,PIL ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
          AB,ACTLV ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD
          DYTP2;
%********************************************************************
% SUBROUTINE TO SEND DATA FROM REGISTER EXAMINE TO MMM
DYTP1:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          B,11 ALUD,NONE
          IDBS,BARG COMM,XMM T,JMP T,PUSH CYCL,SLOW
          DYDAT;
          A,P ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          DYSWP;
%********************************************************************
% SUBROUTINE TO SEND Q AS TWO BYTES TO MMM
DYDAT:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
DYSWP:    ALUD,NONE
          IDBS,SWAP COMM,XMM T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO SEND ACTIVE LEVELS DATA TO MMM
DYTP2:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          B,12 ALUD,NONE
          IDBS,BARG COMM,XMM T,JMP T,HOLD CYCL,SLOW
          DYDAT;
%********************************************************************
% SUBROUTINE TO PRINT OCTAL NUMBER AS 6 DIGITS + SPACE
%********************************************************************
PROCT:    AB,NUMBR MIS,ROT ALUF,PASSQ ALUM,MIC ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,NUMBR ALUF,PASSB ALUD,Q
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          1;
          ALUF,D+Q ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          60;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          5;
          AB,CDIGI ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO CHECK THAT SCRAM = 0 AND STOP
%********************************************************************
STTS0:    AB,SCRAM ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          ILLEG CONDENABL;
%********************************************************************
% SUBROUTINE TO CHECK STOP
STTST:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,STP F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP
          ILLEG CONDENABL;
%********************************************************************
% SUBROUTINE TO SEND LABEL TO MMM
%********************************************************************
LABEL:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          B,16 ALUD,NONE
          IDBS,BARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          AB,TXT1 ALUD,NONE
          IDBS,REG COMM,XMM T,JMP T,PUSH CYCL,SLOW
          DYSWP;
          AB,TXT2 ALUD,NONE
          IDBS,REG COMM,XMM T,JMP T,HOLD CYCL,SLOW
          DYSWP;
%********************************************************************
% SUBROUTINE TO ASSEMBLE CHARACTERS AS LABELS FOR MMM
%********************************************************************
BUILD:    AB,TXT1 ALUF,PASSD ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          B,6 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          AB,TXT2 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,PUSH CYCL,FAST;
          AB,TXT1 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST
          LCOUNT;
          A,R2 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,TXT1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,TXT2 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO ASSEMBLE AN OCTAL NUMBER FROM A DIGIT
%********************************************************************
OCDIG:    AB,OCTN2 ALUF,PASSD ALUD,B
          IDBS,REG T,JMP T,PUSH
          BUILD;
OCDIX:    AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          B,R5 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD;
          B,R5 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD;
          B,R5 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          7;
          A,R2 B,R2 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,R2 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD;
          AB,OCTNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,OCTN2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,DEPOS ALUD,NONE
          IDBS,ARG COMM,EWRF T,RETURN T,POP;
%********************************************************************
%********************************************************************
% ROUTINES FOR DIFFERENT MOPC INPUT CARACTERS
%********************************************************************
% MOPC INPUT CHARACTER WAS 0-7
OCDI2:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          OCDIG;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          INIT;
%********************************************************************
% MOPC INPUT CHARACTER WAS ESCAPE
ESCAP:    AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          A,6 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,PUSH
          WSIOC;
%********************************************************************
% ROUTINE TO MAKE DEPOSIT ILLEGAL
RONLY:    AB,RONLY ALUD,NONE
          IDBS,ARG COMM,EWRF T,JMP T,HOLD
          SPACE;
%********************************************************************
% MOPC INPUT CHARACTER WAS SPACE OR @, RESET MOPC
SPACE:    AB,MANIR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,BPFLG ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,SINGL ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
%********************************************************************
% MOPC INPUT CHARACTER WAS . " Z PARTIALLY RESET MOPC
SPAC9:    AB,TXT1 ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,JMP T,PUSH SPAC2;
          AB,TXT2 ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,JMP T,HOLD INIT;
%********************************************************************
% MOPC OUTPUT CHARACTER WAS LF, PRINT #
LFEED:    AB,PRCHR ALUD,NONE
          IDBS,GPR COMM,EWRF T,JMP T,HOLD
          INIT;
%********************************************************************
% MOPC INPUT CHARACTER WAS A-Y, SCRAMBLE CHARACTERS
LETTR:    AB,SCRAM ALUF,PASSD ALUM,MIC ALUD,SLB
          IDBS,REG T,JMP T,PUSH
          BUILD;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          37;
          A,R2 B,R2 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,R5 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,SCRAM ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD
          INIT;
%********************************************************************
% ! TYPED, START PROGRAM
EXCL:     AB,SCRAM ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;
          AB,DEPOS ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU COMM,START T,JMP T,HOLD
          ESCAP CONDENABL;
          B,P ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ESCAP;
%********************************************************************
% # TYPED, MEMORY TEST
CROSS:
MEMOT:    B,A ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150122;
          AB,OCTNR ALUD,NONE
          IDBS,REG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
MM00:     B,D ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
MM0:      A,0 B,T ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
MM1:      B,R2 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
MM2:      A,B B,P ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
MM3:      A,P B,L ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          MM31 CONDENABL;
          A,T B,L ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          COND,COND F,JMP F,HOLD;
MM31:     A,D B,L ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          MM4 CONDENABL;
          A,P B,P ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD;
          A,L ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          MM41;
MM4:      A,P B,P ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          A,L ALUF,XORDA ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          MMERR CONDENABL;
MM41:     A,P B,X ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,HOLD;
          B,R2 ALUF,INVB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          MM3 CONDENABL;
          B,R2 ALUF,INVB ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          MM2 CONDENABL;
          A,T B,T ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          B,D ALUF,INVB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          MM1 CONDENABL;
          B,D ALUF,INVB ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          MM0 CONDENABL;
          B,A ALUF,INVB ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD
          443;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          MM00 CONDENABL;
          AB,PRCHR ALUD,NONE
          IDBS,GPR COMM,EWRF T,JMP T,HOLD
          RONLY;
MMERR:    B,D ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,L B,D ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD;
          B,T ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD
          ILLEG;
%********************************************************************
% " TYPED, SET READY FOR MANUAL INSTRUCTION
QUOTE:    AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          AB,BRKPT ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,MANIR ALUD,NONE
          IDBS,ARG COMM,EWRF T,JMP T,HOLD
          SPAC9;
%********************************************************************
% STOP-ROUTINE CONTINUED. CHECK FOR MANUAL INSTRUCTION (NOT USED BY MOPC)
MANIR:    AB,MANIR ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,BRKPT ALUD,NONE
          IDBS,REG COMM,LDGPR T,JMP T,HOLD
          INIT CONDENABL;
%********************************************************************
% DO MANUAL INSTRUCTION
          ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,JMP T,PUSH
          MANI1;
%********************************************************************
% POSSIBLE RETURN FROM INSTRUCTION
          ALUD,NONE
          IDBS,ALU T,MAPJ T,HOLD
          FETCH;
MANI1:    ALUD,NONE
          IDBS,GPR COMM,CLIRQ T,MAPJ T,HOLD
          FETCH;
%********************************************************************
% Z IS TYPED, MAKE READY FOR SINGLE INSTRUCTION
ZCHAR:    AB,BPFLG ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% ILLEGAL IF BREAKPOINT IS ACTIVE
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          SINIT CONDENABL;
%********************************************************************
% PERFORM ONE SINGLE INSTRUCTION IN Z OR BREAKPOINT MODE. USED BY STOP OR MOPC
SINGL:    A,P B,P ALUF,A+1 ALUD,B,YA
          IDBS,ALU MIS,FETCH COMM,RDRQ T,JMP T,PUSH CYCL,FAST
          SING1;
%********************************************************************
% POSSIBLE RETURN FROM INSTRUCTION
          PIC,RVECT B,P ALUF,B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,MAPJ T,HOLD CYCL,WAIT
          FETCH;
SING1:    ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% ALSO ENTERED FROM PAGE FAULTS & PROT. VIOLS. WHEN IN STOP
BRKZZ:    ALUD,NONE IDBS,ALU COMM,START T,NEXT T,HOLD;
          ALUD,NONE IDBS,ALU T,NEXT T,HOLD;
%********************************************************************
% EXECUTE SINGLE INSTR.
          PIC,RVECT ALUD,NONE
          IDBS,GPR COMM,SSTOP T,MAPJ T,HOLD CYCL,FAST
          FETCH;
%********************************************************************
% MULTIPLE SINGLE, USED BY MOPC ONLY
SINIT:    AB,SINGL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD
          SPAC9;
%********************************************************************
% ENTERED FROM INTERRUPT VECTOR, SINGLE BUTTON PRESSED
% ONLY LEGAL IN STOP
SING2:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,STP F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          SINGL CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          INIT;
%********************************************************************
% < TYPED
ANGBR:    AB,SCRAM ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          ILLEG CONDENABL;
          AB,CURNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,DUMPF ALUD,NONE
          IDBS,BARG COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          INIT;
%********************************************************************
% * TYPED
ASTRX:    AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          PROCT;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SPACE;
%********************************************************************
% MOPC JUST PRINTED # AFTER LNE WAS ENDED
CR:       AB,PRCHR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,DUMPF ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          AB,SCRAM ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          CR1 CONDENABL;
%********************************************************************
% DUMP SHOULD NOT BE STARTED
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          114;
          B,0 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD
          CR2 CONDENABL;
%********************************************************************
% IRD WRITTEN, TEST IF STOP
          B,3 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,PUSH
          STTST;
%********************************************************************
% SET UP FOR INTERNAL REGISTER DUMP
          AB,DUMPF ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,SCRAM ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          20;
          AB,UPPNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,CURNR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          DMP11;
%********************************************************************
% IRD NOT WRITTEN
CR2:      B,5 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          B,6 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          CR21 CONDENABL;
%********************************************************************
% E WRITTEN
          AB,DEPOS ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD
          CR22 CONDENABL;
%********************************************************************
% SET VIRTUAL EXAMINE
          A,2 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD;
%********************************************************************
% SEND EXAMINE MODE TO MMM
CR22:     ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150121;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,PUSH CYCL,SLOW
          EXMO2;
%********************************************************************
% SEND ONE Q-BYTE TO MMM
DYTP7:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          RONLY;
%********************************************************************
% E NOT TYPED, CHECK F
CR21:     ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          CR20 CONDENABL;
%********************************************************************
% F TYPED
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          B,17 ALUD,NONE
          IDBS,BARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUD,NONE
          IDBS,REG COMM,XMM T,JMP T,PUSH CYCL,SLOW
          DYSWP;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          RONLY;
%********************************************************************
% F NOT TYPED, CHECK MACL
CR20:     ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          176;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          CR3 CONDENABL;
%********************************************************************
% MACL TYPED
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MACL;
%********************************************************************
% MACL NOT TYPED, CHECK STOP
CR3:      ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          426;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          CR16 CONDENABL;
%********************************************************************
% STOP TYPED
          ALUD,NONE
          IDBS,ALU COMM,SSTOP T,JMP T,HOLD
          RONLY;
%********************************************************************
% NO SPECIAL CR FUNCTION. DEPOSIT OR NEXT MEMORY EXAMINE
CR16:     AB,DEPOS ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          CR4 CONDENABL;
%********************************************************************
% NOTHING TO DEPOSIT
          AB,SCRAM ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,DISPL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;  % ILLEGAL IF ANY LETTER HAS BEEN WRITTEN
          AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST
          RONLY CONDENABL;  % RONLY IF NOT MEMORY EXAMINE
%********************************************************************
% GET AND PRINT NEXT MEMORY ADDRESS
CR6:      AB,OCTAD ALUF,Q+1 ALUD,Q
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,FAST
          DSPLY;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          PROCT;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SPACE;
%********************************************************************
% SOMETHING TO DEPOSIT
CR4:      ALUF,D-Q ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          52;
%********************************************************************
% IF SCRAM IS UNEQUAL TO 'DEP', CHECK THAT SCRAM = 0 AND STOP
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          STTS0 CONDENABL;
          AB,RONLY ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          AB,WRTYP ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;  % DEPOSIT IS ILLEGAL NOW
          B,1 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          CR5 CONDENABL;
%********************************************************************
% MEMORY DEPOSIT
DEPOS:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150122;
          AB,OCTA2 ALUD,NONE
          IDBS,REG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG COMM,DERQ T,NEXT T,HOLD;
          AB,OCTNR ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          CR6;
CR5:      B,2 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          CR9 CONDENABL;
%********************************************************************
% REGISTER DEPOSIT, COMPARES WITH IRW
          AB,WRADR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,CLIRQ T,MAPJ T,JMP T,PUSH
          OPCRB;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD
          CR10 CONDENABL;
          B,DEST ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH
          CR10B;
          ALUF,PASSQ ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD
          RONLY;
CR10:     A,REG B,DEST ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH
          CR10B;
          A,REG B,Z ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD
          RONLY;
CR10B:    ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          377;
          B,DEST ALUF,PASSD ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP
          RONLY CONDENABL;
CR9:      ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          CR11 CONDENABL;
%********************************************************************
% AUXILIARY REGISTER DEPOSIT
          AB,WRADR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          A,3 B,R6 ALUF,ORDQ ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          A,REG B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          RONLY;
%********************************************************************
% INTERNAL REGISTER DEPOSIT
CR11:     A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CR12;
          A,R7 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          RONLY;
CR12:     AB,WRADR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% USE TRR
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TRR;
%********************************************************************
% DUMP SHOULD STARTED AFTER CR
CR1:      A,A ALUF,Q-D ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW
          CR13 CONDENABL;
%********************************************************************
% MEMORY DUMP
          AB,OCTNR ALUF,D+1 ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          AB,UPPNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          DMP11;
CR13:     ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          CR14 CONDENABL;
%********************************************************************
% REGISTER DUMP
          AB,OCTNR ALUF,D+1 ALUD,B
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          CR15;
          AB,SCRAM ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          DMP11;
CR14:     ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          125;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          ILLEG CONDENABL;
%********************************************************************
% REGISTER DUMP EXTENDED (AUXILIARY REGISTERS)
          AB,OCTNR ALUF,D+1 ALUD,B
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          CR15;
          AB,SCRAM ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% END OF DUMP SET-UP ROUTINES
DMP11:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          15;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,CNT10 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          INIT;
%********************************************************************
% SUBROUTINE COMMON FOR RD AND RDE
CR15:     AB,CURNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,PASSB ALUM,MIC ALUD,SLD IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,PASSB ALUM,MIC ALUD,SLD IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,CURNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,UPPNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,1 ALUF,PASSD ALUD,Q
          IDBS,BARG T,RETURN T,POP CYCL,FAST;
%********************************************************************
% / TYPED
SLASH:    AB,SCRAM ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,R1 ALUF,Q-D ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          RWX CONDENABL;
          CYCL,SLOW B,17 IDBS,BARG ALUF,Q-D ALUD,Q T,JMP T,HOLD IXX CONDENABL;
          CYCL,SLOW B,4 IDBS,BARG ALUF,D+Q ALUD,Q T,JMP T,HOLD XXX CONDENABL;
          CYCL,SLOW B,1 IDBS,BARG ALUF,D+Q ALUD,Q T,JMP T,HOLD TXX CONDENABL;
          CYCL,SLOW B,3 IDBS,BARG ALUF,D+Q ALUD,Q T,JMP T,HOLD SXX CONDENABL;
          CYCL,SLOW B,4 IDBS,BARG ALUF,D+Q ALUD,Q T,JMP T,HOLD PXX CONDENABL;
          CYCL,SLOW B,13 IDBS,BARG ALUF,D+Q ALUD,Q T,JMP T,HOLD LXX CONDENABL;
          CYCL,SLOW B,1 IDBS,BARG ALUF,Q-D ALUD,Q T,JMP T,HOLD AXX CONDENABL;
          CYCL,SLOW B,2 IDBS,BARG ALUF,Q-D ALUD,Q T,JMP T,HOLD BXX CONDENABL;
          CYCL,SLOW B,16 IDBS,BARG ALUF,Q-D ALUD,Q T,JMP T,HOLD DXX CONDENABL;
          B,3 ALUF,Q-D ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          RXX CONDENABL;
          B,R4 ALUF,Q-D ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          UXX CONDENABL;
          CYCL,SLOW B,3 IDBS,BARG ALUF,D+Q ALUD,Q T,JMP T,HOLD IOOPC CONDENABL;
          CYCL,SLOW A,12 IDBS,AARG ALUF,Q-D ALUD,Q T,JMP T,HOLD ACTX CONDENABL;
          CYCL,SLOW A,5 IDBS,AARG ALUF,D+Q+1 ALUD,Q T,JMP T,HOLD OPRX CONDENABL;
          IDBS,ALU ALUD,NONE T,JMP T,HOLD BUSX CONDENABL;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLEG;
%********************************************************************
% REGISTER NAMES/
SXX:      B,0 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
DXX:      B,1 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
PXX:      B,2 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
BXX:      B,3 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
LXX:      B,4 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
AXX:      B,5 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
TXX:      B,6 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
XXX:      B,7 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD REGXX;
REGXX:    B,R2 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH
          OCDIX;
%********************************************************************
% R/
RXX:      AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          TYP1;
TYP1:     A,0 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          RWY;
%********************************************************************
% I/
IXX:      AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
TYP3:     A,1 B,R1 ALUF,D+1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          RWY;
%********************************************************************
% MEMORY EXAMINE
RWX:      B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% REGISTER EXAMINE
RWY:      AB,OCTAD ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,WRADR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,OCTN2 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          AB,OCTA2 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          A,R1 ALUF,PASSA ALUD,Q
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          AB,WRTYP ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          RWZ;
%********************************************************************
% GET VALUE OF EXAMINE
RWZ:      AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,FAST
          DSPLY;
          AB,RONLY ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,FAST
          PROCT;
          AB,DISPL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          LABEL CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          SPACE;
%********************************************************************
% IO/ TYPED
IOOPC:    A,A B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,CLIRQ T,MAPJ T,NEXT T,HOLD;
          B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          AB,OPR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH
          IOXX1;
          A,A ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          PROCT;
          A,R4 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD
          RONLY;
%********************************************************************
% OPR/ TYPED
OPRX:     A,16 ALUF,D+1 ALUD,Q
          IDBS,AARG T,JMP T,HOLD
          TYP2;
%********************************************************************
% U/ TYPED
UXX:      ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          142;
TYP2:     A,1 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD
          RWY;
%********************************************************************
% ACTX/ TYPED
ACTX:     B,17 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH
          RONLY;
%********************************************************************
% BUS/ TYPED
BUSX:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150123;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          B,14 ALUD,NONE
          IDBS,BARG COMM,XMM T,JMP T,HOLD CYCL,SLOW
          DYTP7;
%********************************************************************
%********************************************************************
% COMMERCIAL INSTRUCTIONS
%********************************************************************
COMME:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          60;
          ALUF,ANDDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD;
          A,2 ALUF,XORDQ ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          T,NEXT T,HOLD
          ILLIN CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP0-3 T,HOLD CYCL,WAIT
          COBVC;
%********************************************************************
% SUBROUTINE TO REMEMBER IN R4 THE NUMBER OF WORDS TO FILL OR MOVE
LSET1:    A,R1 B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
%********************************************************************
% SUBROUTINE TO ADD TO X,T THE CONTENT OF R6, WHICH IS BYTE COUNT SHIFTED ROT 1
MBXS1:    A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD;
          A,R6 B,R4 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,13 ALUF,D-1 ALUD,Q
          IDBS,BMG T,NEXT T,HOLD;
          A,R6 B,R6 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R4 B,T ALUF,A+B ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD;
          A,R6 B,X ALUF,A+B ALUD,B CRY,C
          IDBS,ALU T,RETURN T,POP;
%********************************************************************
% SUBROUTINE TO WRITE R10 INTO LOCATION [R3]
WRDST:    A,R7 B,T ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          WRDS2 CONDENABL;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
WRDS3:    A,STS ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,RETURN T,POP CYCL,WAIT
          COND,IRQ F,NEXT F,HOLD;
WRDS2:    A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,WRRQ T,JMP T,HOLD CYCL,FAST
          WRDS3;
%********************************************************************
% SUBROUTINE TO READ LOCATION [R3] INTO R10
RDDST:    A,R7 B,T ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          RDDS2 CONDENABL;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
RDDS3:    B,STS ALUF,PASSD ALUD,B
          IDBS,DBR T,RETURN T,POP CYCL,WAIT;
RDDS2:    A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD CYCL,FAST
          RDDS3;
%********************************************************************
% SUBROUTINES TO CHECK THAT LAST PAGE NEEDED BY MOVE IS IN MEMORY
PFSRC:    A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD
          RDSRC CONDENABL;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          RDSRC CONDENABL;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          RDSRC;
PFDST:    A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD
          RDDST CONDENABL;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          RDDST CONDENABL;
          B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          RDDST;
%********************************************************************
% SUBROUTINE TO FILL LEFT BYTE OF [R3] WITH LEFT BYTE OF Q
BTL:      B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDDST;
          A,Z B,STS ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          WRDST;
          B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% ADJUST R5 AND R6 FOR BTL AND BTR
BTX:      B,R5 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO FILL RIGHT BYTE OF [R3] WITH RIGHT BYTE OF Q
BTR:      B,X ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDDST;
          A,Z B,STS ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          WRDST;
          A,17 B,R3 ALUF,B+1 ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
          A,T B,T ALUF,MASKDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          BTX;
%********************************************************************
%********************************************************************
% BYTE FILL INSTRUCTION  BFILL (140130)
%********************************************************************
BFILL:    A,16 B,R7 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7777;
          A,T B,R5 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          A,X B,R3 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          BFIL2 CONDENABL;
%********************************************************************
% FINISHED, OR 0 BYTES TO MOVE
          AB,SSAVE ALUD,NONE
          IDBS,STS COMM,EWRF T,NEXT T,HOLD;
          A,R5 B,R6 MIS,ROT ALUF,PASSA ALUD,SRB
          IDBS,ALU T,JMP T,PUSH
          MBXS1;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          170000;
          A,T B,T ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          AB,SSAVE ALUD,NONE STS,LO
          IDBS,REG T,NEXT T,HOLD;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          A,Z B,STS ALUF,MASKAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          BTL CONDENABL;  % LAST BYTE NOT ON WORD BOUNDARY -> BTL
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
BFIL2:    B,Z ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          A,Z B,A ALUF,ANDAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R2 ALUF,ORDQ ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          BTR CONDENABL;  % FIRST BYTE NOT ON WORD BOUNDARY -> BTR
          A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LSET1;
%********************************************************************
% LOOP TO STORE WORDS OF TWO BYTES EACH
BFLOO:    A,R2 B,STS ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          WRDST CONDENABL;
          B,R3 ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          BFILQ CONDENABL;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          BFLOO;
%********************************************************************
% INTERRUPT IS SENSED WHILE INSIDE LOOP
BFILQ:    A,R4 B,R1 ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD;
          A,X B,X ALUF,A+Q+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          B,R1 ALUF,Q+1 ALUD,SLB
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD
          170000;
          A,T B,T ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD;
          A,R5 B,R1 ALUF,A-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R1 B,T ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          INIT;
%********************************************************************
% SUBROUTINE TO MOVE RIGHT BYTE OF [R2] TO LEFT BYTE OF [R3]
RBTL:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDSRC;
          A,Z B,R4 ALUF,ANDDA ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,Z ALUF,MASKAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          BTL;
%********************************************************************
% SUBROUTINE TO MOVE LEFT BYTE OF [R2] TO LEFT BYTE OF [R3]
LBTL1:    B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
LBTL:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDSRC;
          A,Z B,STS ALUF,MASKAB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          BTL;
%********************************************************************
% SUBROUTINE TO MOVE LEFT BYTE OF [R2] TO RIGHT BYTE OF [R3]
LBTR:     B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          3243;
          ALUF,ANDDA
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,MASKAB ALUD,B
          T,JMP T,HOLD CYCL,FAST
          2720;
RBTR:     ALUD,NONE
          T,JMP T,PUSH CYCL,FAST
          3243;
          B,STS ALUF,ANDAB
          T,JMP T,HOLD CYCL,FAST
          2720;
MOVB9:    A,R4 ALUF,PASSD
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,D ALUF,ANDAQ ALUD,NONE
          T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          T,NEXT T,HOLD CYCL,FAST
          3105 CONDENABL;
          ALUD,NONE
          T,JMP T,HOLD CYCL,FAST
          3141;
MOVB:     A,T ALUF,PASSA
          T,NEXT T,HOLD CYCL,FAST;
          A,R4 B,T ALUF,MASKDQ ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          3007;
%********************************************************************
MOVBF:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          10000;
          A,T B,T ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
%********************************************************************
% COMMON PARTS OF MOVB AND MOVBF
% SET UP INITIAL REGISTERS
MOVB3:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7777;
          A,D B,R5 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,15 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
          A,T B,R1 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          A,T B,R6 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MINTD CONDENABL;
          A,14 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
          A,T B,R2 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          MOVB2 CONDENABL;
MINTD:    A,R5 B,R6 ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,14 B,R4 ALUF,INVQ ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD
          MOVB5 CONDENABL;
          A,R6 B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
MOVB5:    A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,R1 B,T ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          MOVB2 CONDENABL;
          A,R4 B,T ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R5 B,T ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R4 B,D ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R5 B,D ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
MOVB2:    A,10 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,WAIT;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,16 B,R7 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          MOVB9 CONDENABL;  % ZERO BYTES TO MOVE
%********************************************************************
% ENSURE THAT NECESSARY PAGES ARE IN MEMORY
          B,R2 ALUF,ZERO ALUM,FMU ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,A B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH
          PFSRC;
          A,X B,R3 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH
          PFDST;
          B,R2 ALUF,ZERO ALUM,FMU ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD;
          A,A B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH
          RDSRC;
          A,X B,R3 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH
          RDDST;
          A,A B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDSRC;
          A,X B,R3 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDDST;
%********************************************************************
% SELECT WAY THROUGH MOVE
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          MB1T4 CONDENABL;
MB5T8:    A,R5 B,R4 ALUF,A-1 ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          MB5T6 CONDENABL;
          A,A B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,JMP F,PUSH;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          MB7T CONDENABL;
%********************************************************************
% FORWARD ALIGNED, FIRST BYTE RIGHT
MB8:      A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          RBTR;
          B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH
          TTDCR;
          A,R1 B,D ALUF,MASKAB ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          FWLOO;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          MB21;
MB7T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          TOLAP;
          A,R5 B,STS ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,POP
          CONDENABL;
%********************************************************************
% BACKWARD ALIGNED, FIRST BYTE RIGHT
MB7:      A,STS B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD;
          A,STS B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LBTL1 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BWLOO;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,PUSH
          MBXBW;
          A,T B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RBTR;
MB71:     B,X ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R4 B,T ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
MB5T6:    A,A B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,JMP F,PUSH;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          MB5T CONDENABL;
%********************************************************************
% FORWARDS SWAP, FIRST BYTE RIGHT
MB6:      ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          FWEXL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          MB41;
MB5T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          TOLAP;
          A,R5 B,STS ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,POP
          CONDENABL;
%********************************************************************
% BACKWARD SWAP, FIRST BYTE RIGHT
MB5:      A,STS B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD;
          A,R4 B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MB51 CONDENABL;
          B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RBTL;
          A,R4 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BWEXQ;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MB52;
MB51:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BWEXL;
MB52:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          MBXBW;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          INIT;
MB1T4:    A,R5 B,R4 ALUF,A-1 ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          MB1T2 CONDENABL;
          A,A B,X ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,NEXT F,HOLD;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          MB3T CONDENABL;
%********************************************************************
% FORWARD SWAP, FIRST BYTE LEFT
MB4:      A,R1 B,T ALUF,MASKAB ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LBTR;
          A,R1 B,D ALUF,ORAB ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTDCR;
          A,R4 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          FWEXQ;
MB41:     B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH
          MBXFW;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          A,R1 ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          BTL CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
MB3T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          TOLAP;
          A,R5 B,STS ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,POP
          CONDENABL;
%********************************************************************
% BACKWARD SWAP, FIRST BYTE LEFT
MB3:      A,R4 B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,STS B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MB31 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BWEXL;
MB32:     B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          MBXBW;
          A,T B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R1 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          BTR;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MB71;
MB31:     B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RBTL;
          A,R4 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BWEXQ;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          MB32;
MB1T2:    A,A B,X ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,NEXT F,HOLD;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          MB1T CONDENABL;
%********************************************************************
% FORWARD ALIGNED, FIRST BYTE LEFT
MB2:      ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          FWLOO;
MB21:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          MBXFW;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          LBTL CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
MB1T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          TOLAP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,POP
          CONDENABL;
%********************************************************************
% BACKWARD ALIGNED, FIRST BYTE LEFT
MB1:      A,R4 B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          LBTL1 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          BWLOO;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          MBXBW;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          INIT;
%********************************************************************
% SUBROUTINE TO TEST ILLEGAL OVERLAP CF SOURCE AND DESTINATION
TOLAP:    A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,RETURN F,POP;
          ALUF,PASSD
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD
          10000 CONDENABL;
          A,D ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD;
          AB,SSAVE A,R3 B,R6 ALUF,ZERO
          IDBS,STS COMM,EWRF T,NEXT T,HOLD
          0 CONDENABL;
          A,17 B,R5 MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD;
          A,D ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD;
          A,R5 ALUF,A+Q ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD
          3777;
          A,R5 B,R6 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD;
          A,A B,R6 ALUF,A+B ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD;
          AB,SSAVE ALUD,NONE STS,LO
          IDBS,REG T,JMP T,PUSH
          OLAP1;
%********************************************************************
% RETURN HERE MEANS NO OVERLAP
          B,R5 MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD;
          B,1 ALUF,PASSD ALUD,Q
          IDBS,BARG T,RETURN T,POP
          COND,F=0 F,RETURN F,POP;
OLAP1:    A,X B,R6 ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          COND,CRY F,RETURN F,POP;
          A,14 B,R6 ALUF,PASSB ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD
          CONDENABL COND,F=0 F,NEXT F,HOLD;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD
          OXEQ6 CONDENABL;
%********************************************************************
% OVERLAP EXISTS, ILLEGAL IF  'MOVBF'
OVLAP:    A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,POP
          COND,F=0 F,JMP F,HOLD;
          A,14 B,R5 MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD
          MBERR CONDENABL;
          A,D B,D ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD;
          ALUF,ZERO ALUD,Q
          IDBS,ALU T,RETURN T,POP
          COND,F=0 F,RETURN F,POP;
OXEQ6:    A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,RETURN T,POP
          CONDENABL COND,F15 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP
          OVLAP CONDENABL;
%********************************************************************
% FORWARDS MOVE LOOP S INTERRUPTED
IRQFW:    A,R4 B,R1 ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,A B,A ALUF,A+Q+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,14 B,R1 ALUF,Q+1 ALUD,SLB
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,X B,X ALUF,A+Q+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          MOVB4 CONDENABL;
          A,R1 B,T ALUF,B-A ALUD,B
          T,JMP T,HOLD CYCL,FAST
          MOVB4;
%********************************************************************
% BACKWARDS MOVE LOOP IS INTERRUPTED
IRQBW:    A,R4 B,R1 ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R1 ALUF,Q+1 ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
MOVB4:    A,R1 B,D ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
%********************************************************************
% ILLEGAL OVERLAP IN MOVBF-INSTRUCTION
MBERR:    ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD
          30000;
          A,T B,T ALUF,MASKDA ALUD,B
          IDBS,GPR T,JMP T,HOLD
          INIT;
%********************************************************************
% SUBROUTINE TO ADJUST BYTE POINTERS WHEN FORWARDS MOVE IS FINISHED
MBXFW:    A,R5 B,R6 MIS,ROT ALUF,PASSA ALUD,SRB
          IDBS,ALU T,JMP T,PUSH
          MBXSR;
MOVB0:    A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,14 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          MBX1 CONDENABL;
MOVBX:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          147777;
          A,T B,T ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R5 B,T ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R5 B,D ALUF,B-A ALUD,B
          IDBS,ALU T,RETURN T,POP;
%********************************************************************
% SUBROUTINE TO ADJUST BYTE POINTERS WHEN BACKWARDS MOVE IS FINISHED
MBXBW:    B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          7777;
          A,T B,R6 MIS,ROT ALUF,ANDAB ALUD,SRB
          IDBS,ALU T,JMP T,PUSH
          MBXSR;
MBX1:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          147777;
          A,T B,T ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          170000;
          A,D B,D ALUF,ANDAQ ALUD,B
          IDBS,ALU T,RETURN T,POP;
%********************************************************************
% SUBROUTINE USED BY MBXFW AND MBXBW
MBXSR:    AB,SSAVE ALUD,NONE
          IDBS,STS COMM,EWRF T,JMP T,PUSH CYCL,FAST
          MBXS1;
          A,R4 B,D ALUF,A+B ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD;
          A,R6 B,A ALUF,A+B ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          167777;
          A,D B,D ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          AB,SSAVE ALUD,NONE STS,LO
          IDBS,REG T,RETURN T,POP;
%********************************************************************
% SUBROUTINE TO READ WORD [R2] INTO R10
RDSRC:    A,R7 B,D ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          RDSR2 CONDENABL;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
RDSR3:    B,STS ALUF,PASSD ALUD,B
          IDBS,DBR T,RETURN T,POP CYCL,WAIT;
RDSR2:    A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD CYCL,FAST
          RDSR3;
%********************************************************************
% SUBROUTINE TO INCREMENT R3
R3INC:    B,R3 ALUF,B+1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
%********************************************************************
% SUBROUTINE TO DECREMENT R3
R3DCR:    B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
%********************************************************************
% SUBROUTINE TO MOVE WORDS FORWARDS, BYTES ALIGNED
FWLOO:    A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          FWFST;
FWLO1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          RDSRC CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          WRDST;
          B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          IRQFW CONDENABL;
          B,R3 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          FWLO1;
%********************************************************************
% SUBROUTINE TO MOVE WORDS BACKWARDS, BYTES ALIGNED
BWLOO:    A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LSET1;
BWLO1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          RDSRC CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          WRDST;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          IRQBW CONDENABL;
          B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          BWLO1;
%********************************************************************
% SUBROUTINE TO MOVE WORDS FORWARDS, BYTES SWAPPED
FWEXL:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDSRC;
          A,Z B,STS ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% ALTERNATIVE ENTRY IF FIRST BYTE ALREADY PRESENT IN Q
FWEXQ:    B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LSET1;
FWEX1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          RDSRC CONDENABL;
          A,Z B,STS ALUF,ANDDA ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          WRDST;
          A,Z B,R6 ALUF,MASKAB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          IRQFW CONDENABL;
          B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          R3INC;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          FWEX1;
%********************************************************************
% SUBROUTINE TO MOVE BYTES BACKWARDS, BYTES SWAPPED
BWEXL:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          RDSRC;
          A,STS B,R2 ALUF,B-1 ALUD,B,YA
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,Z ALUF,ANDDA ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD;
%********************************************************************
% ALTERNATIVE ENTRY IF FIRST BYTE ALREADY PRESENT IN Q
BWEXQ:    A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LSET1;
BWEX1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST
          RDSRC CONDENABL;
          A,Z B,R6 ALUF,ANDDA ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,Z B,STS ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          WRDST;
          A,R6 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          IRQBW CONDENABL;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          R3DCR;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          BWEX1;
%********************************************************************
% SUBROUTINE TO MOVE WORDS ALIGNED FORWARDS AS LONG AS >10 ARE LEFT
% OPTIMIZED AGAINST SPEED
FWFST:    A,R1 B,7 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD
          COND,F15 F,NEXT F,HOLD;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD
          40;
          A,R1 B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP
          CONDENABL COND,F=0 F,JMP F,PUSH;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          COND,LC=0;
          A,PIL B,LC ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,LOAD LCOUNT
          FWLO2;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH
          COND,LC=0;
          A,PIL B,LC ALUF,PASSD ALUD,B
          IDBS,REG T,NEXT T,POP LCOUNT;
          A,R4 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,RETURN T,POP
          COND,F=0 F,JMP F,PUSH;
FWLO2:    A,R1 B,11 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F15 F,NEXT F,HOLD;
          A,R7 B,7 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDLC T,RETURN T,POP
          CONDENABL COND,F=0 F,RETURN F,HOLD;
          A,PIL B,D ALUF,ANDDQ ALUD,NONE
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          FWLO3;
          A,R2 B,R2 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,JMP T,HOLD
          FWLO5;
FWLO5:    B,LC ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,POP LCOUNT CYCL,WAIT
          LCOUNT;
          B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD
          COND,F=0 F,RETURN F,HOLD;
          A,PIL B,T ALUF,ANDDQ ALUD,NONE
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          FWLO4;
          A,R3 B,R3 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,WRRQ T,JMP T,HOLD
          FWLO6;
FWLO6:    B,LC ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,LC=0;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU COMM,CLIRQ T,NEXT T,POP LCOUNT CYCL,WAIT
          COND,IRQ F,JMP F,HOLD;
          B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,RETURN T,POP
          FWLO2 CONDENABL;
FWLO3:    ALUD,NONE
          IDBS,ALU T,NEXT T,LOAD
          CONDENABL COND,LC=0;
          A,R2 B,R2 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD
          FWLO5;
FWLO4:    ALUD,NONE
          IDBS,ALU T,NEXT T,LOAD
          CONDENABL COND,LC=0;
          A,R3 B,R3 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,PT COMM,WRRQ T,JMP T,HOLD
          FWLO6;
%********************************************************************
% TEST IF T-REG SHOULD BE DECREMENTED AFTER SINGLE BYTE MOVED BEFORE
% LOOPS ARE ENTERED.
TTDCR:    A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD;
          A,14 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP
          0 CONDENABL;
          B,T ALUF,B-1 ALUD,B
          IDBS,ALU T,RETURN T,POP;
%********************************************************************
%********************************************************************
% INSTRUCTIONS FOR BIG CORE-MAP HANDLING IN SINTRAN III
%********************************************************************
SINTR:    A,12 ALUF,D+1 ALUD,Q
          IDBS,AARG T,NEXT T,HOLD;
          A,T B,R7 ALUF,PASSA ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          EXPHY;
          A,X B,SRCE ALUF,D+A ALUD,Q
          IDBS,BARG T,JMP0-3 T,HOLD
          VCSI3;
LDA8:     B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          EXMO3;
LDX8:     B,X ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          EXMO3;
LDAD8:    B,D ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDA8;
LDB8:     ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          B,B ALUF,ORDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          77400;
          A,B B,B ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD
          EXMO3;
STA8:     A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          EXMO3;
STZ8:     ALUF,ZERO ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          EXMO3;
STAD8:    A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STA8;
%********************************************************************
%********************************************************************
% PLANC ENTER- AND LEAVE- ROUTINES
%********************************************************************
% 5INIT IN PLANC
5INIT:    A,P B,R1 ALUF,A+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          176;
          A,B B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRC;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          172;
          B,R7 ALUF,D+Q ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRB;
          ALUF,PASSD ALUD,Q
          IDBS,STS T,NEXT T,HOLD CYCL,WAIT;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          ALUF,XORDQ ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,0 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,P ALUF,A+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TSTAC CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          INIT;
%********************************************************************
% 5ENTR IN PLANC
ENTR:     B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          176;
          A,B B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,B B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRC;
          A,R2 B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          172;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRB;
TSTAC:    A,R7 B,R3 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,JMP F,POP;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          INIT CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          INIT;
ENTRC:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          B,L ALUF,B+1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,7 B,B ALUF,D+Q ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,R3 ALUF,A+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,B B,R3 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R6 B,R4 ALUF,A-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,WAIT;
ENTRB:    A,B B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R5 ALUF,D-A ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,WAIT;
          A,B B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,B B,R3 ALUF,A+Q ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,WAIT;
%********************************************************************
% 5LEAV AND ELEAV IN PLANC
ELEAV:    A,7 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,WAIT;
          A,B ALUF,A-Q ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,D-1 ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          173;
          A,B ALUF,A-Q ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
LEAV:     B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          177;
          A,B B,R1 ALUF,A-B ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,B ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R1 ALUF,A-1 ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,P ALUF,PASSD ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,POP CYCL,WAIT
          INIT;
%********************************************************************
%********************************************************************
% VECTOR FOR SINTRAN CORE-MAP INSTRUCTIONS
%********************************************************************
3460/
VCSI3:    ALUF,PASSQ ALUD,NONE
          COMM,IRDRQ T,JMP T,HOLD CYCL,FAST
          LDA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDX8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDAD8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDB8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STZ8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STAD8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STAD8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDX8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDAD8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          LDB8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STZ8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STAD8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD
          STAD8;
%********************************************************************
%********************************************************************
% VECTOR FOR DECODING OF  COMMERCIAL INSTRUCTIONS  (1401XX)
%********************************************************************
COBVC:    ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD BFILL;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD MOVB;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD MOVBF;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
% THE PRINTED LISTING (PROM 015XX) JUMPS TO 5INIT HERE; THE PROMS 3033S AND 3033E-CX JUMP TO ILLIN
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          ILLIN;
% THE PRINTED LISTING JUMPS TO ENTR HERE; THE PROMS JUMP TO ILLIN
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          ILLIN;
% THE PRINTED LISTING JUMPS TO LEAV HERE; THE PROMS JUMP TO ILLIN
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
% THE PRINTED LISTING JUMPS TO ELEAV HERE; THE PROMS JUMP TO ILLIN
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
%********************************************************************
%********************************************************************
% VECTOR TO DETERMINE ALD-VALUES
%********************************************************************
ALDVC:    ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP 0;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP 1560;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          20500;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          21540;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP 400;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP 1600;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          100000;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          101560;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          120500;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          121540;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          100400;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          101600;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          100000;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP
          100000;
%********************************************************************
%********************************************************************
% VECTOR FOR MOPC EXAMINE DISPLAY FUNCTION
%********************************************************************
VECT4:    ALUD,NONE  % MEM. EX. (0)
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          EXAMI;
          A,A B,R7 ALUF,PASSA ALUD,B  % REG. EX. (1)
          IDBS,ALU COMM,CLIRQ T,JMP T,HOLD CYCL,FAST
          VC41;
          A,3 B,R6 ALUF,ORDQ ALUD,B  % AUX. REG. EX. (2)
          IDBS,BMG COMM,CLIRQ T,JMP T,HOLD CYCL,FAST
          VC42;
          A,A B,R7 ALUF,PASSA ALUD,B  % INT. REG. EX. (3)
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          VC43;
          ALUD,NONE  % BUS EX. (4)
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          VC44;
%********************************************************************
% MOPC STOP-ROUTINE CONTINUED
STOP2:    AB,SINGL ALUF,PASSD ALUD,Q
          IDBS,REG COMM,SSTOP T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,BPFLG ALUF,PASSD ALUD,NONE
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          BPCHK CONDENABL;
%********************************************************************
% MULTIPLE SINGLE IS ON
          AB,SINGL ALUF,Q-1 ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          SINGL;
BPCHK:    AB,BRKPT ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD
          MANIR CONDENABL;
%********************************************************************
% BREAKPOINT IS ON
          A,P ALUF,Q-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F=0 F,JMP F,HOLD;
          A,6 ALUF,D-1 ALUD,Q
          IDBS,AARG T,NEXT T,HOLD
          SINGL CONDENABL;
%********************************************************************
% BREAKPOINT IS FINISHED, PRINT .
          AB,PRCHR ALUF,Q-1 ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD
          RONLY;
%********************************************************************
% . PRINTED TO MOPC, SET UP BREAKPOINT MODE
DOT:      AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD;
          AB,BRKPT ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD;
          AB,BPFLG ALUD,NONE
          IDBS,ARG COMM,EWRF T,JMP T,HOLD
          SPAC9;
%********************************************************************
% LAST ENTRY IN VECT4 : DEFAULT DISPLAY MODE (ACTIVITY) (17)
          AB,ACTLV ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD
          VC417;
%********************************************************************
%********************************************************************
% VECTOR FOR 1504XX- INSTRUCTIONS (PON ETC.)
%********************************************************************
VECT1:    ALUD,NONE
          T,JMP T,HOLD CYCL,WAIT
          INPUT;
IOF:      A,17 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          IOF2;
ION:      A,17 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,WAIT
          ION2;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT INIT;
POF:      A,16 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,WAIT
          POF2;
PIOF:     A,16 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          IOF;
SEX:      A,15 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,WAIT
          POF2;
REX:      A,15 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,WAIT
          POF2;
PON:      A,16 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,WAIT
          POF2;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT INIT;
PION:     A,16 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          ION;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT INIT;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT INIT;
IOXT:     ALUD,NONE T,JMP T,HOLD IOXT2;
EXAM:     A,12 ALUF,D+1 ALUD,Q
          IDBS,AARG T,JMP T,HOLD
          EXAM2;
DEPO:     A,12 ALUF,D+1 ALUD,Q
          IDBS,AARG T,JMP T,HOLD
          DEPO2;
%********************************************************************
%********************************************************************
% VECTOR FOR 1500XX-INSTRUCTIONS (TRA)
%********************************************************************
VECT2:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          APANS;
TASTS:    B,A ALUF,PASSD ALUD,B
          IDBS,STS T,RETURN T,HOLD CYCL,FAST;
TAOPR:    AB,OPR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD
          APIE1;
TAPGS:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          APGS1;
TAPVL:    AB,PVL ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          APVL1;
TAIIC:    PIC,RSTS B,R5 ALUF,PASSD ALUD,B
          IDBS,PIC COMM,EPIC T,JMP T,HOLD CYCL,FAST
          AIIC1;
TAPID:    PIC,RMSK B,R1 ALUF,PASSD ALUD,B
          IDBS,DSABL COMM,EPIC T,JMP T,HOLD CYCL,FAST
          APID1;
TAPIE:    AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          APIE1;
TACSR:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          ACSR1;
TAPIM:    A,PIL B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,RETURN T,HOLD CYCL,FAST;
TAALD:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          AALD1;
TAPES:    B,A ALUF,INVD ALUD,B
          IDBS,PES T,RETURN T,HOLD CYCL,FAST;
TAPGC:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT APGC1;
TAPEA:    B,A ALUF,INVD ALUD,B
          IDBS,PEA T,RETURN T,HOLD CYCL,FAST;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT AIR16;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT AIR16;
%********************************************************************
%********************************************************************
% VECTOR FOR 1501XX-INSTRUCTIONS (TRR)
%********************************************************************
VECT3:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RPANC;
TRSTS:    ALUF,PASSQ ALUD,NONE STS,LO
          IDBS,ALU T,RETURN T,HOLD CYCL,FAST;
TRLMP:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,FAST RLMP1;
TRPCR:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          RPCR1;
TR4:      ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR4;
TRIIE:    A,A ALUF,A+Q ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          RIIE1;
TRPID:    AB,PID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          RPID1;
TRPIE:    AB,PIE ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          RPIE1;
TRCCL:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          RCCL1;
TRCIL:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RCIL1;
TRCIU:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          RCIU1;
TR13:     ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR13;
TR14:     ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR14;
TRECC:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          RECC1;
TR16:     ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR16;
TR17:     ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR17;
%********************************************************************
%********************************************************************
% VECTOR FOR IOX 30X INSTRUCTIONS
%********************************************************************
TRMVC:    ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,FAST
          TRM0;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
          B,A ALUF,PASSD ALUD,B
          IDBS,IOR T,JMP T,HOLD CYCL,FAST
          TRM2;
          A,A B,R2 ALUF,INVA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TRM3;
          B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,TBSTR T,RETURN T,POP CYCL,SLOW;
          B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TRM6;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,FAST
          TRM7;
%********************************************************************
%********************************************************************
% VECTOR FOR IOX 10-13
%********************************************************************
CLKVC:    A,A ALUF,ZERO ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
          A,7 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          CLK1;
          B,A ALUF,ANDDQ ALUD,B
          IDBS,ARG T,RETURN T,POP CYCL,FAST
          11;
          A,0 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          CLK3;
%********************************************************************
%********************************************************************
% EXTRAS FOR MEM.REF.CALC. FOR JUMPS
%********************************************************************
INDJ1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD
          INDIJ;
INDJ2:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,JMP T,HOLD
          INDIJ;
POXJ1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD
          POSXJ;
POXJ2:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,JMP T,HOLD
          POSXJ;
%********************************************************************
%********************************************************************
% VECTOR FOR MEMORY REFERENCE CALCULATIONS IN JMP
%********************************************************************
MREFJ:    A,P B,P ALUD,B  % P-REL
          T,JMP T,HOLD CYCL,WAIT
          INIT;
          A,B B,P ALUF,A+Q+1 ALUD,B  % B-REL
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
          A,P B,R1 ALUF,A+Q ALUD,B  % I P-REL
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INDJ1;
          A,B B,R1 ALUF,A+Q+1 ALUD,B  % I B-REL
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INDJ2;
          A,X B,P ALUF,A+Q+1 ALUD,B  % X-REL
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
          A,X B,P ALUF,A+Q+1 ALUD,B  % X & B-REL
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          BADDJ;
          A,P B,R1 ALUF,A+Q ALUD,B  % I X-REL
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          POXJ1;
          A,B B,R1 ALUF,A+Q+1 ALUD,B  % I B & X-REL
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          POXJ2;
%********************************************************************
% EXTRAS FOR MEM. REF. CALC. ROUTINES
POSXJ:    A,X B,P ALUF,D+A ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          INIT;
INDIJ:    B,P ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          INIT;
BADDJ:    A,B B,P ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
STWR2:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,RETURN T,POP CYCL,FAST;
STRD2:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO START READ REQUEST IN MULTIPLE READ INSTRUCTONS
RDRQ:     B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,RDRQ MIS,HOLD T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO START WRITE REQUESR IN MULTIPLE WRITE INSTRUCTIONS
WRRQ:     A,P B,R1 ALUF,A-B ALUD,NONE
          IDBS,ALU COMM,ESRP T,NEXT T,HOLD CYCL,WAIT;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,HOLD COMM,WRRQ T,RETURN T,POP CYCL,FAST;
%********************************************************************
%********************************************************************
% VECTOR FOR MEMORY REFERENCE CALCULATIONS IN STORE ISTRUCTIONS
%********************************************************************
MREFS:    A,P B,R1 ALUF,A+B ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          STWR1;
          A,B B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          STWR2;
          A,P B,R1 ALUF,A+B ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          INDS1;
          A,B B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          INDS2;
          A,X B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          STWR2;
          A,X B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          BADDS;
%********************************************************************
          A,P B,R1 ALUF,A+B ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          POXS1;
          A,B B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          POXS2;
%********************************************************************
% EXTRAS FOR MEM. REF. CALC. ROUTINES FOR STORES
INDS1:    B,R1 ALUF,PASSB ALUD,NONE
          MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,FAST
          INDIS;
INDS2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,FAST;
INDIS:    B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STWR2;
POXS1:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,FAST
          POSXS;
POXS2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,FAST;
POSXS:    A,X B,R1 ALUF,D+A ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STWR2;
BADDS:    A,B B,R1 ALUF,A+B ALUD,B
          IDBS,ALU MIS,APT COMM,WRRQ T,RETURN T,POP CYCL,FAST;
STWR1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,WRRQ T,RETURN T,POP CYCL,FAST;
%********************************************************************
%********************************************************************
% VECTOR FOR MEMORY REFERENCE CALCULATIONS FOR LOAD-INSTRUCTIONS
%********************************************************************
MREFL:    A,P B,R1 ALUF,A+B ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          STRD1;
          A,B B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          STRD2;
          A,P B,R1 ALUF,A+B ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          INDL1;
          A,B B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          INDL2;
          A,X B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          STRD2;
          A,X B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          BADDL;
          A,P B,R1 ALUF,A+B ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          POXL1;
          A,B B,R1 ALUF,A+B+1 ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          POXL2;
%********************************************************************
% EXTRAS FOR MEM. REF. CALC. ROUTINES FOR LOADS
INDL1:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,FAST
          INDIL;
INDL2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,FAST;
INDIL:    B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STRD2;
POXL1:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,FAST
          POSXL;
POXL2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,FAST;
POSXL:    A,X B,R1 ALUF,D+A ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STRD2;
BADDL:    A,B B,R1 ALUF,A+B ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,RETURN T,POP CYCL,FAST;
STRD1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,RDRQ T,RETURN T,POP CYCL,FAST;
%********************************************************************
%********************************************************************
% *
% I N T E R R U P T   V E C T O R   *
% *
%********************************************************************
%********************************************************************
ITSRV:    B,12 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST XINT;
          B,13 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST XINT;
          B,14 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST XINT;
          B,15 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST XINT;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST EXT14;
          B,17 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,FAST XINT;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST STOP;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST MS20;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST PRQ;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST SING2;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST LOAD;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST CONT;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST RSTRT;
          AB,MACL ALUD,NONE IDBS,ARG COMM,EWRF T,JMP T,HOLD CYCL,FAST MACL;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST STOP;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST MS20;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST PRQ;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST SING2;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST LOAD;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST CONT;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,FAST RSTRT;
          AB,MACL ALUD,NONE IDBS,ARG COMM,EWRF T,JMP T,HOLD CYCL,FAST MACL;
%********************************************************************
%********************************************************************
% VECTOR FOR DECODING OF BCD, BYTE BLOCK, STACK ,TSET AND RDUS
%********************************************************************
%********************************************************************
COBVC_CX: A,2 B,11 ALUF,ZERO ALUD,NONE  % DECIMAL ADD
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,WAIT
          ADDE;
          A,0 ALUD,NONE  % DECIMAL SUBTRACT
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          SUBD;
          A,0 B,17 ALUD,NONE  % DECIMAL COMPARE
          IDBS,BARG XRF COMM,EWRF T,JMP T,HOLD CYCL,WAIT
          COMD;
          ALUD,NONE  % TSET
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          TSET;
          ALUD,NONE  % CONVERT TO BCD
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          PACK;
          ALUD,NONE  % CONVERT TO ASCII
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          UPACK;
          ALUD,NONE  % DECIMAL SHIFT
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          SHDE;
          ALUD,NONE  % RDUS
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          RDUS;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT BFILL;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT MOVB;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT MOVBF;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          5INIT_CX;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          ENTR_CX;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          LEAV_CX;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          ELEAV_CX;
%********************************************************************
% DECIMAL SUBTRACTION SUBROUTINE
SSUB:     B,R5 ALUF,XORDQ ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          ALUF,Q-D-1 ALUD,Q STS,EA CRY,C
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,NEXT F,HOLD;
          AB,OCTNR ALUF,XORAQ ALUD,B
          T,JMP T,HOLD CYCL,FAST
          SUBB CONDENABL;
          ALUF,Q-D ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          60000;
SUBB:     A,L B,R5 ALUF,ANDAB ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,R2 ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,R5 ALUF,ORAB ALUD,SRB
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% DECIMAL ADDITION SUBROUTINE
SADD:     B,R5 ALUF,XORDQ ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          ALUF,D+Q ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          63146;
          ALUF,D+Q ALUD,Q STS,EA CRY,C
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,CRY F,NEXT F,HOLD;
          AB,OCTNR ALUF,XNORAQ ALUD,B
          T,JMP T,HOLD CYCL,FAST
          ADDB CONDENABL;
          ALUF,Q-D ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          60000;
ADDB:     A,L B,R5 ALUF,ANDAB ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,R2 ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,R5 ALUF,ORAB ALUD,SRB
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% ENTRY-POINT ALL COMMERCIAL INSTRUCTIONS
%********************************************************************
COMME_CX: ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD
          60;
          ALUF,ANDDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,2 ALUF,XORDQ ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,2 B,16 ALUD,NONE
          IDBS,STS COMM,EWRF T,NEXT T,HOLD CYCL,FAST
          ILLIN CONDENABL;
          A,2 B,15 ALUD,NONE
          IDBS,BARG COMM,EWRF T,JMP0-3 T,HOLD CYCL,FAST
          COBVC_CX;
%********************************************************************
% SUBROUTINE TO SAVE REGISTERS FROM CURRENT LEVEL
% L -> RF(5,13)
% B -> RF(5,12)
% GPR IS USED AS SCRATCH
CSAV1:    A,L ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,5 B,13 ALUD,NONE
          IDBS,GPR COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,B ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,A B,12 ALUD,NONE
          IDBS,GPR COMM,EWRF T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO UNSAVE REGISTERS TO CURRENT LEVEL
% RF(5,13) -> L
% RF(5,12) -> B
% GPR IS USED AS SCRATCH
CUSV1:    A,5 B,12 ALUD,NONE
          IDBS,REG COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
          B,B ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,5 B,13 ALUD,NONE
          IDBS,REG COMM,LDGPR T,NEXT T,HOLD CYCL,NORM;
          B,L ALUF,PASSD ALUD,B
          IDBS,GPR T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO COMPUTE BOTTOM WORD ADDRESS
% AND NUMBER OF WORDS OF AN ASCII OPERAND
% DESCRIPTORS IN R1,R2
% RETURN WITH NUMBER OF WORDS IN R4
% NUMBER OF BYTES IN R7
% BOTTOM WORD ADDRESS IN R6
LWAB:     B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,R2 B,R7 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          LWABC CONDENABL;
          B,R7 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
LWABC:    A,R7 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,R7 B,R4 MIS,ZIN ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          LWABB CONDENABL;
          A,R6 B,R4 ALUF,A+B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,Q-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
LWABB:    A,R4 B,R4 ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,R6 ALUF,D+A ALUD,B
          IDBS,GPR T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SUBROUTINE TO COMPUTE NUMBER OF WORDS
% AND BOTTOM WORD ADDRESS OF A BCD-OPERAND
% DESCRIPTORS IN R1,R2
% RETURN WITH NUMBER OF WORDS IN STS
% NUMBER OF NIBLES IN R3
% BOTTOM WORD ADDRESS IN R1
LWA:      A,R2 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,STS ALUF,ANDDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          LWAA CONDENABL;
          B,STS ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
LWAA:     A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,STS MIS,ZIN ALUF,PASSB ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          LWAC CONDENABL;
          B,STS ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
LWAC:     A,STS B,R3 MIS,ZIN ALUF,PASSA ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,STS MIS,ZIN ALUF,PASSB ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT;
          A,STS B,R1 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          LWAD CONDENABL;
          B,STS ALUF,B+1 ALUD,B
          IDBS,ARG COMM,LDGPR T,RETURN T,POP CYCL,FAST
          37;
LWAD:     B,R1 ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,RETURN T,POP CYCL,FAST
          37;
%********************************************************************
% SUBROUTINE TO MAKE MASK FOR TOPWORD BCD-OPERANDS
% DESCRIPTOR IN R2. RETURN WITH MASK IN Z.
TTPWD:    A,R2 ALUF,PASSA ALUD,NONE
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          RIGTB CONDENABL;
          A,R2 B,D ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,POP;
          A,14 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          CONDENABL;
          B,0 ALUF,D-1 ALUD,B
          IDBS,BARG T,RETURN T,POP CYCL,FAST;
RIGTB:    A,R2 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,POP;
          A,4 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          CONDENABL;
          A,10 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,RETURN T,POP CYCL,FAST;
%********************************************************************
% COMMERCIAL INSTRUCTION: COMPARE
%********************************************************************
COMD:     A,Z B,R4 ALUF,A+1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          16;
%********************************************************************
% TEST SECOND OPERAND EMPTY
          A,T B,R7 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          CFIR CONDENABL;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
%********************************************************************
% IF NOT EMPTY, READ SECOND OPERAND TO XRF(RA,0)
          A,X B,17 ALUF,A-1 ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          ALUF,Q+1 ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,LC ALUF,A-Q-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,0 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,WAIT;
          A,R3 B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,STS B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,D-1 ALUD,B
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
          A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
%********************************************************************
% TEST FIRST OPERAND EMPTY
CFIR:     A,D B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,A B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          ANEMP CONDENABL;
          A,1 B,17 ALUD,NONE
          IDBS,BARG XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,0 B,STS ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          STRPS;
ANEMP:    A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
%********************************************************************
% IF NOT EMPTY, READ FIRST OPERAND TO XRF(RA,1)
          A,A B,17 ALUF,A-1 ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          ALUF,Q+1 ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,LC ALUF,A-Q-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,1 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,WAIT;
          B,R6 ALUF,D-1 ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
          A,1 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
STRPS:    A,2 ALUF,D-1 ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,B+1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,R7 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          CLLBY CONDENABL;
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          A,0 B,LC ALUF,MASKAQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          STRTW;
CLLBY:    A,Z B,R2 ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
STRTW:    B,R6 ALUF,B+1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,PUSH CYCL,FAST
          BUNOR;
%********************************************************************
% TEST UNSIGNED OPERANDS AND EQUAL SIGNS
          A,Z B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,L ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          PLUS1 CONDENABL;
          ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
PLUS1:    A,R2 B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,5 B,13 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST
          PLUS2 CONDENABL;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
PLUS2:    A,Z B,R2 ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,3 B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST
          SDIFF CONDENABL;
%********************************************************************
% TEST EQUAL LENGTH
          A,R4 B,STS ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,6 ALUD,NONE STS,LO
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          XTSHO CONDENABL;
          A,R4 B,STS ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          A,R5 B,R1 ALUF,A+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          COMPA CONDENABL;
%********************************************************************
% FIRST OPERAND SHORTEST LENGTH,INSERT ZEROES
          B,R6 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,R6 B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,POP;
          A,D B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,RETURN T,HOLD CYCL,FAST
          CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          B,R5 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,POP;
          A,1 B,LC ALUF,ZERO ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,RETURN T,HOLD CYCL,FAST
          COMPA CONDENABL;
%********************************************************************
% SECOND OPERAND SHORTEST, INSERT ZEROES
XTSHO:    A,R6 B,R1 ALUF,A+1 ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          B,R5 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,R5 B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,POP;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,RETURN T,HOLD CYCL,FAST
          CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          B,R6 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,POP;
          A,0 B,LC ALUF,ZERO ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,RETURN T,HOLD CYCL,FAST
          CONDENABL;
%********************************************************************
% COMPARE
COMPA:    A,R7 B,R3 ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,10 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          NOTEB CONDENABL;
%********************************************************************
% BOTH OPERANDS EQUAL BOTTOM BYTE ADDRESS, COMPARE WORDS
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          B,L ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          10420;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,1 B,LC ALUD,NONE
          IDBS,REG XRF COMM,LDGPR T,JMP T,PUSH CYCL,NORM
          SSUB;
          A,R5 ALUF,Q-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          A,R1 B,LC ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          UNEQL CONDENABL;
          A,6 B,A ALUF,ZERO ALUD,B STS,LO
          IDBS,BMG T,NEXT T,POP LCOUNT CYCL,FAST;
EXIT:     A,3 B,12 ALUF,PASSD ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,R2 B,D ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,5 B,13 ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          EXITB CONDENABL;
          B,A ALUF,INVB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,A ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
EXITB:    B,L ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          EXITC;
%********************************************************************
% UNEQUAL, TEST CARRY FROM SUBTACT SUBROUTINE
UNEQL:    B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          SEOGR CONDENABL;
FIOGR:    A,0 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          EXIT;
%********************************************************************
% DIFFERENT SIGNS
SDIFF:    B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          A,0 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          SDIFC CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          A,1 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,STS ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          SDIFC CONDENABL;
          B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          EXIT;
SDIFC:    A,Z ALUF,ANDDA ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,3 B,12 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          FIOGR CONDENABL;
SEOGR:    A,0 B,A ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          EXIT;
%********************************************************************
% OPERANDS NOT EQUAL BOTTOM BYTE ADDRESS, COMPARE SWAPPED BYTES
NOTEB:    A,R7 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,6 B,R7 ALUF,ZERO ALUD,B STS,LO
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          XTHOB CONDENABL;
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          B,L ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          10420;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          B,R3 ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          A,Z B,R6 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          B,R3 ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          SSUB;
          A,R5 ALUF,Q-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          UNEQL CONDENABL;
          B,R5 ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          A,Z B,R7 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,6 B,R6 ALUF,PASSB ALUD,Q STS,LO
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,PUSH CYCL,FAST
          SSUB;
          A,R5 ALUF,Q-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          UNEQL CONDENABL;
          A,R1 B,LC ALUF,D-A-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,6 B,A ALUF,ZERO ALUD,B STS,LO
          IDBS,BMG T,JMP T,POP LCOUNT CYCL,FAST
          EXIT;
XTHOB:    B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          B,L ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          10420;
          A,1 B,LC ALUF,PASSD
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,Z B,R3 ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          A,Z B,R6 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R7 ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,PUSH CYCL,FAST
          SSUB;
          A,R5 ALUF,Q-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          UNEQL CONDENABL;
          A,Z B,R5 ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          A,Z B,R7 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,6 B,R5 ALUF,PASSB ALUD,Q STS,LO
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,PUSH CYCL,FAST
          SSUB;
          A,R5 ALUF,Q-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          UNEQL CONDENABL;
          A,R1 B,LC ALUF,D-A-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,6 B,A ALUF,ZERO ALUD,B STS,LO
          IDBS,BMG T,JMP T,POP LCOUNT CYCL,FAST
          EXIT;
BUNOR:    A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          RLLBY CONDENABL;
          B,Z ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          ALUF,MASKDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,RETURN T,POP CYCL,FAST;
RLLBY:    A,Z B,Z ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,RETURN T,POP CYCL,FAST;
%********************************************************************
% COMMERSIAL INSTRUCTION:ADDD (A,D +/- X,T -> A,D)
%********************************************************************
SUBD:     A,2 B,11 ALUD,NONE
          IDBS,GPR COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
ADDE:     ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,T ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,D B,R7 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          SECOP CONDENABL;
          A,A B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          FIROC CONDENABL;
UTGNG:    B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          INIT;
SECOP:    A,5 B,16 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,5 B,17 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
          A,R1 B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,STS B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TFIRE;
%********************************************************************
% X,T EMPTY, SET SIGN IN A,D TO 14 (+) OR 15 (-)
FIROC:    A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          FIROL CONDENABL;
          B,R4 ALUF,ANDDQ ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          7400;
          B,R4 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          ALUF,MASKDQ ALUD,Q
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          FIROE;
FIROL:    B,R4 ALUF,ANDDQ ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          17;
          ALUF,MASKDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
FIROE:    A,15 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,D ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          FIROA CONDENABL;
          A,2 B,R4 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          FIROB;
FIROA:    A,R4 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,14 ALUF,PASSD ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          FIROB CONDENABL;
          B,R4 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
FIROB:    A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R4 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          FIOSL CONDENABL;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
FIOSL:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,R4 ALUF,ORAQ ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          UTGNG;
%********************************************************************
% TEST FIRST OPERAND EMPTY
TFIRE:    A,D B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,A B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          FIROP CONDENABL;
          A,1 B,17 ALUD,NONE
          IDBS,BARG XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,0 B,STS ALUF,D ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          TNOEQ;
FIROP:    A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
          B,R1 ALUF,B+1 ALUD,Q
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST
          17;
%********************************************************************
% READ FIRST OPERAND TO XRF (RA,1)
          ALUF,Q-1 ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,A B,LC ALUF,Q-A-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,1 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,HOLD CYCL,WAIT
          COND,COND;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          A,1 B,LC ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          T,NEXT T,POP LCOUNT CYCL,WAIT;
          A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
          ALUF,PASSB ALUD,Q
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,Z B,R2 ALUF,MASKAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,2 B,12 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
TNOEQ:    A,R7 B,R3 ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,10 B,R2 ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          NOTEQ CONDENABL;
%********************************************************************
% READ SECOND OPERAND TO XRF (RA,O)
          B,R6 ALUF,B+1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST
          17;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,X B,R6 ALUF,B-A-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,DBR XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,WAIT;
          B,LC ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
          B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          A,Z B,LC ALUF,ANDAQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,PUSH CYCL,FAST
          CSAV1;
TSIGN:    A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,1 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          SLBYT CONDENABL;
%********************************************************************
% SIGN IN RIGHT BYTE
          B,Z ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          ALUF,MASKDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          A,D B,R7 ALUF,PASSQ ALUD,NONE
          XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          ALUF,MASKDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          A,0 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          SIGN;
%********************************************************************
% SIGN IN LEFT BYTE FIRST OPERAND
SLBYT:    A,R2 B,Z ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          B,B ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          A,1 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,R2 B,R2 ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          A,0 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          SIGN;
%********************************************************************
% SWAP SECOND OPERAND WHEN READING TO XRF LEVEL (
NOTEQ:    A,R7 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,R7 ALUF,INVA ALUD,B
          IDBS,BARG COMM,LDLC T,JMP T,HOLD CYCL,FAST
          BOTWD CONDENABL;
          A,R6 B,R6 ALUF,B-1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,JMP T,PUSH CYCL,FAST
          CSAV1;
          A,R6 B,X ALUF,A-B ALUD,NONE
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F15 F,NEXT F,HOLD;
          A,R2 B,Z ALUF,ANDDA ALUD,B
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          NOTEC CONDENABL;
NTECC:    B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          B,R6 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R7 B,R5 ALUF,ANDDA ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,Z ALUF,ORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,Z ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,FAST;
NOTEC:    B,LC ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,4 B,R2 ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          TOPWD CONDENABL;
          A,T B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,GPR COMM,LDLC T,JMP T,HOLD CYCL,FAST
          TSIGN CONDENABL;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7777;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          TSIGN;
TOPWD:    A,T B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SAVTP CONDENABL;
          A,R2 B,Z ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
SAVTP:    A,0 B,LC ALUF,PASSA ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          TSIGN;
BOTWD:    B,Z ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CSAV1;
          B,R4 ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          NTECC;
%********************************************************************
% TEST UNSIGNED OPERAND AND ADD/SUB
SIGN:     A,R2 B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,2 B,11 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          SIGNA CONDENABL;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
SIGNA:    A,Z B,LC ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,R2 ALUF,XORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          SIGNB CONDENABL;
          A,Z B,Z ALUF,A-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
SIGNB:    A,R4 B,STS ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,Z ALUF,XORAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SIGNC CONDENABL;
          A,STS B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SIGND;
SIGNC:    A,R4 B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
SIGND:    B,L ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          10420;
          A,0 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT;
          A,5 B,14 ALUD,NONE
          IDBS,BARG COMM,EWRF T,JMP T,HOLD CYCL,FAST
          CONDENABL F,HOLD
          ADDA;
%********************************************************************
% SUBTRACTION
          A,6 ALUD,NONE STS,LO
          IDBS,BMG T,JMP T,PUSH CYCL,FAST
          SUBDC;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
SUBDC:    A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,0 B,LC ALUD,NONE
          IDBS,REG XRF COMM,LDGPR T,JMP T,PUSH CYCL,NORM
          SSUB;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,5 B,16 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,5 B,17 ALUF,Q-D ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F15 F,NEXT F,HOLD;
          A,R4 B,STS ALUF,A-B ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          FINI CONDENABL;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R5 ALUF,Q+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          EQLLT CONDENABL;
%********************************************************************
% FIRST OPERAND SHORTEST
          B,R5 ALUF,B-1 ALUD,NONE
          T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          B,LC ALUF,ZERO ALUD,Q
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          EQLLT CONDENABL;
          A,0 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,R5 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          INVER CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          EQLLT;
INVER:    ALUF,Q ALUD,NONE CRY,C
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,2 B,15 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          INVWR CONDENABL;
          A,R4 B,STS ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,0 B,LC ALUF,D-1 ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,FAST
          INVWR CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          INVWR CONDENABL;
          A,2 B,15 ALUD,NONE
          IDBS,BARG COMM,EWRF T,JMP T,HOLD CYCL,FAST
          INVWR;
%********************************************************************
% OPERANDS HAVE EQUAL LENGTH
EQLLT:    B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          TUSIG CONDENABL;
INVWR:    A,STS B,R6 ALUF,PASSA ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          17;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          360;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7400;
          A,1 B,17 ALUD,NONE
          IDBS,REG XRF COMM,LDGPR T,JMP T,PUSH CYCL,NORM
          INVWS;
          B,17 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          A,D B,LC ALUF,ANDDQ ALUD,NONE
          IDBS,REG XRF COMM,LDGPR T,JMP T,HOLD CYCL,NORM
          INVSS;
INVWS:    ALUF,ZERO ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
INVSS:    A,R5 ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          INVQ CONDENABL;
          A,R7 ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          INVR CONDENABL;
          A,R4 ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          INVS CONDENABL;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          INVT CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          TUSIG;
INVQ:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          114633;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INVWC;
INVR:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          114641;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INVWC;
INVS:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          115001;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INVWC;
INVT:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          120001;
INVWC:    B,R6 ALUF,B+1 ALUD,B STS,EA
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          INVCC;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          114631;
INVCC:    A,1 B,LC ALUF,ZERO ALUD,NONE
          IDBS,REG XRF COMM,LDGPR T,JMP T,PUSH CYCL,NORM
          SSUB;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,FAST;
          A,Z B,Z ALUF,XORDA ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          TUSIG;
%********************************************************************
% SECOND OPERAND SHORTEST
FINI:     B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,0 B,R6 ALUF,-Q ALUD,B STS,LO
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          TUSIG CONDENABL;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          B,0 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          INVWR CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          SSUB;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST
          TUSIG CONDENABL;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          A,0 ALUD,NONE STS,LO
          IDBS,AARG T,JMP T,POP LCOUNT CYCL,FAST
          INVWR;
%********************************************************************
% ADD, OPERANDS EQUAL LENGTH
LIKE:     B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          OVERF CONDENABL;
TUSIG:    A,5 B,17 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,HOLD;
          A,15 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          ATOVE CONDENABL;
          A,2 B,15 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,1 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,HOLD CYCL,NORM
          DECP CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          EXITD CONDENABL;
DECP:     B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          EXITD;
ATOVE:    A,D ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,14 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          TSIGF CONDENABL;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          NOCAR;
TSIGF:    A,Z B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,Z ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          NOCAR CONDENABL;
          B,Z ALUF,Q+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
NOCAR:    A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,1 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          LFTBY CONDENABL;
          A,Z ALUF,ORAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TEFIN;
LFTBY:    A,Z ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,ORDQ ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          ALUF,MASKDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          A,B ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
TEFIN:    A,D B,R7 ALUF,PASSQ ALUD,NONE
          XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,2 B,16 ALUD,NONE STS,LO
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,R1 B,A ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,JMP T,HOLD CYCL,FAST
          SKRVC CONDENABL;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,WAIT;
          A,R1 B,A ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,F=0;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU COMM,LDGPR T,NEXT T,POP LCOUNT CYCL,FAST;
SKRVC:    A,2 B,15 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,HOLD CYCL,NORM
          OVFLO CONDENABL;
          A,2 B,14 ALUF,MASKDQ ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,2 B,14 ALUF,ANDDQ ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          USAVE CONDENABL;
OVFLO:    B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUF,ANDDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
USAVE:    A,2 B,12 ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          B,A ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
EXITD:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CUSV1;
EXITC:    A,2 B,16 ALUD,NONE STS,LO
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          UTGNG;
%********************************************************************
% ADDITION
ADDA:     A,0 ALUD,NONE STS,LO
          IDBS,AARG T,JMP T,PUSH CYCL,FAST
          ADDCC;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
ADDCC:    A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,0 B,LC ALUD,NONE
          IDBS,REG XRF COMM,LDGPR T,JMP T,PUSH CYCL,NORM
          SADD;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
ADSLT:    A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,5 B,16 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,5 B,17 ALUF,D-Q ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F15 F,JMP F,HOLD;
          A,R4 B,STS ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          ADSLC CONDENABL;
%********************************************************************
% FIRST OPERAND SHORTEST
          B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,R6 ALUF,Q+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          OVERF CONDENABL;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TUSIG CONDENABL;
          A,0 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          OVERF CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          TUSIG;
%********************************************************************
% SECOND OPERAND SHORTEST
ADSLC:    A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,STS B,R4 ALUF,A-B ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          LIKE CONDENABL;
          B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          B,R6 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TUSIG CONDENABL;
          B,0 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          OVERF CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          SADD;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,POP CYCL,FAST
          TUSIG CONDENABL;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,FAST;
OVERF:    A,2 B,15 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          TUSIG;
%********************************************************************
% COMMERCIAL INSTRUCTION: SHIFT
%********************************************************************
SHDE:     ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,D ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          STNOE CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          SAEMP CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          INIT;
%********************************************************************
% X,T-OPERAND NOT EMPTY, READ FIRST AND LAST WORD
STNOE:    A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
          A,R1 B,R2 ALUF,ZERO ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,COND F,NEXT;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          RFIRW CONDENABL;
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          377;
RFIRW:    A,2 B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,WAIT;
          A,STS B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
          A,Z B,STS ALUF,ZERO ALUD,B,YA
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUD,NONE
          IDBS,GPR COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,Z ALUF,INVB ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,2 B,11 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
SAEMP:    A,D B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,A B,R1 ALUF,A ALUD,B STS,EA
          T,JMP T,HOLD CYCL,FAST
          SHCON CONDENABL;
          A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
%********************************************************************
% COMPUTE SHIFT COUNT FROM THE DIFFERENCE IN
% DECIMAL POSITION OF THE OPERANDS
SHCON:    A,R3 B,3 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          B,R5 ALUF,PASSQ ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          1740;
          A,D ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,PUSH CYCL,FAST;
          B,R2 MIS,ZIN ALUF,PASSB ALUD,SRD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          A,R2 ALUF,A-Q ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R7 B,R3 ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R7 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,R3 B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          TSHTD CONDENABL;
          B,R3 ALUF,-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
TSHTD:    A,0 B,17 ALUD,NONE
          IDBS,ARG XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST
          14;
          A,R3 B,R3 ALUF,A+Q ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,JMP T,HOLD CYCL,FAST
          RSHFT CONDENABL;
%********************************************************************
%********************************************************************
% LEFT SHIFT
          A,R5 B,17 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          LSHFB CONDENABL;
          A,2 B,R1 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          LSHFT;
%********************************************************************
% READ FIRST OPERAND TO RF LEVEL 0
LSHFB:    A,A ALUF,A-1 ALUD,Q
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          ALUF,Q+1 ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,LC ALUF,A-Q-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,0 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,WAIT;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
LSHFT:    A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,PUSH CYCL,FAST
          CSAV1;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,PUSH CYCL,FAST
          SBUNO;
          A,R1 B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,4 B,14 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,R5 ALUF,A-1 ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TEMTS;
          B,3 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          LSHFC;
TEMTS:    ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,POP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          CONDENABL;
          A,0 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,LC ALUF,D-Q ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          USAV3 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USAV3;
SBUNO:    A,R5 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          SLLBY CONDENABL;
          B,L ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          B,17 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          BUNNC;
SLLBY:    A,Z B,L ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
BUNNC:    A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,4 B,10 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,POP CYCL,FAST;
LSHFC:    A,R3 B,4 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,2 B,B ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          LSHLC CONDENABL;
%********************************************************************
% SHIFT-COUNT > 4, MOVE POINTERS
          A,R3 B,R2 MIS,ZIN ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R2 MIS,ZIN ALUF,PASSB ALUD,SRB
          IDBS,ARG COMM,LDGPR T,NEXT T,PUSH CYCL,FAST
          3;
          B,R5 ALUF,B-1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          3;
          A,Z B,LC ALUF,ZERO ALUD,NONE EN_EXT
          COMM,EWRF T,NEXT T,POP LCOUNT;
LSHLC:    A,R3 B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R4 B,STS ALUF,PASSA ALUD,B
          T,JMP T,HOLD
          FINSH CONDENABL;
%********************************************************************
% SHIFT INSIDE THE WORD (SHIFT-COUNT<4)
          B,R2 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          17;
          B,R3 MIS,ZIN ALUF,PASSB ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R3 MIS,ZIN ALUF,PASSB ALUD,SLD
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          2;
          A,R3 B,R3 ALUF,A-D ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,2 B,L ALUF,D-1 ALUD,B
          IDBS,AARG T,NEXT T,PUSH CYCL,FAST;
          B,R3 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          B,R1 MIS,ZIN ALUF,PASSB ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          A,L B,R4 ALUF,B-1 ALUD,B,YA
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,R1 ALUF,ORAB ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUD,NONE
          IDBS,GPR XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,L ALUF,B-1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,LC ALUF,D-A-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,HOLD;
          B,R2 ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          CONDENABL;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% TEST OVERFLOW
FINSH:    A,R5 B,STS ALUF,A+B ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,STS B,17 ALUF,A-D-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,12 B,R3 ALUF,INVB ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,PUSH CYCL,FAST
          RWRIT CONDENABL;
          A,0 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,STS ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          XOVER CONDENABL;
          A,STS B,17 ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,RETURN F,HOLD;
          B,STS ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,FAST
          RWRIT CONDENABL;
%********************************************************************
% CARRY FROM ROUNDING, AND LEFT SHIFT
LWRIR:    B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          A,R1 B,17 ALUF,A-D-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,POP;
          A,Z B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          LWRIT CONDENABL;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          SADD;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,R4 ALUF,B-1 ALUD,B,YA
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,HOLD;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,POP CYCL,FAST
          0 CONDENABL;
TCLIR:    B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          A,Z B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          CAROV CONDENABL;
%********************************************************************
% TEST UNSIGNED DESTINATION, AND INSERT SIGN
LWRIT:    A,4 B,10 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,15 B,Z ALUF,PASSQ ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R5 B,R5 ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          CHSIG CONDENABL;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          LWRIC;
CHSIG:    A,Z B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,Z B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,JMP T,HOLD
          SSPOS CONDENABL;
          B,15 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,HOLD
          SSPOS CONDENABL;
          B,Z ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD
          LWRIC;
SSPOS:    B,Z ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          14;
LWRIC:    A,R7 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          WLLBY CONDENABL;
WLRBY:    B,17 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          A,Z ALUF,ORAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          WRITB;
WLLBY:    ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          A,Z ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,ORDQ ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          A,2 B,12 ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
WRITB:    B,R3 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          RWRIC CONDENABL;
%********************************************************************
% WRITE SECOND OPERAND WHEN LEFT SHIFT
          A,X B,R6 ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          A,R5 B,R6 ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          NOVFL CONDENABL;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R5 B,17 ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,WAIT
          COND,F15 F,NEXT F,HOLD;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          ZEROF CONDENABL;
          A,R6 B,X ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,HOLD;
          B,R5 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,POP CYCL,FAST
          CONDENABL;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          NOVFL;
ZEROF:    B,0 ALUF,D ALUD,Q STS,EA CRY,C
          IDBS,BARG T,RETURN T,POP CYCL,FAST;
%********************************************************************
% TEST OVERFLOW
NOVFL:    A,2 B,15 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,2 B,14 ALUF,MASKDQ ALUD,NONE
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          LEOVF CONDENABL;
          A,2 B,14 ALUF,ANDDQ ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          WRITT CONDENABL;
LEOVF:    B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUF,ANDDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
%********************************************************************
% WRITE TOP-WORD
WRITT:    A,2 B,R1 ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,X B,P ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
USAV3:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CUSV1;
          A,2 B,16 ALUD,NONE STS,LO
          IDBS,REG T,JMP T,POP CYCL,NORM
          INIT;
%********************************************************************
%********************************************************************
% RIGHT SHIFT
RSHFT:    A,R5 ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          RSFTC CONDENABL;
%********************************************************************
% READ SOURCE OPERAND TO XRF (RA,0)
          B,R1 ALUF,B+1 ALUD,Q
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          ALUF,Q-1 ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,A B,LC ALUF,Q-A-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,0 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,HOLD LCOUNT CYCL,WAIT;
          A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
RSFTC:    A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          CSAV1;
          A,4 B,14 ALUF,PASSB ALUD,B
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,LC ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,Z B,17 ALUF,ANDAQ ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,B ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,PUSH CYCL,FAST
          SBUNO;
          A,B B,17 ALUF,A-1 ALUD,Q
          IDBS,BARG COMM,LDLC T,JMP T,PUSH CYCL,FAST
          TEMTS;
          B,R3 ALUF,-B ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,D ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,2 B,R5 ALUF,D-1 ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,3 ALUF,A-D-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          B,17 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          RCONT CONDENABL;
%********************************************************************
% SHIFT COUNT > 4, MOVE POINTERS AND INSERT ZEROES
          A,R3 B,R2 MIS,ZIN ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R2 MIS,ZIN ALUF,PASSB ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,R5 ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,B ALUF,B-1 ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,PUSH CYCL,FAST
          COND,F=0;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          3;
          A,0 B,LC ALUF,ZERO ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,FAST;
          B,LC ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          B,B ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
RCONT:    A,R3 B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ZRORS CONDENABL;
%********************************************************************
% SHIFT WITHIN EACH WORD
          B,R3 MIS,ZIN ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,L ALUF,PASSA ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R3 ALUF,B-1 ALUD,SLB
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,R3 B,R1 ALUF,PASSQ ALUD,B,YA
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUF,ZERO ALUD,Q
          IDBS,ALU XRF COMM,EWRF T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          B,R1 MIS,ZIN ALUF,PASSB ALUD,SRD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,L ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,R2 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          B,L ALUF,B-1 ALUD,B
          IDBS,ALU COMM,LDLC T,JMP T,POP CYCL,FAST
          XTOPR CONDENABL;
          A,B B,LC ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,RETURN F,HOLD;
          A,R1 B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,POP CYCL,FAST
          CONDENABL;
%********************************************************************
% FILL ZEROES
ZFILR:    A,R2 ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,12 ALUF,ZERO ALUD,Q
          IDBS,BMG COMM,LDGPR T,JMP T,POP LCOUNT CYCL,FAST
          RWRIT;
ZRORS:    A,STS B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ZFILR CONDENABL;
          A,R5 B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% TEST OVERFLOW
XTOPR:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,12 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          XOVER CONDENABL;
          A,B B,LC ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,PUSH;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          RWRIT CONDENABL;
          A,0 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          A,B B,LC ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          XOVER CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          RWRIT;
XOVER:    A,2 B,15 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% TEST ROUNDING
RWRIT:    A,2 B,16 ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R3 B,R3 ALUF,INVA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          LWRIT CONDENABL;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          ROUND;
%********************************************************************
% WRITE SECOND OPERAND WHILE RIGHT SHIFT
RWRIC:    A,R6 B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          A,R5 ALUF,A-1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          NOVFL CONDENABL;
          B,R6 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,WAIT;
          A,R6 B,X ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,F=0;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,HOLD CYCL,NORM
          NOVFL;
ROUND:    A,R7 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,Z B,LC ALUF,PASSD EN_EXT
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          RLFBY CONDENABL;
          B,R1 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          ALUF,MASKDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          A,R1 B,A ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,4 ALUF,ZERO ALUD,NONE STS,EA
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          LWRIT CONDENABL;
          B,L ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          10420;
          A,R5 B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          SADD;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
TCARY:    A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          LWRIT CONDENABL;
          A,4 B,14 ALUF,D-1 ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,R5 ALUF,A-1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          CAROV CONDENABL;
          B,R3 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,R5 ALUF,PASSA ALUD,B
          T,NEXT T,HOLD CYCL,FAST
          LWRIR CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CCARY;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
CCARY:    A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          SADD;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,0 ALUF,D ALUD,NONE CRY,C
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          LWRIT CONDENABL;
CAROV:    A,2 B,15 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          LWRIT;
RLFBY:    B,R1 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7400;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          2400;
          A,R1 ALUF,A-D ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,14 ALUF,ZERO ALUD,NONE STS,EA
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          LWRIT CONDENABL;
          B,L ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          10420;
          A,R5 B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          SADD;
          A,R5 ALUF,Q-A ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TCARY;
%********************************************************************
% COMMERCIAL INSTRUCTION: PACK (A,D -ASCII-FIELD -> X,T -BCD-FIELD)
%********************************************************************
PACK:     B,R5 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,T B,R1 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,D ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          XNOTE CONDENABL;
          A,0 B,STS ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          XADEM CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          INIT;
XADEM:    A,3 B,11 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,3 B,12 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          TADEM;
%********************************************************************
% READ X,T-OPERAND FIRST AND LAST WORD IF NOT EMPTY
XNOTE:    A,3 B,11 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,3 B,12 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
          A,R1 B,R2 ALUF,ZERO ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,COND F,NEXT F,HOLD;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          PRFIR CONDENABL;
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          377;
          A,1 B,R5 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST;
PRFIR:    A,2 B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,WAIT;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          TTPWD;
          A,Z B,Z ALUF,INVA ALUD,B,YA
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,2 B,11 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUD,NONE
          IDBS,GPR COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
%********************************************************************
% TEST A,D-OPREAND EMPTY, AND READ IT TO RF LEVEL 0
TADEM:    A,3 B,12 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,HOLD;
          A,A B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          NEMP CONDENABL;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          30060;
          B,R2 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          CSAV1;
          B,B ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          16;
          A,5 B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,R4 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD
          USIGN;
NEMP:     A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWAB;
          A,R6 B,17 ALUF,A+1 ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          ALUF,Q-1 ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,A B,LC ALUF,Q-A-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,0 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,WAIT;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R2 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          ADEMP CONDENABL;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          ALUF,ORDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          30000;
ADEMP:    A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,PUSH CYCL,FAST
          CSAV1;
          B,B ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          16;
          A,R7 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF COMM,LDGPR T,JMP T,HOLD CYCL,NORM
          DECSA CONDENABL;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          A,1 B,R2 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% DECODE SIGN REPRESENTATION OF A,D-OPERAND
DECSA:    ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177;
          A,5 B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,15 B,R4 ALUF,B-1 ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,D ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,14 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          USIGN CONDENABL;
          A,D ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,D B,R1 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          LEAD CONDENABL;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F11 F,NEXT F,HOLD;
          A,R1 B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SEPTR CONDENABL;
%********************************************************************
% EMBEDDED TRAILING/LEADING
EMBC:     B,R1 ALUF,B+1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          173;
          ALUF,D-Q ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,Z ALUF,A+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          PZERO CONDENABL;
          ALUF,D-Q ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          175;
          B,Z ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          PZERO CONDENABL;
          B,Z ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          112;
          ALUF,Q-D ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          POS CONDENABL;
NEG:      ALUF,D-Q ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          122;
          A,R1 ALUF,Q-D-1 ALUD,Q
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          ILCDP CONDENABL;
          A,1 B,Z ALUF,B+1 ALUD,B
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          PZERC;
PZERO:    B,2 ALUF,ZERO ALUD,Q
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
PZERC:    A,Z B,Z ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          TPLED;
POS:      A,10 ALUF,D-Q ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,7 B,L ALUF,D+1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          TPLEC CONDENABL;
          A,6 ALUF,Q-D ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,L ALUF,A-Q ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ILCDP CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ILCDP CONDENABL;
TPLEC:    ALUF,ANDDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,1 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          PZERC;
TPLED:    A,14 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,D ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,2 B,R1 ALUF,D+1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          TRAIL CONDENABL;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TRBYT CONDENABL;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
TRBYT:    A,0 B,LC ALUF,ORDQ ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          B,R3 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TBOD;
TRAIL:    A,1 B,R7 ALUF,PASSQ ALUD,B
          IDBS,BMG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          A,1 B,R1 ALUF,D+1 ALUD,B
          IDBS,AARG T,NEXT T,PUSH CYCL,FAST;
          B,R7 ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          A,R7 B,Z ALUF,ORAB ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TBOD;
%********************************************************************
% UNSIGNED
USIGN:    B,Z ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          14;
          A,2 B,R1 ALUF,D+1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          TBOD;
%********************************************************************
% LEADING
LEAD:     A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF COMM,LDGPR T,NEXT T,HOLD CYCL,NORM
          LEADA CONDENABL;
          A,6 ALUF,PASSD ALUD,Q
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          LEADB;
LEADA:    ALUD,NONE
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
LEADB:    ALUF,ORDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          30000;
          B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F11 F,JMP F,HOLD;
          ALUF,ANDDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          EMBC CONDENABL;
          A,0 B,17 ALUD,NONE
          IDBS,REG XRF COMM,LDGPR T,NEXT T,HOLD CYCL,NORM;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% SEPARATE LEADING/TRAILING
SEPTR:    A,2 B,R1 ALUF,D+1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          53;
          B,14 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          SPOS CONDENABL;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          55;
          B,Z ALUF,D+1 ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          TBOD CONDENABL;
          A,4 ALUF,Q-D ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,Z ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          ILCDP CONDENABL;
%********************************************************************
% TEST UNSIGNED DESTINATION AND PREPARE FOR CONVERSION LOOP
TBOD:     A,15 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,Z B,17 ALUF,MASKDA ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          TBODC CONDENABL;
          B,Z ALUF,ORDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
TBODC:    B,R5 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,R1 B,R5 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          PHALB CONDENABL;
          A,Z B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          NONEW;
PHALB:    A,R5 B,17 ALUF,A-D-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,Z ALUF,PASSB ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          BSAVE CONDENABL;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,2 B,Z ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          NONEW;
BSAVE:    B,R1 ALUF,ZERO ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          B,Z ALUF,D-1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          17;
          B,STS ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R5 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          LASTW CONDENABL;
NONEW:    A,1 B,17 ALUD,NONE
          IDBS,GPR XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          PLOOP;
SPOS:     B,Z ALUF,PASSD ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          TBOD;
%********************************************************************
% CONVERSION LOOP
%
% R2 = BYTE-COUNTER
% R5 = NIBLE-COUNTER
% R6 = CONSTANT
% GPR = SCRATCH
% R3 = CURRENT ASCII-WORD
% Q  = SCRATCH
% L  = SCRATCH
% R1 = CURRENT BCD-WORD
PLOOP:    A,3 B,10 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,PUSH CYCL,FAST
          34400;
          A,R2 B,10 ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,7 B,R6 ALUF,D+1 ALUD,B
          IDBS,AARG T,JMP T,PUSH CYCL,FAST
          PREAD CONDENABL;
          A,6 B,R2 ALUF,PASSB ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,R3 ALUF,PASSA ALUD,Q
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          PLBYT CONDENABL;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177;
          A,6 ALUF,Q-D ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,R6 B,17 ALUF,A-Q ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          ILLCH CONDENABL;
          B,L ALUF,ANDDQ ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          ILLCH CONDENABL;
CLOOP:    A,R5 B,R2 ALUF,A-B ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,R2 B,R5 ALUF,A-B-1 ALUD,NONE
          COMM,LDLC T,JMP T,HOLD CYCL,FAST
          SRIGT CONDENABL;
          B,L MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,LC=0;
          B,L MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,ALU COMM,CLFF T,NEXT T,PUSH CYCL,FAST;
          A,1 B,L MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,AARG COMM,LDGPR T,JMP T,POP LCOUNT CYCL,FAST
          TSAVE;
SRIGT:    B,L MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          A,1 B,L MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,AARG COMM,LDGPR T,JMP T,POP LCOUNT CYCL,FAST
          TSAVE;
PLBYT:    ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          77400;
          ALUF,Q-D ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,R7 B,17 ALUF,A-Q ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          ILLCV CONDENABL;
          ALUF,ANDDQ ALUD,Q
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          ILLCV CONDENABL;
          B,L ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          CLOOP;
TSAVE:    A,R2 B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,4 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,D+A ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,14 ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,RETURN F,HOLD;
          A,L B,R1 ALUF,ORAB ALUD,B
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          CONDENABL;
          B,R5 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,Z B,Z ALUF,B-1 ALUD,B,YA
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          LASTW CONDENABL;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUD,NONE
          IDBS,GPR XRF COMM,EWRF T,RETURN T,HOLD CYCL,FAST;
%********************************************************************
% SAVE LAST WORD, TEST OVERFLOW
LASTW:    A,R2 B,17 ALUF,A-D-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          LASTC CONDENABL;
          A,R3 ALUF,ANDAQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
LASTC:    A,1 B,LC ALUD,NONE
          IDBS,GPR XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST
          POVFL CONDENABL;
          A,B B,R4 ALUF,PASSB ALUD,B,YA
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          PWRIT CONDENABL;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,PUSH CYCL,FAST
          30060;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          77577;
          A,0 B,LC ALUF,ANDDQ ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,R1 ALUF,XORAQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,POP;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          POVFL CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          PWRIT;
POVFL:    A,2 B,15 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          PWRIT;
%********************************************************************
% READ NEXT WORD FROM FIRST OPERAND
PREAD:    A,R4 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,B B,R2 ALUF,ZERO ALUD,B,YA
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          PSLUT CONDENABL;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          B,R3 ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,B ALUF,B-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
PSLUT:    B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,RETURN T,POP CYCL,FAST
          30060;
%********************************************************************
% TEST DESTINATION EMPTY, WRITE X,T-FIELD, AND TEST OVERFLOW
PWRIT:    A,X B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,3 B,11 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,A B,R1 ALUF,PASSD ALUD,B
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          POVER CONDENABL;
          A,1 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          WRITS;
          A,2 B,15 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,HOLD CYCL,NORM
          POVEF CONDENABL;
          A,2 B,14 ALUF,MASKDQ ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,2 B,14 ALUF,ANDDQ ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          PUSAV CONDENABL;
POVEF:    B,P ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,D B,D ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,D B,D ALUF,D+A+1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUF,ANDDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
PUSAV:    A,2 B,11 ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,R6 B,P ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          USAV4;
%********************************************************************
% SUBROUTINE TO WRITE FROM XRF LEVEL 1 TO MEMORY
WRITS:    A,2 B,12 ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,1 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,R1 B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,RETURN T,POP CYCL,FAST
          CONDENABL;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,WAIT;
          A,R1 B,R6 ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,F=0;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% X,T-OPERAND EMPTY, TEST OVERFLOW
POVER:    A,2 B,15 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,4 B,R1 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          TOVER CONDENABL;
          A,D B,R7 ALUF,PASSD
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          B,17 ALUF,MASKDQ ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          TOVER CONDENABL;
POVEC:    B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USAV4;
TOVER:    A,R1 B,D ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,D B,D ALUF,D+A+1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          USAV4;
%********************************************************************
% ILLEGAL CODE, SET ADDRESS AND CODE IN A,D-REG.
ILLCV:    A,7 B,STS ALUF,A+B ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,D B,R3 ALUF,MASKDA ALUD,B
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          ILLC;
ILLCH:    A,7 B,STS ALUF,A+B ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,D B,R3 ALUF,ORDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
ILLC:     A,3 B,10 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,4 B,R1 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          TILOV CONDENABL;
          A,STS B,R6 ALUF,A-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,3 B,R1 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,R3 ALUF,MASKAB ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TOVER CONDENABL;
          A,1 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,5 B,11 ALUF,PASSD ALUD,B
          IDBS,REG T,JMP T,PUSH CYCL,NORM
          WRITS;
TILOV:    A,R6 B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          PNWRT CONDENABL;
          A,17 ALUF,D-1 ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUF,ANDDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,LC ALUF,Q-D ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,4 B,R1 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          TOVER CONDENABL;
PNWRT:    A,R4 B,A ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,D ALUF,D+A+1 ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          USAV4;
%********************************************************************
% ILLEGAL CODE IN SIGN, GIVE ADDRESS AND CODE IN A,D-REG.
ILCDP:    A,3 B,11 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT;
          A,4 B,R1 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          TOVER CONDENABL;
          A,14 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          A,D ALUF,ANDAQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,17 B,D ALUF,PASSB ALUD,Q
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          BAANN CONDENABL;
          A,R7 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R6 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          ORDBN CONDENABL;
          A,D ALUF,MASKDA ALUD,Q
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          BAANN;
ORDBN:    A,D ALUF,ORDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
BAANN:    B,D ALUF,MASKDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          37;
          A,D B,D ALUF,ORDA ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          USAV4;
%********************************************************************
% COMMERCIAL INSTRUCTION: UPACK (A,D -BCD-FIELD -> X,T -ASCII-FIELD)
%********************************************************************
UPACK:    B,R5 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,T B,R1 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,D ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          TNOTE CONDENABL;
          A,0 B,R4 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          TEMPT CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          INIT;
%********************************************************************
% READ FIRST AND LAST WORD OF X,T-OPERAND
TNOTE:    A,3 B,11 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,3 B,12 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,X B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,T B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWAB;
          A,R6 B,R2 ALUF,ZERO ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,JMP T,HOLD CYCL,FAST
          URBOT;
TEMPT:    A,3 B,11 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,3 B,12 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,FAST
          TAEMP;
URBOT:    A,R7 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,COND F,NEXT F,HOLD;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          URFIR CONDENABL;
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          377;
          A,1 B,R5 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST;
URFIR:    A,X B,T ALUF,PASSB ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,2 B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST
          URFIC CONDENABL;
          B,Z ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          177400;
URFIC:    A,Z ALUF,ANDDA ALUD,Q
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,WAIT;
          A,2 B,11 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% TEST A,D-OPERAND EMPTY, AND READ IT TO RF LEVEL 1
TAEMP:    A,B B,R2 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,HOLD;
          A,A B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          UNEMP CONDENABL;
          A,1 B,17 ALUD,NONE
          IDBS,BARG XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,R3 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          17;
          A,0 B,STS ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          UEMP1;
POSS:     B,13 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          UDCS;
UNEMP:    ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          LWA;
          A,R1 B,17 ALUF,A+1 ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,FAST;
          ALUF,Q-1 ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,A B,LC ALUF,Q-A-1 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15;
          A,1 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,WAIT;
          A,D B,R2 ALUF,PASSA ALUD,B
          IDBS,GPR COMM,LDLC T,JMP T,PUSH CYCL,FAST
          TTPWD;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
UEMP1:    A,2 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,PUSH CYCL,FAST
          CSAV1;
          A,R3 B,2 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,D B,R7 ALUF,PASSD
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          HALVB CONDENABL;
          ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          B,17 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          A,1 B,R2 ALUF,D+1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          UDECC;
HALVB:    A,Z B,Z ALUF,ANDDA ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          170000;
          B,R2 ALUF,D+1 ALUD,B
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% IF X,T-OPERAND EMPTY, TEST OVERFLOW
UDECC:    A,3 B,11 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,HOLD;
          B,STS ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          UDECB CONDENABL;
          B,16 ALUF,PASSQ ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          UDECA CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          EOVER CONDENABL;
INCRP:    B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USAV4;
UDECA:    B,STS ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          EOVER CONDENABL;
          A,1 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,STS ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          EOVER CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          INCRP;
EOVER:    ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,D B,D ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,D B,D ALUF,D+A+1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          USAV4;
%********************************************************************
% DECODE SIGN REPRESENTATION OF X,T-OPERAND AND CONVERT SIGN
UDECB:    A,15 B,R3 ALUF,PASSQ ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,2 B,B ALUF,D-1 ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          ULEAD CONDENABL;
          A,4 B,R1 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST;
          A,Z B,17 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,Z B,15 ALUF,A-D ALUD,NONE
          IDBS,BARG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          POSS CONDENABL;
          A,Z B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          POSS CONDENABL;
UDCS:     A,R1 ALUF,ORDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,2 B,14 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,14 B,R3 ALUF,PASSB ALUD,Q
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,R2 ALUF,B-1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          ULEAD CONDENABL;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F11 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          USEPT CONDENABL;
%********************************************************************
% EMBEDDED TRAILING
          A,R3 B,Z ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          A,2 B,Z MIS,ZIN ALUF,PASSB ALUD,SRB
          IDBS,BMG COMM,LDGPR T,NEXT T,POP LCOUNT CYCL,FAST;
          A,Z B,17 ALUF,ANDDA ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST;
          B,Z ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          16;
          B,12 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,R2 B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          ILLE CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          SUBEM;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          SAME CONDENABL;
          B,R3 ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,R5 ALUF,PASSD ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          UPLOP;
SUBEM:    A,R1 B,4 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          EMPOS CONDENABL;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,RETURN T,POP CYCL,FAST
          175 CONDENABL;
          B,R1 ALUF,D+Q ALUD,B
          IDBS,ARG T,RETURN T,POP CYCL,FAST
          111;
EMPOS:    B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,RETURN T,POP CYCL,FAST
          173 CONDENABL;
          A,10 B,R1 ALUF,D+Q ALUD,B
          IDBS,AARG T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SEPARATE TRAILING
USEPT:    A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,1 B,R5 ALUF,PASSD ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          UPLOP CONDENABL;
          A,2 B,14 ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
SAME:     A,0 B,17 ALUD,NONE
          IDBS,SWAP XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          B,B ALUF,PASSD ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          16;
          B,Z ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          16;
          B,R4 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,R3 ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          LAWRA CONDENABL;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          UCLOP;
%********************************************************************
% LEADING SIGN IN X,T-OPERAND
ULEAD:    B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
UPLOP:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUD,NONE
          IDBS,GPR XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
%********************************************************************
% CONVERSION LOOP
%
% R2 = NIBLE-COUNTER
% R5 = BYTE-COUNTER
% R3 = CURRENT BCD-WORD
% R1 = CURRENT ASCII-WORD
% L  = SCRATCH
% Q  = SCRATCH
UCLOP:    B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,PUSH CYCL,FAST
          16;
          A,R2 B,14 ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,FAST
          UPRED CONDENABL;
          A,R2 B,R5 ALUF,A-B ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,R3 B,L ALUF,PASSA ALUD,B
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          POSSH CONDENABL;
          A,R5 B,R2 ALUF,A-B-1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          B,L MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          B,L MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          UPLP;
POSSH:    B,L MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,ALU COMM,CLFF T,NEXT T,PUSH CYCL,FAST
          COND,LC=0;
          B,L MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          B,L MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
UPLP:     A,L ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R5 B,4 ALUF,PASSA ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          RBYT CONDENABL;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          7400;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          5000;
          ALUF,Q-D ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R5 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          ILL CONDENABL;
          ALUF,ORDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          30000;
          A,R1 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,B B,R4 ALUF,B-1 ALUD,B,YA
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          B,B ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          LAWRD CONDENABL;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,RETURN T,HOLD CYCL,FAST;
RBYT:     ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          17;
          B,12 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,1 B,R5 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,FAST
          ILL CONDENABL;
          B,R1 ALUF,ORDQ ALUD,B
          IDBS,ARG T,RETURN T,HOLD CYCL,FAST
          60;
%********************************************************************
% READ NEXT WORD FROM A,D-OPERAND TO Q,R3
UPRED:    B,STS ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,Z B,R2 ALUF,ZERO ALUD,B,YA
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,FAST
          SLUT CONDENABL;
          B,STS ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,1 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM;
          B,Z ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          SUPRD;
SLUT:     ALUF,ZERO ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
SUPRD:    B,R3 ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% SAVE LAST WORD OF X,T OPERAND AND TEST OVERFLOW
LARDC:    B,L ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,FAST
          LAWRC;
LAWRA:    B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
LAWRD:    A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSQ ALUD,NONE  % OBS! LAST LC (B)
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,R2 B,17 ALUF,A-D-1 ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,LC B,L ALUF,D-1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          LARDC CONDENABL;
LAWRC:    A,L B,R3 ALUF,MASKAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,STS ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          UPOVR CONDENABL;
          B,Z ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST
          TOVFL CONDENABL;
TLEAD:    A,15 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          TLEAC;
TOVFL:    B,STS ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,FAST;
          A,1 B,LC ALUF,PASSD ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,JMP F,POP;
          B,STS ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          UPOVR CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,FAST
          TLEAD;
UPOVR:    A,2 B,15 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TLEAD;
%********************************************************************
% TEST LEADING SIGN OF X,T-OPERAND
TLEAC:    A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          UWRIT CONDENABL;
          A,14 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,13 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,FAST
          UWRIT CONDENABL;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          B,R3 ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USEPL CONDENABL;
%********************************************************************
% EMBEDDED LEADING
          A,2 B,14 ALUD,NONE
          IDBS,REG COMM,LDGPR T,NEXT T,HOLD CYCL,NORM;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          TOPHB CONDENABL;
          B,17 ALUF,ANDDQ ALUD,Q
          IDBS,BARG T,JMP T,PUSH CYCL,FAST
          SUBEM;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          377;
          A,R3 ALUF,MASKDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,R1 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
LEADC:    A,B ALUF,A+1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,FAST;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,JMP T,HOLD CYCL,FAST
          UWRIT;
TOPHB:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,FAST;
          B,17 ALUF,ANDDQ ALUD,Q
          IDBS,BARG T,JMP T,PUSH CYCL,FAST
          SUBEM;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          377;
          A,R3 ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,ORDQ ALUD,Q
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          LEADC;
%********************************************************************
% SEPARATE LEADING
USEPL:    A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,NEXT F,HOLD;
          A,10 ALUF,D-1 ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,FAST
          SEPRB CONDENABL;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          7400;
          A,R3 ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          A,R3 ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USOVF CONDENABL;
          A,2 B,14 ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          ALUF,ORDQ ALUD,Q
          IDBS,SWAP T,JMP T,HOLD CYCL,FAST
          LEADC;
SEPRB:    ALUF,INVQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,17 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,PUSH;
          A,R3 ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          USOVF CONDENABL;
          A,2 B,14 ALUF,ORDQ ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,NORM
          LEADC;
USOVF:    A,2 B,15 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,POP CYCL,FAST;
%********************************************************************
% WRITE X,T OPERAND. TEST OVERFLOW IN TOP-WORD
UWRIT:    A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          UWRTS;
          A,2 B,15 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,HOLD CYCL,NORM
          UVFLT CONDENABL;
          A,T B,17 ALUF,PASSA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          WRTOP CONDENABL;
          A,10 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST;
          ALUF,ANDDQ ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          WRTOP CONDENABL;
UVFLT:    A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,10 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          UVFLO CONDENABL;
          A,Z ALUF,ANDAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
UVFLO:    ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          37;
          A,D B,D ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
          B,P ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          3;
          A,D B,D ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
WRTOP:    A,2 B,11 ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT CYCL,NORM;
          A,R6 B,P ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% EXIT, UNSAVE REGISTERS AND STATUS
USAV4:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CUSV1;
          A,2 B,16 ALUD,NONE STS,LO
          IDBS,REG T,JMP T,POP CYCL,NORM
          INIT;
%********************************************************************
% SUBROUTINE TO WRITE WORDS FROM RF LEVEL 0 TO MEMORY
UWRTS:    A,2 B,12 ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,NORM;
          A,0 B,17 ALUF,PASSQ ALUD,NONE
          IDBS,ALU XRF COMM,EWRF T,NEXT T,HOLD CYCL,FAST;
          A,R6 B,R1 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,PUSH;
          B,17 ALUD,NONE
          IDBS,BARG COMM,LDLC T,RETURN T,POP CYCL,FAST
          0 CONDENABL;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,0 B,LC ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,WAIT;
          A,R6 B,R1 ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,F=0;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,FAST;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,FAST;
%********************************************************************
% ILLEGAL CODE, TEST IN WHITCH BYTE AND GIVE ADDRESS AND CODE IN A,D REG
ILLE:     B,10 ALUD,NONE
          IDBS,BARG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST;
          AB,OCTNR ALUF,D+A ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
ILL:      A,R2 B,14 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          A,17 B,R4 ALUF,PASSB ALUD,Q
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,FAST
          UILCV CONDENABL;
          A,D B,R3 ALUF,ORDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,FAST
          ILC;
UILCV:    A,D B,R3 ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,FAST;
ILC:      A,3 B,10 ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,NORM
          COND,F=0 F,NEXT F,HOLD;
          A,4 B,R7 ALUF,D-1 ALUD,B
          IDBS,AARG T,JMP T,HOLD
          ULONE CONDENABL;
          A,X ALUF,A+Q ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          B,R1 ALUF,Q-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          IL;
ULONE:    A,X B,R1 ALUF,A+Q ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
IL:       A,R7 B,R3 ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,0 B,17 ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,JMP T,PUSH CYCL,NORM
          UWRTS;
          A,R1 B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          A,0 B,LC ALUF,PASSD ALUD,Q
          IDBS,REG XRF T,NEXT T,HOLD CYCL,NORM
          NTOP CONDENABL;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          COND,F15 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          NTOP CONDENABL;
          A,R5 B,10 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          EOVER CONDENABL;
NTOP:     A,STS B,A ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,R3 B,D ALUF,D+A+1 ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,FAST
          USAV4;
%********************************************************************
%********************************************************************
% GECO-INSTRUCTION
%********************************************************************
%********************************************************************
GECO:     B,R2 ALUF,PASSD ALUD,B
          IDBS,GPR COMM,LDLC T,NEXT T,HOLD CYCL,WAIT
          COND,LC=0;
          A,D B,R1 ALUF,A ALUD,B STS,EA
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,ARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW
          0;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          122;
          B,R7 ALUF,B ALUD,B CRY,C
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,R1 ALUF,A+1 ALUD,B,YA STS,EA
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          A,0 B,LC ALUD,NONE
          IDBS,DBR XRF COMM,EWRF T,NEXT T,POP LCOUNT CYCL,WAIT;
          A,B B,R1 ALUF,PASSA ALUD,B
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          AB,EXMOD ALUD,NONE
          IDBS,REG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,PUSH
          COND,LC=0;
          A,R1 B,R1 ALUF,A+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          A,0 B,LC ALUD,NONE
          IDBS,REG XRF T,NEXT T,HOLD CYCL,WAIT;
          A,R2 B,17 ALUF,ANDDA ALUD,Q
          IDBS,BARG T,NEXT T,POP LCOUNT CYCL,WAIT;
          A,L B,D ALUF,A+B ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD;
          B,A ALUF,B ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD;
          A,B B,B ALUF,A+Q+1 ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD;
          B,X ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD
          COND,F15 F,NEXT F,HOLD;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          INIT CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD
          INIT;
%********************************************************************
%********************************************************************
% INSTRUCTIONS TO SPEED UP SINTRAN III SEGMENT HANDLING
% THE INSTRUCTION GROUP 'S3SEG'   OPCODE 1403XX
%********************************************************************
%********************************************************************
% OPCODE 140300   :   SETPT
% SETPT:   JXZ * 10   % FINISHED
% LDDTX 20
% BSET ZRO 130 DA % PGU-BIT
% LDBTX 10
% 177777   % OLD BUG IN LDBTX
% STD ,B   % ALWAYS INSIDE PAGE TABLE
% LDXTX 00
% JMP *-7
%********************************************************************
% OPCODE 140301   :   CLEPT
% CLEPT:   JXZ * 11   % FINISHED
% LDBTX 10
% 177777   % OLD BUG IN LDBTX
% LDA ,B
% JAZ * 3
% STATX 20
% STZ ,B   % ALWAYS INSIDE PAGE TABLE
% LDXTX 00
% JMP *-10
%********************************************************************
% OPCODE 140302   :   CLNREENT
% READ ADDRESS  A+2 TO FIND PAGE TABLE TO BE AFFECTED.
% READ RT-DESCRIPTION BITMAP WORDS, FOUND FROM ADDRESS X+25.
% CLEAR PAGE-TABLE ENTRIES CORRESPONDING TO 1-BITS IN BITMAP,
% THE LAST BITMAP-WORD IS IN ADDRESS X+T.
%********************************************************************
% OPCODE 140303   :   CHREENTPAGES
% 1. READ ADDRESS  D,X -> R1 ;  D,X -> PREVIOUS (SCRATCH REG)
% 2. IF R1 = 0; SKIP RETURN (FINISHED)
% 3. READ ADDRESS T,R1+2
% 4. IF NOT WIP; T,R1 -> PREVIOUS; READ ADDR T,R1  ->  R1; GOTO 2
% 5. READ ADDRESS T,R1 -> R2
% 6. WRITE R2 -> ADDRESS PREVIOUS
% 7. R1 -> X ; PREVIOUS -> D,A ; RETURN
%********************************************************************
% OPCODE 140304   :   CLEPU
% AS 'CLEPT', BUT INCLUDING WORKING SET INFORMATION
% FOR ALL PAGE-TABLE ENTRIES HANDLED
% IF PGU OF ENTRY IS 1
% D /\ 300
% B /\ 776 SHR 1 - D
% B-REG BITS 0-3 IS NOW BIT NUMBER
% B-REG BITS 4-6 IS NOW WORD NUMBER
% SET BIT IN 8-WORD TABLE IN PAGE-MAP BANK
% POINTED TO BY L-REGISTER
% LAYOUT OF 8-WORD TABLE :
% BIT 15                                          BIT 0
% ---------------------------------------------
% L-REG -> WORD 0 # PAGE 17                              PAGE 0 #
% WORD 1 # PAGE 37                                     20 #
% WORD 2 # PAGE 57                                     40 #
% WORD 7 # PAGE 177                                   160 #
% ---------------------------------------------
%********************************************************************
%********************************************************************
S3SEG:    A,A ALUF,A+1
          IDBS,DBR COMM,LDGPR T,JMP0-3 T,HOLD CYCL,WAIT
          SETPT;
%********************************************************************
SEPT1:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,PUSH CYCL,SLOW
          PATA1;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,EXRQ T,JMP T,PUSH
          PATA4;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          B,D ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,B ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          A,R7 B,A ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,B ALUF,A+1 ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD
          COND,IRQ F,JMP F,HOLD;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          PATA2 CONDENABL;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,POP
          PATA3;
%********************************************************************
CLPU1:    B,R5 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD;
CLPT1:    A,D B,D ALUF,A+B ALUD,Q
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          B,R4 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          600;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,PUSH CYCL,SLOW
          PATA1;
          A,B ALUF,PASSA ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,JMP T,PUSH
          PATA4;
          A,A B,R7 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          PATA2 CONDENABL;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD
          COND,COND F,NEXT F,HOLD;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R4 ALUF,Q-A ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          CLPT3 CONDENABL;
% CLEPU-INSTRUCTION AND PGU-BIT = 1
          B,R3 ALUF,ANDDQ ALUD,SRB  % BIT NO.
          IDBS,ARG T,NEXT T,HOLD
          36;
          B,R6 ALUF,ANDDQ ALUD,SLB
          IDBS,ARG T,NEXT T,HOLD
          740;
          A,R6 B,R6 ALUF,A+B ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD;
          B,R6 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          A,L B,R6 ALUF,D+A ALUD,B
          IDBS,SWAP T,NEXT T,HOLD;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,LC ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
CLPT3:    A,B ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD
          COND,IRQ F,JMP F,HOLD;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          PATA2 CONDENABL;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,POP
          PATA3;
%********************************************************************
PATA1:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          122;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
PATA2:    A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          B,X ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          PATA3 CONDENABL;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          B,B ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,B B,B ALUF,A+B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD;
          B,B ALUF,ORDQ ALUD,B
          IDBS,ARG T,RETURN T,HOLD
          177000;
PATA3:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          AB,EXMOD ALUD,NONE
          IDBS,REG COMM,XMM T,JMP T,POP CYCL,SLOW
          USGPR;
PATA4:    B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,RETURN T,POP CYCL,WAIT
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
CLNR1:    B,R5 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD
          COND,F=0 F,NEXT F,HOLD;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR CONDENABL;
          B,R7 ALUF,ANDDQ ALUD,SLB
          IDBS,ARG T,NEXT T,HOLD
          300;
          B,R1 ALUF,D+A ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          177000;
          A,X ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD;
          B,R2 ALUF,D+Q ALUD,B
          IDBS,ARG T,NEXT T,HOLD
          25;
          A,T B,R3 ALUF,A+Q ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R2 B,R2 ALUF,A+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD;
CLNR4:    B,R4 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,17 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDLC T,JMP T,HOLD
          CLNR5 CONDENABL;
          A,0 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD;
          B,2 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,PUSH
          COND,F=0 F,NEXT F,HOLD;
          A,R4 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,JMP T,PUSH
          CLNR3;
          B,R6 ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,POP LCOUNT
          COND,F=0 F,NEXT F,HOLD;
CLNR2:    A,R3 B,R2 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,F15 F,JMP F,HOLD;
          A,R2 B,R2 ALUF,A+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD
          CLNR4 CONDENABL;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,POP CYCL,WAIT
          USGPR;
CLNR3:    A,R1 B,R1 ALUF,A+Q ALUD,B
          IDBS,ALU T,RETURN T,POP
          CONDENABL COND,LC=0;
          A,R1 ALUF,A-Q ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,WAIT;
CLNR5:    A,5 B,R1 ALUF,D+Q ALUD,B
          IDBS,BMG T,JMP T,HOLD
          CLNR2;
%********************************************************************
CHRE1:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          122;
          A,D B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          A,X B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
CHRE2:    B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,NEXT F,HOLD;
          A,T B,R1 ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          CHRE4 CONDENABL;
          A,R1 ALUF,A+1 ALUD,NONE
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD;
          A,R4 ALUF,ANDDA ALUD,NONE
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,R1 ALUF,A-1 ALUD,B
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD
          CHRE3 CONDENABL;
% WIP
          B,R2 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R6 B,D ALUF,PASSA ALUD,B
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          A,R7 B,A ALUF,PASSA ALUD,B
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R1 B,X ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          PATA3;
% NOT WIP
CHRE3:    A,T B,R6 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
          A,R1 B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD
          CHRE2;
% FINISHED
CHRE4:    B,P ALUF,B+1 ALUD,B
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          AB,EXMOD ALUD,NONE
          IDBS,REG COMM,XMM T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
%********************************************************************
% MOVE-WORDS - INSTRUCTION : OPCODE 1431XX
%********************************************************************
%********************************************************************
MOVEW:    A,13 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD;
          A,L ALUF,A-Q-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD
          COND,CRY F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD  % > 2K WORDS
          CONDENABL COND,F=0 F,JMP F,HOLD;
          A,L ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP0-3 T,HOLD
          MVWVC;
% PT -> PT
MVW0:     A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CPT;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CPT;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          PTRD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          PTWR;
% PT -> APT
MVW1:     A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CPT;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CAPT;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          PTRD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          APTWR;
% PT -> PHYSICAL
MVW2:     ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,LDIR T,NEXT T,HOLD CYCL,WAIT
          COND,RESTR F,NEXT F,HOLD;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PRIVI CONDENABL;
          A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          CPT;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          ALUD,NONE
          IDBS,ARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          122;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          PTRD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          PHWR;
% APT -> PT
MVW3:     A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CAPT;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CPT;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          APTRD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          PTWR;
% APT -> APT
MVW4:     A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CAPT;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          CAPT;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          APTRD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          APTWR;
% APT -> PHYSICAL
MVW5:     ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,LDIR T,NEXT T,HOLD CYCL,WAIT
          COND,RESTR F,NEXT F,HOLD;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PRIVI CONDENABL;
          A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          CAPT;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          ALUD,NONE
          IDBS,ARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          122;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          APTRD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          PHWR;
% PHYSICAL -> PT
MVW6:     ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,LDIR T,NEXT T,HOLD CYCL,WAIT
          COND,RESTR F,NEXT F,HOLD;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PRIVI CONDENABL;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          CPT;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          ALUD,NONE
          IDBS,ARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          122;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          PHRD;
          B,A ALUF,B ALUD,B CRY,C
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PTWR;
% PHYSICAL -> APT
MVW7:     ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,LDIR T,NEXT T,HOLD CYCL,WAIT
          COND,RESTR F,NEXT F,HOLD;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PRIVI CONDENABL;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH
          CAPT;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          ALUD,NONE
          IDBS,ARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          122;
          ALUD,NONE
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          PHRD;
          B,A ALUF,B ALUD,B CRY,C
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          APTWR;
% PHYSICAL -> PHYSICAL
MVW8:     ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,LDIR T,NEXT T,HOLD CYCL,WAIT
          COND,RESTR F,NEXT F,PUSH;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          PRIVI CONDENABL;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          ALUD,NONE
          IDBS,ARG COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          122;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,PUSH CYCL,SLOW
          PHRD;
          A,X B,A ALUF,B ALUD,B,YA CRY,C
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PHWR;
% SUBROUTINES FOR MOVEW
% CHECK THAT PT-ADDRESSED FIELD IS PRESENT
CPT:      ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD
          CPT1;
% CHECK THAT APT-ADDRESSED FIELD IS PRESENT
CAPT:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,JMP T,HOLD
          CPT1;
CPT1:     A,L B,R2 MIS,ZIN ALUF,PASSA ALUD,SRB
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R2 ALUF,A+Q ALUD,NONE
          IDBS,ALU MIS,HOLD COMM,RDRQ T,NEXT T,HOLD;
          A,L B,R2 ALUF,A-1 ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R2 ALUF,A+Q ALUD,NONE
          IDBS,ALU MIS,HOLD COMM,RDRQ T,NEXT T,HOLD
          COND,IRQ F,RETURN F,POP;
          ALUD,NONE
          IDBS,DBR T,RETURN T,HOLD CYCL,WAIT;
% READ PT-WORD
PTRD:     A,D B,D ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD
          INTER CONDENABL;
% READ APT-WORD
APTRD:    A,D B,D ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,JMP T,HOLD
          INTER CONDENABL;
% READ PHYSICAL WORD
PHRD:     A,D B,D ALUF,B+1 ALUD,B,YA STS,EA
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD
          COND,IRQ F,RETURN F,POP;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          INTER CONDENABL;
% INSTRUCTION IS INTERRUPTED
INTER:    B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD;
% INSTRUCTION IS FINISHED
MVWEX:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          121;
          AB,EXMOD ALUD,NONE
          IDBS,REG COMM,XMM T,JMP T,HOLD CYCL,SLOW
          INIT;
% WRITE PT-WORD
PTWR:     A,T B,L ALUF,B-1 ALUD,B,YA
          IDBS,ALU MIS,PT COMM,WRRQ T,NEXT T,HOLD
          COND,F=0 F,RETURN F,HOLD;
          A,R1 B,T ALUF,B+1 ALUD,B,YA
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          CONDENABL COND,IRQ F,RETURN F,POP;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          MVWEX;
% WRITE APT-WORD
APTWR:    A,T B,L ALUF,B-1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD
          COND,F=0 F,RETURN F,HOLD;
          A,R1 B,T ALUF,B+1 ALUD,B,YA
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          CONDENABL COND,IRQ F,RETURN F,POP;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          MVWEX;
% WRITE PHYSICAL WORD
PHWR:     A,T B,L ALUF,B-1 ALUD,B,YA
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD
          COND,F=0 F,RETURN F,HOLD;
          A,R1 B,T ALUF,B+1 ALUD,B,YA STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,COND F,RETURN F,HOLD;
          B,X ALUF,B ALUD,B CRY,C
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,WAIT
          CONDENABL COND,IRQ F,RETURN F,POP;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          MVWEX;
%********************************************************************
%********************************************************************
% TSET - INSTRUCTION, OPCODE 140123, RDUS-INSTRUCTION, OPCODE 140127
%********************************************************************
%********************************************************************
TSET:     B,13 ALUD,NONE
          IDBS,BARG COMM,LDIR T,JMP T,PUSH CYCL,SLOW
          TSET1;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD;
          A,Z ALUF,A-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          USGPR;
RDUS:     B,13 ALUD,NONE
          IDBS,BARG COMM,LDIR T,JMP T,PUSH CYCL,SLOW
          TSET1;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          USGPR;
TSET1:    ALUD,NONE
          IDBS,ALU COMM,XMM T,NEXT T,HOLD CYCL,SLOW;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD;
          B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,RETURN T,POP CYCL,WAIT;
%********************************************************************
%********************************************************************
% PLANC ENTER- AND LEAVE- ROUTINES
%********************************************************************
% 5INIT IN PLANC
5INIT_CX: A,P B,R1 ALUF,A+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          176;
          A,B B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRC_CX;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          172;
          B,R7 ALUF,D+Q ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRB_CX;
          ALUF,PASSD ALUD,Q
          IDBS,STS T,NEXT T,HOLD CYCL,WAIT;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          ALUF,XORDQ ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,0 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,FAST
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,P ALUF,A+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          TSTAC_CX CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          BCHNG;
%********************************************************************
% 5ENTR IN PLANC
ENTR_CX:  B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          176;
          A,B B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          A,B B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRC_CX;
          A,R2 B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,FAST
          172;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRB_CX;
TSTAC_CX: A,R7 B,R3 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,CRY F,JMP F,POP;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST
          BCHNG CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,FAST
          BCHNG;
ENTRC_CX: ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          B,L ALUF,B+1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,7 B,STS ALUF,D+Q ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,WAIT;
          A,R6 B,R3 ALUF,A+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,FAST;
          A,STS B,R3 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R6 B,R4 ALUF,A-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,WAIT;
ENTRB_CX: A,STS B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R5 ALUF,D-A ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,WAIT;
          A,STS B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,STS B,R3 ALUF,A+Q ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,WAIT;
%********************************************************************
% 5LEAV AND ELEAV IN PLANC
ELEAV_CX: A,7 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,WAIT;
          A,B ALUF,A-Q ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,D-1 ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          173;
          A,B ALUF,A-Q ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,FAST;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
LEAV_CX:  B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          177;
          A,B B,R1 ALUF,A-B ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,STS ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R1 ALUF,A-1 ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,FAST;
          B,P ALUF,PASSD ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,POP CYCL,WAIT
          BCHNG;
BCHNG:    A,STS B,B ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,FAST
          INIT;
%********************************************************************
%********************************************************************
% VECTOR TO FIND TYPE OF MOVEW INSTRUCTION
7340/
MVWVC:    A,R2 ALUF,D+1
          IDBS,AARG T,RETURN T,HOLD CYCL,WAIT
          MVW0 CONDENABL;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW1 CONDENABL CYCL,WAIT;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW2 CONDENABL CYCL,WAIT;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW3 CONDENABL CYCL,WAIT;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW4 CONDENABL CYCL,WAIT;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW5 CONDENABL CYCL,WAIT;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW6 CONDENABL CYCL,WAIT;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW7 CONDENABL CYCL,WAIT;
          A,12 IDBS,AARG ALUF,D+1 ALUD,Q T,RETURN T,HOLD MVW8 CONDENABL CYCL,WAIT;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
%********************************************************************
%********************************************************************
% VECTOR TO SELECT BETWEEN INSTRUCTIONS IN THE 1403XX-GROUP
SETPT:    A,13 B,R7 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD
          SEPT1;
CLEPT:    B,R7 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD
          CLPT1;
CLNRE:    ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,RDRQ T,JMP T,HOLD
          CLNR1;
CHREE:    A,14 B,R4 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD
          CHRE1;
CLEPU:    A,13 B,R7 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD
          CLPU1;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          T,JMP T,HOLD ALUD,NONE IDBS,ALU ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          ILLIN;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          ILLIN;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD
          ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD 27;
