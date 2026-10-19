%#MODEL nd100
%
% ND-100 MICROCODE, 32 BIT FLOATING POINT VARIANT (PROM SET 026XX), ON THE 3033S BASE
%
% This file is the 3033S program (ND-100-3033S.uc) with the words 0517 - 1105 replaced by the
% printed listing "32-BITS ND-100 FLOATING (PROM 026XX)" (printout of 16.12.1985; scan
% ND100-MICROCODE.pdf, pages 221-233). There is NO chip dump of the 026XX PROMs, so the
% instruction words of the replaced part cannot be compared with a ROM image. What was checked
% is that the file assembles, that every label resolves, and that the 1801 words outside 0517 -
% 1105 are bit for bit the words of the 3033S chips (so the entry points FSB, FAD, FMU, FDV, NLZ,
% DNZ and IOX of the 32 bit routines are at the same addresses as in the 48 bit routines).
% CYCL: as in ND-100-3033S.uc, a printed CYCL,FAST or missing CYCL is written CYCL,SLOW.
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
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,FETCH F,NEXT F,HOLD;
          A,15 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          FTCH CONDENABL;
%********************************************************************
% INCREMENT P IF NOT FETCH
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
FTCH:     A,13 ALUF,ORDQ ALUD,Q
          IDBS,BMG COMM,CLIRQ T,NEXT T,HOLD CYCL,SLOW
          COND,IRQ F,JMP F,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          NOINT CONDENABL;
%********************************************************************
% INTERRUPT IS PENDING
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,STP F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          BRKZZ CONDENABL;
%********************************************************************
% NO INTERRUPT IS PENDING, IT CAN BE MASTER CLEAR OR IOF-PAGEFAULT
NOINT:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,FETCH F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          FTCH2 CONDENABL;
%********************************************************************
% DECREMENT P, IT HAS BEEN INCREMENTED
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          FTCH2;
%********************************************************************
% EXECUTE LEVEL CHANGE OR JMP *
FTCH2:    PIC,RVECT ALUD,NONE
          IDBS,GPR T,MAPJ T,JMP T,HOLD CYCL,SLOW
          FETCH;
%********************************************************************
%********************************************************************
% MAPPING POINT FOR ALL INSTRUCTIONS. NEXT MICROADDRESS IS TAKEN FROM
% MAPPING PROM, OR CONTROLLED BY THE INTERRUPT HARDWARE (INTERRUPT VECTOR)
%********************************************************************
FETCH:    A,P B,Z ALUF,ZERO ALUD,B,YA
          IDBS,ALU MIS,FETCH COMM,RDRQ T,JMP T,PUSH CYCL,SLOW;
%********************************************************************
% RETURN FROM P-MODIFYING ROP- OR BOP-INSTRUCTION
PMODX:    ALUD,NONE
          IDBS,DSABL T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% RETURN AFTER JUMPS, OR WHENEVER NEW FETCH OF INSTRUCTION HAS TO BE DONE
INIT:     B,P ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,FETCH COMM,RDRQ T,NEXT T,PUSH CYCL,SLOW;
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
          IDBS,GPR T,NEXT T,MAPJ T,HOLD CYCL,SLOW
          FETCH CONDENABL;
%********************************************************************
% *+1 HAS BEEN CHANGED
          PIC,LOSTS B,P ALUF,B-1 ALUD,B
          IDBS,AARG COMM,EPIC T,NEXT T,HOLD CYCL,SLOW
          10;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% RETURN WITH NEXT INSTRUCTION IN GPR
USGPR:    PIC,RVECT B,P ALUF,B+1 ALUD,B
          IDBS,GPR T,MAPJ T,HOLD CYCL,SLOW
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
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFS;
          ALUF,ZERO ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STA:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFS;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STT:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFS;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STX:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFS;
          A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFS;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          WRRQ;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
STF:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
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
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,R2 ALUF,D+1 ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,HOLD;
          B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,WRRQ MIS,HOLD T,NEXT T,HOLD CYCL,SLOW
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
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDT:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,T ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDX:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,X ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
LDAD:     B,A ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          B,D ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
LDF:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,T ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
NEXT:     B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,HOLD COMM,RDRQ T,JMP T,HOLD CYCL,SLOW
          LDAD;
ADD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          A,A B,A ALUF,D+A ALUD,B STS,EA
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
SUB:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          A,A B,A ALUF,A-D ALUD,B STS,EA
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
AND:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          A,A B,A ALUF,ANDDA ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
ORA:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          A,A B,A ALUF,ORDA ALUD,B
          IDBS,DBR T,JMP T,POP CYCL,WAIT
          USGPR;
%********************************************************************
%********************************************************************
% MULTIPLY SINGLE PRECISION
%********************************************************************
MPY:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,R7 ALUF,PASSD ALUD,B  % SAVE GPR (NEXT INSTR)
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q  % READ STATUS
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          B,STS ALUF,MASKDQ ALUD,B  % RESET DYN. OVERFLOW
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          20;
          A,A B,R2 ALUF,PASSA ALUD,B  % COPY A-REG.
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          B,R3 ALUF,PASSD ALUD,B  % READ MEM. OPERAND
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          MPY1 CONDENABL;
          B,R2 ALUF,-B ALUD,B  % NEGATIVE A-REG.
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,JMP;
MPY1:     B,16 ALUF,ZERO ALUD,Q  % LOAD LOOP-COUNTER
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          MPY2 CONDENABL;
          A,R3 ALUF,-A ALUD,NONE  % NEG. MEM.-OPERAND
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
MPY2:     B,R5 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          A,R2 B,R5 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD  % MAKE RESULT IN R5
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW
          LCOUNT;
          B,R5 ALUF,PASSB ALUD,SLD
          MIS,APT T,NEXT T,HOLD CYCL,SLOW;
          B,R5 MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT;
          B,R4 ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MPY3 CONDENABL;
          B,R4 ALUF,PASSD ALUD,B  % SET DYN. & STAT. OVF.
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          60;
MPY3:     A,STS B,R4 ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R3 ALUF,XORAB ALUD,NONE  % TEST SIGN
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MPY4 CONDENABL;
          B,A ALUF,-B ALUD,B  % INVERT RESULT
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
MPY4:     A,R7 ALUF,PASSA ALUD,NONE  % FILL GPR WITH NEXT
          IDBS,ALU COMM,LDGPR T,JMP T,POP CYCL,SLOW
          USGPR;
%********************************************************************
%********************************************************************
% JUMP INSTRUCTIONS
%********************************************************************
JMP:      ALUF,D-1
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFJ;
JPL:      A,P B,L ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          JMP;
JAZ:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F=0 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD CYCL,SLOW
          CJMP CONDENABL;
%********************************************************************
% CONDITIONAL JUMP IS TRUE
CJMP:     A,R1 B,P ALUF,A+B ALUD,B
          T,JMP T,HOLD CYCL,WAIT
          INIT;
JAF:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,RETURN T,HOLD CYCL,SLOW
          CJMP CONDENABL;
JAN:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F15 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD CYCL,SLOW
          CJMP CONDENABL;
JAP:      A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,RETURN T,HOLD CYCL,SLOW
          CJMP CONDENABL;
JXZ:      A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F=0 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD CYCL,SLOW
          CJMP CONDENABL;
JPC:      B,X ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,RETURN T,HOLD CYCL,SLOW
          CJMP CONDENABL;
JNC:      B,X ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F15 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD CYCL,SLOW
          CJMP CONDENABL;
JXN:      A,X ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F15 F,RETURN F,HOLD;
          B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP T,HOLD CYCL,SLOW
          CJMP CONDENABL;
%********************************************************************
%********************************************************************
% ROP GROUP OF INSTRUCTIONS
%********************************************************************
SWAP0:    B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
SW0:      A,SRCE B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,SRCE ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
SWAP1:    B,Z ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SW0;
SWAP2:    B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
SW2:      A,SRCE B,DEST ALUF,INVA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,SRCE ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
SWAP3:    B,Z ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SW2;
RAND0:    A,SRCE B,DEST ALUF,ANDAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RAND3:
RAND1:    A,Z B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RAND2:    A,SRCE B,DEST ALUF,MASKAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
REXO0:    A,SRCE B,DEST ALUF,XORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RORA1:
REXO1:    A,SRCE B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RORA2:
REXO2:    A,SRCE B,R1 ALUF,INVA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,DEST ALUF,ORAB ALUD,B
          T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
REXO3:
RORA3:    A,SRCE B,DEST ALUF,INVA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RORA0:    A,SRCE B,DEST ALUF,ORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD0:    A,SRCE B,DEST ALUF,A+B ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD1:    A,SRCE B,DEST ALUF,A ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD2:    A,SRCE B,DEST ALUF,B-A-1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD3:    A,SRCE B,DEST ALUF,-A-1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD4:    A,SRCE B,DEST ALUF,A+B+1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD5:    A,SRCE B,DEST ALUF,A+1 ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD6:    A,SRCE B,DEST ALUF,B-A ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RADD7:    A,SRCE B,DEST ALUF,-A ALUD,B STS,EA
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RAD10:    A,SRCE B,DEST ALUF,A+B ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RAD11:    A,SRCE B,DEST ALUF,A ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RAD12:    A,SRCE B,DEST ALUF,B-A-1 ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RAD13:    A,SRCE B,DEST ALUF,-A-1 ALUD,B STS,EA CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          USDBR CONDENABL;
RAD14:
RAD15:
RAD16:
RAD17:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          USDBR;
%********************************************************************
%********************************************************************
% SHIFT INSTRUCTIONS
%********************************************************************
SHA:      ALUD,NONE
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,SLOW
          DUMMY;
          B,A ALUF,PASSB ALUM,IR ALUD,SRB
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,SLOW
          USDBR;
%********************************************************************
% SUBROUTINE TO REMOVE ONE SHIFT COUNT
DUMMY:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD LCOUNT CYCL,SLOW;
SHT:      ALUD,NONE
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,SLOW
          DUMMY;
          B,T ALUF,PASSB ALUM,IR ALUD,SRB
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,SLOW
          USDBR;
SHD:      ALUD,NONE
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,SLOW
          DUMMY;
          B,D ALUF,PASSB ALUM,IR ALUD,SRB
          IDBS,ALU T,JMP T,POP LCOUNT CYCL,SLOW
          USDBR;
SAD:      A,D ALUF,PASSA ALUD,Q
          IDBS,GPR COMM,LDLC T,JMP T,LOAD CYCL,SLOW
          DUMMY;
          B,A ALUF,PASSB ALUM,IR ALUD,SRD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          USDBR;
%********************************************************************
%********************************************************************
% ARGUMENT INSTRUCTIONS
%********************************************************************
SAA:      B,A ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
SAT:      B,T ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
SAX:      B,X ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
SAB:      B,B ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
AAA:      A,A B,A ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
AAT:      A,T B,T ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
AAX:      A,X B,X ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
AAB:      A,B B,B ALUF,D+A ALUD,B STS,EA
          IDBS,GPR,SEXT T,JMP T,POP CYCL,SLOW
          USDBR;
%********************************************************************
%********************************************************************
% SKIP INSTRUCTIONS
%********************************************************************
SKEQL:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F=0 F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SKIP CONDENABL;
%********************************************************************
% SKIP IS TRUE
SKIP:     B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
SKGRE:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,OVF F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SKLSS CONDENABL;
SKGEQ:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW
          SKIP CONDENABL;
SKMGR:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,CRY F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SKIP CONDENABL;
SKUEQ:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW
          SKIP CONDENABL;
SKLST:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,OVF F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SKGEQ CONDENABL;
SKLSS:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,F15 F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SKIP CONDENABL;
SKMLS:    A,SRCE B,DEST ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          COND,CRY F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW
          SKIP CONDENABL;
%********************************************************************
%********************************************************************
% BIT INSTRUCTIONS
%********************************************************************
% BSET BAC
BSETK:    B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,PUSH CYCL,SLOW
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          BSET1 CONDENABL;
%********************************************************************
% BSET ZRO
BSET0:    A,REG B,R1 ALUF,INVD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          STSTZ;
          A,R1 B,DEST ALUF,ANDAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          ZTSTS CONDENABL;
%********************************************************************
% SUBROUTINE TO ISOLATE K-FLIP-FLOP
GETK:     ALUF,ANDDQ ALUD,Q
          IDBS,STS T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% SUBROUTINE TO TRANSFER STS TO Z-REGISTER
STSTZ:    B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,RETURN T,POP CYCL,SLOW
          COND,DR=2 F,JMP F,POP;
%********************************************************************
% SUBROUTINE TO TRANSFER Z-REGISTER TO STS
ZTSTS:    A,Z ALUF,PASSA ALUD,Q STS,LO
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% BSET ONE
BSET1:    A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          STSTZ;
          A,R1 B,DEST ALUF,ORAB ALUD,B
          IDBS,BMG T,RETURN T,POP CYCL,SLOW
          ZTSTS CONDENABL;
%********************************************************************
% BSET BCM
BSETC:    A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          STSTZ;
          A,R1 B,DEST ALUF,XORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          ZTSTS CONDENABL;
%********************************************************************
% BSKP BCM
BSKPC:    B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,SLOW
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          BSKP0 CONDENABL;
%********************************************************************
% BSKP ONE
BSKP1:    B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          B,DEST ALUF,INVB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          BSKP9;
%********************************************************************
% BSKP BAC
BSKPK:    B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,SLOW
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          BSKP1 CONDENABL;
%********************************************************************
% BSKP ZRO
BSKP0:    B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
BSKP9:    A,REG ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,RETURN F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SKIP CONDENABL;
%********************************************************************
% BSTA
BSTA:     A,2 B,R2 ALUF,INVD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          BSTA1;
          A,Z B,R2 ALUF,ANDAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          PMODX;
BSTA1:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BSETK;
          A,Z B,R2 ALUF,ANDAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
%********************************************************************
% BSTC
BSTC:     A,2 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          BSTC1;
          A,Z B,R2 ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          PMODX;
BSTC1:    A,R2 ALUF,XORDA ALUD,Q
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BSETK;
          A,Z B,R2 ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          INIT;
%********************************************************************
% BANC
BANC:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,SLOW
          GETK;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW
          BLDC CONDENABL;
%********************************************************************
% BORC
BORC:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,SLOW
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          USDBR CONDENABL;
%********************************************************************
% BLDC
BLDC:     A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          STSTZ;
          A,R1 B,DEST ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,2 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          SETK0 CONDENABL;
SETK1:    A,R2 B,Z ALUF,ORAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          USDBR;
%********************************************************************
% BAND
BAND:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,SLOW
          GETK;
          ALUD,NONE
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW
          BLDA CONDENABL;
%********************************************************************
% BORA
BORA:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,LOAD CYCL,SLOW
          GETK;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          USDBR CONDENABL;
%********************************************************************
% BLDA
BLDA:     A,REG B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          STSTZ;
          A,R1 B,DEST ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,2 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          SETK1 CONDENABL;
SETK0:    A,R2 B,Z ALUF,MASKAB ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          USDBR;
%********************************************************************
%********************************************************************
% STORE REGISTER BLOCK
%********************************************************************
SRB:      B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,JMP T,PUSH CYCL,SLOW
          RBLOK;
          B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          SRB1 CONDENABL;
%********************************************************************
% OWN LEVEL, SAVE REGISTER BLOCK IN REGISTER FILE
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          A,PIL B,LC ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,POP LCOUNT CYCL,SLOW;
SRB1:     A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          WRRQ;
          ALUF,PASSQ ALUD,NONE IDBS,ALU T,JMP T,PUSH CYCL,WAIT WRRQ;
          A,REG B,B ALUD,NONE IDBS,REG T,JMP T,POP CYCL,WAIT STEND;
%********************************************************************
% SUBROUTINE TO CHECK FOR OWN LEVEL IN SRB, LRB, IRW, IRR
RBLOK:    ALUF,PASSD ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% ENTRY USED BY MOPC IN REGISTER DEPOSIT
OPCRB:    ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% ENTRY USED BY IRR AND IRW
IRWRD:    A,PIL ALUF,XORDQ ALUD,Q
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          170;
%********************************************************************
%********************************************************************
% LOAD REGISTER BLOCK
%********************************************************************
LRB:      B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,JMP T,PUSH CYCL,SLOW
          RBLOK;
          A,P B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,X B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          USGPR CONDENABL;
%********************************************************************
% OWN LEVEL, UNSAVE REGISTER BLOCK
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          A,PIL B,LC ALUF,PASSD ALUD,B
          IDBS,REG T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,R2 B,P ALUF,PASSA ALUD,B  % P IS UNCHANGED
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,Z ALUF,PASSA ALUD,NONE STS,LO  % CHANGE STS
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USGPR;
%********************************************************************
%********************************************************************
% INTER-REGISTER READ
%********************************************************************
IRR:      B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,LOAD CYCL,SLOW
          IRWRD;
          A,REG B,Z ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          IRR1 CONDENABL;
%********************************************************************
% OWN LEVEL
          A,Z B,Z ALUF,ANDDA ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377;
          B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          IRR2;
%********************************************************************
% OTHER LEVEL
IRR1:     ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377;
          A,REG B,Z ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          A,REG B,DEST ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
IRR2:     B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
%********************************************************************
% INTER REGISTER WRITE
%********************************************************************
IRW:      A,P B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,LOAD CYCL,SLOW
          IRWRD;
          ALUD,NONE
          IDBS,DSABL T,NEXT T,HOLD CYCL,SLOW
          IRW1 CONDENABL;
%********************************************************************
% OWN LEVEL
          A,A B,DEST ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          IRW2;
          A,R2 B,P ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          CONDENABL;
%********************************************************************
% STS MUST BE LOADED
          A,Z ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% OTHER LEVEL
IRW1:     A,A ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,REG B,DEST ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          IRW2;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377 CONDENABL;
%********************************************************************
% STS MUST BE LOADED
          A,REG B,Z ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO CHECK FOR STS AS DESTINATION
IRW2:     B,DEST ALUF,PASSD ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
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
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USGPR;
%********************************************************************
% UPPER BYTE
LBYTU:    ALUF,PASSD ALUD,Q
          IDBS,SWAP T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO CALCULATE ADDRESS IN LBYT AND SBYT
LBYTM:    A,T B,R1 ALUF,A+B ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          A,X B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
%********************************************************************
% STORE BYTE
%********************************************************************
SBYT:     B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377;
          A,A B,R3 ALUF,ANDAB ALUD,B  % ISOLATE BYTE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,X B,R1 MIS,ZIN ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          LBYTM;
          ALUF,PASSD ALUD,Q  % READ WORD
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          SBYTU CONDENABL;
%********************************************************************
% LOWER BYTE
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          177400;
%********************************************************************
% BOTH BYTES
SBYT1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,R2 ALUF,ORAB ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,WAIT
          STEND;
%********************************************************************
% UPPER BYTE
SBYTU:    B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,SWAP T,JMP T,HOLD CYCL,SLOW
          SBYT1;
%********************************************************************
%********************************************************************
% REGISTER MULTIPLY
%********************************************************************
RMPY:     A,SRCE B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          B,DEST ALUF,PASSB ALUD,Q
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          RMPY1 CONDENABL;
          B,R1 ALUF,-B ALUD,B  % FIRST OP. NEG.
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,JMP F,HOLD;
RMPY1:    B,16 ALUF,ZERO ALUD,B
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          RMPY2 CONDENABL;
          ALUF,-Q ALUD,NONE  % SEC. OP. NEG.
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
RMPY2:    ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          A,R1 B,R6 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD  % MULTIPLY LOOP
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,SRCE B,DEST ALUF,XORAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RMPY3 CONDENABL;
          A,R6 B,A ALUF,PASSA ALUD,B  % ANSWER POSITIVE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USDBR;
RMPY3:    B,D ALUF,-Q ALUD,B STS,EA  % ANSWER NEG.
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,-A-1 ALUD,B CRY,C
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USDBR;
%********************************************************************
%********************************************************************
% REGISTER DIVIDE
%********************************************************************
RDIV:     A,SRCE B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          A,A B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDIV1 CONDENABL;
          B,R1 ALUF,-B ALUD,B  % NEGATIVE DIVISOR
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,JMP F,HOLD;
RDIV1:    A,SRCE B,A ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDIV2 CONDENABL;
          B,D ALUF,-B ALUD,B STS,EA  % NEGATIVE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;  % DIVIDEND
          B,A ALUF,-B-1 ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
RDIV2:    A,R1 B,A ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,CRY F,NEXT F,HOLD;
          B,R7 ALUF,PASSQ ALUD,B
          T,JMP T,HOLD CYCL,SLOW
          RDIVZ CONDENABL;
          B,D ALUF,PASSB ALUD,Q
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          16;
          B,STS ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          A,7 ALUF,PASSD ALUD,NONE STS,LO
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,0 B,A MIS,ZIN ALUF,PASSB ALUD,SLD STS,ES
          IDBS,AARG COMM,LDGPR T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
%********************************************************************
% DIVIDE LOOP
          A,R1 B,A MIS,ZIN ALUF,B-A-1 ALUM,FDV ALUD,SLD STS,ES CRY,GPR
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,A B,D MIS,LIN ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,STS ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDIV3 CONDENABL;
          A,R1 B,D ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
RDIV3:    A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDIV4 CONDENABL;
%********************************************************************
% CHANGE QUOTIENT SIGN
          ALUF,-Q ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,JMP F,HOLD;
RDIV4:    B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDIV5 CONDENABL;
%********************************************************************
% CHANGE REMAINDER SIGN
          B,D ALUF,-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
RDIV5:    A,A B,R7 ALUF,XORAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,POP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          USDBR CONDENABL;
%********************************************************************
% OVERFLOW (OR ERROR IN EXR, DNZ ETC.)
RDIVZ:    B,10 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          B,STS ALUF,ORDQ ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          A,STS ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USDBR;
%********************************************************************
%********************************************************************
% EXECUTE REGISTER
%********************************************************************
EXR:      A,SRCE ALUF,XORDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,ANDDQ ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          177700;
          A,SRCE ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          RDIVZ CONDENABL;
%********************************************************************
% OK, NOT EXR(EXR)
          ALUD,NONE
          IDBS,GPR COMM,CLIRQ T,NEXT T,MAPJ T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW;
%********************************************************************
%********************************************************************
% MIX3-INSTRUCTION
%********************************************************************
MIX3:     A,A B,X ALUF,A-1 ALUM,MIC ALUD,SLB
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,X B,X ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,POP CYCL,SLOW
          USDBR;
%********************************************************************
% 32-BIT M-VERSION
%********************************************************************
% FLOATING SUBTRACT INSTRUCTION
%********************************************************************
FSB:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% INVERT SIGN OF MEMORY OPERAND
          A,17 B,R2 ALUF,XORDQ ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          FAD2;
%********************************************************************
%********************************************************************
% FLOATING ADD INSTRUCTION
%********************************************************************
FAD:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,R2 ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% COMMON PART OF FAD & FSB
FAD2:     B,4 ALUD,NONE
          IDBS,BARG COMM,LDLC T,JMP T,PUSH CYCL,SLOW
          RDRQ;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,STS ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          100077;
          A,R2 ALUF,MASKDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,A B,R4 ALUF,MASKDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          STSST CONDENABL;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          UNSF2 CONDENABL;
          A,R4 B,R3 ALUF,A-Q ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          B,R3 ALUF,PASSB ALUD,SRB STS,ES
          IDBS,ARG COMM,LDGPR T,NEXT T,POP LCOUNT CYCL,SLOW
          30;
          A,R3 ALUF,D-A ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          A,R3 ALUF,D+A ALUD,NONE
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          STSST CONDENABL;
          B,R3 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          UNSF2 CONDENABL;
          A,R3 ALUF,A+1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,SLOW
          NED1 CONDENABL;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R3 ALUF,A-1 ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,SLOW
          EQUAL CONDENABL;
%********************************************************************
% AD-OPERAND GREATEST
          B,R1 ALUF,PASSB ALUD,Q
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          77;
          A,R2 B,R5 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R6 ALUF,MASKDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          NORM1;
%********************************************************************
% MEMORY OPERAND GREATEST
NED1:     B,D ALUF,PASSB ALUD,Q
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          77;
          A,R2 B,R6 ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R5 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,D ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R2 B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          NORM1;
%********************************************************************
% EQUAL EXPONENTS
EQUAL:    B,R1 ALUF,PASSB ALUD,Q
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          77;
          A,A B,R3 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R2 B,R5 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R6 ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          100;
          A,R5 B,R5 ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,R3 ALUF,ORDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          FADD;
%********************************************************************
% ALIGNEMENT SHIFT
NORM1:    ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          100;
          A,R5 B,R5 ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,R3 ALUF,ORDA ALUD,B
          IDBS,GPR COMM,CLFF T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          B,R5 MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD STS,ES
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,R5 MIS,LIN ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% EQUAL SIGNS?
FADD:     A,A B,R2 ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          A,7 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          SUBF CONDENABL;
%********************************************************************
% EQUAL SIGNS, ADD MANTISSAS
          A,D B,D ALUF,A+Q ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,R3 ALUF,A+B ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R3 B,R1 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,6 B,D ALUF,PASSQ ALUD,B
          IDBS,BMG COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          NOCRY CONDENABL;
%********************************************************************
% ADDITION GAVE CARRY
          A,R6 B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,R3 MIS,ZIN ALUF,PASSB ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          100;
          A,R2 ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,R3 ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,16 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,JMP T,PUSH CYCL,SLOW
          CHKOF;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          STSEX;
NOCRY:    A,R3 B,A ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          STSST;
%********************************************************************
% AD-OPERAND INSIGNIFICANT
UNSF2:    A,R2 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,D ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          STSST;
%********************************************************************
% UNEQUAL SIGNS, SUBTRACT MANTISSAS
SUBF:     A,D B,D ALUF,A-Q-1 ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,R5 ALUF,A-B-1 ALUD,Q CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INV CONDENABL;
          B,D ALUF,B+1 ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,A ALUF,Q ALUD,B CRY,C
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          NOINV;
%********************************************************************
% INVERT ANSWER AFTER SUBTRACTION
INV:      B,A ALUF,INVQ ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          100000;
          A,R6 B,R6 ALUF,XORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,D ALUF,INVB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% NORMALIZE ANSWER AFTER SUBTRACTION
NOINV:    B,R1 ALUF,D-1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          21;
          A,6 B,A ALUF,PASSB ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          B,D ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          FAD5 CONDENABL;
          A,R6 B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          FAD4 CONDENABL;
%********************************************************************
% AD-OPERAND = 0
ZAD:      B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R7 B,D ALUF,ZERO ALUD,B,YA
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          STSEX;
%********************************************************************
% A-REG EQ ZERO D-REG NEQ ZERO
FAD4:     A,16 B,R5 ALUF,PASSD ALUD,B
          IDBS,BMG COMM,CLFF T,NEXT T,PUSH CYCL,SLOW
          COND,F15;
          B,D MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLB
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,D MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,D MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,LC ALUF,A-D ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          B,R2 ALUF,D+Q+1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          5;
          B,D ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW;
          B,A MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          4;
FAD6:     B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW;
          A,6 B,R2 MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLB
          IDBS,BMG COMM,LDGPR T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,A B,A ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,R2 ALUF,A-B ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          CHKUF;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          STSEX;
%********************************************************************
% A-REG AND D-REG NEQ ZERO
FAD5:     A,A ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,D ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          FAD3 CONDENABL;
          A,16 B,R5 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,PUSH CYCL,SLOW
          COND,F11;
          B,A MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,LC ALUF,A-D ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          B,R2 ALUF,Q-D-1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          5;
          B,D ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW;
          B,A MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,4 ALUD,NONE
          IDBS,BARG COMM,LDLC T,JMP T,HOLD CYCL,SLOW
          FAD6;
FAD3:     A,A B,A ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          STSST;
%********************************************************************
%********************************************************************
% FLOATING MULTIPLY INSTRUCTION
%********************************************************************
FMU:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,R2 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          B,STS ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          77;
          A,A ALUF,MASKDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          ZAD CONDENABL;
          A,R2 B,R3 ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% ADD EXPONENTS
          A,R3 ALUF,A+Q ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ZAD CONDENABL;
          B,R6 ALUF,MASKDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          100000;
          A,A B,R2 ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          A,17 B,R5 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          FMU2 CONDENABL;
%********************************************************************
% UNEQUAL SIGNS, CHANGE SIGNBIT
          A,R5 B,R6 ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
FMU2:     A,16 B,R5 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R5 ALUF,ANDAQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          FMU1 CONDENABL;
          A,R6 B,A ALUF,XNORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 ALUF,ANDAQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,16 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          OFUF CONDENABL;
%********************************************************************
% MULTIPLY MANTISSAS
FMU1:     A,R5 B,R6 ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,A ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R2 B,R4 ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,6 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,R4 ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ZERO ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          B,R3 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,SLOW
          17;
          A,D ALUF,A+Q ALUM,FMU ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R3 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD STS,EA CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,R4 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          B,5 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,PUSH CYCL,SLOW;
          A,D ALUF,A+Q ALUM,FMU ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R3 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,SRD STS,EA CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,D ALUF,A+Q ALUM,FMU ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R3 MIS,ZIN ALUF,A+B ALUM,FMU ALUD,B STS,EA CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,7 B,R4 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,R4 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MCRY1 CONDENABL;
%********************************************************************
% NO CARRY FROM LAST ADDITION IN MULTIPLY LOOP
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ZAD CONDENABL;
          A,R1 B,A ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,R1 ALUF,A-B ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          CHKUF;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          STSEX;
%********************************************************************
% CARRY FROM LAST ADDITION IN MULTIPLY LOOP
MCRY1:    A,R4 B,A ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,A MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R7 B,D ALUF,PASSQ ALUD,B,YA
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          STSEX;
%********************************************************************
%********************************************************************
% FLOATING DIVIDE INSTRUCTION
%********************************************************************
FDV:      B,R1 ALUF,D-1 ALUD,B
          IDBS,GPR,SEXT T,JMP8-10 T,PUSH CYCL,SLOW
          MREFL;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,R2 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          RDRQ;
          B,STS ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          A,R2 B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          77;
          A,A ALUF,MASKDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          ZAD CONDENABL;
          A,R2 B,R3 ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R3 ALUF,Q-A ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          A,A B,R2 ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,17 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          FDV2 CONDENABL;
%********************************************************************
% UNEQUAL SIGNS, CHANGE SIGNBIT
          A,17 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
FDV2:     B,R6 ALUF,XORDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          40000;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,16 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          FLOVF CONDENABL;
          A,R2 B,R1 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,A B,R6 ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          FDV1 CONDENABL;
          A,R1 ALUF,ANDAQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,16 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          FDV1 CONDENABL;
OFUF:     A,A B,R1 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          FLOVF CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ZAD;
%********************************************************************
% DIVIDE MANTISSAS
FDV1:     B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          100;
          A,R4 B,R4 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,A B,A ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,R4 ALUF,ORAB ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          6;
          A,R1 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,D ALUF,PASSB ALUD,Q
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          0;
          A,7 B,R1 ALUF,PASSD ALUD,B STS,LO
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          A,R5 ALUF,Q-A ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,A MIS,ZIN ALUF,B-A-1 ALUM,MIC ALUD,SLD STS,ES CRY,C
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW;
          A,R5 ALUF,Q-A-1 ALUM,FDV ALUD,Q STS,EA CRY,GPR
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,A MIS,ZIN ALUF,B-A-1 ALUM,FDV ALUD,SLD STS,ES CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,SLOW
          17;
          A,R5 ALUF,Q-A-1 ALUM,FDV ALUD,Q STS,EA CRY,GPR
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,A MIS,ZIN ALUF,B-A-1 ALUM,FDV ALUD,SLD STS,ES CRY,C
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,R3 B,R1 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          POSDV CONDENABL;
          B,R3 MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,6 B,D ALUF,PASSQ ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,R6 ALUF,D+A ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,R3 ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,16 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,JMP T,PUSH CYCL,SLOW
          CHKOF;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
