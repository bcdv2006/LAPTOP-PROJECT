//==========================================================================
// File Name   : SACM_A3400Pro_USER.asm
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
.include A3400Pro.inc


//**************************************************************************
// Table Publication Area
//**************************************************************************
.public D_IO_EVENT_NUM 
.public D_SW_PWM_LEVEL
.public T_IO_Event


//***************************************************************************************
// User Definition Section for IO Event
//***************************************************************************************
.define C_IO_EVENT_NUM    0                      // IO number for IO_Event 
.define C_SW_PWM_FREQ     60                     // PWM frequency (Unit: Hz)
.define C_SW_PWM_LEVEL    128                    // PWM level selection (32/64/128/256)
.define C_PWM_FREQ        65536 - (SystemClock / (C_SW_PWM_FREQ * C_SW_PWM_LEVEL))      // for PWM Service Timer Setting

.text 
//
// IO Event Definition
// - Mapped to the number of Edit Event on G+ Eventor
//
T_IO_Event:
.DD    C_IOB0
.DD    C_IOB1
.DD    C_IOB2
.DD    C_IOB3
.DD    C_IOB4
.DD    C_IOB5
.DD    C_IOB6
.DD    C_IOB7
.DD    C_IOB8
.DD    C_IOB9
.DD    C_IOB10
.DD    C_IOB11
.DD    C_IOB12
.DD    C_IOB13
.DD    C_IOB14
.DD    C_IOB15

.DD    C_IOA0
.DD    C_IOA1
.DD    C_IOA2
.DD    C_IOA3
.DD    C_IOA4
.DD    C_IOA5
.DD    C_IOA6
.DD    C_IOA7
.DD    C_IOA8
.DD    C_IOA9
.DD    C_IOA10
.DD    C_IOA11
.DD    C_IOA12
.DD    C_IOA13
.DD    C_IOA14
.DD    C_IOA15


//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_A3400Pro_Timer_Setting_X1		C_Timer_Setting_12K
.define C_A3400Pro_Timer_Setting_X2		C_Timer_Setting_24K
.define C_A3400Pro_Timer_Setting_X4		C_Timer_Setting_48K

.define C_RING_BUFFER_LEN               200  // Define ring buffer length

.define C_SpeechNumberLength		    4    // for skip song number

.define C_SACM_A3400Pro_PLAY			0x0001
.define	C_SACM_A3400Pro_AUTO			0x0080

//
// IO Event Pin Definition Section
// - Based on IC I/O Configuration         
// - example ".define C_IOA3            0x20000003"
//   1st word:0x2000 = I/O Configuration Register Base
//   2st word:0x0003 = I/O Pin Number
//
.define C_IOA0            0x20000000
.define C_IOA1            0x20000001  
.define C_IOA2            0x20000002
.define C_IOA3            0x20000003
.define C_IOA4            0x20000004 
.define C_IOA5            0x20000005 
.define C_IOA6            0x20000006 
.define C_IOA7            0x20000007
.define C_IOA8            0x20000008
.define C_IOA9            0x20000009  
.define C_IOA10           0x2000000A
.define C_IOA11           0x2000000B
.define C_IOA12           0x2000000C 
.define C_IOA13           0x2000000D 
.define C_IOA14           0x2000000E 
.define C_IOA15           0x2000000F
.define C_IOB0            0x20040000
.define C_IOB1            0x20040001  
.define C_IOB2            0x20040002
.define C_IOB3            0x20040003
.define C_IOB4            0x20040004 
.define C_IOB5            0x20040005 
.define C_IOB6            0x20040006 
.define C_IOB7            0x20040007 
.define C_IOB8            0x20040008 
.define C_IOB9            0x20040009 
.define C_IOB10           0x2004000A 
.define C_IOB11           0x2004000B 
.define C_IOB12           0x2004000C
.define C_IOB13           0x2004000D 
.define C_IOB14           0x2004000E 
.define C_IOB15           0x2004000F

.define C_PORT_DATA_IDX   0 
.define C_PORT_BUF_IDX    1
.define C_PORT_DIR_IDX    2
.define C_PORT_ATT_IDX    3


//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _USER_A3400Pro_SetStartAddr
.public F_USER_A3400Pro_SetStartAddr
.public  _USER_A3400Pro_SetStartAddr_Con
.public F_USER_A3400Pro_SetStartAddr_Con
.public F_USER_A3400Pro_GetData
.public  _USER_A3400Pro_Volume
.public F_USER_A3400Pro_Volume
.public F_SACM_A3400Pro_SendDAC1
.public F_SACM_A3400Pro_SendDAC2
.public F_SACM_A3400Pro_StartPlay
.public F_SACM_A3400Pro_EndPlay
.public F_SACM_A3400Pro_INT_ON
.public F_SACM_A3400Pro_INT_OFF
.public F_SACM_A3400Pro_Init_
.public F_SACM_A3400Pro_DAC_Timer_X1
.public F_SACM_A3400Pro_DAC_Timer_X2
.public F_SACM_A3400Pro_GetStartAddr_Con
.public F_Event_Init_
.public F_GetExtSpeechStartAddr
.public F_USER_GetEvtData
.public F_USER_IoEvtStart
.public F_USER_IoEvtEnd
.public F_USER_EvtProcess
.public  _USER_A3400Pro_ServiceLoop
.public F_USER_A3400Pro_ServiceLoop
.public  _InitRingBuffer
.public F_InitRingBuffer


//**************************************************************************
// Variable Publication Area
//**************************************************************************
.public R_DutyArray 
.public R_A3400Pro_DAC_Data


//**************************************************************************
// External Function Declaration
//**************************************************************************
.external F_SPI_ReadAWord
.external F_SPI_ReadNWords
.external F_SACM_Delay


//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_ExtMem_Low
.var R_ExtMem_High
.var R_ExtMem_Low_Con
.var R_ExtMem_High_Con
.var R_SPI_Addr_Low
.var R_SPI_Addr_High
.var R_A3400Pro_DAC_Data

R_SACM_Ring_Buffer:    .dw    C_RING_BUFFER_LEN    dup(?)
.var    R_RingBufferWrPtr                                 
.var    R_RingBufferRdPtr 

R_DutyArray:    .dw    C_IO_EVENT_NUM    dup(?)  


//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.TEXT
// Volume Table
T_SACM_A3400Pro_Volume_Level:
.dw 0x0000, 0x0250, 0x0500, 0x1000
.dw	0x1500, 0x2000, 0x2500, 0x3000
.dw 0x3500, 0x4000, 0x5000, 0x6500
.dw	0x7d00, 0x9c00, 0xc400, 0xf500

D_IO_EVENT_NUM:
.DW C_IO_EVENT_NUM

D_SW_PWM_LEVEL:
.DW C_SW_PWM_LEVEL


//*****************************************************************************
// CODE Definition Area
//*****************************************************************************
.CODE

//*****************************************************************************
// Function    : F_SACM_A3400Pro_Init_
// Description : Hardware initilazation for A3400Pro, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_Init_:	.proc
	FIR_MOV OFF;
	
	R1 = [P_Timer_Ctrl];
	R1 |= C_TimerA_FPLL;
	[P_Timer_Ctrl] = R1;
	R1 = C_A3400Pro_Timer_Setting_X1;
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

    //
    // Initialize R_RingBufferWrPtr and R_RingBufferRdPtr 
    //
    R1 = R_SACM_Ring_Buffer;  
    [R_RingBufferWrPtr] = R1;
    [R_RingBufferRdPtr] = R1;  

	FIQ on;

	retf;
	.endp

//*****************************************************************************
// Function    : F_USER_A3400Pro_Volume
// Description : Set speech volume
// Destory     : R1
// Parameter   : R1: volume index
// Return      : None
// Note        : None
//*****************************************************************************
 _USER_A3400Pro_Volume: .proc
	R1 = SP + 3;
	R1 = [R1];								// volume index
F_USER_A3400Pro_Volume:
	R1 += T_SACM_A3400Pro_Volume_Level;		// loop up volume table
	R1 = [R1];
	call F_SACM_A3400Pro_Volume;
	retf
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_DAC_Timer_X1
// Description : Change timer setting for change DA filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************
 _SACM_A3400Pro_DAC_Timer_X1:	.proc
