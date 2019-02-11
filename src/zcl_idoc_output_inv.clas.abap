class ZCL_IDOC_OUTPUT_INV definition
  public
  inheriting from ZCL_IDOC_OUTPUT
  create public .

public section.
*"* public components of class ZCL_IDOC_OUTPUT_INV
*"* do not include other source files here!!!
protected section.
*"* protected components of class ZCL_IDOC_OUTPUT_INV
*"* do not include other source files here!!!

  methods POSTPROCESS
    redefinition .
  methods PREPROCESS
    redefinition .
  methods PROCESS_IDOC_FM
    redefinition .
  methods VALIDATION_CHECK
    redefinition .
private section.
*"* private components of class ZCL_IDOC_OUTPUT_INV
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IDOC_OUTPUT_INV IMPLEMENTATION.


METHOD postprocess.

  FIELD-SYMBOLS:
    <lfs_edidd> LIKE LINE OF me->ref_edidd->*,
    <lfs_e1edk01> TYPE e1edk01.

  LOOP AT me->ref_edidd->* ASSIGNING <lfs_edidd>.
    CASE <lfs_edidd>-segnam.
      WHEN 'E1EDK01'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1edk01> CASTING.
        <lfs_e1edk01>-curcy = 'USD'.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDMETHOD.


METHOD preprocess.



ENDMETHOD.


METHOD process_idoc_fm.

  DATA:
    lv_error_msg TYPE string.

  CALL FUNCTION 'IDOC_OUTPUT_INVOIC'
    EXPORTING
      object                        = me->s_nast
      control_record_in             = me->s_edidc
    IMPORTING
      control_record_out            = me->s_edidc
      object_type                   = me->v_obj_type
    TABLES
      int_edidd                     = me->ref_edidd->*
    EXCEPTIONS
      error_message_received        = 1
      data_not_relevant_for_sending = 2
      OTHERS                        = 3.
  CASE sy-subrc.
    WHEN 0.
*       NOP
    WHEN 2.
      MESSAGE ID sy-msgid TYPE c_msg_type_error NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
           INTO lv_error_msg.
      RAISE EXCEPTION TYPE zcx_idoc_data_not_for_send
        EXPORTING
          msg = lv_error_msg.
    WHEN OTHERS.
      RAISE EXCEPTION TYPE zcx_idoc_generic_process_error
        EXPORTING
          msgty = sy-msgty
          msgid = sy-msgid
          msgno = sy-msgno
          msgv1 = sy-msgv1
          msgv2 = sy-msgv2
          msgv3 = sy-msgv3
          msgv4 = sy-msgv4.
  ENDCASE.

ENDMETHOD.


METHOD validation_check.

* Sample to raise not relevant for send if some criteria is not fulfilled
*  DATA:
*    lv_msg TYPE string.
*
*  RAISE EXCEPTION TYPE zcx_idoc_data_not_for_send
*    EXPORTING
*      msg = lv_msg.

ENDMETHOD.
ENDCLASS.
