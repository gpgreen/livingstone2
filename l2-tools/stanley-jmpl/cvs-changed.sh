#! /bin/sh

# from Benoit Hudson

# mba/cpp>  cvs-changed
# [list of files, spit to the screen and to the file "changed"]
# mba/cpp>  emacs ChangeLog
# mba/cpp>  cvs ci ChangeLog `cat changed`

# Note: if you create a new file or deleted an old one, that doesn't show up
# in 'changed'

# Also: sometimes, it wonks out (all recursive cvs commands do).  Just try
# again.


if test "x$1" = "x-" ; then
    shift
    TMPFILE=/tmp/cvs-changed.$$
    trap 'rm -f $TMPFILE' 0 
else
    TMPFILE=changed
fi

# Run cvs, store the results in a file, then print the file.
# Otherwise, we risk interleaving some of the results with the stderr
# output.
cvs diff "$@" | \
        egrep -e '^Index:' | \
        sed -e 's/^Index: *//' | \
        grep -v "src/livingstone/version.c" > $TMPFILE

exec cat $TMPFILE