STSEX:    A,STS ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USGPR;
POSDV:    A,6 B,D ALUF,PASSQ ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,A ALUF,MASKDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          STSST;
FLOVF:    A,Z B,D ALUF,INVA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          77777;
          A,R6 B,A ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          10;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
STSST:    A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          STSEX;
CHKUF:    A,R6 B,R2 ALUF,MASKAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,R2 B,R5 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,A ALUF,ORAQ ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          ZAD CONDENABL;
CHKOF:    B,R2 ALUF,INVQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,R2 ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,POP;
          A,R2 B,R2 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,A ALUF,A+Q ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          FLOVF CONDENABL;
%********************************************************************
%********************************************************************
% NORMALIZE INSTRUCTION
%********************************************************************
NLZ:      A,10 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          B,D ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          NLZ1 CONDENABL;
          B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USDBR;
NLZ1:     B,R6 ALUF,D+Q ALUD,B
          IDBS,GPR,SEXT T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          A,11 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          NLZ2 CONDENABL;
          A,R6 B,R6 ALUF,D+A ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,A ALUF,-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
NLZ2:     B,R5 ALUF,D-1 ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,SLOW
          21;
          B,A MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SLB STS,ES
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,A MIS,LIN ALUF,PASSB ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,LC ALUF,A-D-1 ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,R6 ALUF,A-Q ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          4;
          B,A ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          B,R6 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,D ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USDBR;
%********************************************************************
%********************************************************************
% DENORMALIZE INSTRUCTION
%********************************************************************
DNZ:      B,D ALUF,PASSB ALUD,Q
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          4;
          B,R1 ALUF,PASSD ALUD,B
          IDBS,GPR,SEXT T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          B,A ALUF,PASSB ALUD,SRD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,17 B,D ALUF,PASSQ ALUD,SRB
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,D B,D ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,A ALUF,A+B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R2 ALUF,D+Q ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          20;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          400;
          A,R2 B,R6 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,SLOW
          ZAD2 CONDENABL;
          A,10 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDIVZ CONDENABL;
          A,11 B,R3 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          B,D MIS,ZIN ALUF,PASSB ALUD,SRD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,D ALUF,PASSB ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R3 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,D ALUF,PASSB ALUD,SLD
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          DNZ1 CONDENABL;
          B,D ALUF,-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
DNZ1:     A,D B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
ZAD3:     B,D ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USDBR;
ZAD2:     B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ZAD3;
%********************************************************************
%********************************************************************
% IOX-INSTRUCTION
%********************************************************************
IOX:      B,R1 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          IOXG;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USGPR;
%********************************************************************
%********************************************************************
% IOXT - INSTRUCION
%********************************************************************
IOXT2:    A,T B,R1 ALUF,PASSA ALUD,B
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          IOXX1;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USGPR;
%********************************************************************
%********************************************************************
% SUBROUTINE USED BY IOX OR MICROPROGRAMMED LOADERS
% TO ISSUE IOXINSTRUCTIONS ON SYSTEM BUS
%********************************************************************
% IOX-ROUTINE FOR 11-BIT IOX-ADDRESS
IOXG:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          3777;
          A,R1 B,R1 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% IOX-ROUTINE FOR 16-BIT IOX ADDRESS
IOXX1:    A,R1 B,7 ALUF,MASKDA ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,OPCTT1 F,NEXT F,HOLD;
%********************************************************************
% CHECK IF DEVICE NUMBERS 30X IS ON THE CPU-BOARD
          ALUF,XORDQ ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          300;
          A,R1 B,3 ALUF,MASKDA ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          TERMX CONDENABL;
%********************************************************************
% CHECK IF DEVICE IS IN THE RANGE 10-13
          B,10 ALUF,XORDQ ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,SLOW
          CLKX CONDENABL;
%********************************************************************
% DEVICE IS NOT ON CPU-BOARD. ISSUE GENERAL IOX
          A,R1 ALUF,PASSA ALUD,NONE  % ADDRESS -> IOX
          COMM,IOX T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE  % OUTPUT DATA
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          B,A ALUF,PASSD ALUD,B  % INPUT DATA
          IDBS,DBR T,RETURN T,POP CYCL,WAIT;
%********************************************************************
% DEV.NO. 30X IS ON CPU BOARD. JUMP TO VECTOR
TERMX:    AB,STATUS ALUF,PASSD
          IDBS,REG T,JMP0-3 T,HOLD CYCL,SLOW
          TRMVC;
%********************************************************************
% DEV.NO. IS 10-13, JUMP TO VECTOR
CLKX:     AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP0-3 T,HOLD CYCL,SLOW
          CLKVC;
%********************************************************************
% SUBROUTINE TO WRITE STATUS-SCRATCH WORD, AND TO WRITE SIOC-REGISTER
WSIOC:    AB,STATUS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
WSIO2:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,SIOC T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% ROUTINES FOR CPU-TERMINAL, ENTERED FROM VECTOR
%********************************************************************
% IOX 300
TRM0:     A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,A ALUF,ANDDQ ALUD,B
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          377 CONDENABL;
          ALUD,NONE
          IDBS,ALU COMM,RSDA T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% IOX 302
TRM2:     A,A B,1 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,PUSH CYCL,SLOW;
          B,A MIS,ZIN ALUF,PASSB ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          340;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R6 B,A ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,4 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          TRM20 CONDENABL;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
TRM20:    A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          TRM21 CONDENABL;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          TRM21 CONDENABL;
          A,3 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
TRM21:    A,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,0 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,RETURN T,POP CYCL,SLOW
          CONDENABL;
TRM22:    A,R6 B,A ALUF,ORAB ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% IOX 303
TRM3:     A,R2 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,R2 ALUF,ORDA ALUD,B
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          TRM31 CONDENABL;
          A,R2 B,R2 ALUF,MASKDA ALUD,B
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
TRM31:    B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          74002;
          A,R3 B,R2 ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          175;
          A,R2 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          WSIOC;
%********************************************************************
% IOX 306
TRM6:     ALUF,PASSD ALUD,NONE
          IDBS,IOR T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          TRM61 CONDENABL;
          A,3 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
TRM61:    A,2 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,0 B,R6 ALUF,PASSD ALUD,B
          IDBS,BMG T,RETURN T,POP CYCL,SLOW
          TRM22 CONDENABL;
%********************************************************************
% IOX 307
TRM7:     A,A B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,2 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          WSIOC CONDENABL;
          B,4 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          WSIOC;
%********************************************************************
% ROUTINES FOR DEVICE NUMBERS 10-13, ENTERED FROM VECTOR
%********************************************************************
% IOX 11
CLK1:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,SIOC T,NEXT T,HOLD CYCL,SLOW;
          A,7 ALUF,MASKDQ ALUD,Q
          IDBS,BMG COMM,CLRTC T,JMP T,HOLD CYCL,SLOW
          WSIO2;
%********************************************************************
% IOX 13
CLK3:     A,A B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,15 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          CLK31 CONDENABL;
          B,1 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
CLK31:    A,A B,R2 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          WSIOC CONDENABL;
          B,10 ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          WSIOC;
%********************************************************************
%********************************************************************
% IDENT-INTRUCTION
%********************************************************************
IDENT:    A,6 B,R1 ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,R1 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,NEXT F,HOLD;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          43;
          A,R1 B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,4 ALUF,A-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          ID13 CONDENABL;
          A,R1 B,11 ALUF,A-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          ID10 CONDENABL;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,SLOW
          IDX CONDENABL;
%********************************************************************
% IDENT IS ON LEVEL 12, CHECK IF TERMINAL GAVE INTERRUPT
ID12:     A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          IDX CONDENABL;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          IDX CONDENABL;
          A,1 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
% CPU-BOARD TERMINAL READY FOR TRANSFER
IDSPC:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,NEXT F,HOLD;
          B,LC ALUF,MASKDQ ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          IDX CONDENABL;
%********************************************************************
% DEVICE ON CPU-BOARD (TERMINAL OR CLOCK) READY FOR TRANSFER AND INT. ENABLED
IDRET:    A,0 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,SIOC T,NEXT T,HOLD CYCL,SLOW;
          AB,STATUS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,POP CYCL,SLOW
          USGPR;
%********************************************************************
% IDENT IS ON LEVEL 10, CHECK IF TERMINAL GAVE INTERRUPT
ID10:     A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ANDDQ ALUD,NONE
          IDBS,IOR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          IDX CONDENABL;
          A,2 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG COMM,LDLC T,JMP T,HOLD CYCL,SLOW
          IDSPC;
%********************************************************************
% IDENT IS ON LEVEL 13, CHECK IF CLOCK GAVE INTERRUPT
ID13:     AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,R2 ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          11;
          A,R2 B,11 ALUF,D-A ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,0 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          IDRET CONDENABL;
%********************************************************************
% DEVICE IS NOT ON CPU-BOARD, SEND OUT GENERAL IDENT
IDX:      A,R1 ALUF,PASSA ALUD,NONE  % ADDRESS -> IDENT
          IDBS,ALU COMM,IDENT T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,GPR T,JMP T,PUSH CYCL,SLOW
          MCMS1;
          B,6 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MCSTS CONDENABL;
          B,7 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MCPID CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MCPIE CONDENABL;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,POP CYCL,WAIT INIT;
%********************************************************************
%********************************************************************
% MASKED SET INSTRUCION
%********************************************************************
MST:      ALUF,PASSD ALUD,Q
          IDBS,GPR T,JMP T,PUSH CYCL,SLOW
          MCMS1;
          B,6 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MSSTS CONDENABL;
          B,7 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          MSPID CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MSPIE CONDENABL;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,POP CYCL,WAIT INIT;
%********************************************************************
% SUBROUTINE FOR MCL & MST INSTRUCTIONS
MCMS1:    B,17 ALUF,ANDDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,1 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE FOR MCL
MCLEA:    A,A ALUF,MASKAQ ALUD,Q
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE FOR MST
MSET:     A,A ALUF,ORAQ ALUD,Q
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% MCL STS
MCSTS:    ALUF,PASSD ALUD,Q
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,MASKAQ ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          USDBR;
%********************************************************************
% MCL PID
MCPID:    AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          MCLEA;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          TRPID;
%********************************************************************
% MCL PIE
MCPIE:    AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          MCLEA;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          TRPIE;
%********************************************************************
% MST STS
MSSTS:    A,A ALUF,ORDA ALUD,Q
          IDBS,STS T,JMP T,HOLD CYCL,SLOW
          TRSTS;
%********************************************************************
% MST PID
MSPID:    AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          MSET;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          TRPID;
%********************************************************************
% MST PIE
MSPIE:    AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          MSET;
          ALUD,NONE
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          TRPIE;
%********************************************************************
%********************************************************************
% MONITOR CALL INSTRUCTION
%********************************************************************
MON:      A,4 ALUD,NONE
          IDBS,BMG COMM,SMPID T,NEXT T,POP CYCL,SLOW;
          A,16 B,T ALUD,NONE
          IDBS,GPR,SEXT COMM,EWRF T,RETURN T,HOLD CYCL,SLOW;
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
          IDBS,STS T,JMP0-3 T,HOLD CYCL,SLOW
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
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          CHKIT;
%********************************************************************
% EXAM - INSTRUCTION
EXAM2:    A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          EXPHY;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD CYCL,SLOW;
          B,T ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          EXMO3;
%********************************************************************
% DEPO - INSTRUCTION
DEPO2:    A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          EXPHY;
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,ALU T,JMP0-3 T,POP CYCL,SLOW
          VECT2;
%********************************************************************
% TRA-ROUTINES, ENTERED FROM VECTOR
%********************************************************************
% TRA PID
APID1:    PIC,RSTS B,R5 ALUF,PASSD ALUD,B
          IDBS,PIC COMM,EPIC T,NEXT T,HOLD CYCL,SLOW
          COND,IRQ F,JMP F,HOLD;
          PIC,LOSTS B,10 ALUF,ZERO ALUD,Q
          IDBS,BARG COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
          PIC,ION B,R6 ALUF,INVD ALUD,B
          IDBS,BMG COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
          PIC,LMSK B,R6 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
          AB,IIE ALUF,PASSD ALUD,B
          IDBS,REG COMM,CLIRQ T,NEXT T,HOLD CYCL,SLOW;
          A,17 ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          APID2 CONDENABL;
          A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
APID2:    B,5 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
          A,4 B,R3 ALUF,INVD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          PIC,LMSK B,R2 ALUF,INVB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,PUSH CYCL,SLOW
          APID3;
          PIC,LMSK B,R3 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,SLOW
          APID3 CONDENABL;
          ALUF,ORDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
APID3:    PIC,LOSTS B,10 ALUD,NONE
          IDBS,BARG COMM,EPIC T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          B,R3 ALUF,PASSB ALUM,FMU ALUD,SRB
          IDBS,ALU COMM,CLIRQ T,NEXT T,POP LCOUNT CYCL,SLOW
          COND,IRQ F,JMP F,HOLD;
          AB,PID ALUF,ORDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          PIC,LOSTS B,R5 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,NONE
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          PIC,LMSK B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          APIE1 CONDENABL;
APID4:    PIC,IOF ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          APIE1;
%********************************************************************
% TRA IIC
AIIC1:    PIC,RMSK B,R6 ALUF,PASSD ALUD,B
          IDBS,DSABL COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
          AB,IIE ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          37760;
          PIC,LMSK ALUF,INVQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          25;
          PIC,ION B,13 ALUF,PASSD ALUD,B
          IDBS,BARG COMM,EPIC T,NEXT T,PUSH CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          PIC,LOSTS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,POP CYCL,SLOW
          AIIC3 CONDENABL;
          A,R3 ALUF,A-Q ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,RETURN F,HOLD;
          ALUF,Q-1 ALUD,Q
          IDBS,ALU COMM,CLIRQ T,NEXT T,POP CYCL,SLOW
          CONDENABL COND,IRQ F,NEXT F,HOLD;
          ALUF,ZERO ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          AIIC2;
AIIC3:    ALUF,Q-D ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          12;
          A,16 ALUD,NONE
          IDBS,BMG COMM,SMPID T,NEXT T,HOLD CYCL,SLOW;
AIIC2:    PIC,LOSTS B,R5 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,PUSH CYCL,SLOW
          CLR14;
          ALUF,PASSD ALUD,NONE
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          PIC,LMSK B,R6 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,SLOW
          APID4 CONDENABL;
%********************************************************************
% TRA PIE
APIE1:    B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% TRA PVL
APVL1:    B,A ALUF,ORDQ ALUD,B
          IDBS,ARG T,RETURN T,HOLD CYCL,SLOW
          153602;
%********************************************************************
% TRA ALD
AALD1:    ALUD,NONE
          IDBS,ALU T,JMPALD T,PUSH CYCL,SLOW
          ALDVC;
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% TRA PANS
AIR16:
AIR17:
APANS:    B,0 ALUF,D-1 ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          AMM2;
%********************************************************************
% TRA PGC (PAGING CONTROL REG.)
APGC1:    B,R6 ALUF,PASSD ALUD,B
          IDBS,STS T,JMP T,PUSH CYCL,SLOW
          PLPCR;
          ALUF,PASSD ALUD,Q
          IDBS,MMR T,NEXT T,HOLD CYCL,SLOW;
          A,R7 B,A ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          7773;
%********************************************************************
% SUBROUTINE FOR TRA PGC AND TRR PCR
PLPC2:    A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDPIL T,JMP T,HOLD CYCL,SLOW
          PRFCH;
%********************************************************************
% TRR PCR
RPCR1:    B,R6 ALUF,PASSD ALUD,B
          IDBS,STS T,JMP T,PUSH CYCL,SLOW
          PLPCR;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,XMM T,JMP T,HOLD CYCL,SLOW
          PLPC2;
%********************************************************************
% TRA PGS
APGS1:    A,R6 ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          1777;
%********************************************************************
% SUBROUTINE FOR TRA ANY MEMORY MANAGEMENT REGISTER
AMM2:     ALUD,NONE
          IDBS,GPR COMM,LDIR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;  % WAIT-TIME FOR MMM
          B,A ALUF,ANDDQ ALUD,B
          IDBS,MMR T,JMP T,HOLD CYCL,SLOW
          PRFCH;
