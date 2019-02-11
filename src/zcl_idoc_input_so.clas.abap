class ZCL_IDOC_INPUT_SO definition
  public
  inheriting from ZCL_IDOC_INPUT
  create public .

public section.
*"* public components of class ZCL_IDOC_INPUT_SO
*"* do not include other source files here!!!
protected section.
*"* protected components of class ZCL_IDOC_INPUT_SO
*"* do not include other source files here!!!

  types:
    BEGIN OF ty_serial_items,
          posnr TYPE vbap-posnr,
          sernr TYPE equi-sernr,
    END OF ty_serial_items .
  types:
    ty_t_serial_items TYPE STANDARD TABLE OF ty_serial_items .
  types:
    BEGIN OF ty_cam_partners,
      addr_link   TYPE e1bpparnr-addr_link,
      partn_role  TYPE e1bpparnr-partn_role,
      partn_numb  TYPE e1bpparnr-partn_numb,
    END OF ty_cam_partners .
  types:
    ty_t_cam_partners TYPE SORTED TABLE OF ty_cam_partners WITH UNIQUE KEY addr_link .

  data V_EXISTING_VBELN type VBAK-VBELN .
  data V_AUART type VBAK-AUART .
  data T_SERIAL_ITEMS type TY_T_SERIAL_ITEMS .
  data T_CAM_PARTNERS type TY_T_CAM_PARTNERS .

  methods CONVERT_MATERIAL
    importing
      !IS_E1BPSDITM1 type E1BPSDITM1
    changing
      !CS_E1BPSDITM type E1BPSDITM
    raising
      ZCX_IDOC_PREPROCESS_ERROR .
  methods CONVERT_UOM
    changing
      !CS_E1BPSDITM type E1BPSDITM
    raising
      ZCX_IDOC_PREPROCESS_ERROR .
  methods ADD_SERIAL_TO_SO
    importing
      !IV_VBELN type VBAK-VBELN
      !IT_SERIAL_ITEMS type TY_T_SERIAL_ITEMS
    raising
      ZCX_IDOC_POSTPROCESS_ERROR .
  methods UPDATE_PARTNER_ADDRESS
    changing
      !CS_E1BPADR1 type E1BPADR1
      !CS_E1BPADR11 type E1BPADR11 .

  methods POSTPROCESS
    redefinition .
  methods PREPROCESS
    redefinition .
  methods PROCESS_IDOC_FM
    redefinition .
  methods UPDATE_LOGS
    redefinition .
private section.
*"* private components of class ZCL_IDOC_INPUT_SO
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IDOC_INPUT_SO IMPLEMENTATION.


method ADD_SERIAL_TO_SO.

  TYPES:
    BEGIN OF lty_vbap,
      posnr TYPE vbap-posnr,
      matnr TYPE vbap-matnr,
      pstyv TYPE vbap-pstyv,
      werks TYPE vbap-werks,
      kunnr TYPE vbak-kunnr,
      vbtyp TYPE vbak-vbtyp,
      auart TYPE vbak-auart,
    END OF   lty_vbap.

  DATA:
    lv_sernp          TYPE marc-sernp,
    lt_vbap           TYPE STANDARD TABLE OF lty_vbap.
  FIELD-SYMBOLS:
    <lfs_serial_item> LIKE LINE OF it_serial_items,
    <lfs_vbap>        LIKE LINE OF lt_vbap,
    <lfs_edids>       LIKE LINE OF me->ref_idoc_status->*.

* Retrieve the values for VBAK/VBAP for subsequent processing
  SELECT vbap~posnr vbap~matnr vbap~pstyv vbap~werks
         vbak~kunnr vbak~vbtyp vbak~auart
          INTO TABLE lt_vbap
          FROM vbak JOIN vbap
            ON vbak~vbeln = vbap~vbeln
          WHERE vbak~vbeln = iv_vbeln.
  IF sy-subrc = 0.
    SORT lt_vbap BY posnr.
  ENDIF.


  LOOP AT it_serial_items ASSIGNING <lfs_serial_item>.
    READ TABLE lt_vbap ASSIGNING <lfs_vbap>
                       WITH KEY posnr = <lfs_serial_item>-posnr
                       BINARY SEARCH.
    IF sy-subrc = 0.
*     Get serial profile from MARC-SERNP
      TRY.
          me->o_buffer->lookup_marc( EXPORTING iv_matnr      = <lfs_vbap>-matnr
                                               iv_werks      = <lfs_vbap>-werks
                                               iv_fieldname  = 'SERNP'
                                     IMPORTING ev_fieldvalue = lv_sernp ).
        CATCH ZCX_IDOC_GENERIC_PROCESS_ERROR ##no_handler.
      ENDTRY.

