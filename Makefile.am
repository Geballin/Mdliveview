bin_SCRIPTS = mdliveview
mdliveview:
	echo "#! /bin/sh" >$@
	echo 'tclsh `dirname $$0`/../share/mdliveview/mdliveview.tcl' >>$@
	chmod ugo+x $@
CLEANFILES = mdliveview

SUBDIRS = src
