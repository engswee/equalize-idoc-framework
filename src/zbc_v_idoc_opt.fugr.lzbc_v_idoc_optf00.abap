*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 19.02.2019 at 10:24:21
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBC_V_IDOC_OPT..................................*
FORM GET_DATA_ZBC_V_IDOC_OPT.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZBC_IDOC_OPTIONS WHERE
(VIM_WHERETAB) .
    CLEAR ZBC_V_IDOC_OPT .
ZBC_V_IDOC_OPT-MANDT =
ZBC_IDOC_OPTIONS-MANDT .
ZBC_V_IDOC_OPT-DIRECT =
ZBC_IDOC_OPTIONS-DIRECT .
ZBC_V_IDOC_OPT-PARNUM =
ZBC_IDOC_OPTIONS-PARNUM .
ZBC_V_IDOC_OPT-PARTYP =
ZBC_IDOC_OPTIONS-PARTYP .
ZBC_V_IDOC_OPT-PARFCT =
ZBC_IDOC_OPTIONS-PARFCT .
ZBC_V_IDOC_OPT-MESTYP =
ZBC_IDOC_OPTIONS-MESTYP .
ZBC_V_IDOC_OPT-MESCOD =
ZBC_IDOC_OPTIONS-MESCOD .
ZBC_V_IDOC_OPT-MESFCT =
ZBC_IDOC_OPTIONS-MESFCT .
ZBC_V_IDOC_OPT-MATNR_CONV =
ZBC_IDOC_OPTIONS-MATNR_CONV .
ZBC_V_IDOC_OPT-CUST_CONV =
ZBC_IDOC_OPTIONS-CUST_CONV .
ZBC_V_IDOC_OPT-UOM_CONV =
ZBC_IDOC_OPTIONS-UOM_CONV .
    SELECT SINGLE * FROM ZBC_IDOC_CFG WHERE
DIRECT = ZBC_IDOC_OPTIONS-DIRECT AND
PARNUM = ZBC_IDOC_OPTIONS-PARNUM AND
PARTYP = ZBC_IDOC_OPTIONS-PARTYP AND
PARFCT = ZBC_IDOC_OPTIONS-PARFCT AND
MESTYP = ZBC_IDOC_OPTIONS-MESTYP AND
MESCOD = ZBC_IDOC_OPTIONS-MESCOD AND
MESFCT = ZBC_IDOC_OPTIONS-MESFCT .
    IF SY-SUBRC EQ 0.
    ENDIF.
<VIM_TOTAL_STRUC> = ZBC_V_IDOC_OPT.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZBC_V_IDOC_OPT .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZBC_V_IDOC_OPT.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZBC_V_IDOC_OPT-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZBC_IDOC_OPTIONS WHERE
  DIRECT = ZBC_V_IDOC_OPT-DIRECT AND
  PARNUM = ZBC_V_IDOC_OPT-PARNUM AND
  PARTYP = ZBC_V_IDOC_OPT-PARTYP AND
  PARFCT = ZBC_V_IDOC_OPT-PARFCT AND
  MESTYP = ZBC_V_IDOC_OPT-MESTYP AND
  MESCOD = ZBC_V_IDOC_OPT-MESCOD AND
  MESFCT = ZBC_V_IDOC_OPT-MESFCT .
    IF SY-SUBRC = 0.
    DELETE ZBC_IDOC_OPTIONS .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZBC_IDOC_OPTIONS WHERE
  DIRECT = ZBC_V_IDOC_OPT-DIRECT AND
  PARNUM = ZBC_V_IDOC_OPT-PARNUM AND
  PARTYP = ZBC_V_IDOC_OPT-PARTYP AND
  PARFCT = ZBC_V_IDOC_OPT-PARFCT AND
  MESTYP = ZBC_V_IDOC_OPT-MESTYP AND
  MESCOD = ZBC_V_IDOC_OPT-MESCOD AND
  MESFCT = ZBC_V_IDOC_OPT-MESFCT .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZBC_IDOC_OPTIONS.
    ENDIF.
