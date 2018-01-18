//==========================================================================
// File Name   : A3400Pro.inc
// Description : SACM A3400Pro API declaration
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
//==========================================================================
.ifndef __A3400Pro_CH1_INC__
.define __A3400Pro_CH1_INC__

.external F_SACM_A3400Pro_Initial
.external F_SACM_A3400Pro_Play
.external F_SACM_A3400Pro_Stop
.external F_SACM_A3400Pro_Volume
.external F_SACM_A3400Pro_Pause
.external F_SACM_A3400Pro_Resume
.external F_SACM_A3400Pro_Status
.external F_SACM_A3400Pro_ServiceLoop
.external F_ISR_Service_SACM_A3400Pro

.external F_Event_Initial
.external F_Event_ServiceLoop
.external F_IO_Event_Enable
.external F_IO_Event_Disable
.external F_ISR_Event_Service

.endif
//========================================================================================        
// End of SACM_A3400Pro.inc
//========================================================================================