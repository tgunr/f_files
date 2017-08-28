! File: xattr.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors classes.tuple io io.encodings io.encodings.utf8 io.files
io.streams.c kernel kernel.private libc sequences splitting
unix.ffi uuid ;
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

: quoted-value ( xattr -- value )
    value>>  "\"" dup surround ;

: set-xattr ( path xattr -- )
    "xattr -w "  over name>> append
    " " append
    swap quoted-value  append  
    " " append
    prepend
    system drop ;

: get-xattrs ( path -- {xattr} )
    "xattr -l " prepend command-lines
    [ ":" split [ [ 32 = ] trim ] map 
      xattr slots>tuple ] map ;


: test ( -- x )
    "~/test"
    [ "net.polymicro.sha" "sha" <xattr> set-xattr ] keep
    get-xattrs ;
    
