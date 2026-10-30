;;; b:vscode:claude.el --- Blee and VS Code Claude: the vscodeClaude layer  -*- lexical-binding: t; -*-

(orgCmntBegin "
* Summary: Blee to a local VS Code Claude session (prompts in, results back) --- thin over vscodeClaude.cs.
" orgCmntEnd)

;;;#+BEGIN: b:elisp:file/copyLeftPlus :outLevel 1
(orgCmntBegin "
* *[[elisp:(org-cycle)][| Proclamations |]]* :: Libre-Halaal Software --- Part Of Blee ---  Poly-COMEEGA Format.
** This is Libre-Halaal Software. © Libre-Halaal Foundation. Subject to AGPL.
** It is not part of Emacs. It is part of Blee.
** Best read and edited  with Poly-COMEEGA (Polymode Colaborative Org-Mode Enhance Emacs Generalized Authorship)
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN: b:elisp:file/authors :authors ("./inserts/authors-mb.org")
(orgCmntBegin "
** Authors: Mohsen BANAN, http://mohsen.banan.1.byname.net/contact
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN: b:elisp:file/orgTopControls :outLevel 1
(orgCmntBegin "
*  [[elisp:(org-cycle)][|/Controls/| ]] :: [[elisp:(org-show-subtree)][|=]]  [[elisp:(show-all)][Show-All]]  [[elisp:(org-shifttab)][Overview]]  [[elisp:(progn (org-shifttab) (org-content))][Content]] | [[file:Panel.org][Panel]] | [[elisp:(blee:ppmm:org-mode-toggle)][Nat]] | [[elisp:(bx:org:run-me)][Run]] | [[elisp:(bx:org:run-me-eml)][RunEml]] | [[elisp:(delete-other-windows)][(1)]] | [[elisp:(progn (save-buffer) (kill-buffer))][S&Q]]  [[elisp:(save-buffer)][Save]]  [[elisp:(kill-buffer)][Quit]] [[elisp:(org-cycle)][| ]]
** /Version Control/ ::  [[elisp:(call-interactively (quote cvs-update))][cvs-update]]  [[elisp:(vc-update)][vc-update]] | [[elisp:(bx:org:agenda:this-file-otherWin)][Agenda-List]]  [[elisp:(bx:org:todo:this-file-otherWin)][ToDo-List]]
" orgCmntEnd)
;;;#+END:

(orgCmntBegin "
* Commentary, Model and Terminology:
The vscodeClaude layer, on top of b:vscode.el. Three channels (see the design):
1. Prompt in: b:vscode:claude/atPrompt puts a prompt (normally a /bx- command) in the input box
   of a local VS Code Claude session; the user presses Enter.
2. Results back by file: e.g. /bx-git-commit-msg writes .git/CLAUDE_COMMIT_MSG, which
   b:vscode:claude:magit:commitMsg/offer offers in the magit commit buffer.
3. Results back by call: Claude runs emacsclient (skill bs-blee-emacs-server).
All the logic is in Python (bisos.aiActivity); elisp stays thin.
Moved here from bcpg:claudePlus.el (bap:claudeSessions/prompt) and bcpg:magitPlus.el
(bap:magit:claudeCommitMsg/*, bap:magit:claudeDispatch) --- WorkPlan 2.4.
* Relevant Panels:
** [[file:./Emacs+VS-Code+Claude.org]] --- the design.
* Planned Improvements:
** TODO Stage 6: b:vscode:claude/thisEmacsServer.
" orgCmntEnd)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 0 :title "REQUIRES" :extraInfo "Imports"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*     [[elisp:(outline-show-subtree+toggle)][| _REQUIRES_: |]]  Imports  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(require 'blee-libs)
(require 'b:vscode)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Variables And Constants" :extraInfo "defvar, defcustom"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Variables And Constants:* |]]  defvar, defcustom  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(defvar b:vscode:claude:program "vscodeClaude.cs"
  "The CLI (bisos.aiActivity) that finds the local VS Code Claude sessions and prompts them.")

(defvar b:vscode:claude:outBuffer "*vscodeClaude*"
  "Buffer holding the last b:vscode:claude:program run's output (the commands it ran are on its stderr).")

(defvar b:vscode:claude:magit:commitMsg:pending nil
  "Path of the CLAUDE_COMMIT_MSG inserted into the commit buffer being edited, or nil.")

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Prompt In" :extraInfo "A prompt into a local VS Code Claude session"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Prompt In:* |]]  A prompt into a local VS Code Claude session  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/atPrompt" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/atPrompt>>  --  -- Put <text in the input box of a local VS Code Claude session.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/atPrompt (
;;;#+END:
                                    <text &optional <session)
   " #+begin_org
** DocStr: Put <text in the input box of a local VS Code Claude session; the user presses Enter.
<session is a sessionId, \"new\" (a new conversation), or nil: the latest local session.
A thin layer over =vscodeClaude.cs -i claudePrompt=, which holds all the logic: a
running session is brought to the front and the text pasted (xclip, xdotool). DISPLAY is Emacs's.
#+end_org "
  (interactive "sClaude prompt: ")
  (let* ((default-directory (expand-file-name "~/"))   ; a local process, also from a TRAMP buffer
         ($args (append (when <session (list (concat "--session=" <session)))
                        (list "-i" "claudePrompt" <text)))
         $status)
    (with-current-buffer (get-buffer-create b:vscode:claude:outBuffer)
      (erase-buffer))
    (setq $status (apply #'call-process b:vscode:claude:program nil b:vscode:claude:outBuffer nil $args))
    ;; A refused PyCS Cmnd still exits 0: its usage error is in the output.
    (if (and (eql $status 0)
             (not (with-current-buffer b:vscode:claude:outBuffer
                    (save-excursion (goto-char (point-min)) (search-forward "EH_Problem" nil t)))))
        (message "Claude prompt sent: %s" <text)
      (display-buffer b:vscode:claude:outBuffer)
      (user-error "%s failed (see %s)" b:vscode:claude:program b:vscode:claude:outBuffer))))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Magit: Claude's Commit Message" :extraInfo "x c asks Claude; c c offers .git/CLAUDE_COMMIT_MSG"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Magit: Claude's Commit Message:* |]]  x c asks Claude; c c offers .git/CLAUDE_COMMIT_MSG  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/commitMsgGenerate" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/commitMsgGenerate>>  --  -- Send /bx-git-commit-msg <repo> to the latest local VS Code Claude session.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/commitMsgGenerate (
;;;#+END:
                                                        )
   " #+begin_org
** DocStr: Send /bx-git-commit-msg <repo> to the latest local VS Code Claude session (x c).
Run once staging is done. Then: Enter in Claude, wait for its message, c c in magit, and
b:vscode:claude:magit:commitMsg/offer offers it. The repo is given as a path, so the session need
not be working in it.
#+end_org "
  (interactive)
  (let (($repo (magit-toplevel)))
    (unless $repo
      (user-error "Not in a git repository"))
    (unless (magit-anything-staged-p)
      (user-error "Nothing staged in %s" $repo))
    (b:vscode:claude/atPrompt (format "/bx-git-commit-msg %s" (directory-file-name $repo)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:magit:commitMsg/offer" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:magit:commitMsg/offer>>  --  -- In git-commit-setup-hook: offer <gitdir>/CLAUDE_COMMIT_MSG when the message is empty.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:magit:commitMsg/offer (
;;;#+END:
                                                 )
   " #+begin_org
** DocStr: In git-commit-setup-hook: offer <gitdir>/CLAUDE_COMMIT_MSG when the message is empty.
Skipped when the buffer already has a message (amend, git commit -t, a reword).
#+end_org "
  (setq b:vscode:claude:magit:commitMsg:pending nil)
  (let* (($gitDir (and buffer-file-name (file-name-directory buffer-file-name)))
         ($msgFile (and $gitDir (expand-file-name "CLAUDE_COMMIT_MSG" $gitDir))))
    (when (and $msgFile
               (file-readable-p $msgFile)
               (not (git-commit-buffer-message))
               (y-or-n-p "Use Claude's commit message (.git/CLAUDE_COMMIT_MSG)? "))
      (goto-char (point-min))
      (insert-file-contents $msgFile)
      (goto-char (point-min))
      ;; git-commit-setup marks the buffer unmodified after this hook, and with-editor does
      ;; not save an unmodified buffer: git would then read its own empty COMMIT_EDITMSG.
      (add-hook 'with-editor-pre-finish-hook (lambda () (set-buffer-modified-p t)) nil t)
      (setq b:vscode:claude:magit:commitMsg:pending $msgFile))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:magit:commitMsg/markUsed" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:magit:commitMsg/markUsed>>  --  -- In git-commit-post-finish-hook: rename the used message to CLAUDE_COMMIT_MSG.used,  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:magit:commitMsg/markUsed (
;;;#+END:
                                                    )
   " #+begin_org
** DocStr: In git-commit-post-finish-hook: rename the used message to CLAUDE_COMMIT_MSG.used,
so it is not offered again. Not run when the commit is aborted: the file then stays.
#+end_org "
  (when (and b:vscode:claude:magit:commitMsg:pending
             (file-exists-p b:vscode:claude:magit:commitMsg:pending))
    (rename-file b:vscode:claude:magit:commitMsg:pending
                 (concat b:vscode:claude:magit:commitMsg:pending ".used") t))
  (setq b:vscode:claude:magit:commitMsg:pending nil))

(with-eval-after-load 'magit
  (transient-define-prefix b:vscode:claude:magit/dispatch ()
    "Claude, in the local VS Code (vscodeClaude.cs)."
    ["Claude (latest local VS Code session)"
     ("c" "Commit message for the staged changes (/bx-git-commit-msg)"
      b:vscode:claude:aiActivity/commitMsgGenerate)]))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:magit|config" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:magit|config>>  --  -- Hook Claude's commit message into magit: the commit hooks and x c.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:magit|config (
;;;#+END:
                                        )
   " #+begin_org
** DocStr: Hook Claude's commit message into magit: the commit hooks and x c.
Run after magit is loaded (b:npa:vscode-claude:config|main does so).
#+end_org "
  ;;; Offer Claude's .git/CLAUDE_COMMIT_MSG (written by /bx-git-commit-msg) in an empty commit buffer.
  (add-hook 'git-commit-setup-hook #'b:vscode:claude:magit:commitMsg/offer t)
  (add-hook 'git-commit-post-finish-hook #'b:vscode:claude:magit:commitMsg/markUsed)
  ;;; x c: ask the latest local VS Code Claude session for that message. x was magit-reset-quickly,
  ;;; which stays reachable as X (magit-reset). Also in magit-dispatch, next to X.
  (define-key magit-mode-map (kbd "x") #'b:vscode:claude:magit/dispatch)
  (condition-case nil
      (transient-append-suffix 'magit-dispatch "X" '("x" "Claude" b:vscode:claude:magit/dispatch))
    (error (message "b:vscode:claude: magit-dispatch has no X: Claude (x) not added"))))

;;;#+BEGIN: b:elisp:file/provide :modName nil
(provide 'b:vscode:claude)
;;;#+END:

;;;#+BEGIN: b:elisp:file/endOf :outLevel 1
(orgCmntBegin "
* [[elisp:(show-all)][(>]] ~END-OF-FILE~  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;; local variables:
;;; no-byte-compile: t
;;; end:
;;;#+END:
