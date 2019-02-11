class ZCX_IDOC_DATA_NOT_FOR_SEND definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.
*"* public components of class ZCX_IDOC_DATA_NOT_FOR_SEND
*"* do not include other source files here!!!

  constants ZCX_IDOC_DATA_NOT_FOR_SEND type SOTR_CONC value '53550E88D1BD0D40E10080000AD00C21'. "#EC NOTEXT
  data MSG type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !MSG type STRING optional .
protected section.
*"* protected components of class ZCX_IDOC_DATA_NOT_FOR_SEND
*"* do not include other source files here!!!
private section.
*"* private components of class ZCX_IDOC_DATA_NOT_FOR_SEND
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCX_IDOC_DATA_NOT_FOR_SEND IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_IDOC_DATA_NOT_FOR_SEND .
 ENDIF.
me->MSG = MSG .
endmethod.
ENDCLASS.
