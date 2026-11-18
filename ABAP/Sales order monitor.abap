
REPORT zsales_order_monitor.

TABLES: vbak, vbap, kna1.

*---------------------------------------------------------------------*
* Type Declaration
*---------------------------------------------------------------------*

TYPES: BEGIN OF ty_sales_order,
         vbeln  TYPE vbak-vbeln,
         kunnr  TYPE vbak-kunnr,
         audat  TYPE vbak-audat,
         posnr  TYPE vbap-posnr,
         matnr  TYPE vbap-matnr,
         kwmeng TYPE vbap-kwmeng,
         vrkme  TYPE vbap-vrkme,
         netwr  TYPE vbap-netwr,
         waerk  TYPE vbak-waerk,
         name1  TYPE kna1-name1,
         maktx  TYPE makt-maktx,
       END OF ty_sales_order.

*---------------------------------------------------------------------*
* Global Data
*---------------------------------------------------------------------*

DATA: gt_sales_orders TYPE STANDARD TABLE OF ty_sales_order,
      go_container    TYPE REF TO cl_gui_custom_container,
      go_alv          TYPE REF TO cl_gui_alv_grid,
      gt_fieldcat     TYPE lvc_t_fcat,
      gs_fieldcat     TYPE lvc_s_fcat,
      gs_layout       TYPE lvc_s_layo.

DATA: gv_currency_count TYPE i,
      gv_currency       TYPE vbak-waerk.

*---------------------------------------------------------------------*
* Event Handler Class Definition
*---------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.

    METHODS:

      on_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id,

      on_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column,

      open_sales_order
        IMPORTING iv_index TYPE lvc_index.

ENDCLASS.

*---------------------------------------------------------------------*
* Event Handler Object
*---------------------------------------------------------------------*

DATA go_event_handler TYPE REF TO lcl_event_handler.

*---------------------------------------------------------------------*
* Event Handler Class Implementation
*---------------------------------------------------------------------*

CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_hotspot_click.

    me->open_sales_order(
      iv_index = e_row_id-index ).

  ENDMETHOD.

  METHOD on_double_click.

    me->open_sales_order(
      iv_index = e_row-index ).

  ENDMETHOD.

  METHOD open_sales_order.

    READ TABLE gt_sales_orders
      INTO DATA(ls_sales_order)
      INDEX iv_index.

    IF sy-subrc = 0.

      SET PARAMETER ID 'AUN'
        FIELD ls_sales_order-vbeln.

      CALL TRANSACTION 'VA03'
        AND SKIP FIRST SCREEN.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS:
  s_vbeln FOR vbak-vbeln,
  s_kunnr FOR vbak-kunnr,
  s_audat FOR vbak-audat.

PARAMETERS:
  p_vkorg TYPE vbak-vkorg.

SELECTION-SCREEN END OF BLOCK b1.

*---------------------------------------------------------------------*
* Start of Selection
*---------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM get_sales_orders.

  IF gt_sales_orders IS INITIAL.

    MESSAGE 'No Sales Orders Found' TYPE 'I'.

  ELSE.

    CALL SCREEN 0100.

  ENDIF.

*---------------------------------------------------------------------*
* Get Sales Orders
*---------------------------------------------------------------------*

FORM get_sales_orders.

  CLEAR gt_sales_orders.

  SELECT
    vbak~vbeln,
    vbap~posnr,
    vbak~kunnr,
    kna1~name1,
    vbap~matnr,
    makt~maktx,
    vbak~audat,
    vbap~kwmeng,
    vbap~vrkme,
    vbap~netwr,
    vbak~waerk

    FROM vbak

    INNER JOIN vbap
      ON vbak~vbeln = vbap~vbeln

    INNER JOIN kna1
      ON vbak~kunnr = kna1~kunnr

    INNER JOIN makt
      ON vbap~matnr = makt~matnr
     AND makt~spras = @sy-langu

    WHERE vbak~vbeln IN @s_vbeln
      AND vbak~kunnr IN @s_kunnr
      AND vbak~audat IN @s_audat
      AND ( @p_vkorg IS INITIAL
            OR vbak~vkorg = @p_vkorg )

    INTO CORRESPONDING FIELDS OF TABLE @gt_sales_orders.

  PERFORM check_currency.

