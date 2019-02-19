class ZCX_WRONG_FUNCTION_CALLED definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

*"* public components of class ZCX_WRONG_FUNCTION_CALLED
*"* do not include other source files here!!!
  constants ZCX_WRONG_FUNCTION_CALLED type SOTR_CONC value '00505697691A1ED98BBA9D91B295E51D' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .
protected section.
*"* protected components of class ZCX_WRONG_FUNCTION_CALLED
*"* do not include other source files here!!!
private section.
*"* private components of class ZCX_WRONG_FUNCTION_CALLED
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCX_WRONG_FUNCTION_CALLED IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_WRONG_FUNCTION_CALLED .
 ENDIF.
  endmethod.
ENDCLASS.