F_SACM_A3400Pro_DAC_Timer_X1:
	R1 = C_A3400Pro_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_DAC_Timer_X2
// Description : Set timer for A3400Pro playback, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************
 _SACM_A3400Pro_DAC_Timer_X2:	.proc
F_SACM_A3400Pro_DAC_Timer_X2:
	push R1 to [SP];
	R1 = C_A3400Pro_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_SendDAC1
// Description : Send data to DAC1, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_SendDAC1:	.proc    
	[P_DAC_CH1_Data] = R4;		
	retf;
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_SendDAC2
// Description : Send data to DAC2, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_SendDAC2:	.proc
    [P_DAC_CH2_Data] = R4;
	retf; 
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_StartPlay
// Description : This function called by library when Play function is callled
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_StartPlay:	.proc
	nop;
	retf;
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_EndPlay
// Description : This function called by library when speech play end
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_EndPlay:	.proc
	nop;
	retf;
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_INT_ON
// Description : This function called by library
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_INT_ON:	.proc
	FIQ on;
	retf;
	.endp

//*****************************************************************************
// Function    : F_SACM_A3400Pro_INT_OFF
// Description : This function called by library
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_INT_OFF:	.proc
	FIQ off;
	retf;
	.endp

//*****************************************************************************
// Function    : F_USER_A3400Pro_SetStartAddr
// Description : This API allows users to set the beginning address
//               to fetch data. This address can be either a ROM address
//               or a external storage address. User would have to modify
//               the function body based on the application's need.
// Destory     : None
// Parameter   : R1: Low byte of start address
//               R2: High byte of start address
// Return      : None
// Note        : None
//*****************************************************************************
_USER_A3400Pro_SetStartAddr:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_A3400Pro_SetStartAddr:
	push R1, R2 to [SP];
	
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

	pop R1, R2 from [SP];
	retf;
	.endp

//*****************************************************************************
// Function    : F_USER_A3400Pro_SetStartAddr_Con
// Description : This API allows users to set the beginning address
//               to fetch data. This address can be either a ROM address
//               or a external storage address. User would have to modify
//               the function body based on the application's need.
// Destory     : None
// Parameter   : R1: Low byte of start address
//               R2: High byte of start address
// Return      : None
// Note        : None
//*****************************************************************************
_USER_A3400Pro_SetStartAddr_Con:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_A3400Pro_SetStartAddr_Con:
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

//*****************************************************************************
// Function    : F_SACM_A3400Pro_GetStartAddr_Con
// Description : 
// Destory     : None
// Parameter   : 
// Return      : None
// Note        : None
//*****************************************************************************
F_SACM_A3400Pro_GetStartAddr_Con:	.proc
	R1 = [R_ExtMem_Low_Con];
	R2 = [R_ExtMem_High_Con];
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	retf;
	.endp

//*****************************************************************************
// Function    : F_USER_A3400Pro_GetData
// Description : Get speech data from internal or external memory
//               and fill these data to buffer of library.
// Destory     : None
// Parameter   : None
// Return      : R1: A3400Pro data
// Note        : None
//*****************************************************************************
F_USER_A3400Pro_GetData:	.proc
    R2 = [R_RingBufferRdPtr];    
    R1 = [R2++];                                      
    cmp R2, R_SACM_Ring_Buffer + C_RING_BUFFER_LEN;
    jb ?L_StoreRingBufferRdPtr;                       
    R2 = R_SACM_Ring_Buffer;                          
?L_StoreRingBufferRdPtr:                              
    [R_RingBufferRdPtr] = R2; 	
	retf;
	.endp

//*****************************************************************************
// Function    : F_Event_Init_
// Description : None
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//***************************************************************************** 
F_Event_Init_:    .proc
	push R1, BP to [sp];

	//
	// Initialize S/W PWM IO as output low
	// 	
	R1 = 0;  
	R2 = T_IO_Event; 	
