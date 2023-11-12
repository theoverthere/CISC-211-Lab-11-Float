/*** asmFmax.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data  

@ Define the globals so that the C code can access them

.global f1,f2,fMax,signBitMax,biasedExpMax,expMax,mantMax
.type f1,%gnu_unique_object
.type f2,%gnu_unique_object
.type fMax,%gnu_unique_object
.type signBitMax,%gnu_unique_object
.type biasedExpMax,%gnu_unique_object
.type expMax,%gnu_unique_object
.type mantMax,%gnu_unique_object

.global sb1,sb2,biasedExp1,biasedExp2,exp1,exp2,mant1,mant2
.type sb1,%gnu_unique_object
.type sb2,%gnu_unique_object
.type biasedExp1,%gnu_unique_object
.type biasedExp2,%gnu_unique_object
.type exp1,%gnu_unique_object
.type exp2,%gnu_unique_object
.type mant1,%gnu_unique_object
.type mant2,%gnu_unique_object
 
.align
@ use these locations to store f1 values
f1: .word 0
sb1: .word 0
biasedExp1: .word 0  /* the unmodified 8b exp value extracted from the float */
exp1: .word 0
mant1: .word 0
 
@ use these locations to store f2 values
f2: .word 0
sb2: .word 0
exp2: .word 0
biasedExp2: .word 0  /* the unmodified 8b exp value extracted from the float */
mant2: .word 0
 
@ use these locations to store fMax values
fMax: .word 0
signBitMax: .word 0
biasedExpMax: .word 0
expMax: .word 0
mantMax: .word 0

.global nanValue 
.type nanValue,%gnu_unique_object
nanValue: .word 0x7FFFFFFF            

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
 function name: initVariables
    input:  none
    output: initializes all f1*, f2*, and *Max varibales to 0
********************************************************************/
.global initVariables
 .type initVariables,%function
initVariables:
    /* YOUR initVariables CODE BELOW THIS LINE! Don't forget to push and pop! */
    /*enter function*/
    push {r4-r11, LR}
    
    /*load all these labels into available registers*/
    ldr r4, =f1          
    ldr r5, =sb1
    ldr r6, =biasedExp1
    ldr r7, =exp1
    ldr r8, =mant1
    ldr r9, =f2
    ldr r10, =sb2
    
    /*move zero into r12 for initialization purposes*/
    mov r11, 0
    
    /*intialize all locations pointed to by register to zero*/
    str r11, [r4]
    str r11, [r5]
    str r11, [r6]
    str r11, [r7]
    str r11, [r8]
    str r11, [r9]
    str r11, [r10]
   
    
    /*load all these labels into available registers*/
    ldr r4, =exp2
    ldr r5, =mant2
    ldr r6, =fMax
    ldr r7, =signBitMax
    ldr r8, =biasedExpMax
    ldr r9, =expMax
    ldr r10, =mantMax
    
    
    /*intialize all locations pointed to by register to zero*/
    str r11, [r4]
    str r11, [r5]
    str r11, [r6]
    str r11, [r7]
    str r11, [r8]
    str r11, [r9]
    str r11, [r10]
    
    ldr r4, =biasedExp2
    str r11, [r4]
    
    /*exit function*/
    pop {r4-r11, LR}
    bx lr
   
    
    /* YOUR initVariables CODE ABOVE THIS LINE! Don't forget to push and pop! */

    
/********************************************************************
 function name: getSignBit
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store sign bit (bit 31).
                Store a 1 if the sign bit is negative,
                Store a 0 if the sign bit is positive
                use sb1, sb2, or signBitMax for storage, as needed
    output: [r1]: mem location given by r1 contains the sign bit
********************************************************************/
.global getSignBit
.type getSignBit,%function
getSignBit:
    /* YOUR getSignBit CODE BELOW THIS LINE! Don't forget to push and pop! */
    /*enter the function*/
    push {r4-r11, LR}
    
    ldr r4, [r0] /*load unpacked 32b float into r4*/
    tst r4, 0x80000000 /*tst r4 with 0x80000000 to see if sign bit is turned on*/
    bne negativeSign /*else, branch here*/
    beq positiveSign /*if 0, float is positive, branch here*/
    
    positiveSign:
    mov r10, 0 /*mov zero into r10*/
    str r10, [r1] /*return positive sign bit*/
    b exitFunction
    
    negativeSign:
    mov r10, 1 /*mov zero into r10*/
    str r10, [r1] /*return negative sign bit*/
    
    
    exitFunction:
    pop {r4-r11, LR}
    bx LR
    

    /* YOUR getSignBit CODE ABOVE THIS LINE! Don't forget to push and pop! */
    

    
