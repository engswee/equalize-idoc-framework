class ZCL_IDOC_BASE definition
  public
  abstract
  create public .

public section.
*"* public components of class ZCL_IDOC_BASE
*"* do not include other source files here!!!

  constants C_STATUS_IN_ERR type EDI_STATUS value '51'. "#EC NOTEXT
  constants C_STATUS_IN_SUCC type EDI_STATUS value '53'. "#EC NOTEXT
  constants C_WF_RESULT_ERR type WF_RESULT value '99999'. "#EC NOTEXT
  constants C_WF_PARAM_SUCC type WFVARIABLE value 'Processed_IDOCs'. "#EC NOTEXT
  constants C_WF_PARAM_ERR type WFVARIABLE value 'Error_IDOCs'. "#EC NOTEXT
  constants C_WF_PARAM_APPOBJ type WFVARIABLE value 'Appl_Objects'. "#EC NOTEXT
  constants C_WF_PARAM_APPOBJTYPE type WFVARIABLE value 'Appl_Object_Type'. "#EC NOTEXT
  constants C_MSG_TYPE_ABORT type BAPI_MTYPE value 'A'. "#EC NOTEXT
  constants C_MSG_TYPE_ERROR type BAPI_MTYPE value 'E'. "#EC NOTEXT
  constants C_MSG_TYPE_INFO type BAPI_MTYPE value 'I'. "#EC NOTEXT
  constants C_MSG_TYPE_WARNING type BAPI_MTYPE value 'W'. "#EC NOTEXT
  constants C_MSG_TYPE_SUCCESS type BAPI_MTYPE value 'S'. "#EC NOTEXT

  class-methods GET_INSTANCE
    importing
      !IV_DIRECTION type EDI_DIRECT
      !IV_PARNUM type EDIPPARNUM
      !IV_PARTYP type EDIPPARTYP
      !IV_PARFCT type EDI_PARFCT
      !IV_MESTYP type EDI_MESTYP
      !IV_MESCOD type EDI_MESCOD
      !IV_MESFCT type EDI_MESFCT
    returning
      value(RO_INTERFACE) type ref to ZCL_IDOC_BASE
    raising
      CX_SY_CREATE_OBJECT_ERROR .
  class-methods FREE_INSTANCE .
protected section.
*"* protected components of class ZCL_IDOC_BASE
*"* do not include other source files here!!!

  data O_BUFFER type ref to ZCL_IDOC_DB_BUFFER .
  data S_IDOC_OPTIONS type ZBC_IDOC_OPTIONS .

  methods SEND_EMAIL
    importing
      !IS_EMAIL_DOC type SODOCCHGI1
      !IT_CONTENTS type SRM_T_SOLISTI1
      !IV_DO_COMMIT type XFELD optional
    changing
      !CT_RECEIVERS type SOMLRECI1_T .
  methods SET_PROCESSING_OPTIONS
    importing
      !IS_IDOC_OPTIONS type ZBC_IDOC_OPTIONS .
  methods CONVERT_MATERIAL_WITH_EINA
    importing
      !IV_VENDOR type EINA-LIFNR
      !IV_EXT_MATERIAL type EINA-IDNLF
      !IV_PURCH_ORG type EINE-EKORG optional
      !IV_PLANT type EINE-WERKS optional
    returning
      value(RV_MATNR) type EINA-MATNR .
  methods CONVERT_MAT_WITH_MARC_MARA
    importing
      !IV_EXT_MATERIAL type MARA-BISMT
      !IV_MATERIAL_GROUP type MARA-MATKL optional
      !IV_PLANT type MARC-WERKS optional
    returning
      value(RV_MATNR) type MARA-MATNR .
  methods CONVERT_EXT_MATERIAL_WITH_EINA
    importing
      !IV_MATNR type EINA-MATNR
    returning
      value(RV_EXT_MATERIAL) type EINA-IDNLF .
  methods CONVERT_EXT_MATERIAL_WITH_MARA
    importing
      !IV_MATNR type MARA-MATNR
    returning
      value(RV_EXT_MATERIAL) type MARA-BISMT .
  methods CONVERT_UOM_ISO_TO_SAP
    importing
      !IV_ISOUOM type T006-ISOCODE
    returning
      value(RV_SAPUOM) type T006-MSEHI .
  methods CONVERT_UOM_SAP_TO_ISO
    importing
      !IV_SAPUOM type T006-MSEHI
      !IV_CUNIT_CONVERSION type XFELD optional
    returning
      value(RV_ISOUOM) type T006-ISOCODE .
  methods CONVERT_BATCH_WITH_MCHA
    importing
      !IV_MATNR type MCHA-MATNR
      !IV_WERKS type MCHA-WERKS
      !IV_EXT_BATCH type MCHA-LICHA
    returning
      value(RV_CHARG) type MCHA-CHARG .
  methods CONVERT_EXT_BATCH_WITH_MCHA
    importing
      !IV_MATNR type MCHA-MATNR
      !IV_WERKS type MCHA-WERKS
      !IV_CHARG type MCHA-CHARG
    returning
      value(RV_EXT_BATCH) type MCHA-LICHA .
  methods CONVERT_SERIAL_WITH_EQUI
    importing
      !IV_MATNR type EQUI-MATNR
      !IV_EXT_SERIAL type EQUI-SERGE
    returning
      value(RV_SERNR) type EQUI-SERNR .
  methods CONVERT_EXT_SERIAL_WITH_EQUI
    importing
      !IV_MATNR type EQUI-MATNR
      !IV_SERNR type EQUI-SERNR
    returning
      value(RV_EXT_SERIAL) type EQUI-SERGE .
  methods POPULATE_X_STRUCTURE
    importing
      !IS_STRUC type DATA
    changing
      !CS_STRUC_X type DATA .
