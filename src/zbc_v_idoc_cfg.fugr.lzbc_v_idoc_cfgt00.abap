*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.02.2019 at 15:26:45
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBC_V_IDOC_CFG..................................*
TABLES: ZBC_V_IDOC_CFG, *ZBC_V_IDOC_CFG. "view work areas
CONTROLS: TCTRL_ZBC_V_IDOC_CFG
TYPE TABLEVIEW USING SCREEN '2000'.
DATA: BEGIN OF STATUS_ZBC_V_IDOC_CFG. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBC_V_IDOC_CFG.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBC_V_IDOC_CFG_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBC_V_IDOC_CFG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBC_V_IDOC_CFG_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBC_V_IDOC_CFG_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBC_V_IDOC_CFG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBC_V_IDOC_CFG_TOTAL.

*.........table declarations:.................................*
TABLES: ZBC_IDOC_CFG                   .
TABLES: ZBC_IDOC_OPTIONS               .
