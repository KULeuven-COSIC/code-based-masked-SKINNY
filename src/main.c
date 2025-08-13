//////////////////////////////////////////////////////////////////////////////
//////////////////// BITSLICE SKINNY-64-64, N = 2, K = 4 /////////////////////
//////////////////////////////////////////////////////////////////////////////

#include "../common/stm32wrapper.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define NBR_ROUND 32
#define NBR_RAND 18
#define TOTAL_RAND NBR_ROUND*NBR_RAND


#define n 2
typedef unsigned char uint8;

/*********************************************************************
* Assembly functions
*/
extern void skinny_assembly(void * shares0,void * shares1, void * BS_RK_0,void * BS_RK_1, void * randomness);

/*********************************************************************
* Protypes
*/
uint8 get_rand_byte(); 
void tweakeyExpansion(uint8 *key,uint8 *w); 
void encodeState(uint8 * pt_state, uint8 * shares0,uint8 * shares1); 
void decodeState( uint8 * pt_out, uint8 * shares0, uint8 * shares1); 
void tweakeyexpansion_share(uint8 key[16],uint8 shares0[512], uint8 shares1[512]); 
void maskedRoundKeyToBS(uint32_t BS_RK_0[64], uint32_t BS_RK_1[64], uint8 shares0[512], uint8 shares1[512]); 
void maskedInputToBS(uint8 shares0[16], uint8 shares1[16], uint32_t BS_shares0[16], uint32_t BS_shares1[16]); 
uint8 gf16MultiplyMat(uint8 M[4][4], uint8 x ); 
void dotMatVec(uint8 r[4],uint8 M[4][4],uint8 v[4]);
uint8 binaryArrayToInt(uint8 binaryArray[4]);
uint32_t ROR16(uint32_t a, int offset);
uint32_t ROL16(uint32_t a, int offset);


/*********************************************************************
* Global variables
*/
const static uint8 Logtable[16] = {0, 15, 1, 4, 2, 8, 5, 10, 3, 14, 9, 7, 6, 13, 11, 12};
const static uint8 Alogtable[16] = {1, 2, 4, 8, 3, 6, 12, 11, 5, 10, 7, 14, 15, 13, 9, 1};
uint8 key[16] =  {0xa,0xa,0xb,0xb,0xc,0xc,0xd,0xd,0x1,0x1,0x4,0x4,0x8,0x8,0xe,0xe};
uint8 pt_state[16] = {0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xA,0xB,0xC,0xD,0xE,0xF};

const uint8 k = 4;
uint8 pt_out[16];
uint8 L[2][4][4];



/*********************************************************************
* Helper functions
*/
uint32_t ROR16(uint32_t a, int offset){
    uint16_t  r0 = ((((uint16_t)a) >> offset));
    uint16_t  r1 = ((((uint16_t)a) << (16-offset)));
    uint32_t ror = r0^r1;
    return ror;
}


uint32_t ROL16(uint32_t a, int offset){
    uint16_t  r0 = ((((uint16_t)a) << offset));
    uint16_t  r1 = ((((uint16_t)a) >> (16-offset)));
    uint32_t rol = r0^r1;
    return rol;
}

void tweakeyExpansion(uint8 *key,uint8 *w)
{
    uint8 pt_idx[16] = {9,15,8,13,10,14,12,11,0,1,2,3,4,5,6,7};

    for(int i=0;i<16;i++){
        w[i]=key[i];
    }

    for(int i=1;i<32;i++)
    {
        uint8 tmpKey[16];
        for (int j = 0; j < 16; ++j) {
            tmpKey[j] = w[(i-1)*16 + j];
        }
        for (int j = 0; j < 16; ++j) {
            w[i*16 + j] = tmpKey[pt_idx[j]];
        }
    }
}


void tweakeyexpansion_share(uint8 key[16],uint8 shares0[512], uint8 shares1[512])
{

    uint8 w[512];
    tweakeyExpansion(key,w);

    for(int i=0;i<512;i++)
    {      
        uint8 tmp = get_rand_byte();
        shares1[i] = tmp;
        tmp = gf16MultiplyMat(L[1], tmp);
        shares0[i] = w[i] ^ tmp;

    }
}

uint32_t getRand(){
    return rng_get_random_blocking();
}

uint8 get_rand_byte(){
    
    return getRand() & 0xF; 
}

