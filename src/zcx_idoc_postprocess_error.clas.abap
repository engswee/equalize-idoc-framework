class ZCX_IDOC_POSTPROCESS_ERROR definition
  public
  inheriting from ZCX_IDOC_GENERIC_PROCESS_ERROR
  final
  create public .

public section.

*"* public components of class ZCX_IDOC_POSTPROCESS_ERROR
*"* do not include other source files here!!!
  constants ZCX_IDOC_POSTPROCESS_ERROR type SOTR_CONC value '00505697691A1ED98BBA9D424303051D' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !MSGTY type SY-MSGTY optional
      !MSG type STRING optional
      !MSGID type SY-MSGID optional
      !MSGNO type SY-MSGNO optional
      !MSGV1 type SY-MSGV1 optional
      !MSGV2 type SY-MSGV2 optional
      !MSGV3 type SY-MSGV3 optional
      !MSGV4 type SY-MSGV4 optional .
protected section.
*"* protected components of class ZCX_IDOC_POSTPROCESS_ERROR
*"* do not include other source files here!!!
private section.
*"* private components of class ZCX_IDOC_POSTPROCESS_ERROR
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCX_IDOC_POSTPROCESS_ERROR IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
MSGTY = MSGTY
MSG = MSG
MSGID = MSGID
MSGNO = MSGNO
MSGV1 = MSGV1
MSGV2 = MSGV2
MSGV3 = MSGV3
MSGV4 = MSGV4
.
 IF textid IS INITIAL.
   me->textid = ZCX_IDOC_POSTPROCESS_ERROR .
 ENDIF.
  endmethod.
ENDCLASS.
