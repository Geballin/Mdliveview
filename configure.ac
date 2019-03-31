AC_INIT(mdliveview, 1.0)
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([src/mdliveview.tcl])

AC_CHECK_PROGS(TCL_TK_CHECK, wish,no)
AS_IF([test x"TCL_TK_CHECK" == x"no"], [AC_MSG_ERROR([Please install TCL and TK before configuring.])])

AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT
