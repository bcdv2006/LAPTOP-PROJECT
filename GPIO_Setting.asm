//***************************************************************************************
// Header File Included Area
//***************************************************************************************
.include include/GPCE2P064.inc


//***************************************************************************************
// Function Call Publication Area
//***************************************************************************************
.public  _Setting_IO_OutputLow
.public F_Setting_IO_OutputLow

.public  _Setting_IO_OutputHigh
.public F_Setting_IO_OutputHigh

.public  _Setting_IO_OutputHigh_with_data_inverted
.public F_Setting_IO_OutputHigh_with_data_inverted

.public  _Setting_IO_OutputLow_with_data_inverted
.public F_Setting_IO_OutputLow_with_data_inverted

.public  _Setting_IO_InputFloat
.public F_Setting_IO_InputFloat

.public  _Setting_IO_InputPullLow
.public F_Setting_IO_InputPullLow

.public  _Setting_IO_InputPullHigh
.public F_Setting_IO_InputPullHigh


//***************************************************************************************
// CODE Definition Area
//***************************************************************************************
.CODE
    
//*****************************************************************************
// Function    : F_Setting_IO_as_OutputLow
// Description : Setting IO pins as output low with buffer
// Destroy     : 
// Parameter   : R1: 0 => Set Port A
//                   the others => Set Port B
//               R2: Writing '1' to set corresponding pins as OutputLow 
// Return      : None
// Note        : None
//*****************************************************************************
_Setting_IO_OutputLow:   .proc
    R2 = SP + 3;
    R1 = [R2++];
    R2 = [R2];
F_Setting_IO_OutputLow: 
    push R1, R3 to [sp];
    
    cmp R1, 0;
    jne ?L_SetPortB;

?L_SetPortA:
    R1 = [P_IOA_Buffer];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;
    [P_IOA_Buffer] = R1;  

    R1 = [P_IOA_Attrib];
    R1 |= R2; 
    [P_IOA_Attrib] = R1;
    
    R1 = [P_IOA_Dir]; 
    R1 |= R2;
    [P_IOA_Dir] = R1;  
    
    pop R1, R3 from [sp];
    retf;

?L_SetPortB:
    R1 = [P_IOB_Buffer];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;
    [P_IOB_Buffer] = R1;  

    R1 = [P_IOB_Attrib];
    R1 |= R2; 
    [P_IOB_Attrib] = R1;
    
    R1 = [P_IOB_Dir]; 
    R1 |= R2;
    [P_IOB_Dir] = R1;  
    
    pop R1, R3 from [sp];   
    retf; 
    .endp       
    
//*****************************************************************************
// Function    : F_Setting_IO_OutputHigh
// Description : Setting IO pins as Output high with buffer
// Destroy     : 
// Parameter   : R1: 0 => Set Port A
//                   the others => Set Port B
//               R2: Writing '1' to set corresponding pins as OutputHigh 
// Return      : None
// Note        : None
//*****************************************************************************
_Setting_IO_OutputHigh:   .proc
    R2 = SP + 3;
    R1 = [R2++];
    R2 = [R2];
F_Setting_IO_OutputHigh:
    push R1, R2 to [sp];

    cmp R1, 0;
    jne ?L_SetPortB;

?L_SetPortA:
    R1 = [P_IOA_Buffer];
    R1 |= R2;
    [P_IOA_Buffer] = R1;

    R1 = [P_IOA_Attrib];
    R1 |= R2;
    [P_IOA_Attrib] = R1;

    R1 = [P_IOA_Dir]; 
    R1 |= R2;
    [P_IOA_Dir] = R1;

    pop R1, R2 from [sp];
    retf;

?L_SetPortB:
    R1 = [P_IOB_Buffer];
    R1 |= R2;
    [P_IOB_Buffer] = R1;


    R1 = [P_IOB_Attrib];
    R1 |= R2;
    [P_IOB_Attrib] = R1;

    R1 = [P_IOB_Dir]; 
    R1 |= R2;
    [P_IOB_Dir] = R1;

    pop R1, R2 from [sp];
    retf;
    .endp     
    
//*****************************************************************************
// Function    : F_Setting_IO_OutputHigh_with_data_inverted 
// Description : Setting IO pins as output high with data inverted  
// Destroy     : 
// Parameter   : R1: 0 => Set Port A
//                   the others => Set Port B
//               R2: Writing '1' to set corresponding pins as output high
//                   with data inverted 
// Return      : None
// Note        : None
//*****************************************************************************
_Setting_IO_OutputHigh_with_data_inverted:   .proc
    R2 = SP + 3;
    R1 = [R2++];
    R2 = [R2];
F_Setting_IO_OutputHigh_with_data_inverted: 
    push R1, R3 to [sp];

    cmp R1, 0;
    jne ?L_SetPortB;

?L_SetPortA:
    R1 = [P_IOA_Buffer];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;    
    [P_IOA_Buffer] = R1;

    R1 = [P_IOA_Attrib];
    R1 &= R3; 
    [P_IOA_Attrib] = R1;

    R1 = [P_IOA_Dir]; 
    R1 |= R2;
    [P_IOA_Dir] = R1;

    pop R1, R3 from [sp];
    retf;

?L_SetPortB:
    R1 = [P_IOB_Buffer];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;    
    [P_IOB_Buffer] = R1;

    R1 = [P_IOB_Attrib];
    R1 &= R3; 
    [P_IOB_Attrib] = R1;

    R1 = [P_IOB_Dir]; 
    R1 |= R2;
    [P_IOB_Dir] = R1;

    pop R1, R3 from [sp];
    retf;
    .endp     
    
