class ZCL_IDOC_DB_BUFFER definition
  public
  final
  create private .

public section.
*"* public components of class ZCL_IDOC_DB_BUFFER
*"* do not include other source files here!!!

  class-methods GET_INSTANCE
    returning
      value(RO_BUFFER) type ref to ZCL_IDOC_DB_BUFFER
    raising
      CX_SY_CREATE_OBJECT_ERROR .
  methods GET_MATERIAL_FROM_EINA_EINE
    importing
      !IV_VENDOR type EINA-LIFNR
      !IV_EXT_MATERIAL type EINA-IDNLF
      !IV_PURCH_ORG type EINE-EKORG
      !IV_PLANT type EINE-WERKS optional
    returning
      value(RV_MATNR) type EINA-MATNR .
  methods GET_MATERIAL_FROM_EINA
    importing
      !IV_VENDOR type EINA-LIFNR
      !IV_EXT_MATERIAL type EINA-IDNLF
    returning
      value(RV_MATNR) type EINA-MATNR .
  methods GET_MATERIAL_FROM_MARA_BYGROUP
    importing
      !IV_EXT_MATERIAL type MARA-BISMT
      !IV_MATERIAL_GROUP type MARA-MATKL
    returning
      value(RV_MATNR) type MARA-MATNR .
  methods GET_MATERIAL_FROM_MARA
    importing
      !IV_EXT_MATERIAL type MARA-BISMT
    returning
      value(RV_MATNR) type MARA-MATNR .
  methods GET_MATERIAL_FROM_MARC_BYGROUP
    importing
      !IV_PLANT type MARC-WERKS
      !IV_EXT_MATERIAL type MARA-BISMT
      !IV_MATERIAL_GROUP type MARA-MATKL
    returning
      value(RV_MATNR) type MARA-MATNR .
  methods GET_MATERIAL_FROM_MARC
    importing
      !IV_PLANT type MARC-WERKS
      !IV_EXT_MATERIAL type MARA-BISMT
    returning
      value(RV_MATNR) type MARA-MATNR .
  methods GET_EXT_MATERIAL_FROM_EINA
    importing
      !IV_MATNR type EINA-MATNR
    returning
      value(RV_EXT_MATERIAL) type EINA-IDNLF .
  methods GET_EXT_MATERIAL_FROM_MARA
    importing
      !IV_MATNR type MARA-MATNR
    returning
      value(RV_EXT_MATERIAL) type MARA-BISMT .
  methods GET_BATCH_FROM_MCHA
    importing
      !IV_MATNR type MCHA-MATNR
      !IV_WERKS type MCHA-WERKS
      !IV_EXT_BATCH type MCHA-LICHA
    returning
      value(RV_CHARG) type MCHA-CHARG .
  methods GET_EXT_BATCH_FROM_MCHA
    importing
      !IV_MATNR type MCHA-MATNR
      !IV_WERKS type MCHA-WERKS
      !IV_CHARG type MCHA-CHARG
    returning
      value(RV_EXT_BATCH) type MCHA-LICHA .
  methods GET_SERIAL_FROM_EQUI
    importing
      !IV_MATNR type EQUI-MATNR
      !IV_EXT_SERIAL type EQUI-SERGE
    returning
      value(RV_SERNR) type EQUI-SERNR .
  methods GET_EXT_SERIAL_FROM_EQUI
    importing
      !IV_MATNR type EQUI-MATNR
      !IV_SERNR type EQUI-SERNR
    returning
      value(RV_EXT_SERIAL) type EQUI-SERGE .
  type-pools ABAP .
  methods RETURN_FIELDVALUE_DYNAMICALLY
    importing
      !IS_STRUC type DATA
      !IV_FIELDNAME type ABAP_COMPDESCR-NAME
    exporting
      !EV_FIELDVALUE type ANY
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods LOOKUP_MARA
    importing
      !IV_MATNR type MARA-MATNR
      !IV_FIELDNAME type ABAP_COMPDESCR-NAME
    exporting
      !EV_FIELDVALUE type ANY
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods LOOKUP_MARC
    importing
      !IV_MATNR type MARC-MATNR
      !IV_WERKS type MARC-WERKS
      !IV_FIELDNAME type ABAP_COMPDESCR-NAME
    exporting
      !EV_FIELDVALUE type ANY
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods LOOKUP_MVKE
    importing
      !IV_MATNR type MVKE-MATNR
      !IV_VKORG type MVKE-VKORG
      !IV_VTWEG type MVKE-VTWEG
      !IV_FIELDNAME type ABAP_COMPDESCR-NAME
    exporting
      !EV_FIELDVALUE type ANY
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods LOOKUP_KNA1
    importing
      !IV_KUNNR type KNA1-KUNNR
      !IV_FIELDNAME type ABAP_COMPDESCR-NAME
    exporting
      !EV_FIELDVALUE type ANY
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods LOOKUP_KNB1
    importing
      !IV_KUNNR type KNB1-KUNNR
      !IV_BUKRS type KNB1-BUKRS
      !IV_FIELDNAME type ABAP_COMPDESCR-NAME
    exporting
      !EV_FIELDVALUE type ANY
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
  methods LOOKUP_KNVV
    importing
      !IV_KUNNR type KNVV-KUNNR
      !IV_VKORG type KNVV-VKORG
      !IV_VTWEG type KNVV-VTWEG
      !IV_SPART type KNVV-SPART
      !IV_FIELDNAME type ABAP_COMPDESCR-NAME
    exporting
      !EV_FIELDVALUE type ANY
    raising
      ZCX_IDOC_GENERIC_PROCESS_ERROR .