ZBC_IDOC_OPTIONS-MANDT =
ZBC_V_IDOC_OPT-MANDT .
ZBC_IDOC_OPTIONS-DIRECT =
ZBC_V_IDOC_OPT-DIRECT .
ZBC_IDOC_OPTIONS-PARNUM =
ZBC_V_IDOC_OPT-PARNUM .
ZBC_IDOC_OPTIONS-PARTYP =
ZBC_V_IDOC_OPT-PARTYP .
ZBC_IDOC_OPTIONS-PARFCT =
ZBC_V_IDOC_OPT-PARFCT .
ZBC_IDOC_OPTIONS-MESTYP =
ZBC_V_IDOC_OPT-MESTYP .
ZBC_IDOC_OPTIONS-MESCOD =
ZBC_V_IDOC_OPT-MESCOD .
ZBC_IDOC_OPTIONS-MESFCT =
ZBC_V_IDOC_OPT-MESFCT .
ZBC_IDOC_OPTIONS-MATNR_CONV =
ZBC_V_IDOC_OPT-MATNR_CONV .
ZBC_IDOC_OPTIONS-CUST_CONV =
ZBC_V_IDOC_OPT-CUST_CONV .
ZBC_IDOC_OPTIONS-UOM_CONV =
ZBC_V_IDOC_OPT-UOM_CONV .
    IF SY-SUBRC = 0.
    UPDATE ZBC_IDOC_OPTIONS ##WARN_OK.
    ELSE.
    INSERT ZBC_IDOC_OPTIONS .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZBC_V_IDOC_OPT-UPD_FLAG,
STATUS_ZBC_V_IDOC_OPT-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZBC_V_IDOC_OPT.
  SELECT SINGLE * FROM ZBC_IDOC_OPTIONS WHERE
DIRECT = ZBC_V_IDOC_OPT-DIRECT AND
PARNUM = ZBC_V_IDOC_OPT-PARNUM AND
PARTYP = ZBC_V_IDOC_OPT-PARTYP AND
PARFCT = ZBC_V_IDOC_OPT-PARFCT AND
MESTYP = ZBC_V_IDOC_OPT-MESTYP AND
MESCOD = ZBC_V_IDOC_OPT-MESCOD AND
MESFCT = ZBC_V_IDOC_OPT-MESFCT .
ZBC_V_IDOC_OPT-MANDT =
ZBC_IDOC_OPTIONS-MANDT .
ZBC_V_IDOC_OPT-DIRECT =
ZBC_IDOC_OPTIONS-DIRECT .
ZBC_V_IDOC_OPT-PARNUM =
ZBC_IDOC_OPTIONS-PARNUM .
ZBC_V_IDOC_OPT-PARTYP =
ZBC_IDOC_OPTIONS-PARTYP .
ZBC_V_IDOC_OPT-PARFCT =
ZBC_IDOC_OPTIONS-PARFCT .
ZBC_V_IDOC_OPT-MESTYP =
ZBC_IDOC_OPTIONS-MESTYP .
ZBC_V_IDOC_OPT-MESCOD =
ZBC_IDOC_OPTIONS-MESCOD .
ZBC_V_IDOC_OPT-MESFCT =
ZBC_IDOC_OPTIONS-MESFCT .
ZBC_V_IDOC_OPT-MATNR_CONV =
ZBC_IDOC_OPTIONS-MATNR_CONV .
ZBC_V_IDOC_OPT-CUST_CONV =
ZBC_IDOC_OPTIONS-CUST_CONV .
ZBC_V_IDOC_OPT-UOM_CONV =
ZBC_IDOC_OPTIONS-UOM_CONV .
    SELECT SINGLE * FROM ZBC_IDOC_CFG WHERE
