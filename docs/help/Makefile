##
# Copyright © 2025 Charles Choi
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

EMACS_ELPA_DIR=$(HOME)/.config/emacs/elpa
EMACS=$(EMACS_APP_EXEC)
PACKAGE_PATHS=-L $(EMACS_ELPA_DIR)/htmlize-current

TARGET_DIR=../../Scrim.help/Contents/Resources/en.lproj

$(TARGET_DIR):
	mkdir -p $@

.PHONY: create-helpbook
create-helpbook: clean-helpbook build-helpbook indexes

.PHONY: indexes
indexes: $(TARGET_DIR)
	cd $(TARGET_DIR);hiutil -I lsm -Caf Scrim.helpindex -vv .
	cd $(TARGET_DIR);hiutil -I corespotlight -Caf Scrim.cshelpindex -vv .

.PHONY: build-helpbook
build-helpbook:
	$(EMACS) -batch $(PACKAGE_PATHS) -l publish-doc.el --eval '(org-publish "scrim-help-book" t)'

.PHONY: open-helpbook
open-helpbook: $(TARGET_DIR)
	open $(TARGET_DIR)/ScrimUserGuide.html

.PHONY: open-using-scrim
open-using-scrim: $(TARGET_DIR)
	open $(TARGET_DIR)/UsingScrim.html

.PHONY: clean-helpbook
clean-helpbook: $(TARGET_DIR)
	/bin/rm -rf $(TARGET_DIR)/*

.PHONY: entr
entr:
	find . -name '*.org' | entr $(MAKE) create-helpbook

.PHONY: devserver
devserver:
	cd $(TARGET_DIR); python -m http.server

.PHONY: user-guide
dev-user-guide:
	open "http://localhost:8000/ScrimUserGuide.html"