*     Add the serial number into the SO
      CALL FUNCTION 'SERNR_ADD_TO_AU'
        EXPORTING
          sernr                 = <lfs_serial_item>-sernr
          profile               = lv_sernp
          material              = <lfs_vbap>-matnr
          quantity              = '1'
          document              = iv_vbeln
          item                  = <lfs_vbap>-posnr
          debitor               = <lfs_vbap>-kunnr
          vbtyp                 = <lfs_vbap>-vbtyp
          sd_auart              = <lfs_vbap>-auart
          sd_postyp             = <lfs_vbap>-pstyv
        EXCEPTIONS
          konfigurations_error  = 1
          serialnumber_errors   = 2
          serialnumber_warnings = 3
          no_profile_operation  = 4
          OTHERS                = 5.
      IF sy-subrc <> 0.
*       Change all the previous status to error
        LOOP AT me->ref_idoc_status->* ASSIGNING <lfs_edids>.
          <lfs_edids>-status = c_status_in_err.
        ENDLOOP.
        me->append_idoc_status( iv_status = c_status_in_err
                                iv_msgty  = c_msg_type_error
                                iv_msgid  = sy-msgid
                                iv_msgno  = sy-msgno
                                iv_msgv1  = sy-msgv1
                                iv_msgv2  = sy-msgv2
                                iv_msgv3  = sy-msgv3
                                iv_msgv4  = sy-msgv4 ).
        RAISE EXCEPTION TYPE ZCX_IDOC_POSTPROCESS_ERROR.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Commit changes if no exception occurred
  CALL FUNCTION 'SERIAL_LISTE_POST_AU'.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  SET UPDATE TASK LOCAL. "Set back LUW to local update after commit

endmethod.


METHOD convert_material.

  DATA:
    lv_material     LIKE cs_e1bpsditm-material,
    lv_vendor       TYPE eina-lifnr,
    lv_ext_material TYPE eina-idnlf,
    lv_old_material TYPE mara-bismt,
    lv_purch_org    TYPE eine-ekorg,
    ls_extension    LIKE LINE OF me->t_extension.

  IF cs_e1bpsditm-material IS NOT INITIAL.
    lv_ext_material = cs_e1bpsditm-material.
    lv_old_material = cs_e1bpsditm-material.
  ELSEIF is_e1bpsditm1-mat_ext IS NOT INITIAL.
    lv_ext_material = is_e1bpsditm1-mat_ext.
    lv_old_material = cs_e1bpsditm-material.
  ENDIF.

  CASE me->s_idoc_options-matnr_conv.
    WHEN 'IN_EINA'.
*     Get Vendor from default VENDOR value mapped in Extension
      READ TABLE me->t_extension INTO ls_extension
                                 TRANSPORTING valuepart1
                                 WITH KEY structure = 'VENDOR'
                                 BINARY SEARCH.
      IF sy-subrc = 0 AND ls_extension-valuepart1 IS NOT INITIAL.
        lv_vendor       = ls_extension-valuepart1.
        lv_material     = me->convert_material_with_eina( iv_vendor       = lv_vendor
                                                          iv_ext_material = lv_ext_material ).
      ELSE.
*       VENDOR not populated for conversion IN_EINA
        me->append_idoc_status( iv_status = c_status_in_err
                                iv_msgty  = c_msg_type_error
                                iv_msgid  = 'AD'
                                iv_msgno  = '010'
                                iv_msgv1  = 'VENDOR not populated for conversion'
                                iv_msgv2  = me->s_idoc_options-matnr_conv ).
        RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
      ENDIF.

    WHEN 'IN_EINA_EINE'.
*     Get Vendor from default VENDOR value mapped in Extension
      READ TABLE me->t_extension INTO ls_extension
                                 TRANSPORTING valuepart1
                                 WITH KEY structure = 'VENDOR'
                                 BINARY SEARCH.
      IF sy-subrc = 0 AND ls_extension-valuepart1 IS NOT INITIAL.
        lv_vendor = ls_extension-valuepart1.
      ELSE.
*       VENDOR not populated for conversion IN_EINA_EINE
        me->append_idoc_status( iv_status = c_status_in_err
                                iv_msgty  = c_msg_type_error
                                iv_msgid  = 'AD'
                                iv_msgno  = '010'
                                iv_msgv1  = 'VENDOR not populated for conversion'
                                iv_msgv2  = me->s_idoc_options-matnr_conv ).
        RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
      ENDIF.