ENDFORM.

*---------------------------------------------------------------------*
* Check Currency
*---------------------------------------------------------------------*

FORM check_currency.

  CLEAR: gv_currency_count,
         gv_currency.

  LOOP AT gt_sales_orders INTO DATA(ls_sales_order).

    IF gv_currency IS INITIAL.

      gv_currency = ls_sales_order-waerk.

    ELSEIF gv_currency <> ls_sales_order-waerk.

      gv_currency_count = 2.
      EXIT.

    ENDIF.

  ENDLOOP.

  IF gv_currency_count = 0 AND gv_currency IS NOT INITIAL.
    gv_currency_count = 1.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Display ALV
*---------------------------------------------------------------------*

FORM display_alv.

  IF go_container IS INITIAL.

    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

    PERFORM build_fieldcat.

    gs_layout-cwidth_opt = 'X'.
    gs_layout-zebra      = 'X'.

    CREATE OBJECT go_event_handler.

    SET HANDLER:
      go_event_handler->on_hotspot_click FOR go_alv,
      go_event_handler->on_double_click  FOR go_alv.

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_sales_orders
        it_fieldcatalog = gt_fieldcat.

  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Add Field Catalog
*---------------------------------------------------------------------*

FORM add_fieldcat USING p_fieldname TYPE lvc_fname
                        p_coltext   TYPE lvc_txt.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = p_fieldname.
  gs_fieldcat-coltext   = p_coltext.

  IF p_fieldname = 'VBELN'.
    gs_fieldcat-hotspot = 'X'.
  ENDIF.

  IF p_fieldname = 'NETWR'.

    gs_fieldcat-cfieldname = 'WAERK'.

    IF gv_currency_count = 1.
      gs_fieldcat-do_sum = 'X'.
    ENDIF.

  ENDIF.

  APPEND gs_fieldcat TO gt_fieldcat.

ENDFORM.

*---------------------------------------------------------------------*
* Build Field Catalog
*---------------------------------------------------------------------*

FORM build_fieldcat.

  CLEAR gt_fieldcat.

  PERFORM add_fieldcat USING 'VBELN'  'Sales Order'.
  PERFORM add_fieldcat USING 'POSNR'  'Item Number'.
  PERFORM add_fieldcat USING 'KUNNR'  'Customer Number'.
  PERFORM add_fieldcat USING 'NAME1'  'Customer Name'.
  PERFORM add_fieldcat USING 'MATNR'  'Material Number'.
  PERFORM add_fieldcat USING 'MAKTX'  'Material Description'.
  PERFORM add_fieldcat USING 'AUDAT'  'Document Date'.
  PERFORM add_fieldcat USING 'KWMENG' 'Order Quantity'.
  PERFORM add_fieldcat USING 'VRKME'  'Sales Unit'.
  PERFORM add_fieldcat USING 'NETWR'  'Net Value'.
  PERFORM add_fieldcat USING 'WAERK'  'Currency'.

ENDFORM.

*---------------------------------------------------------------------*
* PBO Module
*---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.

  SET PF-STATUS 'MAIN'.

ENDMODULE.

MODULE pbo_display_alv OUTPUT.

  PERFORM display_alv.

ENDMODULE.

*---------------------------------------------------------------------*
* PAI Module
*---------------------------------------------------------------------*

MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.

      LEAVE TO SCREEN 0.

    WHEN 'REFRESH'.

      PERFORM get_sales_orders.

      IF go_alv IS BOUND.

        PERFORM build_fieldcat.

        go_alv->set_frontend_fieldcatalog(
          EXPORTING
            it_fieldcatalog = gt_fieldcat ).

        go_alv->refresh_table_display( ).

      ENDIF.

  ENDCASE.

ENDMODULE.
