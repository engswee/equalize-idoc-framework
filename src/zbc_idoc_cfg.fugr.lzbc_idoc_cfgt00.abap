*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.02.2019 at 15:18:48
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBC_IDOC_CFG....................................*
DATA:  BEGIN OF STATUS_ZBC_IDOC_CFG                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_IDOC_CFG                  .
CONTROLS: TCTRL_ZBC_IDOC_CFG
            TYPE TABLEVIEW USING SCREEN '2000'.
*.........table declarations:.................................*
TABLES: *ZBC_IDOC_CFG                  .
TABLES: ZBC_IDOC_CFG                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
