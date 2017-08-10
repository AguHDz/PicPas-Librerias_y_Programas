// CONFIGURATION WORD PIC16F87XA
// PIC16F873A
// PIC16F874A
// PIC16F876A
// PIC16F877A

// =======================================
// CP : FLASH Program Memory Code Protection bit.
{$define _CP_ON       =     $1FFF}
{$define _CP_OFF      =     $3FFF}
// DEBUG : In-Circuit Debugger Mode bit
// RB6-RB7 are dedicaded to the debugger.
{$define _DEBUG_ON    =     $2FFF}
{$define _DEBUG_OFF   =     $3FFF}
// WRT1:WRT0 : Flash Program Memory Write Enable bits.
{$define _WRT_OFF     =     $3FFF}
{$define _WRT01_ON    =     $3DFF}
{$define _WRT10_ON    =     $3BFF}
{$define _WRT00_ON    =     $39FF}
// CPD : Data EEPROM Memory Code Protection bit.
{$define _CPD_ON      =     $3F3F}
{$define _CPD_OFF     =     $3FFF}
// LVP : Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit.
{$define _LVP_ON      =     $3FFF}
{$define _LVP_OFF     =     $3FBF}
// BOREN : Brown-out Reset Enable bit.
// Enable BOREN automatically enable PWRTEN, regardless of the
// value of bit PWRTEN. Ensure the PWRTEN is enable any time
// BOREN is enable.
{$define _BOR_ON      =     $3FDF}
{$define _BOR_OFF     =     $3FFF}
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