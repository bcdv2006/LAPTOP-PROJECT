//==========================================================================
// File Name   : A3400Pro.inc
// Description : SACM A3400Pro API declaration
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
//==========================================================================
.ifndef __A3400Pro_CH2_INC__
.define __A3400Pro_CH2_INC__

.external F_SACM_A3400Pro_CH2_Initial
.external F_SACM_A3400Pro_CH2_Play
.external F_SACM_A3400Pro_CH2_Stop
.external F_SACM_A3400Pro_CH2_Volume
.external F_SACM_A3400Pro_CH2_Pause
.external F_SACM_A3400Pro_CH2_Resume
.external F_SACM_A3400Pro_CH2_Status
.external F_SACM_A3400Pro_CH2_ServiceLoop
.external F_ISR_Service_SACM_A3400Pro_CH2

.external F_Event_CH2_Initial
.external F_Event_CH2_ServiceLoop
.external F_IO_Event_CH2_Enable
.external F_IO_Event_CH2_Disable
.external F_ISR_Event_CH2_Service

.endif
//========================================================================================        
// End of SACM_A3400Pro.inc
//========================================================================================