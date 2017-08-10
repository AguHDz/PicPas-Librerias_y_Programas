// CONFIGURATION WORD PIC16F72

// =======================================
// BOREN : Brown-out Reset Enable bit.
// Enable BOREN automatically enable PWRTEN, regardless of the
// value of bit PWRTEN. Ensure the PWRTEN is enable any time
// BOREN is enable.
{$define _BOR_ON      =     $3FBF}
{$define _BOR_OFF     =     $3FFF}
// CP : FLASH Program Memory Code Protection bit.
{$define _CP_ON       =     $3FEF}
{$define _CP_OFF      =     $3FFF}
// /PWRTEN : Power-up Timer Enable bit.
{$define _PWRT_ON     =     $3FF7}
{$define _PWRT_OFF    =     $3FFF}
// WDTEN : Watchdog Timer Eneble bit.
{$define _WDT_ON      =     $3FFF}
{$define _WDT_OFF     =     $3FFB}
// FOSC1:FOSC2 : Oscilator Seleccion bits.
{$define _LP_OSC      =     $3FFC}
{$define _XT_OSC      =     $3FFD}
{$define _HS_OSC      =     $3FFE}
{$define _RC_OSC      =     $3FFF}
// =======================================
// The erased (unprogrammed) value of the configuration word is 3FFFFh.
// Configuration Word Address : 2007h.