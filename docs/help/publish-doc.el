;; Copyright © 2025 Charles Choi
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(require 'org)
(require 'htmlize)
(require 'ox-html)
(require 'ox-publish)

(setq org-publish-project-alist
      `(("pages"
         :base-directory "."
         :base-extension "org"
         :recursive t
         :publishing-directory "../../Scrim.help/Contents/Resources/en.lproj"
         :publishing-function org-html-publish-to-html)

        ("static"
         :base-directory "."
         :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|svg\\|helpindex\\|cshelpindex"
         :recursive t
         :publishing-directory "../../Scrim.help/Contents/Resources/en.lproj"
         :publishing-function org-publish-attachment)

        ("scrim-help-book"
         :components ("pages" "static"))))
