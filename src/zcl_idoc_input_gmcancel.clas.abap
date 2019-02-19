CLASS zcl_idoc_input_gmcancel DEFINITION
  PUBLIC
  INHERITING FROM zcl_idoc_input
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.

    DATA v_mblnr TYPE mkpf-mblnr .
    DATA v_mjahr TYPE mkpf-mjahr .

    METHODS postprocess
        REDEFINITION .
    METHODS preprocess
        REDEFINITION .
    METHODS process_idoc_fm
        REDEFINITION .

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_idoc_input_gmcancel IMPLEMENTATION.


  METHOD postprocess.

    FIELD-SYMBOLS:
      <lfs_edids> LIKE LINE OF me->ref_idoc_status->*.

* Change message returned from BAPI for successful message
    LOOP AT me->ref_idoc_status->* ASSIGNING <lfs_edids>.
      IF ( <lfs_edids>-msgid = 'B1' AND <lfs_edids>-msgno = '501' ). "BAPI & has been called successfully
*     N1ME(259) - Material document & & posted
        <lfs_edids>-msgid = 'AD'.
        <lfs_edids>-msgty = c_msg_type_success.
        <lfs_edids>-msgno = '010'.
        <lfs_edids>-msgv1 = 'Material document cancelled -'.
        <lfs_edids>-msgv2 = me->v_mblnr.
        <lfs_edids>-msgv3 = me->v_mjahr.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "postprocess


  METHOD preprocess.

    FIELD-SYMBOLS:
      <lfs_edidd>    LIKE LINE OF me->ref_idoc_data->*,
      <lfs_e1mbgmca> TYPE e1mbgmca.
    DATA:
       lv_material TYPE matnr.

* Retrieve all the data populated in the extension segment E1BPPAREX and store in instance attribute
    me->extract_extension_data( iv_sort = 'X' ).

* Default preprocessing from configuration
    LOOP AT me->ref_idoc_data->* ASSIGNING <lfs_edidd>.
      CASE <lfs_edidd>-segnam.

        WHEN 'E1MBGMCA'.
          ASSIGN <lfs_edidd>-sdata TO <lfs_e1mbgmca> CASTING.

      ENDCASE.
    ENDLOOP.

* Raise IDoc error if there are any error message collected
    IF me->ref_idoc_status->* IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
    ENDIF.

  ENDMETHOD.


  METHOD process_idoc_fm.

    DATA:
      ls_retvar LIKE LINE OF me->ref_return_variables->*.

    CALL FUNCTION 'IDOC_INPUT_MBGMCA'
      EXPORTING
        input_method          = me->v_input_method
        mass_processing       = me->v_mass_processing
      IMPORTING
        workflow_result       = me->v_workflow_result
        application_variable  = me->v_application_variable
        in_update_task        = me->v_in_update_task
        call_transaction_done = me->v_call_transaction_done
      TABLES
        idoc_contrl           = me->ref_idoc_contrl->*
        idoc_data             = me->ref_idoc_data->*
        idoc_status           = me->ref_idoc_status->*
        return_variables      = me->ref_return_variables->*
        serialization_info    = me->ref_serialization_info->*
      EXCEPTIONS
        wrong_function_called = 1
        error_message         = 2.
    CASE sy-subrc.
      WHEN 0.
*     Process return messages from BAPI - rollback, commit or trigger exception
        me->process_bapi_return( ).
*     If it's successful, get the MatDoc and year
        READ TABLE me->ref_return_variables->* INTO ls_retvar
                   WITH KEY wf_param = c_wf_param_appobj.
        IF sy-subrc = 0.
          me->v_mblnr = ls_retvar-doc_number+00.
          me->v_mjahr = ls_retvar-doc_number+10.
        ENDIF.

      WHEN 1.
        RAISE EXCEPTION TYPE zcx_wrong_function_called.

      WHEN 2.
*     Catch and store any error messages that did not propagate through call stack with RAISING
        me->append_idoc_status( iv_status = c_status_in_err
                                iv_msgty  = c_msg_type_error
                                iv_msgid  = sy-msgid
                                iv_msgno  = sy-msgno
                                iv_msgv1  = sy-msgv1
                                iv_msgv2  = sy-msgv2
                                iv_msgv3  = sy-msgv3
                                iv_msgv4  = sy-msgv4 ).
        me->set_retvar_wf_error( ).
        RAISE EXCEPTION TYPE zcx_idoc_fm_error.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
