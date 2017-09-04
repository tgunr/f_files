! File: lib.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: alien.c-types alien.strings file.xattr.ffi kernel libc
locals unix.utilities xattr.ffi io.encodings.utf8 ;
IN: file.xattr.lib

CONSTANT: TEST "/Users/davec/test"
CONSTANT: TESTKEY1 "net.polymicro.checksum.fnv1-32"
CONSTANT: TESTKEY2 "net.polymicro.sha"

! ssize_t getxattr ( c-string path, c-string  name, void* value, size_t size, u_int32_t position, int optionals )
:: getxattr ( path key -- size )
    f :> value!
    path key f 0 0 0 (getxattr) :> size!
    size [
        path key
        size malloc :> xvalue
        xvalue size  0 0 (getxattr) drop
        xvalue utf8 alien>string value!
        xvalue free
    ] when
    value ;
    
! ssize_t fgetxattr ( int fd, c-string name, void *value, size_t size, u_int32_t position, int options ) 
:: fgetxattr ( fd key -- size )
    f :> value!
    fd key f 0 0 0 (fgetxattr) :> size!
    size [
        size malloc :> xvalue
        fd key xvalue size 0 0 (fgetxattr) drop
        xvalue utf8 alien>string value!
        xvalue free
    ] when
    value ;
    


! int setxattr ( c-string path, c-string name, void *value, size_t size, u_int32_t position, int options ) 
! int fsetxattr ( int fd, c-string name, void *value, size_t size, u_int32_t position, int options ) 
! int removexattr ( c-string path, c-string name, int options ) 
! int fremovexattr ( int fd, c-string name, int options ) 
! ssize_t listxattr  (  c-string path, c-string namebuff, size_t size, int options  )
: listxattr ( path -- xattrs )
    dup f 0 0 (listxattr)
    [ malloc ] keep
    [ swap over ] dip 
    0 (listxattr) drop
    ;

    
! ssize_t flistxattr ( int fd, c-string namebuff, size_t size, int options ) 