PROTECTED SECTION.
*"* protected components of class ZCL_IDOC_DB_BUFFER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IDOC_DB_BUFFER
*"* do not include other source files here!!!

  types:
    BEGIN OF ty_eina_lookup ,
          lifnr TYPE eina-lifnr,
          idnlf TYPE eina-idnlf,
          matnr TYPE eina-matnr,
        END OF ty_eina_lookup .
  types:
    BEGIN OF ty_eine_lookup ,
          lifnr TYPE eina-lifnr,
          idnlf TYPE eina-idnlf,
          ekorg TYPE eine-ekorg,
          werks TYPE eine-werks,
          matnr TYPE eina-matnr,
        END OF ty_eine_lookup .
  types:
    BEGIN OF ty_mara_lookup ,
          matkl TYPE mara-matkl,
          bismt TYPE mara-bismt,
          matnr TYPE mara-matnr,
        END OF ty_mara_lookup .
  types:
    BEGIN OF ty_marc_lookup ,
          werks TYPE marc-werks,
          matkl TYPE mara-matkl,
          bismt TYPE mara-bismt,
          matnr TYPE mara-matnr,
        END OF ty_marc_lookup .
  types:
    BEGIN OF ty_mcha_lookup ,
          matnr TYPE mcha-matnr,
          werks TYPE mcha-werks,
          licha TYPE mcha-licha,
          charg TYPE mcha-charg,
        END OF ty_mcha_lookup .
  types:
    BEGIN OF ty_equi_lookup ,
          matnr TYPE equi-matnr,
          serge TYPE equi-serge,
          sernr TYPE equi-sernr,
        END OF ty_equi_lookup .

  class-data O_BUFFER type ref to ZCL_IDOC_DB_BUFFER .
  data:
    t_eina_to_material TYPE SORTED TABLE OF ty_eina_lookup WITH UNIQUE KEY lifnr idnlf .
  data:
    t_eine_to_material TYPE SORTED TABLE OF ty_eine_lookup WITH UNIQUE KEY lifnr idnlf ekorg werks.
  data:
    t_eina_to_ext_material TYPE SORTED TABLE OF ty_eina_lookup WITH UNIQUE KEY matnr .
  data:
    t_mara_to_material TYPE SORTED TABLE OF ty_mara_lookup WITH UNIQUE KEY bismt .
  data:
    t_mara_to_material_by_group TYPE SORTED TABLE OF ty_mara_lookup WITH UNIQUE KEY matkl bismt .
  data:
    t_marc_to_material TYPE SORTED TABLE OF ty_marc_lookup WITH UNIQUE KEY werks bismt .
  data:
    t_marc_to_material_by_group TYPE SORTED TABLE OF ty_marc_lookup WITH UNIQUE KEY werks matkl bismt .
  data:
    t_mara_to_ext_material TYPE SORTED TABLE OF ty_mara_lookup WITH UNIQUE KEY matnr .
  data:
    t_equi_to_serial TYPE SORTED TABLE OF ty_equi_lookup WITH UNIQUE KEY matnr serge .
  data:
    t_equi_to_ext_serial TYPE SORTED TABLE OF ty_equi_lookup WITH UNIQUE KEY matnr sernr .
  data:
    t_mcha_to_batch TYPE SORTED TABLE OF ty_mcha_lookup WITH UNIQUE KEY matnr werks licha .
  data:
    t_mcha_to_ext_batch TYPE SORTED TABLE OF ty_mcha_lookup WITH UNIQUE KEY matnr werks charg .
  data:
    T_MARA TYPE SORTED TABLE OF mara WITH UNIQUE KEY matnr .
  data:
    T_MARC TYPE SORTED TABLE OF marc WITH UNIQUE KEY matnr werks .
  data:
    T_MVKE TYPE SORTED TABLE OF mvke WITH UNIQUE KEY matnr vkorg vtweg .
  data:
    T_KNA1 TYPE SORTED TABLE OF kna1 WITH UNIQUE KEY kunnr .
  data:
    T_KNB1 TYPE SORTED TABLE OF knb1 WITH UNIQUE KEY kunnr bukrs .
  data:
    T_KNVV TYPE SORTED TABLE OF knvv WITH UNIQUE KEY kunnr vkorg vtweg spart .
ENDCLASS.



CLASS ZCL_IDOC_DB_BUFFER IMPLEMENTATION.


method GET_BATCH_FROM_MCHA.

  DATA:
    ls_mcha LIKE LINE OF me->t_mcha_to_batch.

  ls_mcha-matnr = iv_matnr.
  ls_mcha-werks = iv_werks.
  ls_mcha-licha = iv_ext_batch.

* First, read from runtime buffered internal table
  READ TABLE me->t_mcha_to_batch FROM ls_mcha
             INTO ls_mcha
             TRANSPORTING charg.
  IF sy-subrc = 0.
    rv_charg = ls_mcha-charg.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT charg FROM mcha UP TO 1 ROWS
           INTO ls_mcha-charg
           WHERE matnr = ls_mcha-matnr
             AND werks = ls_mcha-werks
             AND licha = ls_mcha-licha.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_charg = ls_mcha-charg.
      INSERT ls_mcha INTO TABLE me->t_mcha_to_batch.
    ENDIF.
  ENDIF.

endmethod.


method GET_EXT_BATCH_FROM_MCHA.

  DATA:
    ls_mcha LIKE LINE OF me->t_mcha_to_ext_batch.

  ls_mcha-matnr = iv_matnr.
  ls_mcha-werks = iv_werks.
  ls_mcha-charg = iv_charg.

* First, read from runtime buffered internal table
  READ TABLE me->t_mcha_to_ext_batch FROM ls_mcha
             INTO ls_mcha
             TRANSPORTING licha.
  IF sy-subrc = 0.
    rv_ext_batch = ls_mcha-licha.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE licha FROM mcha
            INTO ls_mcha-licha
            WHERE matnr = ls_mcha-matnr
              AND werks = ls_mcha-werks
              AND charg = ls_mcha-charg.
    IF sy-subrc = 0.
      rv_ext_batch = ls_mcha-licha.
      INSERT ls_mcha INTO TABLE me->t_mcha_to_ext_batch.
    ENDIF.
  ENDIF.

endmethod.


method GET_EXT_MATERIAL_FROM_EINA.

  DATA:
    ls_eina LIKE LINE OF me->t_eina_to_ext_material.

  ls_eina-matnr = iv_matnr.

* First, read from runtime buffered internal table
  READ TABLE me->t_eina_to_ext_material FROM ls_eina
             INTO ls_eina
             TRANSPORTING idnlf.
  IF sy-subrc = 0.
    rv_ext_material = ls_eina-idnlf.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT idnlf FROM eina UP TO 1 ROWS
                 INTO ls_eina-idnlf
                 WHERE matnr = ls_eina-matnr.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_ext_material = ls_eina-idnlf.
      INSERT ls_eina INTO TABLE me->t_eina_to_ext_material.
    ENDIF.
  ENDIF.

endmethod.