private section.
*"* private components of class ZCL_IDOC_BASE
*"* do not include other source files here!!!

  class-data O_INTERFACE type ref to ZCL_IDOC_BASE .
ENDCLASS.



CLASS ZCL_IDOC_BASE IMPLEMENTATION.


method CONVERT_BATCH_WITH_MCHA.

  rv_charg = me->o_buffer->get_batch_from_mcha( iv_matnr     = iv_matnr
                                                iv_werks     = iv_werks
                                                iv_ext_batch = iv_ext_batch ).

endmethod.


method CONVERT_EXT_BATCH_WITH_MCHA.

  rv_ext_batch = me->o_buffer->get_ext_batch_from_mcha( iv_matnr        = iv_matnr
                                                        iv_werks        = iv_werks
                                                        iv_charg        = iv_charg ).

endmethod.


method CONVERT_EXT_MATERIAL_WITH_EINA.

* Retrieve external material no from Purchasing Info Record
  rv_ext_material = me->o_buffer->get_ext_material_from_eina( iv_matnr ).

endmethod.


method CONVERT_EXT_MATERIAL_WITH_MARA.

* Retrieve external material no from MARA Old Material No
  rv_ext_material = me->o_buffer->get_ext_material_from_mara( iv_matnr ).

endmethod.


method CONVERT_EXT_SERIAL_WITH_EQUI.

  rv_ext_serial = me->o_buffer->get_ext_serial_from_equi( iv_matnr         = iv_matnr
                                                          iv_sernr         = iv_sernr ).

endmethod.


method CONVERT_MATERIAL_WITH_EINA.

  IF iv_purch_org IS SUPPLIED AND iv_plant IS SUPPLIED.
*   Retrieve SAP material no from Purchasing Info Record with Purch Org & Plant
    rv_matnr = me->o_buffer->get_material_from_eina_eine( iv_vendor       = iv_vendor
                                                          iv_ext_material = iv_ext_material
                                                          iv_purch_org    = iv_purch_org
                                                          iv_plant        = iv_plant ).

  ELSE.
*   Retrieve SAP material no from Purchasing Info Record
    rv_matnr = me->o_buffer->get_material_from_eina( iv_vendor       = iv_vendor
                                                     iv_ext_material = iv_ext_material ).
  ENDIF.

endmethod.


method CONVERT_MAT_WITH_MARC_MARA.

  IF iv_plant IS SUPPLIED.
*   Retrieve SAP material no from Material Master via Old Material Number with Plant
    IF iv_material_group IS SUPPLIED.
      rv_matnr = me->o_buffer->get_material_from_marc_bygroup( iv_plant           = iv_plant
                                                               iv_ext_material    = iv_ext_material
                                                               iv_material_group  = iv_material_group ).
    ELSE.
      rv_matnr = me->o_buffer->get_material_from_marc( iv_plant        = iv_plant
                                                       iv_ext_material = iv_ext_material ).
    ENDIF.
  ELSE.
*   Retrieve SAP material no from Material Master via Old Material Number
    IF iv_material_group IS SUPPLIED.
      rv_matnr = me->o_buffer->get_material_from_mara_bygroup( iv_ext_material    = iv_ext_material
                                                               iv_material_group  = iv_material_group ).
    ELSE.
      rv_matnr = me->o_buffer->get_material_from_mara( iv_ext_material ).
    ENDIF.
  ENDIF.

endmethod.


method CONVERT_SERIAL_WITH_EQUI.

  rv_sernr = me->o_buffer->get_serial_from_equi( iv_matnr      = iv_matnr
                                                 iv_ext_serial = iv_ext_serial ).

endmethod.


