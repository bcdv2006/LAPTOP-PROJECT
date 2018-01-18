#include "include/SACM.h"
#include "include/GPCE2P064.h"
#include "FileMerger_laptop_14092017.h"
#define 		VN  						0
#define 		EN  						1
#define 		Manual_Mode_Index		   -1
#define 		Manual 						0
#define 		Auto 						1
#define 		DAC1					    1
#define 		DAC2 						2
#define 		Ramp_Up 					1
#define 		Ramp_Dn 					2
#define 		MaxSpeechNum 				3
#define 		NotNhac 					0
#define 		MauSac  					1
#define 		So 							2
#define 		ChuCai  					0
#define 		Tu  						1
#define 		BaiHat 						2
#define			BASS						3

char kq=0;
char test = 0;
char bass =0;
char daBam =0;
unsigned char dem =0;
unsigned int SaveKey = 0;
int Mode;
char MODE_1,MODE_2,LANG=0;
int *px;
int *py;
unsigned int key =0;
int i,j =0;
int ID_Flash = 0;
int Data_Flash = 0;
unsigned int temp =0;
unsigned int tempA=0;
int SpeechIndex = 0;
unsigned int Key = 0;
void delay(unsigned int timer);
int Scanner();
unsigned char mtp_quetphim();
unsigned int Dem_Sleep = 0;
void Play(unsigned int track);
void PIANO();
void Number(char Lang);
void Color(char Lang);
void DocChuCai(char Lang);
void DocTu(char Lang);
void Music();
void Sleep();
void main()
{
	System_Initial();
	SPI_Initial();
	ID_Flash = SPI_Read_Flash_ID();
	Data_Flash = SPI_ReadAWord(0x00,0x00);
	SACM_DVR4800_Initial();
	asm("NOP");
	SACM_DVR4800_Volume(0x6500);
	USER_DVR4800_SetStartAddr(_CHAO_16K_wav);
	SACM_DVR4800_Play(-1, DAC1+DAC2, Ramp_Up+Ramp_Dn); // Play 1st speech
		
	while(1)
	{
		Key = Scanner();
		if(Key == 0x20)
		{
					
			MODE_1++;
			if(MODE_1 == 3)MODE_1=0;
			if(MODE_1 == ChuCai)
			{
				if(LANG == VN)Play(_ChuDeBangChuCai_16K_wav);
				else if(LANG==EN)Play(_TheAlphabetMode_16K_wav);
			}
			else if(MODE_1 == Tu)
			{
				if(LANG == VN)Play(_ChuDeTuVung_16K_wav);
				else if(LANG==EN)Play(_TheWordMode_16K_wav);
			}
			else if(MODE_1 == BaiHat)
			{
				if(LANG==VN)Play(_ChuDeBaiHat_16K_wav);
				else if(LANG==EN)Play(_TheSongMode_16K_wav);
			}
			delay(10000);
		}
		else if(Key == 0x2A)
		{
			
			MODE_2++;
			if(MODE_2 == 3)MODE_2=0;
			if(MODE_2 == So)
			{
				if(LANG==VN)Play(_ChuDeSoDiem_16K_wav);
				else if(LANG==EN)Play(_TheNumberMode_16K_wav);
			}
			else if(MODE_2 == MauSac)
			{
				if(LANG==VN)Play(_ChuDeMauSac_16K_wav);
				else if(LANG==EN)Play(_TheColorMode_16K_wav);
			}
			else if(MODE_2 == NotNhac)
			{
				if(LANG==VN)Play(_ChuDeDanPiano_16K_wav);
				else if(LANG==EN)Play(_ThePianoMode_16K_wav);			
			}	
			//else if(MODE_2 == BASS)Play(_BASS_1_8K_wav);
			delay(10000);
			daBam = 0;
			bass = 0;
			
		}
		else if(Key == 0x25)
		{
			LANG++;
			if(LANG==2)LANG=0;
			if(LANG == VN)Play(_VIETNAMESE_16K_wav);
			else if(LANG ==EN)Play(_ENGLISH_16K_wav);
			delay(10000);			
		}
		if((Key!=0)&&(Key!=0x20)&&(Key!=0x2A))
		{
			Dem_Sleep = 0;
			if(MODE_2 == So)
			{
				if(LANG == VN)Number(VN);
				else if(LANG == EN)Number(EN);
				
			}
			/*
			else if(MODE_2 == NotNhac)
			{
				PIANO();	
			}
			*/
			else if(MODE_2 == MauSac)
			{
				if(LANG == VN)Color(VN);	
				else if(LANG == EN)Color(EN);
				
			}
			
			
			if(MODE_1 == ChuCai)
			{
				if(LANG == VN)DocChuCai(VN);
				else if(LANG == EN)DocChuCai(EN);
				
			}
			else if(MODE_1 == Tu)
			{
				if(LANG == VN)DocTu(VN);
				else if(LANG == EN)DocTu(EN);
					
			}
			else if(MODE_1==BaiHat)
			{
				Music();	
			}
					
		}
		 if(MODE_2 == NotNhac)
			{
				PIANO();
			}
		Key = 0;	
		System_ServiceLoop(); // Service loop for watchdog clear
		SACM_DVR4800_ServiceLoop(); // Service loop for decode
		Dem_Sleep++;	
		if(Dem_Sleep == 0x2fff)
			{
				Dem_Sleep =0;
				Sleep();
			}
	} 
}


