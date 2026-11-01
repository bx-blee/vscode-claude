;;; b:vscode:claude:aiActivity.el --- Blee, VS Code Claude and AI-Activity (layer 5)  -*- lexical-binding: t; -*-

(orgCmntBegin "
* Summary: Layer 5, Emacs <-> VS Code Claude + AI-Activity: root and here, the commit cycle, /bx- menus.
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
Layer 5 of the five (README.org, WorkPlan Stage 13): what Blee does with VS Code Claude because the
work is an AI-Activity. Built on layer 4 (b:vscode:claude.el), which knows nothing of AI-Activity.
- The base dir of a buffer is its AI-Activity dir (the nearest CLAUDE.md above): this file sets
  layer 4's b:vscode:claude:baseDir-function.
- Root and here: confirmRoot sends /bx-confirm-root dir= emacs= register=<this file's rootRegister>,
  so the layer-1 command names no Blee function; confirmHere sends /bx-confirm-here <dir>. Both fill
  layer 4's associations.
- The commit cycle: x c / x x send /bx-git-commit-msg; the commit buffer offers CLAUDE_COMMIT_MSG; on
  Claude's Stop (layer 4's hook) magit is raised for a requested repo.
- The commit walk: /bx-git-commit-walk walk=<this file's walk> hands Blee the repos; x n moves on.
- Menus: a transient of /bx- commands, added to layer 4's as \"a\"; magit's x.
- Org links: [[aiActivity:status-read]] sends /bx-status-read (C-u flips submit); the
  b:ai:workflow/driver dblock (dblock-vscode-claude.el) is a panel of them.
* Relevant Panels:
** [[file:./README.org]] --- the design and documentation.
" orgCmntEnd)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 0 :title "REQUIRES" :extraInfo "Imports"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*     [[elisp:(outline-show-subtree+toggle)][| _REQUIRES_: |]]  Imports  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(require 'blee-libs)
(require 'b:vscode:claude)
(require 'seq)
(require 'subr-x)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Variables And Constants" :extraInfo "defvar, defcustom"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Variables And Constants:* |]]  defvar, defcustom  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(defvar b:vscode:claude:aiActivity:commitMsg:requests nil
  "Alist of (repo . time) of /bx-git-commit-msg requests not yet seen fulfilled (by the Stop hook).")

(defvar b:vscode:claude:aiActivity:magit:commitMsg:pending nil
  "Path of the CLAUDE_COMMIT_MSG inserted into the commit buffer being edited, or nil.")

(defvar b:vscode:claude:aiActivity:walk:repos nil
  "The repos of the commit walk, in order (b:vscode:claude:aiActivity:magit/walk).")

(defvar b:vscode:claude:aiActivity:walk:index 0
  "Index in b:vscode:claude:aiActivity:walk:repos of the repo open now.")

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "The AI-Activity Dir" :extraInfo "Layer 4's base dir, for an AI-Activity"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *The AI-Activity Dir:* |]]  Layer 4's base dir, for an AI-Activity  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/activityDir" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/activityDir>>  --  -- This buffer's AI-Activity dir: the nearest CLAUDE.md above, else layer 4's default.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/activityDir (
;;;#+END:
                  )
   " #+begin_org
** DocStr: This buffer's AI-Activity dir: the nearest CLAUDE.md above, else layer 4's default.
#+end_org "
  (or (locate-dominating-file default-directory "CLAUDE.md")
      (b:vscode:claude:baseDir/default)))

(setq b:vscode:claude:baseDir-function #'b:vscode:claude:aiActivity/activityDir)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Root And Here" :extraInfo "Confirming a session's AI-Activities, from Blee"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Root And Here:* |]]  Confirming a session's AI-Activities, from Blee  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/confirmRoot" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/confirmRoot>>  --  -- Confirm the root AI-Activity of the session covering this buffer.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/confirmRoot (
;;;#+END:
                  &optional <submit)
   " #+begin_org
