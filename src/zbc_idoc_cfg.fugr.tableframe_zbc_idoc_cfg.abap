*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBC_IDOC_CFG
*   generation date: 13.02.2019 at 15:18:47
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBC_IDOC_CFG       .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
