class ZCL_IDOC_INPUT definition
  public
  inheriting from ZCL_IDOC_BASE
  abstract
  create public .

public section.
*"* public components of class ZCL_IDOC_INPUT
*"* do not include other source files here!!!

  methods EXECUTE_INBOUND
    importing
      !IV_INPUT_METHOD type BDWFAP_PAR-INPUTMETHD
      !IV_MASS_PROCESSING type BDWFAP_PAR-MASS_PROC
    exporting
      !EV_WORKFLOW_RESULT type BDWF_PARAM-RESULT
      !EV_APPLICATION_VARIABLE type BDWF_PARAM-APPL_VAR
      !EV_IN_UPDATE_TASK type BDWFAP_PAR-UPDATETASK
      !EV_CALL_TRANSACTION_DONE type BDWFAP_PAR-CALLTRANS
    changing
      !CT_IDOC_CONTRL type EDIDC_TT
      !CT_IDOC_DATA type EDIDD_TT
      !CT_IDOC_STATUS type BDTIDOCSTA
      !CT_RETURN_VARIABLES type BDTWFRETVA
      !CT_SERIALIZATION_INFO type BDTI_SER
    raising
      ZCX_WRONG_FUNCTION_CALLED .
protected section.
*"* protected components of class ZCL_IDOC_INPUT
*"* do not include other source files here!!!

  types:
    BEGIN OF ty_vendor_serial_items ,
          ebelp TYPE ekpo-ebelp,
          matnr TYPE equi-matnr,
          serge TYPE equi-serge,
          sernr TYPE equi-sernr,
        END OF ty_vendor_serial_items .
  types:
    ty_t_vendor_serial_items TYPE STANDARD TABLE OF ty_vendor_serial_items .

  data V_INPUT_METHOD type BDWFAP_PAR-INPUTMETHD .
  data V_MASS_PROCESSING type BDWFAP_PAR-MASS_PROC .
  data V_WORKFLOW_RESULT type BDWF_PARAM-RESULT .
  data V_APPLICATION_VARIABLE type BDWF_PARAM-APPL_VAR .
  data V_IN_UPDATE_TASK type BDWFAP_PAR-UPDATETASK .
  data V_CALL_TRANSACTION_DONE type BDWFAP_PAR-CALLTRANS .
  data REF_IDOC_CONTRL type ref to EDIDC_TT .
  data REF_IDOC_DATA type ref to EDIDD_TT .
  data REF_IDOC_STATUS type ref to BDTIDOCSTA .
  data REF_RETURN_VARIABLES type ref to BDTWFRETVA .
  data REF_SERIALIZATION_INFO type ref to BDTI_SER .
  data S_EDIDC type EDIDC .
  data V_COMMIT_IDOC_FM type XFELD .
  data:
    T_EXTENSION TYPE STANDARD TABLE OF E1BPPAREX .
  data T_VENDOR_SERIAL type TY_T_VENDOR_SERIAL_ITEMS .

  methods INIT .
  methods VALIDATION_CHECK
    raising
      ZCX_IDOC_VALIDATION_ERROR .
  methods UPDATE_LOGS
    importing
      !IV_STATUS type EDI_STATUS .
  methods APPEND_IDOC_STATUS
    importing
      !IV_STATUS type EDI_STATUS
      !IV_MSGTY type SYMSGTY
      !IV_MSGID type MSGID
      !IV_MSGNO type ANY
      !IV_MSGV1 type ANY optional
      !IV_MSGV2 type ANY optional
      !IV_MSGV3 type ANY optional
      !IV_MSGV4 type ANY optional
      !IV_SEGNUM type IDOCSSGNUM optional
      !IV_SEGFLD type ANY optional
      !IV_LOGNO type EDI_ALOG optional .
  methods SET_RETVAR_WF_ERROR .
  methods POPULATE_DEFAULT_FIELDS
    importing
      !IS_INPUT type ANY
      !IV_DEFAULT_VALUE type CHAR1 default '/'
    changing
      !CS_OUTPUT type ANY .
  methods SET_COMMIT_FLAG
    importing
      !IV_COMMIT type XFELD .
  methods CREATE_BATCH
    importing
      !IV_MATNR type MCHB-MATNR
      !IV_WERKS type MCHB-WERKS
      !IV_CHARG type MCHB-CHARG
      !IV_LGORT type MCHB-LGORT optional
      !IV_VENDOR_BATCH type MCHA-LICHA optional
      !IV_EXPIRY_DATE type MCHA-VFDAT optional
      !IV_BATCH_ATTR type BAPIBATCHATT optional
      !IV_COMMIT type XFELD default 'X'
    returning
      value(RV_SUBRC) type SY-SUBRC .
  methods CREATE_SERIAL
    exporting
      !EV_SUBRC type SY-SUBRC
    changing
      !CT_VENDOR_SERIAL type TY_T_VENDOR_SERIAL_ITEMS .
  methods CREATE_CLASSIFICATION
    importing
      !IV_OBJKEY type BAPI1003_KEY-OBJECT
      !IV_OBJTABLE type BAPI1003_KEY-OBJECTTABLE
      !IV_CLASSNUM type BAPI1003_KEY-CLASSNUM
      !IV_CLASSTYPE type BAPI1003_KEY-CLASSTYPE
      !IV_COMMIT type XFELD default 'X'
    returning
      value(RV_SUBRC) type SY-SUBRC .
  methods EXTRACT_EXTENSION_DATA
    importing
      !IV_SORT type XFELD optional .
  methods PROCESS_BAPI_RETURN
    raising
      ZCX_IDOC_FM_ERROR .
  methods PROCESS_IDOC_FM
  abstract
    raising
      ZCX_WRONG_FUNCTION_CALLED
      ZCX_IDOC_FM_ERROR .
  methods PREPROCESS
  abstract
    raising
      ZCX_IDOC_PREPROCESS_ERROR .
  methods POSTPROCESS
  abstract
    raising
      ZCX_IDOC_POSTPROCESS_ERROR .
