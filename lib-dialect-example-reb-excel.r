REBOL [
    Title:  "Library Dialect Example - REBOL Excel DLL"
    File:   %lib-dialect-example-reb-excel.r
    Author: "Gregg Irwin"
]

do %lib-dialect.r

;-----------------------------------------------------------
;-- Library Declarations -----------------------------------
;--

; For name modifications that take params (other than the name itself),
; you need to wrap them so the name is the last param. e.g.
remove-dashes: func [string] [trim/with string "-"]
dashes-to-underscores: func [string] [replace/all string "-" "_"]
; remove and replace should be included in the dialect context.
; Maybe even have a "replace x with y"/"change x to y" syntax?
remove-all: func [chars string] [trim/with string chars]
replace-all: func [old new string] [replace/all string old new]


dll-funcs: [
    lib %reb-excel.dll
    mod-imports [uppercase remove-all "-"]

    ;com-Init
    ;com-Uninit
    xl-add-workbook
    xl-add-worksheet [name [string!]]
    xl-close
    xl-close-active-workbook
    xl-copy
    xl-copy-to [id [string!]]
    xl-current-cell   string!
    xl-current-column long
    xl-current-row    long
    xl-cut-to [id [string!]]
    xl-cut
    xl-display-alerts [yes-no [integer!]]
    xl-get-selection-value returns string!
    xl-goto [kind [string!] id [string!]]
    xl-open long
    xl-open-file [filename [string!]] long
    xl-paste
    xl-paste-special [type [string!]]
    xl-remove-active-worksheet
    xl-save
    xl-save-as [filename [string!]]
    xl-select [kind [string!] id [string!]]
    xl-select-cell [row [integer!] col [integer!]]
    xl-select-range [id [string!]]
    xl-set-cell-value [row [integer!] col [integer!] val [string!]]
    xl-set-selection-value [val [string!]]
    xl-show
]
make-routines dll-funcs

halt