** DocStr: Confirm the root AI-Activity of the session covering this buffer.
Sends /bx-confirm-root dir=<root> emacs=<socket> register=b:vscode:claude:aiActivity/rootRegister to
the session whose cwd covers this buffer (the VS Code window's folder: the root); when several
sessions share that folder, asks which (layer 4's picker). Claude checks it can reach this Emacs and
calls the register function with its session id; the association is recorded now too.
#+end_org "
  (interactive (list (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let* (($covering (b:vscode:claude:sessions/covering default-directory))
         ($deepest (and $covering (plist-get (car $covering) :cwd)))
         ($candidates (seq-filter (lambda ($s) (equal (plist-get $s :cwd) $deepest)) $covering))
         ($id (if $candidates
                  (b:vscode:claude:session/choose $candidates nil "Session to confirm the root in: ")
                (user-error "No running session has %s in its folder: open its root in VS Code"
                            default-directory)))
         ($root (directory-file-name (b:vscode:claude:dir/canonical $deepest))))
    (b:vscode:claude:association/set $root $id)
    (b:vscode:claude/atPrompt
     (format "/bx-confirm-root dir=%s emacs=%s register=b:vscode:claude:aiActivity/rootRegister"
             $root (b:vscode:partner/socket))
     $id <submit)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/rootRegister" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/rootRegister>>  --  -- Claude's call back from /bx-confirm-root: record <rootDir -> <sessionId.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/rootRegister (
;;;#+END:
                  <rootDir <sessionId)
   " #+begin_org
** DocStr: Claude's call back from /bx-confirm-root: record <rootDir -> <sessionId.
Named in the prompt by confirmRoot (register=); returns a short confirmation string for Claude to
report.
#+end_org "
  (b:vscode:claude:association/set <rootDir <sessionId)
  (message "VS Code Claude session %s registered for %s" <sessionId <rootDir)
  (format "registered %s %s" <rootDir <sessionId))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/confirmHere" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/confirmHere>>  --  -- Join this buffer's AI-Activity to its session: /bx-confirm-here <dir>.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/confirmHere (
;;;#+END:
                  &optional <dir <submit)
   " #+begin_org
** DocStr: Join this buffer's AI-Activity to its session: /bx-confirm-here <dir>.
<dir: the nearest directory above with a CLAUDE.md. The session: that of the root above (its
association), else the one covering <dir. The association <dir -> session is recorded.
#+end_org "
  (interactive (list nil (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let* (($dir (directory-file-name
                (b:vscode:claude:dir/canonical
                 (or <dir (locate-dominating-file default-directory "CLAUDE.md")
                     (user-error "No CLAUDE.md above %s: not an AI-Activity" default-directory)))))
         ($id (or (b:vscode:claude:session/forDir $dir)
                  (user-error "No session for %s: b:vscode:claude:aiActivity/confirmRoot in a buffer of its root" $dir))))
    (b:vscode:claude:association/set $dir $id)
    (b:vscode:claude/atPrompt (format "/bx-confirm-here %s" $dir) $id <submit)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/bxSend" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/bxSend>>  --  -- Send the /bx-<name> command, with optional <args.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/bxSend (
;;;#+END:
                  <name &optional <args <submit)
   " #+begin_org
** DocStr: Send the /bx-<name> command, with optional <args.
#+end_org "
  (b:vscode:claude/atPrompt (string-join (delq nil (list (concat "/bx-" <name) <args)) " ") nil <submit))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "The Commit Cycle" :extraInfo "x c asks Claude, x x also submits; c c offers .git/CLAUDE_COMMIT_MSG"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *The Commit Cycle:* |]]  x c asks Claude, x x also submits; c c offers .git/CLAUDE_COMMIT_MSG  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/commitMsgGenerate" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/commitMsgGenerate>>  --  -- Send /bx-git-commit-msg <repo> to this repo's VS Code Claude session.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/commitMsgGenerate (
;;;#+END:
                  &optional <submit)
   " #+begin_org
** DocStr: Send /bx-git-commit-msg <repo> to this repo's VS Code Claude session.
x c: not submitted (press Enter in VS Code); x x: submitted. Then Claude writes the message; with
the Claude Code hooks installed, its Stop raises magit here. c c, and
b:vscode:claude:aiActivity:magit:commitMsg/offer offers it. The repo is given as a path, so the
session need not be working in it.
#+end_org "
  (interactive (list (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (require 'magit)                      ; also run from an aiActivity: link, outside magit
  (let (($repo (magit-toplevel)))
    (unless $repo
      (user-error "Not in a git repository"))
    (unless (magit-anything-staged-p)
      (user-error "Nothing staged in %s" $repo))
    (setq $repo (directory-file-name $repo))
    (setf (alist-get $repo b:vscode:claude:aiActivity:commitMsg:requests nil nil #'string=) (current-time))
    (b:vscode:claude/atPrompt (format "/bx-git-commit-msg %s" $repo) nil <submit)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/commitMsgGenerateSubmit" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/commitMsgGenerateSubmit>>  --  -- As commitMsgGenerate, submitted (magit x x).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/commitMsgGenerateSubmit (
;;;#+END:
                  )
   " #+begin_org
** DocStr: As commitMsgGenerate, submitted (magit x x).
#+end_org "
  (interactive)
  (b:vscode:claude:aiActivity/commitMsgGenerate t))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit:commitMsg/file" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit:commitMsg/file>>  --  -- The CLAUDE_COMMIT_MSG of <repo (in its git dir).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit:commitMsg/file (
;;;#+END:
                  <repo)
   " #+begin_org
** DocStr: The CLAUDE_COMMIT_MSG of <repo (in its git dir).
#+end_org "
  (let ((default-directory (file-name-as-directory <repo)))
    (expand-file-name "CLAUDE_COMMIT_MSG"
                      (if (fboundp 'magit-gitdir) (magit-gitdir) (expand-file-name ".git")))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit:commitMsg/offer" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit:commitMsg/offer>>  --  -- In git-commit-setup-hook: offer <gitdir>/CLAUDE_COMMIT_MSG when the message is empty.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit:commitMsg/offer (
;;;#+END:
                  )
   " #+begin_org
** DocStr: In git-commit-setup-hook: offer <gitdir>/CLAUDE_COMMIT_MSG when the message is empty.
Skipped when the buffer already has a message (amend, git commit -t, a reword).
#+end_org "
  (setq b:vscode:claude:aiActivity:magit:commitMsg:pending nil)
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
      (setq b:vscode:claude:aiActivity:magit:commitMsg:pending $msgFile))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit:commitMsg/markUsed" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit:commitMsg/markUsed>>  --  -- In git-commit-post-finish-hook: rename the used message to CLAUDE_COMMIT_MSG.used,  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit:commitMsg/markUsed (
;;;#+END:
                  )
   " #+begin_org
** DocStr: In git-commit-post-finish-hook: rename the used message to CLAUDE_COMMIT_MSG.used,
so it is not offered again. Not run when the commit is aborted: the file then stays.
#+end_org "
  (when (and b:vscode:claude:aiActivity:magit:commitMsg:pending
             (file-exists-p b:vscode:claude:aiActivity:magit:commitMsg:pending))
    (rename-file b:vscode:claude:aiActivity:magit:commitMsg:pending
                 (concat b:vscode:claude:aiActivity:magit:commitMsg:pending ".used") t))
  (setq b:vscode:claude:aiActivity:magit:commitMsg:pending nil))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:hook/commitMsgReady" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:hook/commitMsgReady>>  --  -- On Stop: a requested commit message is written: raise magit there.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:hook/commitMsgReady (
;;;#+END:
                  <event)
   " #+begin_org
** DocStr: On Stop: a requested commit message is written: raise magit there.
For each /bx-git-commit-msg request (x c, x x) whose CLAUDE_COMMIT_MSG is newer than the request:
forget the request, show that repo's magit status in a raised frame, and say so.
#+end_org "
  (when (equal (plist-get <event :type) "Stop")
    (dolist ($req b:vscode:claude:aiActivity:commitMsg:requests)
      (let (($file (ignore-errors (b:vscode:claude:aiActivity:magit:commitMsg/file (car $req)))))
        (when (and $file (file-exists-p $file)
                   (time-less-p (cdr $req) (file-attribute-modification-time (file-attributes $file))))
          (setq b:vscode:claude:aiActivity:commitMsg:requests
                (delq $req b:vscode:claude:aiActivity:commitMsg:requests))
          (b:vscode:claude:aiActivity:magit/show (car $req))
          (message "Claude's commit message for %s is ready: c c" (car $req)))))))

(add-hook 'b:vscode:claude:event-hook #'b:vscode:claude:aiActivity:hook/commitMsgReady)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "The Commit Walk" :extraInfo "Committing several repos in turn: x n moves on (WorkPlan 12.5)"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *The Commit Walk:* |]]  Committing several repos in turn: x n moves on (WorkPlan 12.5)  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit/show" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit/show>>  --  -- Show <repo's magit status in a raised frame.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit/show (
;;;#+END:
                  <repo)
   " #+begin_org
