class ZCX_WRONG_FUNCTION_CALLED definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.
*"* public components of class ZCX_WRONG_FUNCTION_CALLED
*"* do not include other source files here!!!

  constants ZCX_WRONG_FUNCTION_CALLED type SOTR_CONC value '51E61E5E0C1C0900E10080000AD00C21'. "#EC NOTEXT

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
