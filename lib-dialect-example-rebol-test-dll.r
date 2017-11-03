REBOL []

do %lib-dialect.r

; For name modifications that take params (other than the name itself),
; you need to wrap them so the name is the last param. e.g.
remove-dashes: func [string] [trim/with string "-"]
dashes-to-underscores: func [string] [replace/all string "-" "_"]
; remove and replace should be included in the dialect context.
; Maybe even have a "replace x with y"/"change x to y" syntax?
remove-all: func [chars string] [trim/with string chars]
replace-all: func [old new string] [replace/all string old new]

dll-funcs: [
    lib %rebol-test-dll.dll
    ;library %rebol-test-dll.dll
    ;from %rebol-test-dll.dll
    ;file %rebol-test-dll.dll

    ;export (a.k.a. globalize)
    ;export all
    ;export [rnd-char add-char]

    mod-imports [uppercase remove-all "-"]

    ; -- Data type tests
    ;def-rtn-type none
    no-param-sub [] "NOPARAMSUB"
    NOPARAMSUB []   ;<< uppercase here since the word is formed directly for
    NOPARAMSUB      ;<< use as the DLL func name, and PB uppercases them.
    noparamsub
    no-param-sub [] none "NOPARAMSUB"
    no-param-sub
    no-param-sub calls "NOPARAMSUB"
    one-long-param-sub [val [integer!]] none "ONELONGPARAMSUB"

    def-rtn-type char
    rnd-char  [] char "RNDCHAR"
    rnd-char  [] returns char "RNDCHAR"
    RNDCHAR   [] char
    rnd-char  char "RNDCHAR"
    RNDCHAR char
    rndchar char
    rndchar as char
    rndchar returns char
    rnd-char
    rnd-char  calls "RNDCHAR" returns char
    add-char  [val [char]] char

    rnd-short [] short
    add-short [val [short]] short
    rnd-long  [] integer!
    add-one   [val [integer!]] integer!

    set default-return-type decimal!  ; Use if no rtn-type given (NONE overrides)

    rnd-decimal [] ;decimal!
    dec-add   [val [decimal!]] ;decimal!
    rnd-double [] ;decimal!
    dbl-add   [val [decimal!]] ;decimal!

    cap-first [val [string!]] string!
    ;-- Useful functions
    change-mouse-pointer [style [integer!]] none
    disk-capacity [drive [string!]] decimal!

    EnumTopLevelWindows integer!        ; << call this
    EnumTopLevelWindowResults string!   ;    then call this to get the results

    format-number [value [decimal!] fmt [string!]] string!
    free-disk-space [drive [string!]] decimal!
    GUID-text [val [string!]]  string!
    high-byte [val [short]] char

    def-rtn-type short  ; Use if no rtn-type given (NONE overrides)

    high-int  [val [integer!]] ;short
    high-word [val [integer!]] ;short
    low-byte  [val [short]] char
    low-int   [val [integer!]] short
    low-word  [val [integer!]] short
    ;make-dword [low [short] high [short]] integer!
    make-GUID [val [string!]] string!
    make-int  [low [char] high [char]] short
    make-long [low [short] high [short]] integer!
    ;make-word [low [char] high [char]] short
    regex-find [string [string!] pattern [string!]] string!
    ;regex-find [string [string!] pattern [string!]] string!
    ;regex-replace [string [string!] pattern [string!] new-data [string!]] string!
    to-number [string [string!]] integer!
    to-octal  [value [integer!]] string!
]

;
; ; lib is a global word reference in this func.
; dll-func: func [specs name] [make routine! specs lib name]
;
; ; uppercase is used here since PowerBASIC exports things that way.
; foreach [fn-word spec rtn-type fn-name] dll-funcs [
;     print [mold rtn-type type? rtn-type]
;     if 'none <> rtn-type [
;         append spec compose/deep [return: [(rtn-type)]]
;     ]
;     ;print mold spec
;     set fn-word dll-func spec uppercase fn-name
; ]
; ;halt

make-routines dll-funcs


;---------------------------------------------------------------

mouse-pointers: [   ; order is important here!
    Hide
    Arrow
    Cross
    I-Beam
    Arrow-2       ; same as arrow
    Size-all
    Size-NE-SW
    Size-vertical
    Size-NW-SE
    Size-horizontal
    Up-arrow
    Hourglass
    Busy
    No-pointer
    App-Starting
]
set-cursor: func ['style] [
    change-mouse-pointer subtract index? find mouse-pointers style 1
]

;---------------------------------------------------------------

no-param-sub
one-long-param-sub 0
one-long-param-sub 1

print rnd-char
print rnd-char
print [res: add-char #"^@"  tab to integer! res]
print add-char #"þ"
print [res: add-char #"ÿ"   tab to integer! res]


print rnd-short
print rnd-short
print add-short 0
print add-short 65534
print add-short 65535

print rnd-long
print rnd-long
print rnd-long
print add-one 100
print add-one 1000
print add-one 2147483646
print add-one 2147483647

print rnd-decimal
print rnd-decimal
print dec-add 0
print dec-add 1.1

print rnd-double
print rnd-double
print dbl-add 0
print dbl-add 1.1

print cap-first "gregg irwin"
print cap-first "abc"
print cap-first "ab^@c"
print cap-first "^@abc"

; repeat i 1'000'000 [
;recycle/off
; repeat i 100'000 [
;     cap-first "gregg irwin"
; ;    if 0 = remainder i 10 [
; ;    ;    prin "."
; ;        recycle
; ;        wait .01
; ;    ]
; ]
;recycle/on
;recycle

print regex-find "Gregg Sherman-Stanley Irwin" "-S"
print regex-find "Gregg Sherman-Stanley Irwin" "er.*an"

;
; ;repeat i 1'000'000 [
; repeat i 100'000 [
;     regex-find "Gregg Sherman-Stanley Irwin" "er.*an"
;     ;if 0 = remainder i 10'000 [
;     ;    prin "."
;     ;    recycle
;     ;    wait .1
;     ;]
; ]
; print ""

print ["Capacity of drive C:" res: disk-capacity "C" "bytes" tab res / 1024 "KB"]
print ["Capacity of drive D:" res: disk-capacity "D" "bytes" tab res / 1024 "KB"]
print ["Capacity of drive E:" res: disk-capacity "E" "bytes" tab res / 1024 "KB"]
;print ["Capacity of drive F:" res: disk-capacity "F" "bytes" tab res / 1024 "KB"]

print ["Free space on drive C:" res: free-disk-space "C" "bytes" tab res / 1024 "KB"]
print ["Free space on drive D:" res: free-disk-space "D" "bytes" tab res / 1024 "KB"]
print ["Free space on drive E:" res: free-disk-space "E" "bytes" tab res / 1024 "KB"]
;print ["Free space on drive F:" res: free-disk-space "F" "bytes" tab res / 1024 "KB"]


print format-number 1234567890.0 "#,"
print format-number 1234567890.0 "$**###,.00"
print format-number 0.0 "00.00"
print format-number 0.5 "0.0%"

print [res: make-GUID ""   to binary! res]
print res: GUID-text res
print [res: make-GUID res  to binary! res]

val: -1357
print lb: low-byte val
print hb: high-byte val
;print make-word lb hb
print make-int lb hb

val: -35357
print li: low-int val
print ['high-int hi: high-int val]
;print make-dword lw hw
print make-long li hi
;print make-long -1000 -2000

val: -45678
print lw: low-word val
print ['high-word hw: high-word val]
;print make-dword lw hw
print make-long lw hw
;print make-long -1000 -2000

;foreach style mouse-pointers [set-cursor :style wait .5]
; the console resets it outside of our control
;set-cursor arrow-2 wait 3
;set-cursor arrow wait 3
set-cursor arrow

print EnumTopLevelWindows
print b: to block! EnumTopLevelWindowResults

print to-octal 8
print to-octal 9
print to-octal 32767
print to-octal 65535
print to-number "&O10"
print to-number "&O37777777777"
tmp: join "&O" to-octal 65535
print to-number tmp
;!! This is a problem in the library interface!
;print to-number join "&O" to-octal 65535

; print stats
; recycle
; wait 5
; print stats


halt
