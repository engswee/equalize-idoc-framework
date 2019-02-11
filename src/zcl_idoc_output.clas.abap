class ZCL_IDOC_OUTPUT definition
  public
  inheriting from ZCL_IDOC_BASE
  abstract
  create public .

public section.
*"* public components of class ZCL_IDOC_OUTPUT
*"* do not include other source files here!!!

  constants C_STATUS_OUT_ERR type EDI_STATUS value '20'. "#EC NOTEXT
  constants C_STATUS_OUT_SUCC type EDI_STATUS value '18'. "#EC NOTEXT

  methods EXECUTE_OUTBOUND
    importing
      !IS_OBJECT type NAST
      !IS_EDIDC type EDIDC
    exporting
      !ES_EDIDC type EDIDC
      !EV_OBJ_TYPE type WFAS1-ASGTP
    changing
      !CT_EDIDD type EDIDD_TT
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR
      ZCX_IDOC_DATA_NOT_FOR_SEND .
  methods EXECUTE_OUTBOUND_PORT
    importing
      !IV_DOCNUM type EDIDC-DOCNUM
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
protected section.
*"* protected components of class ZCL_IDOC_OUTPUT
*"* do not include other source files here!!!

  data S_NAST type NAST .
  data S_EDIDC type EDIDC .
  data V_OBJ_TYPE type WFAS1-ASGTP .
  data REF_EDIDD type ref to EDIDD_TT .
  data S_EDIDS type EDI_DS .

  methods INIT
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR
      ZCX_IDOC_DATA_NOT_FOR_SEND .
  methods VALIDATION_CHECK
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR
      ZCX_IDOC_DATA_NOT_FOR_SEND .
  methods OPEN_IDOC
    importing
      !IV_DOCNUM type EDIDC-DOCNUM
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods PROCESS_IDOC_FM
  abstract
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR
      ZCX_IDOC_DATA_NOT_FOR_SEND .
  methods PREPROCESS
  abstract
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR
      ZCX_IDOC_DATA_NOT_FOR_SEND .
  methods POSTPROCESS
  abstract
    raising
      ZCX_IDOC_POSTPROCESS_ERROR .
  methods SET_IDOC_STATUS
    importing
      !IV_STATUS type EDI_STATUS
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods ADD_MESSAGE
    importing
      !IV_MSGID type MSGID
      !IV_MSGNO type ANY
      !IV_MSGV1 type ANY optional
      !IV_MSGV2 type ANY optional
      !IV_MSGV3 type ANY optional
      !IV_MSGV4 type ANY optional .
  methods START_ERROR_WORKFLOW
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods CLOSE_IDOC
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods TRANSMIT_TRFC
    raising
      ZCX_IDOC_POSTPROCESS_ERROR .
private section.
*"* private components of class ZCL_IDOC_OUTPUT
*"* do not include other source files here!!!

  data T_EDIDD_TEMP type EDIDD_TT .
ENDCLASS.



CLASS ZCL_IDOC_OUTPUT IMPLEMENTATION.


METHOD add_message.

  me->s_edids-stamid = iv_msgid.
  me->s_edids-stamno = iv_msgno.
  me->s_edids-stapa1 = iv_msgv1.
  me->s_edids-stapa2 = iv_msgv2.
  me->s_edids-stapa3 = iv_msgv3.
  me->s_edids-stapa4 = iv_msgv4.

ENDMETHOD.


METHOD close_idoc.

  CALL FUNCTION 'EDI_DOCUMENT_CLOSE_PROCESS'
    EXPORTING
      document_number     = me->s_edidc-docnum
    EXCEPTIONS
      document_not_open   = 1
      failure_in_db_write = 2
      parameter_error     = 3
      status_set_missing  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_idoc_generic_process_error
      EXPORTING
        msgty = sy-msgty
        msgid = sy-msgid
        msgno = sy-msgno
        msgv1 = sy-msgv1
        msgv2 = sy-msgv2
        msgv3 = sy-msgv3
        msgv4 = sy-msgv4.
  ENDIF.

ENDMETHOD.


METHOD execute_outbound.

* Set attributes from importing & changing parameters
  me->s_nast  = is_object.
  me->s_edidc = is_edidc.
* Store data reference to tables to avoid copy cost
  GET REFERENCE OF ct_edidd INTO me->ref_edidd.

  me->init( ).

  me->validation_check( ).

  me->preprocess( ).

  me->process_idoc_fm( ).

  me->postprocess( ).

* Update exporting parameters
* Changing parameters do not need direct updating as they are modified by reference
  es_edidc    = me->s_edidc.
  ev_obj_type = me->v_obj_type.

ENDMETHOD.


METHOD execute_outbound_port.

  me->open_idoc( iv_docnum ).

  TRY .
      me->postprocess( ).

      me->transmit_trfc( ).

      me->set_idoc_status( c_status_out_succ ).

    CATCH zcx_idoc_postprocess_error.
      me->set_idoc_status( c_status_out_err ).

      me->start_error_workflow( ).
  ENDTRY.

  me->close_idoc( ).

ENDMETHOD.


method INIT.
endmethod.


