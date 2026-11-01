;;;-*- mode: Emacs-Lisp; lexical-binding: t ; -*-
;;;
;;; b:vscode:claude:menu.el --- Menu of the vscode-claude Blee package.
;;;

(require 'easymenu)
(require 'b:vscode:claude)
(require 'b:vscode:claude:aiActivity)

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
	,(s-- 5)
	,(s-- 6)
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

    ;;; (s-- 5) — Session
    (easy-menu-add-item
     b:vscode:claude:menu nil
     (b:vscode:claude:menuItem:session|define)
     (s-- 5))

    ;;; (s-- 6) — VS Code
    (easy-menu-add-item
     b:vscode:claude:menu nil
     (b:vscode:claude:menuItem:vscode|define)
     (s-- 6))

    'b:vscode:claude:menu
    ))

;;; Prompt In

(defun b:vscode:claude:menuItem:atPrompt|define ()
  (list "Prompt"
        ["Prompt This Buffer's Session  -- b:vscode:claude/atPrompt"
         (call-interactively 'b:vscode:claude/atPrompt)
         :help "Put a prompt in the input box of this buffer's VS Code Claude session"]
        ["Prompt With @file:line  -- b:vscode:claude/sendWithContext"
         (call-interactively 'b:vscode:claude/sendWithContext)]
        ["Send Region  -- b:vscode:claude/sendRegion"
         (call-interactively 'b:vscode:claude/sendRegion) :active (use-region-p)]
        ["Send This File  -- b:vscode:claude/sendBufferFile"
         (call-interactively 'b:vscode:claude/sendBufferFile)]
        ["Fix Error At Point  -- b:vscode:claude/fixErrorAtPoint"
         (call-interactively 'b:vscode:claude/fixErrorAtPoint)]
        ["Submit Prompts (Press Enter)  -- b:vscode:claude/submitToggle"
         (b:vscode:claude/submitToggle)
         :style toggle :selected b:vscode:claude:submit?]
        ["VS Code Claude Transient  -- b:vscode:claude/dispatch"
         (b:vscode:claude/dispatch)]
        ["AI-Activity (/bx-) Transient  -- b:vscode:claude:aiActivity/dispatch"
         (b:vscode:claude:aiActivity/dispatch)]))

;;; Magit

(defun b:vscode:claude:menuItem:magit|define ()
  (list "Magit"
        ["Commit Message for Staged Changes  -- b:vscode:claude:aiActivity/commitMsgGenerate"
         (b:vscode:claude:aiActivity/commitMsgGenerate)
         :help "Send /bx-git-commit-msg <repo> to this repo's VS Code Claude session (magit x c)"]
        ["Commit Message, Submitted  -- b:vscode:claude:aiActivity/commitMsgGenerateSubmit"
         (b:vscode:claude:aiActivity/commitMsgGenerateSubmit)
         :help "As above, and press Enter in VS Code (magit x x)"]
        ["Commit Walk: Start  -- b:vscode:claude:aiActivity:magit/walkStart"
         (b:vscode:claude:aiActivity:magit/walkStart)
         :help "Ask Claude for this session's uncommitted repos and open them here in turn"]
        ["Commit Walk: Next Repo  -- b:vscode:claude:aiActivity:magit/walkNext"
         (b:vscode:claude:aiActivity:magit/walkNext)
         :active b:vscode:claude:aiActivity:walk:repos]
        ))

;;; Session

(defun b:vscode:claude:menuItem:session|define ()
  (list "Session"
        ["Choose Session  -- b:vscode:claude/sessionSelect"
         (call-interactively 'b:vscode:claude/sessionSelect)
         :help "Which running session this buffer's base dir prompts (C-u: this buffer only)"]
        ["Forget The Choice  -- b:vscode:claude/sessionForget"
         (call-interactively 'b:vscode:claude/sessionForget)]
        "---"
        ["Confirm Root (Register)  -- b:vscode:claude:aiActivity/confirmRoot"
         (call-interactively 'b:vscode:claude:aiActivity/confirmRoot)
         :help "/bx-confirm-root dir= emacs= register= to the session covering this buffer"]
        ["Confirm Here  -- b:vscode:claude:aiActivity/confirmHere"
         (call-interactively 'b:vscode:claude:aiActivity/confirmHere)
         :help "/bx-confirm-here <this activity dir> to its session"]
        ["Show Associations  -- b:vscode:claude/associationsShow"
         (b:vscode:claude/associationsShow)]))

;;; VS Code

(defun b:vscode:claude:menuItem:vscode|define ()
  (list "VS Code"
        ["Open This File In VS Code  -- b:vscode/fileOpen"
         (b:vscode/fileOpen)]
        ["This Emacs Is The Partner  -- b:vscode/init"
         (b:vscode/init)
         :help "Write the partner file: VS Code to Emacs and Claude Code hooks reach this Emacs"]
        ["Show The Partner  -- b:vscode/partnerShow"
         (b:vscode/partnerShow)]
        ["Topology  -- b:vscode/topology"
         (b:vscode/topology)]))

(provide 'b:vscode:claude:menu)
;;; b:vscode:claude:menu.el ends here