uint8 gf16MultiplyMat(uint8 M[4][4], uint8 x ){
    uint8 arr[4] = {0,0,0,0};
    uint8 res[4] = {0,0,0,0};
    for (int i = 0; i < 4; ++i) {
        uint8 b = (x >> (3-i)) & 0x1;
        arr[i] = b;
    }
    dotMatVec(res, M,arr);
    uint8 r = binaryArrayToInt(res);
    return r;
}

void dotMatVec(uint8 r[4],uint8 M[4][4],uint8 v[4]){
    for (int i = 0; i < 4; ++i) {
        r[i] = 0;
        for (int j = 0; j < 4; ++j) {
            r[i] =  r[i] + M[i][j]*v[j];
        }
        r[i] = r[i] % 2;
    }
}



uint8 binaryArrayToInt(uint8 binaryArray[4]){
    uint8 r = 0;
    for (int i = 0; i <4 ; ++i) {
        r |= binaryArray[3-i] << i ;
    }
    return r;
}


void encodeState(uint8 * pt_state, uint8 * shares0, uint8 * shares1){
    uint8 tmp;
    uint8 res_mul;
    for(int i = 0; i< 16; i++){
        tmp = get_rand_byte();
        
        shares1[i] = tmp;

        res_mul = gf16MultiplyMat(L[1], tmp);
        shares0[i] = pt_state[i] ^ res_mul;
    }
}

void decodeState(uint8 * pt_out, uint8 * shares0, uint8 * shares1){
    uint8 tmp;
    for(int i = 0; i< 16; i++){
        tmp = gf16MultiplyMat(L[1], shares1[i]);
        pt_out[i] = shares0[i] ^ tmp;
    }
}

void maskedRoundKeyToBS(uint32_t BS_RK_0[64], uint32_t BS_RK_1[64], uint8 shares0[512], uint8 shares1[512]){
    uint8 kk = 0;
    for (int i = 0; i <32; ++i) {

        uint32_t A_0 = 0;
        uint32_t B_0 = 0;
        uint32_t C_0 = 0;
        uint32_t D_0 = 0;
        uint32_t res0 = 0;

        uint32_t A_1 = 0;
        uint32_t B_1 = 0;
        uint32_t C_1 = 0;
        uint32_t D_1 = 0;
        uint32_t res1 = 0;

        uint8 val0;
        uint8 val1;
        uint8 a, a1;
        uint8 b, b1;
        uint8 c, c1;
        uint8 d, d1;


        for (int j = 0; j < 8; ++j) {
            // Share 0
            val0 = shares0[i*16 + j];

            a = val0 & 0x1;
            a = a << j;
            A_0 = A_0 ^ a;

            b = (val0 >> 1) & 0x1;
            b = b << j;
            B_0 = B_0 ^ b;

            c = (val0 >> 2) & 0x1;
            c = c << j;
            C_0 = C_0 ^ c;

            d = (val0 >> 3) & 0x1;
            d = d << j;
            D_0 = D_0 ^ d;


            // Share 1
            val1 = shares1[i*16 + j];

            a1 = val1 & 0x1;
            a1 = a1 << j;
            A_1 = A_1 ^ a1;

            b1 = (val1 >> 1) & 0x1;
            b1 = b1 << j;
            B_1 = B_1 ^ b1;

            c1 = (val1 >> 2) & 0x1;
            c1 = c1 << j;
            C_1 = C_1 ^ c1;

            d1 = (val1 >> 3) & 0x1;
            d1 = d1 << j;
            D_1 = D_1 ^ d1;
        }

        //A_0 = ROR16(A_0,0);
        B_0 = ROR16(B_0,1);
        C_0 = ROR16(C_0,2);
        D_0 = ROR16(D_0,3);
        A_1 = ROR16(A_1,4);
        B_1 = ROR16(B_1,5);
        C_1 = ROR16(C_1,6);
        D_1 = ROR16(D_1,7);


        res0 = res0 ^ B_0;
        res0 = res0 << 16;
        res0 = res0 ^ A_0;
        BS_RK_0[2*i] = res0;
        res0 = 0;
        res0 = res0 ^ D_0;
        res0 = res0 << 16;
        res0 = res0 ^ C_0;
        BS_RK_0[2*i+1] = res0;

        res1 = res1 ^ B_1;
        res1 = res1 << 16;
        res1 = res1 ^ A_1;
        BS_RK_1[2*i] = res1;
        res1 = 0;
        res1 = res1 ^ D_1;
        res1 = res1 << 16;
        res1 = res1 ^ C_1;
        BS_RK_1[2*i+1] = res1; 
    }
}


