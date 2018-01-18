#####################################################################
#																	 
#	Created by u'nSP IDE V3.0.12		09:27:15	01/15/18
#
#####################################################################




APPDIR	= C:\PROGRA~2\GENERA~1\UNSPID~1.12

OUTDIR	= .\Debug

CC	= $(APPDIR)\toolchain\gcc

AS	= $(APPDIR)\toolchain\xasm16

LD	= $(APPDIR)\toolchain\xlink16

AR	= $(APPDIR)\toolchain\xlib16

RESC	= $(APPDIR)\toolchain\resc

RM	= del	/F	1>NUL	2>NUL

STRIP	= $(APPDIR)\toolchain\stripper

INCLUDES	= -I"D:/PROGRAM_LAPTOP_A4800" -I"C:/Program Files (x86)/Generalplus/unSPIDE 3.0.12/library/include" -I"C:/Program Files (x86)/Generalplus/unSPIDE 3.0.12/library/include/sys"

BODY	= -body GPCE2P064A -nobdy -bfile "D:\PROGRAM_LAPTOP_A4800\DEMO_S480.bdy"

BODYFILE	= "D:\PROGRAM_LAPTOP_A4800\DEMO_S480.bdy" 

BINFILE	= "$(OUTDIR)\DEMO_S480.TSK"

BINFILENOEXT	= $(OUTDIR)\DEMO_S480

ARYFILE	= "$(OUTDIR)\DEMO_S480.ary"

SBMFILE	= "$(OUTDIR)\DEMO_S480.sbm"

OPT	= -S -gstabs -Wall -mglobal-var-iram

ASFLAGS	= -t5 -d -sr

CASFLAGS	= -t5 -sr -wpop

CFLAGS	= $(OPT) -B$(APPDIR)\toolchain\ $(INCLUDES) 

BINTYPE	= -at

LDFLAGS	=  -blank 0x00 -infblk "D:\PROGRAM_LAPTOP_A4800\DEMO_S480.inb" -conf "C:\Program Files (x86)\Generalplus\unSPIDE 3.0.12\Body\GPCE\GPCE2P064A\Checksum\GPCE2P064A.cks"

EXTRAFLAGS	= 


OBJFILES	= \
	"$(OUTDIR)\main.obj" \
	"$(OUTDIR)\isr.obj" \
	"$(OUTDIR)\Resource.obj" \
	"$(OUTDIR)\System.obj" \
	"$(OUTDIR)\SPI_Flash_CE2P064.obj" \
	"$(OUTDIR)\GPIO_Setting.obj" \
	"$(OUTDIR)\SACM_DVR4800_User.obj" 

"$(OUTDIR)\main.asm": "D:\PROGRAM_LAPTOP_A4800\main.c" 
	set PATH="$(APPDIR)\toolchain\";%PATH% & \
	$(CC) $(CFLAGS) -o "$(OUTDIR)/main.asm" "D:/PROGRAM_LAPTOP_A4800/main.c" 

"$(OUTDIR)\main.obj": "$(OUTDIR)\main.asm"
	$(AS) $(CASFLAGS) $(INCLUDES) -o "$(OUTDIR)\main.obj" "$(OUTDIR)\main.asm" 

"$(OUTDIR)\isr.obj": "D:\PROGRAM_LAPTOP_A4800\isr.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\isr.obj" "D:\PROGRAM_LAPTOP_A4800\isr.asm" 

"$(OUTDIR)\Resource.obj": "D:\PROGRAM_LAPTOP_A4800\Resource.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\Resource.obj" "D:\PROGRAM_LAPTOP_A4800\Resource.asm" 

"$(OUTDIR)\System.obj": "D:\PROGRAM_LAPTOP_A4800\include\System.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\System.obj" "D:\PROGRAM_LAPTOP_A4800\include\System.asm" 

"$(OUTDIR)\SPI_Flash_CE2P064.obj": "D:\PROGRAM_LAPTOP_A4800\include\SPI_Flash_CE2P064.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\SPI_Flash_CE2P064.obj" "D:\PROGRAM_LAPTOP_A4800\include\SPI_Flash_CE2P064.asm" 

"$(OUTDIR)\GPIO_Setting.obj": "D:\PROGRAM_LAPTOP_A4800\GPIO_Setting.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\GPIO_Setting.obj" "D:\PROGRAM_LAPTOP_A4800\GPIO_Setting.asm" 

"$(OUTDIR)\SACM_DVR4800_User.obj": "D:\PROGRAM_LAPTOP_A4800\include\SACM_DVR4800_User.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\SACM_DVR4800_User.obj" "D:\PROGRAM_LAPTOP_A4800\include\SACM_DVR4800_User.asm" 


.SUFFIXES : .c .asm .obj .s37 .tsk .res

all :	 BEFOREBUILD "$(OUTDIR)" $(BINFILE)

BEFOREBUILD :

"$(OUTDIR)" :
	if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

$(BINFILE) : $(OBJFILES) 
	$(LD) $(BINTYPE) $(ARYFILE) $(BINFILE) $(LDFLAGS) $(BODY) $(EXTRAFLAGS)

compile :	 $(OBJFILES)

clean :
	$(RM) "$(OUTDIR)\main.obj" 
	$(RM) "$(OUTDIR)\main.lst" 
	$(RM) "$(OUTDIR)\main.asm" 
	$(RM) "$(OUTDIR)\isr.obj" 
	$(RM) "$(OUTDIR)\isr.lst" 
	$(RM) "$(OUTDIR)\Resource.obj" 
	$(RM) "$(OUTDIR)\Resource.lst" 
	$(RM) "$(OUTDIR)\System.obj" 
	$(RM) "$(OUTDIR)\System.lst" 
	$(RM) "$(OUTDIR)\SPI_Flash_CE2P064.obj" 
	$(RM) "$(OUTDIR)\SPI_Flash_CE2P064.lst" 
	$(RM) "$(OUTDIR)\GPIO_Setting.obj" 
	$(RM) "$(OUTDIR)\GPIO_Setting.lst" 
	$(RM) "$(OUTDIR)\SACM_DVR4800_User.obj" 
	$(RM) "$(OUTDIR)\SACM_DVR4800_User.lst" 
	$(RM) "$(BINFILENOEXT).s37" "$(BINFILENOEXT).tsk" "$(BINFILENOEXT)_SPI.bin" "$(BINFILENOEXT).hdb" $(SBMFILE) 

.c.asm:
	$(CC) $(CFLAGS) $(INCLUDES) -o "$(OUTDIR)/$@" $<

.asm.obj:
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)/$@" $<