*     Get Purchasing Org from default PURCH_ORG value mapped in Extension
      READ TABLE me->t_extension INTO ls_extension
                                 TRANSPORTING valuepart1
                                 WITH KEY structure = 'PURCH_ORG'
                                 BINARY SEARCH.
      IF sy-subrc = 0 AND ls_extension-valuepart1 IS NOT INITIAL.
        lv_purch_org = ls_extension-valuepart1.
      ELSE.
*       PURCH_ORG not populated for conversion IN_EINA_EINE
        me->append_idoc_status( iv_status = c_status_in_err
                                iv_msgty  = c_msg_type_error
                                iv_msgid  = 'AD'
                                iv_msgno  = '010'
                                iv_msgv1  = 'PURCH_ORG not populated for conversion'
                                iv_msgv2  = me->s_idoc_options-matnr_conv ).
        RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
      ENDIF.
      lv_material     = me->convert_material_with_eina( iv_vendor       = lv_vendor
                                                        iv_ext_material = lv_ext_material
                                                        iv_purch_org    = lv_purch_org
                                                        iv_plant        = cs_e1bpsditm-plant ).

    WHEN 'IN_MARA'.
      lv_material = me->convert_mat_with_marc_mara( lv_old_material ).

    WHEN 'IN_MARA_MG'.
      IF me->s_idoc_options-matkl IS INITIAL.
*       MATKL not populated for conversion IN_MARA_MG
        me->append_idoc_status( iv_status = c_status_in_err
                                iv_msgty  = c_msg_type_error
                                iv_msgid  = 'AD'
                                iv_msgno  = '010'
                                iv_msgv1  = 'MATKL not populated for conversion'
                                iv_msgv2  = me->s_idoc_options-matnr_conv ).
        RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
      ENDIF.
      lv_material = me->convert_mat_with_marc_mara( iv_ext_material    = lv_old_material
                                                    iv_material_group  = me->s_idoc_options-matkl ).

    WHEN 'IN_MARC_MARA'.
      lv_material = me->convert_mat_with_marc_mara( iv_plant        = cs_e1bpsditm-plant
                                                    iv_ext_material = lv_old_material ).

    WHEN 'IN_MARC_MARA_MG'.
      IF me->s_idoc_options-matkl IS INITIAL.
*       MATKL not populated for conversion IN_MARC_MARA_MG
        me->append_idoc_status( iv_status = c_status_in_err
                                iv_msgty  = c_msg_type_error
                                iv_msgid  = 'AD'
                                iv_msgno  = '010'
                                iv_msgv1  = 'MATKL not populated for conversion'
                                iv_msgv2  = me->s_idoc_options-matnr_conv ).
        RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
      ENDIF.
      lv_material = me->convert_mat_with_marc_mara( iv_plant           = cs_e1bpsditm-plant
                                                    iv_ext_material    = lv_old_material
                                                    iv_material_group  = me->s_idoc_options-matkl ).

  ENDCASE.

* Raise error if the conversion was not successful
  IF lv_material IS INITIAL.
*   Material & does not exist
    me->append_idoc_status( iv_status = c_status_in_err
                            iv_msgty  = c_msg_type_error
                            iv_msgid  = 'M3'
                            iv_msgno  = '238'
                            iv_msgv1  = lv_ext_material ).
  ELSE.
    cs_e1bpsditm-material = lv_material.
  ENDIF.

ENDMETHOD.


METHOD convert_uom.

  CASE me->s_idoc_options-uom_conv.
    WHEN 'SAP_2_ISO'.
      cs_e1bpsditm-s_unit_iso = me->convert_uom_sap_to_iso( cs_e1bpsditm-s_unit_iso ).
    WHEN 'SAP_2_ISO_CUNIT'.
      cs_e1bpsditm-s_unit_iso = me->convert_uom_sap_to_iso( iv_sapuom           = cs_e1bpsditm-s_unit_iso
                                                            iv_cunit_conversion = 'X' ).
  ENDCASE.

ENDMETHOD.


method POSTPROCESS.

  DATA:
    lv_vbeln  TYPE vbak-vbeln,
    ls_status LIKE LINE OF me->ref_idoc_status->*.

  READ TABLE me->ref_idoc_status->*
             INTO ls_status
             WITH KEY msgty  = c_msg_type_success
                      msgid  = 'V1'
                      msgno  = '311'.

* Add serial numbers to SO if it is populated
  IF me->t_serial_items IS NOT INITIAL.
    lv_vbeln = ls_status-msgv2.          "Sales Order number
    me->add_serial_to_so( iv_vbeln        = lv_vbeln
                          it_serial_items = me->t_serial_items ).
  ENDIF.