//*****************************************************************************
// Function    : F_Setting_IO_OutputLow_with_data_inverted 
// Description : Setting IO pins as output low with data inverted  
// Destroy     : 
// Parameter   : R1: 0 => Set Port A
//                   the others => Set Port B
//               R2: Writing '1' to set corresponding pins as output low
//                   with data inverted 
// Return      : None
// Note        : None
//*****************************************************************************
_Setting_IO_OutputLow_with_data_inverted:   .proc
    R2 = SP + 3;
    R1 = [R2++];
    R2 = [R2];
F_Setting_IO_OutputLow_with_data_inverted:
    push R1, R3 to [sp];

    cmp R1, 0;
    jne ?L_SetPortB;

?L_SetPortA:
    R1 = [P_IOA_Buffer];
    R1 |= R2;
    [P_IOA_Buffer] = R1;
    
    R1 = [P_IOA_Attrib];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3; 
    [P_IOA_Attrib] = R1;
    
    R1 = [P_IOA_Dir]; 
    R1 |= R2;
    [P_IOA_Dir] = R1;

    pop R1, R3 from [sp];
    retf;

?L_SetPortB:
    R1 = [P_IOB_Buffer];
    R1 |= R2;
    [P_IOB_Buffer] = R1;
    
    R1 = [P_IOB_Attrib];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3; 
    [P_IOB_Attrib] = R1;
    
    R1 = [P_IOB_Dir]; 
    R1 |= R2;
    [P_IOB_Dir] = R1;

    pop R1, R3 from [sp];
    retf;
    .endp     

//*****************************************************************************
// Function    : F_Setting_IO_InputFloat
// Description : Setting IO pins as input with float
// Destroy     : 
// Parameter   : R1: 0 => Set Port A
//                   the others => Set Port B
//               R2: Writing '1' to set corresponding pins as input with float
// Return      : None
// Note        : None
//*****************************************************************************
_Setting_IO_InputFloat:   .proc
    R2 = SP + 3;
    R1 = [R2++];
    R2 = [R2];
F_Setting_IO_InputFloat:
    push R1, R3 to [sp];

    cmp R1, 0;
    jne ?L_SetPortB;

?L_SetPortA:   
    R1 = [P_IOA_Attrib];
    R1 |= R2; 
    [P_IOA_Attrib] = R1;
    
    R1= [P_IOA_Dir]; 
    R3 = R2 ^ 0xFFFF;
    R1 &= R3; 
    [P_IOA_Dir] = R1; 
    
    pop R1, R3 from [sp];
    retf;    

?L_SetPortB:
    R1 = [P_IOB_Attrib];
    R1 |= R2; 
    [P_IOB_Attrib] = R1;
    
    R1= [P_IOB_Dir]; 
    R3 = R2 ^ 0xFFFF;
    R1 &= R3; 
    [P_IOB_Dir] = R1;   

    pop R1, R3 from [sp];
    retf;
    .endp
    
//*****************************************************************************
// Function    : F_Setting_IO_InputPullLow
// Description : Setting IO pins as Input with pull low  
// Destroy     : 
// Parameter   : R1: 0 => Set Port A
//                   the others => Set Port B
//               R2: Writing '1' to set corresponding pins as input with pull low  
// Return      : None
// Note        : None
//*****************************************************************************
_Setting_IO_InputPullLow:   .proc
    R2 = SP + 3;
    R1 = [R2++];
    R2 = [R2];
F_Setting_IO_InputPullLow: 
    push R1, R3 to [sp];    

    cmp R1, 0;
    jne ?L_SetPortB;

?L_SetPortA:
    R1 = [P_IOA_Buffer];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;     
    [P_IOA_Buffer] = R1;

    R1 = [P_IOA_Attrib];
    R1 &= R3;
    [P_IOA_Attrib] = R1;

    R1 = [P_IOA_Dir]; 
    R1 &= R3;
    [P_IOA_Dir] = R1;

    pop R1, R3 from [sp];
    retf;

?L_SetPortB:
    R1 = [P_IOB_Buffer];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;     
    [P_IOB_Buffer] = R1;

    R1 = [P_IOB_Attrib];
    R1 &= R3;
    [P_IOB_Attrib] = R1;

    R1 = [P_IOB_Dir]; 
    R1 &= R3;
    [P_IOB_Dir] = R1;

    pop R1, R3 from [sp];
    retf;
    .endp    
    
//*****************************************************************************
// Function    : F_Setting_IO_InputPullHigh
// Description : Setting IO pins as Input with pull high 
// Destroy     : 
// Parameter   : R1: 0 => Set Port A
//                   the others => Set Port B
//               R2: Writing '1' to set corresponding pins as input with pull high 
// Return      : None
// Note        : None
//*****************************************************************************
_Setting_IO_InputPullHigh:   .proc
    R2 = SP + 3;
    R1 = [R2++];
    R2 = [R2];
F_Setting_IO_InputPullHigh:
    push R1, R3 to [sp];   
    
    cmp R1, 0;
    jne ?L_SetPortB;

?L_SetPortA:   
    R1 = [P_IOA_Buffer];
    R1 |= R2;
    [P_IOA_Buffer] = R1;

    R1 = [P_IOA_Attrib];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;   
    [P_IOA_Attrib] = R1;

    R1 = [P_IOA_Dir]; 
    R1 &= R3;  
    [P_IOA_Dir] = R1;

    pop R1, R3 from [sp];
    retf;
 

?L_SetPortB:
    R1 = [P_IOB_Buffer];
    R1 |= R2;
    [P_IOB_Buffer] = R1;

    R1 = [P_IOB_Attrib];
    R3 = R2 ^ 0xFFFF;
    R1 &= R3;   
    [P_IOB_Attrib] = R1;

    R1 = [P_IOB_Dir]; 
    R1 &= R3;  
    [P_IOB_Dir] = R1;

    pop R1, R3 from [sp];
    retf;
    .endp    