?L_IOSettingLoop:   
	R3 = [R2++];
	R5 = [R2++];  
	R4 = [R5 + C_PORT_DIR_IDX];
	setb R4, R3;
	[R5 + C_PORT_DIR_IDX] = R4; 
	R4 = [R5 + C_PORT_ATT_IDX];
	setb R4, R3;     
	[R5 + C_PORT_ATT_IDX] = R4;   
	R4 = [R5 + C_PORT_BUF_IDX];
	clrb R4, R3;
	[R5 + C_PORT_BUF_IDX] = R4;  	
	R1 += 1;
	cmp R1, C_IO_EVENT_NUM;
	jb ?L_IOSettingLoop 
	
	//
	// Initialize TimerC and enable IRQ2_TimerC interrupt
	//
	R1 = [P_Timer_Ctrl];
	R1 |= C_TimerC_FPLL;
	[P_Timer_Ctrl] = R1;
	R1 = C_PWM_FREQ;
	[P_TimerC_Data] = R1;
	[P_TimerC_CNTR] = R1;  
	R1 = [P_INT_Ctrl];
	R1 |= C_IRQ2_TMC;
	[P_INT_Ctrl] = R1;  
	IRQ ON;  

?L_Event_Init_End:
	pop R1, BP from [sp];
	retf
	.endp

//*****************************************************************************
// Function    : F_GetExtSpeechStartAddr
// Description : In the manual mode, library call this function to get 
//               external speech start address.
// Destory     : None
// Parameter   :
// Return      : R1 = Low ward of sound data addr  
//               R2 = High ward of sound data addr 
// Note        : None
//*****************************************************************************
F_GetExtSpeechStartAddr:	.proc	
	R1 = [R_ExtMem_Low];	
	R2 = [R_ExtMem_High];
	retf
	.endp

//*****************************************************************************
// Function    : F_USER_GetEvtData
// Description : In the manual mode, library call this function to get 
//               external event data. 
// Destory     : None
// Parameter   : R1 = Low ward of the event data addr  
//               R2 = High ward of the event data addr 
// Return      : R1 = Event Data
// Note        : None
//*****************************************************************************
F_USER_GetEvtData:	.proc
    call F_SPI_ReadAWord;      
	retf;
	.endp

//*****************************************************************************
// Function    : F_USER_IoEvtStart
// Description : This function will be called by library when IO event start.
//               The state of IO pins can be set by user 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************    
F_USER_IoEvtStart:    .proc 
	push R1, BP to [sp];
	
	//
	// Set S/W PWM IO as output low
	//	
	R1 = 0;  
	R2 = T_IO_Event;  
?L_IOSettingLoop:   
	R3 = [R2++];
	R5 = [R2++];
	R4 = [R5 + C_PORT_BUF_IDX];
	clrb R4, R3;
	[R5 + C_PORT_BUF_IDX] = R4;   
	//R4 = [R5 + C_PORT_DIR_IDX];
	//setb R4, R3;
	//[R5 + C_PORT_DIR_IDX] = R4;  
	R1 += 1;
	cmp R1, C_IO_EVENT_NUM;
	jb ?L_IOSettingLoop 

	pop R1, BP from [sp];
	retf
	.endp

//*****************************************************************************
// Function    : F_USER_IoEvtEnd
// Description : This function will be called by library when IO event ends.
//               The state of IO pins can be set by user 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************    
F_USER_IoEvtEnd:    .proc 
	push R1, BP to [sp];
	
	//
	// Set S/W PWM IO as output low
	//	
	R1 = 0;  
	R2 = T_IO_Event;  
?L_IOSettingLoop:   
	R3 = [R2++];
	R5 = [R2++];
	R4 = [R5 + C_PORT_BUF_IDX];
	clrb R4, R3;
	[R5 + C_PORT_BUF_IDX] = R4;   
	//R4 = [R5 + C_PORT_DIR_IDX];
	//setb R4, R3;
	//[R5 + C_PORT_DIR_IDX] = R4;  
	R1 += 1;
	cmp R1, C_IO_EVENT_NUM;
	jb ?L_IOSettingLoop 

	pop R1, BP from [sp];
	retf
	.endp
	
