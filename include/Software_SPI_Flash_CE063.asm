//==========================================================================
// File Name   : SACM_DVR4800_USER.asm
// Description : Users implement functions
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
// Note: 
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
.include GPCE063.inc;

//**************************************************************************
// Contant Defintion Area
//**************************************************************************
//Using IOB as SPI interface
.define	P_SPI_Data					P_IOB_Data
.define	P_SPI_Buffer				P_IOB_Buffer
.define	P_SPI_Dir					P_IOB_Dir
.define	P_SPI_Attrib				P_IOB_Attrib
//----------- SPI Hardware Port Definition -------------
//----------------------------------------------------------------
//Control I/O:
//	  IOB12  ---------  CS
//	  IOB13  ---------  SCK
//    IOB14  ---------  DO
//    IOB15  ---------  DI
//----------------------------------------------------------------
.define B_SPI_DI	0x8000
.define B_SPI_DO	0x4000
.define B_SPI_SCK	0x2000
.define B_SPI_CS	0x1000

//----------- Flash Operation Command Definition -------
.define C_SPI_Flash_Read_CMD		0x03
.define C_SPI_Flash_Block_Erase		0xD8
.define C_SPI_Flash_Sector_Erase	0x20

.define C_SPI_Flash_Chip_Erase		0x60
.define C_SPI_Flash_Page_Program	0x02
.define C_SPI_Flash_Read_Status		0x05
.define C_SPI_Flash_Write_Status	0x01
.define C_SPI_Flash_Write_Enable	0x06
.define C_SPI_Flash_Write_Disable	0x04
.define C_SPI_Flash_Read_ID			0x9F
.define C_SPI_Flash_Fast_Read		0x0B
.define C_SPI_Flash_Power_Down		0xB9
.define C_SPI_Flash_Release_DP		0xAB
.define C_SPI_Flash_Enter_4K		0xA5
.define C_SPI_Flash_Exit_4K			0xB5
.define C_SPI_Flash_Read_ES			0xAB
.define C_SPI_Flash_Read_EMS		0x90
.define C_SPI_Flash_Parallel_Mode	0x55

//----------- Flash Status Port Definition ----------
.define C_Flash_Busy				0x01
.define C_Flash_WEL					0x02		// Write Enable Latch
.define C_Flash_BP0					0x04
.define C_Flash_BP1					0x08
.define C_Flash_BP2					0x10
.define C_Flash_BP3					0x20		
.define C_Flash_PEE					0x40		// Program Erase Error
.define C_Flash_SRWP				0x80		// Status Register Write Protect
//.define C_SPI_BufferSize	128 // be same as that defined in "sacm_DVR4800_user.asm"

//**************************************************************************
// Variable Publication Area
//**************************************************************************

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _SPI_Initial
.public F_SPI_Initial
.public  _SPI_ReadAByte
.public	F_SPI_ReadAByte
.public  _SPI_ReadAWord
.public	F_SPI_ReadAWord
.public  _SPI_ReadNWords
.public F_SPI_ReadNWords
.public  _SPI_SendNWords
.public F_SPI_SendNWords
.public  _Flash_Write_Enable
.public F_Flash_Write_Enable
.public  _Flash_Write_Disable
.public F_Flash_Write_Disable
.public  _SPI_Read_Status_Register
.public F_SPI_Read_Status_Register
.public  _SPI_Enable_Write_Status_Register
.public F_SPI_Enable_Write_Status_Register
.public  _SPI_Write_Status_Register
.public F_SPI_Write_Status_Register	
.public  _SPI_Flash_Block_Erase
.public F_SPI_Flash_Block_Erase
.public  _SPI_Flash_Sector_Erase
.public F_SPI_Flash_Sector_Erase
.public  _SPI_Flash_Chip_Erase
.public F_SPI_Flash_Chip_Erase
.public  _SPI_Read_Flash_ID
.public F_SPI_Read_Flash_ID
.public  _SPI_SendAWord
.public F_SPI_SendAWord


//**************************************************************************
// External Variable Declaration
//**************************************************************************
.external EXT_FLASH_PtrL
.external EXT_FLASH_PtrH

//**************************************************************************
// External Function Declaration
//**************************************************************************

//**************************************************************************
// External Table Declaration
//**************************************************************************

//**************************************************************************
// RAM Definition Area
//**************************************************************************

//*****************************************************************************
// Table Definition Area
//*****************************************************************************


//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE
//****************************************************************
// Function    : F_SPI_Initial
// Description : Initial SPI interface
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
_SPI_Initial: .proc
F_SPI_Initial:
	push R1 to [SP];