DIRECT = ZBC_IDOC_OPTIONS-DIRECT AND
PARNUM = ZBC_IDOC_OPTIONS-PARNUM AND
PARTYP = ZBC_IDOC_OPTIONS-PARTYP AND
PARFCT = ZBC_IDOC_OPTIONS-PARFCT AND
MESTYP = ZBC_IDOC_OPTIONS-MESTYP AND
MESCOD = ZBC_IDOC_OPTIONS-MESCOD AND
MESFCT = ZBC_IDOC_OPTIONS-MESFCT .
    IF SY-SUBRC EQ 0.
    ELSE.
      CLEAR SY-SUBRC.
    ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZBC_V_IDOC_OPT USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZBC_V_IDOC_OPT-DIRECT TO
ZBC_IDOC_OPTIONS-DIRECT .
MOVE ZBC_V_IDOC_OPT-PARNUM TO
ZBC_IDOC_OPTIONS-PARNUM .
MOVE ZBC_V_IDOC_OPT-PARTYP TO
ZBC_IDOC_OPTIONS-PARTYP .
MOVE ZBC_V_IDOC_OPT-PARFCT TO
ZBC_IDOC_OPTIONS-PARFCT .
MOVE ZBC_V_IDOC_OPT-MESTYP TO
ZBC_IDOC_OPTIONS-MESTYP .
MOVE ZBC_V_IDOC_OPT-MESCOD TO
ZBC_IDOC_OPTIONS-MESCOD .
MOVE ZBC_V_IDOC_OPT-MESFCT TO
ZBC_IDOC_OPTIONS-MESFCT .
MOVE ZBC_V_IDOC_OPT-MANDT TO
ZBC_IDOC_OPTIONS-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZBC_IDOC_OPTIONS'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZBC_IDOC_OPTIONS TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZBC_IDOC_OPTIONS'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
FORM COMPL_ZBC_V_IDOC_OPT USING WORKAREA.
*      provides (read-only) fields from secondary tables related
*      to primary tables by foreignkey relationships
ZBC_IDOC_OPTIONS-MANDT =
ZBC_V_IDOC_OPT-MANDT .
ZBC_IDOC_OPTIONS-DIRECT =
ZBC_V_IDOC_OPT-DIRECT .
ZBC_IDOC_OPTIONS-PARNUM =
ZBC_V_IDOC_OPT-PARNUM .
ZBC_IDOC_OPTIONS-PARTYP =
ZBC_V_IDOC_OPT-PARTYP .
ZBC_IDOC_OPTIONS-PARFCT =
ZBC_V_IDOC_OPT-PARFCT .
ZBC_IDOC_OPTIONS-MESTYP =
ZBC_V_IDOC_OPT-MESTYP .
ZBC_IDOC_OPTIONS-MESCOD =
ZBC_V_IDOC_OPT-MESCOD .
ZBC_IDOC_OPTIONS-MESFCT =
ZBC_V_IDOC_OPT-MESFCT .
ZBC_IDOC_OPTIONS-MATNR_CONV =
ZBC_V_IDOC_OPT-MATNR_CONV .
ZBC_IDOC_OPTIONS-CUST_CONV =
ZBC_V_IDOC_OPT-CUST_CONV .
ZBC_IDOC_OPTIONS-UOM_CONV =
ZBC_V_IDOC_OPT-UOM_CONV .
    SELECT SINGLE * FROM ZBC_IDOC_CFG WHERE
DIRECT = ZBC_IDOC_OPTIONS-DIRECT AND
PARNUM = ZBC_IDOC_OPTIONS-PARNUM AND
PARTYP = ZBC_IDOC_OPTIONS-PARTYP AND
PARFCT = ZBC_IDOC_OPTIONS-PARFCT AND
MESTYP = ZBC_IDOC_OPTIONS-MESTYP AND
MESCOD = ZBC_IDOC_OPTIONS-MESCOD AND
MESFCT = ZBC_IDOC_OPTIONS-MESFCT .
    IF SY-SUBRC EQ 0.
    ELSE.
      CLEAR SY-SUBRC.
    ENDIF.
ENDFORM.
