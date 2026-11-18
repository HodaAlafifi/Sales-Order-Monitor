# SAP ABAP – Sales Order Monitor

## Project Overview

**ZSALES_ORDER_MONITOR** is a custom SAP ABAP report designed to monitor Sales Orders and display their header and item details in an interactive ALV Grid.

The report allows users to search for Sales Orders using different selection criteria, review customer and material information, and navigate directly to the Sales Order display transaction.

## Features

- Search Sales Orders using:
  - Sales Order Number
  - Customer Number
  - Document Date
  - Sales Organization
- Retrieve Sales Order header and item data using Open SQL JOINs.
- Display customer and material descriptions.
- Interactive OO ALV Grid.
- Optimized column widths and Zebra layout.
- Hotspot and Double-Click event handling.
- Navigate directly to SAP transaction VA03.
- Refresh displayed data.
- Display Sales Unit and Currency information.
- Currency-aware Net Value aggregation when all displayed records share the same currency.

## SAP Tables Used

| Table | Description |
|---|---|
| VBAK | Sales Document Header |
| VBAP | Sales Document Item |
| KNA1 | Customer Master General Data |
| MAKT | Material Descriptions |

## Technical Concepts

This project demonstrates practical knowledge of:

- ABAP Reports and Event Blocks
- Selection Screen
- Open SQL
- INNER JOIN
- Internal Tables and Structures
- `INTO CORRESPONDING FIELDS OF TABLE`
- Modularization using FORM routines
- Object-Oriented ABAP
- Local Classes and Methods
- ALV Grid Control (`CL_GUI_ALV_GRID`)
- Custom Container (`CL_GUI_CUSTOM_CONTAINER`)
- Field Catalog and Layout
- ALV Event Handling
- Hotspot and Double-Click Events
- Screen Programming (PBO / PAI)
- GUI Status and Function Codes
- SAP Transaction Navigation
- Currency and Unit of Measure References

## User Interface

The report contains a selection screen for filtering Sales Orders and an interactive ALV Grid for displaying the results.

### Selection Screen
Add a screenshot here.

### ALV Output
Add a screenshot here.

## Installation and Setup

1. Create an executable ABAP report named `ZSALES_ORDER_MONITOR`.
2. Copy the source code into the report.
3. Create Screen `0100`.
4. Add a Custom Control named `CC_ALV` to Screen 0100.
5. Configure the screen flow logic with the required PBO and PAI modules.
6. Create GUI Status `MAIN` in SE41.
7. Add the required function codes:
   - `BACK`
   - `EXIT`
   - `CANCEL`
   - `REFRESH`
8. Maintain Text Symbol `001` as `Sales Order Selection`.
9. Activate the program and screen objects.
10. Execute the report.

## Requirements

- SAP system with ABAP development access.
- Sales Order data available in VBAK and VBAP.
- Customer data available in KNA1.
- Material descriptions available in MAKT.

## Future Improvements

- Add Sales Order status information.
- Add advanced filtering options.
- Improve error and exception handling.
- Add additional ALV navigation features.
- Enhance the report with more business-oriented analytics.

## Author

**Hoda Alafifi**

Aspiring SAP ABAP Developer

