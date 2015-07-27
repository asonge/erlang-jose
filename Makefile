PROJECT = jose
DEPS = base64url crypto_rsassa_pss jsx
dep_base64url = git git://github.com/dvv/base64url.git master
dep_crypto_rsassa_pss = git git://github.com/potatosalad/erlang-crypto_rsassa_pss.git master
dep_jsx = git git://github.com/talentdeficit/jsx.git master
# TEST_ERLC_OPTS += +'{parse_transform, eunit_autoexport}'
# TEST_DEPS = cutkey triq
# dep_cutkey = git git://github.com/potatosalad/cutkey.git master
# dep_triq = git git://github.com/krestenkrab/triq.git master
include erlang.mk