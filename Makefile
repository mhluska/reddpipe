SHELL=/bin/bash
BASE=$(shell cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATE=$(shell date +%I:%M%p)
NAME=pipeline
SILENT=>/dev/null
NPM_SILENT=--loglevel silent ${SILENT}
CHECK='\033[32m%s\033[39m %s\n' '✔' 'Done'

LIB=source/lib
ASSETS=server/public
MODULES=modules
ZEPTO=${MODULES}/zepto
ZEPTO_DIST=${ZEPTO}/dist
SKELETON_DIST=${MODULES}/skeleton/stylesheets

all: submodules symlink compile
	@install -m 764 pre-commit .git/hooks
	@echo
	@echo "${NAME} successfully built at ${DATE}."
	@echo "Thanks for building! @mhluska."
	@echo

submodules:
	@printf '%s' 'Updating submodules...         '
	@git submodule update --quiet --init --recursive
	@printf ${CHECK}
	@printf '%s' 'Building submodule Zepto...    '
	@cd ${ZEPTO} && npm install ${NPM_SILENT}
	@cd ${ZEPTO} && npm run-script dist ${NPM_SILENT}
	@printf ${CHECK}

symlink:
	@printf '%s' 'Setting up symlinks...         '
	@ln -fs ${BASE}/${ZEPTO_DIST}/zepto.js ${LIB}
	@ln -fs ${BASE}/${MODULES}/underscore/underscore.js ${LIB}/underscore-lib.js
	@ln -fs ${BASE}/${MODULES}/backbone/backbone.js ${LIB}
	@ln -fs ${BASE}/${MODULES}/text/text.js ${LIB}
	@ln -fs ${BASE}/${LIB}/text.js source/js
	@ln -fs ${BASE}/${MODULES}/skeleton/stylesheets/skeleton.css ${ASSETS}
	@printf ${CHECK}

compile:
	@grunt requirejs ${SILENT}