private section.
*"* private components of class ZCL_IDOC_INPUT
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IDOC_INPUT IMPLEMENTATION.


method APPEND_IDOC_STATUS.

  DATA:
    ls_edids LIKE LINE OF me->ref_idoc_status->*.

  ls_edids-docnum   = me->s_edidc-docnum.
  ls_edids-status   = iv_status.
  ls_edids-msgty    = iv_msgty.
  ls_edids-msgid    = iv_msgid.
  ls_edids-msgno    = iv_msgno.
  ls_edids-msgv1    = iv_msgv1.
  ls_edids-msgv2    = iv_msgv2.
  ls_edids-msgv3    = iv_msgv3.
  ls_edids-msgv4    = iv_msgv4.
  ls_edids-segnum   = iv_segnum.
  ls_edids-segfld   = iv_segfld.
  ls_edids-appl_log = iv_logno.
  APPEND ls_edids TO me->ref_idoc_status->*.

endmethod.


method CREATE_BATCH.

  DATA:
    ls_batchatt  TYPE bapibatchatt,
    lt_bapiret   TYPE STANDARD TABLE OF bapiret2.
  FIELD-SYMBOLS:
    <lfs_bapiret>  LIKE LINE OF lt_bapiret.

* Populate values passed by optional parameters
  ls_batchatt            = iv_batch_attr.
  ls_batchatt-expirydate = iv_expiry_date.
  ls_batchatt-vendrbatch = iv_vendor_batch.

  CALL FUNCTION 'BAPI_BATCH_CREATE'
    EXPORTING
      material             = iv_matnr
      batch                = iv_charg
      plant                = iv_werks
      batchattributes      = ls_batchatt
      batchstoragelocation = iv_lgort        "Optional
    TABLES
      return               = lt_bapiret.

