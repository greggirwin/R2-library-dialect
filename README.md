# R2-library-dialect

Old Rebol 2 Library Interface Dialect

- author: Gregg Irwin
- date:   6-Nov-2004
    
# Overview

The REBOL library interface, for declaring routines in DLLs,
is good, but requires a lot of redundancy if you're accessing
a lot of functions in the same library, and it isn't always
as concise as it could be in any case. That said, it's a great
foundation to build on, and maybe RT couldn't simplify it
further without constraining us too much.

The goal of the lib-dialect.r Library Dialect is to make it
faster and easier to access routines in DLLs.


# Main Function

<b>make-routines</b> is the dialected function you use to declare
routines. The spec you pass it includes the library name,
special commands, and function interface definitions.

    make-routines [spec]


# Dialect


## Library Declaration

The first thing in the spec block you pass to make-routines
should be the library declaration itself. A file value,
preceded by the word <b>lib</b> or <b>library</b> will do the trick.

    lib %my-library.dll
    library %my-library.dll


## Modifying Import Names

The next item in the spec is optional. You can include commands
to modify the function names, as they are declared in the DLL,
relative to the REBOL names you give the routines. The commands
can be any standard REBOL code, given as a single block.

How and why does it work? Let's say you have a DLL where the
functions are exported as all uppercase and, as with most
languages, dashes aren't allowed in function names; in REBOL
you want to use lower case names and include dashes in the names.
You can do this manually, like so:

    no-param-sub [] "NOPARAMSUB"

Or you can include a modify-import-names block and those "rules"
will be applied to all names as functions are imported.

    remove-all: func [chars string] [trim/with string chars]
    modify-import-names [uppercase remove-all "-"]

To include name modification, use the word <b>modify-import-names</b>
or <b>mod-imports</b>, followed by a block containing the commands
you want to use.

    remove-all: func [chars string] [trim/with string chars]

    modify-import-names [uppercase remove-all "-"]
    mod-imports [uppercase remove-all "-"]

The one big trick/limitation to the command block is that the
routine name is implied as the final value in the block. That 
is, the command block has the routine name JOINed to the end, 
then the block is DOne, so you may need to write wrapper 
functions--like REMOVE-ALL above--to change the order of 
parameters.

All function names are affected; there is no way to turn name
modification on for only certain functions.

\note
    This was a quick and easy way to implement the basic
    idea, but don't consider it a final design goal if we
    can come up with something better.
/note


## Function Declarations

Functions have a REBOL name, an interface spec, a return type,
and a name as it is exported from the DLL. After the REBOL name,
the spec, return type, and native name can appear in any order.


### Interface Specs

The REBOL name is the only required element; it is just a word
(not a set-word!). If the DLL function takes no parameters,
returns no value, and matches the REBOL name (after
modify-import-names is applied), you don't need anything else to
declare a routine.

    my-no-param-sub

If you want to use a REBOL name that isn't mapped to the native
function name, you can include the native function name, as a
string. You can, optionally, put the word <b>calls</b> in front
of the string if you want, for readability.

    my-no-param-sub "NOPARAMSHERE"
    my-no-param-sub calls "NOPARAMSHERE"

If the function returns a value, you can include that information
by declaring the datatype, optionally preceded by the word 'returns
or 'as. For example:

    rndchar char
    rndchar as char
    rndchar returns char

The way the standard REBOL routine dialect works, the return
type is part of the interface spec--which makes sense if you
think about it--but requires that you name the final item in
the spec return: (as a set-word!). More than once I've messed
up this simple step and spent time tracking it down.

\note
    See also: Datatypes, Default Return Types
/note

If the function takes parameters, they are declared as a block,
just as you would for a REBOL function (except that they can't
accept multiple data types for a single argument).

    add-one [val [integer!]] returns integer!

    regex-replace [
        string   [string!]
        pattern  [string!]
        new-data [string!]
    ] returns string!


### Datatypes

The REBOL library interface doesn't support all REBOL datatypes,
and it has a few non-REBOL types as well.

    none
    char
    short
    long
    integer!
    string!
    decimal!


### Default Return Type

If you have multiple functions that return the same data type
as a result, you can set a default return type that will be
used for all functions declared until the next <b>default-return-type</b>
command is encountered.

    set def-rtn-type <datatype>
    set default-return-type <datatype>
    def-rtn-type <datatype>
    default-return-type <datatype>


Example:

    remove-all: func [chars string] [trim/with string chars]

    make-routines [

        library %my-library.dll

        ;-- The following modify-import-names rules are in effect,
        ;   based on a DLL that exports names as all uppercase.
        remove-all: func [chars string] [trim/with string chars]
        modify-import-names [uppercase remove-all "-"]

        ;----------------------------------------------------------
        ;-- Functions that take no args, and return no value.

        def-rtn-type none ; This turns off any default rtn type set

        ;-- All the following are equivalent
        no-param-sub [] "NOPARAMSUB"
        NOPARAMSUB []
        NOPARAMSUB
        noparamsub
        no-param-sub [] none "NOPARAMSUB"
        no-param-sub

        ;-- One long param, no return value
        one-long-param-sub [val [integer!]]

        ;-- No params, returns char
        def-rtn-type char
        ;-- All the following are equivalent
        rnd-char  [] char "RNDCHAR"
        rnd-char  [] returns char "RNDCHAR"
        RNDCHAR   [] char
        rnd-char  char "RNDCHAR"
        RNDCHAR char
        rndchar char
        rndchar as char
        rndchar returns char
        rnd-char
        add-char  [val [char]] char

        rnd-short [] short
        add-short [val [short]] short
        rnd-long  [] integer!
        add-one   [val [integer!]] integer!

        ;-- Note the use of a default return type here
        set default-return-type decimal!
        rnd-decimal []
        dec-add   [val [decimal!]]

        ;-- The default return type is still in effect, but the
        ;   following declarations override it.

        format-number [value [decimal!] fmt [string!]] string!

        make-long [low [short] high [short]] integer!

        regex-replace [
            string [string!]
            pattern [string!]
            new-data [string!]
        ] string!
    ]

# Current Limitations

Routine names are global when they are created, they are not
bound into the context where make-routines is called.

There is no way to manually free the library you're importing
from.