method GET_EXT_MATERIAL_FROM_MARA.

  DATA:
    ls_mara LIKE LINE OF me->t_mara_to_ext_material.

  ls_mara-matnr = iv_matnr.

* First, read from runtime buffered internal table
  READ TABLE me->t_mara_to_ext_material FROM ls_mara
             INTO ls_mara
             TRANSPORTING bismt.
  IF sy-subrc = 0.
    rv_ext_material = ls_mara-bismt.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE bismt FROM mara
            INTO ls_mara-bismt
            WHERE matnr = ls_mara-matnr.
    IF sy-subrc = 0.
      rv_ext_material = ls_mara-bismt.
      INSERT ls_mara INTO TABLE me->t_mara_to_ext_material.
    ENDIF.
  ENDIF.

endmethod.


method GET_EXT_SERIAL_FROM_EQUI.

  DATA:
    ls_equi LIKE LINE OF me->t_equi_to_ext_serial.

  ls_equi-matnr = iv_matnr.
  ls_equi-sernr = iv_sernr.

* First, read from runtime buffered internal table
  READ TABLE me->t_equi_to_ext_serial FROM ls_equi
             INTO ls_equi
             TRANSPORTING serge.
  IF sy-subrc = 0.
    rv_ext_serial = ls_equi-serge.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT serge FROM equi UP TO 1 ROWS
            INTO ls_equi-serge
            WHERE sernr = ls_equi-sernr
              AND matnr = ls_equi-matnr.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_ext_serial = ls_equi-serge.
      INSERT ls_equi INTO TABLE me->t_equi_to_ext_serial.
    ENDIF.
  ENDIF.

endmethod.


method GET_INSTANCE.

* Create singleton so that in any single session, only
* one instance of class exists
  IF o_buffer IS NOT BOUND.
    CREATE OBJECT o_buffer TYPE ZCL_IDOC_DB_BUFFER.
  ENDIF.
  ro_buffer = o_buffer.

endmethod.


method GET_MATERIAL_FROM_EINA.

  DATA:
    ls_eina LIKE LINE OF me->t_eina_to_material.

  ls_eina-lifnr = iv_vendor.
  ls_eina-idnlf = iv_ext_material.

* First, read from runtime buffered internal table
  READ TABLE me->t_eina_to_material FROM ls_eina
             INTO ls_eina
             TRANSPORTING matnr.
  IF sy-subrc = 0.
    rv_matnr = ls_eina-matnr.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT matnr FROM eina UP TO 1 ROWS
                 INTO ls_eina-matnr
                 WHERE lifnr = ls_eina-lifnr
                   AND idnlf = ls_eina-idnlf
                   AND loekz = space.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_matnr = ls_eina-matnr.
      INSERT ls_eina INTO TABLE me->t_eina_to_material.
    ENDIF.
  ENDIF.

endmethod.


method GET_MATERIAL_FROM_EINA_EINE.

  DATA:
    ls_eine LIKE LINE OF me->t_eine_to_material.

  ls_eine-lifnr = iv_vendor.
  ls_eine-idnlf = iv_ext_material.
  ls_eine-ekorg = iv_purch_org.
  ls_eine-werks = iv_plant.

* First, read from runtime buffered internal table
  READ TABLE me->t_eine_to_material FROM ls_eine
             INTO ls_eine
             TRANSPORTING matnr.
  IF sy-subrc = 0.
    rv_matnr = ls_eine-matnr.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    IF iv_plant IS SUPPLIED.
      SELECT eina~matnr UP TO 1 ROWS
                   FROM eina
                   JOIN eine
                     ON eina~infnr = eine~infnr
                   INTO ls_eine-matnr
                   WHERE eina~lifnr = ls_eine-lifnr
                     AND eina~idnlf = ls_eine-idnlf
                     AND eina~loekz = space
                     AND eine~ekorg = iv_purch_org
                     AND eine~werks = iv_plant
                     AND eine~loekz = space.
      ENDSELECT.
    ELSE.
      SELECT eina~matnr UP TO 1 ROWS
                   FROM eina
                   JOIN eine
                     ON eina~infnr = eine~infnr
                   INTO ls_eine-matnr
                   WHERE eina~lifnr = ls_eine-lifnr
                     AND eina~idnlf = ls_eine-idnlf
                     AND eina~loekz = space
                     AND eine~ekorg = iv_purch_org
                     AND eine~loekz = space.
      ENDSELECT.
    ENDIF.

    IF sy-subrc = 0.
      rv_matnr = ls_eine-matnr.
      INSERT ls_eine INTO TABLE me->t_eine_to_material.
    ENDIF.
  ENDIF.

