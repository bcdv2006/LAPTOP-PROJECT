//==========================================================================
// File Name   : SACM_S200_USER.asm
// Description : Users implement functions
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
// Note: 
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
.include GPCE2P064.inc
.include S200.inc


//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_S200_Timer_Setting_X1		C_Timer_Setting_8K
.define C_S200_Timer_Setting_X2		C_Timer_Setting_16K
.define C_S200_Timer_Setting_X4		C_Timer_Setting_32K
.define C_SpeechNumberLength		4	// for skip song number


//**************************************************************************
// Variable Publication Area
//**************************************************************************


//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _USER_S200_SetStartAddr
.public F_USER_S200_SetStartAddr
.public  _USER_S200_SetStartAddr_Con
.public F_USER_S200_SetStartAddr_Con

.public F_USER_S200_GetData
.public  _USER_S200_Volume
.public F_USER_S200_Volume

.public F_SACM_S200_SendDAC1
.public F_SACM_S200_SendDAC2
.public F_SACM_S200_StartPlay
.public F_SACM_S200_EndPlay
.public F_SACM_S200_Init_
.public F_SACM_S200_DAC_Timer_X1
.public F_SACM_S200_DAC_Timer_X2
.public F_SACM_S200_GetStartAddr_Con


//**************************************************************************
// External Function Declaration
//**************************************************************************
.external F_SPI_ReadAWord
.external F_SPI_ReadNWords
.external F_SACM_Delay


//**************************************************************************
// External Table Declaration
//**************************************************************************
.external T_SACM_S200_SpeechTable


//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_ExtMem_Low
.var R_ExtMem_High
.var R_ExtMem_Low_Con
.var R_ExtMem_High_Con


//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.TEXT
// Volume Table
T_SACM_S200_Volume_Level:
.dw 0x0000, 0x0250, 0x0500, 0x1000
.dw	0x1500, 0x2000, 0x2500, 0x3000
.dw 0x3500, 0x4000, 0x5000, 0x6500
.dw	0x7d00, 0x9c00, 0xc400, 0xf500


//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE

//****************************************************************
// Function    : F_SACM_S200_Init_
// Description : Hardware initilazation for S200, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_S200_Init_:	.proc
FIR_MOV OFF;
	
	R1 = C_TimerA_FPLL;				// TimerA CKA=Fosc/2 CKB=1 Tout:off
	[P_Timer_Ctrl] = R1;
	R1= C_S200_Timer_Setting_X1;	// TimerA setting
	[P_TimerA_Data] = R1;
	[P_TimerA_CNTR] = R1;

	R1 = C_DAC_Enable | C_DAC_CH1_Up_Sample_Enable | C_DAC_CH1_Enable | C_DAC_CH1_TMR_Sel_TimerA;
	[P_DAC_Ctrl] = R1;

	R1 = C_Ext_DAC_In_Disable | C_PP_NMOS_Enable | C_PP_Gain_LV9;
	[P_PPAMP_Ctrl] = R1;
	call F_SACM_Delay;
	R1 |= C_PP_PMOS_Enable;
	[P_PPAMP_Ctrl] = R1;

	R1 = [P_INT_Ctrl];
	R1 |= C_IRQ0_TMA;
	[P_INT_Ctrl] = R1;

	R1 = [P_FIQ_Sel];
	R1 |= C_IRQ0_TMA;
	[P_FIQ_Sel] = R1;

	FIQ on;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_S200_Volume
// Description : Set speech volume
// Destory     : R1
// Parameter   : R1: volume index
// Return      : None
// Note        : None
//****************************************************************
 _USER_S200_Volume: .proc
	R1 = SP + 3;
	R1 = [R1];								// volume index
F_USER_S200_Volume:
	R1 += T_SACM_S200_Volume_Level;		// loop up volume table
	R1 = [R1];
	call F_SACM_S200_Volume;
	retf
	.endp

//****************************************************************
// Function    : F_SACM_S200_DAC_Timer_X1
// Description : Change timer setting for change DA filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_S200_DAC_Timer_X1:	.proc
F_SACM_S200_DAC_Timer_X1:
	R1 = C_S200_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_S200_DAC_Timer_X2
// Description : Set timer for S200 playback, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_S200_DAC_Timer_X2:	.proc
F_SACM_S200_DAC_Timer_X2:
	push R1 to [SP];
	R1 = C_S200_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_S200_SendDAC1
// Description : Send data to DAC1, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_S200_SendDAC1:	.proc
    [P_DAC_CH1_Data] = R4;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_S200_SendDAC2
// Description : Send data to DAC2, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_S200_SendDAC2:	.proc
    [P_DAC_CH2_Data] = R4;
	retf; 
	.endp

//****************************************************************
// Function    : F_SACM_S200_StartPlay
// Description : This function called by library when Play function is callled
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_S200_StartPlay:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_S200_EndPlay
// Description : This function called by library when speech play end
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_S200_EndPlay:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_S200_SetStartAddr
// Description : This API allows users to set the beginning address
//               to fetch data. This address can be either a ROM address
//               or a external storage address. User would have to modify
//               the function body based on the application's need.
// Destory     : None
// Parameter   : R1: Low byte of start address
//               R2: High byte of start address
// Return      : None
// Note        : None
//****************************************************************
_USER_S200_SetStartAddr:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_S200_SetStartAddr:
	push R2 to [SP];
	
	R1 = R1 lsl 2;
	R1 += C_SpeechNumberLength;
	push R1 to [SP];
	R2 = 0x0000;
	call F_SPI_ReadAWord;
	[R_ExtMem_Low] = R1;
	
	pop R1 from [SP];
	R1 += 2;
	call F_SPI_ReadAWord;	
	[R_ExtMem_High] = R1;

	pop R2 from [SP];
	retf;
	.endp

.comment @
_USER_S200_SetStartAddr:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_S200_SetStartAddr:
	push R1, R2 to [SP];
	R1 += T_SACM_S200_SpeechTable;
	R1 = [R1];
	R2 = [R1++];
	[R_ExtMem_Low] = R2;
	R1 = [R1];
	R1 = R1 lsl 4;
	R1 = R1 lsl 4;
	R1 = R1 lsl 2;
	[R_ExtMem_High] = R1;
			
	pop R1, R2 from [SP];
	retf;
	.endp
@
.comment @
_USER_S200_SetStartAddr:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_USER_S200_SetStartAddr:
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	retf;
	.endp
@
//****************************************************************
// Function    : F_USER_S200_SetStartAddr_Con
// Description : This API allows users to set the beginning address
//               to fetch data. This address can be either a ROM address
//               or a external storage address. User would have to modify
//               the function body based on the application's need.
// Destory     : None
// Parameter   : R1: Low byte of start address
//               R2: High byte of start address
// Return      : None
// Note        : None
//****************************************************************
_USER_S200_SetStartAddr_Con:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_S200_SetStartAddr_Con:
	push R2 to [SP];
	
	R1 = R1 lsl 2;
	R1 += C_SpeechNumberLength;
	push R1 to [SP];
	R2 = 0x0000;
	call F_SPI_ReadAWord;
	[R_ExtMem_Low_Con] = R1;
	
	pop R1 from [SP];
	R1 += 2;
	call F_SPI_ReadAWord;	
	[R_ExtMem_High_Con] = R1;

	pop R2 from [SP];
	retf;
	.endp

.comment @
_USER_S200_SetStartAddr_Con:	.proc
	R1 = SP + 3;
	R1 = [R1];
F_USER_S200_SetStartAddr_Con:
	push R1, R2 to [SP];
	R1 += T_SACM_S200_SpeechTable;
	R1 = [R1];
	R2 = [R1 ++];
	[R_ExtMem_Low_Con] = R2;
	R1 = [R1];
	R1 = R1 lsl 4;
	R1 = R1 lsl 4;
	R1 = R1 lsl 2;
	[R_ExtMem_High_Con] = R1;

	pop R1, R2 from [SP];
	retf;
	.endp
@
//****************************************************************
// Function    : F_SACM_S200_GetStartAddr_Con
// Description : 
// Destory     : None
// Parameter   : 
// Return      : None
// Note        : None
//****************************************************************
F_SACM_S200_GetStartAddr_Con:	.proc
	R1 = [R_ExtMem_Low_Con];
	R2 = [R_ExtMem_High_Con];
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_S200_GetData
// Description : Get speech data from internal or external memory
//               and fill these data to buffer of library.
// Destory     : None
// Parameter   : R1: decode buffer address of library
//               R2: data length
// Return      : None
// Note        : None
//****************************************************************
.comment @
F_USER_S200_GetData:	.proc
	push R1, R5 to [SP];
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];

?L_Get_Loop:
	cmp R2, 0;
	jz ?L_End;
	SR &= (~0xFC00);
	SR |= R4;
	R5 = D:[R3++];
	[R1++] = R5;
	R2 -= 1;
	cmp R3, 0;
	jnz ?L_Get_Loop;
	R4 += 0x0400;
	[R_ExtMem_High] = R4;
	jmp ?L_Get_Loop;

?L_End:
	[R_ExtMem_Low] = R3; 
	 
	pop R1, R5 from [SP];
	retf;
	.endp
@

F_USER_S200_GetData:	.proc
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SPI_ReadNWords;
	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;
	.endp


.comment @
F_USER_S200_GetData:	.proc
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SIO_ReadNWords;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;
	.endp
@
