[ARCH]
BODY=GPCE2P064A;
SEC=RAM,0,7FF,W;
SEC=FLASH,8000,FBFF,F;
SEC=SysROM,FC00,FFEF,F;
SEC=Interrupt,FFF0,FFFF,F;
SEC=I/O,2000,27FF,W;
BANK=1,FFFF;
CPUTYPE=unsp002;
DMAENABLE=1;
USB_SLEEP=14;
DEFAULTISAVER=ISA13;
MEMORYTYPE=GeneralFlash;
LOCATE=IRQVec,FFF5;
--ISA1.3 clock divider is fixed to 0x06 -----
---USB_SCK_SEL is used for ProbeI ---;
USB_SCK_SEL=2;
MaskOptionEnable=1;
SupportProbeI=0;
SumWholeBin=1;
CKSFilePath=Body\GPCE\GPCE2P064A\Checksum\GPCE2P064A.cks;
---DISABLECOMPILEROPTIMIZE is also used to set Near compiler as default value---;
DISABLECOMPILEROPTIMIZE=1;
DISABLEICESOFTBP=1;
DISABLEOUTPUTONLY=1;