endmethod.


method GET_MATERIAL_FROM_MARA.

  DATA:
    ls_mara LIKE LINE OF me->t_mara_to_material.

  ls_mara-bismt = iv_ext_material.

* First, read from runtime buffered internal table
  READ TABLE me->t_mara_to_material FROM ls_mara
             INTO ls_mara
             TRANSPORTING matnr.
  IF sy-subrc = 0.
    rv_matnr = ls_mara-matnr.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT matnr FROM mara UP TO 1 ROWS
                 INTO ls_mara-matnr
                 WHERE bismt = ls_mara-bismt
                   AND lvorm = space.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_matnr = ls_mara-matnr.
      INSERT ls_mara INTO TABLE me->t_mara_to_material.
    ENDIF.
  ENDIF.

endmethod.


method GET_MATERIAL_FROM_MARA_BYGROUP.

  DATA:
    ls_mara LIKE LINE OF me->t_mara_to_material_by_group.

  ls_mara-matkl = iv_material_group.
  ls_mara-bismt = iv_ext_material.

* First, read from runtime buffered internal table
  READ TABLE me->t_mara_to_material_by_group FROM ls_mara
             INTO ls_mara
             TRANSPORTING matnr.
  IF sy-subrc = 0.
    rv_matnr = ls_mara-matnr.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT matnr FROM mara UP TO 1 ROWS
                 INTO ls_mara-matnr
                 WHERE bismt = ls_mara-bismt
                   AND matkl = ls_mara-matkl
                   AND lvorm = space.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_matnr = ls_mara-matnr.
      INSERT ls_mara INTO TABLE me->t_mara_to_material_by_group.
    ENDIF.
  ENDIF.

endmethod.


method GET_MATERIAL_FROM_MARC.

  DATA:
    ls_marc LIKE LINE OF me->t_marc_to_material.

  ls_marc-werks = iv_plant.
  ls_marc-bismt = iv_ext_material.

* First, read from runtime buffered internal table
  READ TABLE me->t_marc_to_material FROM ls_marc
             INTO ls_marc
             TRANSPORTING matnr.
  IF sy-subrc = 0.
    rv_matnr = ls_marc-matnr.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT mara~matnr UP TO 1 ROWS
                 FROM mara
                 JOIN marc
                   ON mara~matnr = marc~matnr
                 INTO ls_marc-matnr
                 WHERE mara~bismt = ls_marc-bismt
                   AND marc~werks = ls_marc-werks
                   AND mara~lvorm = space
                   AND marc~lvorm = space.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_matnr = ls_marc-matnr.
      INSERT ls_marc INTO TABLE me->t_marc_to_material.
    ENDIF.
  ENDIF.

endmethod.


method GET_MATERIAL_FROM_MARC_BYGROUP.

  DATA:
    ls_marc LIKE LINE OF me->t_marc_to_material_by_group.

  ls_marc-werks = iv_plant.
  ls_marc-matkl = iv_material_group.
  ls_marc-bismt = iv_ext_material.

* First, read from runtime buffered internal table
  READ TABLE me->t_marc_to_material_by_group FROM ls_marc
             INTO ls_marc
             TRANSPORTING matnr.
  IF sy-subrc = 0.
    rv_matnr = ls_marc-matnr.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT mara~matnr UP TO 1 ROWS
                 FROM mara
                 JOIN marc
                   ON mara~matnr = marc~matnr
                 INTO ls_marc-matnr
                 WHERE mara~bismt = ls_marc-bismt
                   AND mara~matkl = ls_marc-matkl
                   AND marc~werks = ls_marc-werks
                   AND mara~lvorm = space
                   AND marc~lvorm = space.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_matnr = ls_marc-matnr.
      INSERT ls_marc INTO TABLE me->t_marc_to_material_by_group.
    ENDIF.
  ENDIF.

endmethod.


method GET_SERIAL_FROM_EQUI.

  DATA:
    ls_equi LIKE LINE OF me->t_equi_to_serial.

  ls_equi-matnr = iv_matnr.
  ls_equi-serge = iv_ext_serial.