/********************************************************************
 function name: getExponent
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store BIASED
                bits 23-30 (exponent) 
                BIASED means the unpacked value (range 0-255)
                use exp1, exp2, or expMax for storage, as needed
            r2: address of mem to store unpacked and UNBIASED 
                bits 23-30 (exponent) 
                UNBIASED means the unpacked value - 127
                use exp1, exp2, or expMax for storage, as needed
    output: [r1]: mem location given by r1 contains the unpacked
                  original (biased) exponent bits, in the lower 8b of the mem 
                  location
            [r2]: mem location given by r2 contains the unpacked
                  and UNBIASED exponent bits, in the lower 8b of the mem 
                  location
********************************************************************/
.global getExponent
.type getExponent,%function
getExponent:
    /* YOUR getExponent CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR} /*enter the function*/
    
    ldr r4, [r0] /*load value pointed to by r0 (unpacked 32b float) to r4*/
   
    lsr r4, r4, 23 /*shift bits right by 23 to isolate 8 exponent bits*/
    ror r4, r4, 8 /*rotate bits by 8, now sign bit is LSB*/
    lsr r4, r4, 24 /*shift right again, this time by 24. exponent bits are now isolated in the 8 LSB's*/
    
    str r4, [r1] /*store biased exponent to address in r1*/
    sub r4, r4, 127 /*subtract 127 from biased exponent to unbias it*/
    str r4, [r2] /*store unbiased exponent to address in r2*/
    
    pop {r4-r11, LR} /*exit the function*/
    bx lr
    
    /* YOUR getExponent CODE ABOVE THIS LINE! Don't forget to push and pop! */
   

    
/********************************************************************
 function name: getMantissa
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store unpacked bits 0-22 (mantissa) 
                of 32b float. 
                Use mant1, mant2, or mantMax for storage, as needed
    output: [r1]: mem location given by r1 contains the unpacked
                  mantissa bits
********************************************************************/
.global getMantissa
.type getMantissa,%function
getMantissa:
    /* YOUR getMantissa CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR} /*enter the function*/
    
    ldr r4, [r0] /*load unpacked 32b float into r4*/
    lsl r4, r4, 9 /*shift left r4 by 9 bits, making the mantissa occupy the 23 MSB's*/
    lsr r4, r4, 9 /* shift r4 right by 9 bits, isolating the mantissa*/
    add r4, r4, 0x800000
    str r4, [r1] /*store the unpacked mantissa to location pointed to by r1*/
    
    pop {r4-r11, LR}
    bx lr
    
    /* YOUR getMantissa CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
function name: asmFmax
function description:
     max = asmFmax ( f1 , f2 )
     
where:
     f1, f2 are 32b floating point values passed in by the C caller
     max is the ADDRESS of fMax, where the greater of (f1,f2) must be stored
     
     if f1 equals f2, return either one
     notes:
        "greater than" means the most positive numeber.
        For example, -1 is greater than -200
     
     The function must also unpack the greater number and update the 
     following global variables prior to returning to the caller:
     
     signBitMax: 0 if the larger number is positive, otherwise 1
     expMax:     The UNBIASED exponent of the larger number
                 i.e. the BIASED exponent - 127
     mantMax:    the lower 23b unpacked from the larger number
     
     SEE LECTURE SLIDES FOR EXACT REQUIREMENTS on when and how to adjust values!


********************************************************************/    
.global asmFmax
.type asmFmax,%function
asmFmax:   

    /* Note to Profs: Solution used to test c code is located in Canvas:
     *    Files -> Lab Files and Coding Examples -> Lab 11 Float Solution
     */

    /* YOUR asmFmax CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11, LR}
    bl initVariables
    
    /*unpack value of r0 into f1*/
    ldr r4, =f1
    str r0, [r4]
    /*unpack value of r1 into f2*/
    ldr r4, =f2
    str r1, [r4]
    
    
    /*pop {r4-r11, LR}*/
    /*get sign bit for float one*/
    ldr r0, =f1
    ldr r1, =sb1
    bl getSignBit
    
    /*get sign bit for float two*/
    ldr r0, =f2
    ldr r1, =sb2
    bl getSignBit
    
    
    /*get exp for float one*/
    ldr r0, =f1
    ldr r1, =biasedExp1
    ldr r2, =exp1
    bl getExponent
    
    /*get exp for float two*/
    ldr r0, =f2
    ldr r1, =biasedExp2
    ldr r2, =exp2
    bl getExponent
    
    
    /*get mantissa for float one*/
    ldr r0, =f1
    ldr r1, =mant1
    bl getMantissa
    
    /*push {r4-r11, LR}*/
    ldr r5, =biasedExp1
    ldr r5, [r5]
    ldr r1, =mant1
    ldr r6, [r1]
    cmp r5, 0
    /*orrne r6, r6, 0x00800000 /*turn on the 23rd bit for mantissa conversion*/
    str r6, [r1]
   /* pop {r4-r11, LR}*/
    
    /*get mantissa for float two*/
    ldr r0, =f2
    ldr r1, =mant2
    bl getMantissa
    
   /* push {r4-r11, LR}*/
    ldr r5, =biasedExp2
    ldr r5, [r5]
    ldr r1, =mant2
    ldr r6, [r1]
    cmp r5, 0
   /* orrne r6, r6, 0x00800000 /*turn on the 23rd bit for mantissa conversion*/
    str r6, [r1]
    
    ldr r5, =f1
    ldr r6, =f2
    ldr r10, =0x7fffffff
    cmp r5, r10
    beq NaN
    cmp r6, r10
    beq NaN  
    ldr r10, =0x7f800000
    cmp r5, r10 
    beq fp1Larger
    cmp r6, r10
    beq fp2Larger
    ldr r10, =0xff800000
    cmp r5, r10
    beq fp2Larger
    cmp r6, r10
    beq fp1Larger
    
    ldr r7, =sb1
    ldr r8, =sb2
    ldr r9, [r7]
    ldr r10, [r8]
    cmp r10, r9
    bmi fp2Larger
    beq expCheck
    bhi fp1Larger
    
    expCheck:
    ldr r7, =exp1
    ldr r8, =exp2
    ldr r9, [r7]
    ldr r10, [r8]
    cmp r10, r9
    bhi fp2Larger
    beq mantissaCheck
    blo fp1Larger
    
    mantissaCheck:
    ldr r7, =mant1
    ldr r8, =mant2
    ldr r9, [r7]
    ldr r10, [r8]
    cmp r10, r9
    bmi fp2Larger
    bhi fp1Larger
    
    equalFp:
    ldr r0, =fMax
    ldr r1, [r5]
    str r1, [r0]
    ldr r1, =signBitMax
    ldr r2, =sb1
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =biasedExpMax
    ldr r2, =biasedExp1
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =expMax
    ldr r2, =exp1
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =mantMax
    ldr r2, =mant1
    ldr r3, [r2]
    str r3, [r1]
    b finally
    
    fp1Larger:
    ldr r0, =fMax
    ldr r1, [r5]
    str r1, [r0]
    ldr r1, =signBitMax
    ldr r2, =sb1
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =biasedExpMax
    ldr r2, =biasedExp1
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =expMax
    ldr r2, =exp1
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =mantMax
    ldr r2, =mant1
    ldr r3, [r2]
    str r3, [r1]
    b finally
    
    fp2Larger:
    ldr r0, =fMax
    ldr r1, [r6]
    str r1, [r0]
    
    ldr r1, =signBitMax
    ldr r2, =sb2
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =biasedExpMax
    ldr r2, =biasedExp2
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =expMax
    ldr r2, =exp2
    ldr r3, [r2]
    str r3, [r1]
    
    ldr r1, =mantMax
    ldr r2, =mant2
    ldr r3, [r2]
    str r3, [r1]
    b finally
    
    NaN:
    ldr r0, =fMax
    ldr r6, =0x7fffffff
    str r6, [r0]
    b finally
    
    finally:
    pop {r4-r11, LR}
    bx lr
    
    /* YOUR asmFmax CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




