! File: xattr.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs classes.tuple fry io io.encodings
io.encodings.utf8 io.files io.launcher io.streams.c kernel
kernel.private libc locals make math math.parser prettyprint sequences
splitting unix.ffi uuid strings words ;
IN: file.xattr

: (command-reader) ( command -- stream|f )
    uuid1 "/tmp/" prepend
    [ " >" prepend append system ] keep
    swap 0=
    [ (file-reader) ]
    [ drop f ]
    if
    ;

: <command-reader> ( command -- stream )
    (command-reader) { file-reader } declare 
    utf8 <decoder> ; inline

: with-command-reader ( command quot -- x )
    [ <command-reader> ] dip
    with-input-stream ; inline

: command-lines ( command -- seq )
    <command-reader> stream-lines ;

: (popen-reader) ( command -- stream|f )
    "r+" popen <c-reader> ;

: <popen-reader> ( command -- stream )
    (popen-reader) { file-reader } declare 
    utf8 <decoder> ; inline

: with-popen-reader ( command quot -- )
    [ <popen-reader> ] dip
    with-input-stream ; inline

:  popen-lines ( command -- seq )
    <popen-reader> stream-lines ;

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

: valueRead ( xattr -- value )
    value>> dup number?
    [ number>string ]
    [ unparse ]
    if
    soft-quote
    ;

:: xattrStore ( path xattr -- )
    "xattr -w "
    xattr nameRead append  +space
    xattr valueRead +space append
    path escape-string append
    run-process wait-for-process .
    ;

:: get-xattrs ( path -- {xattr} )
    "xattr -l "  path escape-string append
    dup HERE.
    utf8
    [ B contents 
      [ ":" split [ [ 32 = ] trim ] map 
        xattr slots>tuple ] map
    ] with-process-reader ;
    