* First, read from runtime buffered internal table
  READ TABLE me->t_equi_to_serial FROM ls_equi
             INTO ls_equi
             TRANSPORTING sernr.
  IF sy-subrc = 0.
    rv_sernr = ls_equi-sernr.
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT sernr FROM equi UP TO 1 ROWS
            INTO ls_equi-sernr
            WHERE serge = ls_equi-serge
              AND matnr = ls_equi-matnr.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_sernr = ls_equi-sernr.
      INSERT ls_equi INTO TABLE me->t_equi_to_serial.
    ENDIF.
  ENDIF.

endmethod.


method LOOKUP_KNA1.

  DATA:
    ls_kna1 LIKE LINE OF me->t_kna1.

  CLEAR: ev_fieldvalue.

* First, read from runtime buffered internal table
  READ TABLE me->t_kna1 INTO ls_kna1
                        WITH KEY kunnr = iv_kunnr.
  IF sy-subrc = 0.
    me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_kna1
                                                 iv_fieldname  = iv_fieldname
                                       IMPORTING ev_fieldvalue = ev_fieldvalue ).
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE * FROM kna1 INTO ls_kna1
                    WHERE kunnr = iv_kunnr.
    IF sy-subrc = 0.
      INSERT ls_kna1 INTO TABLE me->t_kna1.
      me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_kna1
                                                   iv_fieldname  = iv_fieldname
                                         IMPORTING ev_fieldvalue = ev_fieldvalue ).
    ENDIF.
  ENDIF.

endmethod.


method LOOKUP_KNB1.

  DATA:
    ls_knb1 LIKE LINE OF me->t_knb1.

  CLEAR: ev_fieldvalue.

* First, read from runtime buffered internal table
  READ TABLE me->t_knb1 INTO ls_knb1
                        WITH KEY kunnr = iv_kunnr
                                 bukrs = iv_bukrs.
  IF sy-subrc = 0.
    me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_knb1
                                                 iv_fieldname  = iv_fieldname
                                       IMPORTING ev_fieldvalue = ev_fieldvalue ).
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE * FROM knb1 INTO ls_knb1
                    WHERE kunnr = iv_kunnr
                      AND bukrs = iv_bukrs.
    IF sy-subrc = 0.
      INSERT ls_knb1 INTO TABLE me->t_knb1.
      me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_knb1
                                                   iv_fieldname  = iv_fieldname
                                         IMPORTING ev_fieldvalue = ev_fieldvalue ).
    ENDIF.
  ENDIF.

endmethod.


method LOOKUP_KNVV.

  DATA:
    ls_knvv LIKE LINE OF me->t_knvv.

  CLEAR: ev_fieldvalue.

* First, read from runtime buffered internal table
  READ TABLE me->t_knvv INTO ls_knvv
                        WITH KEY kunnr = iv_kunnr
                                 vkorg = iv_vkorg
                                 vtweg = iv_vtweg
                                 spart = iv_spart.
  IF sy-subrc = 0.
    me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_knvv
                                                 iv_fieldname  = iv_fieldname
                                       IMPORTING ev_fieldvalue = ev_fieldvalue ).
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE * FROM knvv INTO ls_knvv
                    WHERE kunnr = iv_kunnr
                      AND vkorg = iv_vkorg
                      AND vtweg = iv_vtweg
                      AND spart = iv_spart.
    IF sy-subrc = 0.
      INSERT ls_knvv INTO TABLE me->t_knvv.
      me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_knvv
                                                   iv_fieldname  = iv_fieldname
                                         IMPORTING ev_fieldvalue = ev_fieldvalue ).
    ENDIF.
  ENDIF.

endmethod.


method LOOKUP_MARA.

  DATA:
    ls_mara LIKE LINE OF me->t_mara.

  CLEAR: ev_fieldvalue.

* First, read from runtime buffered internal table
  READ TABLE me->t_mara INTO ls_mara
                        WITH KEY matnr = iv_matnr.
  IF sy-subrc = 0.
    me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_mara
                                                 iv_fieldname  = iv_fieldname
                                       IMPORTING ev_fieldvalue = ev_fieldvalue ).
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE * FROM mara INTO ls_mara
                    WHERE matnr = iv_matnr.
    IF sy-subrc = 0.
      INSERT ls_mara INTO TABLE me->t_mara.
      me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_mara
                                                   iv_fieldname  = iv_fieldname
                                         IMPORTING ev_fieldvalue = ev_fieldvalue ).
    ENDIF.
  ENDIF.

