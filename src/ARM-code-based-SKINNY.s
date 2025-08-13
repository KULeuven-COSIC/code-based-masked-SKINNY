/******************************************************************************************
*                          3rd order secure assembly                                      *
*                           SKINNY CB BIT-SLICED                                          *
*                            Two shares, 4 bits                                           *
******************************************************************************************/


.syntax unified
.thumb
 
.data


.align 4 
.globl bt_RCnst  
bt_RCnst:

    .word 0x00000401
    .word 0x00000501
    .word 0x00010501
    .word 0x01010501
    .word 0x01010503
    .word 0x01010702
    .word 0x01010603
    .word 0x01000703
    .word 0x00010703
    .word 0x01010701
    .word 0x01010502
    .word 0x01010602
    .word 0x01000603
    .word 0x00000703
    .word 0x00010701
    .word 0x01010500
    .word 0x01010403
    .word 0x01000702
    .word 0x00010603
    .word 0x01000701
    .word 0x00010502
    .word 0x01010600
    .word 0x01000402
    .word 0x00000602
    .word 0x00000601
    .word 0x00000500
    .word 0x00010401
    .word 0x01000501
    .word 0x00010503
    .word 0x01010700
    .word 0x01010402
    .word 0x01000602
    
.text
bt_RCnst_addr: .word bt_RCnst

.align 4
.global   addRCnst
.type   addRCnst, %function;
// r0 = pt shares0
// r1 = round count
addRCnst:
    
    push {r4-r11,r14}
    sub sp, sp, #(4 * 2)

    str r0, [sp]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// ADD RC[0] VALUES to shares 0 ////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    //load shares 0
    ldr r2, [r0, #0]
    ldr r3, [r0, #4]
    ldr r4, [r0, #8]
    ldr r5, [r0, #12]

    
    lsl r1, 2
    
    ldr r10, bt_RCnst_addr
    ldr r11, [r10, r1] // 32 bits RC
    
    //////////////////////////
    // add RC to a0
    //////////////////////////

    and r12, r11, 0xF
    and r14, r12, 0x1 // bit c0
    eor r2, r2, r14

    and r14, r12, 0x2 // bit c1
    lsl r14, r14 , 3
    eor r2, r2, r14

    and r14, r12, 0x4 // bit c2
    lsl r14, r14 , 6
    eor r2, r2, r14
    
    //////////////////////////
    // add RC to b0
    //////////////////////////

    lsr r11, r11, 8
    and r12, r11, 0xF
    and r14, r12, 0x1 // bit c0
    lsl r14, r14 , 15
    eor r3, r3, r14

    and r14, r12, 0x2 // bit c1
    lsl r14, r14 , 2
    eor r3, r3, r14

    and r14, r12, 0x4 // bit c2
    lsl r14, r14 , 5
    eor r3, r3, r14
    
    //////////////////////////
    // add RC to c0
    //////////////////////////

    lsr r11, r11, 8
    and r12, r11, 0xF
    and r14, r12, 0x1 // bit c0
    lsl r14, r14 , 14
    eor r4, r4, r14

    and r14, r12, 0x2 // bit c1
    lsl r14, r14 , 1
    eor r4, r4, r14

    and r14, r12, 0x4 // bit c2
    lsl r14, r14 , 4
    eor r4, r4, r14
    
    //////////////////////////
    // add RC to d0
    //////////////////////////

    lsr r11, r11, 8
    and r12, r11, 0xF
    and r14, r12, 0x1 // bit c0
    lsl r14, r14 , 13
    eor r5, r5, r14

    and r14, r12, 0x2 // bit c1
    eor r5, r5, r14

    and r14, r12, 0x4 // bit c2
    lsl r14, r14 , 3
    eor r5, r5, r14

    //store shares 0
    str r2, [r0, #0]
    str r3, [r0, #4]
    str r4, [r0, #8]
    str r5, [r0, #12]

    add sp, sp, #(4 * 2)
    // END OF CODE
    pop {r4-r11,r14}
    bx lr



// Shiftback version
.align 4
.global   fromBStoElem
.type   fromBStoElem, %function;
// r0 = pt shares0
// r1 = pt shares 1
fromBStoElem:
    
    push {r4-r11,r14}
    sub sp, sp, #(4 * 2)

    
    
    mov r12, 0xFFFF
    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r5, #0

    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0

    //load shares 0
    ldr r2, [r0, #0]
    ldr r3, [r0, #4]
    ldr r4, [r0, #8] 
    ldr r5, [r0, #12] 

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////// SHIFT BACK SHARES 0//////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // ROL r3 (b0) of #1
    mov r11, #0
    lsr r11, r3, #15
    lsl r3, r3, #1
    eor r3, r3, r11
    and r3, r3, r12

    // ROL r4 (c0) of #2
    mov r11, #0
    lsr r11, r4, #14
    lsl r4, r4, #2
    eor r4, r4, r11
    and r4, r4, r12

    // ROL r5 (d0) of #3
    mov r11, #0
    lsr r11, r5, #13
    lsl r5, r5, #3
    eor r5, r5, r11
    and r5, r5, r12
    mov r11, #0 
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// FROM BIT-SLICE TO ELEMENTS ////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    mov r14, #0
    //////////////////////////////////// Shares 0 ////////////////////////////////////
    
    /// element 1
    // a
    and r10, r2, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r3, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r4, #1 
    lsl r11, r10, #2
    eor r14, r14, r11

    // d
    and r10, r5, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 2
    // a
    and r10, r2, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r3, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r4, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r5, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 3
    // a
    and r10, r2, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r3, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r4, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r5, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 4
    // a
    and r10, r2, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r3, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r4, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r5, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11

    // Store updated
    str r14, [r0, #0] 

    mov r14, #0

    lsr r2, r2, #4
    lsr r3, r3, #4
    lsr r4, r4, #4
    lsr r5, r5, #4

    /// element 5
    // a
    and r10, r2, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r3, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r4, #1 
    lsl r11, r10, #2
    eor r14, r14, r11

    // d
    and r10, r5, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 6
    // a
    and r10, r2, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r3, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r4, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r5, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 7
    // a
    and r10, r2, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r3, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r4, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r5, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 8
    // a
    and r10, r2, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r3, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r4, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r5, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11


    // Store updated
    str r14, [r0, #4] 

    mov r14, #0

    lsr r2, r2, #4
    lsr r3, r3, #4
    lsr r4, r4, #4
    lsr r5, r5, #4

    /// element 9
    // a
    and r10, r2, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r3, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r4, #1 
    lsl r11, r10, #2
    eor r14, r14, r11

    // d
    and r10, r5, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 10
    // a
    and r10, r2, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r3, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r4, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r5, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 11
    // a
    and r10, r2, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r3, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r4, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r5, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 12
    // a
    and r10, r2, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r3, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r4, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r5, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11


    // Store updated
    str r14, [r0, #8] 

    mov r14, #0

    lsr r2, r2, #4
    lsr r3, r3, #4
    lsr r4, r4, #4
    lsr r5, r5, #4

    /// element 13
    // a
    and r10, r2, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r3, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r4, #1 
    lsl r11, r10, #2
    eor r14, r14, r11

    // d
    and r10, r5, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 14
    // a
    and r10, r2, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r3, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r4, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r5, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 15
    // a
    and r10, r2, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r3, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r4, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r5, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 16
    // a
    and r10, r2, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r3, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r4, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r5, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11


    // Store updated
    str r14, [r0, #12] 

    // clear tmp 
    mov r10, #0
    mov r11, #0
    mov r14, #0

    // clear shares 0
    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r5, #0
    
    //////////////////////////////////// Shares 1 ////////////////////////////////////
    //load shares 1
    ldr r6, [r1, #0] 
    ldr r7, [r1, #4] 
    ldr r8, [r1, #8] 
    ldr r9, [r1, #12] 

    // ROL r6 (a1) of #4
    mov r11, #0
    lsr r11, r6, #12
    lsl r6, r6, #4
    eor r6, r6, r11
    and r6, r6, r12

    // ROL r7 (b1) of #5
    mov r11, #0
    lsr r11, r7, #11
    lsl r7, r7, #5
    eor r7, r7, r11
    and r7, r7, r12

    // ROL r8 (c1) of #6
    mov r11, #0
    lsr r11, r8, #10
    lsl r8, r8, #6
    eor r8, r8, r11
    and r8, r8, r12

    // ROL r9 (d1) of #7
    mov r11, #0
    lsr r11, r9, #9
    lsl r9, r9, #7
    eor r9, r9, r11
    and r9, r9, r12
    mov r11, #0 


    /// element 1
    // a
    and r10, r6, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r7, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r8, #1 
    lsl r11, r10, #2
    eor r14, r14, r11

    // d
    and r10, r9, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 2
    // a
    and r10, r6, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r7, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r8, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r9, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 3
    // a
    and r10, r6, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r7, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r8, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r9, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 4
    // a
    and r10, r6, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r7, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r8, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r9, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11

    // Store updated
    str r14, [r1, #0] 

    mov r14, #0

    lsr r6, r6, #4
    lsr r7, r7, #4
    lsr r8, r8, #4
    lsr r9, r9, #4

    /// element 5
    // a
    and r10, r6, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r7, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r8, #1 
    lsl r11, r10, #2
    eor r14, r14, r11

    // d
    and r10, r9, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 6
    // a
    and r10, r6, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r7, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r8, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r9, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 7
    // a
    and r10, r6, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r7, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r8, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r9, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 8
    // a
    and r10, r6, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r7, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r8, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r9, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11


    // Store updated
    str r14, [r1, #4] 

    mov r14, #0

    lsr r6, r6, #4
    lsr r7, r7, #4
    lsr r8, r8, #4
    lsr r9, r9, #4

    /// element 9
    // a
    and r10, r6, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r7, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r8, #1 
    lsl r11, r10, #2
    eor r14, r14, r11

    // d
    and r10, r9, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 10
    // a
    and r10, r6, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r7, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r8, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r9, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 11
    // a
    and r10, r6, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r7, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r8, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r9, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 12
    // a
    and r10, r6, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r7, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r8, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r9, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11


    // Store updated
    str r14, [r1, #8] 

    mov r14, #0

    lsr r6, r6, #4
    lsr r7, r7, #4
    lsr r8, r8, #4
    lsr r9, r9, #4

    /// element 13
    // a
    and r10, r6, #1 
    lsl r11, r10, #0
    eor r14, r14, r11

    // b
    and r10, r7, #1 
    lsl r11, r10, #1
    eor r14, r14, r11

    // c
    and r10, r8, #1         
    lsl r11, r10, #2        
    eor r14, r14, r11

    // d
    and r10, r9, #1 
    lsl r11, r10, #3
    eor r14, r14, r11

    /// element 14
    // a
    and r10, r6, #2
    lsr r10, r10, #1
    lsl r11, r10, #8
    eor r14, r14, r11

    // b
    and r10, r7, #2
    lsr r10, r10, #1
    lsl r11, r10, #9
    eor r14, r14, r11

    // c
    and r10, r8, #2 
    lsr r10, r10, #1
    lsl r11, r10, #10
    eor r14, r14, r11

    // d
    and r10, r9, #2 
    lsr r10, r10, #1
    lsl r11, r10, #11
    eor r14, r14, r11
    

    /// element 15
    // a
    and r10, r6, #4
    lsr r10, r10, #2
    lsl r11, r10, #16
    eor r14, r14, r11

    // b
    and r10, r7, #4
    lsr r10, r10, #2
    lsl r11, r10, #17
    eor r14, r14, r11

    // c
    and r10, r8, #4 
    lsr r10, r10, #2
    lsl r11, r10, #18
    eor r14, r14, r11

    // d
    and r10, r9, #4 
    lsr r10, r10, #2
    lsl r11, r10, #19
    eor r14, r14, r11
    

    /// element 16
    // a
    and r10, r6, #8
    lsr r10, r10, #3
    lsl r11, r10, #24
    eor r14, r14, r11

    // b
    and r10, r7, #8
    lsr r10, r10, #3
    lsl r11, r10, #25
    eor r14, r14, r11

    // c
    and r10, r8, #8 
    lsr r10, r10, #3
    lsl r11, r10, #26
    eor r14, r14, r11

    // d
    and r10, r9, #8 
    lsr r10, r10, #3
    lsl r11, r10, #27
    eor r14, r14, r11

    // Store updated
    str r14, [r1, #12] 

    add sp, sp, #(4 * 2)
    // END OF CODE
    pop {r4-r11,r14}
    bx lr

.align 4
.global   addRoundKey
.type   addRoundKey, %function;
// r0 = pt shares0
// r1 = pt shares1
// r2 = pt BS_RK_0
// r3 = pt BS_RK_1
// r4 = round count
addRoundKey:
    
    push {r4-r11,r14}
    sub sp, sp, #(4 * 20)

    
    str r3, [sp, #4] // pt BS_RK_1
    


    ///////////////////////////////// SHARE 0 /////////////////////////////////
    mov r10, r2
    lsl r4, r4, 3
    str r4, [sp, #0] // round count
    ldr r11, [r10, r4] // 32 bits Round key BA
    add r4, r4, 4
    ldr r14, [r10, r4] // 32 bits Round key DC
    mov r10, 0xFFFF

    //load shares 0
    ldr r2, [r0, #0]
    ldr r3, [r0, #4]
    ldr r4, [r0, #8]
    ldr r5, [r0, #12]

    // add RK to a0
    and r12, r11, 0xFF
    eor r2, r2, r12

    // add RC to b0
    lsr r12, r11, 16
    //and r12, r11, r10
    eor r3, r3, r12

    // add RC to c0
    and r12, r14, r10
    eor r4, r4, r12

    // add RC to d0
    lsr r14, r14, 16
    //and r12, r14, r10
    eor r5, r5, r14

    //store shares 0
    str r2, [r0, #0]
    str r3, [r0, #4]
    str r4, [r0, #8]
    str r5, [r0, #12]

    // clear shares 0
    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r5, #0

    ///////////////////////////////// SHARE 1 /////////////////////////////////
    ldr r4, [sp, #0] // round count
    ldr r10, [sp, #4] // pt RK share 1
    ldr r11, [r10, r4] // 32 bits Round key
    add r4, r4, 4
    ldr r14, [r10, r4] // 32 bits Round key DC
    mov r10, 0xFFFF

    //load shares 1
    ldr r6, [r1, #0]
    ldr r7, [r1, #4]
    ldr r8, [r1, #8]
    ldr r9, [r1, #12]
    
    // add RK to a1
    and r12, r11, r10
    eor r6, r6, r12

    // add RC to b1
    lsr r12, r11, 16
    //and r12, r11, 0xFF
    eor r7, r7, r12

    // add RC to c1
    and r12, r14, r10
    eor r8, r8, r12

    // add RC to d0
    lsr r14, r14, 16
    //and r12, r11, 0xFF
    eor r9, r9, r14

    //store shares 1
    str r6, [r1, #0]
    str r7, [r1, #4]
    str r8, [r1, #8]
    str r9, [r1, #12]

    // clear shares 1
    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0
    

    // END OF CODE
    add sp, sp, #(4 * 20)
    pop {r4-r11,r14}
    bx lr    


.align 4
.global   mult72
.type   mult72, %function;
// r0 = i
mult72:
    mov r1, #0
    mov r2, #0
    cmp r0, #0
    beq rt_branch // if i == 0 -> return 0
loop_mult:    
    add r1,r1, #72 // accumulator 
    add r2,r2,1 
    cmp r2, r0
    blt loop_mult
    mov r0, r1
rt_branch:
    bx lr



.align 4
.global   shiftRows
.type   shiftRows, %function;
// r0 = pt shares0
// r1 = pt shares1
shiftRows:
    
    push {r4-r11,r14}
    sub sp, sp, #(4 * 2)
    
    ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// SHARE 0 /////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////// bits a0 /////////////////////////////////


    //load shares 0
    ldr r2, [r0, #0] // a
    
    //////////////////////////////////////////
    ////////// Row 1 (byte s4 - s7) //////////
    //////////////////////////////////////////

    //// bits a ////
    
    mov r10, r2 
    lsr r11, r10, 4
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 3
    lsl r11, r11, 1
    and r11, r11, 0xF
    eor r11, r11, r12 // updated 4 bits bit 

    lsl r11, r11, 4
    mov r6, 0xFF0F
    and r2, r2, r6
    eor r2, r2, r11

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear

    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////

    
    mov r10, r2 
    lsr r11, r10, 8
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 8
    mov r7, 0xF0FF
    and r2, r2, r7
    eor r2, r2, r11 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear

    //////////////////////////////////////////
    ////////// Row 3
    //////////////////////////////////////////


    mov r10, r2 
    lsr r11, r10, 12
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 12
    mov r8, 0x0FFF
    and r2, r2, r8
    eor r2, r2, r11 // DONE

    //store updated shares a0
    str r2, [r0, #0] // a
    mov r2, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear




    ///////////////////////////////// bits b0 /////////////////////////////////

    ldr r3, [r0, #4] // b  

    //////////////////////////////////////////
    ////////// Row 1
    //////////////////////////////////////////
      

    mov r10, r3 
    lsr r11, r10, 3
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 3
    lsl r11, r11, 1
    and r11, r11, 0xF
    eor r11, r11, r12 // updated 4 bits bit 
    
    lsl r11, r11, 3
    mov r6, 0xFF87
    and r3, r3, r6
    eor r3, r3, r11 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////


    mov r10, r3 
    lsr r11, r10, 7
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 7
    mov r7, 0xF87F
    and r3, r3, r7
    eor r3, r3, r11 // DONE
    
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 3
    //////////////////////////////////////////

    mov r10, r3 
    lsr r11, r10, 11
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 11
    mov r8, 0x87FF
    and r3, r3, r8
    eor r3, r3, r11  // DONE 


    //store updated shares b0
    str r3, [r0, #4] // b
    mov r3, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    ///////////////////////////////// bits c0 /////////////////////////////////
    
    ldr r4, [r0, #8] // c

    //////////////////////////////////////////
    ////////// Row 1
    //////////////////////////////////////////
    

    mov r10, r4 
    lsr r11, r10, 2
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 3
    lsl r11, r11, 1
    and r11, r11, 0xF
    eor r11, r11, r12 // updated 4 bits bit 
    
    lsl r11, r11, 2
    mov r6, 0xFFC3
    and r4, r4, r6
    eor r4, r4, r11 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear

    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////  

    mov r10, r4 
    lsr r11, r10, 6
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 6
    mov r7, 0xFC3F
    and r4, r4, r7
    eor r4, r4, r11 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 3
    //////////////////////////////////////////  


    mov r10, r4 
    lsr r11, r10, 10
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 10
    mov r8, 0xC3FF
    and r4, r4, r8
    eor r4, r4, r11  // DONE   

 
    //store updated shares c0
    str r4, [r0, #8] // c
    mov r4, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    ///////////////////////////////// bits d0 /////////////////////////////////

    ldr r5, [r0, #12] // d

    //////////////////////////////////////////
    ////////// Row 1
    //////////////////////////////////////////  

    mov r10, r5 
    lsr r11, r10, 1
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 3
    lsl r11, r11, 1
    and r11, r11, 0xF
    eor r11, r11, r12 // updated 4 bits bit 
    
    lsl r11, r11, 1
    mov r6, 0xFFE1
    and r5, r5, r6
    eor r5, r5, r11 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////  

    mov r10, r5 
    lsr r11, r10, 5
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 5
    mov r7, 0xFE1F
    and r5, r5, r7
    eor r5, r5, r11 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 3
    ////////////////////////////////////////// 


    mov r10, r5 
    lsr r11, r10, 9
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 9
    mov r8, 0xE1FF
    and r5, r5, r8
    eor r5, r5, r11  // DONE

    //store updated shares d0
    str r5, [r0, #12] // d
    mov r5, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear



    // clear shares 0
    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r5, #0

    ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// SHARE 1 /////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////


    ///////////////////////////////// bits a1 /////////////////////////////////

    //// bits a ////
    ldr r6, [r1, #0] // a

    //////////////////////////////////////////
    ////////// Row 1
    //////////////////////////////////////////

    
    mov r11, r6 
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 3
    lsl r11, r11, 1
    and r11, r11, 0xF
    eor r11, r11, r12 // updated 4 bits bit 

    mov r2, 0xFFF0
    and r6, r6, r2
    eor r6, r6, r11 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear

    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////


    mov r10, r6 
    lsr r11, r10, 4
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 4
    mov r3, 0xFF0F
    and r6, r6, r3
    eor r6, r6, r11

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 3
    //////////////////////////////////////////
    
    mov r10, r6 
    lsr r11, r10, 8
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 8
    mov r3, 0xF0FF
    and r6, r6, r3
    eor r6, r6, r11    


    //store updated shares a1
    str r6, [r1, #0] // a
    mov r6, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear

    ///////////////////////////////// bits b1 /////////////////////////////////

    //// bits b ////
    ldr r7, [r1, #4]

    //////////////////////////////////////////
    ////////// Row 1
    //////////////////////////////////////////


    mov r10, r7 

    lsr r11, r10, 2
    and r11, r11, 1 //b7
    lsl r12, r11, 15 // b7 positioned

    lsr r11, r10, 15 // b4
    and r11, r11, 1 // b4


    lsl r10, r10, 1
    eor r10, r10, r11
    and r10, r10, 0x7

    eor r12, r12, r10

    mov r2, 0x7FF8
    and r7, r7, r2

    eor r7, r7, r12 // DONE

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear
    


    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////

    mov r10, r7 
    lsr r11, r10, 3
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 3
    mov r3, 0xFF87
    and r7, r7, r3
    eor r7, r7, r11

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 3
    //////////////////////////////////////////

    mov r10, r7 
    lsr r11, r10, 7
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 7
    mov r3, 0xF87F
    and r7, r7, r3
    eor r7, r7, r11    

    str r7, [r1, #4]
    mov r7, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear
    





    ///////////////////////////////// bits c1 /////////////////////////////////

    //// bits c ////
    ldr r8, [r1, #8]

    //////////////////////////////////////////
    ////////// Row 1
    //////////////////////////////////////////

    mov r10, r8
    lsr r12, r10, 15 // c5

    and r11, r10, 1 // c6
    lsl r11, r11, 1 // c6 positioned

    eor r12, r12, r11  // c6 c5

    lsr r11, r10, 14 // c4
    lsl r11, r11, 15 // c4 positionned 

    eor r12, r12, r11

    lsr r11, r10, 1
    and r11, r11, 1 // c7
    lsl r11, r11, 14 // c7 positionned

    eor r12, r12, r11 // DONE

    mov r2, 0x3FFC
    and r8, r8, r2

    eor r8, r8, r12
    mov r12, 0 // clear

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////

    mov r10, r8 


    mov r10, r8 
    lsr r11, r10, 2
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 2
    mov r3, 0xFFC3
    and r8, r8, r3
    eor r8, r8, r11

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear

    //////////////////////////////////////////
    ////////// Row 3
    //////////////////////////////////////////


    mov r10, r8 
    lsr r11, r10, 6
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 6
    mov r3, 0xFC3F
    and r8, r8, r3
    eor r8, r8, r11    

    str r8, [r1, #8]
    mov r8, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear
    
    


    ///////////////////////////////// bits d1 /////////////////////////////////

    //// bits d ////

    ldr r9, [r1, #12]


    //////////////////////////////////////////
    ////////// Row 1
    //////////////////////////////////////////

    mov r10, r9

    lsr r12, r10, 15 // positionned d_6

    lsr r11, r10, 13
    and r11, r11, 0x3 // d5 d4

    lsl r11, r11, 14 // d5 d4 positionned

    eor r12, r12, r11

    and r11, r10, 0x1 // d_7
    lsl r11, r11, 13 // d_7 positionned

    eor r12, r12, r11 // Done

    mov r2, 0x1FFE
    and r9, r9, r2
    eor r9, r9, r12
    mov r12, 0 // clear

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear

    //////////////////////////////////////////
    ////////// Row 2
    //////////////////////////////////////////

    mov r10, r9 

    mov r10, r9 
    lsr r11, r10, 1
    and r11, r11, 0xF // the original 4 bits we want
    lsr r12, r11, 2
    lsl r11, r11, 2
    eor r11, r11, r12 // updated 4 bits bit 
    and r11, r11, 0xF

    lsl r11, r11, 1
    mov r3, 0xFFE1
    and r9, r9, r3
    eor r9, r9, r11

    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear


    //////////////////////////////////////////
    ////////// Row 3
    //////////////////////////////////////////

    mov r10, r9 
    lsr r11, r10, 5
    and r11, r11, 0xF // the original 4 bits we want
    and r12, r11, 0x1
    lsl r12, r12, 0x3
    lsr r11, r11, 1
    eor r11, r11, r12 // updated 4 bits bit
    and r11, r11, 0xF

    lsl r11, r11, 5
    mov r3, 0xFE1F
    and r9, r9, r3
    eor r9, r9, r11    


    str r9, [r1, #12]
    mov r9, 0
    mov r10, 0 // clear
    mov r11, 0 // clear
    mov r12, 0 // clear
    

   
   add sp, sp, #(4 * 2)

    // END OF CODE
    pop {r4-r11,r14}
    bx lr    


.align 4
.global   mixColumns
.type   mixColumns, %function;
// r0 = pt shares0
// r1 = pt shares1
mixColumns:
    
    push {r4-r11,r14}
    sub sp, sp, #(4 * 20)

    str r0, [sp, 0]


    ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// SHARE 0 /////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////

    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0


    ////////
    //////////////////////////////////////////////////////////////// FULL bits a ////////////////////////////////
    ////////
    ldr r2, [r0, #0] // a 
    mov r6, r2 // copy OG a
    
    ////////////////////////////////////////////
    //////////////////Update s0 = s0 + s8 + s12 ////////////////
    ////////////////////////////////////////////
    // s8
    lsr r10, r2, 8
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r2, 12
    and r11, r11, 0x1 // s12
    
    eor r11, r11, r10
    eor r6, r6, r11


    /////////////////////////////////////////////
    ///////////////// Update s1 = s1 + s9 + s13/////////////////
    /////////////////////////////////////////////

    // s9
    lsr r10, r2, 9
    and r10, r10, 0x1 // s9

    // s13
    lsr r11, r2, 13
    and r11, r11, 0x1 // s13
    
    eor r11, r11, r10

    lsl r11, r11, 1
    eor r6, r6, r11

    


    /////////////////////////////////////////////
    ///////////////// Update s2 = s2 + s10 + s14/////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits a
    ////////
    
    

    // s10
    lsr r10, r2, 10
    and r10, r10, 0x1 // s10

    // s14
    lsr r11, r2, 14
    and r11, r11, 0x1 // s14
    
    eor r11, r11, r10

    lsl r11, r11, 2

    eor r6, r6, r11


 

    /////////////////////////////////////////////
    ///////////////// Update s3 = s3 + s11 + s15/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits a
    ////////
    
    

    // s11
    lsr r10, r2, 11
    and r10, r10, 0x1 // s11
    

    // s15
    lsr r11, r2, 15
    and r11, r11, 0x1 // s15
    
    eor r11, r11, r10

    lsl r11, r11, 3

    eor r6, r6, r11
 
  

    /////////////////////////////////////////////
    ///////////////// Update s4 = s0/////////////////
    /////////////////////////////////////////////
    
    //////////////////////////////// bits a
    ////////
    mov r14, 0xFFEF
    
    
    
    // s0 
    and r11, r2, 0x1 // s0
    lsl r11, r11, 4

    and r6, r6, r14
    eor r6, r6, r11 // update r6

 

    /////////////////////////////////////////////
    ///////////////// Update s5 = s1 /////////////////
    /////////////////////////////////////////////
    mov r14, 0xFFDF
    //////////////////////////////// bits a
    ////////
    
    
    
    // s1 
    lsr r11, r2, 1
    and r11, r11, 0x1 // s1
    lsl r11, r11, 5

    and r6, r6, r14
    eor r6, r6, r11 // update r6

 

    /////////////////////////////////////////////
    ///////////////// Update s6 = s2/////////////////
    /////////////////////////////////////////////
    
    //////////////////////////////// bits a
    ////////
    mov r14, 0xFFBF
        
    // s2 
    lsr r11, r2, 2
    and r11, r11, 0x1 // s2
    lsl r11, r11, 6

    and r6, r6, r14
    eor r6, r6, r11 // update r6

 

    /////////////////////////////////////////////
    ///////////////// Update s7 = s3/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits a
    
    mov r14, 0xFF7F
    
    
    // s3 
    lsr r11, r2, 3
    and r11, r11, 0x1 // s3
    lsl r11, r11, 7

    and r6, r6, r14
    eor r6, r6, r11 // update r6

 

    /////////////////////////////////////////////
    ///////////////// Update s8 = s4 + s8 /////////////////
    /////////////////////////////////////////////

//////////////////////////////// bits a
    ////////
    
    
    
    // s4 
    lsr r11, r2, 4
    and r11, r11, 0x1 // s4
    lsl r11, r11, 8

    eor r6, r6, r11

 

    /////////////////////////////////////////////
    ///////////////// Update s9 = s5 + s9 /////////////////
    /////////////////////////////////////////////

 //////////////////////////////// bits a
    ////////
    
    
    
    // s5 
    lsr r11, r2, 5
    and r11, r11, 0x1 // s5
    lsl r11, r11, 9
    eor r6, r6, r11

 

    /////////////////////////////////////////////
    ///////////////// Update s10 = s6 + s10 ////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits a
    ////////
    
    
    
    // s6 
    lsr r11, r2, 6
    and r11, r11, 0x1 // s6
    lsl r11, r11, 10
    eor r6, r6, r11

 
    /////////////////////////////////////////////
    ///////////////// Update s11 = s7 + s11 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits a
    ////////
    
    
    // s7 
    lsr r11, r2, 7
    and r11, r11, 0x1 // s7
    lsl r11, r11, 11
    eor r6, r6, r11

 

    /////////////////////////////////////////////
    ///////////////// Update s12 = s0 + s8 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits a
    mov r14, 0xEFFF
    
    
    // s0 
    and r10, r2, 0x1 // s0

    lsr r11, r2, 8
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 12

    and r6, r6, r14
    eor r6, r6, r11 // update r6

 

    /////////////////////////////////////////////
    ///////////////// Update s13 = s1 + s9 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits a
    
    mov r14, 0xDFFF
    
    
    
    // s1 
    lsr r10, r2, 1
    and r10, r10, 0x1 // s1

    lsr r11, r2, 9
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 13

    and r6, r6, r14
    eor r6, r6, r11 // update r6

 

    //////////////////////////////////////////////
    ///////////////// Update s14 = s2 + s10 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits a
    mov r14, 0xBFFF
    
    
    
    // s2 
    lsr r10, r2, 2
    and r10, r10, 0x1 // s2

    lsr r11, r2, 10
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10

    lsl r11, r11, 14

    and r6, r6, r14
    eor r6, r6, r11 // update r6

    //////////////////////////////////////////////
    ///////////////// Update s15 = s3 + s11 ////////////////
    /////////////////////////////////////////////
    
    //////////////////////////////// bits a
    mov r14, 0x7FFF
    
    // s3 
    lsr r10, r2, 3
    and r10, r10, 0x1 // s3

    lsr r11, r2, 11
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 15

    and r6, r6, r14
    eor r6, r6, r11 // update r6

    str r6, [r0, #0] // a 
    mov r2, #0 // clear a
    mov r6, #0 // clear a og
    mov r10, #0 // clear
    mov r11, #0 // clear

    ////////
    //////////////////////////////////////////////////////////////// FULL bits b ////////////////////////////////
    ////////

    ldr r3, [r0, #4] // b 
    mov r7, r3 // copy OG b
    /////////////////////////////////////////////
    ///////////////// Update s0 = s0 + s8 + s12 /////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
 

    // s8
    lsr r10, r3, 7
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r3, 11
    and r11, r11, 0x1 // s12
    eor r11, r11, r10 // s8 + s12

    lsl r11, r11, 15
    eor r7, r7, r11 

    

    /////////////////////////////////////////////
    ///////////////// Update s1 = s1 + s9 + s13/////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits b
    ////////

    
    
    lsr r10, r3, 8
    and r10, r10, 0x1 // s9

    // s13
    lsr r11, r3, 12
    and r11, r11, 0x1 // s13
    
    eor r11, r11, r10

    eor r7, r7, r11

    
    




    /////////////////////////////////////////////
    ///////////////// Update s2 = s2 + s10 + s14/////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits b
    ////////
    
    
    // s10
    lsr r10, r3, 9
    and r10, r10, 0x1 // s10

    // s14
    lsr r11, r3, 13
    and r11, r11, 0x1 // s14
    
    eor r11, r11, r10

    lsl r11, r11, 1

    eor r7, r7, r11

    
    

    /////////////////////////////////////////////
    ///////////////// Update s3 = s3 + s11 + s15/////////////////
    /////////////////////////////////////////////



    //////////////////////////////// bits b
    ////////
    

    // s11
    lsr r10, r3, 10
    and r10, r10, 0x1 // s11
    

    // s15
    lsr r11, r3, 14
    and r11, r11, 0x1 // s15
    
    eor r11, r11, r10

    lsl r11, r11, 2

    eor r7, r7, r11

    
    


    /////////////////////////////////////////////
    ///////////////// Update s4 = s0/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    mov r14, 0xFFF7
    
    
    // s0 
    lsr r11, r3, 15
    and r11, r11, 0x1 // s0
    lsl r11, r11, 3

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    

    /////////////////////////////////////////////
    ///////////////// Update s5 = s1 /////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////

    mov r14, 0xFFEF
    
    
    
    // s1 
    and r11, r3, 0x1 // s1
    lsl r11, r11, 4

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    

    /////////////////////////////////////////////
    ///////////////// Update s6 = s2/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    mov r14, 0xFFDF
    
    
    
    // s2 
    lsr r11, r3, 1
    and r11, r11, 0x1 // s2
    lsl r11, r11, 5

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    

    /////////////////////////////////////////////
    ///////////////// Update s7 = s3/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    mov r14, 0xFFBF

    
    
    // s3 
    lsr r11, r3, 2
    and r11, r11, 0x1 // s3
    lsl r11, r11, 6

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    

    /////////////////////////////////////////////
    ///////////////// Update s8 = s4 + s8 /////////////////
    /////////////////////////////////////////////



    //////////////////////////////// bits b
    ////////

    
    
    
    // s4 
    lsr r11, r3, 3
    and r11, r11, 0x1 // s4
    lsl r11, r11, 7
    eor r7, r7, r11

    
    /////////////////////////////////////////////
    ///////////////// Update s9 = s5 + s9 /////////////////
    /////////////////////////////////////////////



    //////////////////////////////// bits b
    ////////
    
    
    
    // s5 
    lsr r11, r3, 4
    and r11, r11, 0x1 // s5
    lsl r11, r11, 8
    eor r7, r7, r11

    

    /////////////////////////////////////////////
    ///////////////// Update s10 = s6 + s10 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits b
    ////////
    
    
    // s6 
    lsr r11, r3, 5
    and r11, r11, 0x1 // s6
    lsl r11, r11, 9
    eor r7, r7, r11


    
    

    /////////////////////////////////////////////
    ///////////////// Update s11 = s7 + s11 ////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    
    
    // s7 
    lsr r11, r3, 6
    and r11, r11, 0x1 // s7
    lsl r11, r11, 10
    eor r7, r7, r11

    


    /////////////////////////////////////////////
    ///////////////// Update s12 = s0 + s8 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits b
    ////////
    mov r14, 0xF7FF
    
    
    
    // s0 
    lsr r10, r3, 15
    and r10, r10, 0x1 // s0

    lsr r11, r3, 7
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 11

    and r7, r7, r14
    eor r7, r7, r11 // update r7   

    


    /////////////////////////////////////////////
    ///////////////// Update s13 = s1 + s9 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits b
    ////////
    mov r14, 0xEFFF
    
    

    // s1 
    and r10, r3, 0x1 // s1

    lsr r11, r3, 8
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 12

    and r7, r7, r14
    eor r7, r7, r11 // update r7 

    

    /////////////////////////////////////////////
    ///////////////// Update s14 = s2 + s10 ////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    mov r14, 0xDFFF
    
    

    // s2 
    lsr r10, r3, 1
    and r10, r10, 0x1 // s2

    lsr r11, r3, 9
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10

    lsl r11, r11, 13

    and r7, r7, r14
    eor r7, r7, r11 // update r7 


    //////////////////////////////////////////////
    ///////////////// Update s15 = s3 + s11 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits b
    ////////
    mov r14, 0xBFFF

    // s3 
    lsr r10, r3, 2
    and r10, r10, 0x1 // s3

    lsr r11, r3, 10
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 14

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    str r7, [r0, #4] // b
    mov r3, #0 // clear b
    mov r7, #0 // clear b og
    mov r10, #0 // clear
    mov r11, #0 // clear


    ////////
    //////////////////////////////////////////////////////////////// FULL bits c ////////////////////////////////
    ////////


    ldr r4, [r0, #8] // c 
    mov r8, r4 // copy OG c


    /////////////////////////////////////////////
    ///////////////// Update s0 = s0 + s8 + s12 /////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////


    // s8
    lsr r10, r4, 6
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r4, 10
    and r11, r11, 0x1 // s12

    eor r11, r11, r10 // s8 + s12

    lsl r11, r11, 14
    eor r8, r8, r11 

    
    /////////////////////////////////////////////
    ///////////////// Update s1 = s1 + s9 + s13/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits c
    ////////
    

    
    lsr r10, r4, 7
    and r10, r10, 0x1 // s9

    // s13
    lsr r11, r4, 11
    and r11, r11, 0x1 // s13
    
    eor r11, r11, r10

    lsl r11, r11, 15

    eor r8, r8, r11



    


    /////////////////////////////////////////////
    ///////////////// Update s2 = s2 + s10 + s14/////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    

    // s10
    lsr r10, r4, 8
    and r10, r10, 0x1 // s10

    // s14
    lsr r11, r4, 12
    and r11, r11, 0x1 // s14
    
    eor r11, r11, r10

    //lsl r11, r11, 2

    eor r8, r8, r11

    

    /////////////////////////////////////////////
    ///////////////// Update s3 = s3 + s11 + s15/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits c
    ////////
    

    // s11
    lsr r10, r4, 9
    and r10, r10, 0x1 // s11
    

    // s15
    lsr r11, r4, 13
    and r11, r11, 0x1 // s15
    
    eor r11, r11, r10

    lsl r11, r11, 1

    eor r8, r8, r11

    
    /////////////////////////////////////////////
    ///////////////// Update s4 = s0/////////////////
    /////////////////////////////////////////////
    

    //////////////////////////////// bits c
    ////////
    mov r14, 0xFFFB    
    
    // s0 
    lsr r11, r4, 14
    and r11, r11, 0x1 // s0
    lsl r11, r11, 2

    and r8, r8, r14
    eor r8, r8, r11 // update r8


    /////////////////////////////////////////////
    ///////////////// Update s5 = s1 /////////////////
    /////////////////////////////////////////////



    //////////////////////////////// bits c
    ////////
    mov r14, 0xFFF7    

    
    // s1 
    lsr r11, r4, 15
    and r11, r11, 0x1 // s1
    lsl r11, r11, 3

    and r8, r8, r14
    eor r8, r8, r11 // update r8


    /////////////////////////////////////////////
    ///////////////// Update s6 = s2/////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    mov r14, 0xFFEF
    
    
    // s2 
    and r11, r4, 0x1 // s2
    lsl r11, r11, 4

    and r8, r8, r14
    eor r8, r8, r11 // update r8


    /////////////////////////////////////////////
    ///////////////// Update s7 = s3/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits c
    ////////
    mov r14, 0xFFDF
    
    
    // s3 
    lsr r11, r4, 1
    and r11, r11, 0x1 // s3
    lsl r11, r11, 5

    and r8, r8, r14
    eor r8, r8, r11 // update r8



    /////////////////////////////////////////////
    ///////////////// Update s8 = s4 + s8 /////////////////
    /////////////////////////////////////////////


    
    //////////////////////////////// bits c
    ////////
    

    
    
    // s4 
    lsr r11, r4, 2
    and r11, r11, 0x1 // s4
    lsl r11, r11, 6
    eor r8, r8, r11

    /////////////////////////////////////////////
    ///////////////// Update s9 = s5 + s9 /////////////////
    /////////////////////////////////////////////


   
    //////////////////////////////// bits c
    ////////
    

    
    
    // s5 
    lsr r11, r4, 3
    and r11, r11, 0x1 // s5
    lsl r11, r11, 7
    eor r8, r8, r11

    /////////////////////////////////////////////
    ///////////////// Update s10 = s6 + s10 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    

    
    // s6 
    lsr r11, r4, 4
    and r11, r11, 0x1 // s6
    lsl r11, r11, 8
    eor r8, r8, r11


    /////////////////////////////////////////////
    ///////////////// Update s11 = s7 + s11 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    

    
    // s7 
    lsr r11, r4, 5
    and r11, r11, 0x1 // s7
    lsl r11, r11, 9
    eor r8, r8, r11

    /////////////////////////////////////////////
    ///////////////// Update s12 = s0 + s8 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    mov r14, 0xFBFF    

    // s0 
    lsr r10, r4, 14
    and r10, r10, 0x1 // s0

    lsr r11, r4, 6
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 10

    and r8, r8, r14
    eor r8, r8, r11 // update r8   

    
    /////////////////////////////////////////////
    ///////////////// Update s13 = s1 + s9 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    
    mov r14, 0xF7FF    

    // s1 
    lsr r10, r4, 15
    and r10, r10, 0x1 // s1

    lsr r11, r4, 7
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 11

    and r8, r8, r14
    eor r8, r8, r11 // update r8 

    
    /////////////////////////////////////////////
    ///////////////// Update s14 = s2 + s10 ////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits c
    ////////
    mov r14, 0xEFFF    

    // s2 
    and r10, r4, 0x1 // s2

    lsr r11, r4, 8
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10

    lsl r11, r11, 12

    and r8, r8, r14
    eor r8, r8, r11 // update r8  


    //////////////////////////////////////////////
    ///////////////// Update s15 = s3 + s11 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    mov r14, 0xDFFF

    // s3 
    lsr r10, r4, 1
    and r10, r10, 0x1 // s3

    lsr r11, r4, 9
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 13

    and r8, r8, r14
    eor r8, r8, r11 // update r8

    str r8, [r0, #8] // c
    mov r4, #0 // clear c
    mov r8, #0 // clear b og
    mov r10, #0 // clear
    mov r11, #0 // clear



    ////////
    //////////////////////////////////////////////////////////////// FULL bits d ////////////////////////////////
    ////////

    ldr r5, [r0, #12] // d
    mov r9, r5 // copy OG d
    /////////////////////////////////////////////
    ///////////////// Update s0 = s0 + s8 + s12 /////////////////
    /////////////////////////////////////////////

    

    //////////////////////////////// bits d
    ////////


    // s8
    lsr r10, r5, 5
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r5, 9
    and r11, r11, 0x1 // s12
    eor r11, r11, r10 // s8 + s12

    lsl r11, r11, 13

    eor r9, r9, r11 


    

    ////////////////////////////////////////////
    //////////////////Update s1 = s1 + s9 + s13= s1 + s9 + s13
    ////////////////////////////////////////////

   
    //////////////////////////////// bits d
    ////////
    
    

    lsr r10, r5, 6
    and r10, r10, 0x1 // s9

    // s13
    lsr r11, r5, 10
    and r11, r11, 0x1 // s13
    
    eor r11, r11, r10

    lsl r11, r11, 14

    eor r9, r9, r11  
    

    // before here is OK

    ////////////////////////////////////////////
    //////////////////Update s2 = s2 + s10 + s14= s2 + s10 + s14
    ////////////////////////////////////////////




    //////////////////////////////// bits d
    ////////    

    // s10
    lsr r10, r5, 7
    and r10, r10, 0x1 // s10

    // s14
    lsr r11, r5, 11
    and r11, r11, 0x1 // s14
    
    eor r11, r11, r10

    lsl r11, r11, 15

    eor r9, r9, r11

    

   ////////////////////////////////////////////
    //////////////////Update s3 = s3 + s11 + s15= s3 + s11 + s15
    ////////////////////////////////////////////


    //////////////////////////////// bits d
    ////////    

    // s11
    lsr r10, r5, 8
    and r10, r10, 0x1 // s11
    

    // s15
    lsr r11, r5, 12
    and r11, r11, 0x1 // s15
    
    eor r11, r11, r10

    //lsl r11, r11, 1

    eor r9, r9, r11     

    


    ////////////////////////////////////////////
    //////////////////Update s4 = s0= s0
    ////////////////////////////////////////////


    //////////////////////////////// bits d
    ////////
    mov r14, 0xFFFD    

    
    
    // s0 
    lsr r11, r5, 13
    and r11, r11, 0x1 // s0
    lsl r11, r11, 1

    and r9, r9, r14
    eor r9, r9, r11 // update r9


    ////////////////////////////////////////////
    //////////////////Update s5 = s1 = s1
    ////////////////////////////////////////////
    

    //////////////////////////////// bits d
    ////////
    mov r14, 0xFFFB    

    
    // s1 
    lsr r11, r5, 14
    and r11, r11, 0x1 // s1
    lsl r11, r11, 2

    and r9, r9, r14
    eor r9, r9, r11 // update r9    


    ////////////////////////////////////////////
    //////////////////Update s6 = s2= s2
    ////////////////////////////////////////////
    


    //////////////////////////////// bits d
    ////////
    mov r14, 0xFFF7    
    
    // s2 
    lsr r11, r5, 15
    and r11, r11, 0x1 // s2
    lsl r11, r11, 3

    and r9, r9, r14
    eor r9, r9, r11 // update r9 



    ////////////////////////////////////////////
    //////////////////Update s7 = s3= s3
    ////////////////////////////////////////////
    


    //////////////////////////////// bits d
    ////////
    mov r14, 0xFFEF
    

    
    // s3 
    and r11, r5, 0x1 // s3
    lsl r11, r11, 4

    and r9, r9, r14
    eor r9, r9, r11 // update r9 



    ////////////////////////////////////////////
    //////////////////Update s8 = s4 + s8 = s4 + s8
    ////////////////////////////////////////////

    //////////////////////////////// bits d
    ////////    

    
    // s4 
    lsr r11, r5, 1
    and r11, r11, 0x1 // s4
    lsl r11, r11, 5
    eor r9, r9, r11



    ////////////////////////////////////////////
    //////////////////Update s9 = s5 + s9 = s5 + s9
    ////////////////////////////////////////////


    //////////////////////////////// bits d
    ////////    
    
    // s5 
    lsr r11, r5, 2
    and r11, r11, 0x1 // s5
    lsl r11, r11, 6
    eor r9, r9, r11 



    ////////////////////////////////////////////
    //////////////////Update s10 = s6 + s10 = s6 + s10
    ////////////////////////////////////////////

    

    //////////////////////////////// bits d
    ////////    

    
    // s6 
    lsr r11, r5, 3
    and r11, r11, 0x1 // s6
    lsl r11, r11, 7
    eor r9, r9, r11 


    ////////////////////////////////////////////
    //////////////////Update s11 = s7 + s11 = s7 + s11
    ////////////////////////////////////////////


    //////////////////////////////// bits d
    ////////    

    
    // s7 
    lsr r11, r5, 4
    and r11, r11, 0x1 // s7
    lsl r11, r11, 8
    eor r9, r9, r11 


    ////////////////////////////////////////////
    //////////////////Update s12 = s0 + s8 = s0 + s8
    ////////////////////////////////////////////
    


    //////////////////////////////// bits d
    ////////
    mov r14, 0xFDFF    

    // s0 
    lsr r10, r5, 13
    and r10, r10, 0x1 // s0

    lsr r11, r5, 5
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 9

    and r9, r9, r14
    eor r9, r9, r11 // update r9   

    

    ////////////////////////////////////////////
    //////////////////Update s13 = s1 + s9 = s1 + s9
    ////////////////////////////////////////////


    //////////////////////////////// bits d
    ////////
    mov r14, 0xFBFF    

        // s1 
    lsr r10, r5, 14
    and r10, r10, 0x1 // s1

    lsr r11, r5, 6
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 10

    and r9, r9, r14
    eor r9, r9, r11 // update r9 
    


    ////////////////////////////////////////////
    //////////////////Update s14 = s2 + s10 = s2 + s10
    ////////////////////////////////////////////
    


    //////////////////////////////// bits d
    ////////
    mov r14, 0xF7FF    

    // s2 
    lsr r10, r5, 15
    and r10, r10, 0x1 // s2

    lsr r11, r5, 7
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10
    lsl r11, r11, 11

    and r9, r9, r14
    eor r9, r9, r11 // update r9     



    ////////////////////////////////////////////
    //////////////////Update s15 = s3 + s11 = s3 + s11
    ////////////////////////////////////////////


    //////////////////////////////// bits d
    ////////
    mov r14, 0xEFFF

    // s3 
    and r10, r5, 0x1 // s3

    lsr r11, r5, 8
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 12

    and r9, r9, r14
    eor r9, r9, r11 // update r9

    str r9, [r0, #12] // d
    mov r5, #0 // clear d
    mov r9, #0 // clear b og
    mov r10, #0 // clear
    mov r11, #0 // clear



    // clear shares 0
    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r5, #0

    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0

    mov r10, #0
    mov r11, #0
    mov r12, #0

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// SHARE 1 ////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////

  
    ////////
    //////////////////////////////////////////////////////////////// FULL bits a ////////////////////////////////
    ////////

    
    ldr r2, [r1, #0] // a 
    mov r6, r2 // copy OG a
    
    ////////////////////////////////////////////
    //////////////////Update s0 = s0 + s8 + s12 ////////////////
    ////////////////////////////////////////////    

    lsr r10, r2, 4
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r2, 8
    and r11, r11, 0x1 // s12
    
    eor r11, r11, r10
    

    lsl r11, r11, 12

    eor r6, r6, r11


    /////////////////////////////////////////////
    ///////////////// Update s1 = s1 + s9 + s13/////////////////
    /////////////////////////////////////////////


    lsr r10, r2, 5
    and r10, r10, 0x1 // s9

    // s12
    lsr r11, r2, 9
    and r11, r11, 0x1 // s13
    
    eor r11, r11, r10


    lsl r11, r11, 13
    eor r6, r6, r11


    /////////////////////////////////////////////
    ///////////////// Update s2 = s2 + s10 + s14/////////////////
    /////////////////////////////////////////////

    lsr r10, r2, 6
    and r10, r10, 0x1 // s10

    // s12
    lsr r11, r2, 10
    and r11, r11, 0x1 // s14
    
    eor r11, r11, r10
    
    lsl r11, r11, 14

    eor r6, r6, r11

 

    /////////////////////////////////////////////
    ///////////////// Update s3 = s3 + s11 + s15/////////////////
    /////////////////////////////////////////////

    lsr r10, r2, 7
    and r10, r10, 0x1 // s11

    // s12
    lsr r11, r2, 11
    and r11, r11, 0x1 // s15
    
    eor r11, r11, r10
    
    lsl r11, r11, 15

    eor r6, r6, r11
  

    /////////////////////////////////////////////
    ///////////////// Update s4 = s0/////////////////
    /////////////////////////////////////////////
    
    mov r14, 0xFFFE

    lsr r10, r2, 12
    and r10, r10, 0x1 // s0

    and r6, r6, r14
    eor r6, r6, r10

 

    /////////////////////////////////////////////
    ///////////////// Update s5 = s1 /////////////////
    /////////////////////////////////////////////

    mov r14, 0xFFFD

    lsr r10, r2, 13
    and r10, r10, 0x1 // s1

    lsl r10, r10, 1

    and r6, r6, r14
    eor r6, r6, r10

 

    /////////////////////////////////////////////
    ///////////////// Update s6 = s2/////////////////
    /////////////////////////////////////////////
    
    
    mov r14, 0xFFFB

    lsr r10, r2, 14
    and r10, r10, 0x1 // s2

    lsl r10, r10, 2
    
    and r6, r6, r14
    eor r6, r6, r10

 

    /////////////////////////////////////////////
    ///////////////// Update s7 = s3/////////////////
    /////////////////////////////////////////////

    
    mov r14, 0xFFF7

    lsr r10, r2, 15
    and r10, r10, 0x1 // s3

    lsl r10, r10, 3
    
    and r6, r6, r14
    eor r6, r6, r10


 

    /////////////////////////////////////////////
    ///////////////// Update s8 = s4 + s8 /////////////////
    /////////////////////////////////////////////

    
    and r10, r2, 0x1 // s4
    
    lsl r10, r10, 4

    eor r6, r6, r10


    /////////////////////////////////////////////
    ///////////////// Update s9 = s5 + s9 /////////////////
    /////////////////////////////////////////////

    lsr r10, r2, 1
    and r10, r10, 0x1 // s5
    
    lsl r10, r10, 5

    eor r6, r6, r10

 

    /////////////////////////////////////////////
    ///////////////// Update s10 = s6 + s10 ////////////////
    /////////////////////////////////////////////

    lsr r10, r2, 2
    and r10, r10, 0x1 // s6
    
    lsl r10, r10, 6
    
    eor r6, r6, r10

 
    /////////////////////////////////////////////
    ///////////////// Update s11 = s7 + s11 ////////////////
    /////////////////////////////////////////////
    
    lsr r10, r2, 3
    and r10, r10, 0x1 // s7
    
    lsl r10, r10, 7
    
    eor r6, r6, r10
 

    /////////////////////////////////////////////
    ///////////////// Update s12 = s0 + s8 ////////////////
    /////////////////////////////////////////////

    mov r14, 0xFEFF
    
    
    // s0 
    lsr r10, r2, 12 
    and r10, r10, 0x1 // s0

    lsr r11, r2, 4
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 8

    and r6, r6, r14
    eor r6, r6, r11 // update r12

 

    /////////////////////////////////////////////
    ///////////////// Update s13 = s1 + s9 ////////////////
    /////////////////////////////////////////////

    
    mov r14, 0xFDFF
    
    
    // s1 
    lsr r10, r2, 13
    and r10, r10, 0x1 // s1

    lsr r11, r2, 5
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 9

    and r6, r6, r14
    eor r6, r6, r11 // update r6

 

    //////////////////////////////////////////////
    ///////////////// Update s14 = s2 + s10 ////////////////
    /////////////////////////////////////////////

    mov r14, 0xFBFF
    
    
    // s2 
    lsr r10, r2, 14
    and r10, r10, 0x1 // s2

    lsr r11, r2, 6
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10

    lsl r11, r11, 10

    and r6, r6, r14
    eor r6, r6, r11 // update r6

    //////////////////////////////////////////////
    ///////////////// Update s15 = s3 + s11 ////////////////
    /////////////////////////////////////////////
    
    mov r14, 0xF7FF
    
    // s3 
    lsr r10, r2, 15
    and r10, r10, 0x1 // s3

    lsr r11, r2, 7
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 11

    and r6, r6, r14
    eor r6, r6, r11 // update r6

    str r6, [r1, #0] // a 
    mov r2, #0 // clear a
    mov r6, #0 // clear a og
    mov r10, #0 // clear
    mov r11, #0 // clear

    ////////
    //////////////////////////////////////////////////////////////// FULL bits b ////////////////////////////////
    ////////

    ldr r3, [r1, #4] // b 
    mov r7, r3 // copy OG b
    /////////////////////////////////////////////
    ///////////////// Update s0 = s0 + s8 + s12 /////////////////
    /////////////////////////////////////////////


    // s8
    lsr r10, r3, 3
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r3, 7
    and r11, r11, 0x1 // s12
    eor r11, r11, r10 // s8 + s12

    lsl r11, r11, 11
    eor r7, r7, r11 

    

    /////////////////////////////////////////////
    ///////////////// Update s1 = s1 + s9 + s13/////////////////
    /////////////////////////////////////////////
    
    
    lsr r10, r3, 4
    and r10, r10, 0x1 // s9

    // s13
    lsr r11, r3, 8
    and r11, r11, 0x1 // s13
    eor r11, r11, r10

    lsl r11, r11, 12

    eor r7, r7, r11

    

    /////////////////////////////////////////////
    ///////////////// Update s2 = s2 + s10 + s14/////////////////
    /////////////////////////////////////////////

        
    // s10
    lsr r10, r3, 5
    and r10, r10, 0x1 // s10

    // s14
    lsr r11, r3, 9
    and r11, r11, 0x1 // s14
    eor r11, r11, r10

    lsl r11, r11, 13

    eor r7, r7, r11
    
    

    /////////////////////////////////////////////
    ///////////////// Update s3 = s3 + s11 + s15/////////////////
    /////////////////////////////////////////////



    //////////////////////////////// bits b
    ////////
    

    // s11
    lsr r10, r3, 6
    and r10, r10, 0x1 // s11
    

    // s15
    lsr r11, r3, 10
    and r11, r11, 0x1 // s15
    eor r11, r11, r10

    lsl r11, r11, 14
    eor r7, r7, r11

    
    


    /////////////////////////////////////////////
    ///////////////// Update s4 = s0/////////////////
    /////////////////////////////////////////////

    mov r14, 0x7FFF
    
    
    // s0 
    lsr r11, r3, 11
    and r11, r11, 0x1 // s0
    lsl r11, r11, 15

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    
    /////////////////////////////////////////////
    ///////////////// Update s5 = s1 /////////////////
    /////////////////////////////////////////////

    mov r14, 0xFFFE
    
    // s1 
    lsr r11, r3, 12
    and r11, r11, 0x1 // s1

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    

    /////////////////////////////////////////////
    ///////////////// Update s6 = s2/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    mov r14, 0xFFFD
    
    // s2 
    lsr r11, r3, 13
    and r11, r11, 0x1 // s2
    lsl r11, r11, 1

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    

    /////////////////////////////////////////////
    ///////////////// Update s7 = s3/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    mov r14, 0xFFFB

    // s3 
    lsr r11, r3, 14
    and r11, r11, 0x1 // s3
    lsl r11, r11, 2

    and r7, r7, r14
    eor r7, r7, r11 // update r7


    /////////////////////////////////////////////
    ///////////////// Update s8 = s4 + s8 /////////////////
    /////////////////////////////////////////////
    
    // s4 
    lsr r11, r3, 15
    and r11, r11, 0x1 // s4
    lsl r11, r11, 3
    eor r7, r7, r11

    
    /////////////////////////////////////////////
    ///////////////// Update s9 = s5 + s9 /////////////////
    /////////////////////////////////////////////
        
    // s5 
    and r11, r3, 0x1 // s5
    lsl r11, r11, 4
    eor r7, r7, r11
    

    /////////////////////////////////////////////
    ///////////////// Update s10 = s6 + s10 ////////////////
    /////////////////////////////////////////////
    
    // s6 
    lsr r11, r3, 1
    and r11, r11, 0x1 // s6
    lsl r11, r11, 5
    eor r7, r7, r11



    /////////////////////////////////////////////
    ///////////////// Update s11 = s7 + s11 ////////////////
    /////////////////////////////////////////////
    
    // s7 
    lsr r11, r3, 2
    and r11, r11, 0x1 // s7
    lsl r11, r11, 6
    eor r7, r7, r11


    /////////////////////////////////////////////
    ///////////////// Update s12 = s0 + s8 ////////////////
    /////////////////////////////////////////////

    mov r14, 0xFF7F
    
    // s0 
    lsr r10, r3, 11
    and r10, r10, 0x1 // s0

    lsr r11, r3, 3
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 7

    and r7, r7, r14
    eor r7, r7, r11 // update r7   

    


    /////////////////////////////////////////////
    ///////////////// Update s13 = s1 + s9 ////////////////
    /////////////////////////////////////////////

    mov r14, 0xFEFF
    
    // s1 
    lsr r10, r3, 12
    and r10, r10, 0x1 // s1

    lsr r11, r3, 4
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 8

    and r7, r7, r14
    eor r7, r7, r11 // update r7 

    

    /////////////////////////////////////////////
    ///////////////// Update s14 = s2 + s10 ////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits b
    ////////
    mov r14, 0xFDFF
    

    // s2 
    lsr r10, r3, 13
    and r10, r10, 0x1 // s2

    lsr r11, r3, 5
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10

    lsl r11, r11, 9

    and r7, r7, r14
    eor r7, r7, r11 // update r7 


    //////////////////////////////////////////////
    ///////////////// Update s15 = s3 + s11 ////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits b
    ////////
    mov r14, 0xFBFF

    // s3 
    lsr r10, r3, 14
    and r10, r10, 0x1 // s3

    lsr r11, r3, 6
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 10

    and r7, r7, r14
    eor r7, r7, r11 // update r7

    str r7, [r1, #4] // b
    mov r3, #0 // clear b
    mov r7, #0 // clear b og
    mov r10, #0 // clear
    mov r11, #0 // clear




    ////////
    //////////////////////////////////////////////////////////////// FULL bits c ////////////////////////////////
    ////////

    ldr r4, [r1, #8] // c 
    mov r8, r4 // copy OG c

    /////////////////////////////////////////////
    ///////////////// Update s0 = s0 + s8 + s12 /////////////////
    /////////////////////////////////////////////


    // s8
    lsr r10, r4, 2
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r4, 6
    and r11, r11, 0x1 // s12

    eor r11, r11, r10 // s8 + s12

    lsl r11, r11, 10
    eor r8, r8, r11 

    
    /////////////////////////////////////////////
    ///////////////// Update s1 = s1 + s9 + s13/////////////////
    /////////////////////////////////////////////

    
    lsr r10, r4, 3
    and r10, r10, 0x1 // s9

    // s13
    lsr r11, r4, 7
    and r11, r11, 0x1 // s13
    
    eor r11, r11, r10
    lsl r11, r11, 11

    eor r8, r8, r11



    


    /////////////////////////////////////////////
    ///////////////// Update s2 = s2 + s10 + s14/////////////////
    /////////////////////////////////////////////


    //////////////////////////////// bits c
    ////////
    

    // s10
    lsr r10, r4, 4
    and r10, r10, 0x1 // s10

    // s14
    lsr r11, r4, 8
    and r11, r11, 0x1 // s14
    
    eor r11, r11, r10
    lsl r11, r11, 12

    eor r8, r8, r11

    

    /////////////////////////////////////////////
    ///////////////// Update s3 = s3 + s11 + s15/////////////////
    /////////////////////////////////////////////

    // s11
    lsr r10, r4, 5
    and r10, r10, 0x1 // s11
    

    // s15
    lsr r11, r4, 9
    and r11, r11, 0x1 // s15
    
    eor r11, r11, r10
    lsl r11, r11, 13

    eor r8, r8, r11

    
    /////////////////////////////////////////////
    ///////////////// Update s4 = s0/////////////////
    /////////////////////////////////////////////
    

    //////////////////////////////// bits c
    ////////
    mov r14, 0xBFFF
    
    // s0 
    lsr r11, r4, 10
    and r11, r11, 0x1 // s0
    lsl r11, r11, 14

    and r8, r8, r14
    eor r8, r8, r11 // update r8


    /////////////////////////////////////////////
    ///////////////// Update s5 = s1 /////////////////
    /////////////////////////////////////////////



    //////////////////////////////// bits c
    ////////
    mov r14, 0x7FFF

    
    // s1 
    lsr r11, r4, 11
    and r11, r11, 0x1 // s1
    lsl r11, r11, 15

    and r8, r8, r14
    eor r8, r8, r11 // update r8


    /////////////////////////////////////////////
    ///////////////// Update s6 = s2/////////////////
    /////////////////////////////////////////////

    mov r14, 0xFFFE
    
    
    // s2 
    lsr r11, r4, 12
    and r11, r11, 0x1 // s2
    //lsl r11, r11, 4

    and r8, r8, r14
    eor r8, r8, r11 // update r8


    /////////////////////////////////////////////
    ///////////////// Update s7 = s3/////////////////
    /////////////////////////////////////////////

    //////////////////////////////// bits c
    ////////
    mov r14, 0xFFFD
    
    
    // s3 
    lsr r11, r4, 13
    and r11, r11, 0x1 // s3
    lsl r11, r11, 1

    and r8, r8, r14
    eor r8, r8, r11 // update r8



    /////////////////////////////////////////////
    ///////////////// Update s8 = s4 + s8 /////////////////
    /////////////////////////////////////////////

    
    // s4 
    lsr r11, r4, 14
    and r11, r11, 0x1 // s4
    lsl r11, r11, 2
    eor r8, r8, r11

    /////////////////////////////////////////////
    ///////////////// Update s9 = s5 + s9 /////////////////
    /////////////////////////////////////////////
    
    // s5 
    lsr r11, r4, 15
    and r11, r11, 0x1 // s5
    lsl r11, r11, 3
    eor r8, r8, r11

    /////////////////////////////////////////////
    ///////////////// Update s10 = s6 + s10 ////////////////
    /////////////////////////////////////////////

    // s6
    and r11, r4, 0x1 // s6
    lsl r11, r11, 4
    eor r8, r8, r11


    /////////////////////////////////////////////
    ///////////////// Update s11 = s7 + s11 ////////////////
    /////////////////////////////////////////////

    // s7 
    lsr r11, r4, 1
    and r11, r11, 0x1 // s7
    lsl r11, r11, 5
    eor r8, r8, r11

    /////////////////////////////////////////////
    ///////////////// Update s12 = s0 + s8 ////////////////
    /////////////////////////////////////////////

    mov r14, 0xFFBF

    // s0 
    lsr r10, r4, 10
    and r10, r10, 0x1 // s0

    lsr r11, r4, 2
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 6

    and r8, r8, r14
    eor r8, r8, r11 // update r8   

    
    /////////////////////////////////////////////
    ///////////////// Update s13 = s1 + s9 ////////////////
    /////////////////////////////////////////////
    
    mov r14, 0xFF7F

    // s1 
    lsr r10, r4, 11
    and r10, r10, 0x1 // s1

    lsr r11, r4, 3
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 7

    and r8, r8, r14
    eor r8, r8, r11 // update r8 

    
    /////////////////////////////////////////////
    ///////////////// Update s14 = s2 + s10 ////////////////
    /////////////////////////////////////////////

    mov r14, 0xFEFF

    // s2 
    lsr r10, r4, 12
    and r10, r10, 0x1 // s2

    lsr r11, r4, 4
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10

    lsl r11, r11, 8

    and r8, r8, r14
    eor r8, r8, r11 // update r8  


    //////////////////////////////////////////////
    ///////////////// Update s15 = s3 + s11 ////////////////
    /////////////////////////////////////////////

    mov r14, 0xFDFF

    // s3 
    lsr r10, r4, 13
    and r10, r10, 0x1 // s3

    lsr r11, r4, 5
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 9

    and r8, r8, r14
    eor r8, r8, r11 // update r8

    str r8, [r1, #8] // c
    mov r4, #0 // clear c
    mov r8, #0 // clear b og
    mov r10, #0 // clear
    mov r11, #0 // clear



    ////////
    //////////////////////////////////////////////////////////////// FULL bits d ////////////////////////////////
    ////////

    ldr r5, [r1, #12] // d
    mov r9, r5 // copy OG d
    /////////////////////////////////////////////
    ///////////////// Update s0 = s0 + s8 + s12 /////////////////
    /////////////////////////////////////////////

    // s8
    lsr r10, r5, 1
    and r10, r10, 0x1 // s8

    // s12
    lsr r11, r5, 5
    and r11, r11, 0x1 // s12
    eor r11, r11, r10 // s8 + s12

    lsl r11, r11, 9
    eor r9, r9, r11 


    

    ////////////////////////////////////////////
    //////////////////Update s1 = s1 + s9 + s13
    ////////////////////////////////////////////


    lsr r10, r5, 2
    and r10, r10, 0x1 // s9

    // s13
    lsr r11, r5, 6
    and r11, r11, 0x1 // s13
    
    eor r11, r11, r10
    lsl r11, r11, 10

    eor r9, r9, r11  
    

    // before here is OK

    ////////////////////////////////////////////
    //////////////////Update s2 = s2 + s10 + s14
    ////////////////////////////////////////////


    // s10
    lsr r10, r5, 3
    and r10, r10, 0x1 // s10

    // s14
    lsr r11, r5, 7
    and r11, r11, 0x1 // s14
    
    eor r11, r11, r10

    lsl r11, r11, 11

    eor r9, r9, r11

    

    ////////////////////////////////////////////
    //////////////////Update s3 = s3 + s11 + s15
    ////////////////////////////////////////////

    // s11
    lsr r10, r5, 4
    and r10, r10, 0x1 // s11
    
    // s15
    lsr r11, r5, 8
    and r11, r11, 0x1 // s15
    
    eor r11, r11, r10

    lsl r11, r11, 12

    eor r9, r9, r11     

    
    ////////////////////////////////////////////
    //////////////////Update s4 = s0
    ////////////////////////////////////////////

    mov r14, 0xDFFF
    
    // s0 
    lsr r11, r5, 9
    and r11, r11, 0x1 // s0
    lsl r11, r11, 13

    and r9, r9, r14
    eor r9, r9, r11 // update r9


    ////////////////////////////////////////////
    //////////////////Update s5 = s1
    ////////////////////////////////////////////
    
    mov r14, 0xBFFF

    
    // s1 
    lsr r11, r5, 10
    and r11, r11, 0x1 // s1
    lsl r11, r11, 14

    and r9, r9, r14
    eor r9, r9, r11 // update r9    


    ////////////////////////////////////////////
    //////////////////Update s6 = s2
    ////////////////////////////////////////////
    
    mov r14, 0x7FFF
    
    // s2 
    lsr r11, r5, 11
    and r11, r11, 0x1 // s2
    lsl r11, r11, 15

    and r9, r9, r14
    eor r9, r9, r11 // update r9 



    ////////////////////////////////////////////
    //////////////////Update s7 = s3
    ////////////////////////////////////////////
    
    mov r14, 0xFFFE
    

    
    // s3 
    lsr r11, r5, 12
    and r11, r11, 0x1 // s3
    //lsl r11, r11, 4

    and r9, r9, r14
    eor r9, r9, r11 // update r9 


    ////////////////////////////////////////////
    //////////////////Update s8 = s4 + s8
    ////////////////////////////////////////////

    
    // s4 
    lsr r11, r5, 13
    and r11, r11, 0x1 // s4
    lsl r11, r11, 1
    eor r9, r9, r11


    ////////////////////////////////////////////
    //////////////////Update s9 = s5 + s9
    ////////////////////////////////////////////

    // s5 
    lsr r11, r5, 14
    and r11, r11, 0x1 // s5
    lsl r11, r11, 2
    eor r9, r9, r11 



    ////////////////////////////////////////////
    //////////////////Update s10 = s6 + s10
    ////////////////////////////////////////////

    // s6 
    lsr r11, r5, 15
    and r11, r11, 0x1 // s6
    lsl r11, r11, 3
    eor r9, r9, r11 


    ////////////////////////////////////////////
    //////////////////Update s11 = s7 + s11
    ////////////////////////////////////////////


    //////////////////////////////// bits d
    ////////    

    // s7 
    and r11, r5, 0x1 // s7
    lsl r11, r11, 4
    eor r9, r9, r11 


    ////////////////////////////////////////////
    //////////////////Update s12 = s0 + s8
    ////////////////////////////////////////////
    
    mov r14, 0xFFDF

    // s0 
    lsr r10, r5, 9
    and r10, r10, 0x1 // s0

    lsr r11, r5, 1
    and r11, r11, 0x1 // s8

    eor r11, r11, r10 // s0 + s8
    lsl r11, r11, 5

    and r9, r9, r14
    eor r9, r9, r11 // update r9   

    

    ////////////////////////////////////////////
    //////////////////Update s13 = s1 + s9
    ////////////////////////////////////////////

    mov r14, 0xFFBF

    // s1 
    lsr r10, r5, 10
    and r10, r10, 0x1 // s1

    lsr r11, r5, 2
    and r11, r11, 0x1 // s9

    eor r11, r11, r10 // s1 + s9

    lsl r11, r11, 6

    and r9, r9, r14
    eor r9, r9, r11 // update r9 
    

    ////////////////////////////////////////////
    //////////////////Update s14 = s2 + s10 
    ////////////////////////////////////////////
    
    mov r14, 0xFF7F

    // s2 
    lsr r10, r5, 11
    and r10, r10, 0x1 // s2

    lsr r11, r5, 3
    and r11, r11, 0x1 // s10

    eor r11, r11, r10 // s2 + s10
    lsl r11, r11, 7

    and r9, r9, r14
    eor r9, r9, r11 // update r9     



    ////////////////////////////////////////////
    //////////////////Update s15 = s3 + s11
    ////////////////////////////////////////////

    mov r14, 0xFEFF

    // s3 
    lsr r10, r5, 12
    and r10, r10, 0x1 // s3 problem

    lsr r11, r5, 4
    and r11, r11, 0x1 // s11

    eor r11, r11, r10 // s3 + s11

    lsl r11, r11, 8

    and r9, r9, r14
    eor r9, r9, r11 // update r9

    str r9, [r1, #12] // d
    mov r5, #0 // clear d
    mov r9, #0 // clear b og
    mov r10, #0 // clear
    mov r11, #0 // clear

    // clear shares 1
    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r5, #0

    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0

    // END OF CODE MIXCOLUMNS
    
    add sp, sp, #(4 * 20)
    pop {r4-r11,r14}
    bx lr    






.align 4
.global   skinny_assembly
.type   skinny_assembly, %function;
// r0 = pt BS shares0
// r1 = pt BS shares1
// r2 = BS_RK_0
// r3 = BS_RK_1
// r4 = randomness

skinny_assembly:
    
    ldr r4, [sp, #0]
    
    push {r4-r11,r14}
    
    sub sp, sp, #(4 * 40)
    str r0, [sp, #0] // pt BS shares0
    str r1, [sp, #4] // pt BS shares1
    str r2, [sp, #8] // BS_RK_0
    str r3, [sp, #12] // BS_RK_1
    str r4, [sp, #16] // randomness

    // Round [0-31]
    mov r11, #0 // round count
    str r11, [sp, #32] // store round count in the stack

mainLoop:

    ldr r0, [sp, #0] // pt BS shares0
    ldr r1, [sp, #4] // pt BS shares1
    ldr r2, [sp, #8] // BS_RK_0
    ldr r3, [sp, #12] // BS_RK_1
    ldr r4, [sp, #16] // randomness

    ///////// SBOX /////////
        // r0 = pt BS shares0
        // r1 = pt BS shares1
        // r2 = randomness
        // r3 = round
    ////////////////////////
 
    mov r2, r4
    mov r3, r11
    bl sbox

    ///////// AddConstants /////////
    mov r1, r11
    bl addRCnst
    ldr r1, [sp, #4]

    ///////// Add key Round /////////
    ldr r2, [sp, #8] // BS_RK_0
    ldr r3, [sp, #12] // BS_RK_1
    mov r4, r11
    bl addRoundKey 

    bl shiftRows

    bl mixColumns


    // Loop iteration
    ldr r11, [sp, #32]
    add r11, r11, #1
    str r11, [sp, #32]
    cmp r11, #32
    blt mainLoop

    bl fromBStoElem

    // END OF CODE
    add sp, sp, #(4 * 40)
    pop {r4-r11,r14}
    bx lr




//////////////////////////////////////////////////////
/////////////// Shifted Sbox 2-refresh ///////////////
//////////////////////////////////////////////////////
.align 4
.global   sbox
.type   sbox, %function;
// r0 = pt BS shares0
// r1 = pt BS shares1
// r2 = randomness
// r3 = round

sbox:
    push {r4-r11,r14}
    
    sub sp, sp, #(4 * 100)
    str r0, [sp, #0] // pt BS shares0
    str r1, [sp, #4] // pt BS shares1
    str r2, [sp, #8] // pt randomness
    str r3, [sp, #12] // round
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// LOAD BIT-SLICE INPUTS ////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////

    //load shares 0
    ldr r2, [r0, #0]
    ldr r3, [r0, #4]
    ldr r4, [r0, #8]
    ldr r5, [r0, #12]

    //load shares 1
    ldr r6, [r1, #0]
    ldr r7, [r1, #4]
    ldr r8, [r1, #8]
    ldr r9, [r1, #12]



    //////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////// COMPUTE A1 ////////////////////////////
    //////////////////////////////////////////////////////////////////////////////

    // Shares 0
    mov r10, r3
    // ROR 7
    lsr r10, r10, #7 // place at free index 8
    lsl r11, r3, #9
    eor r10, r10, r11
    mov r11, 0xFFFF
    and r10, r10, r11
    
    mov r3, r5
    // ROL r3 by two
    lsr r11, r3, #14
    lsl r3, r3, #2
    eor r3, r3, r11
    mov r11, 0xFFFF
    and r3, r3, r11

    mov r5, r4
    // ROR r5 by one
    lsl r11, r5, #15 // get c_13
    lsr r5, r5, #1
    eor r5, r5, r11
    mov r11, 0xFFFF
    and r5, r5, r11

    // ROL r4 by 6
    lsl r4, r10, #6
    lsr r10, r10, #10 
    eor r4, r4, r10
    mov r11, 0xFFFF
    and r4, r4, r11
    
    mov r10, 0xFFFF
    eor r2, r2, r10
    eor r3, r3, r10
    eor r4, r4, r10
    eor r5, r5, r10
    
    // store shares 0
    str r2, [r0, #0]
    str r3, [r0, #4]
    str r4, [r0, #8]
    str r5, [r0, #12]



    ///////////////////// Shares 1 /////////////////////

    mov r10, r7
    // ROR 3
    lsr r10, r10, #3 // place at free index 8
    lsl r11, r7, 16-3
    eor r10, r10, r11
    mov r11, 0xFFFF
    and r10, r10, r11
    
    mov r7, r9
    // ROL r7 by two
    lsr r11, r7, #14
    lsl r7, r7, #2
    eor r7, r7, r11
    mov r11, 0xFFFF
    and r7, r7, r11
    
    mov r9, r8
    // ROR r9 by one
    lsl r11, r9, #15 // get c_9
    lsr r9, r9, #1
    eor r9, r9, r11
    mov r11, 0xFFFF
    and r9, r9, r11


    // ROL r8 by 2
    lsl r8, r10, #2
    lsr r10, r10, #14 
    eor r8, r8, r10
    mov r10, #0
    mov r11, 0xFFFF
    and r8, r8, r11
    mov r10, #0
    

    // store shares 1
    str r6, [r1, #0]
    str r7, [r1, #4]
    str r8, [r1, #8]
    str r9, [r1, #12]




    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////// COMPUTE FIRST Q_294 (a, b, c, d) -> (a + bd, b + cd, c, d)  ////////////////////////////////////
    /////////////////////////////////////////////////// (b0 + a1 + c1 + d1)(d0 + a1 + b1 + c1) and (c0 + a1 + b1 + d1)(d0 + a1 + b1 + c1) //////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    //////////////////////////////////////////// REFRESH SHARES /////////////////////////////////////////
    // compute index to fetch Randomness from array according to the current round
    ldr r0, [sp, #12] // load round
    bl mult72 // get starting offset from Randomness array given the current round  
    mov r11, r0
    //lsl r11, r11, 8 
    ldr r0, [sp, #0]
    ldr r1, [sp, #4]
    ldr r2, [r0, #0]

    str r11, [sp, #16] // store starting offset from Randomness array given the current round
    ldr r10, [sp, #8] // load Randomness pt


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////// Remask d value  ////////////////////////////////////////////////
    /////////////////////////////////////////////////////// (d0 + a1 + b1 + c1) ////////////////////////////////////////////////////
    
    /////////////
    ///// d0' = d0 + r1 + r4 + z1 + z0 + z2 + r1 + r4 ///
    /////////////

    // add r1 to d0 //
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 3 r1 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r1
    eor r5, r5, r14 


    // add r4 to d0 //
    add r12, r11, #28
    ldr r14, [r10,r12] // r4
    // ROR 3 r4 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r4
    eor r5, r5, r14 
    
    // add z1 to d0 //
    add r12, r11, #4
    ldr r14, [r10,r12] // z1
    // ROR 3 z1 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with z1
    eor r5, r5, r14 
    
    // add z0 to d0 //
    add r12, r11, #0
    ldr r14, [r10,r12] // z0
    // ROR 3 z0 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with z0
    eor r5, r5, r14 

    // add z2 to d0 //
    add r12, r11, #8
    ldr r14, [r10,r12] // z2
    // ROR 3 z2 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with z2
    eor r5, r5, r14 

    // add r1 to d0 //
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 3 r1 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r1
    eor r5, r5, r14 


    // add r4 to d0 //
    add r12, r11, #28
    ldr r14, [r10,r12] // r4
    // ROR 3 r4 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r4
    eor r5, r5, r14 


    // add z0 to a1 //
    add r12, r11, #0
    ldr r14, [r10,r12] // z0
    // ROR 4 z0 at position of a1
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask a1 with z0
    eor r6, r6, r14 


    // add z1 to b1 //
    add r12, r11, #4
    ldr r14, [r10,r12] // z1
    // ROR 4 z1 at position of b1
    lsl r12, r14, #11
    lsr r14, r14, #5
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask b1 with z1
    eor r7, r7, r14

    // add z2 to c1 //
    add r12, r11, #8
    ldr r14, [r10,r12] // z2
    // ROR 4 z2 at position of c1
    lsl r12, r14, #10
    lsr r14, r14, #6
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask c1 with z2
    eor r8, r8, r14

    mov r14, #0


    /////////////////////////////////////////////////////////
    ///////////// COMPUTE COMMON CROSS PRODUCTS /////////////
    /////////////////////////////////////////////////////////

    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r2, r5 // d0'
    
    mov r3, r6 // a1'

    // ROL 4 a1'
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    mov r4, r7 // b1'
    mov r5, r8 // c1'
    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0

    ldr r6, [r1, #0] // a1
    // ROL 2 a1
    lsr r12, r6, #14
    lsl r6, r6, #2
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    ldr r7, [r1, #12] // d1

    // ROR 4 a1'
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    /////////////////////////////////////////
    /// d'0a1 ///
    /////////////////////////////////////////

    // ROR 5 d'0 
    lsl r12, r2, #11
    lsr r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult d'0a1 //
    and r8, r2, r6

    // mask r8
    add r12, r11, #12
    ldr r14, [r10,r12] // r0 
    // ROR 8 r0 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12
    
    /////////////////////////////////////////
    /// d'0d1 ///
    /////////////////////////////////////////

    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult d'0d1 //
    and r8, r2, r7  


    // mask r8
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 8 r0 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    
    eor r8, r8, r14                

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12
                                    
    // add to sum r9 
    eor r9, r9, r8                  


    // ROL back 5 d'0 
    lsr r12, r2, #11
    lsl r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12
    
    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    /////////////////////////////////////////
    /// a'1a1 ///
    /////////////////////////////////////////

    // ROR 4 a'1 
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult a'1a1 //
    and r8, r3, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    /////////////////////////////////////////
    /// a'1d1 ///
    /////////////////////////////////////////

    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult a'1d1 //
    and r8, r3, r7

    // mask r8
    add r12, r11, #20
    ldr r14, [r10,r12] // r2
    // ROR 8 r1
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    
    eor r8, r8, r14


    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 4 a'1 
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


    /////////////////////////////////////////
    /// b'1a1 ///
    /////////////////////////////////////////

    // ROR 3 b'1 
    lsl r12, r4, #13
    lsr r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12


    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    // mult b'1a1 //
    and r8, r4, r6
    

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    /////////////////////////////////////////
    /// b'1d1 ///
    /////////////////////////////////////////

    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult b'1d1 //
    and r8, r4, r7

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 3 b'1 
    lsr r12, r4, #13
    lsl r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12

    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


    /////////////////////////////////////////
    /// c'1a1 ///
    /////////////////////////////////////////

    // ROR 2 c'1 
    lsl r12, r5, #14
    lsr r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12


    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    // mult c'1a1 //
    and r8, r5, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    /////////////////////////////////////////
    /// c'1d1 ///
    /////////////////////////////////////////


    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult c'1d1 //
    and r8, r5, r7

    // mask r8
    add r12, r11, #24
    ldr r14, [r10,r12] // r3
    // ROR 8 r1
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    
    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // store in stack common SUM cross-prod
    str r9, [sp, #20]


    // ROL back 2 c'1 
    lsr r12, r5, #14
    lsl r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12


    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// Compute *bd* specific part ///////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    mov r6, #0
    mov r7, #0
    ldr r6, [r0, #4]
    ldr r7, [r1, #8]

    ////////////////////////////////////
    /////////////////////////// d'0b0 //
    ////////////////////////////////////

    // ROR 5 d'0 
    lsl r12, r2, #11
    lsr r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult d'0b0 //
    and r8, r2, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    
    //////////////////////////////////////////////////////
    /////////////////////////// d'0c1 //
    //////////////////////////////////////////////////////

    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult 
    and r8, r2, r7

    // mask r8
    add r12, r11, #28
    ldr r14, [r10,r12] // r4
    // ROR 8 r4
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14


    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 c1 
    lsr r12, r7, #14
    lsl r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL 5 d'0 
    lsr r12, r2, #11
    lsl r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    //////////////////////////////////////////////////////
    /////////////////////////// a'1b0 //
    //////////////////////////////////////////////////////

    // ROR 4 a'1 
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r3, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// a'1c1 //
    //////////////////////////////////////////////////////
    
    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r3, r7

    // mask r8
    add r12, r11, #12
    ldr r14, [r10,r12] // r0 
    // ROR 8 r0 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12


    // add to sum r9 
    eor r9, r9, r8

    // ROL back 2 c1
    lsr r12, r7, #14
    lsl r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 4 a'1 
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1b0 //
    //////////////////////////////////////////////////////


    // ROR 3 b'1 
    lsl r12, r4, #13
    lsr r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12


    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r4, r6


    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1c1 //
    //////////////////////////////////////////////////////

    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r4, r7

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 2 c1 
    lsr r12, r7, #14
    lsl r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 3 b'1 
    lsr r12, r4, #13
    lsl r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12

    //////////////////////////////////////////////////////
    /////////////////////////// c'1b0 //
    //////////////////////////////////////////////////////

    // ROR 2 c'1 
    lsl r12, r5, #14
    lsr r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r5, r6

    // mask r8
    add r12, r11, #20
    ldr r14, [r10,r12] // r2
    // ROR 8 r2 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    //////////////////////////////////////////////////////
    /////////////////////////// c'1c1 //
    //////////////////////////////////////////////////////


    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r5, r7
    
    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 c1 
    lsr r12, r7, #10
    lsl r7, r7, #6
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


   // ROL back 2 c'1 
    lsr r12, r5, #14
    lsl r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    ldr r8, [r0, #0] // load a0

    // ROR 9 r8
    lsl r12, r8, #7
    lsr r8, r8, #9
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add sum to r9
    eor r9, r9, r8

    // mask r9
    add r12, r11, #12
    ldr r14, [r10,r12] // r0
    // ROR 9 r0 
    lsl r12, r14, #7
    lsr r14, r14, #9
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r9, r9, r14 /////// 


    // ROL back 9 a0+bd 
    lsr r12, r9, #7
    lsl r9, r9, #9
    eor r9, r9, r12
    mov r12, 0xFFFF
    and r9, r9, r12

    
    str r9, [r0, #0] // update: a0 is now a0 + bd + r...

    mov r6, 0
    mov r7, 0
    mov r8, 0
    mov r9, 0


    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// Compute *cd* specific part /////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    // load common sum cross-prod
    ldr r9, [sp, #20]
    ldr r6, [r0, #8] // c0
    ldr r7, [r1, #4] // b1


    //////////////////////////////////////////////////////
    /////////////////////////// d'0c0 //
    //////////////////////////////////////////////////////

    // ROR 5 d'0 
    lsl r12, r2, #11
    lsr r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult d'0c0 //
    and r8, r2, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// d'0b1 //
    //////////////////////////////////////////////////////

    // ROR 3 b1 
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult 
    and r8, r2, r7

    // mask r8
    add r12, r11, #32
    ldr r14, [r10,r12] // r5
    // ROR 8 r5
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 3 b1 
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL 5 d'0 
    lsr r12, r2, #11
    lsl r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    
    //////////////////////////////////////////////////////
    /////////////////////////// a'1c0 //
    //////////////////////////////////////////////////////

    // ROR 4 a'1 
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult 
    and r8, r3, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// a'1b1 //
    //////////////////////////////////////////////////////
    
    // ROR 3 b1
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r3, r7

    // mask r8
    add r12, r11, #20
    ldr r14, [r10,r12] // r2 
    // ROR 8 r2
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 3 b1
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 4 a'1 
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1c0 //
    //////////////////////////////////////////////////////

    // ROR 3 b'1 
    lsl r12, r4, #13
    lsr r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12


    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r4, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1b1 //
    //////////////////////////////////////////////////////

    // ROR 3 b1 
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r4, r7

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 3 b1 
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 3 b'1 
    lsr r12, r4, #13
    lsl r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12

    //////////////////////////////////////////////////////
    /////////////////////////// c'1c0 //
    //////////////////////////////////////////////////////

    // ROR 2 c'1 
    lsl r12, r5, #14
    lsr r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r5, r6

    // mask r8
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 8 r1
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// c'1b1 //
    //////////////////////////////////////////////////////


    // ROR 3 b1 
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r5, r7
    
    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 3 b1 
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


   // ROL back 2 c'1 
    lsr r12, r5, #14
    lsl r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    // load b0
    ldr r8, [r0, #4]

    // ROR 8 r8
    lsl r12, r8, #8
    lsr r8, r8, #8
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add sum to r8
    eor r9, r9, r8 

    // ROL back 8 r9
    lsr r12, r9, #8
    lsl r9, r9, #8
    eor r9, r9, r12
    mov r12, 0xFFFF
    and r9, r9, r12

    
    str r9, [r0, #4] // update: b0 is now b0 + cd + r...

    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0

    mov r6, 0
    mov r7, 0
    mov r8, 0
    mov r9, 0

    //A2 taken into account 


    ldr r2, [r0, #12] // d0
    // ROR 7 d0
    lsl r12, r2, #9
    lsr r2, r2, #7
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    ldr r3, [r0, #8] // c0
    ldr r4, [r0, #4] // b0
    // ROR 7 b0 at index 8
    lsl r12, r4, #9
    lsr r4, r4, #7
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12

    // ROL 1 c0
    lsr r12, r3, #15
    lsl r3, r3, #1
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROL 6 b0
    lsr r12, r4, #10
    lsl r4, r4, #6
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12
    
    ldr r5, [r0, #0] // a0
    
    // ROR 3 a0
    lsl r12, r5, #13
    lsr r5, r5, #3
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    // ROL back 10 d0
    lsr r12, r2, #6
    lsl r2, r2, #10
    eor r2, r2, r12
    mov r12, 0xFFFF 
    and r2, r2, r12

    ////////////////////////////////// shares 1

    ldr r6, [r1, #12] // d1

    // ROR 3 d1 at index 10
    lsl r12, r6, #13
    lsr r6, r6, #3
    eor r6, r6, r12
    mov r12, 0xFFFF 
    and r6, r6, r12

    ldr r7, [r1, #8] // c1
    ldr r8, [r1, #4] // b1
    // ROR 3 b1
    lsl r12, r8, #13
    lsr r8, r8, #3
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // ROL back 1 c1
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF 
    and r7, r7, r12

    // ROL back 2 b1
    lsr r12, r8, #14
    lsl r8, r8, #2
    eor r8, r8, r12
    mov r12, 0xFFFF 
    and r8, r8, r12


    ldr r9, [r1, #0] // a1
    // ROR 3 a1
    lsl r12, r9, #13
    lsr r9, r9, #3
    eor r9, r9, r12
    mov r12, 0xFFFF
    and r9, r9, r12

    // ROL back 6 d1
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF 
    and r6, r6, r12
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////// Apply correction terms ///////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////
    //////////////////////////////////  c0 + r0
    //////////////////////////////////
    add r12, r11, #12
    ldr r14, [r10,r12] // r0


    // ROR 1 r0
    lsl r12, r14, #15
    lsr r14, r14, #1
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r3, r3, r14 // mask c0

    //////////////////////////////////
    //////////////////////////////////  c0 + r5
    //////////////////////////////////
    add r12, r11, #32
    ldr r14, [r10,r12] // r0

    // ROR 1 r5 
    lsl r12, r14, #15
    lsr r14, r14, #1
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r3, r3, r14 // mask c0

    //////////////////////////////////
    //////////////////////////////////  d0 + r1
    //////////////////////////////////
    add r12, r11, #16
    ldr r14, [r10,r12] // r1

    eor r2, r2, r14 // mask d0

    //////////////////////////////////
    //////////////////////////////////  a1 + r1
    //////////////////////////////////

    // ROR 7 r1
    lsl r12, r14, #9
    lsr r14, r14, #7
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r9, r9, r14 // mask a1
    
    //////////////////////////////////
    //////////////////////////////////  a1 + r3
    //////////////////////////////////
    add r12, r11, #24
    ldr r14, [r10,r12] // r3

    // ROR 7 r3
    lsl r12, r14, #9
    lsr r14, r14, #7
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r9, r9, r14 // mask a1


    //////////////////////////////////
    //////////////////////////////////  b1 + r5
    //////////////////////////////////
    add r12, r11, #32
    ldr r14, [r10,r12] // r5

    // ROR 6 r5
    lsl r12, r14, #10
    lsr r14, r14, #6
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14 // mask b1

    //////////////////////////////////
    //////////////////////////////////  b1 + r4
    //////////////////////////////////
    add r12, r11, #28
    ldr r14, [r10,r12] // r4

    // ROR 6 r4
    lsl r12, r14, #10
    lsr r14, r14, #6
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14 // mask b1

    //////////////////////////////////
    //////////////////////////////////  b1 + r3
    //////////////////////////////////
    add r12, r11, #24
    ldr r14, [r10,r12] // r3

    // ROR 6 r3
    lsl r12, r14, #10
    lsr r14, r14, #6
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14 // mask b1


    //////////////////////////////////
    //////////////////////////////////  c1 + r4
    //////////////////////////////////
    add r12, r11, #28
    ldr r14, [r10,r12] // r4

    // ROR 5 r4
    lsl r12, r14, #11
    lsr r14, r14, #5
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r7, r7, r14 // mask c1   

    //////////////////////////////////
    //////////////////////////////////  c1 + r5
    //////////////////////////////////
    add r12, r11, #32
    ldr r14, [r10,r12] // r5

    // ROR 5 r5
    lsl r12, r14, #11
    lsr r14, r14, #5
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r7, r7, r14 // mask c1   


    //////////////////////////////////
    //////////////////////////////////  d1 + r0
    //////////////////////////////////
    add r12, r11, #12
    ldr r14, [r10,r12] // r0

    // ROR 5 r0
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r6, r6, r14 // mask d1   


    //////////////////////////////////
    //////////////////////////////////  d1 + r4
    //////////////////////////////////
    add r12, r11, #28
    ldr r14, [r10,r12] // r4

    // ROR 5 r4
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r6, r6, r14 // mask d1   


    //////////////////////////////////
    //////////////////////////////////  d1 + r1
    //////////////////////////////////
    add r12, r11, #16
    ldr r14, [r10,r12] // r1

    // ROR 5 r1
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r6, r6, r14 // mask d1   

    // STORE RESULT
    str r2, [r0, #0]
    str r3, [r0, #4]
    str r4, [r0, #8]
    str r5, [r0, #12]

    str r6, [r1, #0]
    str r7, [r1, #4]
    str r8, [r1, #8]
    str r9, [r1, #12]






    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////// COMPUTE SECOND Q_294 (a, b, c, d) -> (a + bd, b + cd, c, d)  ///////////////////////////////////
    /////////////////////////////////////////////////// (b0 + a1 + c1 + d1)(d0 + a1 + b1 + c1) and (c0 + a1 + b1 + d1)(d0 + a1 + b1 + c1) //////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    
    ldr r10, [sp, #8] // load Randomness pt
    ldr r11, [sp, #16] // store starting offset from Randomness array given the current round
    add r11, r11, #36



    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////// Remask d value  ////////////////////////////////////////////////
    /////////////////////////////////////////////////////// (d0 + a1 + b1 + c1) ////////////////////////////////////////////////////

    /////////////
    ///// d0' = d0 + r1 + r4 + z1 + z0 + z2 + r1 + r4 ///
    /////////////

    // add r1 to d0 //
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 3 r1 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r1
    eor r5, r5, r14 


    // add r4 to d0 //
    add r12, r11, #28
    ldr r14, [r10,r12] // r4
    // ROR 3 r4 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r4
    eor r5, r5, r14 
    
    // add z1 to d0 //
    add r12, r11, #4
    ldr r14, [r10,r12] // z1
    // ROR 3 z1 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with z1
    eor r5, r5, r14 
    
    // add z0 to d0 //
    add r12, r11, #0
    ldr r14, [r10,r12] // z0
    // ROR 3 z0 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with z0
    eor r5, r5, r14 

    // add z2 to d0 //
    add r12, r11, #8
    ldr r14, [r10,r12] // z2
    // ROR 3 z2 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with z2
    eor r5, r5, r14 

    // add r1 to d0 //
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 3 r1 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r1
    eor r5, r5, r14 


    // add r4 to d0 //
    add r12, r11, #28
    ldr r14, [r10,r12] // r4
    // ROR 3 r4 at position of d0
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask d0 with r4
    eor r5, r5, r14 


    // add z0 to a1 //
    add r12, r11, #0
    ldr r14, [r10,r12] // z0
    // ROR 4 z0 at position of a1
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask a1 with z0
    eor r6, r6, r14 


    // add z1 to b1 //
    add r12, r11, #4
    ldr r14, [r10,r12] // z1
    // ROR 4 z1 at position of b1
    lsl r12, r14, #11
    lsr r14, r14, #5
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask b1 with z1
    eor r7, r7, r14

    // add z2 to c1 //
    add r12, r11, #8
    ldr r14, [r10,r12] // z2
    // ROR 4 z2 at position of c1
    lsl r12, r14, #10
    lsr r14, r14, #6
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    // remask c1 with z2
    eor r8, r8, r14

    mov r14, #0


    /////////////////////////////////////////////////////////
    ///////////// COMPUTE COMMON CROSS PRODUCTS /////////////
    /////////////////////////////////////////////////////////

    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r2, r5 // d0'
    
    mov r3, r6 // a1'

    // ROL 4 a1'
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    mov r4, r7 // b1'
    mov r5, r8 // c1'
    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0

    ldr r6, [r1, #0] // a1
    // ROL 2 a1
    lsr r12, r6, #14
    lsl r6, r6, #2
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    ldr r7, [r1, #12] // d1

    // ROR 4 a1'
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    /////////////////////////////////////////
    /// d'0a1 ///
    /////////////////////////////////////////

    // ROR 5 d'0 
    lsl r12, r2, #11
    lsr r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult d'0a1 //
    and r8, r2, r6

    // mask r8
    add r12, r11, #12
    ldr r14, [r10,r12] // r0 
    // ROR 8 r0 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12
    
    /////////////////////////////////////////
    /// d'0d1 ///
    /////////////////////////////////////////

    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult d'0d1 //
    and r8, r2, r7  


    // mask r8
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 8 r0 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    
    eor r8, r8, r14                

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12
                                    
    // add to sum r9 
    eor r9, r9, r8                  


    // ROL back 5 d'0 
    lsr r12, r2, #11
    lsl r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12
    
    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    /////////////////////////////////////////
    /// a'1a1 ///
    /////////////////////////////////////////

    // ROR 4 a'1 
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult a'1a1 //
    and r8, r3, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    /////////////////////////////////////////
    /// a'1d1 ///
    /////////////////////////////////////////

    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult a'1d1 //
    and r8, r3, r7

    // mask r8
    add r12, r11, #20
    ldr r14, [r10,r12] // r2
    // ROR 8 r1
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    
    eor r8, r8, r14


    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 4 a'1 
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


    /////////////////////////////////////////
    /// b'1a1 ///
    /////////////////////////////////////////

    // ROR 3 b'1 
    lsl r12, r4, #13
    lsr r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12


    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    // mult b'1a1 //
    and r8, r4, r6
    

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    /////////////////////////////////////////
    /// b'1d1 ///
    /////////////////////////////////////////

    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult b'1d1 //
    and r8, r4, r7

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 3 b'1 
    lsr r12, r4, #13
    lsl r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12

    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


    /////////////////////////////////////////
    /// c'1a1 ///
    /////////////////////////////////////////

    // ROR 2 c'1 
    lsl r12, r5, #14
    lsr r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12


    // ROR 6 a1 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    // mult c'1a1 //
    and r8, r5, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 a1 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    /////////////////////////////////////////
    /// c'1d1 ///
    /////////////////////////////////////////


    // ROR 1 d1 
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult c'1d1 //
    and r8, r5, r7

    // mask r8
    add r12, r11, #24
    ldr r14, [r10,r12] // r3
    // ROR 8 r1
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12
    
    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // store in stack common SUM cross-prod
    str r9, [sp, #20]


    // ROL back 2 c'1 
    lsr r12, r5, #14
    lsl r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12


    // ROL back 1 d1 
    lsr r12, r7, #15
    lsl r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// Compute *bd* specific part ///////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    mov r6, #0
    mov r7, #0
    ldr r6, [r0, #4]
    ldr r7, [r1, #8]

    ////////////////////////////////////
    /////////////////////////// d'0b0 //
    ////////////////////////////////////

    // ROR 5 d'0 
    lsl r12, r2, #11
    lsr r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult d'0b0 //
    and r8, r2, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    
    //////////////////////////////////////////////////////
    /////////////////////////// d'0c1 //
    //////////////////////////////////////////////////////

    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult 
    and r8, r2, r7

    // mask r8
    add r12, r11, #28
    ldr r14, [r10,r12] // r4
    // ROR 8 r4
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14


    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 c1 
    lsr r12, r7, #14
    lsl r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL 5 d'0 
    lsr r12, r2, #11
    lsl r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    //////////////////////////////////////////////////////
    /////////////////////////// a'1b0 //
    //////////////////////////////////////////////////////

    // ROR 4 a'1 
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r3, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// a'1c1 //
    //////////////////////////////////////////////////////
    
    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r3, r7

    // mask r8
    add r12, r11, #12
    ldr r14, [r10,r12] // r0 
    // ROR 8 r0 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12


    // add to sum r9 
    eor r9, r9, r8

    // ROL back 2 c1
    lsr r12, r7, #14
    lsl r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 4 a'1 
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1b0 //
    //////////////////////////////////////////////////////


    // ROR 3 b'1 
    lsl r12, r4, #13
    lsr r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12


    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r4, r6


    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1c1 //
    //////////////////////////////////////////////////////

    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r4, r7

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 2 c1 
    lsr r12, r7, #14
    lsl r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 3 b'1 
    lsr r12, r4, #13
    lsl r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12

    //////////////////////////////////////////////////////
    /////////////////////////// c'1b0 //
    //////////////////////////////////////////////////////

    // ROR 2 c'1 
    lsl r12, r5, #14
    lsr r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    // ROR 7 b0 
    lsl r12, r6, #9
    lsr r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r5, r6

    // mask r8
    add r12, r11, #20
    ldr r14, [r10,r12] // r2
    // ROR 8 r2 
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 7 b0 
    lsr r12, r6, #9
    lsl r6, r6, #7
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12


    //////////////////////////////////////////////////////
    /////////////////////////// c'1c1 //
    //////////////////////////////////////////////////////


    // ROR 2 c1 
    lsl r12, r7, #14
    lsr r7, r7, #2
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r5, r7
    
    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 c1 
    lsr r12, r7, #10
    lsl r7, r7, #6
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


   // ROL back 2 c'1 
    lsr r12, r5, #14
    lsl r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    ldr r8, [r0, #0] // load a0

    // ROR 9 r8
    lsl r12, r8, #7
    lsr r8, r8, #9
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add sum to r9
    eor r9, r9, r8

    // mask r9
    add r12, r11, #12
    ldr r14, [r10,r12] // r0
    // ROR 9 r0 
    lsl r12, r14, #7
    lsr r14, r14, #9
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r9, r9, r14 /////// 


    // ROL back 9 a0+bd 
    lsr r12, r9, #7
    lsl r9, r9, #9
    eor r9, r9, r12
    mov r12, 0xFFFF
    and r9, r9, r12

    
    str r9, [r0, #0] // update: a0 is now a0 + bd + r...

    mov r6, 0
    mov r7, 0
    mov r8, 0
    mov r9, 0


    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// Compute *cd* specific part /////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    // load common sum cross-prod
    ldr r9, [sp, #20]
    ldr r6, [r0, #8] // c0
    ldr r7, [r1, #4] // b1


    //////////////////////////////////////////////////////
    /////////////////////////// d'0c0 //
    //////////////////////////////////////////////////////

    // ROR 5 d'0 
    lsl r12, r2, #11
    lsr r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult d'0c0 //
    and r8, r2, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// d'0b1 //
    //////////////////////////////////////////////////////

    // ROR 3 b1 
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult 
    and r8, r2, r7

    // mask r8
    add r12, r11, #32
    ldr r14, [r10,r12] // r5
    // ROR 8 r5
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 3 b1 
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL 5 d'0 
    lsr r12, r2, #11
    lsl r2, r2, #5
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    
    //////////////////////////////////////////////////////
    /////////////////////////// a'1c0 //
    //////////////////////////////////////////////////////

    // ROR 4 a'1 
    lsl r12, r3, #12
    lsr r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult 
    and r8, r3, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// a'1b1 //
    //////////////////////////////////////////////////////
    
    // ROR 3 b1
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r3, r7

    // mask r8
    add r12, r11, #20
    ldr r14, [r10,r12] // r2 
    // ROR 8 r2
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 3 b1
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 4 a'1 
    lsr r12, r3, #12
    lsl r3, r3, #4
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1c0 //
    //////////////////////////////////////////////////////

    // ROR 3 b'1 
    lsl r12, r4, #13
    lsr r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12


    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r4, r6

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// b'1b1 //
    //////////////////////////////////////////////////////

    // ROR 3 b1 
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r4, r7

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 3 b1 
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL back 3 b'1 
    lsr r12, r4, #13
    lsl r4, r4, #3
    eor r4, r4, r12
    mov r12, 0xFFFF
    and r4, r4, r12

    //////////////////////////////////////////////////////
    /////////////////////////// c'1c0 //
    //////////////////////////////////////////////////////

    // ROR 2 c'1 
    lsl r12, r5, #14
    lsr r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    // ROR 6 c0 
    lsl r12, r6, #10
    lsr r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    // mult
    and r8, r5, r6

    // mask r8
    add r12, r11, #16
    ldr r14, [r10,r12] // r1
    // ROR 8 r1
    lsl r12, r14, #8
    lsr r14, r14, #8
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14

    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8


    // ROL back 6 c0 
    lsr r12, r6, #10
    lsl r6, r6, #6
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    //////////////////////////////////////////////////////
    /////////////////////////// c'1b1 //
    //////////////////////////////////////////////////////


    // ROR 3 b1 
    lsl r12, r7, #13
    lsr r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // mult
    and r8, r5, r7
    
    // ROR 1 r8
    lsl r12, r8, #15
    lsr r8, r8, #1
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add to sum r9 
    eor r9, r9, r8

    // ROL back 3 b1 
    lsr r12, r7, #13
    lsl r7, r7, #3
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12


   // ROL back 2 c'1 
    lsr r12, r5, #14
    lsl r5, r5, #2
    eor r5, r5, r12
    mov r12, 0xFFFF
    and r5, r5, r12

    // load b0
    ldr r8, [r0, #4]

    // ROR 8 r8
    lsl r12, r8, #8
    lsr r8, r8, #8
    eor r8, r8, r12
    mov r12, 0xFFFF
    and r8, r8, r12

    // add sum to r8
    eor r9, r9, r8 

    // ROL back 8 r9
    lsr r12, r9, #8
    lsl r9, r9, #8
    eor r9, r9, r12
    mov r12, 0xFFFF
    and r9, r9, r12

    
    str r9, [r0, #4] // update: b0 is now b0 + cd + r...

    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0

    mov r6, 0
    mov r7, 0
    mov r8, 0
    mov r9, 0
    

    //A3 taken into account 

    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    ///////// PLACE IT AS IN A3 ////////
    //////////////////////////////////////////////////////////////////////////////////////////  
    //////////////////////////////////////////////////////////////////////////////////////////

    ///////////// a0 /////////////

    ldr r3, [r0, #0] // a0
    // ROR 9 a0
    lsl r12, r3, #7
    lsr r3, r3, #9
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    ldr r2, [r0, #4] // b0
    // ROL 1 b0
    lsr r12, r2, #15
    lsl r2, r2, #1
    eor r2, r2, r12
    mov r12, 0xFFFF
    and r2, r2, r12

    // ROL 8 a0
    lsr r12, r3, #8
    lsl r3, r3, #8
    eor r3, r3, r12
    mov r12, 0xFFFF
    and r3, r3, r12

    ldr r4, [r0, #8] // c0

    ldr r5, [r0, #12] // d0


    ///////////// b1 /////////////

    ldr r6, [r1, #4] // b1

    // ROR 3 b1
    lsl r12, r6, #13
    lsr r6, r6, #3
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    ldr r7, [r1, #0] // a1
    // ROR 1 a1
    lsl r12, r7, #15
    lsr r7, r7, #1
    eor r7, r7, r12
    mov r12, 0xFFFF
    and r7, r7, r12

    // ROL 4 b1
    lsr r12, r6, #12
    lsl r6, r6, #4
    eor r6, r6, r12
    mov r12, 0xFFFF
    and r6, r6, r12

    ldr r8, [r1, #8] // c1

    ldr r9, [r1, #12] // d1


    mov r14, 0xFFFF
    eor r2, r2, r14
    eor r3, r3, r14
    eor r4, r4, r14
    eor r5, r5, r14

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////// Apply correction terms ///////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////
    //////////////////////////////////  c0 + r0
    //////////////////////////////////
    add r12, r11, #12
    ldr r14, [r10,r12] // r0


    // ROR 2 r0
    lsl r12, r14, #14
    lsr r14, r14, #2
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r4, r4, r14 // mask c0

    //////////////////////////////////
    //////////////////////////////////  c0 + r5
    //////////////////////////////////
    add r12, r11, #32
    ldr r14, [r10,r12] // r0

    // ROR 2 r5 
    lsl r12, r14, #14
    lsr r14, r14, #2
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r4, r4, r14 // mask c0

    //////////////////////////////////
    //////////////////////////////////  d0 + r1
    //////////////////////////////////
    add r12, r11, #16
    ldr r14, [r10,r12] // r1

    // ROR 3 r1
    lsl r12, r14, #13
    lsr r14, r14, #3
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r5, r5, r14 // mask d0

    //////////////////////////////////
    //////////////////////////////////  a1 + r1
    //////////////////////////////////

    // ROR 2 r1
    lsl r12, r14, #14
    lsr r14, r14, #2
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r7, r7, r14 // mask a1
    
    //////////////////////////////////
    //////////////////////////////////  a1 + r3
    //////////////////////////////////
    add r12, r11, #24
    ldr r14, [r10,r12] // r3

    // ROR 5 r3
    lsl r12, r14, #11
    lsr r14, r14, #5
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r7, r7, r14 // mask a1


    //////////////////////////////////
    //////////////////////////////////  b1 + r5
    //////////////////////////////////
    add r12, r11, #32
    ldr r14, [r10,r12] // r5

    // ROR 4 r5
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r6, r6, r14 // mask b1

    //////////////////////////////////
    //////////////////////////////////  b1 + r4
    //////////////////////////////////
    add r12, r11, #28
    ldr r14, [r10,r12] // r4

    // ROR 4 r4
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r6, r6, r14 // mask b1

    //////////////////////////////////
    //////////////////////////////////  b1 + r3
    //////////////////////////////////
    add r12, r11, #24
    ldr r14, [r10,r12] // r3

    // ROR 4 r3
    lsl r12, r14, #12
    lsr r14, r14, #4
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r6, r6, r14 // mask b1


    //////////////////////////////////
    //////////////////////////////////  c1 + r4
    //////////////////////////////////
    add r12, r11, #28
    ldr r14, [r10,r12] // r4

    // ROR 6 r4
    lsl r12, r14, #10
    lsr r14, r14, #6
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14 // mask c1   

    //////////////////////////////////
    //////////////////////////////////  c1 + r5
    //////////////////////////////////
    add r12, r11, #32
    ldr r14, [r10,r12] // r5

    // ROR 6 r5
    lsl r12, r14, #10
    lsr r14, r14, #6
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r8, r8, r14 // mask c1   


    //////////////////////////////////
    //////////////////////////////////  d1 + r0
    //////////////////////////////////
    add r12, r11, #12
    ldr r14, [r10,r12] // r0

    // ROR 7 r0
    lsl r12, r14, #9
    lsr r14, r14, #7
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r9, r9, r14 // mask d1   


    //////////////////////////////////
    //////////////////////////////////  d1 + r4
    //////////////////////////////////
    add r12, r11, #28
    ldr r14, [r10,r12] // r4

    // ROR 7 r4
    lsl r12, r14, #9
    lsr r14, r14, #7
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r9, r9, r14 // mask d1   


    //////////////////////////////////
    //////////////////////////////////  d1 + r1
    //////////////////////////////////
    add r12, r11, #16
    ldr r14, [r10,r12] // r1

    // ROR 7 r1
    lsl r12, r14, #9
    lsr r14, r14, #7
    eor r14, r14, r12
    mov r12, 0xFFFF
    and r14, r14, r12

    eor r9, r9, r14 // mask d1   

    // STORE RESULT
    str r2, [r0, #0]
    str r3, [r0, #4]
    str r4, [r0, #8]
    str r5, [r0, #12]

    str r6, [r1, #0]
    str r7, [r1, #4]
    str r8, [r1, #8]
    str r9, [r1, #12]


    // END OF CODE
    add sp, sp, #(4 * 100)
    pop {r4-r11,r14}
    bx lr