// set CS as output buffer high (1,1,1)
// set SCK as output buffer low (1,1,0)
// set DO as output buffer low (1,1,0)
// set DI as input pull low (0,0,0)
	R1 = [P_SPI_Dir];
	R1 |= B_SPI_CS | B_SPI_SCK | B_SPI_DO;
	R1 &= ~B_SPI_DI;
	[P_SPI_Dir] = R1;

	R1 = [P_SPI_Attrib];
	R1 |= B_SPI_CS | B_SPI_SCK | B_SPI_DO;
	R1 &= ~B_SPI_DI;
	[P_SPI_Attrib] = R1;

	R1 = [P_SPI_Data];
	R1 |= B_SPI_CS;
	R1 &= ~(B_SPI_SCK | B_SPI_DO | B_SPI_DI);
	[P_SPI_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//************************************************************************
// Function:  F_SPI_ReadAByte
// Description: Read A Byte from SPI Flash
// Syntax: 
// Parameter:   R1:Address Low Word, R2:Address High Word
// Return:      R1
//************************************************************************
_SPI_ReadAByte: .PROC
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_SPI_ReadAByte:
	push R2, R4 to [SP];
//	R1--input FLASH low,mid address
//	R2--input FLASH hi address
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;

	R3 = R1;	
	R1 = C_SPI_Flash_Read_CMD;
	call F_SPI_Send;
	R1 = R2;
	call F_SPI_Send;
	R1 = R3 lsr 4;
	R1 = R1 lsr 4;
	call F_SPI_Send;
	R1 = R3 & 0x00FF;
	call F_SPI_Send;
	call F_SPI_Read;
	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	pop R2, R4 from [SP];
	retf;
	.endp;

//************************************************************************
// Function:  F_SPI_Send
// Description: Send 8-bit data to SPI
// Syntax: 
// Parameter:   R1:Low byte data which is sent to SPI
// Return:      None
//************************************************************************
F_SPI_Send:
	push R1, R3 to [SP];
	R2 = 0x80;
?L_Send_Data_Loop:
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	test R2, R1;
	jnz ?L_Send_One;
	R3 &= ~B_SPI_DO;
	jmp ?L_Send_Bit_Ready;
?L_Send_One:
	R3 |= B_SPI_DO;
	nop;
	nop;
	nop;
?L_Send_Bit_Ready:
	[P_SPI_Data] = R3;
	R3 |= B_SPI_SCK;
	[P_SPI_Data] = R3;
	R2 = R2 lsr 1;
	jnz ?L_Send_Data_Loop;
	pop R1, R3 from [SP];
	retf;

//************************************************************************
// Function:  F_SPI_Read
// Description: Read 8-bit data from SPI
// Syntax: 
// Parameter:   None
// Return:      R1:Low byte data which is read from SPI
//************************************************************************
F_SPI_Read:
	push R2, R3 to [SP];
	R1 = 0;
	R2 = 8;
?L_Read_Data_Loop:
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	nop;
	nop;
	nop;
	R3 |= B_SPI_SCK;
	[P_SPI_Data] = R3;
	R3 = [P_SPI_Data];
	test R3, B_SPI_DI;
	jz ?L_CheckBitNumber;
	R1 |= 0x0001;
?L_CheckBitNumber:
	R2 -= 1;
	jz ?L_Read_Data_End;
	R1 = R1 lsl 1;
	jmp ?L_Read_Data_Loop;
?L_Read_Data_End:
	pop R2, R3 from [SP];
	retf;

//************************************************************************
// Function:  F_SPI_ReadAWord
// Description: Read A Word from SPI Flash
// Syntax: 
// Parameter:   R1:Address Low Word, R2:Address High Word
// Return:      R1
//************************************************************************
_SPI_ReadAWord:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_SPI_ReadAWord:
	push R2, R4 to [SP];
//	R1--input FLASH low,mid address
//	R2--input FLASH hi address
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R3 = R1;
	R1 = C_SPI_Flash_Read_CMD;
	call F_SPI_Send;
	R1 = R2;
	call F_SPI_Send;
	R1 = R3 lsr 4;
	R1 = R1 lsr 4;
	call F_SPI_Send;
	R1 = R3;
	call F_SPI_Send;
	call F_SPI_Read;
	R4 = R1;
	call F_SPI_Read;
	R1 = R1 lsl 4;
	R1 = R1 lsl 4;
	R1 |= R4;	
	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	
	pop R2, R4 from [SP];
	retf;
	.endp;

//****************************************************************
// Function    : F_SPI_ReadNWords
// Description : Get N words from external memory to buffer
// Destory     : R1, R2, R3, R4
// Parameter   : R1 : buffer address
//               R2 : data length
//               R3 : external memory address low word
//               R4 : external memory address high word
// Return      : None
// Note        : None
//****************************************************************
_SPI_ReadNWords:	.proc
    R4 = SP + 3;
    R1 = [R4++];							// buffer address
    R2 = [R4++];							// data length
    R3 = [R4++];							// external memory address low byte
    R4 = [R4];							// external memory address high byte
F_SPI_ReadNWords:
	push R1, R5 to [SP];
	R5 = [P_SPI_Buffer];		// set CS low
	R5 &= ~B_SPI_CS;
	[P_SPI_Data] = R5;
	R5 &= ~B_SPI_SCK;
	[P_SPI_Data] = R5;

	R5 = R1;
	R1 = C_SPI_Flash_Read_CMD;
	call F_SPI_Send;
	R1 = R4;					// address high byte
	call F_SPI_Send;
	R1 = R3;					// address middle byte
	R1 = R1 lsr 4;
	R1 = R1 lsr 4;
	call F_SPI_Send;
	R1 = R3;					// address low byte
	call F_SPI_Send;
?L_ReadDataLoop:
	call F_SPI_Read;
	R4 = R1;
	call F_SPI_Read;
	R1 = R1 lsl 4;
	R1 = R1 lsl 4;
	R1 |= R4;	
	[R5++] = R1;
	R2 -= 1;
	jnz ?L_ReadDataLoop;
	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	
	pop R1, R5 from [SP];
	retf;
	.endp;

//****************************************************************
// Function    : F_Flash_Write_Enable
// Description : Enable flash to be written or erased
// Destory     : R1, R2, R3
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
_Flash_Write_Enable:	.proc
F_Flash_Write_Enable:
	push R1, R3 to [SP];
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R1 = C_SPI_Flash_Write_Enable;
	call F_SPI_Send;

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	pop R1, R3 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_Flash_Write_Disable
// Description : Disable flash to be written or erased
// Destory     : R1, R2, R3
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
_Flash_Write_Disable:	.proc
F_Flash_Write_Disable:
	push R1, R3 to [SP];
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R1 = C_SPI_Flash_Write_Disable;
	call F_SPI_Send;

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	pop R1, R3 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Read_Status_Register
// Description : Read status register in flash
// Destory     : R1, R2, R3
// Parameter   : None
// Return      : R1 = Value of Status Register
// Note        : None
//****************************************************************
_SPI_Read_Status_Register:	.proc
F_SPI_Read_Status_Register:
	push R2, R3 to [SP];
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R1 = C_SPI_Flash_Read_Status;
	call F_SPI_Send;
	call F_SPI_Read;			// Return Status Register
	
	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	pop R2, R3 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Enable_Write_Status_Register
// Description : Enable status register in flash to be written
// Destory     : R1, R2, R3
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
_SPI_Enable_Write_Status_Register:	.proc
F_SPI_Enable_Write_Status_Register:
	push R1, R3 to [SP];
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R1 = C_SPI_Flash_Write_Status;
	call F_SPI_Send;

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	pop R1, R3 from [SP];
	retf;
	.endp
	
//****************************************************************
// Function    : F_SPI_Write_Status_Register
// Description : Write data to status register in flash 
// Destory     : R1, R2, R3
// Parameter   : R1 = Data to be written into Status Register
// Return      : None
// Note        : None
//****************************************************************
_SPI_Write_Status_Register:	.proc
	R1 = SP + 3;
	R1 = [R1];
F_SPI_Write_Status_Register:
	push R1, R3 to [SP];
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;

	R2 = R1;	
	R1 = C_SPI_Flash_Write_Status;
	call F_SPI_Send;
	R1 = R2 & 0x00FF;
	call F_SPI_Send;

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	pop R1, R3 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Flash_Block_Erase
// Description : Erase one sector of flash
// Destory     : R1, R2, R3, R4
// Parameter   : R1 = Sector Address Low, R2 = Sector Address High
// Return      : None
// Note        : None
//****************************************************************
_SPI_Flash_Block_Erase:	.proc
	R1 = SP + 3;
	R1 = [R1];
F_SPI_Flash_Block_Erase:
	push R1, R5 to [SP];
	call F_Flash_Write_Enable;	// Enable sector erase command 
.if 0		// for GPR25L005, GPR25L010, GPR25L020, GPR25L040, GPR25L080
	R2 = SECTOR_SIZE;
	MR = R1 * R2;
	R1 = R3;
	R2 = R4;
.endif

.if 1		// for GPR25L160, GPR25L320, GPR25L640
	R2 = R1;
	R1 = 0x0000;
.endif

	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R5 = R1;
	R1 = C_SPI_Flash_Block_Erase;
	call F_SPI_Send;
	R1 = R2;
	call F_SPI_Send;
	R1 = R5 lsr 4;
	R1 = R5 lsr 4;
	call F_SPI_Send;
	R1 = R5 & 0x00FF;
	call F_SPI_Send;

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	
?L_Check_Busy:					// Wait untill sector has been erased successfully (about 1 to 3 seconds)
	R1 = C_Watchdog_Clear;
    [P_Watchdog_Clear] = R1;
	call F_SPI_Read_Status_Register;
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy;

	pop R1, R5 from [SP];
	retf;	
	.endp

//****************************************************************
// Function    : F_SPI_Flash_Sector_Erase
// Description : Erase one sector of flash
// Destory     : R1, R2, R3, R4
// Parameter   : R1 = Sector Address Low, R2 = Sector Address High
// Return      : None
// Note        : None
//****************************************************************
_SPI_Flash_Sector_Erase:	.proc
	R1 = SP + 3;
	R1 = [R1];
F_SPI_Flash_Sector_Erase:
	push R1, R5 to [SP];
	call F_Flash_Write_Enable;	// Enable sector erase command 

.comment @		
.if 0		// for GPR25L005, GPR25L010, GPR25L020, GPR25L040, GPR25L080
	R2 = SECTOR_SIZE;
	MR = R1 * R2;
	R1 = R3;
	R2 = R4;
.endif

.if 1		// for GPR25L160, GPR25L320, GPR25L640
	R2 = R1;
	R1 = 0x0000;
.endif
@
	R2 = 0;
	R1 = R1 LSL 4;
	R2 = R2 ROL 4;
	R1 = R1 LSL 4;
	R2 = R2 ROL 4;
	R1 = R1 LSL 4;
	R2 = R2 ROL 4;

	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R5 = R1;
	R1 = C_SPI_Flash_Sector_Erase;
	call F_SPI_Send;
	R1 = R2;
	call F_SPI_Send;
	R1 = R5 lsr 4;
	R1 = R1 lsr 4;
	call F_SPI_Send;
	R1 = R5 & 0x00FF;
	call F_SPI_Send;

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	
?L_Check_Busy:					// Wait untill sector has been erased successfully (about 1 to 3 seconds)
	R1 = C_Watchdog_Clear;
    [P_Watchdog_Clear] = R1;
	call F_SPI_Read_Status_Register;
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy;

	pop R1, R5 from [SP];
	retf;	
	.endp
//****************************************************************
// Function    : F_SPI_Flash_Chip_Erase
// Description :  Erase hole chip of flash 
// Destory     : R1, R2, R3
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
_SPI_Flash_Chip_Erase:	.proc
F_SPI_Flash_Chip_Erase:
	push R1, R3 to [SP];
	call F_Flash_Write_Enable;		// Enable chip erase command 
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R1 = C_SPI_Flash_Chip_Erase;
	call F_SPI_Send;

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
	
?L_Check_Busy:						// Wait untill chip has been erased successfully (about 128 to 256 seconds)
	R1 = C_Watchdog_Clear;
    [P_Watchdog_Clear] = R1;
	call F_SPI_Read_Status_Register;
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy;
	pop R1, R3 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Read_Flash_ID
// Description : Read flash manufacturer,memory and individual device ID 
// Destory     : R1, R2, R3
// Parameter   : None
// Return      : R1 = Manufacturer and memory ID, R2 = Individual Device ID
// Note        : None
//****************************************************************
_SPI_Read_Flash_ID:	.proc
F_SPI_Read_Flash_ID:
	push R2, R3 to [SP];
	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_CS;
	[P_SPI_Data] = R3;
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	
	R1 = C_SPI_Flash_Read_ID;
	call F_SPI_Send;
	call F_SPI_Read;			// Read Manufacturer ID
	push R1 to [SP];
	call F_SPI_Read;			// Read Memory ID
	push R1 to [SP];
	call F_SPI_Read;			// Read Individual Device ID
	R2 = R1;					// Return Individual Device ID
	pop R3 from [SP];
	pop R1 from [SP];
	R3 = R3 lsl 4;
	R3 = R3 lsl 4;
	R1 |= R3;					// Return Memory ID and Manufacturer ID

	R3 = [P_SPI_Buffer];
	R3 &= ~B_SPI_SCK;
	[P_SPI_Data] = R3;
	R3 |= B_SPI_CS;
	[P_SPI_Data] = R3;
	pop R2, R3 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_SendAWord
// Description : Write a word data to flash
// Destory     : R1, R2, R3
// Parameter   : R1 = Address Low, R2 = Address High, R3 = one word of data
// Return      : None
// Note        : None
//****************************************************************
_SPI_SendAWord:	.proc
	R3 = SP + 3;
	R1 = [R3++];
	R2 = [R3++];
	R3 = [R3];
F_SPI_SendAWord:
	push R1, R4 to [SP];
	call F_Flash_Write_Enable;
	R4 = [P_SPI_Buffer];
	R4 &= ~B_SPI_CS;
	[P_SPI_Data] = R4;
	R4 &= ~B_SPI_SCK;
	[P_SPI_Data] = R4;
	
	R4 = R1;
	R1 = C_SPI_Flash_Page_Program;
	call F_SPI_Send;
	R1 = R2;
	call F_SPI_Send;
	R1 = R4 lsr 4;
	R1 = R1 lsr 4;
	call F_SPI_Send;
	R1 = R4 & 0xFF;
	call F_SPI_Send;
	R1 = R3 & 0x00FF;
	call F_SPI_Send;
	R1 = R3 lsr 4;
	R1 = R1 lsr 4;
	call F_SPI_Send; 

	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;

?L_Check_Busy:						// Wait untill one word data has been written into flash successfully (about 3 to 12ms).
	call F_SPI_Read_Status_Register; // WatchDog overflow can escape from dead loop
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy;	

	pop R1, R4 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_SendNWords
// Description : Send N words to external memory from internal buffer
// Destory     : None
// Parameter   : R1 : buffer address
//               R2 : data length
//               R3 : external memory address low word
//               R4 : external memory address high word
// Return      : None
// Note        : None
//****************************************************************
 _SPI_SendNWords:	.proc
	R4 = SP + 4;
	R1 = [R4++];
	R2 = [R4++];
	R3 = [R4++];
	R4 = [R4];
F_SPI_SendNWords:
	push R1, R5 to [SP];

?L_WriteData:
	call F_Flash_Write_Enable;
	R5 = [P_SPI_Buffer];
	R5 &= ~B_SPI_CS;
	[P_SPI_Data] = R5;
	R5 &= ~B_SPI_SCK;
	[P_SPI_Data] = R5;
	
	R5 = R1;
	R1 = C_SPI_Flash_Page_Program;
	call F_SPI_Send;
	R1 = R4 & 0x00FF;
	call F_SPI_Send;
	R1 = R3 lsr 4;			// Address Middle byte
	R1 = R1 lsr 4;
	call F_SPI_Send;
	R1 = R3 & 0x00FF;		// Address low byte
	call F_SPI_Send;

?L_SendDataLoop:
	R1 = [R5++];
	call F_SPI_Send;
	R1 = R1 lsr 4;
	R1 = R1 lsr 4;
	call F_SPI_Send;
	R2 -= 1;
	jz ?L_SendDataEnd;
	R3 += 2;
	test R3, 0x00FF;
	jnz ?L_SendDataLoop;
?L_JumpToNextPage:
	cmp R3, 0x0000;
	jne ?L_WriteCurrentPage;
	R4 += 1;
?L_WriteCurrentPage:
//	setb [P_IOB_Data], C_SPI_CS_IO;	// disable SPI Flash
	R1 = [P_SPI_Buffer];
	R1 &= ~B_SPI_SCK;
	[P_SPI_Data] = R1;
	R1 |= B_SPI_CS;
	[P_SPI_Data] = R1;

?L_Check_Busy_1:					// Wait untill one word data has been written into flash successfully (about 3 to 12ms).
	call F_SPI_Read_Status_Register; // WatchDog overflow can escape from dead loop
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy_1;
	R1 = R5;
	pc = ?L_WriteData;
	
?L_SendDataEnd:
	R2 = [P_SPI_Buffer];
	R2 &= ~B_SPI_SCK;
	[P_SPI_Data] = R2;
	R2 |= B_SPI_CS;
	[P_SPI_Data] = R2;
?L_Check_Busy:						// Wait untill one word data has been written into flash successfully (about 3 to 12ms).
	call F_SPI_Read_Status_Register; // WatchDog overflow can escape from dead loop
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy;

	pop R1, R5 from [SP];
	retf;
	.endp