endmethod.


method LOOKUP_MARC.

  DATA:
    ls_marc LIKE LINE OF me->t_marc.

  CLEAR: ev_fieldvalue.

* First, read from runtime buffered internal table
  READ TABLE me->t_marc INTO ls_marc
                        WITH KEY matnr = iv_matnr
                                 werks = iv_werks.
  IF sy-subrc = 0.
    me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_marc
                                                 iv_fieldname  = iv_fieldname
                                       IMPORTING ev_fieldvalue = ev_fieldvalue ).
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE * FROM marc INTO ls_marc
                    WHERE matnr = iv_matnr
                      AND werks = iv_werks.
    IF sy-subrc = 0.
      INSERT ls_marc INTO TABLE me->t_marc.
      me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_marc
                                                   iv_fieldname  = iv_fieldname
                                         IMPORTING ev_fieldvalue = ev_fieldvalue ).
    ENDIF.
  ENDIF.

endmethod.


method LOOKUP_MVKE.

  DATA:
    ls_mvke LIKE LINE OF me->t_mvke.

  CLEAR: ev_fieldvalue.

* First, read from runtime buffered internal table
  READ TABLE me->t_mvke INTO ls_mvke
                        WITH KEY matnr = iv_matnr
                                 vkorg = iv_vkorg
                                 vtweg = iv_vtweg.
  IF sy-subrc = 0.
    me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_mvke
                                                 iv_fieldname  = iv_fieldname
                                       IMPORTING ev_fieldvalue = ev_fieldvalue ).
  ELSE.
*   If not found, then read from database, and populate into
*   buffered table for subsequent reads
    SELECT SINGLE * FROM mvke INTO ls_mvke
                    WHERE matnr = iv_matnr
                      AND vkorg = iv_vkorg
                      AND vtweg = iv_vtweg.
    IF sy-subrc = 0.
      INSERT ls_mvke INTO TABLE me->t_mvke.
      me->return_fieldvalue_dynamically( EXPORTING is_struc      = ls_mvke
                                                   iv_fieldname  = iv_fieldname
                                         IMPORTING ev_fieldvalue = ev_fieldvalue ).
    ENDIF.
  ENDIF.

endmethod.


method RETURN_FIELDVALUE_DYNAMICALLY.

  DATA:
    lo_struct_descr   TYPE REF TO cl_abap_structdescr,
    lv_position       TYPE sy-tabix,
    lv_error_msg      TYPE string.
  FIELD-SYMBOLS:
    <lfs_fieldvalue>  TYPE any.

  CLEAR ev_fieldvalue.

  lo_struct_descr ?= cl_abap_typedescr=>describe_by_data( is_struc ).
  READ TABLE lo_struct_descr->components TRANSPORTING NO FIELDS WITH KEY name = iv_fieldname.
  IF sy-subrc = 0.
    lv_position = sy-tabix.
  ELSE.
*   No field & in structure
    MESSAGE ID 'AD' TYPE 'E' NUMBER '010'
         WITH 'No field' iv_fieldname 'in structure'
         INTO lv_error_msg.
    RAISE EXCEPTION TYPE ZCX_IDOC_GENERIC_PROCESS_ERROR
      EXPORTING
        msg = lv_error_msg.
  ENDIF.

  ASSIGN COMPONENT lv_position OF STRUCTURE is_struc TO <lfs_fieldvalue>.
  IF sy-subrc = 0.
    ev_fieldvalue = <lfs_fieldvalue>.
  ELSE.
*   Error dynamically assigning field & at position & of structure
    MESSAGE ID 'AD' TYPE 'E' NUMBER '010'
         WITH 'Error dynamically assigning field' iv_fieldname 'at position' lv_position
         INTO lv_error_msg.
    RAISE EXCEPTION TYPE ZCX_IDOC_GENERIC_PROCESS_ERROR
      EXPORTING
        msg = lv_error_msg.
  ENDIF.

endmethod.
ENDCLASS.