void delay(unsigned int timer)
{ 
for(i = 0;i<timer; i++)
	{
		for(j = 0; j<10;j++)
		{
			SACM_DVR4800_ServiceLoop(); // Service loop for decode
		}	
	}	
}

int Scanner()
{
//////////////HANG 1//////////////////
		Setting_IO_OutputLow(1,0x1F);
		Setting_IO_OutputHigh(1,0x01);
		delay(20);
		
		px = P_IOB_Data;	
		temp = *px;	
		temp &=  0xE0;
		
		py = P_IOA_Data;
		tempA=*py;
		tempA &= 0xFF;		
		
		if(temp==0x20)return 0x10;				
		else if(temp==0x40)return 0x11;
		else if(temp==0x80)return 0x12;
		else if(tempA==0x001)return 0x13;
		else if(tempA==0x004)return 0x00;
		else if(tempA==0x002)return 0x14;
		else if(tempA==0x008)return 0x15;
		else if(tempA==0x010)return 0x16;
		else if(tempA==0x020)return 0x17;
		else if(tempA==0x040)return 0x18;
		else if(tempA==0x080)return	0x19;
		delay(10);

//////////////HANG 2//////////////////
		Setting_IO_OutputLow(1,0x1F);
		Setting_IO_OutputHigh(1,0x02);
		delay(20);
		
		px = P_IOB_Data;	
		temp = *px;	
		temp &=  0xE0;	
		
		py = P_IOA_Data;
		tempA=*py;
		tempA &= 0xFF;
			
		if(temp==0x20)return 0x20;				
		else if(temp==0x40)return 0x21;
		else if(temp==0x80)return 0x22;
		else if(tempA==0x001)return 0x23;
		else if(tempA==0x002)return 0x24;
		else if(tempA==0x004)return 0x25;
		else if(tempA==0x008)return 0x26;
		else if(tempA==0x010)return 0x27;
		else if(tempA==0x020)return 0x28;
		else if(tempA==0x040)return 0x29;
		else if(tempA==0x080)return 0x2A;
		delay(10);	
	//////////////HANG 3//////////////////
		Setting_IO_OutputLow(1,0x1F);
		Setting_IO_OutputHigh(1,0x10);
		delay(20);
		
		px = P_IOB_Data;	
		temp = *px;	
		temp &=  0xE0;
		
		py = P_IOA_Data;
		tempA=*py;
		tempA &= 0xFF;
				
		if(temp==0x20)return 0x30;				
		else if(temp==0x40)return 0x31;
		else if(temp==0x80)return 0x32;
		else if(tempA==0x001)return 0x33;
		else if(tempA==0x002)return 0x34;
		else if(tempA==0x004)return 0x35;
		else if(tempA==0x008)return 0x36;
		else if(tempA==0x010)return 0x37;
		else if(tempA==0x020)return 0x38;
		else if(tempA==0x040)return 0x39;
		else if(tempA==0x080)return	0x3A;
		delay(10);
		
	//////////////HANG 4//////////////////
		Setting_IO_OutputLow(1,0x1F);
		Setting_IO_OutputHigh(1,0x08);
		delay(20);
		
		px = P_IOB_Data;	
		temp = *px;	
		temp &=  0xE0;		
		
		py = P_IOA_Data;
		tempA=*py;
		tempA &= 0xFF;
		
		if(temp==0x20)return 0x40;				
		else if(temp==0x40)return 0x41;
		else if(temp==0x80)return 0x42;
		else if(tempA==0x001)return 0x43;
		else if(tempA==0x002)return 0x44;
		else if(tempA==0x004)return 0x45;
		else if(tempA==0x008)return 0x46;
		else if(tempA==0x010)return 0x47;
		else if(tempA==0x020)return 0x48;
		else if(tempA==0x040)return 0x49;
		else if(tempA==0x080)return	0x4A;
		delay(10);
		
	//////////////HANG 5//////////////////
		Setting_IO_OutputLow(1,0x1F);
		Setting_IO_OutputHigh(1,0x04);
		delay(20);
		
		px = P_IOB_Data;	
		temp = *px;	
		temp &=  0xE0;	
		
		py = P_IOA_Data;
		tempA=*py;
		tempA &= 0xFF;
			
		if(temp==0x20)return 0x50;				
		else if(temp==0x40)return 0x51;
		else if(temp==0x80)return 0x52;
		else if(tempA==0x001)return 0x53;
		else if(tempA==0x002)return 0x54;
		else if(tempA==0x004)return 0x55;
		else if(tempA==0x008)return 0x56;
		else if(tempA==0x010)return 0x57;
		else if(tempA==0x020)return 0x58;
		else if(tempA==0x040)return 0x59;
		else if(tempA==0x080)return	0x5A;
		delay(10);
return 0;	
}
void Play(unsigned int track)
{
		USER_DVR4800_SetStartAddr(track); // Set start address of CH1 speech data
		SACM_DVR4800_Play(Manual_Mode_Index, DAC1+DAC2, Ramp_Up+Ramp_Dn);
}



