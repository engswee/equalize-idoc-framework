FUNCTION Z_IDOC_OUTPUT_FW_PORT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      I_EDIDC STRUCTURE  EDIDC
*"----------------------------------------------------------------------
DATA:
    lo_interface  TYPE REF TO zcl_idoc_output,
    lo_excp_error TYPE REF TO zcx_idoc_generic_process_error,
    ls_edidc      LIKE LINE OF i_edidc[],
    lv_msg        TYPE string.

  LOOP AT i_edidc[] INTO ls_edidc.
    TRY.
        lo_interface ?= zcl_idoc_output=>get_instance( iv_direction  = ls_edidc-direct
                                                       iv_parnum     = ls_edidc-rcvprn
                                                       iv_partyp     = ls_edidc-rcvprt
                                                       iv_parfct     = ls_edidc-rcvpfc
                                                       iv_mestyp     = ls_edidc-mestyp
                                                       iv_mescod     = ls_edidc-mescod
                                                       iv_mesfct     = ls_edidc-mesfct ).

        lo_interface->execute_outbound_port( ls_edidc-docnum ).

      CATCH cx_sy_create_object_error.
        MESSAGE ID 'AD'
                TYPE zcl_idoc_base=>c_msg_type_error
                NUMBER '010'
                WITH 'Error creating IDoc framework object for'
                     ls_edidc-mestyp
                     ls_edidc-mescod
                     ls_edidc-mesfct.

*     Error during processing
      CATCH zcx_idoc_generic_process_error INTO lo_excp_error.
        IF lo_excp_error->msgid IS NOT INITIAL AND lo_excp_error->msgno IS NOT INITIAL.
          MESSAGE ID lo_excp_error->msgid
                  TYPE zcl_idoc_base=>c_msg_type_error
                  NUMBER lo_excp_error->msgno
                  WITH lo_excp_error->msgv1
                       lo_excp_error->msgv2
                       lo_excp_error->msgv3
                       lo_excp_error->msgv4.
        ELSE.
          lv_msg = lo_excp_error->get_text( ).
          MESSAGE lv_msg TYPE zcl_idoc_base=>c_msg_type_error.
        ENDIF.
    ENDTRY.

    CLEAR lo_interface.
    zcl_idoc_output=>free_instance( ).
  ENDLOOP.





ENDFUNCTION.
