//isr.asm
.include include/GPCE2P064.inc
.include include/DVR4800.inc



.TEXT


.public _BREAK;

.public _FIQ;

.public _IRQ0;

.public _IRQ1;

.public _IRQ2;

.public _IRQ3;

.public _IRQ4;

.public _IRQ5;

.public _IRQ6;

.public _IRQ7;




_BREAK:
	//add your code here

	reti;


_FIQ:
	push R1, R5 to [SP]; // push registers
	call F_ISR_Service_SACM_DVR4800; // ISR
	R1 = C_IRQ0_TMA;

	[P_INT_Status] = R1;
	pop R1, R5 from [SP]; // pop registers

	reti;


_IRQ0:
	//add your code here

	reti;


_IRQ1:
	//add your code here

	reti;


_IRQ2:
	//add your code here

	reti;


_IRQ3:
	//add your code here

	reti;


_IRQ4:
	//add your code here

	R1 = C_IRQ4_KEY;
	[P_INT_Status] = R1;
	reti;


_IRQ5:
	//add your code here

	reti;


_IRQ6:
	//add your code here

	reti;


_IRQ7:
	//add your code here

	reti;