%********************************************************************
% TRA CSR
ACSR1:    B,7 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          AMM2;
%********************************************************************
% SUBROUTINE FOR TRR PCR AND TRA PGC
PLPCR:    B,2 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R5 ALUF,PASSA ALUD,SLB
          IDBS,GPR COMM,LDIR T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          B,R5 ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDPIL T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% TRR INSTRUCTIONS (1501XX)
%********************************************************************
TRR:      B,A ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP0-3 T,POP CYCL,SLOW
          VECT3;
%********************************************************************
% TRR ROUTINES, ENTERED FROM VECTOR
%********************************************************************
% TRR IIE
RIIE1:    ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          7774;
          B,R1 ALUF,ORDQ ALUD,SLB
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          10000;
          PIC,RMSK B,R2 ALUF,INVD ALUD,B
          IDBS,DSABL COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
          AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,R1 ALUF,A+B ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          NOTI2 CONDENABL;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          100017;
          A,R6 B,R2 ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R2 B,R2 ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          PIC,LMSK B,R2 ALUF,INVB ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
NOTI2:    AB,IIE ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% TRR PIE
RPIE1:    ALUF,PASSD ALUD,Q
          IDBS,SWAP T,JMP T,PUSH CYCL,SLOW
          PICFM;
          A,Z B,STS ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R1 ALUF,ANDDA ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          100017;
          A,STS ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,IIE ALUF,ANDDQ ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,R1 ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          PIC,LMSK B,R1 ALUF,INVB ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          CHKIT;
%********************************************************************
% TRR PID
RPID1:    ALUF,PASSD ALUD,Q
          IDBS,SWAP T,JMP T,PUSH CYCL,SLOW
          PICFM;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          140017;
          A,Z B,R1 ALUF,MASKAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          CLRXX;
          A,Z ALUF,ANDAQ ALUD,NONE
          IDBS,ALU COMM,SMPID T,JMP T,HOLD CYCL,SLOW
          CHKIT;
%********************************************************************
% TRR LMP
RLMP1:    AB,LMP ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,HOLD CYCL,SLOW;
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
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          100115;
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          IOXX1;
%********************************************************************
% SENDS OUT NEW PREFETCH REQUEST IN CASE TRA OR TRR HAS DESTROYED PREFETCH
PRFCH:    A,P ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,FETCH COMM,RDRQ T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% TRR PANC
RPANC:    ALUD,NONE
          IDBS,GPR COMM,LDIR T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,WAIT
          STOPW CONDENABL;
%********************************************************************
% INTERRUPT IS ON
          B,17 ALUF,ANDDQ ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% REMOVE CURRENT PID-BIT
          B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
          AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,LC ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,16 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,PID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          WT14 CONDENABL;
%********************************************************************
% NOT ON LEVEL 14
          A,R1 B,12 ALUF,A-D ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDLC T,JMP T,HOLD CYCL,SLOW
          CHKIT CONDENABL;
%********************************************************************
% ON LEVEL 10-15 (EXCEPT 14)
          B,4 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          A,LC ALUF,PASSD ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          W1013 CONDENABL;
%********************************************************************
% ON LEVEL 15
          A,17 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
W1013:    PIC,MCLPID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
%********************************************************************
% ROUTINE TO CHECK WHICH INTERRUPT LEVEL SHOULD BE ENTERED
%********************************************************************
CHKIT:    PIC,LOSTS B,10 ALUD,NONE
          IDBS,BARG COMM,EPIC T,NEXT T,HOLD CYCL,SLOW
          COND,IRQ F,NEXT F,HOLD;
          AB,PID ALUF,PASSD ALUD,Q
          IDBS,REG COMM,CLIRQ T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,NONE
          IDBS,STS T,RETURN T,HOLD CYCL,SLOW
          CONDENABL COND,F15 F,RETURN F,HOLD;
%********************************************************************
% NO HARDWARE INTERRUPT REQUEST IS PENDING
          AB,PIE ALUF,ANDDQ ALUD,SLB
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          CONDENABL COND,F11;
%********************************************************************
% CPU IS IN ION
          ALUF,PASSD
          IDBS,ARG COMM,LDLC T,NEXT T,PUSH CYCL,SLOW
          100013;
%********************************************************************
% LOOP TO FIND HIGHEST ENABLED LEVEL
          B,R3 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,LC ALUF,PASSD ALUD,Q  % NEW LEVEL -> Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          PLINT;
%********************************************************************
% THE WAIT-INSTRUCTION WAS ON LEVEL 14
WT14:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          40000;
          PIC,MCLPID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          CHKIT;
%********************************************************************
%********************************************************************
% HARDWARE INTERRUPT HANDLING (EXT. OR INT. INTERRUPTS)
% ENTERED FROM INTERRUPT VECTOR (3740-3757)
%********************************************************************
% INTERNAL INTERRUPTS
EXT14:    B,P ALUF,B-1 ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          27;
          A,16 ALUD,NONE
          IDBS,BMG COMM,SMPID T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% ONLY LEVEL 15 IS HIGHER THAN STATUS 27
          PIC,LOSTS ALUD,NONE
          IDBS,GPR COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          PLINT;
%********************************************************************
% HARDWARE INTERRUPT EXCEPT LEVEL 14
XINT:     B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% LEVEL IN Q SHOULD BE ENTERED
PLINT:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,SWAP T,JMP T,HOLD CYCL,SLOW
          PLV0 CONDENABL;
%********************************************************************
% NEW LEVEL IS NOT LEVEL 0, UPDATE PID
          A,LC ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          AB,PID ALUF,ORDQ ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,PID ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
PLV0:     A,PIL ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,LC ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,RETURN F,HOLD;
          ALUF,ANDDQ ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          140000 CONDENABL;
%********************************************************************
% NEW LEVEL IS UNEQUAL TO OLD LEVEL
          A,LC ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,JMP F,HOLD;
          A,PIL B,R5 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW
          LVSWP CONDENABL;
%********************************************************************
% OLD LEVEL IS NOT 14 OR 15
          AB,PVL ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% CHANGE LEVEL ROUTINE. Q = NEW LEVEL
LVSWP:    AB,ACTLV ALUF,ORDQ ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          7;
          B,Z ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          A,PIL B,LC ALUF,PASSB ALUD,Q  % SAVE LOOP
          IDBS,ALU COMM,EWRF T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,Z ALUF,ANDDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          170000;
          A,Z B,R6 ALUF,ORAB ALUD,NONE
          IDBS,ALU COMM,LDPIL T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          7;
          AB,ACTLV ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,PUSH CYCL,SLOW;
          A,PIL B,LC ALUF,PASSD ALUD,B  % UNSAVE LOOP
          IDBS,REG T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,Z ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
% SUBROUTINE TO CLEAR INTERNAL INTERUPTS
CLR14:    B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          37760;
CLRXX:    PIC,MCLPID B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EPIC T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE USED BY TRR PID AND TRR PIE TO TRANSLATE TO PIC-FORMAT
PICFM:    B,Z ALUF,ANDDQ ALUD,SRB
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          74;
          A,7 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,6 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          PICF2 CONDENABL;
          A,0 B,Z ALUF,ORDA ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,NEXT F,HOLD;
PICF2:    B,Z MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          0 CONDENABL;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          77760;
          A,Z B,Z ALUF,ORAQ ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE USED BY E-COMMAND & MACL TO SET OUT EXAMINE MODE
EXMO2:    ALUD,NONE
          IDBS,ARG COMM,LDIR T,NEXT T,HOLD CYCL,SLOW
          150100;
          AB,EXMOD ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,STS COMM,SSTOP T,JMP T,PUSH CYCL,SLOW
          PIOF;
          ALUF,ZERO ALUD,Q
          IDBS,ALU COMM,RSDA T,JMP T,PUSH CYCL,SLOW
          RIIE1;
          PIC,LOSTS B,10 ALUF,ZERO ALUD,Q  % 0 -> PIE
          IDBS,BARG COMM,EPIC T,JMP T,PUSH CYCL,SLOW
          TRPIE;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          177777;
% INITIALIZE MOPC VARIABLES
          AB,RONLY ALUF,PASSQ ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,CDIGI ALUF,PASSQ ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,PRCHR ALUD,NONE IDBS,ARG COMM,EWRF T,NEXT T,HOLD CYCL,SLOW 443;
          PIC,LMSK ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EPIC T,NEXT T,MAPJ T,HOLD CYCL,SLOW;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTAD ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTA2 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          SPAC2;
          AB,BPFLG ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,STS T,JMP T,PUSH CYCL,SLOW
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
          IDBS,ARG T,NEXT T,PUSH CYCL,SLOW
          400;
%********************************************************************
% TEST 1 : 0-1+1=0
ST1:      B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R1 ALUF,B+1 ALUD,B
          T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF NOT 0 (400)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          STERR CONDENABL;