* Rollback if there is abort message
  READ TABLE lt_bapiret TRANSPORTING NO FIELDS
                        WITH KEY type = c_msg_type_abort.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
* Populate IDoc error if failure during Batch creation and set RC = 4
  LOOP AT lt_bapiret ASSIGNING <lfs_bapiret> WHERE type = c_msg_type_error
                                                OR type = c_msg_type_abort.
    me->append_idoc_status( iv_status = c_status_in_err
                            iv_msgty  = c_msg_type_error
                            iv_msgid  = <lfs_bapiret>-id
                            iv_msgno  = <lfs_bapiret>-number
                            iv_msgv1  = <lfs_bapiret>-message_v1
                            iv_msgv2  = <lfs_bapiret>-message_v2
                            iv_msgv3  = <lfs_bapiret>-message_v3
                            iv_msgv4  = <lfs_bapiret>-message_v4 ).
  ENDLOOP.
  IF sy-subrc = 0.
    rv_subrc = 4.
  ELSEIF iv_commit = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    SET UPDATE TASK LOCAL. "Set back LUW to local update after commit
  ENDIF.

endmethod.


method CREATE_CLASSIFICATION.

  DATA:
    lt_num        TYPE STANDARD TABLE OF bapi1003_alloc_values_num,
    lt_char       TYPE STANDARD TABLE OF bapi1003_alloc_values_char,
    lt_curr       TYPE STANDARD TABLE OF bapi1003_alloc_values_curr,
    lt_bapiret    TYPE STANDARD TABLE OF bapiret2.
  FIELD-SYMBOLS:
    <lfs_bapiret>  LIKE LINE OF lt_bapiret.

  CALL FUNCTION 'BAPI_OBJCL_CHANGE'
    EXPORTING
      objectkey          = iv_objkey
      objecttable        = iv_objtable
      classnum           = iv_classnum
      classtype          = iv_classtype
    TABLES
      allocvaluesnumnew  = lt_num
      allocvaluescharnew = lt_char
      allocvaluescurrnew = lt_curr
      return             = lt_bapiret.

* Rollback if there is abort message
  READ TABLE lt_bapiret TRANSPORTING NO FIELDS
                        WITH KEY type = c_msg_type_abort.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
* Populate IDoc error if failure during classification creation and set RC = 4
  LOOP AT lt_bapiret ASSIGNING <lfs_bapiret> WHERE type = c_msg_type_error
                                                OR type = c_msg_type_abort.
    me->append_idoc_status( iv_status = c_status_in_err
                            iv_msgty  = c_msg_type_error
                            iv_msgid  = <lfs_bapiret>-id
                            iv_msgno  = <lfs_bapiret>-number
                            iv_msgv1  = <lfs_bapiret>-message_v1
                            iv_msgv2  = <lfs_bapiret>-message_v2
                            iv_msgv3  = <lfs_bapiret>-message_v3
                            iv_msgv4  = <lfs_bapiret>-message_v4 ).
  ENDLOOP.
  IF sy-subrc = 0.
*   Error creating classification for object & & & &
    me->append_idoc_status( iv_status = c_status_in_err
                            iv_msgty  = c_msg_type_error
                            iv_msgid  = 'AD'
                            iv_msgno  = '010'
							iv_msgv1  = 'Error creating classification for object'
                            iv_msgv2  = iv_objkey
                            iv_msgv3  = iv_objtable
                            iv_msgv4  = iv_classnum ).
    rv_subrc = 4.
  ELSEIF iv_commit = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    SET UPDATE TASK LOCAL. "Set back LUW to local update after commit
  ENDIF.

endmethod.


