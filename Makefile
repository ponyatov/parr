CWD     = $(CURDIR)
MODULE  = $(shell echo $(notdir $(CWD)) | tr "[:upper:]" "[:lower:]" )
OS     ?= $(shell uname -s)

NOW = $(shell date +%d%m%y)
REL = $(shell git rev-parse --short=4 HEAD)

PIP = $(CWD)/bin/pip3
PY  = $(CWD)/bin/python3

ANTLR_VER = 4.8
ANTLR     = bin/antlr-$(ANTLR_VER)-complete.jar

JAVA  = $(shell which java)
JAVAC = $(shell which javac)

IP	 ?= 127.0.0.1
PORT ?= 19999

WGET = wget -c --no-check-certificate



all: $(PY) $(MODULE).py $(MODULE).ini
	$^

# https://github.com/antlr/antlr4/blob/master/doc/python-target.md
grammar.py: grammar.g4
	antlr4 -Dlanguage=Python3 $<



about:
	@ echo $(JAVA)  ; $(JAVA)  -version
	@ echo $(JAVAC) ; $(JAVAC) -version



.PHONY: install update gz

install: $(OS)_install $(PIP) gz
	$(PIP) install    -r requirements.txt
	$(MAKE) requirements.txt

update: $(OS)_update $(PIP)
	$(PIP) install -U    pip
	$(PIP) install -U -r requirements.txt
	$(MAKE) requirements.txt

gz: $(ANTLR)
$(ANTLR):
	$(WGET) -O $@ https://www.antlr.org/download/antlr-4.8-complete.jar

$(PIP) $(PY):
	python3 -m venv .
	$(PIP) install -U pip pylint autopep8
	$(MAKE) requirements.txt

.PHONY: requirements.txt
requirements.txt: $(PIP)
	$< freeze | grep -v 0.0.0 > $@

.PHONY: Linux_install Linux_update

Linux_install Linux_update:
	sudo apt update
	sudo apt install -u `cat apt.txt`



.PHONY: master shadow release

MERGE  = Makefile README.md .gitignore .vscode apt.txt requirements.txt
MERGE += $(MODULE).py $(MODULE).ini
MERGE += doc/.gitignore bin/.gitignore

master:
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)

shadow:
	git checkout $@
	git pull -v

release:
	git tag $(NOW)-$(REL)
	git push -v && git push -v --tags
	$(MAKE) shadow