void PIANO()
{
	if(Key!=0)
		{
			switch(Key)
			{
				case 0x10:
					Play(_PIANO_A1_16K_wav);
					break;
				case 0x11:
					Play(_PIANO_B1_16K_wav);
					break;
				case 0x12:
					Play(_PIANO_C1_16K_wav);
					break;
				case 0x13:
					Play(_PIANO_D1_16K_wav);	
					break;
				case 0x14:
					Play(_PIANO_E1_16K_wav);
					break;
				case 0x15:
					Play(_PIANO_F1_16K_wav);
					break;
				case 0x16:
					Play(_PIANO_G1_16K_wav);
					break;
				case 0x17:
					Play(_PIANO_A2_16K_wav);
					break;
				case 0x18:
					Play(_PIANO_B2_16K_wav);
					break;
				case 0x19:
					Play(_PIANO_C2_16K_wav);
					break;
		}
	}
}
void Number(char Lang)
{
 	if(!Lang)
	 	{
		switch(Key)
				{
					case 0x10:
						Play(_1_VN_16K_wav);
						break;
					case 0x11:
						Play(_2_VN_16K_wav);
						break;
					case 0x12:
						Play(_3_VN_16K_wav);
						break;
					case 0x13:
						Play(_4_VN_16K_wav);	
						break;
					case 0x14:
						Play(_5_VN_16K_wav);
						break;
					case 0x15:
						Play(_6_VN_16K_wav);
						break;
					case 0x16:
						Play(_7_VN_16K_wav);
						break;
					case 0x17:
						Play(_8_VN_16K_wav);
						break;
					case 0x18:
						Play(_9_VN_16K_wav);
						break;
					case 0x19:
						Play(_10_VN_16K_wav);
						break;
				}
	 	}
	 	else 
	 	{
		switch(Key)
				{
					case 0x10:
						Play(_1_EN_16K_wav);
						break;
					case 0x11:
						Play(_2_EN_16K_wav);
						break;
					case 0x12:
						Play(_3_EN_16K_wav);
						break;
					case 0x13:
						Play(_4_EN_16K_wav);	
						break;
					case 0x14:
						Play(_5_EN_16K_wav);
						break;
					case 0x15:
						Play(_6_EN_16K_wav);
						break;
					case 0x16:
						Play(_7_EN_16K_wav);
						break;
					case 0x17:
						Play(_8_EN_16K_wav);
						break;
					case 0x18:
						Play(_9_EN_16K_wav);
						break;
					case 0x19:
						Play(_10_EN_16K_wav);
						break;
				}
	 	}
}
void Color(char Lang)
{
	if(!Lang)
	 	{
		switch(Key)
				{
					case 0x10:
						Play(_MAU_VANG_VN_16K_wav);
						break;
					case 0x11:
						Play(_MAU_CAM_VN_16K_wav);
						break;
					case 0x12:
						Play(_MAU_DO_VN_16K_wav);
						break;
					case 0x13:
						Play(_MAU_HONG_VN_16K_wav);	
						break;
					case 0x14:
						Play(_MAU_TIM_VN_16K_wav);
						break;
					case 0x15:
						Play(_MAU_XANHDUONG_VN_16K_wav);
						break;
					case 0x16:
						Play(_MAU_XANHLA_VN_16K_wav);
						break;
					case 0x17:
						Play(_MAU_NAU_VN_16K_wav);
						break;
					case 0x18:
						Play(_MAU_TRANG_VN_16K_wav);
						break;
					case 0x19:
						Play(_MAU_DEN_VN_16K_wav);
						break;
				}
	 	}
	 	else 
	 	{
		switch(Key)
				{
					case 0x10:
						Play(_MAU_VANG_EN_16K_wav);
						break;
					case 0x11:
						Play(_MAU_CAM_EN_16K_wav);
						break;
					case 0x12:
						Play(_MAU_DO_EN_16K_wav);
						break;
					case 0x13:
						Play(_MAU_HONG_EN_16K_wav);	
						break;
					case 0x14:
						Play(_MAU_TIM_EN_16K_wav);
						break;
					case 0x15:
						Play(_MAU_XANHDUONG_EN_16K_wav);
						break;
					case 0x16:
						Play(_MAU_XANHLA_EN_16K_wav);
						break;
					case 0x17:
						Play(_MAU_NAU_EN_16K_wav);
						break;
					case 0x18:
						Play(_MAU_TRANG_EN_16K_wav);
						break;
					case 0x19:
						Play(_MAU_DEN_EN_16K_wav);
						break;
				}
	 	}
}
void DocChuCai(char Lang)
{
	if(!Lang)
	 	{
		switch(Key)
				{
					case 0x50:
						Play(_A_VN_16K_wav);
						break;
					case 0x51:
						Play(_A2_VN_16K_wav);
						break;
					case 0x52:
						Play(_A1_VN_16K_wav);
						break;
					case 0x53:
						Play(_B_VN_16K_wav);	
						break;
					case 0x54:
						Play(_C_VN_16K_wav);
						break;
					case 0x55:
						Play(_D_VN_16K_wav);
						break;
					case 0x56:
						Play(_D1_VN_16K_wav);
						break;
					case 0x57:
						Play(_E_VN_16K_wav);
						break;
					case 0x58:
						Play(_E1_VN_16K_wav);
						break;
					case 0x59:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x5A:
						Play(_G_VN_16K_wav);
						break;
					case 0x40:
						Play(_H_VN_16K_wav);
						break;
					case 0x41:
						Play(_I_VN_16K_wav);
						break;
					case 0x42:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x43:
						Play(_K_VN_16K_wav);	
						break;
					case 0x44:
						Play(_L_VN_16K_wav);
						break;
					case 0x45:
						Play(_M_VN_16K_wav);
						break;
					case 0x46:
						Play(_N_VN_16K_wav);
						break;
					case 0x47:
						Play(_O_VN_16K_wav);
						break;
					case 0x48:
						Play(_O1_VN_16K_wav);
						break;
					case 0x49:
						Play(_O2_VN_16K_wav);
						break;
					case 0x4A:
						Play(_P_VN_16K_wav);
						break;
					case 0x30:
						Play(_Q_VN_16K_wav);
						break;
					case 0x31:
						Play(_R_VN_16K_wav);
						break;
					case 0x32:
						Play(_S_VN_16K_wav);
						break;
					case 0x33:
						Play(_T_VN_16K_wav);	
						break;
					case 0x34:
						Play(_U_VN_16K_wav);
						break;
					case 0x35:
						Play(_U1_VN_16K_wav);
						break;
					case 0x36:
						Play(_V_VN_16K_wav);
						break;
					case 0x37:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x38:
						Play(_X_VN_16K_wav);
						break;
					case 0x39:
						Play(_Y_VN_16K_wav);
						break;
					case 0x3A:
						Play(_HIEU_UNG_1_16K_wav);
						break;
				}
	 	}
	 	else 
	 	{
		switch(Key)
				{
					case 0x50:
						Play(_A_EN_16K_wav);
						break;
					case 0x51:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x52:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x53:
						Play(_B_EN_16K_wav);	
						break;
					case 0x54:
						Play(_C_EN_16K_wav);
						break;
					case 0x55:
						Play(_D_EN_16K_wav);
						break;
					case 0x56:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x57:
						Play(_E_EN_16K_wav);
						break;
					case 0x58:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x59:
						Play(_F_EN_16K_wav);
						break;
					case 0x5A:
						Play(_G_EN_16K_wav);
						break;
					case 0x40:
						Play(_H_EN_16K_wav);
						break;
					case 0x41:
						Play(_I_EN_16K_wav);
						break;
					case 0x42:
						Play(_J_EN_16K_wav);
						break;
					case 0x43:
						Play(_K_EN_16K_wav);	
						break;
					case 0x44:
						Play(_L_EN_16K_wav);
						break;
					case 0x45:
						Play(_M_EN_16K_wav);
						break;
					case 0x46:
						Play(_N_EN_16K_wav);
						break;
					case 0x47:
						Play(_O_EN_16K_wav);
						break;
					case 0x48:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x49:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x4A:
						Play(_P_EN_16K_wav);
						break;
					case 0x30:
						Play(_Q_EN_16K_wav);
						break;
					case 0x31:
						Play(_R_EN_16K_wav);
						break;
					case 0x32:
						Play(_S_EN_16K_wav);
						break;
					case 0x33:
						Play(_T_EN_16K_wav);	
						break;
					case 0x34:
						Play(_U_EN_16K_wav);
						break;
					case 0x35:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x36:
						Play(_V_EN_16K_wav);
						break;
					case 0x37:
						Play(_W_EN_16K_wav);
						break;
					case 0x38:
						Play(_X_EN_16K_wav);
						break;
					case 0x39:
						Play(_Y_EN_16K_wav);
						break;
					case 0x3A:
						Play(_Z_EN_16K_wav);
						break;
				}
	 	}
}
void DocTu(char Lang)
{
	if(!Lang)
	 	{
		switch(Key)
				{
					case 0x50:
						Play(_A_TU_VN_16K_wav);
						break;
					case 0x51:
						Play(_A1_TU_VN_16K_wav);
						break;
					case 0x52:
						Play(_A2_TU_VN_16K_wav);
						break;
					case 0x53:
						Play(_B_TU_VN_16K_wav);	
						break;
					case 0x54:
						Play(_C_TU_VN_16K_wav);
						break;
					case 0x55:
						Play(_D_TU_VN_16K_wav);
						break;
					case 0x56:
						Play(_D1_TU_VN_16K_wav);
						break;
					case 0x57:
						Play(_E_TU_VN_16K_wav);
						break;
					case 0x58:
						Play(_E1_TU_VN_16K_wav);
						break;
					case 0x59:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x5A:
						Play(_G_TU_VN_16K_wav);
						break;
					case 0x40:
						Play(_H_TU_VN_16K_wav);
						break;
					case 0x41:
						Play(_I_TU_VN_16K_wav);
						break;
					case 0x42:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x43:
						Play(_K_TU_VN_16K_wav);	
						break;
					case 0x44:
						Play(_L_TU_VN_16K_wav);
						break;
					case 0x45:
						Play(_M_TU_VN_16K_wav);
						break;
					case 0x46:
						Play(_N_TU_VN_16K_wav);
						break;
					case 0x47:
						Play(_O_TU_VN_16K_wav);
						break;
					case 0x48:
						Play(_O1_TU_VN_16K_wav);
						break;
					case 0x49:
						Play(_O2_TU_VN_16K_wav);
						break;
					case 0x4A:
						Play(_P_TU_VN_16K_wav);
						break;
					case 0x30:
						Play(_Q_TU_VN_16K_wav);
						break;
					case 0x31:
						Play(_R_TU_VN_16K_wav);
						break;
					case 0x32:
						Play(_S_TU_VN_16K_wav);
						break;
					case 0x33:
						Play(_T_TU_VN_16K_wav);	
						break;
					case 0x34:
						Play(_U_TU_VN_16K_wav);
						break;
					case 0x35:
						Play(_U1_TU_VN_16K_wav);
						break;
					case 0x36:
						Play(_V_TU_VN_16K_wav);
						break;
					case 0x37:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x38:
						Play(_X_TU_VN_16K_wav);
						break;
					case 0x39:
						Play(_Y_TU_VN_16K_wav);
						break;
					case 0x3A:
						Play(_HIEU_UNG_1_16K_wav);
						break;
				}
	 	}
	 	else 
	 	{
		switch(Key)
				{
					case 0x50:
						Play(_A_TU_EN_16K_wav);
						break;
					case 0x51:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x52:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x53:
						Play(_B_TU_EN_16K_wav);	
						break;
					case 0x54:
						Play(_C_TU_EN_16K_wav);
						break;
					case 0x55:
						Play(_D_TU_EN_16K_wav);
						break;
					case 0x56:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x57:
						Play(_E_TU_EN_16K_wav);
						break;
					case 0x58:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x59:
						Play(_F_TU_EN_16K_wav);
						break;
					case 0x5A:
						Play(_G_TU_EN_16K_wav);
						break;
					case 0x40:
						Play(_H_TU_EN_16K_wav);
						break;
					case 0x41:
						Play(_I_TU_EN_16K_wav);
						break;
					case 0x42:
						Play(_J_TU_EN_16K_wav);
						break;
					case 0x43:
						Play(_K_TU_EN_16K_wav);	
						break;
					case 0x44:
						Play(_L_TU_EN_16K_wav);
						break;
					case 0x45:
						Play(_M_TU_EN_16K_wav);
						break;
					case 0x46:
						Play(_N_TU_EN_16K_wav);
						break;
					case 0x47:
						Play(_O_TU_EN_16K_wav);
						break;
					case 0x48:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x49:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x4A:
						Play(_P_TU_EN_16K_wav);
						break;
					case 0x30:
						Play(_Q_TU_EN_16K_wav);
						break;
					case 0x31:
						Play(_R_TU_EN_16K_wav);
						break;
					case 0x32:
						Play(_S_TU_EN_16K_wav);
						break;
					case 0x33:
						Play(_T_TU_EN_16K_wav);	
						break;
					case 0x34:
						Play(_U_TU_EN_16K_wav);
						break;
					case 0x35:
						Play(_HIEU_UNG_1_16K_wav);
						break;
					case 0x36:
						Play(_V_TU_EN_16K_wav);
						break;
					case 0x37:
						Play(_W_TU_EN_16K_wav);
						break;
					case 0x38:
						Play(_X_TU_EN_16K_wav);
						break;
					case 0x39:
						Play(_Y_TU_EN_16K_wav);
						break;
					case 0x3A:
						Play(_Z_TU_EN_16K_wav);
						break;
				}
	 	}
}
void Music()
{
	switch(Key)
				{
					case 0x50:
					
						Play(_SONG3_16K_wav);
						break;
					case 0x51:
					
						Play(_SONG5_16K_wav);
						break;
					case 0x52:
					
						Play(_SONG1_16K_wav);
						break;
					case 0x53:
					
						Play(_SONG7_16K_wav);	
						break;
					case 0x54:
					
						Play(_SONG2_16K_wav);
						break;
					case 0x55:
				
						Play(_SONG7_16K_wav);
						break;
					case 0x56:
				
						Play(_SONG4_16K_wav);
						break;
					case 0x57:
				
						Play(_SONG7_16K_wav);
						break;
					case 0x58:
				
						Play(_SONG6_16K_wav);
						break;
					case 0x59:
				
						Play(_SONG3_16K_wav);
						break;
					case 0x5A:
					
						Play(_SONG2_16K_wav);
						break;
					case 0x40:
				
						Play(_SONG1_16K_wav);
						break;
					case 0x41:
				
						Play(_SONG2_16K_wav);
						break;
					case 0x42:
				
						Play(_SONG3_16K_wav);
						break;
					case 0x43:
				
						Play(_SONG4_16K_wav);	
						break;
					case 0x44:
				
						Play(_SONG5_16K_wav);
						break;
					case 0x45:
				
						Play(_SONG6_16K_wav);
						break;
					case 0x46:
				
						Play(_SONG7_16K_wav);
						break;
					case 0x47:
				
						Play(_SONG6_16K_wav);
						break;
					case 0x48:
				
						Play(_SONG1_16K_wav);
						break;
					case 0x49:
				
						Play(_SONG2_16K_wav);
						break;
					case 0x4A:
				
						Play(_SONG4_16K_wav);
						break;
					case 0x30:
				
						Play(_SONG7_16K_wav);
						break;
					case 0x31:
				
						Play(_SONG5_16K_wav);
						break;
					case 0x32:
				
						Play(_SONG7_16K_wav);
						break;
					case 0x33:
				
						Play(_SONG5_16K_wav);	
						break;
					case 0x34:
				
						Play(_SONG2_16K_wav);
						break;
					case 0x35:
				
						Play(_SONG6_16K_wav);
						break;
					case 0x36:
				
						Play(_SONG1_16K_wav);
						break;
					case 0x37:
				
						Play(_SONG3_16K_wav);
						break;
					case 0x38:
				
						Play(_SONG6_16K_wav);
						break;
					case 0x39:
				
						Play(_SONG7_16K_wav);
						break;
					case 0x3A:
				
						Play(_SONG4_16K_wav);
						break;
				}	
}
void Sleep()
{
	Play(_TAT_NGUON_16K_wav);
	while(SACM_DVR4800_Status() & 0x01)
		{
			System_ServiceLoop(); // Service loop for watchdog clear
			SACM_DVR4800_ServiceLoop(); // Service loop for CH1 decode
		}
	Setting_IO_InputPullLow(0, 0xFFFF);
	Setting_IO_InputPullLow(1, 0xFFFF);

	px = P_INT_Ctrl;
	*px = C_IRQ4_KEY;
	//Clear INT status Flag
	px = P_INT_Status;
	*px = 0xffff;
	//Enter Standby mode
	px = P_System_Sleep;
	*px = 0x5555;
	
}