%********************************************************************
% TEST 2 : 0 + 1*5 = 5
ST2:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          1000;
          ALUF,ZERO ALUD,Q
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          3;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          ALUF,Q+1 ALUD,Q  % LOOP 5 TIMES
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          B,5 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF NOT 5 (1000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          STERR CONDENABL;
%********************************************************************
% TEST 3 : SHIFT DOUBLE LEFT
ST3:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          1400;
          B,3 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          70707;
          B,R3 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,PUSH CYCL,SLOW
          30303;
          B,R3 MIS,ROT ALUF,PASSB ALUD,SLD  % LOOP 5 TIMES
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW;
          ALUF,Q-D ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          34346;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF Q ERRONEOUS (1400)
          B,R3 ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          STERR CONDENABL;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          14156;
%********************************************************************
% STER1 IF R3 ERRONEOUS (2000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          STER1 CONDENABL;
%********************************************************************
% TEST 4 : -1 -> R5, 0 -> Q
ST4:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          2400;
          AB,PVL ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          177777;
          B,0 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF Q NOT 0 (2400)
          B,R5 ALUF,B+1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          STERR CONDENABL;
%********************************************************************
% STER1 IF R5+1 NOT 0 (3000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          STER1 CONDENABL;
%********************************************************************
% TEST 5 : 170(AARG) -> SWAP = 74000
ST5:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          3400;
          A,17 ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          74000;
% STERR IF NOT 74000 (3400)
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          STERR CONDENABL;
%********************************************************************
% TEST 6 : LC USED TO GENERATE 1 AMONG 0'S.
% SHIFT RIGHT DOUBLE WITH SHIFT GPR.
ST6:      B,R2 ALUF,B+1 ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          4000;
          B,R1 ALUF,ZERO ALUD,B
          IDBS,ARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          17;
          ALUF,PASSD ALUD,Q
          IDBS,ARG COMM,LDGPR T,NEXT T,PUSH CYCL,SLOW
          100000;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,LC ALUF,Q-D ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,POP;
%********************************************************************
% STERR IF BMG(LC) NOT CORRECT (4000)
          ALUF,Q-D ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          STERR CONDENABL;
%********************************************************************
% STER1 IF GPR NOT SHIFTED CORRECT (4400)
          B,R1 ALUF,PASSB ALUM,FMU ALUD,SRD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          STER1 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          ALUD,NONE  % LOOP BACK
          IDBS,PEA T,NEXT T,HOLD LCOUNT CYCL,SLOW;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,STS T,NEXT T,LOAD CYCL,SLOW;
%********************************************************************
% TEST 7 : TEST STS AND REGISTER FILE
ST7:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          5000;
          B,STS ALUD,NONE  % -1 -> REG.FILE
          IDBS,ARG COMM,EWRF T,NEXT T,HOLD CYCL,SLOW
          177777;
          ALUF,ZERO ALUD,NONE STS,LO  % 0 -> STS
          IDBS,ALU COMM,LDPIL T,JMP T,PUSH CYCL,SLOW
          ST77;
          ALUF,PASSD ALUD,Q  % STS -> Q
          IDBS,STS T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          10000;
%********************************************************************
% STERR IF STS NOT 10000 (5000)
          A,17 B,STS ALUF,D+1 ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          STERR CONDENABL;
%********************************************************************
% STER1 IF REG.FILE NOT -1 (5400)
          A,17 B,STS ALUF,ZERO ALUD,NONE  % 0 -> REG.FILE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW
          STER1 CONDENABL;
          A,17 B,STS ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% STER2 IF REG.FILE NOT 0 (6000)
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          STER2 CONDENABL;
          A,R7 ALUF,PASSA ALUD,NONE STS,LO
          IDBS,ALU COMM,LDPIL T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW;
%********************************************************************
% TEST 8 : TEST OF PIC
ST8:      B,R2 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          6400;
          ALUD,NONE  % PID -> REG.FILE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TAPID;
          A,17 B,STS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ZERO ALUD,Q  % 0 -> PID
          IDBS,ALU T,JMP T,LOAD CYCL,SLOW
          TRPID;
          ALUD,NONE  % 176000 -> PID
          IDBS,ARG COMM,SMPID T,NEXT T,HOLD CYCL,SLOW
          140017;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TAPID;
          ALUF,D-Q ALUD,Q  % CHECK PID
          IDBS,ARG T,NEXT T,POP CYCL,SLOW
          176000;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
%********************************************************************
% STERR IF PID NOT 176000 (6400)
          A,17 B,STS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          STERR CONDENABL;
          B,R6 ALUF,ZERO ALUD,B  % REG.FILE -> PID
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TRPID;
          A,R7 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MACL2;
%********************************************************************
% SUBROUTINE TO PLACE IDB HIGH
ST77:     ALUD,NONE
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          177777;
%********************************************************************
% DISPLAY ERROR NO. R2+2
STER2:    A,R2 B,R2 ALUF,A+B ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          400;
%********************************************************************
% DISPLAY ERROR NO. R2+1
STER1:    A,R2 B,R2 ALUF,A+B ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          400;
%********************************************************************
% DISPLAY ERROR NO. R2
STERR:    B,R2 ALUF,PASSB ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          DYTP2;
          ALUF,PASSQ ALUD,NONE  % LOOP ON ERROR
          IDBS,ALU COMM,LDPIL T,RETURN T,HOLD CYCL,SLOW;
%********************************************************************
% LAST PART OF MASTER CLEAR ROUTINE
MACL2:    ALUF,PASSD ALUD,Q
          IDBS,ARG COMM,SIOC T,NEXT T,HOLD CYCL,SLOW
          30140;
          AB,STATUS ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,MANIR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,TXT1 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,TXT2 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,SINGL ALUF,ZERO ALUD,Q
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          LVSWP;
%********************************************************************
%********************************************************************
% SUBROUTINE USED BY MOPC AND MACL TO CLEAR SEVERAL MOPC VARIABLES
%********************************************************************
SPAC2:    AB,DUMPF ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT CYCL,SLOW;
          AB,SCRAM ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,CURNR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,UPPNR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTN2 ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,DEPOS ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% STOP CPU. ENTERED FROM WAIT-INSTRUCTION. PRINT #
%********************************************************************
STOPW:    AB,PRCHR ALUD,NONE
          IDBS,ARG COMM,EWRF T,NEXT T,HOLD CYCL,SLOW
          443;
%********************************************************************
%********************************************************************
% FROM INTERRUPT VECTOR IF THE CPU IS IN STOP (3760 OR 3770)
%********************************************************************
STOP:     AB,MACL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,SLOW
          STOP2 CONDENABL;
%********************************************************************
% STOP FOLLOWS DIRECTLY AFTER MASTER CLEAR. STAND-BY IS NOT OK
          A,R5 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          AB,MACL ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW
          STOP2 CONDENABL;
%********************************************************************
% PANEL IS LOCKED WHEN POWER-UP, OR LOAD IS PRESSED
ALDLO:    ALUD,NONE  % USE ALD-SWITCH
          IDBS,ALU T,JMPALD T,PUSH CYCL,SLOW
          ALDVC;
%********************************************************************
% LOAD, $ OR &, LOAD CODE IN Q
LOAD1:    A,17 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,15 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          INIT CONDENABL;
%********************************************************************
% Q IS NOT 0
          A,7 B,STS ALUF,D-1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          ETLO1 CONDENABL;
%********************************************************************
%********************************************************************
% MASS STORAGE LOAD, BECAUSE BIT 13 IS 1
%********************************************************************
MASS:     A,1 B,D ALUF,D+Q ALUD,B  % DEV.NO. +2 -> D
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
MAS1:     B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% IOX N+1 (0) CORE ADDRESS
          A,D B,R1 ALUF,A-1 ALUD,B
          T,JMP T,PUSH CYCL,SLOW
          IOXG;
%********************************************************************
% IOX N+1 (0) CORE ADDRESS
          A,D B,R1 ALUF,A-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          IOXG;
%********************************************************************
% IOX N+3 (0) BLOCK ADDRESS
          A,D B,R1 ALUF,A+1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          IOXG;
%********************************************************************
% IOX N+7 (2000) WORD COUNTER
          A,D B,R1 ALUF,D+A ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          5;
          A,12 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          IOXG;
%********************************************************************
% IOX N+5 (4) ACTIVATE DEVICE
          A,D B,R1 ALUF,D+A+1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,2 B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          IOXG;
%********************************************************************
% IOX N+4 READ STATUS
MAS2:     A,D B,R1 ALUF,D+A ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          IOXG;
          A,A B,4 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,2 B,R7 ALUF,PASSD ALUD,B
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW
          MAS2 CONDENABL;
%********************************************************************
% DEVICE FINISHED
          A,A B,R7 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MAS1 CONDENABL;
%********************************************************************
% NO ERRORS, START IN 0, AND LEAVE MOPC
          B,P ALUF,ZERO ALUD,B
          IDBS,ALU COMM,START T,JMP T,HOLD CYCL,SLOW
          ESCAP;
%********************************************************************
%********************************************************************
% RESTART, ENTERED FROM INTERRUPT VECTOR (3766)
% ONLY IF STAND-BY POWER IS OK, OR RESTART BUTTON PRESSED
%********************************************************************
RSTRT:    ALUF,PASSD ALUD,Q
          IDBS,IOR COMM,CLRTC T,NEXT T,HOLD CYCL,SLOW
          COND,STP F,RETURN F,POP;
          A,15 ALUF,ANDDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          CONDENABL COND,F=0 F,JMP F,HOLD;
%********************************************************************
% ONLY IF IN STOP MODE
          AB,MACL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          RSTR1 CONDENABL;
%********************************************************************
% IF LOCKED
          AB,MACL ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMPALD T,PUSH CYCL,SLOW
          ALDVC;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT;
%********************************************************************
% LOAD IF BIT 15=1, START IN ADDRESS 20 IF BIT 15=0
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          LOAD1 CONDENABL;
%********************************************************************
% START CPU IN ADDRESS 20
RSTR2:    A,2 B,P ALUF,PASSD ALUD,B
          IDBS,AARG T,JMP T,HOLD CYCL,SLOW
          CONT;
%********************************************************************
% IF UNLOCKED, DO NOTHING JUST AFTER MASTER CLEAR, ELSE START IN 20
RSTR1:    AB,MACL ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW
          INIT CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RSTR2;
%********************************************************************
%********************************************************************
% LOAD BUTTON IS PRESSED, ENTERED FROM INTERRUPT VECTOR (3764 OR 3774)
%********************************************************************
LOAD:     ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,STP F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ALDLO CONDENABL;
%********************************************************************
%********************************************************************
% CPU IS NOT IN STOP WHEN LOAD IS PRESSED, OR
% CONTINUE BUTTON IS PRESSED, ENTERED FROM INTERRUPT VECTOR (3765 OR 3775)
%********************************************************************
CONT:     ALUD,NONE
          IDBS,ALU COMM,START T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ALDLO CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          LOAD1;
%********************************************************************
%********************************************************************
% BINARY LOADER. LOAD CODE BIT 13 IS 0.
%********************************************************************
ETLO1:    B,D ALUF,PASSQ ALUD,B  % DEV.NO. -> D
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          DVACT;
SEEK:     A,R5 B,P ALUF,PASSA ALUD,B  % POSSIBLE S.A.
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
SIKI:     A,5 B,L ALUF,D+1 ALUD,B  % READ OCTAL NO.
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          ASS8;
          A,R2 B,15 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R2 B,L ALUF,A-B ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SEEK CONDENABL;
%********************************************************************
% LAST CHAR. IS NOT CR
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          EXFOU CONDENABL;
%********************************************************************
% LAST CHAR. IS NOT !
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SIKI;
%********************************************************************
% EXCLAMATION MARK (!) FOUND
EXFOU:    A,STS B,STS ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          B,L ALUF,ZERO ALUD,B  % READ CORE ADDR.
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BIN;
          A,Z B,X ALUF,PASSA ALUD,B  % READ WORD COUNT
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BIN;
          A,Z B,T ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% LOOP TO STORE PROGRAM IN MEMORY
STLP:     ALUD,NONE  % READ ONE WORD
          IDBS,ALU T,JMP T,PUSH CYCL,WAIT
          BIN;
          B,T ALUF,B-1 ALUD,B  % DECR. WORD COUNT
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,X B,X ALUF,B+1 ALUD,B,YA  % INCR. CORE ADDR.
          IDBS,ALU MIS,PT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;
%********************************************************************
% CHECKSUM OK, READ ACTION CODE
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          ASS8;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          ESCAP CONDENABL;
%********************************************************************
% ACTION CODE =0, START PROGRAM
          ALUD,NONE
          IDBS,ALU COMM,START T,JMP T,HOLD CYCL,SLOW
          ESCAP;
%********************************************************************
% SUBROUTINE FOR BINARY LOADER TO READ ONE CHARACTER
INCH:     A,D B,R1 ALUF,D+A ALUD,B  % IOX N+2
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          IOXG;
          A,A B,10 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INCH CONDENABL;
%********************************************************************
% READY FOR TRANSFER
          A,D B,R1 ALUF,PASSA ALUD,B  % IOX N
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          IOXG;
          A,A B,STS ALUF,ANDAB ALUD,NONE
          IDBS,ALU COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          DVACT;
%********************************************************************
% ACTIVATE DEVICE
DVACT:    B,A ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          4005;
          A,D B,R1 ALUF,D+A+1 ALUD,B  % IOX N+3 (4005)
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          IOXG;
%********************************************************************
% SUBROUTINE FOR BINARY LOADER TO READ OCTAL NUMBER, RETURNS ON NON-OCTAL CHAR
ASS8:     AB,OCTNR ALUF,ZERO ALUD,B
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          ASS81;
%********************************************************************
% OCTAL DIGIT FOUND
ASS82:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          OCDIG;
ASS81:    AB,OCTNR ALUF,PASSD ALUD,B  % READ CHARACTER
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          INCH;
          A,STS B,R2 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          60;
          A,R2 B,R3 ALUF,A-Q ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R3 B,10 ALUF,A-D ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
          CONDENABL COND,F15 F,RETURN F,POP;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ASS82 CONDENABL;
%********************************************************************
% SUBROUTINE USED BY BINARY LOADER TO READ TWO BYTES AS ONE 16-BIT WORD
BIN:      ALUD,NONE  % READ BYTE 1
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          INCH;
          ALUD,NONE  % SWAP BYTES
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,Z ALUF,PASSD ALUD,B
          IDBS,SWAP T,JMP T,PUSH CYCL,SLOW
          INCH;
          A,Z B,Z ALUF,ORDA ALUD,B  % MAKE WORD
          IDBS,GPR T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% ENTERED FROM INTERRUPT VECTOR EVERY 20 MS
%********************************************************************
MS20:     B,10 ALUF,PASSD ALUD,Q
          IDBS,BARG COMM,CLRTC T,NEXT T,HOLD CYCL,SLOW;
          AB,STATUS ALUF,ORDQ ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MOPC CONDENABL;
%********************************************************************
% MOPC SHOULD BE DRIVEN BY PANEL REQUEST FROM MEMORY MANAGEMENT MODULE
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
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
          IDBS,IOR T,JMP T,HOLD CYCL,SLOW
          NOUTP CONDENABL;
%********************************************************************
% CHARACTER IS WAITING TO BE OUTPUTTED
          A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          OUTPT CONDENABL;
%********************************************************************
% OUTPUT STOPPED BY INPUT
          ALUD,NONE
          IDBS,ALU COMM,RSDA T,JMP T,HOLD CYCL,SLOW
          RONLY;
OUTPT:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT CONDENABL;
%********************************************************************
% UART READY FOR OUTPUT
          AB,PRCHR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,TBSTR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUF,D-Q ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          43;
%********************************************************************
% JUMP TO CR IF OUTPUTTED CHAR. WAS #
          B,12 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          CR CONDENABL;
%********************************************************************
% JUMP TO LFEED IF OUTPUTTED CHAR. WAS LF
          AB,PRCHR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          LFEED CONDENABL;
          AB,CDIGI ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          OUTP1 CONDENABL;
%********************************************************************
% THERE ARE MORE CHARACTERS LEFT TO BE PRINTED IN ONE OCTAL NUMBER
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,CDIGI ALUF,Q-1 ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          SPAC3 CONDENABL;
%********************************************************************
% GET NEXT DIGIT
          AB,NUMBR MIS,ROT ALUF,PASSD ALUM,MIC ALUD,SLB
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,NUMBR MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,NUMBR MIS,ROT ALUF,PASSB ALUM,MIC ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,NUMBR ALUF,PASSB ALUD,Q
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          7;
          ALUF,D+Q ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          60;
%********************************************************************
% PLACE IT IN PRCHR
PRICH:    AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          2036;
%********************************************************************
% GET SPACE, WHICH IS THE LAST CHAR. IN AN OCTAL NUMBER
SPAC3:    A,5 ALUF,PASSD ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          PRICH;
%********************************************************************
% ONE OCTAL NUMBER IS FINISHED
OUTP1:    AB,DUMPF ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,CNT10 ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          2036 CONDENABL;
%********************************************************************
% WE ARE PRESENTLY INSIDE A DUMP COMMAND
          B,2 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          B,12 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          DUMP2 CONDENABL;
          AB,CURNR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          DMP10 CONDENABL;
%********************************************************************
% SOMETHING ELSE THAN MEMORY CONTENT SHOULD BE PRINTED IN THE DUMP NOW
DUMP2:    AB,CNT10 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          DUMP3;
%********************************************************************
% CNT10 = 0 , PRINT ADDRESS
DUMP4:    AB,CURNR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          PROCT;
          AB,CNT10 ALUF,D+1 ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          MRET3;
%********************************************************************
% NEXT OCTAL NUMBER SHOULD POSSIBLY BE PRINTED
DMP10:    AB,UPPNR ALUF,Q-D ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,PRCHR ALUF,ZERO ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SPACE CONDENABL;  % JUMP TO SPACE IF FINISHED WITH DUMP
%********************************************************************
% NOT FINISHED
          AB,SCRAM ALUD,NONE
          IDBS,REG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% GET VALUE
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          DSPLY;
          AB,CURNR ALUF,D+1 ALUD,B
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% PRINT IT WITH PROCT
          AB,CURNR ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          PROCT;
%********************************************************************
% INCREMENT CNT10, CONTROLLING THE NUMBER OF ADDRESSES PER LINE
MRET2:    AB,CNT10 ALUF,D+1 ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
MRET3:    AB,CNT10 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          2036;
DUMP3:    B,1 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
          DUMP5 CONDENABL;
%********************************************************************
% CNT10 = 1, PRINT /
DUMP6:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          57;
DMP61:    AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,CNT10 ALUF,D+1 ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          MRET3;
DUMP5:    B,12 ALUF,D-Q ALUD,NONE
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
          DUMP7 CONDENABL;
%********************************************************************
% CNT10 = 12, PRINT CR
DUMP8:    B,15 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          DMP61;
DUMP7:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          DUMP9 CONDENABL;
%********************************************************************
% CNT10 = 13, PRINT LF
DUMP9:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          412;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,CNT10 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          2036;
%********************************************************************
%********************************************************************
% NO OUTPUT IS WAITING TO GET OUT
%********************************************************************
% COPCM TO CHECK IF MOPC SHOULD USE TERMINAL INPUT
NOUTP:    A,13 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          COPCM;
%********************************************************************
% MOPC USES TERMINAL INPUT
INPUT:    AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,6 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          WSIOC;
          ALUF,PASSD ALUD,Q
          IDBS,IOR T,NEXT T,HOLD CYCL,SLOW;
          A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
%********************************************************************
% NO DATA AVAILABLE ?
          B,Z ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          DISPL CONDENABL;
%********************************************************************
% READ CHARACTER
          ALUF,ANDDQ
          IDBS,ARG COMM,RSDA T,NEXT T,HOLD CYCL,SLOW
          177;
          B,R2 ALUF,PASSQ ALUD,B
          COMM,TBSTR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          B,R5 ALUF,Q-D ALUD,NONE
          IDBS,BARG T,JMP T,PUSH CYCL,SLOW
          2132;
          B,R2 ALUF,PASSD
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          20;
          ALUD,NONE
          T,RETURN T,POP CYCL,SLOW
          CONDENABL COND,F15 F,NEXT F,POP;
          B,R1 ALUF,Q-D ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          60;
          A,R1 B,STS ALUF,A-D ALUD,NONE
          IDBS,BARG T,JMP T,HOLD CYCL,SLOW
          2136 CONDENABL;
          ALUD,NONE
          T,JMP T,HOLD CYCL,SLOW
          2301 CONDENABL;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          101;
          B,R5 ALUF,ZERO ALUD,B
          T,JMP T,HOLD CYCL,SLOW
          2142 CONDENABL;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          132;
          ALUD,NONE
          T,JMP T,HOLD CYCL,SLOW
          2314 CONDENABL;
          A,T ALUF,Q-D
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
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
          IDBS,AARG T,JMP T,HOLD CYCL,SLOW
          SPACE CONDENABL;
%********************************************************************
% OTHER CHARACTERS ONLY LEGAL IN STOP, AND WITHOUT LETTERS IN FRONT
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
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
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW DOT CONDENABL;
%********************************************************************
% ILLEGAL MOPC CONDITION, PRINT ?
ILLEG:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          77;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          RONLY;
%********************************************************************
% RETURN IF MOPC INPUT IS ACTIVE
COPCM:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          CONDENABL COND,STP F,NEXT F,HOLD;
%********************************************************************
% INPUT IF STOP
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INPUT CONDENABL;
%********************************************************************
% REFRESH DISPLAY IF MOPC IS IDLE
DISPL:    AB,DISPL ALUD,NONE
          IDBS,REG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% SEND DATA TO DISPLAY PROCESSOR
          AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          DSPLY;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
%********************************************************************
% SUBROUTINE TO SEND DATA TO OPTIONAL DISPLAY. LC = DISPLAY TYPE. Q = ADDRESS
%********************************************************************
DSPLY:    A,LC ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,JMPAOPR T,HOLD CYCL,SLOW
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
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          DYDAT;
%********************************************************************
% LC=1, REGISTER EXAMINE
VC41:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          VC411;
          A,A ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,POP CYCL,SLOW;
OPAST:    A,R7 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          DYTP1;
%********************************************************************
% USE IRR-ROUTINE
VC411:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          IRR;
%********************************************************************
% LC=2, AUXILIARY REGISTER EXAMINE
VC42:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,REG B,LC ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          DYTP1;
%********************************************************************
% LC = 3 : INTERNAL REGISTER EXAMINE
VC43:     ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
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
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          AB,ACTLV ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,NUMBR ALUF,PASSB ALUD,Q
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          1;
          ALUF,D+Q ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          60;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          5;
          AB,CDIGI ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO CHECK THAT SCRAM = 0 AND STOP
%********************************************************************
STTS0:    AB,SCRAM ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;
%********************************************************************
% SUBROUTINE TO CHECK STOP
STTST:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,STP F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
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
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,LC=0;
          B,6 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
          AB,TXT2 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,PUSH CYCL,SLOW;
          AB,TXT1 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,POP LCOUNT CYCL,SLOW
          LCOUNT;
          A,R2 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,TXT1 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,TXT2 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO ASSEMBLE AN OCTAL NUMBER FROM A DIGIT
%********************************************************************
OCDIG:    AB,OCTN2 ALUF,PASSD ALUD,B
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          BUILD;
OCDIX:    AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          B,R5 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R5 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R5 ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          7;
          A,R2 B,R2 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R2 ALUF,ORAQ ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTN2 ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,DEPOS ALUD,NONE
          IDBS,ARG COMM,EWRF T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% ROUTINES FOR DIFFERENT MOPC INPUT CARACTERS
%********************************************************************
% MOPC INPUT CHARACTER WAS 0-7
OCDI2:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          OCDIG;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% MOPC INPUT CHARACTER WAS ESCAPE
ESCAP:    AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,6 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          WSIOC;
%********************************************************************
% ROUTINE TO MAKE DEPOSIT ILLEGAL
RONLY:    AB,RONLY ALUD,NONE
          IDBS,ARG COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          SPACE;
%********************************************************************
% MOPC INPUT CHARACTER WAS SPACE OR @, RESET MOPC
SPACE:    AB,MANIR ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,BPFLG ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,SINGL ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% MOPC INPUT CHARACTER WAS . " Z PARTIALLY RESET MOPC
SPAC9:    AB,TXT1 ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW SPAC2;
          AB,TXT2 ALUF,ZERO ALUD,NONE IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW INIT;
%********************************************************************
% MOPC OUTPUT CHARACTER WAS LF, PRINT #
LFEED:    AB,PRCHR ALUD,NONE
          IDBS,GPR COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% MOPC INPUT CHARACTER WAS A-Y, SCRAMBLE CHARACTERS
LETTR:    AB,SCRAM ALUF,PASSD ALUM,MIC ALUD,SLB
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          BUILD;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          37;
          A,R2 B,R2 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R2 B,R5 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,SCRAM ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU COMM,START T,JMP T,HOLD CYCL,SLOW
          ESCAP CONDENABL;
          B,P ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
MM0:      A,0 B,T ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
MM1:      B,R2 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
MM2:      A,B B,P ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
MM3:      A,P B,L ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MM31 CONDENABL;
          A,T B,L ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,COND F,JMP F,HOLD;
MM31:     A,D B,L ALUF,XORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MM4 CONDENABL;
          A,P B,P ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,DERQ T,NEXT T,HOLD CYCL,SLOW;
          A,L ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          MM41;
MM4:      A,P B,P ALUF,B+1 ALUD,B,YA
          IDBS,ALU COMM,EXRQ T,NEXT T,HOLD CYCL,SLOW;
          A,L ALUF,XORDA ALUD,NONE
          IDBS,DBR COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MMERR CONDENABL;
MM41:     A,P B,X ALUF,A-B-1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,F=0 F,JMP F,HOLD;
          B,R2 ALUF,INVB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MM3 CONDENABL;
          B,R2 ALUF,INVB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MM2 CONDENABL;
          A,T B,T ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,D ALUF,INVB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MM1 CONDENABL;
          B,D ALUF,INVB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MM0 CONDENABL;
          B,A ALUF,INVB ALUD,B
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          443;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MM00 CONDENABL;
          AB,PRCHR ALUD,NONE
          IDBS,GPR COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          RONLY;
MMERR:    B,D ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,L B,D ALUF,XORAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,T ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          ILLEG;
%********************************************************************
% " TYPED, SET READY FOR MANUAL INSTRUCTION
QUOTE:    AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,BRKPT ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,MANIR ALUD,NONE
          IDBS,ARG COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          SPAC9;
%********************************************************************
% STOP-ROUTINE CONTINUED. CHECK FOR MANUAL INSTRUCTION (NOT USED BY MOPC)
MANIR:    AB,MANIR ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          AB,BRKPT ALUD,NONE
          IDBS,REG COMM,LDGPR T,JMP T,HOLD CYCL,SLOW
          INIT CONDENABL;
%********************************************************************
% DO MANUAL INSTRUCTION
          ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,JMP T,PUSH CYCL,SLOW
          MANI1;
%********************************************************************
% POSSIBLE RETURN FROM INSTRUCTION
          ALUD,NONE
          IDBS,ALU T,MAPJ T,HOLD CYCL,SLOW
          FETCH;
MANI1:    ALUD,NONE
          IDBS,GPR COMM,CLIRQ T,MAPJ T,HOLD CYCL,SLOW
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          SINIT CONDENABL;
%********************************************************************
% PERFORM ONE SINGLE INSTRUCTION IN Z OR BREAKPOINT MODE. USED BY STOP OR MOPC
SINGL:    A,P B,P ALUF,A+1 ALUD,B,YA
          IDBS,ALU MIS,FETCH COMM,RDRQ T,JMP T,PUSH CYCL,SLOW
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
BRKZZ:    ALUD,NONE IDBS,ALU COMM,START T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% EXECUTE SINGLE INSTR.
          PIC,RVECT ALUD,NONE
          IDBS,GPR COMM,SSTOP T,MAPJ T,HOLD CYCL,SLOW
          FETCH;
%********************************************************************
% MULTIPLE SINGLE, USED BY MOPC ONLY
SINIT:    AB,SINGL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          SPAC9;
%********************************************************************
% ENTERED FROM INTERRUPT VECTOR, SINGLE BUTTON PRESSED
% ONLY LEGAL IN STOP
SING2:    ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,STP F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SINGL CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% < TYPED
ANGBR:    AB,SCRAM ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;
          AB,CURNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,DUMPF ALUD,NONE
          IDBS,BARG COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% * TYPED
ASTRX:    AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          PROCT;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SPACE;
%********************************************************************
% MOPC JUST PRINTED # AFTER LNE WAS ENDED
CR:       AB,PRCHR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          CR2 CONDENABL;
%********************************************************************
% IRD WRITTEN, TEST IF STOP
          B,3 ALUF,PASSD ALUD,Q
          IDBS,BARG T,JMP T,PUSH CYCL,SLOW
          STTST;
%********************************************************************
% SET UP FOR INTERNAL REGISTER DUMP
          AB,DUMPF ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,SCRAM ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          20;
          AB,UPPNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,CURNR ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
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
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          CR22 CONDENABL;
%********************************************************************
% SET VIRTUAL EXAMINE
          A,2 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
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
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RONLY;
%********************************************************************
% F NOT TYPED, CHECK MACL
CR20:     ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          176;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          CR3 CONDENABL;
%********************************************************************
% MACL TYPED
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MACL;
%********************************************************************
% MACL NOT TYPED, CHECK STOP
CR3:      ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          426;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          CR16 CONDENABL;
%********************************************************************
% STOP TYPED
          ALUD,NONE
          IDBS,ALU COMM,SSTOP T,JMP T,HOLD CYCL,SLOW
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
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          RONLY CONDENABL;  % RONLY IF NOT MEMORY EXAMINE
%********************************************************************
% GET AND PRINT NEXT MEMORY ADDRESS
CR6:      AB,OCTAD ALUF,Q+1 ALUD,Q
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          DSPLY;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          PROCT;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SPACE;
%********************************************************************
% SOMETHING TO DEPOSIT
CR4:      ALUF,D-Q ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          52;
%********************************************************************
% IF SCRAM IS UNEQUAL TO 'DEP', CHECK THAT SCRAM = 0 AND STOP
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
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
          IDBS,REG COMM,DERQ T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,REG COMM,CLIRQ T,MAPJ T,JMP T,PUSH CYCL,SLOW
          OPCRB;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          CR10 CONDENABL;
          B,DEST ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          CR10B;
          ALUF,PASSQ ALUD,NONE STS,LO
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RONLY;
CR10:     A,REG B,DEST ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          CR10B;
          A,REG B,Z ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          RONLY;
CR10B:    ALUF,ANDDQ ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377;
          B,DEST ALUF,PASSD ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          RONLY CONDENABL;
CR9:      ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          CR11 CONDENABL;
%********************************************************************
% AUXILIARY REGISTER DEPOSIT
          AB,WRADR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,3 B,R6 ALUF,ORDQ ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          A,R6 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,REG B,LC ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          RONLY;
%********************************************************************
% INTERNAL REGISTER DEPOSIT
CR11:     A,A B,R7 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          CR12;
          A,R7 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          RONLY;
CR12:     AB,WRADR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% USE TRR
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TRR;
%********************************************************************
% DUMP SHOULD STARTED AFTER CR
CR1:      A,A ALUF,Q-D ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW
          CR13 CONDENABL;
%********************************************************************
% MEMORY DUMP
          AB,OCTNR ALUF,D+1 ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,UPPNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          DMP11;
CR13:     ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          CR14 CONDENABL;
%********************************************************************
% REGISTER DUMP
          AB,OCTNR ALUF,D+1 ALUD,B
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          CR15;
          AB,SCRAM ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          DMP11;
CR14:     ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          125;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          ILLEG CONDENABL;
%********************************************************************
% REGISTER DUMP EXTENDED (AUXILIARY REGISTERS)
          AB,OCTNR ALUF,D+1 ALUD,B
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          CR15;
          AB,SCRAM ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% END OF DUMP SET-UP ROUTINES
DMP11:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          15;
          AB,PRCHR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,CNT10 ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% SUBROUTINE COMMON FOR RD AND RDE
CR15:     AB,CURNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSB ALUM,MIC ALUD,SLD
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSB ALUM,MIC ALUD,SLD IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSB ALUM,MIC ALUD,SLD IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,CURNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,UPPNR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          B,1 ALUF,PASSD ALUD,Q
          IDBS,BARG T,RETURN T,POP CYCL,SLOW;
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
          IDBS,ALU ALUD,NONE T,JMP T,HOLD BUSX CONDENABL CYCL,SLOW;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLEG;
%********************************************************************
% REGISTER NAMES/
SXX:      B,0 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
DXX:      B,1 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
PXX:      B,2 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
BXX:      B,3 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
LXX:      B,4 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
AXX:      B,5 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
TXX:      B,6 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
XXX:      B,7 IDBS,BARG ALUF,PASSD ALUD,Q T,JMP T,HOLD CYCL,SLOW REGXX;
REGXX:    B,R2 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          OCDIX;
%********************************************************************
% R/
RXX:      AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          TYP1;
TYP1:     A,0 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          RWY;
%********************************************************************
% I/
IXX:      AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
TYP3:     A,1 B,R1 ALUF,D+1 ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          RWY;
%********************************************************************
% MEMORY EXAMINE
RWX:      B,R1 ALUF,ZERO ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% REGISTER EXAMINE
RWY:      AB,OCTAD ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,WRADR ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTN2 ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTA2 ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          A,R1 ALUF,PASSA ALUD,Q
          IDBS,ALU COMM,LDLC T,NEXT T,HOLD CYCL,SLOW;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,WRTYP ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          RWZ;
%********************************************************************
% GET VALUE OF EXAMINE
RWZ:      AB,OCTAD ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          DSPLY;
          AB,RONLY ALUF,ZERO ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          PROCT;
          AB,DISPL ALUF,PASSD ALUD,NONE
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          LABEL CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          SPACE;
%********************************************************************
% IO/ TYPED
IOOPC:    A,A B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG COMM,CLIRQ T,MAPJ T,NEXT T,HOLD CYCL,SLOW;
          B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,OPR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          B,A ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          IOXX1;
          A,A ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          PROCT;
          A,R4 B,A ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RONLY;
%********************************************************************
% OPR/ TYPED
OPRX:     A,16 ALUF,D+1 ALUD,Q
          IDBS,AARG T,JMP T,HOLD CYCL,SLOW
          TYP2;
%********************************************************************
% U/ TYPED
UXX:      ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          142;
TYP2:     A,1 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          RWY;
%********************************************************************
% ACTX/ TYPED
ACTX:     B,17 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          RONLY;
%********************************************************************
% BUS/ TYPED
BUSX:     B,4 ALUF,PASSD ALUD,Q
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          AB,DISPL ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
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
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          60;
          ALUF,ANDDQ ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,2 ALUF,XORDQ ALUD,NONE
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          T,NEXT T,HOLD CYCL,SLOW
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
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,R4 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,13 ALUF,D-1 ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,R6 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,T ALUF,A+B ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,X ALUF,A+B ALUD,B CRY,C
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO WRITE R10 INTO LOCATION [R3]
WRDST:    A,R7 B,T ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          WRDS2 CONDENABL;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
WRDS3:    A,STS ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,CLIRQ T,RETURN T,POP CYCL,WAIT
          COND,IRQ F,NEXT F,HOLD;
WRDS2:    A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,WRRQ T,JMP T,HOLD CYCL,SLOW
          WRDS3;
%********************************************************************
% SUBROUTINE TO READ LOCATION [R3] INTO R10
RDDST:    A,R7 B,T ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RDDS2 CONDENABL;
          A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
RDDS3:    B,STS ALUF,PASSD ALUD,B
          IDBS,DBR T,RETURN T,POP CYCL,WAIT;
RDDS2:    A,R3 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD CYCL,SLOW
          RDDS3;
%********************************************************************
% SUBROUTINES TO CHECK THAT LAST PAGE NEEDED BY MOVE IS IN MEMORY
PFSRC:    A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,D ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDSRC CONDENABL;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDSRC CONDENABL;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RDSRC;
PFDST:    A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDDST CONDENABL;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          RDDST CONDENABL;
          B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RDDST;
%********************************************************************
% SUBROUTINE TO FILL LEFT BYTE OF [R3] WITH LEFT BYTE OF Q
BTL:      B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDDST;
          A,Z B,STS ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          WRDST;
          B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
%********************************************************************
% ADJUST R5 AND R6 FOR BTL AND BTR
BTX:      B,R5 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R6 ALUF,B-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO FILL RIGHT BYTE OF [R3] WITH RIGHT BYTE OF Q
BTR:      B,X ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDDST;
          A,Z B,STS ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          WRDST;
          A,17 B,R3 ALUF,B+1 ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,WAIT;
          A,T B,T ALUF,MASKDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          BTX;
%********************************************************************
%********************************************************************
% BYTE FILL INSTRUCTION  BFILL (140130)
%********************************************************************
BFILL:    A,16 B,R7 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          7777;
          A,T B,R5 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          A,X B,R3 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          BFIL2 CONDENABL;
%********************************************************************
% FINISHED, OR 0 BYTES TO MOVE
          AB,SSAVE ALUD,NONE
          IDBS,STS COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,R6 MIS,ROT ALUF,PASSA ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXS1;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          170000;
          A,T B,T ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,SSAVE ALUD,NONE STS,LO
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          A,Z B,STS ALUF,MASKAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          BTL CONDENABL;  % LAST BYTE NOT ON WORD BOUNDARY -> BTL
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
BFIL2:    B,Z ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          377;
          A,Z B,A ALUF,ANDAB ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R2 ALUF,ORDQ ALUD,B
          IDBS,SWAP T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BTR CONDENABL;  % FIRST BYTE NOT ON WORD BOUNDARY -> BTR
          A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          LSET1;
%********************************************************************
% LOOP TO STORE WORDS OF TWO BYTES EACH
BFLOO:    A,R2 B,STS ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          WRDST CONDENABL;
          B,R3 ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          BFILQ CONDENABL;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          BFLOO;
%********************************************************************
% INTERRUPT IS SENSED WHILE INSIDE LOOP
BFILQ:    A,R4 B,R1 ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,X B,X ALUF,A+Q+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R1 ALUF,Q+1 ALUD,SLB
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          170000;
          A,T B,T ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,R1 ALUF,A-B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 B,T ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% SUBROUTINE TO MOVE RIGHT BYTE OF [R2] TO LEFT BYTE OF [R3]
RBTL:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDSRC;
          A,Z B,R4 ALUF,ANDDA ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,Z ALUF,MASKAQ ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          BTL;
%********************************************************************
% SUBROUTINE TO MOVE LEFT BYTE OF [R2] TO LEFT BYTE OF [R3]
LBTL1:    B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
LBTL:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDSRC;
          A,Z B,STS ALUF,MASKAB ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          BTL;
%********************************************************************
% SUBROUTINE TO MOVE LEFT BYTE OF [R2] TO RIGHT BYTE OF [R3]
LBTR:     B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          3243;
          ALUF,ANDDA
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          B,R4 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          B,R4 ALUF,MASKAB ALUD,B
          T,JMP T,HOLD CYCL,SLOW
          2720;
RBTR:     ALUD,NONE
          T,JMP T,PUSH CYCL,SLOW
          3243;
          B,STS ALUF,ANDAB
          T,JMP T,HOLD CYCL,SLOW
          2720;
MOVB9:    A,R4 ALUF,PASSD
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,D ALUF,ANDAQ ALUD,NONE
          T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          ALUD,NONE
          T,NEXT T,HOLD CYCL,SLOW
          3105 CONDENABL;
          ALUD,NONE
          T,JMP T,HOLD CYCL,SLOW
          3141;
MOVB:     A,T ALUF,PASSA
          T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,T ALUF,MASKDQ ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          3007;
%********************************************************************
MOVBF:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          10000;
          A,T B,T ALUF,ORAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% COMMON PARTS OF MOVB AND MOVBF
% SET UP INITIAL REGISTERS
MOVB3:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          7777;
          A,D B,R5 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,15 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,T B,R1 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,T B,R6 ALUF,ANDAQ ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MINTD CONDENABL;
          A,14 B,R2 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,T B,R2 ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MOVB2 CONDENABL;
MINTD:    A,R5 B,R6 ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          A,14 B,R4 ALUF,INVQ ALUD,B
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          MOVB5 CONDENABL;
          A,R6 B,R5 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
MOVB5:    A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,R1 B,T ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MOVB2 CONDENABL;
          A,R4 B,T ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,T ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,D ALUF,ANDAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,D ALUF,ORAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
MOVB2:    A,10 B,Z ALUF,D-1 ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,WAIT;
          A,R5 ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,16 B,R7 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          MOVB9 CONDENABL;  % ZERO BYTES TO MOVE
%********************************************************************
% ENSURE THAT NECESSARY PAGES ARE IN MEMORY
          B,R2 ALUF,ZERO ALUM,FMU ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH CYCL,SLOW
          PFSRC;
          A,X B,R3 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH CYCL,SLOW
          PFDST;
          B,R2 ALUF,ZERO ALUM,FMU ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R2 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH CYCL,SLOW
          RDSRC;
          A,X B,R3 ALUF,D+A ALUD,B
          IDBS,GPR T,JMP T,PUSH CYCL,SLOW
          RDDST;
          A,A B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDSRC;
          A,X B,R3 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDDST;
%********************************************************************
% SELECT WAY THROUGH MOVE
          A,D ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,JMP F,HOLD;
          A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MB1T4 CONDENABL;
MB5T8:    A,R5 B,R4 ALUF,A-1 ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MB5T6 CONDENABL;
          A,A B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,CRY F,JMP F,PUSH;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          MB7T CONDENABL;
%********************************************************************
% FORWARD ALIGNED, FIRST BYTE RIGHT
MB8:      A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          RBTR;
          B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,A ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TTDCR;
          A,R1 B,D ALUF,MASKAB ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          FWLOO;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MB21;
MB7T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TOLAP;
          A,R5 B,STS ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          CONDENABL;
%********************************************************************
% BACKWARD ALIGNED, FIRST BYTE RIGHT
MB7:      A,STS B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,STS B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          LBTL1 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BWLOO;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXBW;
          A,T B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RBTR;
MB71:     B,X ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,T ALUF,PASSA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
MB5T6:    A,A B,X ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,CRY F,JMP F,PUSH;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          MB5T CONDENABL;
%********************************************************************
% FORWARDS SWAP, FIRST BYTE RIGHT
MB6:      ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          FWEXL;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MB41;
MB5T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TOLAP;
          A,R5 B,STS ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          CONDENABL;
%********************************************************************
% BACKWARD SWAP, FIRST BYTE RIGHT
MB5:      A,STS B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MB51 CONDENABL;
          B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RBTL;
          A,R4 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BWEXQ;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MB52;
MB51:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BWEXL;
MB52:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXBW;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
MB1T4:    A,R5 B,R4 ALUF,A-1 ALUM,MIC ALUD,SRB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          MB1T2 CONDENABL;
          A,A B,X ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,CRY F,NEXT F,HOLD;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          MB3T CONDENABL;
%********************************************************************
% FORWARD SWAP, FIRST BYTE LEFT
MB4:      A,R1 B,T ALUF,MASKAB ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          LBTR;
          A,R1 B,D ALUF,ORAB ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TTDCR;
          A,R4 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          FWEXQ;
MB41:     B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXFW;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          A,R1 ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          BTL CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
MB3T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TOLAP;
          A,R5 B,STS ALUF,PASSA ALUD,SRB
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          CONDENABL;
%********************************************************************
% BACKWARD SWAP, FIRST BYTE LEFT
MB3:      A,R4 B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,STS B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MB31 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BWEXL;
MB32:     B,R1 ALUF,PASSQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXBW;
          A,T B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R1 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BTR;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MB71;
MB31:     B,D ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RBTL;
          A,R4 ALUF,PASSA ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BWEXQ;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MB32;
MB1T2:    A,A B,X ALUF,B-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,CRY F,NEXT F,HOLD;
          A,17 B,R1 ALUF,PASSD ALUD,B
          IDBS,BMG T,JMP T,PUSH CYCL,SLOW
          MB1T CONDENABL;
%********************************************************************
% FORWARD ALIGNED, FIRST BYTE LEFT
MB2:      ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          FWLOO;
MB21:     ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXFW;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          LBTL CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
MB1T:     A,D B,T ALUF,XORAB ALUD,Q
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          TOLAP;
          ALUD,NONE
          IDBS,ALU T,NEXT T,POP CYCL,SLOW
          CONDENABL;
%********************************************************************
% BACKWARD ALIGNED, FIRST BYTE LEFT
MB1:      A,R4 B,R2 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          A,R5 B,1 ALUF,ANDDA ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW;
          A,R4 B,R3 ALUF,A+B ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          LBTL1 CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          BWLOO;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXBW;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% SUBROUTINE TO TEST ILLEGAL OVERLAP CF SOURCE AND DESTINATION
TOLAP:    A,16 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,RETURN F,POP;
          ALUF,PASSD
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          10000 CONDENABL;
          A,D ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          AB,SSAVE A,R3 B,R6 ALUF,ZERO
          IDBS,STS COMM,EWRF T,NEXT T,HOLD CYCL,SLOW
          0 CONDENABL;
          A,17 B,R5 MIS,ROT ALUF,PASSB ALUD,SRB
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,D ALUF,ANDDA ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,R5 ALUF,A+Q ALUD,Q STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          3777;
          A,R5 B,R6 ALUF,ANDDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,A B,R6 ALUF,A+B ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,SSAVE ALUD,NONE STS,LO
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          OLAP1;
%********************************************************************
% RETURN HERE MEANS NO OVERLAP
          B,R5 MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,1 ALUF,PASSD ALUD,Q
          IDBS,BARG T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,RETURN F,POP;
OLAP1:    A,X B,R6 ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,CRY F,RETURN F,POP;
          A,14 B,R6 ALUF,PASSB ALUD,NONE
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          CONDENABL COND,F=0 F,NEXT F,HOLD;
          A,17 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          OXEQ6 CONDENABL;
%********************************************************************
% OVERLAP EXISTS, ILLEGAL IF  'MOVBF'
OVLAP:    A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,POP CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,14 B,R5 MIS,ROT ALUF,PASSB ALUD,SLB
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          MBERR CONDENABL;
          A,D B,D ALUF,ORDA ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          ALUF,ZERO ALUD,Q
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,RETURN F,POP;
OXEQ6:    A,T ALUF,PASSA ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          CONDENABL COND,F15 F,JMP F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          OVLAP CONDENABL;
%********************************************************************
% FORWARDS MOVE LOOP S INTERRUPTED
IRQFW:    A,R4 B,R1 ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,A B,A ALUF,A+Q+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,14 B,R1 ALUF,Q+1 ALUD,SLB
          IDBS,BMG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          A,T ALUF,ANDDA ALUD,NONE
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,X B,X ALUF,A+Q+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MOVB4 CONDENABL;
          A,R1 B,T ALUF,B-A ALUD,B
          T,JMP T,HOLD CYCL,SLOW
          MOVB4;
%********************************************************************
% BACKWARDS MOVE LOOP IS INTERRUPTED
IRQBW:    A,R4 B,R1 ALUF,A-B ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,R1 ALUF,Q+1 ALUD,SLB
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
MOVB4:    A,R1 B,D ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          B,P ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% ILLEGAL OVERLAP IN MOVBF-INSTRUCTION
MBERR:    ALUD,NONE
          IDBS,ARG COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW
          30000;
          A,T B,T ALUF,MASKDA ALUD,B
          IDBS,GPR T,JMP T,HOLD CYCL,SLOW
          INIT;
%********************************************************************
% SUBROUTINE TO ADJUST BYTE POINTERS WHEN FORWARDS MOVE IS FINISHED
MBXFW:    A,R5 B,R6 MIS,ROT ALUF,PASSA ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXSR;
MOVB0:    A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,14 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          MBX1 CONDENABL;
MOVBX:    ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          147777;
          A,T B,T ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,T ALUF,B-A ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,D ALUF,B-A ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO ADJUST BYTE POINTERS WHEN BACKWARDS MOVE IS FINISHED
MBXBW:    B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          7777;
          A,T B,R6 MIS,ROT ALUF,ANDAB ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          MBXSR;
MBX1:     ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          147777;
          A,T B,T ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          170000;
          A,D B,D ALUF,ANDAQ ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE USED BY MBXFW AND MBXBW
MBXSR:    AB,SSAVE ALUD,NONE
          IDBS,STS COMM,EWRF T,JMP T,PUSH CYCL,SLOW
          MBXS1;
          A,R4 B,D ALUF,A+B ALUD,B STS,EA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,A ALUF,A+B ALUD,B CRY,C
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          167777;
          A,D B,D ALUF,ANDAQ ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          AB,SSAVE ALUD,NONE STS,LO
          IDBS,REG T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO READ WORD [R2] INTO R10
RDSRC:    A,R7 B,D ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RDSR2 CONDENABL;
          A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
RDSR3:    B,STS ALUF,PASSD ALUD,B
          IDBS,DBR T,RETURN T,POP CYCL,WAIT;
RDSR2:    A,R2 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD CYCL,SLOW
          RDSR3;
%********************************************************************
% SUBROUTINE TO INCREMENT R3
R3INC:    B,R3 ALUF,B+1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
%********************************************************************
% SUBROUTINE TO DECREMENT R3
R3DCR:    B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
%********************************************************************
% SUBROUTINE TO MOVE WORDS FORWARDS, BYTES ALIGNED
FWLOO:    A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          FWFST;
FWLO1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          RDSRC CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          WRDST;
          B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          IRQFW CONDENABL;
          B,R3 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          FWLO1;
%********************************************************************
% SUBROUTINE TO MOVE WORDS BACKWARDS, BYTES ALIGNED
BWLOO:    A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          LSET1;
BWLO1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          RDSRC CONDENABL;
          ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          WRDST;
          B,R2 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          IRQBW CONDENABL;
          B,R3 ALUF,B-1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          BWLO1;
%********************************************************************
% SUBROUTINE TO MOVE WORDS FORWARDS, BYTES SWAPPED
FWEXL:    ALUD,NONE
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDSRC;
          A,Z B,STS ALUF,ANDAB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% ALTERNATIVE ENTRY IF FIRST BYTE ALREADY PRESENT IN Q
FWEXQ:    B,R2 ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          LSET1;
FWEX1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          RDSRC CONDENABL;
          A,Z B,STS ALUF,ANDDA ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
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
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          RDSRC;
          A,STS B,R2 ALUF,B-1 ALUD,B,YA
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,Z ALUF,ANDDA ALUD,Q
          IDBS,SWAP T,NEXT T,HOLD CYCL,SLOW;
%********************************************************************
% ALTERNATIVE ENTRY IF FIRST BYTE ALREADY PRESENT IN Q
BWEXQ:    A,R5 B,R1 ALUF,PASSA ALUM,MIC ALUD,SRB
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
          LSET1;
BWEX1:    ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          RDSRC CONDENABL;
          A,Z B,R6 ALUF,ANDDA ALUD,B
          IDBS,SWAP COMM,LDGPR T,NEXT T,HOLD CYCL,SLOW;
          B,STS ALUF,PASSD ALUD,B
          IDBS,GPR T,NEXT T,HOLD CYCL,SLOW;
          A,Z B,STS ALUF,MASKAB ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,STS B,STS ALUF,ORAQ ALUD,B
          IDBS,ALU T,JMP T,PUSH CYCL,SLOW
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
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          ALUF,Q-D ALUD,NONE
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          40;
          A,R1 B,R4 ALUF,PASSA ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          CONDENABL COND,F=0 F,JMP F,PUSH;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          A,PIL B,LC ALUF,PASSB ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,LOAD LCOUNT CYCL,SLOW
          FWLO2;
          ALUD,NONE
          IDBS,ALU T,NEXT T,PUSH CYCL,SLOW
          COND,LC=0;
          A,PIL B,LC ALUF,PASSD ALUD,B
          IDBS,REG T,NEXT T,POP LCOUNT CYCL,SLOW;
          A,R4 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          COND,F=0 F,JMP F,PUSH;
FWLO2:    A,R1 B,11 ALUF,A-D ALUD,NONE
          IDBS,BARG T,NEXT T,HOLD CYCL,SLOW
          COND,F15 F,NEXT F,HOLD;
          A,R7 B,7 ALUF,PASSA ALUD,Q
          IDBS,BARG COMM,LDLC T,RETURN T,POP CYCL,SLOW
          CONDENABL COND,F=0 F,RETURN F,HOLD;
          A,PIL B,D ALUF,ANDDQ ALUD,NONE
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          FWLO3;
          A,R2 B,R2 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,RDRQ T,JMP T,HOLD CYCL,SLOW
          FWLO5;
FWLO5:    B,LC ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,POP LCOUNT CYCL,WAIT
          LCOUNT;
          B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,RETURN F,HOLD;
          A,PIL B,T ALUF,ANDDQ ALUD,NONE
          IDBS,REG T,JMP T,PUSH CYCL,SLOW
          FWLO4;
          A,R3 B,R3 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,APT COMM,WRRQ T,JMP T,HOLD CYCL,SLOW
          FWLO6;
FWLO6:    B,LC ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          COND,LC=0;
          B,R1 ALUF,B-1 ALUD,B
          IDBS,ALU COMM,CLIRQ T,NEXT T,POP LCOUNT CYCL,WAIT
          COND,IRQ F,JMP F,HOLD;
          B,7 ALUD,NONE
          IDBS,BARG COMM,LDLC T,RETURN T,POP CYCL,SLOW
          FWLO2 CONDENABL;
FWLO3:    ALUD,NONE
          IDBS,ALU T,NEXT T,LOAD CYCL,SLOW
          CONDENABL COND,LC=0;
          A,R2 B,R2 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,PT COMM,RDRQ T,JMP T,HOLD CYCL,SLOW
          FWLO5;
FWLO4:    ALUD,NONE
          IDBS,ALU T,NEXT T,LOAD CYCL,SLOW
          CONDENABL COND,LC=0;
          A,R3 B,R3 ALUF,B+1 ALUD,B,YA
          IDBS,ALU MIS,PT COMM,WRRQ T,JMP T,HOLD CYCL,SLOW
          FWLO6;
%********************************************************************
% TEST IF T-REG SHOULD BE DECREMENTED AFTER SINGLE BYTE MOVED BEFORE
% LOOPS ARE ENTERED.
TTDCR:    A,T ALUF,PASSA ALUD,Q
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          A,14 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW
          0 CONDENABL;
          B,T ALUF,B-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% INSTRUCTIONS FOR BIG CORE-MAP HANDLING IN SINTRAN III
%********************************************************************
SINTR:    A,12 ALUF,D+1 ALUD,Q
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW;
          A,T B,R7 ALUF,PASSA ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,PUSH CYCL,WAIT
          EXPHY;
          A,X B,SRCE ALUF,D+A ALUD,Q
          IDBS,BARG T,JMP0-3 T,HOLD CYCL,SLOW
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
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDA8;
LDB8:     ALUF,PASSD ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          B,B ALUF,ORDQ ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          77400;
          A,B B,B ALUF,A+B ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STA8;
%********************************************************************
%********************************************************************
% PLANC ENTER- AND LEAVE- ROUTINES
%********************************************************************
% 5INIT IN PLANC
5INIT:    A,P B,R1 ALUF,A+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          176;
          A,B B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRC;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          172;
          B,R7 ALUF,D+Q ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRB;
          ALUF,PASSD ALUD,Q
          IDBS,STS T,NEXT T,HOLD CYCL,WAIT;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,PT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          ALUF,XORDQ ALUD,Q
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,0 ALUF,ANDDQ ALUD,NONE
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,NEXT F,HOLD;
          A,R1 B,P ALUF,A+1 ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          TSTAC CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          INIT;
%********************************************************************
% 5ENTR IN PLANC
ENTR:     B,R6 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          176;
          A,B B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          A,B B,R2 ALUF,PASSA ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRC;
          A,R2 B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          B,R5 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,SLOW
          172;
          B,R7 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,PUSH CYCL,WAIT
          ENTRB;
TSTAC:    A,R7 B,R3 ALUF,A-B ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,CRY F,JMP F,POP;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT
          INIT CONDENABL;
          B,P ALUF,B+1 ALUD,B
          IDBS,ALU T,JMP T,POP CYCL,SLOW
          INIT;
ENTRC:    ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
          B,L ALUF,B+1 ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,7 B,B ALUF,D+Q ALUD,B
          IDBS,BMG T,NEXT T,HOLD CYCL,SLOW;
          A,R6 B,R3 ALUF,A+1 ALUD,B
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,B B,R3 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
          B,R2 ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R6 B,R4 ALUF,A-1 ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,WAIT;
ENTRB:    A,B B,R4 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
          A,R7 ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          A,R5 ALUF,D-A ALUD,Q
          IDBS,GPR T,NEXT T,HOLD CYCL,WAIT;
          A,B B,R6 ALUF,A-B ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
          A,B B,R3 ALUF,A+Q ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,WAIT;
%********************************************************************
% 5LEAV AND ELEAV IN PLANC
ELEAV:    A,7 ALUF,PASSD ALUD,Q
          IDBS,BMG T,NEXT T,HOLD CYCL,WAIT;
          A,B ALUF,A-Q ALUD,Q
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          B,STS ALUF,D-1 ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
          B,STS ALUF,PASSB ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          173;
          A,B ALUF,A-Q ALUD,NONE
          IDBS,ALU MIS,APT COMM,WRRQ T,NEXT T,HOLD CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,WAIT;
LEAV:     B,R1 ALUF,PASSD ALUD,B
          IDBS,ARG T,NEXT T,HOLD CYCL,WAIT
          177;
          A,B B,R1 ALUF,A-B ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          B,B ALUF,PASSD ALUD,B
          IDBS,DBR T,NEXT T,HOLD CYCL,WAIT;
          A,R1 ALUF,A-1 ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,NEXT T,HOLD CYCL,SLOW;
          B,P ALUF,PASSD ALUD,B
          IDBS,DBR COMM,LDGPR T,JMP T,POP CYCL,WAIT
          INIT;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
          T,JMP0-3 T,MAPJ T,HOLD LCOUNT SLWCS CYCL,SLOW
          CONDENABL COND,DR=2 F,JMP F,HOLD;
%********************************************************************
%********************************************************************
% VECTOR FOR SINTRAN CORE-MAP INSTRUCTIONS
%********************************************************************
VCSI3:    ALUF,PASSQ ALUD,NONE
          COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          LDA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDX8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDAD8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDB8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STZ8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STAD8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STAD8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDX8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDAD8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EXRQ T,JMP T,HOLD CYCL,SLOW
          LDB8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STA8;
          ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STZ8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STAD8;
          ALUF,Q+1 ALUD,NONE
          IDBS,ALU COMM,DERQ T,JMP T,HOLD CYCL,SLOW
          STAD8;
%********************************************************************
%********************************************************************
% VECTOR FOR DECODING OF  COMMERCIAL INSTRUCTIONS  (1401XX)
%********************************************************************
COBVC:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW BFILL;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW MOVB;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW MOVBF;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
% THE PRINTED LISTING (PROM 015XX) JUMPS TO 5INIT HERE; THE PROMS 3033S AND 3033E-CX JUMP TO ILLIN
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          ILLIN;
% THE PRINTED LISTING JUMPS TO ENTR HERE; THE PROMS JUMP TO ILLIN
          ALUD,NONE
          IDBS,DBR COMM,LDGPR T,JMP T,HOLD CYCL,WAIT
          ILLIN;
% THE PRINTED LISTING JUMPS TO LEAV HERE; THE PROMS JUMP TO ILLIN
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
% THE PRINTED LISTING JUMPS TO ELEAV HERE; THE PROMS JUMP TO ILLIN
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW ILLIN;
%********************************************************************
%********************************************************************
% VECTOR TO DETERMINE ALD-VALUES
%********************************************************************
ALDVC:    ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP CYCL,SLOW 0;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP CYCL,SLOW 1560;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          20500;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          21540;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP CYCL,SLOW 400;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP CYCL,SLOW 1600;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP CYCL,SLOW;
          ALUF,PASSD ALUD,Q IDBS,ARG T,RETURN T,POP CYCL,SLOW;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          100000;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          101560;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          120500;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          121540;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          100400;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          101600;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          100000;
          ALUF,PASSD ALUD,Q
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          100000;
%********************************************************************
%********************************************************************
% VECTOR FOR MOPC EXAMINE DISPLAY FUNCTION
%********************************************************************
VECT4:    ALUD,NONE  % MEM. EX. (0)
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          EXAMI;
          A,A B,R7 ALUF,PASSA ALUD,B  % REG. EX. (1)
          IDBS,ALU COMM,CLIRQ T,JMP T,HOLD CYCL,SLOW
          VC41;
          A,3 B,R6 ALUF,ORDQ ALUD,B  % AUX. REG. EX. (2)
          IDBS,BMG COMM,CLIRQ T,JMP T,HOLD CYCL,SLOW
          VC42;
          A,A B,R7 ALUF,PASSA ALUD,B  % INT. REG. EX. (3)
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          VC43;
          ALUD,NONE  % BUS EX. (4)
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
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
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          MANIR CONDENABL;
%********************************************************************
% BREAKPOINT IS ON
          A,P ALUF,Q-A ALUD,NONE
          IDBS,ALU T,NEXT T,HOLD CYCL,SLOW
          COND,F=0 F,JMP F,HOLD;
          A,6 ALUF,D-1 ALUD,Q
          IDBS,AARG T,NEXT T,HOLD CYCL,SLOW
          SINGL CONDENABL;
%********************************************************************
% BREAKPOINT IS FINISHED, PRINT .
          AB,PRCHR ALUF,Q-1 ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          RONLY;
%********************************************************************
% . PRINTED TO MOPC, SET UP BREAKPOINT MODE
DOT:      AB,OCTNR ALUF,PASSD ALUD,Q
          IDBS,REG T,NEXT T,HOLD CYCL,SLOW;
          AB,BRKPT ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,NEXT T,HOLD CYCL,SLOW;
          AB,BPFLG ALUD,NONE
          IDBS,ARG COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          SPAC9;
%********************************************************************
% LAST ENTRY IN VECT4 : DEFAULT DISPLAY MODE (ACTIVITY) (17)
          AB,ACTLV ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          VC417;
%********************************************************************
%********************************************************************
% VECTOR FOR 1504XX- INSTRUCTIONS (PON ETC.)
%********************************************************************
VECT1:    ALUD,NONE
          T,JMP T,HOLD CYCL,WAIT
          INPUT;
IOF:      A,17 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          IOF2;
ION:      A,17 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,WAIT
          ION2;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT INIT;
POF:      A,16 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,WAIT
          POF2;
PIOF:     A,16 ALUF,MASKDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
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
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          ION;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT INIT;
          A,7 ALUD,NONE IDBS,BMG COMM,SMPID T,JMP T,HOLD CYCL,WAIT INIT;
IOXT:     ALUD,NONE T,JMP T,HOLD CYCL,SLOW IOXT2;
EXAM:     A,12 ALUF,D+1 ALUD,Q
          IDBS,AARG T,JMP T,HOLD CYCL,SLOW
          EXAM2;
DEPO:     A,12 ALUF,D+1 ALUD,Q
          IDBS,AARG T,JMP T,HOLD CYCL,SLOW
          DEPO2;
%********************************************************************
%********************************************************************
% VECTOR FOR 1500XX-INSTRUCTIONS (TRA)
%********************************************************************
VECT2:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          APANS;
TASTS:    B,A ALUF,PASSD ALUD,B
          IDBS,STS T,RETURN T,HOLD CYCL,SLOW;
TAOPR:    AB,OPR ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          APIE1;
TAPGS:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          APGS1;
TAPVL:    AB,PVL ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          APVL1;
TAIIC:    PIC,RSTS B,R5 ALUF,PASSD ALUD,B
          IDBS,PIC COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          AIIC1;
TAPID:    PIC,RMSK B,R1 ALUF,PASSD ALUD,B
          IDBS,DSABL COMM,EPIC T,JMP T,HOLD CYCL,SLOW
          APID1;
TAPIE:    AB,PIE ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          APIE1;
TACSR:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          ACSR1;
TAPIM:    A,PIL B,A ALUF,PASSD ALUD,B
          IDBS,BMG T,RETURN T,HOLD CYCL,SLOW;
TAALD:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          AALD1;
TAPES:    B,A ALUF,INVD ALUD,B
          IDBS,PES T,RETURN T,HOLD CYCL,SLOW;
TAPGC:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT APGC1;
TAPEA:    B,A ALUF,INVD ALUD,B
          IDBS,PEA T,RETURN T,HOLD CYCL,SLOW;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT AIR16;
          ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT AIR16;
%********************************************************************
%********************************************************************
% VECTOR FOR 1501XX-INSTRUCTIONS (TRR)
%********************************************************************
VECT3:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RPANC;
TRSTS:    ALUF,PASSQ ALUD,NONE STS,LO
          IDBS,ALU T,RETURN T,HOLD CYCL,SLOW;
TRLMP:    ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,SLOW RLMP1;
TRPCR:    ALUD,NONE
          IDBS,ALU T,JMP T,HOLD CYCL,WAIT
          RPCR1;
TR4:      ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR4;
TRIIE:    A,A ALUF,A+Q ALUD,Q
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RIIE1;
TRPID:    AB,PID ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
          RPID1;
TRPIE:    AB,PIE ALUF,PASSQ ALUD,NONE
          IDBS,ALU COMM,EWRF T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          RECC1;
TR16:     ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR16;
TR17:     ALUD,NONE IDBS,ALU T,JMP T,HOLD CYCL,WAIT RIR17;
%********************************************************************
%********************************************************************
% VECTOR FOR IOX 30X INSTRUCTIONS
%********************************************************************
TRMVC:    ALUF,PASSD ALUD,Q
          IDBS,IOR T,JMP T,HOLD CYCL,SLOW
          TRM0;
          ALUD,NONE
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
          B,A ALUF,PASSD ALUD,B
          IDBS,IOR T,JMP T,HOLD CYCL,SLOW
          TRM2;
          A,A B,R2 ALUF,INVA ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          TRM3;
          B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
          A,A ALUF,PASSA ALUD,NONE
          IDBS,ALU COMM,TBSTR T,RETURN T,POP CYCL,SLOW;
          B,A ALUF,ZERO ALUD,B
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
          TRM6;
          AB,STATUS ALUF,PASSD ALUD,Q
          IDBS,REG T,JMP T,HOLD CYCL,SLOW
          TRM7;
%********************************************************************
%********************************************************************
% VECTOR FOR IOX 10-13
%********************************************************************
CLKVC:    A,A ALUF,ZERO ALUD,B
          IDBS,ALU T,RETURN T,POP CYCL,SLOW;
          A,7 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          CLK1;
          B,A ALUF,ANDDQ ALUD,B
          IDBS,ARG T,RETURN T,POP CYCL,SLOW
          11;
          A,0 ALUF,ORDQ ALUD,Q
          IDBS,BMG T,JMP T,HOLD CYCL,SLOW
          CLK3;
%********************************************************************
%********************************************************************
% EXTRAS FOR MEM.REF.CALC. FOR JUMPS
%********************************************************************
INDJ1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          INDIJ;
INDJ2:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          INDIJ;
POXJ1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          POSXJ;
POXJ2:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU T,JMP T,HOLD CYCL,SLOW
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
          IDBS,ALU MIS,APT COMM,WRRQ T,RETURN T,POP CYCL,SLOW;
STRD2:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,APT COMM,RDRQ T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO START READ REQUEST IN MULTIPLE READ INSTRUCTONS
RDRQ:     B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU COMM,RDRQ MIS,HOLD T,RETURN T,POP CYCL,SLOW;
%********************************************************************
% SUBROUTINE TO START WRITE REQUESR IN MULTIPLE WRITE INSTRUCTIONS
WRRQ:     A,P B,R1 ALUF,A-B ALUD,NONE
          IDBS,ALU COMM,ESRP T,NEXT T,HOLD CYCL,WAIT;
          B,R1 ALUF,B+1 ALUD,B
          IDBS,ALU MIS,HOLD COMM,WRRQ T,RETURN T,POP CYCL,SLOW;
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
          MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          INDIS;
INDS2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,SLOW;
INDIS:    B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STWR2;
POXS1:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          POSXS;
POXS2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,SLOW;
POSXS:    A,X B,R1 ALUF,D+A ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STWR2;
BADDS:    A,B B,R1 ALUF,A+B ALUD,B
          IDBS,ALU MIS,APT COMM,WRRQ T,RETURN T,POP CYCL,SLOW;
STWR1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,WRRQ T,RETURN T,POP CYCL,SLOW;
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
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          INDIL;
INDL2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,SLOW;
INDIL:    B,R1 ALUF,PASSD ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STRD2;
POXL1:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,PT COMM,IRDRQ T,JMP T,HOLD CYCL,SLOW
          POSXL;
POXL2:    B,R1 ALUF,PASSB ALUD,NONE
          IDBS,ALU MIS,APT COMM,IRDRQ T,NEXT T,HOLD CYCL,SLOW;
POSXL:    A,X B,R1 ALUF,D+A ALUD,B
          IDBS,DBR T,JMP T,HOLD CYCL,WAIT
          STRD2;
BADDL:    A,B B,R1 ALUF,A+B ALUD,B
          IDBS,ALU MIS,APT COMM,RDRQ T,RETURN T,POP CYCL,SLOW;
STRD1:    A,R1 ALUF,PASSA ALUD,NONE
          IDBS,ALU MIS,PT COMM,RDRQ T,RETURN T,POP CYCL,SLOW;
%********************************************************************
%********************************************************************
% *
% I N T E R R U P T   V E C T O R   *
% *
%********************************************************************
%********************************************************************
ITSRV:    B,12 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW XINT;
          B,13 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW XINT;
          B,14 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW XINT;
          B,15 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW XINT;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,16 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW EXT14;
          B,17 ALUF,PASSD ALUD,Q IDBS,BARG T,JMP T,HOLD CYCL,SLOW XINT;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW STOP;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW MS20;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW PRQ;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW SING2;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW LOAD;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW CONT;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW RSTRT;
          AB,MACL ALUD,NONE IDBS,ARG COMM,EWRF T,JMP T,HOLD CYCL,SLOW MACL;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW STOP;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW MS20;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW PRQ;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW SING2;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW LOAD;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW CONT;
          B,P ALUF,B-1 ALUD,B IDBS,ALU T,JMP T,HOLD CYCL,SLOW RSTRT;
          AB,MACL ALUD,NONE IDBS,ARG COMM,EWRF T,JMP T,HOLD CYCL,SLOW MACL;