METHOD open_idoc.

  CALL FUNCTION 'EDI_DOCUMENT_OPEN_FOR_PROCESS'
    EXPORTING
      document_number          = iv_docnum
    IMPORTING
      idoc_control             = me->s_edidc
    EXCEPTIONS
      document_foreign_lock    = 1
      document_not_exist       = 2
      document_number_invalid  = 3
      document_is_already_open = 4
      OTHERS                   = 5.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_idoc_generic_process_error
      EXPORTING
        msgty = sy-msgty
        msgid = sy-msgid
        msgno = sy-msgno
        msgv1 = sy-msgv1
        msgv2 = sy-msgv2
        msgv3 = sy-msgv3
        msgv4 = sy-msgv4.
  ENDIF.

  CALL FUNCTION 'EDI_SEGMENTS_GET_ALL'
    EXPORTING
      document_number         = iv_docnum
    TABLES
      idoc_containers         = me->t_edidd_temp
    EXCEPTIONS
      document_number_invalid = 1
      end_of_document         = 2
      OTHERS                  = 3.
  IF sy-subrc = 0.
    GET REFERENCE OF me->t_edidd_temp INTO me->ref_edidd.
  ELSE.
    RAISE EXCEPTION TYPE zcx_idoc_generic_process_error
      EXPORTING
        msgty = sy-msgty
        msgid = sy-msgid
        msgno = sy-msgno
        msgv1 = sy-msgv1
        msgv2 = sy-msgv2
        msgv3 = sy-msgv3
        msgv4 = sy-msgv4.
  ENDIF.

ENDMETHOD.


METHOD set_idoc_status.

  me->s_edids-docnum = me->s_edidc-docnum.
  me->s_edids-tabnam = 'EDI_DS'.
  me->s_edids-logdat = sy-datum.
  me->s_edids-logtim = sy-uzeit.
  me->s_edids-repid = 'ZCL_IDOC_OUTPUT'.
  me->s_edids-status = iv_status.
  me->s_edids-stamqu = 'SAP'.

  CALL FUNCTION 'EDI_DOCUMENT_STATUS_SET'
    EXPORTING
      document_number         = me->s_edidc-docnum
      idoc_status             = me->s_edids
    EXCEPTIONS
      document_number_invalid = 1
      other_fields_invalid    = 2
      status_invalid          = 3
      OTHERS                  = 4.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_idoc_generic_process_error
      EXPORTING
        msgty = sy-msgty
        msgid = sy-msgid
        msgno = sy-msgno
        msgv1 = sy-msgv1
        msgv2 = sy-msgv2
        msgv3 = sy-msgv3
        msgv4 = sy-msgv4.
  ENDIF.

ENDMETHOD.


METHOD start_error_workflow.

  CALL FUNCTION 'IDOC_ERROR_WORKFLOW_START'
    EXPORTING
      docnum                  = me->s_edidc-docnum
      eventcode               = 'EDIO'        "Outbound, error handling with IDoc
    EXCEPTIONS
      no_entry_in_tede5       = 1
      error_in_start_workflow = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_idoc_generic_process_error
      EXPORTING
        msgty = sy-msgty
        msgid = sy-msgid
        msgno = sy-msgno
        msgv1 = sy-msgv1
        msgv2 = sy-msgv2
        msgv3 = sy-msgv3
        msgv4 = sy-msgv4.
  ENDIF.

ENDMETHOD.


METHOD transmit_trfc.

  DATA:
    lv_rfc_dest   TYPE edipoa-logdes,
    lt_trfc_edidc TYPE STANDARD TABLE OF edi_dc40,
    lt_trfc_edidd TYPE STANDARD TABLE OF edi_dd40,
    ls_trfc_edidc LIKE LINE OF lt_trfc_edidc,
    ls_trfc_edidd LIKE LINE OF lt_trfc_edidd,
    ls_edidd      LIKE LINE OF me->ref_edidd->*.

  IF me->s_idoc_options-edi_out_port IS INITIAL.
    me->add_message( iv_msgid = 'AD'
                     iv_msgno = '010'
                     iv_msgv1 = 'tRFC port not maintained in ZBC_IDOC_OPTIONS' ).
    RAISE EXCEPTION TYPE zcx_idoc_postprocess_error.
  ELSE.
    MOVE-CORRESPONDING me->s_edidc TO ls_trfc_edidc.
    ls_trfc_edidc-idoctyp = me->s_edidc-idoctp.
    APPEND ls_trfc_edidc TO lt_trfc_edidc.

    LOOP AT me->ref_edidd->* INTO ls_edidd.
      MOVE-CORRESPONDING ls_edidd TO ls_trfc_edidd.
      APPEND ls_trfc_edidd TO lt_trfc_edidd.
    ENDLOOP.

    SELECT SINGLE logdes INTO lv_rfc_dest
                  FROM edipoa
                  WHERE port = me->s_idoc_options-edi_out_port.

    CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS' IN BACKGROUND TASK
      DESTINATION lv_rfc_dest
      TABLES
        idoc_control_rec_40 = lt_trfc_edidc
        idoc_data_rec_40    = lt_trfc_edidd.

    me->add_message( iv_msgid = 'AD'
                     iv_msgno = '010'
                     iv_msgv1 = 'IDoc sent to RFC destination'
                     iv_msgv2 = lv_rfc_dest ).

*    Commit work triggered by calling IDoc framework
  ENDIF.

ENDMETHOD.


method VALIDATION_CHECK.
endmethod.
ENDCLASS.
