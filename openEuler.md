I - openEuler build
===========
openEuler 22.03 build notice

# lsb_release -a
LSB Version:    n/a
Distributor ID: openEuler
Description:    openEuler release 22.03 (LTS-SP3)
Release:        22.03
Codename:       LTS-SP3

# rpm -q glib2-devel
glib2-devel-2.72.2-15.oe2203sp3.aarch64

make will get error of:

......

                 from rbh_modules.c:25:
/usr/include/glib-2.0/glib/gmacros.h:644:28: error: missing binary operator before token "("
  644 | #if g_macro__has_attribute(fallthrough)

it caused by glib2 upgrade

open file:

/usr/include/glib-2.0/glib/gmacros.h

in G_GNUC_FALLTHROUGH define part

change:

#if g_macro__has_attribute(fallthrough)
#define G_GNUC_FALLTHROUGH __attribute__((fallthrough)) \
  GLIB_AVAILABLE_MACRO_IN_2_60
#else
#define G_GNUC_FALLTHROUGH \
  GLIB_AVAILABLE_MACRO_IN_2_60
#endif

to:

#if    __GNUC__ > 6
#define G_GNUC_FALLTHROUGH __attribute__((fallthrough))
#else
#define G_GNUC_FALLTHROUGH
#endif /* __GNUC__ */