void maskedInputToBS(uint8 shares0[16], uint8 shares1[16], uint32_t BS_shares0[16], uint32_t BS_shares1[16])
{
    uint32_t A_0 = 0;
    uint32_t B_0 = 0;
    uint32_t C_0 = 0;
    uint32_t D_0 = 0;


    uint32_t A_1 = 0;
    uint32_t B_1 = 0;
    uint32_t C_1 = 0;
    uint32_t D_1 = 0;

    uint32_t val0;
    uint32_t a, a1;
    uint32_t b, b1;
    uint32_t c, c1;
    uint32_t d, d1;


    for (int i = 0; i < 16; ++i) {
        // Share 0
        val0 = shares0[i];

        a = val0 & 0x1;
        a = a << i;
        A_0 = A_0 ^ a;

        b = (val0 >> 1) & 0x1;
        b = b << i;
        B_0 = B_0 ^ b;

        c = (val0 >> 2) & 0x1;
        c = c << i;
        C_0 = C_0 ^ c;

        d = (val0 >> 3) & 0x1;
        d = d << i;
        D_0 = D_0 ^ d;


        // Share 1
        uint8 val1 = shares1[i];

        a1 = val1 & 0x1;
        a1 = a1 << i;
        A_1 = A_1 ^ a1;

        b1 = (val1 >> 1) & 0x1;
        b1 = b1 << i;
        B_1 = B_1 ^ b1;

        c1 = (val1 >> 2) & 0x1;
        c1 = c1 << i;
        C_1 = C_1 ^ c1;

        d1 = (val1 >> 3) & 0x1;
        d1 = d1 << i;
        D_1 = D_1 ^ d1;
    }
        
    B_0 = ROR16(B_0,1);
    C_0 = ROR16(C_0,2);
    D_0 = ROR16(D_0,3);
    A_1 = ROR16(A_1,4);
    B_1 = ROR16(B_1,5);
    C_1 = ROR16(C_1,6);
    D_1 = ROR16(D_1,7);
    

    BS_shares0[0] = A_0;
    BS_shares0[1] = B_0;
    BS_shares0[2] = C_0;
    BS_shares0[3] = D_0;

    BS_shares1[0] = A_1;
    BS_shares1[1] = B_1;
    BS_shares1[2] = C_1;
    BS_shares1[3] = D_1;
}


uint8 L_bin[4][4] = {
        {0, 1, 1, 1},
        {1, 0, 1, 1},
        {1, 1, 0, 1},
        {1, 1, 1, 0}
};

uint8 L_inv_bin[4][4] = {
        {0, 1, 1, 1},
        {1, 0, 1, 1},
        {1, 1, 0, 1},
        {1, 1, 1, 0}
};

uint8 identity[4][4] = {
        {1, 0, 0, 0},
        {0, 1, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
};


void intToBinaryArray(uint8 value, uint8 binaryArray[4]){
    for (int i = 0; i <=4; i++) {
        binaryArray[3-i] = (value >> i) & 1;
    }
}


int main() {

    uint8 shares0[16];
    uint8 shares1[16];
    uint32_t BS_shares0[16];
    uint32_t BS_shares1[16];

    uint32_t BS_RK_0[64];
    uint32_t BS_RK_1[64];
    uint8 Rk_shares0[512];
    uint8 Rk_shares1[512];

    uint32_t randomness[576]; // 18 * 32

    clock_setup();
    gpio_setup();
    usart_setup(115200);
    flash_setup();

    rng_enable();

  
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) {
            L[0][i][j] = identity[i][j];
            L[1][i][j] = L_bin[i][j];
        }
    }

    for (int i = 0; i < 16; i++) {
        shares0[i] = 0;
        shares1[i] = 0;
    }


  while(1){

    /// read shares 0
    recv_USART_bytes(shares0,16);

    /// read shares 0
    recv_USART_bytes(shares1,16);
    

    // transform shares to Bit-slice representation
    maskedInputToBS(shares0,shares1,BS_shares0,BS_shares1);

        
    // Generate randomness
    for(int i = 0; i < TOTAL_RAND; i++){
        uint32_t tmp = getRand() & 0xFFFF; 
        randomness[i] = tmp;       
        
    }
 
   
    // Generate masked RoundKeys
    tweakeyexpansion_share(key,Rk_shares0, Rk_shares1);
    
    // tansform to Bit-sliced representation
    maskedRoundKeyToBS(BS_RK_0,BS_RK_1 , Rk_shares0, Rk_shares1);                            
             
    skinny_assembly(BS_shares0,BS_shares1, BS_RK_0, BS_RK_1,randomness);
    
    }
        
}
