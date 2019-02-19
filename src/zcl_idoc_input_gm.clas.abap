CLASS zcl_idoc_input_gm DEFINITION
  PUBLIC
  INHERITING FROM zcl_idoc_input
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.

    DATA v_mblnr TYPE mkpf-mblnr .
    DATA v_mjahr TYPE mkpf-mjahr .

    METHODS convert_material
      IMPORTING
        !iv_plant        TYPE marc-werks
        !iv_ext_material TYPE mgv_material_external
        !iv_vendor       TYPE lifnr
      CHANGING
        !cv_material     TYPE matnr
      RAISING
        zcx_idoc_preprocess_error .
    METHODS convert_uom
      CHANGING
        !cs_e1bp2017_gm_item_create TYPE e1bp2017_gm_item_create
      RAISING
        zcx_idoc_preprocess_error .

    METHODS postprocess
        REDEFINITION .
    METHODS preprocess
        REDEFINITION .
    METHODS process_idoc_fm
        REDEFINITION .

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_idoc_input_gm IMPLEMENTATION.


  METHOD convert_material.

    DATA:
      lv_material     LIKE cv_material,
      lv_ext_material TYPE eina-idnlf,
      lv_purch_org    TYPE eine-ekorg,
      ls_extension    LIKE LINE OF me->t_extension.

    IF cv_material IS NOT INITIAL.
      lv_ext_material = cv_material.
    ELSEIF iv_ext_material IS NOT INITIAL.
      lv_ext_material = iv_ext_material.
    ENDIF.

    CASE me->s_idoc_options-matnr_conv.
      WHEN 'IN_EINA'.
        IF iv_vendor IS INITIAL.
*       VENDOR not populated for conversion IN_EINA
          me->append_idoc_status( iv_status = c_status_in_err
                                  iv_msgty  = c_msg_type_error
                                  iv_msgid  = 'AD'
                                  iv_msgno  = '010'
                                  iv_msgv1  = 'VENDOR not populated for conversion'
                                  iv_msgv2  = me->s_idoc_options-matnr_conv ).
          RAISE EXCEPTION TYPE zcx_idoc_preprocess_error.
        ENDIF.
        lv_material     = me->convert_material_with_eina( iv_vendor       = iv_vendor
                                                          iv_ext_material = lv_ext_material ).

      WHEN 'IN_EINA_EINE'.
        IF iv_vendor IS INITIAL.
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
        lv_material     = me->convert_material_with_eina( iv_vendor       = iv_vendor
                                                          iv_ext_material = lv_ext_material
                                                          iv_purch_org    = lv_purch_org
                                                          iv_plant        = iv_plant ).

      WHEN 'IN_MARA'.
        lv_material = me->convert_mat_with_marc_mara( cv_material ).

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
        lv_material = me->convert_mat_with_marc_mara( iv_ext_material    = cv_material
                                                      iv_material_group  = me->s_idoc_options-matkl ).

      WHEN 'IN_MARC_MARA'.
        lv_material = me->convert_mat_with_marc_mara( iv_plant        = iv_plant
                                                      iv_ext_material = cv_material ).

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
        lv_material = me->convert_mat_with_marc_mara( iv_plant           = iv_plant
                                                      iv_ext_material    = cv_material
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
      cv_material = lv_material.
    ENDIF.

  ENDMETHOD.                    "convert_material


  METHOD convert_uom.

    CASE me->s_idoc_options-uom_conv.
      WHEN 'SAP_2_ISO'.
        cs_e1bp2017_gm_item_create-entry_uom_iso = me->convert_uom_sap_to_iso( cs_e1bp2017_gm_item_create-entry_uom_iso ).
      WHEN 'SAP_2_ISO_CUNIT'.
        cs_e1bp2017_gm_item_create-entry_uom_iso = me->convert_uom_sap_to_iso( iv_sapuom           = cs_e1bp2017_gm_item_create-entry_uom_iso
                                                                               iv_cunit_conversion = 'X' ).
    ENDCASE.

  ENDMETHOD.


  METHOD postprocess.

    FIELD-SYMBOLS:
      <lfs_edids> LIKE LINE OF me->ref_idoc_status->*.

* Change message returned from BAPI for successful message creation
    LOOP AT me->ref_idoc_status->* ASSIGNING <lfs_edids>.
      IF ( <lfs_edids>-msgid = 'B1' AND <lfs_edids>-msgno = '501' ). "BAPI & has been called successfully
*     MIGO(012) - Material document & posted
        <lfs_edids>-msgid = 'MIGO'.
        <lfs_edids>-msgty = c_msg_type_success.
        <lfs_edids>-msgno = '012'.
        <lfs_edids>-msgv1 = me->v_mblnr.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "postprocess


  METHOD preprocess.

    FIELD-SYMBOLS:
      <lfs_edidd>                   LIKE LINE OF me->ref_idoc_data->*,
      <lfs_e1bp2017_gm_item_create> TYPE e1bp2017_gm_item_create.
    DATA:
       lv_material TYPE matnr.

* Retrieve all the data populated in the extension segment E1BPPAREX and store in instance attribute
    me->extract_extension_data( iv_sort = 'X' ).

* Default preprocessing from configuration
    LOOP AT me->ref_idoc_data->* ASSIGNING <lfs_edidd>.
      CASE <lfs_edidd>-segnam.

        WHEN 'E1BP2017_GM_ITEM_CREATE'.
          ASSIGN <lfs_edidd>-sdata TO <lfs_e1bp2017_gm_item_create> CASTING.
          IF me->s_idoc_options-matnr_conv IS NOT INITIAL.
            lv_material =  <lfs_e1bp2017_gm_item_create>-material.
            me->convert_material( EXPORTING iv_plant        = <lfs_e1bp2017_gm_item_create>-plant
                                            iv_ext_material = <lfs_e1bp2017_gm_item_create>-material_external
                                            iv_vendor       = <lfs_e1bp2017_gm_item_create>-vendor
                                  CHANGING  cv_material     = lv_material ).
            <lfs_e1bp2017_gm_item_create>-material = lv_material.
            IF <lfs_e1bp2017_gm_item_create>-move_mat IS NOT INITIAL OR
               <lfs_e1bp2017_gm_item_create>-move_mat_external IS NOT INITIAL.
              lv_material =  <lfs_e1bp2017_gm_item_create>-move_mat.
              me->convert_material( EXPORTING iv_plant        = <lfs_e1bp2017_gm_item_create>-move_plant
                                              iv_ext_material = <lfs_e1bp2017_gm_item_create>-move_mat_external
                                              iv_vendor       = <lfs_e1bp2017_gm_item_create>-vendor
                                    CHANGING  cv_material     = lv_material ).
              <lfs_e1bp2017_gm_item_create>-move_mat = lv_material.
            ENDIF.
          ENDIF.
          IF me->s_idoc_options-uom_conv IS NOT INITIAL.
            me->convert_uom( CHANGING cs_e1bp2017_gm_item_create = <lfs_e1bp2017_gm_item_create> ).
          ENDIF.

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

    CALL FUNCTION 'IDOC_INPUT_MBGMCR'
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