endmethod.


METHOD preprocess.

  DATA:
    ls_serial                 LIKE LINE OF me->t_serial_items,
    ls_extension              LIKE LINE OF me->t_extension,
    ls_cam_partner            LIKE LINE OF me->t_cam_partners.

  FIELD-SYMBOLS:
    <lfs_edidd>               LIKE LINE OF me->ref_idoc_data->*,
    <lfs_e1so_createfromdat2> TYPE e1salesorder_createfromdat2,
    <lfs_e1bpsdhd1>           TYPE e1bpsdhd1,
    <lfs_e1bpsditm>           TYPE e1bpsditm,
    <lfs_e1bpsditm1>          TYPE e1bpsditm1,
    <lfs_e1bpparnr>           TYPE e1bpparnr,
    <lfs_e1bpadr1>            TYPE e1bpadr1,
    <lfs_e1bpadr11>           TYPE e1bpadr11.

* Retrieve all the data populated in the extension segment E1BPPAREX and store in instance attribute
  me->extract_extension_data( iv_sort = 'X' ).

* Default preprocessing from configuration
  LOOP AT me->ref_idoc_data->* ASSIGNING <lfs_edidd>.
    CASE <lfs_edidd>-segnam.
      WHEN 'E1SALESORDER_CREATEFROMDAT2'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1so_createfromdat2> CASTING.
        IF <lfs_e1so_createfromdat2>-salesdocumentin IS NOT INITIAL.
          me->v_existing_vbeln = <lfs_e1so_createfromdat2>-salesdocumentin.
        ENDIF.

      WHEN 'E1BPSDHD1'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1bpsdhd1> CASTING.
        me->v_auart = <lfs_e1bpsdhd1>-doc_type.

      WHEN 'E1BPSDITM'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1bpsditm> CASTING.
        IF me->s_idoc_options-uom_conv IS NOT INITIAL.
          me->convert_uom( CHANGING cs_e1bpsditm = <lfs_e1bpsditm> ).
        ENDIF.

      WHEN 'E1BPSDITM1'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1bpsditm1> CASTING.
        IF me->s_idoc_options-matnr_conv IS NOT INITIAL.
          me->convert_material( EXPORTING is_e1bpsditm1 = <lfs_e1bpsditm1>
                                CHANGING  cs_e1bpsditm  = <lfs_e1bpsditm> ).
        ENDIF.

      WHEN 'E1BPPARNR'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1bpparnr> CASTING.
*       CAM address used for this partner, add into partner internal table
        IF <lfs_e1bpparnr>-addr_link IS NOT INITIAL.
          ls_cam_partner-addr_link  = <lfs_e1bpparnr>-addr_link.
          ls_cam_partner-partn_role = <lfs_e1bpparnr>-partn_role.
          ls_cam_partner-partn_numb = <lfs_e1bpparnr>-partn_numb.
          INSERT ls_cam_partner INTO TABLE me->t_cam_partners.
        ENDIF.

      WHEN 'E1BPADR1'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1bpadr1> CASTING.

      WHEN 'E1BPADR11'.
        ASSIGN <lfs_edidd>-sdata TO <lfs_e1bpadr11> CASTING.
*       Retrieve and update default values from customer master
        me->update_partner_address( CHANGING cs_e1bpadr1  = <lfs_e1bpadr1>
                                             cs_e1bpadr11 = <lfs_e1bpadr11> ).

    ENDCASE.
  ENDLOOP.

* Add serial numbers in extension into serial table for adding to SO in postprocessing
  LOOP AT me->t_extension INTO ls_extension WHERE structure = 'SERIAL'.
    ls_serial-posnr = ls_extension-valuepart1.
    ls_serial-sernr = ls_extension-valuepart2.
    APPEND ls_serial TO me->t_serial_items.
  ENDLOOP.

  IF me->t_serial_items IS NOT INITIAL.
*   Commit after BAPI processing so that can insert serial
    me->set_commit_flag( 'X' ).
  ENDIF.

* Raise IDoc error if there are any error message collected
  IF me->ref_idoc_status->* IS NOT INITIAL.
    RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
  ENDIF.

ENDMETHOD.


method PROCESS_IDOC_FM.

  CALL FUNCTION 'IDOC_INPUT_SALESORDER_CREATEFR'
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

    WHEN 1.
      RAISE EXCEPTION TYPE ZCX_WRONG_FUNCTION_CALLED.

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
      RAISE EXCEPTION TYPE ZCX_IDOC_FM_ERROR.
  ENDCASE.

