
WANTED=git,rsync,tig,vim,calcurse,coreutils,diffutils,findutils,curl,wget,grep,man,patch,taskwarrior,libuuid,lynx,openssl

BERRYMUCH_PACKAGES := ~/berrymuch/packages
PKG_LIST := $(shell ls $(BERRYMUCH_PACKAGES)/{$(WANTED)}*)

default: $(foreach pkg,$(PKG_LIST),$(pkg).zip.extract)

	# add berrymuch parts
	rsync -avr bin/ .
	rsync -avr libexec/ ../libexec

	# cleanup source dir
	rm -rf bin libexec

# warning: if files are removed inside zip ...
%.zip.extract:
	unzip -uo $* > /dev/null
