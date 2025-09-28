CLASS zcredit_example DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCREDIT_EXAMPLE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    UPDATE zcredit_bank set state = '1' where credit_no = '0000000006'.

  ENDMETHOD.
ENDCLASS.
