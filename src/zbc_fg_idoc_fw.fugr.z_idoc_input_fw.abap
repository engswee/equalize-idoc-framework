FUNCTION Z_IDOC_INPUT_FW.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INPUT_METHOD) TYPE  BDWFAP_PAR-INPUTMETHD
*"     REFERENCE(MASS_PROCESSING) TYPE  BDWFAP_PAR-MASS_PROC
*"  EXPORTING
*"     REFERENCE(WORKFLOW_RESULT) TYPE  BDWFAP_PAR-RESULT
*"     REFERENCE(APPLICATION_VARIABLE) TYPE  BDWFAP_PAR-APPL_VAR
*"     REFERENCE(IN_UPDATE_TASK) TYPE  BDWFAP_PAR-UPDATETASK
*"     REFERENCE(CALL_TRANSACTION_DONE) TYPE  BDWFAP_PAR-CALLTRANS
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      WRONG_FUNCTION_CALLED
*"----------------------------------------------------------------------
************************************************************************
  DATA:
    lo_interface      TYPE REF TO zcl_idoc_input,
    ls_edidc          LIKE LINE OF idoc_contrl,
    ls_edids          LIKE LINE OF idoc_status,
    ls_ret_var        LIKE LINE OF return_variables.

  READ TABLE idoc_contrl INTO ls_edidc INDEX 1.
  TRY.
      lo_interface ?= zcl_idoc_input=>get_instance( iv_direction  = ls_edidc-direct
                                                    iv_parnum     = ls_edidc-sndprn
                                                    iv_partyp     = ls_edidc-sndprt
                                                    iv_parfct     = ls_edidc-sndpfc
                                                    iv_mestyp     = ls_edidc-mestyp
                                                    iv_mescod     = ls_edidc-mescod
                                                    iv_mesfct     = ls_edidc-mesfct ).

      lo_interface->execute_inbound(
        EXPORTING
          iv_input_method          = input_method
          iv_mass_processing       = mass_processing
        IMPORTING
          ev_workflow_result       = workflow_result
          ev_application_variable  = application_variable
          ev_in_update_task        = in_update_task
          ev_call_transaction_done = call_transaction_done
        CHANGING
          ct_idoc_contrl           = idoc_contrl[]
          ct_idoc_data             = idoc_data[]
          ct_idoc_status           = idoc_status[]
          ct_return_variables      = return_variables[]
          ct_serialization_info    = serialization_info[] ).

    CATCH cx_sy_create_object_error.
*     Issue error message
*     010(AD) - Error creating IDoc framework object for & &
      ls_edids-docnum = ls_edidc-docnum.
      ls_edids-status = zcl_idoc_base=>c_status_in_err.
      ls_edids-msgty  = zcl_idoc_base=>c_msg_type_error.
      ls_edids-msgid  = 'AD'.
      ls_edids-msgno  = '010'.
      ls_edids-msgv1  = 'Error creating IDoc framework object for'.
      ls_edids-msgv2  = ls_edidc-mestyp.
      ls_edids-msgv3  = ls_edidc-mescod.
      ls_edids-msgv4  = ls_edidc-mesfct.
      APPEND ls_edids TO idoc_status.
*     Set output values
      workflow_result       = zcl_idoc_base=>c_wf_result_err.
      ls_ret_var-wf_param   = zcl_idoc_base=>c_wf_param_err.
      ls_ret_var-doc_number = ls_edidc-docnum.
      APPEND ls_ret_var TO return_variables.

    CATCH zcx_wrong_function_called .
      RAISE wrong_function_called.
  ENDTRY.

* Clear the static reference in base class
  zcl_idoc_input=>free_instance( ).





ENDFUNCTION.
