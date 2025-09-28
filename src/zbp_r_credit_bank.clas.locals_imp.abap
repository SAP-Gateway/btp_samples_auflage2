CLASS lhc_zr_credit_bank DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrCreditBank
        RESULT result,
      early_numbering_create FOR NUMBERING
        IMPORTING
          entities FOR CREATE ZrCreditBank,
      validate_credit FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR ZrCreditBank~validate_credit,
      validate_credit_intern
        IMPORTING
          credit TYPE zcredit_bank
        RAISING
          zcx_credit,
      approve_credit FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ZrCreditBank~approve_credit
        RESULT    result,
      deny_credit FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ZrCreditBank~deny_credit
        RESULT    result,
      get_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ZrCreditBank
        RESULT    result,
      set_state FOR DETERMINE ON SAVE
        IMPORTING
          keys FOR ZrCreditBank~set_state.
ENDCLASS.

CLASS lhc_zr_credit_bank IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD early_numbering_create.

    SELECT credit_no FROM zcredit_bank
      ORDER BY credit_no DESCENDING
      INTO @DATA(max_credit_no) UP TO 1 ROWS.
    ENDSELECT.

    DATA(num_credit_no) = CONV i( max_credit_no ).
    LOOP AT entities INTO DATA(entity).

      num_credit_no = num_credit_no + 1.
      DATA(new_credit_no) = CONV zcredit_no( num_credit_no ).
      CONDENSE new_credit_no.
      entity-creditno = |{ new_credit_no ALPHA = IN }|.

      INSERT VALUE #(
        %cid = entity-%cid
        %key = entity-%key
        %is_draft = entity-%is_draft )
        INTO TABLE mapped-zrcreditbank.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_credit.

    READ ENTITIES OF zr_credit_bank IN LOCAL MODE
      ENTITY ZrCreditBank
      FIELDS ( StartYear CreditSum )
      WITH CORRESPONDING #( keys )
      RESULT DATA(credits).

    LOOP AT credits REFERENCE INTO DATA(credit).
      TRY.
          validate_credit_intern(
            VALUE #(
              start_year = credit->*-startyear
              credit_sum = credit->*-creditsum ) ).
        CATCH zcx_credit INTO DATA(error).
          INSERT VALUE #( %tky = credit->*-%tky ) INTO TABLE failed-zrcreditbank.
          INSERT VALUE #( %tky             = credit->*-%tky
                        %state_area      = 'VALIDATE_CREDIT'
                        %msg             = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = error->get_text( ) ) )
                        INTO TABLE reported-zrcreditbank.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_credit_intern.

    IF credit-start_year IS INITIAL.
      RAISE EXCEPTION TYPE zcx_credit
        EXPORTING
          textid = zcx_credit=>start_year_missing.
    ENDIF.

    IF credit-credit_sum <= 0.
      RAISE EXCEPTION TYPE zcx_credit
        EXPORTING
          textid = zcx_credit=>credit_sum_invalid.
    ENDIF.

  ENDMETHOD.

  METHOD get_features.
    CONSTANTS:
      state_new    TYPE zcredit_state VALUE '1',
      state_denied TYPE zcredit_state VALUE '4'.

    READ ENTITIES OF zr_credit_bank IN LOCAL MODE
      ENTITY ZrCreditBank
      FIELDS ( state )
      WITH CORRESPONDING #( keys )
      RESULT DATA(credits).

    result = VALUE #( FOR <credit> IN credits
      ( %tky = <credit>-%tky
        %features-%action-approve_credit = COND #(
         WHEN <credit>-state = state_new OR <credit>-state IS INITIAL
         THEN if_abap_behv=>fc-o-enabled
         ELSE if_abap_behv=>fc-o-disabled )
       %features-%action-deny_credit = COND #(
         WHEN <credit>-state = state_new OR <credit>-state IS INITIAL
         THEN if_abap_behv=>fc-o-enabled
         ELSE if_abap_behv=>fc-o-disabled )
        %features-%delete = COND #(
         WHEN <credit>-state = state_new OR <credit>-state IS INITIAL
         THEN if_abap_behv=>fc-o-enabled
         ELSE if_abap_behv=>fc-o-disabled )
        %features-%update = COND #(
         WHEN <credit>-state = state_denied
         THEN if_abap_behv=>fc-o-disabled
         ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD approve_credit.
    CONSTANTS:
      state_approved TYPE zcredit_state VALUE '2'.

    MODIFY ENTITIES OF zr_credit_bank IN LOCAL MODE
      ENTITY ZrCreditBank
      UPDATE FROM VALUE #(
        FOR <key> IN keys
        ( creditno = <key>-creditno
          state = state_approved
          %control-state = if_abap_behv=>mk-on ) ).

    READ ENTITIES OF zr_credit_bank IN LOCAL MODE
      ENTITY ZrCreditBank
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(credits).

    result = VALUE #(
      FOR <credit> IN credits
      ( %tky = <credit>-%tky
        %param = <credit> ) ).

  ENDMETHOD.

  METHOD deny_credit.
    CONSTANTS:
      state_denied TYPE zcredit_state VALUE '4'.

    MODIFY ENTITIES OF zr_credit_bank IN LOCAL MODE
      ENTITY ZrCreditBank
      UPDATE FROM VALUE #(
        FOR <key> IN keys
        ( creditno = <key>-creditno
          state = state_denied
          denyreason = <key>-%param-denyreason
          %control-state = if_abap_behv=>mk-on
          %control-denyreason = if_abap_behv=>mk-on ) ).

    READ ENTITIES OF zr_credit_bank IN LOCAL MODE
      ENTITY ZrCreditBank
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(credits).

    result = VALUE #(
      FOR <credit> IN credits
      ( %tky = <credit>-%tky
        %param = <credit> ) ).

  ENDMETHOD.

  METHOD set_state.
    CONSTANTS:
      state_new TYPE zcredit_state VALUE '1'.

    MODIFY ENTITIES OF zr_credit_bank IN LOCAL MODE
      ENTITY ZrCreditBank
      UPDATE FROM VALUE #(
        FOR <key> IN keys
        ( creditno = <key>-creditno
          state = state_new
          %control-state = if_abap_behv=>mk-on ) ).

  ENDMETHOD.

ENDCLASS.
