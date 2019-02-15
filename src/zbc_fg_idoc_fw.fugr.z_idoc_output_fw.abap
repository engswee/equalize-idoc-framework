FUNCTION Z_IDOC_OUTPUT_FW.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(OBJECT) TYPE  NAST
*"     REFERENCE(CONTROL_RECORD_IN) TYPE  EDIDC
*"  EXPORTING
*"     REFERENCE(CONTROL_RECORD_OUT) TYPE  EDIDC
*"     REFERENCE(OBJECT_TYPE) TYPE  WFAS1-ASGTP
*"  TABLES
*"      INT_EDIDD STRUCTURE  EDIDD
*"  EXCEPTIONS
*"      ERROR_MESSAGE_RECEIVED
*"      DATA_NOT_RELEVANT_FOR_SENDING
*"----------------------------------------------------------------------
DATA:
    lo_interface    TYPE REF TO zcl_idoc_output,
    lo_excp_error   TYPE REF TO zcx_idoc_generic_process_error,
    lo_excp_nosend  TYPE REF TO zcx_idoc_data_not_for_send,
    lv_msg          TYPE string.

  TRY.
      lo_interface ?= zcl_idoc_output=>get_instance( iv_direction  = control_record_in-direct
                                                     iv_parnum     = control_record_in-rcvprn
                                                     iv_partyp     = control_record_in-rcvprt
                                                     iv_parfct     = control_record_in-rcvpfc
                                                     iv_mestyp     = control_record_in-mestyp
                                                     iv_mescod     = control_record_in-mescod
                                                     iv_mesfct     = control_record_in-mesfct ).

      lo_interface->execute_outbound(
        EXPORTING
          is_object   = object
          is_edidc    = control_record_in
        IMPORTING
          es_edidc    = control_record_out
          ev_obj_type = object_type
        CHANGING
          ct_edidd    = int_edidd[] ).

    CATCH cx_sy_create_object_error.
      MESSAGE ID 'AD'
              TYPE zcl_idoc_base=>c_msg_type_error
              NUMBER '010'
              WITH 'Error creating IDoc framework object for'
                   control_record_in-mestyp
                   control_record_in-mescod
                   control_record_in-mesfct
              RAISING error_message_received.

*   Output status error - error during processing
    CATCH zcx_idoc_generic_process_error INTO lo_excp_error.
      IF lo_excp_error->msgid IS NOT INITIAL AND lo_excp_error->msgno IS NOT INITIAL.
        MESSAGE ID lo_excp_error->msgid
                TYPE zcl_idoc_base=>c_msg_type_error
                NUMBER lo_excp_error->msgno
                WITH lo_excp_error->msgv1
                     lo_excp_error->msgv2
                     lo_excp_error->msgv3
                     lo_excp_error->msgv4
                RAISING error_message_received.
      ELSE.
        lv_msg = lo_excp_error->get_text( ).
        MESSAGE lv_msg TYPE zcl_idoc_base=>c_msg_type_error RAISING error_message_received.
      ENDIF.

*   Output status success - not relevant for sending
    CATCH zcx_idoc_data_not_for_send INTO lo_excp_nosend.
      lv_msg = lo_excp_nosend->get_text( ).
      MESSAGE lv_msg TYPE zcl_idoc_base=>c_msg_type_warning RAISING data_not_relevant_for_sending.
  ENDTRY.

* Clear the static reference in base class
  zcl_idoc_output=>free_instance( ).





ENDFUNCTION.
