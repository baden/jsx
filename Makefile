PROJECT = jsx

# Or use manual:
# ERLC_OPTS ?= -Dmaps_support
ERLC_OPTS ?= `./config.script`

include erlang.mk