** DocStr: Show <repo's magit status in a raised frame.
#+end_org "
  (when (fboundp 'magit-status-setup-buffer)
    (magit-status-setup-buffer (file-name-as-directory <repo)))
  (let (($frame (selected-frame)))
    (raise-frame $frame)
    (select-frame-set-input-focus $frame)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit/walk" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit/walk>>  --  -- Start a commit walk over <repos: open the first one's magit.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit/walk (
;;;#+END:
                  <repos)
   " #+begin_org
** DocStr: Start a commit walk over <repos: open the first one's magit.
Called by Claude from /bx-git-commit-walk walk=b:vscode:claude:aiActivity:magit/walk (sent by
walkStart). In each repo: stage, x x, c c, C-c C-c, then x n for the next. Returns a short string.
#+end_org "
  (setq b:vscode:claude:aiActivity:walk:repos (mapcar #'directory-file-name <repos)
        b:vscode:claude:aiActivity:walk:index 0)
  (if (null <repos)
      "nothing to walk"
    (b:vscode:claude:aiActivity:magit/show (car b:vscode:claude:aiActivity:walk:repos))
    (message "Commit walk: 1/%d %s --- stage, x x, commit, then x n"
             (length <repos) (car b:vscode:claude:aiActivity:walk:repos))
    (format "walking %d repos" (length <repos))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit/walkNext" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit/walkNext>>  --  -- The commit walk's next repo (magit x n).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit/walkNext (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The commit walk's next repo (magit x n).
Warns, and asks, when the repo open now still has uncommitted changes.
#+end_org "
  (interactive)
  (let* (($repos b:vscode:claude:aiActivity:walk:repos)
         ($i b:vscode:claude:aiActivity:walk:index)
         ($now (nth $i $repos)))
    (unless $repos
      (user-error "No commit walk: /bx-git-commit-walk (or x w) starts one"))
    (when (and $now
               (let ((default-directory (file-name-as-directory $now)))
                 (or (magit-anything-staged-p) (magit-anything-unstaged-p)))
               (not (y-or-n-p (format "%s still has changes. Move on anyway? " $now))))
      (user-error "Still in %s" $now))
    (if (>= (1+ $i) (length $repos))
        (progn (setq b:vscode:claude:aiActivity:walk:repos nil)
               (message "Commit walk done: %d repos" (length $repos)))
      (setq b:vscode:claude:aiActivity:walk:index (1+ $i))
      (b:vscode:claude:aiActivity:magit/show (nth (1+ $i) $repos))
      (message "Commit walk: %d/%d %s" (+ 2 $i) (length $repos) (nth (1+ $i) $repos)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit/walkStart" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit/walkStart>>  --  -- Ask this repo's VS Code Claude session for a commit walk, submitted.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit/walkStart (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Ask this repo's VS Code Claude session for a commit walk, submitted.
Sends /bx-git-commit-walk emacs=<socket> walk=b:vscode:claude:aiActivity:magit/walk: Claude lists the
session's uncommitted repos and hands them here; x n then moves from one to the next.
#+end_org "
  (interactive)
  (b:vscode:claude/atPrompt
   (format "/bx-git-commit-walk emacs=%s walk=b:vscode:claude:aiActivity:magit/walk"
           (b:vscode:partner/socket))
   nil t))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "TODOs" :extraInfo "/bx-todo-do and /bx-todo-done, with the anchors of this activity's WorkPlan"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *TODOs:* |]]  /bx-todo-do and /bx-todo-done, with the anchors of this activity's WorkPlan  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:todo/open" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:todo/open>>  --  -- The open TODOs of this activity's AI-WorkPlan.org: a list of (anchor . headline).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:todo/open (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The open TODOs of this activity's AI-WorkPlan.org: a list of (anchor . headline).
A heading whose keyword is TODO and which holds a <<anchor>>. Read from the file on disk (or from its
buffer when it is visited and modified), so it works from any buffer of the activity.
#+end_org "
  (let* (($file (expand-file-name "AI-WorkPlan.org" (b:vscode:claude:aiActivity/activityDir)))
         ($buf (find-buffer-visiting $file))
         ($result nil))
    (unless (or $buf (file-readable-p $file))
      (user-error "No AI-WorkPlan.org in %s" (file-name-directory $file)))
    (with-temp-buffer
      (if $buf (insert (with-current-buffer $buf (buffer-substring-no-properties (point-min) (point-max))))
        (insert-file-contents $file))
      (goto-char (point-min))
      (while (re-search-forward "^\\*+ +TODO +\\(.*<<\\([^>]+\\)>>.*\\)$" nil t)
        (push (cons (match-string-no-properties 2) (string-trim (match-string-no-properties 1))) $result)))
    (nreverse $result)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:todo/choose" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:todo/choose>>  --  -- Ask for an open TODO of this activity; return its anchor.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:todo/choose (
;;;#+END:
                  <prompt)
   " #+begin_org
** DocStr: Ask for an open TODO of this activity; return its anchor.
#+end_org "
  (let* (($todos (or (b:vscode:claude:aiActivity:todo/open)
                     (user-error "No open TODO with an anchor in this activity's AI-WorkPlan.org")))
         ($choice (completing-read <prompt (mapcar #'cdr $todos) nil t)))
    (car (rassoc $choice $todos))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/todoDo" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/todoDo>>  --  -- Send /bx-todo-do <anchor>: Claude works on that TODO.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/todoDo (
;;;#+END:
                  &optional <anchor <submit)
   " #+begin_org
** DocStr: Send /bx-todo-do <anchor>: Claude works on that TODO.
Interactively, asks which open TODO of this activity's WorkPlan.
#+end_org "
  (interactive (list (b:vscode:claude:aiActivity:todo/choose "TODO to work on: ")
                     (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (b:vscode:claude:aiActivity/bxSend
   "todo-do" (or <anchor (b:vscode:claude:aiActivity:todo/choose "TODO to work on: ")) <submit))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity/todoDone" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity/todoDone>>  --  -- Send /bx-todo-done <anchor>: Claude marks that TODO DONE.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity/todoDone (
;;;#+END:
                  &optional <anchor <submit)
   " #+begin_org
** DocStr: Send /bx-todo-done <anchor>: Claude marks that TODO DONE.
Interactively, asks which open TODO of this activity's WorkPlan.
#+end_org "
  (interactive (list (b:vscode:claude:aiActivity:todo/choose "TODO to mark DONE: ")
                     (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (b:vscode:claude:aiActivity/bxSend
   "todo-done" (or <anchor (b:vscode:claude:aiActivity:todo/choose "TODO to mark DONE: ")) <submit))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Org Links" :extraInfo "[[aiActivity:status-read]] sends /bx-status-read"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Org Links:* |]]  [[aiActivity:status-read]] sends /bx-status-read  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:link/follow" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:link/follow>>  --  -- Follow an aiActivity: link: send /bx-<name> <args>.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:link/follow (
;;;#+END:
                  <path &optional <arg)
   " #+begin_org
** DocStr: Follow an aiActivity: link: send /bx-<name> <args>.
<path is \"<name> <args>\", e.g. \"status-read\" or \"todo-do 7.1\". \"S=<name> <args>\" is
submitted (the links after |S| in the workflow driver); otherwise a prefix <arg (C-u C-c C-o) flips
whether it is. Commands that need more than a plain send go through their own
functions: confirm-root (dir=, emacs=, register=), confirm-here (the activity dir), git-commit-msg
(this repo, the request recorded), git-commit-walk (walk=), todo-do and todo-done (ask the anchor).
#+end_org "
  (let* (($forced (string-prefix-p "S=" <path))
         ($words (split-string (string-trim (string-remove-prefix "S=" <path)) "[ \t]+" t))
         ($name (or (car $words) (user-error "Empty aiActivity: link")))
         ($args (and (cdr $words) (string-join (cdr $words) " ")))
         ($submit (or $forced (b:vscode:claude:submit/fromPrefix <arg))))
    (pcase $name
      ("confirm-root" (b:vscode:claude:aiActivity/confirmRoot $submit))
      ("confirm-here" (b:vscode:claude:aiActivity/confirmHere $args $submit))
      ("git-commit-msg" (b:vscode:claude:aiActivity/commitMsgGenerate $submit))
      ("git-commit-walk" (b:vscode:claude:aiActivity:magit/walkStart))
      ("todo-do" (b:vscode:claude:aiActivity/todoDo $args $submit))
      ("todo-done" (b:vscode:claude:aiActivity/todoDone $args $submit))
      (_ (b:vscode:claude:aiActivity/bxSend $name $args $submit)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:link/helpEcho" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:link/helpEcho>>  --  -- The tooltip of an aiActivity: link: what it sends, and whether it submits.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:link/helpEcho (
;;;#+END:
                  <window _object <position)
   " #+begin_org
** DocStr: The tooltip of an aiActivity: link: what it sends, and whether it submits.
#+end_org "
  (let (($path (with-current-buffer (window-buffer <window)
                 (save-excursion
                   (goto-char <position)
                   (org-element-property :path (org-element-context))))))
    (cond ((null $path) "Send this /bx- command to VS Code Claude")
          ((string-prefix-p "S=" $path)
           (format "submits: /bx-%s" (string-remove-prefix "S=" $path)))
          (t (format "pastes: /bx-%s (you press Enter; C-u C-c C-o submits)" $path)))))

(with-eval-after-load 'ol
  (org-link-set-parameters
   "aiActivity"
   :follow #'b:vscode:claude:aiActivity:link/follow
   :face (lambda (<path) (if (string-prefix-p "S=" <path) '(org-link bold) 'org-link))
   :help-echo #'b:vscode:claude:aiActivity:link/helpEcho))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Transients" :extraInfo "The /bx- menu, added to layer 4's; magit's x"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Transients:* |]]  The /bx- menu, added to layer 4's; magit's x  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(with-eval-after-load 'transient
  (transient-define-prefix b:vscode:claude:aiActivity/dispatch ()
    "AI-Activity commands into this buffer's VS Code Claude session (vscode-claude layer 5)."
    [["Session"
      ("r" "/bx-confirm-root (+ register)" b:vscode:claude:aiActivity/confirmRoot)
      ("h" "/bx-confirm-here this activity" b:vscode:claude:aiActivity/confirmHere)
      ("s" "/bx-status-read" (lambda () (interactive) (b:vscode:claude:aiActivity/bxSend "status-read")))
      ("v" "/bx-session-verify" (lambda () (interactive) (b:vscode:claude:aiActivity/bxSend "session-verify")))]
     ["Work"
      ("t" "/bx-todo-do a TODO" b:vscode:claude:aiActivity/todoDo)
      ("T" "/bx-todo-done a TODO" b:vscode:claude:aiActivity/todoDone)]
     ["Record"
      ("u" "/bx-status-update" (lambda () (interactive) (b:vscode:claude:aiActivity/bxSend "status-update")))
      ("a" "/bx-archive-read" (lambda () (interactive) (b:vscode:claude:aiActivity/bxSend "archive-read")))
      ("A" "/bx-archive-update" (lambda () (interactive) (b:vscode:claude:aiActivity/bxSend "archive-update")))
      ("o" "/bx-ai-outputs" (lambda () (interactive) (b:vscode:claude:aiActivity/bxSend "ai-outputs")))]
     ["Git"
      ("g" "/bx-git-uncommitted-list" (lambda () (interactive) (b:vscode:claude:aiActivity/bxSend "git-uncommitted-list")))
      ("w" "/bx-git-commit-walk (in Blee)" b:vscode:claude:aiActivity:magit/walkStart)]])
  (with-eval-after-load 'b:vscode:claude
    (condition-case nil
        (transient-append-suffix 'b:vscode:claude/dispatch "e"
          '("a" "AI-Activity (/bx-)" b:vscode:claude:aiActivity/dispatch))
      (error nil))))

(with-eval-after-load 'magit
  (transient-define-prefix b:vscode:claude:aiActivity:magit/dispatch ()
    "Claude, in the local VS Code, for this repo (vscode-claude layer 5)."
    ["Claude (this repo's VS Code session)"
     ("c" "Commit message for the staged changes (/bx-git-commit-msg)"
      b:vscode:claude:aiActivity/commitMsgGenerate)
     ("x" "Commit message, submitted"
      b:vscode:claude:aiActivity/commitMsgGenerateSubmit)
     ("n" "Commit walk: next repo" b:vscode:claude:aiActivity:magit/walkNext)
     ("w" "Commit walk: start (/bx-git-commit-walk)" b:vscode:claude:aiActivity:magit/walkStart)
     ("d" "VS Code Claude menu" b:vscode:claude/dispatch)]))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:aiActivity:magit|config" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:aiActivity:magit|config>>  --  -- Hook Claude's commit message into magit: the commit hooks, and x.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:aiActivity:magit|config (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Hook Claude's commit message into magit: the commit hooks, and x.
Run after magit is loaded (b:npa:vscode-claude:config|main does so, through the old name
b:vscode:claude:magit|config, kept as an alias).
#+end_org "
  ;;; Offer Claude's .git/CLAUDE_COMMIT_MSG (written by /bx-git-commit-msg) in an empty commit buffer.
  (add-hook 'git-commit-setup-hook #'b:vscode:claude:aiActivity:magit:commitMsg/offer t)
  (add-hook 'git-commit-post-finish-hook #'b:vscode:claude:aiActivity:magit:commitMsg/markUsed)
  ;;; x: x c, x x, x n, x w, x d. x was magit-reset-quickly, which stays reachable as X (magit-reset).
  (define-key magit-mode-map (kbd "x") #'b:vscode:claude:aiActivity:magit/dispatch)
  (condition-case nil
      (transient-append-suffix 'magit-dispatch "X" '("x" "Claude" b:vscode:claude:aiActivity:magit/dispatch))
    (error (message "b:vscode:claude:aiActivity: magit-dispatch has no X: Claude (x) not added"))))

(defalias 'b:vscode:claude:magit|config #'b:vscode:claude:aiActivity:magit|config
  "The name blee/env3's bnpa:vscode-claude.el calls; the function is layer 5's.")

;;;#+BEGIN: b:elisp:file/provide :modName nil
(provide 'b:vscode:claude:aiActivity)
;;;#+END:

;;;#+BEGIN: b:elisp:file/endOf :outLevel 1
(orgCmntBegin "
* [[elisp:(show-all)][(>]] ~END-OF-FILE~  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;; local variables:
;;; no-byte-compile: t
;;; end:
;;;#+END:
