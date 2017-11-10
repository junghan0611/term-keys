;;; term-keys-konsole.el --- term-keys support for Konsole

;;; Commentary:

;; This file contains supplementary code for aiding in the
;; configuration of the Konsole terminal emulator to interoperate with
;; the term-keys package.

;; For more information, please see the accompanying README.md file.

;;; Code:


(require 'term-keys)


(define-widget 'term-keys/konsole-modifier 'lazy
  "Choice for Konsole key binding modifiers and state flags."
  :type '(choice (const "Shift")
		 (const "Ctrl")
		 (const "Alt")
		 (const "Meta")
		 (const "KeyPad")
		 (const "AppScreen")
		 (const "AppCursorKeys")
		 (const "NewLine")
		 (const "Ansi")
		 (const "AnyModifier")
		 (const "AppKeypad")
		 (const :tag "(none)" nil)))


(defcustom term-keys/konsole-modifier-map ["Shift" "Ctrl" "Alt" "Meta" nil nil]
  "Modifier keys for Konsole key bindings.

This should be a vector of 6 elements, with each element being a
string indicating the name of the Konsole modifier or state flag
corresponding to the Emacs modifiers Shift, Control, Meta, Super,
Hyper and Alt respectively, as they should appear in generated
Konsole .keytab files.  nil indicates that there is no mapping
for this modifier."
  :type '(vector
	  (term-keys/konsole-modifier :tag "Shift")
	  (term-keys/konsole-modifier :tag "Control")
	  (term-keys/konsole-modifier :tag "Meta")
	  (term-keys/konsole-modifier :tag "Super")
	  (term-keys/konsole-modifier :tag "Hyper")
	  (term-keys/konsole-modifier :tag "Alt"))
  :group 'term-keys)


(defun term-keys/konsole-keytab ()
  "Construct Konsole key binding configuration as .keytab file syntax.

This function returns, as a string, a Konsole keytab which can be
used to configure Konsole to encode term-keys key sequences,
according to the term-keys configuration.

The returned string is suitable to be pasted as-is to the end of
an existing Konsole .keytab file."
  (apply #'concat
	 (term-keys/iterate-keys
	  (lambda (index keymap mods)

	    ;; Skip key combinations with unrepresentable modifiers
	    (unless (cl-reduce (lambda (x y) (or x y)) ; any
			       (mapcar (lambda (n) ; active modifier mapped to nil
					 (and (elt mods n)
					      (not (elt term-keys/konsole-modifier-map n))))
				       (number-sequence 0 (1- (length mods))))) ; 0..5
	      (format "key %s%s : \"%s\"\n"
		      (elt keymap 3) ; key name
		      (mapconcat
		       (lambda (n)
			 (if (elt term-keys/konsole-modifier-map n)
			     (concat
			      (if (elt mods n) "+" "-")
			      (elt term-keys/konsole-modifier-map n))
			   ""))
		       (number-sequence 0 (1- (length mods)))
		       "")
		      (mapconcat  ; hex-escaped sequence
		       (lambda (x) (format "\\x%02X" x))
		       (append
			term-keys/prefix
			(term-keys/encode-key index mods)
			term-keys/suffix
			nil)
		       "")))))))


(provide 'term-keys-konsole)
;;; term-keys-konsole.el ends here