method CREATE_SERIAL.

  DATA:
    lt_serial_objects TYPE itob_object_tab,
    ls_serial_object  LIKE LINE OF lt_serial_objects.

  FIELD-SYMBOLS:
    <lfs_vendor_serial> LIKE LINE OF ct_vendor_serial.

  LOOP AT ct_vendor_serial ASSIGNING <lfs_vendor_serial>.
    ls_serial_object-eqtyp = 'S'.       "Customer equipment
    ls_serial_object-serge = <lfs_vendor_serial>-serge.
    ls_serial_object-matnr = <lfs_vendor_serial>-matnr.
    APPEND ls_serial_object TO lt_serial_objects.
  ENDLOOP.

  CALL FUNCTION 'ITOB_SERIALNO_CREATE'
    EXPORTING
      i_convert_full_equi = 'X'
      i_commit_work       = 'S'     "Synchronous commit
    CHANGING
      c_object_tab        = lt_serial_objects
    EXCEPTIONS
      not_successful      = 1
      OTHERS              = 2.
  IF sy-subrc = 0.
*   Update the created serial numbers into the table
    SORT lt_serial_objects BY matnr serge.
    LOOP AT ct_vendor_serial ASSIGNING <lfs_vendor_serial>.
      READ TABLE lt_serial_objects INTO ls_serial_object
                                   WITH KEY matnr = <lfs_vendor_serial>-matnr
                                            serge = <lfs_vendor_serial>-serge
                                   BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_vendor_serial>-sernr = ls_serial_object-sernr.
      ENDIF.
    ENDLOOP.
    ev_subrc = 0.
    SET UPDATE TASK LOCAL. "Set back LUW to local update after commit
  ELSE.
*   Populate IDoc error if failure during serial creation and set RC = 4
    me->append_idoc_status( iv_status = c_status_in_err
                            iv_msgty  = c_msg_type_error
                            iv_msgid  = sy-msgid
                            iv_msgno  = sy-msgno
                            iv_msgv1  = sy-msgv1
                            iv_msgv2  = sy-msgv2
                            iv_msgv3  = sy-msgv3
                            iv_msgv4  = sy-msgv4 ).
    ev_subrc = 4.
  ENDIF.

endmethod.


method EXECUTE_INBOUND.

* Set attributes from importing & changing parameters
  me->v_input_method          = iv_input_method.
  me->v_mass_processing       = iv_mass_processing.
* Store data reference to tables to avoid copy cost
  GET REFERENCE OF ct_idoc_contrl         INTO me->ref_idoc_contrl.
  GET REFERENCE OF ct_idoc_data           INTO me->ref_idoc_data.
  GET REFERENCE OF ct_idoc_status         INTO me->ref_idoc_status.
  GET REFERENCE OF ct_return_variables    INTO me->ref_return_variables.
  GET REFERENCE OF ct_serialization_info  INTO me->ref_serialization_info.

  TRY .
      me->init( ).

      me->validation_check( ).

      me->preprocess( ).

      me->process_idoc_fm( ).

      me->postprocess( ).

      me->update_logs( c_status_in_succ ).

    CATCH ZCX_IDOC_VALIDATION_ERROR ZCX_IDOC_PREPROCESS_ERROR.
      me->update_logs( c_status_in_err ).
*     For validation and preprocess error, need to additionally set the exporting parameters
      me->set_retvar_wf_error( ).

    CATCH ZCX_IDOC_FM_ERROR ZCX_IDOC_POSTPROCESS_ERROR.
      me->update_logs( c_status_in_err ).

  ENDTRY.

* Update exporting parameters
* Changing parameters do not need direct updating as they are modified by reference
  ev_workflow_result        = me->v_workflow_result.
  ev_application_variable   = me->v_application_variable.
  ev_in_update_task         = me->v_in_update_task.
  ev_call_transaction_done  = me->v_call_transaction_done.

endmethod.


method EXTRACT_EXTENSION_DATA.

  DATA:
    ls_extension LIKE LINE OF me->t_extension.
  FIELD-SYMBOLS:
    <lfs_edidd>  LIKE LINE OF me->ref_idoc_data->*.

