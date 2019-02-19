*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 19.02.2019 at 10:24:20
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBC_V_IDOC_OPT..................................*
TABLES: ZBC_V_IDOC_OPT, *ZBC_V_IDOC_OPT. "view work areas
CONTROLS: TCTRL_ZBC_V_IDOC_OPT
TYPE TABLEVIEW USING SCREEN '2000'.
DATA: BEGIN OF STATUS_ZBC_V_IDOC_OPT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBC_V_IDOC_OPT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBC_V_IDOC_OPT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBC_V_IDOC_OPT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBC_V_IDOC_OPT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBC_V_IDOC_OPT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBC_V_IDOC_OPT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBC_V_IDOC_OPT_TOTAL.

*.........table declarations:.................................*
TABLES: ZBC_IDOC_CFG                   .
TABLES: ZBC_IDOC_OPTIONS               .
