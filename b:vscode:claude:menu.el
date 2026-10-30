;;;-*- mode: Emacs-Lisp; lexical-binding: t ; -*-
;;;
;;; b:vscode:claude:menu.el --- Menu of the vscode-claude Blee package.
;;;

(require 'easymenu)
(require 'b:vscode:claude)

;; (b:vscode:claude:menu:plugin|install modes:menu:global (s-- 6))
(defun b:vscode:claude:menu:plugin|install (<menuLabel <menuDelimiter)
  "Adds this as a submenu to menu labeled <menuLabel at specified delimited <menuDelimiter."

  (easy-menu-add-item
   <menuLabel
   nil
   (b:vscode:claude:menu|define :active t)
   <menuDelimiter
   )

  (add-hook 'menu-bar-update-hook 'b:vscode:claude:menu|update-hook)
  )

(defun b:vscode:claude:menu|update-hook ()
  "This is to be added to menu-bar-update-hook.
It runs everytime any menu is invoked.
As such what happens below should be exactly what is necessary and no more."
  )

;;
;; (b:vscode:claude:menu|define :active nil)
;; (popup-menu (symbol-value (b:vscode:claude:menu|define)))
;;
(defun b:vscode:claude:menu|define (&rest <namedArgs)
  "Returns b:vscode:claude:menu.
:active can be specified as <namedArgs.
"
  (let (
	(<active (get-arg <namedArgs :active t))
	)

    (easy-menu-define
      b:vscode:claude:menu
      nil
      (format "VS Code Claude Menu")
      `(
	,(format "VS Code Claude Menu")
	:help "Blee to a local VS Code Claude session"
	:active ,<active
	:visible t
	,(s-- 3)
	,(s-- 4)
	))

    ;;; (s-- 3) — Prompt In
    (easy-menu-add-item
     b:vscode:claude:menu nil
     (b:vscode:claude:menuItem:atPrompt|define)
     (s-- 3))

    ;;; (s-- 4) — Magit
    (easy-menu-add-item
     b:vscode:claude:menu nil
     (b:vscode:claude:menuItem:magit|define)
     (s-- 4))

    'b:vscode:claude:menu
    ))

;;; Prompt In

(defun b:vscode:claude:menuItem:atPrompt|define ()
  (car `(
         [,(format "Prompt the Latest Session  -- b:vscode:claude/atPrompt")
          (call-interactively 'b:vscode:claude/atPrompt)
          :help "Put a prompt in the input box of the latest local VS Code Claude session"
          ]
         )))

;;; Magit

(defun b:vscode:claude:menuItem:magit|define ()
  (list "Magit"
        ["Commit Message for Staged Changes  -- b:vscode:claude:aiActivity/commitMsgGenerate"
         (b:vscode:claude:aiActivity/commitMsgGenerate)
         :help "Send /bx-git-commit-msg <repo> to the latest local VS Code Claude session (magit x c)"]
        ))

(provide 'b:vscode:claude:menu)
;;; b:vscode:claude:menu.el ends here
