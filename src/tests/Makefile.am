AM_CFLAGS= $(CC_OPT) $(DB_CFLAGS) $(PURPOSE_CFLAGS)
AM_LDFLAGS= -lpthread

# See autotools/m4/ax_valgrind_check.m4 for documentation
@VALGRIND_CHECK_RULES@
#VALGRIND_SUPPRESSIONS_FILES = my-project.supp
#EXTRA_DIST = my-project.supp

# test_confparam cannot build success on 5.10.0-202.0.0.115.oe2203sp3.aarch64, so disable it
check_PROGRAMS=test_uidgidcache test_params test_parse
    #test_confparam
if LUSTRE
check_PROGRAMS+=create_nostripe test_forcestripe
endif
TESTS=test_parsing.sh test_uidgidcache test_params # test_confparam

noinst_PROGRAMS=$(check_PROGRAMS)

test_forcestripe_LDADD=$(DB_LDFLAGS) $(PURPOSE_LDFLAGS) $(FS_LDFLAGS)

test_uidgidcache_SOURCES=test_uidgidcache.c
test_uidgidcache_LDADD=../common/libcommontools.la
test_params_SOURCES=test_params.c
test_params_LDADD=../common/libcommontools.la
# test_confparam_SOURCES=test_confparam.c
# test_confparam_LDFLAGS=$(DB_LDFLAGS) $(PURPOSE_LDFLAGS) $(FS_LDFLAGS)
# test_confparam_LDADD=../policies/libpolicies.la ../common/libcommontools.la
test_parse_SOURCES	    = test_parse.c
test_parse_LDADD         =  ../cfg_parsing/libconfigparsing.la


indent:
	$(top_srcdir)/scripts/indent.sh
