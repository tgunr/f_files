! File: xattr.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.strings assocs classes.tuple
file.xattr.lib fry io io.encodings io.encodings.utf8 io.files
io.launcher io.streams.c kernel kernel.private libc locals make
math math.parser namespaces prettyprint sequences splitting
strings unix.ffi uuid words ;
IN: file.xattr

TUPLE: xattr name value ;
C: <xattr> xattr 

: nameRead ( xattr -- name )   name>> ;

: soft-quote ( string -- string' )
    "\"" dup surround ;
: hard-quote ( string -- string' )
    "'" dup surround ;

: escape-string-by ( str table -- escaped )
    ! Convert $, (, ), ' and " to shell escapes
    [ '[ dup _ at [ % ] [ , ] ?if ] each ] "" make ;

: escape-string ( str -- str' )
    H{
       { CHAR: \s "\\ "  }
       { CHAR: \n "?"    }
       { CHAR: (  "\\("  }
       { CHAR: )  "\\)"  }
       { CHAR: &  "\\&"  }
       { CHAR: $  "\\$"  }
       { CHAR: ;  "\\;"  }
       { CHAR: "  "\""   }      ! for editor's sake "
       { CHAR: '  "\\'"  } 
       { CHAR: `  "\\`"  }
    } escape-string-by ;

: quoted-value ( xattr -- value )
    value>> soft-quote ;

: (value) ( xattr -- value )
    value>> dup number?
    [ number>string ]
    [ B unparse ]
    if
    ;

: valueRead ( xattr -- value )
    (value) soft-quote
    ;

SYMBOL: XATTRERROR
:: xattrStore ( path xattr -- )
    path  xattr name>>  xattr value>>
    number>string utf8 string>alien setxattr
    XATTRERROR set ;

:: get-xattrs ( path -- {xattr} )
    path xattr-values 
    keys [ path over getxattr  <xattr>  ] map
    ;
    
