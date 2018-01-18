//==========================================================================
// File Name   : SACM_VC_USER.asm
// Description : Users implement functions
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
// Note: 
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
.include GPCE2060.inc
.include RTVC.inc


//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_VC_Timer_Setting_X1		C_Timer_Setting_8K
.define C_VC_Timer_Setting_X2		C_Timer_Setting_16K
.define C_VC_Timer_Setting_X4		C_Timer_Setting_32K

//.define C_VC_Timer_Setting_X1		C_Timer_Setting_12K
//.define C_VC_Timer_Setting_X2		C_Timer_Setting_24K
//.define C_VC_Timer_Setting_X4		C_Timer_Setting_48K


//**************************************************************************
// Variable Publication Area
//**************************************************************************


//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _USER_VC_Volume
.public F_USER_VC_Volume

.public F_SACM_VC_SendDAC1
.public F_SACM_VC_SendDAC2
.public F_SACM_VC_GetADC
.public F_SACM_VC_EndPlay
.public F_SACM_VC_Init_
.public F_SACM_VC_DAC_Timer_X1
.public F_SACM_VC_DAC_Timer_X2
.public F_SACM_VC_ADC_Timer_X1
.public F_SACM_VC_ADC_Timer_X2
.public F_SACM_VC_ADC_Timer_X4


//**************************************************************************
// External Function Declaration
//**************************************************************************
.external F_SACM_Delay


//**************************************************************************
// External Table Declaration
//**************************************************************************
//.external T_SACM_VC_SpeechTable


//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM


//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.TEXT
// Volume Table
T_SACM_VC_Volume_Level:
.dw 0x0000, 0x0250, 0x0500, 0x1000
.dw	0x1500, 0x2000, 0x2500, 0x3000
.dw 0x3500, 0x4000, 0x5000, 0x6500
.dw	0x7d00, 0x9c00, 0xc400, 0xf500


//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE

//****************************************************************
// Function    : F_SACM_VC_Init_
// Description : Hardware initilazation for VC, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC_Init_:	.proc
	FIR_MOV OFF;
	
	//R1 = 0x0030;				// TimerA CKA=Fosc/2 CKB=1 Tout:off
	R1 = C_TimerA_FPLL
    //[P_TimerA_Ctrl] = R1;
	[P_Timer_Ctrl] = R1;	
	R1= C_VC_Timer_Setting_X2;	// TimerA setting
	[P_TimerA_Data] = R1;
	[P_TimerA_CNTR] = R1;

	//R1 = C_DAC_Enable | C_DAC_TMR_Sel_TimerA;
	R1 = C_DAC_Scaler_Enable | C_DAC_Half_Vol_Enable | C_DAC_Enable;
	R1 |= C_DAC_CH2_Up_Sample_Enable | C_DAC_CH2_Enable | C_DAC_CH2_TMR_Sel_TimerA;
	R1 |= C_DAC_CH1_Up_Sample_Enable | C_DAC_CH1_Enable | C_DAC_CH1_TMR_Sel_TimerA;
	[P_DAC_Ctrl] = R1;	
	
	R1 = C_Ext_DAC_In_Disable | C_PP_NMOS_Enable | C_PP_Gain_LV10;
	[P_PPAMP_Ctrl] = R1;
	call F_SACM_Delay;
	R1 |= C_PP_PMOS_Enable;
	[P_PPAMP_Ctrl] = R1;	

	//r1 = 0x0115;			// 061A: AGC enable; MIC IN; ADC enable
	R1 = C_ADC_Enable | C_AGC_Enable | C_ADC_CLK_FPLL_Div_32 | C_ADC_Bias_Enable | C_ADC_MIC_Enable | C_ADC_Timer_A
	[P_ADC_Ctrl] = R1;
	
	R1 = C_ADC_PGA_Disable;
	[P_ADC_PGA_Ctrl] = R1;
	
	R1 = 0xffff;
	[P_INT_Status] = R1; //[P_INT_Clear] = R1;

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
// Function    : F_USER_VC_Volume
// Description : Set speech volume
// Destory     : R1
// Parameter   : R1: volume index
// Return      : None
// Note        : None
//****************************************************************

 _USER_VC_Volume: .proc
	R1 = SP + 3;
	R1 = [R1];								// volume index
F_USER_VC_Volume:
	R1 += T_SACM_VC_Volume_Level;		// loop up volume table
	R1 = [R1];
	call F_SACM_VC_Volume;
	retf
	.endp

//****************************************************************
// Function    : F_SACM_VC_DAC_Timer_X1
// Description : Change timer setting for change DA filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC_DAC_Timer_X1:	.proc
F_SACM_VC_DAC_Timer_X1:
	R1 = C_VC_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC_DAC_Timer_X2
// Description : Set timer for VC playback, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC_DAC_Timer_X2:	.proc
F_SACM_VC_DAC_Timer_X2:
	push R1 to [SP];
	R1 = C_VC_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC_ADC_Timer_X1
// Description : Change timer setting for change AD filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC_ADC_Timer_X1:	.proc
F_SACM_VC_ADC_Timer_X1:
	R1 = C_VC_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC_ADC_Timer_X2
// Description : Change timer setting for change AD filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC_ADC_Timer_X2:	.proc
F_SACM_VC_ADC_Timer_X2:
	R1 = C_VC_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC_ADC_Timer_X4
// Description : Set timer for VC recording, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC_ADC_Timer_X4:	.proc
F_SACM_VC_ADC_Timer_X4:
	push R1 to [SP];
	R1 = C_VC_Timer_Setting_X4;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC_GetADC
// Description : Get ADC data for recording
// Destory     : R1
// Parameter   : None
// Return      : R1 = ADC data
// Note        : None
//****************************************************************
F_SACM_VC_GetADC:	.proc
	push R1 to [SP];	
	R4 = [P_ADC_Data]
	pop R1 from [SP];

	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC_SendDAC1
// Description : Send data to DAC1, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC_SendDAC1:	.proc	
	[P_DAC_CH1_Data] = R4;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC_SendDAC2
// Description : Send data to DAC2, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC_SendDAC2:	.proc
    [P_DAC_CH2_Data] = R4;
	retf; 
	.endp

//****************************************************************
// Function    : F_SACM_VC_EndPlay
// Description : This function called by library when speech play end
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC_EndPlay:	.proc
	nop;
	retf;
	.endp