endmethod.


method UPDATE_LOGS.

  FIELD-SYMBOLS:
    <lfs_edids> LIKE LINE OF me->ref_idoc_status->*.

* Filter out some messages returned from BAPI prior to logging
  LOOP AT me->ref_idoc_status->* ASSIGNING <lfs_edids>.
    IF ( <lfs_edids>-msgid = 'V4' AND <lfs_edids>-msgno = '233' ) OR "<Segment> has been processed successfully
       ( <lfs_edids>-msgid = 'V4' AND <lfs_edids>-msgno = '219' ) OR "Sales document &1 was not changed
       ( <lfs_edids>-msgid = 'V4' AND <lfs_edids>-msgno = '248' ).   "Error in &1 &2
      DELETE me->ref_idoc_status->*.
    ENDIF.
  ENDLOOP.

  super->update_logs( iv_status ).

endmethod.


method UPDATE_PARTNER_ADDRESS.

  DATA:
    lv_cust_no      TYPE bapi4001_1-objkey,
    ls_cam_partner  LIKE LINE OF me->t_cam_partners,
    lt_bapiad1vl    TYPE STANDARD TABLE OF bapiad1vl,
    lt_bapiadtel    TYPE STANDARD TABLE OF bapiadtel,
    lt_bapiadfax    TYPE STANDARD TABLE OF bapiadfax,
    lt_bapiadsmtp   TYPE STANDARD TABLE OF bapiadsmtp,
    lt_bapiret2     TYPE STANDARD TABLE OF bapiret2,
    ls_bapiad1vl    LIKE LINE OF lt_bapiad1vl,
    ls_bapiadtel    LIKE LINE OF lt_bapiadtel,
    ls_bapiadfax    LIKE LINE OF lt_bapiadfax,
    ls_bapiadsmtp   LIKE LINE OF lt_bapiadsmtp.

  READ TABLE me->t_cam_partners INTO ls_cam_partner
                                WITH KEY addr_link = cs_e1bpadr1-addr_no.
  IF sy-subrc = 0.
*   Retrieve existing partner address details from customer master
    lv_cust_no = ls_cam_partner-partn_numb.
    CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
      EXPORTING
        obj_type   = 'KNA1'
        obj_id     = lv_cust_no
      TABLES
        bapiad1vl  = lt_bapiad1vl
        bapiadtel  = lt_bapiadtel
        bapiadfax  = lt_bapiadfax
        bapiadsmtp = lt_bapiadsmtp
        return     = lt_bapiret2.
    READ TABLE lt_bapiret2 TRANSPORTING NO FIELDS
                           WITH KEY type = c_msg_type_error.
    IF sy-subrc <> 0.
*     Get default address fields from current record
      LOOP AT lt_bapiad1vl INTO ls_bapiad1vl
                           WHERE from_date <= sy-datum
                             AND to_date   >= sy-datum.
        me->populate_default_fields( EXPORTING is_input  = ls_bapiad1vl
                                     CHANGING  cs_output = cs_e1bpadr1 ).
        me->populate_default_fields( EXPORTING is_input  = ls_bapiad1vl
                                     CHANGING  cs_output = cs_e1bpadr11 ).
      ENDLOOP.
*     Get default Telephone 1 number
      IF cs_e1bpadr1-tel1_numbr = '/'.
        LOOP AT lt_bapiadtel INTO ls_bapiadtel WHERE consnumber = '001'.
          cs_e1bpadr1-tel1_numbr = ls_bapiadtel-telephone.
        ENDLOOP.
        IF sy-subrc <> 0.
          CLEAR cs_e1bpadr1-tel1_numbr.
        ENDIF.
      ENDIF.
*     Get default Fax number
      IF cs_e1bpadr1-fax_number = '/'.
        LOOP AT lt_bapiadfax INTO ls_bapiadfax WHERE consnumber = '001'.
          cs_e1bpadr1-fax_number = ls_bapiadfax-fax.
        ENDLOOP.
        IF sy-subrc <> 0.
          CLEAR cs_e1bpadr1-fax_number.
        ENDIF.
      ENDIF.
*     Get default e-mail
      IF cs_e1bpadr11-e_mail = '/'.
        LOOP AT lt_bapiadsmtp INTO ls_bapiadsmtp WHERE consnumber = '001'.
          cs_e1bpadr11-e_mail = ls_bapiadsmtp-e_mail.
        ENDLOOP.
        IF sy-subrc <> 0.
          CLEAR cs_e1bpadr11-e_mail.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

endmethod.
ENDCLASS.
