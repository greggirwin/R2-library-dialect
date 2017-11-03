REBOL [
    Title:   "Library Interface Dialect"
    File:    %lib-dialect.r
    Author:  "Gregg Irwin"
    Purpose: "Allow for a more concise way to define library routine interfaces."
]

lib-dialect-ctx: context [
    lib: none
    def-rtn-type: none

    name-mods: copy []
    mod-name: func [name] [do join name-mods name]

    ; lib is a global word reference in this func.
    make-dll-func: func [reb-name spec rtn-type name] [
        spec: copy any [spec []]
        if all [rtn-type  'none <> rtn-type] [
            append spec compose/deep [return: [(rtn-type)]]
        ]
        set reb-name make routine! spec lib  mod-name any [name  form reb-name]
    ]

    data-type: [
        'none | 'char | 'short | 'long | 'integer! | 'string! | 'decimal!
        ; TBD add struct support ?
    ]

    func-decl: [
        (spec: name: none  rtn-type: def-rtn-type)
        set reb-name word!
        any [
              [set spec block!]
            | [opt ['returns | 'as] set rtn-type data-type]
            | [opt 'calls set name string!]
        ]
        (make-dll-func reb-name spec rtn-type name)
    ]

    ; You can use this multiple times, e.g. grouping functions by return
    ; type and using it before each group.
    set-def-rtn-type: [
        opt 'set ['def-rtn-type | 'default-return-type]
        set def-rtn-type data-type
    ]

    rules: [
        ['lib | 'library] set file file! (lib: load/library file)
        opt [
            ['modify-import-names | 'mod-imports] set name-mods block!
        ]
        any [set-def-rtn-type | func-decl]
    ]

    set 'make-routines func [spec [any-block!]] [
        clear name-mods
        parse spec rules
    ]
]