//*****************************************************************************
// Function    : F_USER_EvtProcess
// Description : When a user event is decoded, F_USER_EvtProcess will be executed.
//               User can process the user event in this function.
// Destory     : 
// Parameter   : R1 = SubIndex(8-bits):MainIndex(8-bits) 
// Return      : None
// Note        : None
//*****************************************************************************
F_USER_EvtProcess:    .proc  
	
	retf
	.endp	

//*****************************************************************************
// Function    : F_SACM_A3400Pro_ServiceLoop
// Description : This function will fill R_SACM_Ring_Buffer with 
//               A3400Pro encoded data 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : 
//*****************************************************************************
_USER_A3400Pro_ServiceLoop:    .proc
F_USER_A3400Pro_ServiceLoop:    
    push R1, R5 to [SP];
    
    call F_SACM_A3400Pro_Status;
    R2 = R1 & C_SACM_A3400Pro_PLAY;
    jz ?_USER_A3400Pro_ServiceLoop_End
    R2 = R1 & C_SACM_A3400Pro_AUTO;
    jz ?L_Fill_RingBuffer;

?_USER_A3400Pro_ServiceLoop_End:       
	pop R1, R5 from [SP]; 
	retf;  

?L_Fill_RingBuffer:    
    R1 = [R_RingBufferWrPtr];
    R2 = [R_RingBufferRdPtr];
    cmp R2, R1;
    je ?_USER_A3400Pro_ServiceLoop_End;
    cmp R2, R1;
    ja ?L_Fill_RingBuffer_1;
    jmp ?L_Fill_RingBuffer_2;
    
?L_Fill_RingBuffer_1:
    R2 = R2 - R1;
	R3 = [R_SPI_Addr_Low];	
	R4 = [R_SPI_Addr_High];		
	call F_SPI_ReadNWords;	
	
	R1 += R2;
    [R_RingBufferWrPtr] = R1;  

	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_SPI_Addr_Low] = R3;
	[R_SPI_Addr_High] = R4; 	
	
	pop R1, R5 from [SP]; 
	retf;

?L_Fill_RingBuffer_2:		
    R2 += C_RING_BUFFER_LEN
    R2 -= R1;
    R5 = R2;
    R2 = R_SACM_Ring_Buffer + C_RING_BUFFER_LEN;    
    R2 -= R1;    
	R3 = [R_SPI_Addr_Low];
	R4 = [R_SPI_Addr_High];		
	call F_SPI_ReadNWords;	

    R1 = R_SACM_Ring_Buffer;    
	R3 += R2 lsl 1;
	R4 += 0, carry;  
	[R_SPI_Addr_Low] = R3;
	[R_SPI_Addr_High] = R4;
		    
    push R5 to [SP];
    R5 -= R2;
    jz ?L_Update_RingBufferWrPtr;    
    R2 = R5;      
    call F_SPI_ReadNWords;	

	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_SPI_Addr_Low] = R3;
	[R_SPI_Addr_High] = R4; 	

?L_Update_RingBufferWrPtr:
    pop R5 from [SP];	
    R1 = [R_RingBufferWrPtr];
	R1 += R5;
	R1 -= C_RING_BUFFER_LEN;
    [R_RingBufferWrPtr] = R1;   	

    pop R1, R5 from [SP];
	retf;   
    .endp  

//*****************************************************************************
// Function    : F_InitRingBuffer
// Description : None
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : 2011.06.14 Allen
//*****************************************************************************
_InitRingBuffer:    .proc
F_InitRingBuffer:    
    push R1 to [sp];

    //
    // Initialize R_RingBufferWrPtr and R_RingBufferRdPtr 
    //
    R1 = R_SACM_Ring_Buffer;  
    [R_RingBufferWrPtr] = R1;
    [R_RingBufferRdPtr] = R1;  

    //
    // Initial SACM Ring Buffer
    //
    R1 = R_SACM_Ring_Buffer
    R2 = C_RING_BUFFER_LEN;      
    R3 = [R_ExtMem_Low];	
    R4 = [R_ExtMem_High];		
    call F_SPI_ReadNWords;		  
    R3 += R2 lsl 1;
    R4 += 0, carry;
    [R_SPI_Addr_Low] = R3;
    [R_SPI_Addr_High] = R4; 

    pop R1 from [sp];
    retf;
    .endp      