* Get the initial line where the Extension segment starts for looping later
* Can't do binary search because the IDoc data table is not sorted by segment name
  READ TABLE me->ref_idoc_data->* TRANSPORTING NO FIELDS
                                  WITH KEY segnam = 'E1BPPAREX'.
  IF sy-subrc = 0.
    LOOP AT me->ref_idoc_data->* ASSIGNING <lfs_edidd> FROM sy-tabix.
      CASE <lfs_edidd>-segnam.
        WHEN 'E1BPPAREX'.
          ls_extension = <lfs_edidd>-sdata.
          APPEND ls_extension TO me->t_extension.
        WHEN OTHERS.
          EXIT. "Exit the loop once finish processing the Extension segments
      ENDCASE.
    ENDLOOP.
  ENDIF.

  IF iv_sort = 'X'.
    SORT me->t_extension.
  ENDIF.

endmethod.


method INIT.

  READ TABLE me->ref_idoc_contrl->* INTO me->s_edidc INDEX 1.

* Get the new/active singleton for the buffer object
  me->o_buffer = ZCL_IDOC_DB_BUFFER=>get_instance( ).

endmethod.


method POPULATE_DEFAULT_FIELDS.

  DATA:
    lo_struct_chg         TYPE REF TO cl_abap_structdescr,
    ls_component_chg      LIKE LINE OF lo_struct_chg->components.
  FIELD-SYMBOLS:
    <lfs_fieldvalue_in>   TYPE any,
    <lfs_fieldvalue_chg>  TYPE any.

* Get the structure of the output parameter
  lo_struct_chg ?= cl_abap_typedescr=>describe_by_data( cs_output ).

* Loop through all the fields of the output structure
  LOOP AT lo_struct_chg->components INTO ls_component_chg.
    ASSIGN COMPONENT sy-tabix OF STRUCTURE cs_output TO <lfs_fieldvalue_chg>.
*   If the field is populated with default indicator, then get the default value from the
*   corresponding field of the input structure
    IF sy-subrc = 0 AND <lfs_fieldvalue_chg> = iv_default_value.
      ASSIGN COMPONENT ls_component_chg-name OF STRUCTURE is_input TO <lfs_fieldvalue_in>.
      IF sy-subrc = 0.
        <lfs_fieldvalue_chg> = <lfs_fieldvalue_in>.
      ENDIF.
    ENDIF.
  ENDLOOP.

endmethod.


method PROCESS_BAPI_RETURN.

* Case 1 - Abort message, rollback then raise exception
  READ TABLE me->ref_idoc_status->* TRANSPORTING NO FIELDS
                                    WITH KEY msgty = c_msg_type_abort.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    RAISE EXCEPTION TYPE ZCX_IDOC_FM_ERROR.
  ENDIF.

* Case 2 - Error message, raise exception to skip further processing
  READ TABLE me->ref_idoc_status->* TRANSPORTING NO FIELDS
                                    WITH KEY status = c_status_in_err.
  IF sy-subrc = 0.
    RAISE EXCEPTION TYPE ZCX_IDOC_FM_ERROR.
  ENDIF.

* Case 3 - No errors and Commit is required
  IF me->v_commit_idoc_fm = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    SET UPDATE TASK LOCAL. "Set back LUW to local update after commit
  ENDIF.

endmethod.


method SET_COMMIT_FLAG.

  me->v_commit_idoc_fm = iv_commit.

endmethod.


method SET_RETVAR_WF_ERROR.

  DATA:
    ls_retvar LIKE LINE OF me->ref_return_variables->*.

  me->v_workflow_result = c_wf_result_err.

  ls_retvar-wf_param   = c_wf_param_err.
  ls_retvar-doc_number = me->s_edidc-docnum.
  APPEND ls_retvar TO me->ref_return_variables->*.

endmethod.


method UPDATE_LOGS.

* Update custom log tables

endmethod.


method VALIDATION_CHECK.

* Code validation checks here

endmethod.
ENDCLASS.