method CONVERT_UOM_ISO_TO_SAP.

  SELECT msehi FROM t006 UP TO 1 ROWS
         INTO rv_sapuom
         WHERE isocode = iv_isouom.
  ENDSELECT.

endmethod.


method CONVERT_UOM_SAP_TO_ISO.

  DATA:
    lv_msehi TYPE t006-msehi.

  IF iv_cunit_conversion = 'X'.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = iv_sapuom
      IMPORTING
        output         = lv_msehi
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      lv_msehi = iv_sapuom.
    ENDIF.
  ELSE.
    lv_msehi = iv_sapuom.
  ENDIF.

  SELECT SINGLE isocode FROM t006
         INTO rv_isouom
         WHERE msehi = lv_msehi.
* Return input value if unit not found
  IF sy-subrc <> 0.
    rv_isouom = iv_sapuom.
  ENDIF.

endmethod.


method FREE_INSTANCE.

  FREE o_interface.

endmethod.


METHOD get_instance.

  DATA:
    lv_classname    TYPE string,
    ls_idoc_options TYPE zbc_idoc_options.

  IF o_interface IS NOT BOUND.

    SELECT SINGLE idoc_class FROM zbc_idoc_cfg
           INTO lv_classname
           WHERE direct   = iv_direction
             AND parnum   = iv_parnum
             AND partyp   = iv_partyp
             AND parfct   = iv_parfct
             AND mestyp   = iv_mestyp
             AND mescod   = iv_mescod
             AND mesfct   = iv_mesfct.

    CREATE OBJECT o_interface TYPE (lv_classname).

    SELECT SINGLE * FROM zbc_idoc_options
           INTO ls_idoc_options
           WHERE direct   = iv_direction
             AND parnum   = iv_parnum
             AND partyp   = iv_partyp
             AND parfct   = iv_parfct
             AND mestyp   = iv_mestyp
             AND mescod   = iv_mescod
             AND mesfct   = iv_mesfct.
    IF sy-subrc = 0.
      o_interface->set_processing_options( ls_idoc_options ).
    ENDIF.

  ENDIF.
  ro_interface = o_interface.

ENDMETHOD.


method POPULATE_X_STRUCTURE.

  DATA:
    lo_struct_descr     TYPE REF TO cl_abap_structdescr,
    lo_struct_descr_x   TYPE REF TO cl_abap_structdescr,
    ls_component        LIKE LINE OF lo_struct_descr->components,
    ls_component_x      LIKE LINE OF lo_struct_descr_x->components,
    lv_position         TYPE sy-tabix,
    lv_position_x       TYPE sy-tabix.
  FIELD-SYMBOLS:
    <lfs_fieldvalue>    TYPE any,
    <lfs_fieldvalue_x>  TYPE any.

  lo_struct_descr   ?= cl_abap_typedescr=>describe_by_data( is_struc ).
  lo_struct_descr_x ?= cl_abap_typedescr=>describe_by_data( cs_struc_x ).

* Loop through every field of the input structure
  LOOP AT lo_struct_descr->components INTO ls_component.
    lv_position = sy-tabix.
    ASSIGN COMPONENT lv_position OF STRUCTURE is_struc TO <lfs_fieldvalue>.
    IF sy-subrc = 0 AND <lfs_fieldvalue> IS NOT INITIAL.
*     If the field is populated, find the position of the field in the corresponding X structure
      READ TABLE lo_struct_descr_x->components INTO ls_component_x INDEX lv_position.
      IF sy-subrc = 0 AND ls_component-name = ls_component_x-name.
*       If the fields in both structures are in the same position
        lv_position_x = lv_position.
      ELSE.
*       If the positions are different, then find where the position is in the X structure
        READ TABLE lo_struct_descr_x->components INTO ls_component_x
                                                 WITH TABLE KEY name = ls_component-name.
        IF sy-subrc = 0.
          lv_position_x = sy-tabix.
        ENDIF.
      ENDIF.

*     If position in X structure is found, then populate it with X
      IF lv_position_x IS NOT INITIAL.
        ASSIGN COMPONENT lv_position_x OF STRUCTURE cs_struc_x TO <lfs_fieldvalue_x>.
        IF sy-subrc = 0.
          <lfs_fieldvalue_x> = 'X'.
        ENDIF.
      ENDIF.

      CLEAR: lv_position, lv_position_x.
      UNASSIGN: <lfs_fieldvalue>, <lfs_fieldvalue_x>.
    ENDIF.
  ENDLOOP.

endmethod.


method SEND_EMAIL.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = is_email_doc
    TABLES
      object_content             = it_contents
      receivers                  = ct_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc = 0 AND iv_do_commit = 'X'.
    COMMIT WORK.
  ENDIF.

endmethod.


METHOD set_processing_options.

  me->s_idoc_options = is_idoc_options.

ENDMETHOD.
ENDCLASS.
