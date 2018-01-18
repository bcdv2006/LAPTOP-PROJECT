//==========================================================================
// File Name   : SACM_DVRIMA_USER.asm
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
.include DVRIMA.inc


//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_DVRIMA_Timer_Setting_X1		C_Timer_Setting_12K
.define C_DVRIMA_Timer_Setting_X2		C_Timer_Setting_24K
.define C_DVRIMA_Timer_Setting_X4		C_Timer_Setting_48K

.define C_SpeechNumberLength		4	// for skip song number


//**************************************************************************
// Variable Publication Area
//**************************************************************************
.public R_ShereDAC

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _USER_DVRIMA_SetStartAddr
.public F_USER_DVRIMA_SetStartAddr
.public  _USER_DVRIMA_SetStartAddr_Con
.public F_USER_DVRIMA_SetStartAddr_Con

.public F_USER_DVRIMA_GetData
.public F_USER_DVRIMA_WriteData
.public  _USER_DVRIMA_Volume
.public F_USER_DVRIMA_Volume

.public F_SACM_DVRIMA_SendDAC1
.public F_SACM_DVRIMA_SendDAC2
.public F_SACM_DVRIMA_GetADC
.public F_SACM_DVRIMA_StartPlay
.public F_SACM_DVRIMA_EndPlay
.public F_SACM_DVRIMA_StartRecord
.public F_SACM_DVRIMA_EndRecord
.public F_SACM_DVRIMA_Init_
.public F_SACM_DVRIMA_DAC_Timer_X1
.public F_SACM_DVRIMA_DAC_Timer_X2
.public F_SACM_DVRIMA_ADC_Timer_X1
.public F_SACM_DVRIMA_ADC_Timer_X2
.public F_SACM_DVRIMA_ADC_Timer_X4
.public F_SACM_DVRIMA_GetStartAddr_Con


//**************************************************************************
// External Variable Declaration
//**************************************************************************
.external _Mode


//**************************************************************************
// External Function Declaration
//**************************************************************************
.external F_SPI_ReadAWord
.external F_SPI_ReadNWords
.external F_SPI_SendAWord
.external F_SPI_SendNWords

.external F_SACM_Delay


//**************************************************************************
// External Table Declaration
//**************************************************************************
.external T_SACM_DVRIMA_SpeechTable


//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_ExtMem_Low
.var R_ExtMem_High
.var R_ExtMem_Low_Con
.var R_ExtMem_High_Con
.var R_ExtMem_Low_Rear
.var R_ExtMem_High_Rear
.var R_ExtMemLength_RearPTR
.var R_ShereDAC


//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.TEXT
// Volume Table
T_SACM_DVRIMA_Volume_Level:
.dw 0x0000, 0x0250, 0x0500, 0x1000
.dw	0x1500, 0x2000, 0x2500, 0x3000
.dw 0x3500, 0x4000, 0x5000, 0x6500
.dw	0x7d00, 0x9c00, 0xc400, 0xf500


//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE

//****************************************************************
// Function    : F_SACM_DVRIMA_Init_
// Description : Hardware initilazation for DVRIMA, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_Init_:	.proc
	FIR_MOV OFF;
	
	R1 = C_TimerA_FPLL;				// TimerA CKA=Fosc/2 CKB=1 Tout:off
	[P_Timer_Ctrl] = R1;
	R1= C_DVRIMA_Timer_Setting_X2;	// TimerA setting
	[P_TimerA_Data] = R1;
	[P_TimerA_CNTR] = R1;

	R1 = C_DAC_Enable | C_DAC_CH1_Up_Sample_Enable | C_DAC_CH1_Enable | C_DAC_CH1_TMR_Sel_TimerA;
	[P_DAC_Ctrl] = R1;	

	R1 = C_Ext_DAC_In_Disable | C_PP_NMOS_Enable | C_PP_Gain_LV9;
	[P_PPAMP_Ctrl] = R1;
	call F_SACM_Delay;
	R1 |= C_PP_PMOS_Enable;
	[P_PPAMP_Ctrl] = R1;
	
	R1 = C_ADC_Enable | C_AGC_Enable | C_ADC_CLK_FPLL_Div_32 | C_ADC_Bias_Enable | C_ADC_MIC_Enable | C_ADC_Timer_A
	[P_ADC_Ctrl] = R1;

	R1 = C_ADC_PGA_Disable;
	[P_ADC_PGA_Ctrl] = R1;

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
// Function    : F_USER_DVRIMA_Volume
// Description : Set speech volume
// Destory     : R1
// Parameter   : R1: volume index
// Return      : None
// Note        : None
//****************************************************************
 _USER_DVRIMA_Volume: .proc
	R1 = SP + 3;
	R1 = [R1];								// volume index
F_USER_DVRIMA_Volume:
	R1 += T_SACM_DVRIMA_Volume_Level;		// loop up volume table
	R1 = [R1];
	call F_SACM_DVRIMA_Volume;
	retf
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_DAC_Timer_X1
// Description : Change timer setting for change DA filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_DVRIMA_DAC_Timer_X1:	.proc
F_SACM_DVRIMA_DAC_Timer_X1:
	R1 = C_DVRIMA_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_DAC_Timer_X2
// Description : Set timer for DVRIMA playback, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_DVRIMA_DAC_Timer_X2:	.proc
F_SACM_DVRIMA_DAC_Timer_X2:
	push R1 to [SP];
	R1 = C_DVRIMA_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_ADC_Timer_X1
// Description : Change timer setting for change AD filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_DVRIMA_ADC_Timer_X1:	.proc
F_SACM_DVRIMA_ADC_Timer_X1:
	R1 = C_DVRIMA_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_ADC_Timer_X2
// Description : Change timer setting for change AD filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_DVRIMA_ADC_Timer_X2:	.proc
F_SACM_DVRIMA_ADC_Timer_X2:
	R1 = C_DVRIMA_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_ADC_Timer_X4
// Description : Set timer for DVRIMA recording, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_DVRIMA_ADC_Timer_X4:	.proc
F_SACM_DVRIMA_ADC_Timer_X4:
	push R1 to [SP];
	R1 = C_DVRIMA_Timer_Setting_X4;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_GetADC
// Description : Get ADC data for recording
// Destory     : R1
// Parameter   : None
// Return      : R1 = ADC data
// Note        : None
//****************************************************************
F_SACM_DVRIMA_GetADC:	.proc
	R4 = [P_ADC_Data];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_SendDAC1
// Description : Send data to DAC1, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_SendDAC1:	.proc
	[P_DAC_CH1_Data] = R4;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_SendDAC2
// Description : Send data to DAC2, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_SendDAC2:	.proc
	//[P_DAC_CH2_Data] = R4;
	R4 = R4 ASR 1;
	[R_ShereDAC] = R4;
	retf; 
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_StartPlay
// Description : This function called by library when Play function is callled
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_StartPlay:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_EndPlay
// Description : This function called by library when speech play end
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_EndPlay:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_StartRecord
// Description : This function called by library when Record function is callled
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_StartRecord:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVRIMA_EndRecord
// Description : Call back from kernel when bit stream encoding is done 
// Destory     : R1, R2, R3
// Parameter   : R1: Low byte of file length
//               R2: High byte of File length
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_EndRecord: .proc
	push R2 to [SP];
	push R1 to [SP];
	R1 = 0;
	R2 = 7;				// eighth block 0x70000
	pop R3 from [SP];
	call F_SPI_SendAWord;
	R1 += 2;
	pop R3 from [SP];
	call F_SPI_SendAWord;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_DVRIMA_SetStartAddr
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
_USER_DVRIMA_SetStartAddr:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_USER_DVRIMA_SetStartAddr:
	push R1, R3 to [SP];
	R3 = [_Mode];
	jz ?L_PlayPrerecordData;
?L_PlayRecordedData:
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	//Add by Gary
	push R1 to [SP];
	call F_SPI_ReadAWord;
	R3 = R1;				//Length Low Byte
	pop R1 from [SP];
	R1 += 2;
	call F_SPI_ReadAWord;
	R4 = R1;				//Length High Byte
	R1 = [R_ExtMem_Low];
	R2 = [R_ExtMem_High];
	R3 += R1;
	R4 += R2 , carry;
	R3 += 4;				//4 byte length and 1 byte last byte
	R4 += 0 , carry;
	[R_ExtMem_Low_Rear] = R3;
	[R_ExtMem_High_Rear] = R4;
	//Add by Gary end
	jmp ?L_SetAddr_End

?L_PlayPrerecordData:
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

	//Add by Gary
	R1 = [R_ExtMem_Low];
	R2 = [R_ExtMem_High];
	push R1 to [SP];
	call F_SPI_ReadAWord;
	R3 = R1;				//Length Low Byte
	pop R1 from [SP];
	R1 += 2;
	call F_SPI_ReadAWord;
	R4 = R1;				//Length High Byte
	R1 = [R_ExtMem_Low];
	R2 = [R_ExtMem_High];
	R3 += R1;
	R4 += R2 , carry;
	R3 += 4;
	R4 += 0 , carry;
	[R_ExtMem_Low_Rear] = R3;
	[R_ExtMem_High_Rear] = R4;
	//Add by Gary end
		
?L_SetAddr_End:	
	pop R1, R3 from [SP];
	retf;
	.endp

.comment @
_USER_DVRIMA_SetStartAddr:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_USER_DVRIMA_SetStartAddr:
	push R1, R3 to [SP];
	R3 = [_Mode];
	jz ?L_PlayPrerecordData;
?L_PlayRecordedData:
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	jmp ?L_SetStartAddrEnd;
		
?L_PlayPrerecordData:
	R1 += T_SACM_DVRIMA_SpeechTable;
	R1 = [R1];
	R2 = [R1++];
	[R_ExtMem_Low] = R2;
	R1 = [R1];
	R1 = R1 lsl 4;
	R1 = R1 lsl 4;
	R1 = R1 lsl 2;
	[R_ExtMem_High] = R1;
			
?L_SetStartAddrEnd:
	pop R1, R3 from [SP];
	retf;
	.endp
@
//****************************************************************
// Function    : F_USER_DVRIMA_SetStartAddr_Con
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
_USER_DVRIMA_SetStartAddr_Con:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_USER_DVRIMA_SetStartAddr_Con:
	push R1, R3 to [SP];
	R3 = [_Mode];
	jz ?L_PlayPrerecordData;
?L_PlayRecordedData:
	[R_ExtMem_Low_Con] = R1;
	[R_ExtMem_High_Con] = R2;
	jmp ?L_SetAddr_End
		
?L_PlayPrerecordData:
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
?L_SetAddr_End:	
	pop R1, R3 from [SP];
	retf;
	.endp

.comment @
_USER_DVRIMA_SetStartAddr_Con:	.proc
	R1 = SP + 3;
	R1 = [R1];
F_USER_DVRIMA_SetStartAddr_Con:
	push R1, R2 to [SP];
	R1 += T_SACM_DVRIMA_SpeechTable;
	R1 = [R1];
	R2 = [R1++];
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
// Function    : F_SACM_DVRIMA_GetStartAddr_Con
// Description : 
// Destory     : None
// Parameter   : 
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVRIMA_GetStartAddr_Con:	.proc
	R1 = [R_ExtMem_Low_Con];
	R2 = [R_ExtMem_High_Con];
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_DVRIMA_GetData
// Description : Get speech data from internal or external memory
//               and fill these data to buffer of library.
// Destory     : None
// Parameter   : R1: decode buffer address of library
//               R2: data length
//				 R3: Play Direction,0 is foreward, 1 is backward
// Return      : None
// Note        : None
//****************************************************************
F_USER_DVRIMA_GetData:	.proc
	push R1, R5 to [SP];
	//Add by Gary
	tstb R3 , 0;
	jnz ?L_GetData_FromRear;
	//Add by Gary End
	
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SPI_ReadNWords;
	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	
	//Add by Gary
	jmp ?L_GetData_End;
?L_GetData_FromRear:	
	R3 = [R_ExtMem_Low_Rear];
	R4 = [R_ExtMem_High_Rear];
	push R1,R2 to [SP]
	R1 = R2 lsl 1;
	R3 -= R1;
	jpl ?L_CheckRear_End;
	R4 -= 1;
?L_CheckRear_End:
	[R_ExtMem_Low_Rear] = R3;
	[R_ExtMem_High_Rear] = R4;
	pop R1,R2 from [SP]
	call F_SPI_ReadNWords;
	
?L_GetData_End:
	//Add by Gary end	
	
	pop R1, R5 from [SP];
	retf;
	.endp

.comment @
F_USER_DVRIMA_GetData:	.proc
	push R1, R5 to [SP];
	R3 = [_Mode];
	jz ?L_PlayPrerecordData;
?L_PlayRecordedData:
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SPI_ReadNWords;
	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	jmp ?L_GetDataEnd;

?L_PlayPrerecordData:
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
?L_Get_Loop:
	cmp R2, 0;
	jz ?L_LoopEnd;
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
?L_LoopEnd:
	[R_ExtMem_Low] = R3; 
	
?L_GetDataEnd:	 
	pop R1, R5 from [SP];
	retf;
	.endp
@
.comment @
F_USER_DVRIMA_GetData:	.proc
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SIO_ReadNWords;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;
	.endp
@

//****************************************************************
// Function    : F_USER_DVRIMA_WriteData
// Description : Get encoded speech data from buffer of library
//               and write to external memory.
// Destory     : None
// Parameter   : R1: encode buffer address of library
//               R2: data length
// Return      : None
// Note        : None
//****************************************************************
F_USER_DVRIMA_WriteData:	.proc
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SPI_SendNWords;
	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;
	.endp
.comment @
F_USER_DVRIMA_WriteData:	.proc
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SIO_SendNWords;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;
	.endp
@
T_SACM_A1800_SpeechTable_Manual:
//D:\WorkingFolder\Tools\SpeechFileMerger\A1800\audio13.a18:
   .dw 0x0011,0x0022;
//D:\WorkingFolder\Tools\SpeechFileMerger\A1800\jingle.a18:
   .dw 0x0000,0xD8BE;
//D:\WorkingFolder\Tools\SpeechFileMerger\A1800\pour.a18:
   .dw 0x0001,0xC84C;
   
 .public  _USER_A1800_SetStartAddr
.public F_USER_A1800_SetStartAddr  
_USER_A1800_SetStartAddr:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_A1800_SetStartAddr:
	push R1, R2 to [SP];
	R1 = R1 lsl 1;
	R2 = R1 + T_SACM_A1800_SpeechTable_Manual;
//	R1 = [R1];
	R1 = [R2++];
	R2 = [R2];
	[R_ExtMem_Low] = R2;
	[R_ExtMem_High] = R1;

	pop R1, R2 from [SP];
	retf;
	.endp   