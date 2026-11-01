;;; b:vscode:claude.el --- Blee and VS Code Claude: the vscodeClaude layer  -*- lexical-binding: t; -*-

(orgCmntBegin "
* Summary: Layer 4, Emacs <-> VS Code Claude: prompts, sessions, context, submit, hooks --- thin over vscodeClaude.cs.
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
Layer 4 of the five (README.org, WorkPlan Stage 13): Blee driving the Claude of the local VS Code,
with no knowledge of AI-Activity --- it names no /bx- command and no CLAUDE.md. Layer 5,
b:vscode:claude:aiActivity.el, builds on it.
- Prompt in: b:vscode:claude/atPrompt puts text in a session's input box (vscodeClaude.cs -i
  claudePrompt); the user presses Enter unless submit is asked for (b:vscode:claude:submit?, C-u).
- Which session: a one-shot choice (sessionSelect's new conversation), a buffer-local one, the
  association of the buffer's base dir (walk-up; layer 5 makes the base dir the AI-Activity dir),
  the running session whose folder covers the buffer, else the latest local one.
- Sends with context: @file:line, the region, the file, the flymake/flycheck error at point.
- Claude Code hooks: vscodeClaude.cs -i hookToEmacs calls b:vscode:claude/hookHandle, which runs
  b:vscode:claude:event-hook (the model is claude-code.el's claude-code-handle-hook).
* Relevant Panels:
** [[file:./README.org]] --- the design and documentation.
* Planned Improvements:
" orgCmntEnd)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 0 :title "REQUIRES" :extraInfo "Imports"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*     [[elisp:(outline-show-subtree+toggle)][| _REQUIRES_: |]]  Imports  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(require 'blee-libs)
(require 'b:vscode)
(require 'json)
(require 'seq)
(require 'subr-x)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Variables And Constants" :extraInfo "defvar, defcustom"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Variables And Constants:* |]]  defvar, defcustom  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(defvar b:vscode:claude:program "vscodeClaude.cs"
  "The CLI (bisos.vscodeClaude) that finds the local VS Code Claude sessions and prompts them.")

(defvar b:vscode:claude:outBuffer "*vscodeClaude*"
  "Buffer holding the last b:vscode:claude:program run's output (the commands it ran are on its stderr).")

(defvar b:vscode:claude:history nil
  "Minibuffer history of the prompts sent to VS Code Claude.")

(defvar b:vscode:claude:submit? nil
  "Non-nil: prompts are submitted (Enter pressed in VS Code). A C-u prefix flips it for one send.")

(defvar b:vscode:claude:associations nil
  "Alist of (base dir . sessionId): which session a buffer under that dir prompts.
Dirs are true names ending in /. Filled by sessionSelect, and by layer 5 (confirmRoot, confirmHere).")

(defvar-local b:vscode:claude:session:buffer nil
  "A sessionId this buffer prompts, before any association (sessionSelect with C-u).")

(defvar b:vscode:claude:session:next nil
  "A one-shot target for the next prompt: \"new\" (a new conversation), then cleared.")

(defvar b:vscode:claude:baseDir-function #'b:vscode:claude:baseDir/default
  "Function of no arguments: the base dir a choice of session applies to, for the current buffer.
Layer 5 (b:vscode:claude:aiActivity) sets it to the buffer's AI-Activity dir.")

(defvar b:vscode:claude:event-hook nil
  "Abnormal hook run, from a timer, on each Claude Code hook event hookHandle receives.
Each function gets one plist: :type (\"Stop\", \"Notification\", ...), :session, :cwd, :data (the
event's JSON as an alist). Its return value is ignored.")

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Sessions" :extraInfo "The running sessions, and choosing one"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Sessions:* |]]  The running sessions, and choosing one  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:sessions/running" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:sessions/running>>  --  -- The running local sessions, newest first, as plists.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:sessions/running (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The running local sessions, newest first, as plists.
Each plist: :sessionId :instance :cwd :name :status :updatedAt :pid (vscodeClaude.cs claudeSessionsList).
#+end_org "
  (let (($out (b:vscode:program/runOrError
               b:vscode:claude:program b:vscode:claude:outBuffer "-i" "claudeSessionsList")))
    (delq nil
          (mapcar (lambda ($line)
                    (let (($f (split-string $line "\t")))
                      (when (= (length $f) 7)
                        (list :sessionId (nth 0 $f) :instance (nth 1 $f) :cwd (nth 2 $f)
                              :name (nth 3 $f) :status (nth 4 $f) :updatedAt (nth 5 $f)
                              :pid (nth 6 $f)))))
                  (split-string $out "\n" t)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:session/describe" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:session/describe>>  --  -- A one-line description of session <s for a choice.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:session/describe (
;;;#+END:
                  <s)
   " #+begin_org
** DocStr: A one-line description of session <s for a choice.
#+end_org "
  (let* (($ms (string-to-number (or (plist-get <s :updatedAt) "0")))
         ($ago (if (> $ms 0) (- (float-time) (/ $ms 1000.0)) 0)))
    (format "%-24s %-8s %5s  %s  [%s]"
            (truncate-string-to-width (or (plist-get <s :name) "") 24)
            (or (plist-get <s :status) "")
            (cond ((< $ago 90) (format "%ds" (round $ago)))
                  ((< $ago 5400) (format "%dm" (round (/ $ago 60))))
                  (t (format "%dh" (round (/ $ago 3600)))))
            (abbreviate-file-name (or (plist-get <s :cwd) ""))
            (truncate-string-to-width (or (plist-get <s :sessionId) "?") 8))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:session/choose" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:session/choose>>  --  -- Ask which session: a sessionId, or new (a new conversation) when <newOk allows it.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:session/choose (
;;;#+END:
                  <sessions &optional <newOk <prompt)
   " #+begin_org
** DocStr: Ask which session: a sessionId, or new (a new conversation) when <newOk allows it.
One session and no <newOk: that one, without asking. None and no <newOk: a user-error.
#+end_org "
  (let* (($choices (mapcar (lambda ($s) (cons (b:vscode:claude:session/describe $s)
                                               (plist-get $s :sessionId)))
                           <sessions))
         ($new "(a new conversation)"))
    (when <newOk (setq $choices (append $choices (list (cons $new "new")))))
    (cond ((null $choices) (user-error "No running local VS Code Claude session"))
          ((and (= (length $choices) 1) (not <newOk)) (cdar $choices))
          (t (cdr (assoc (completing-read (or <prompt "Claude session: ") $choices nil t)
                         $choices))))))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Base Dirs And Associations" :extraInfo "Which session a buffer prompts"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Base Dirs And Associations:* |]]  Which session a buffer prompts  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:dir/canonical" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:dir/canonical>>  --  -- <dir as a true name ending in /.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:dir/canonical (
;;;#+END:
                  <dir)
   " #+begin_org
** DocStr: <dir as a true name ending in /.
#+end_org "
  (file-name-as-directory (file-truename (expand-file-name <dir))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:dir/within?" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:dir/within?>>  --  -- Non-nil when <dir is <base or under it (both canonical).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:dir/within? (
;;;#+END:
                  <dir <base)
   " #+begin_org
** DocStr: Non-nil when <dir is <base or under it (both canonical).
#+end_org "
  (string-prefix-p <base <dir))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:baseDir/default" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:baseDir/default>>  --  -- The default base dir of this buffer: its git repo, else its directory.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:baseDir/default (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The default base dir of this buffer: its git repo, else its directory.
#+end_org "
  (or (locate-dominating-file default-directory ".git") default-directory))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:baseDir" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:baseDir>>  --  -- The base dir a choice of session applies to, for this buffer (canonical).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:baseDir (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The base dir a choice of session applies to, for this buffer (canonical).
#+end_org "
  (b:vscode:claude:dir/canonical (funcall b:vscode:claude:baseDir-function)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:sessions/covering" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:sessions/covering>>  --  -- The running sessions whose cwd is <dir or above it: deepest, then newest.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:sessions/covering (
;;;#+END:
                  <dir &optional <sessions)
   " #+begin_org
** DocStr: The running sessions whose cwd is <dir or above it: deepest, then newest.
#+end_org "
  (let (($dir (b:vscode:claude:dir/canonical <dir)))
    ;; sessions/running is newest first and seq-sort is stable: deepest cwd, then newest.
    (seq-sort (lambda ($a $b) (> (length (plist-get $a :cwd)) (length (plist-get $b :cwd))))
              (seq-filter (lambda ($s) (b:vscode:claude:dir/within?
                                        $dir (b:vscode:claude:dir/canonical (plist-get $s :cwd))))
                          (or <sessions (b:vscode:claude:sessions/running))))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:session/covering" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:session/covering>>  --  -- The running session whose cwd is <dir or above it, deepest first.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:session/covering (
;;;#+END:
                  <dir &optional <sessions)
   " #+begin_org
** DocStr: The running session whose cwd is <dir or above it, deepest first.
Among sessions with the same cwd, the most recently active. nil when none covers <dir.
#+end_org "
  (car (b:vscode:claude:sessions/covering <dir <sessions)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:association/set" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:association/set>>  --  -- Record that buffers under <dir prompt session <sessionId.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:association/set (
;;;#+END:
                  <dir <sessionId)
   " #+begin_org
** DocStr: Record that buffers under <dir prompt session <sessionId.
#+end_org "
  (let (($key (b:vscode:claude:dir/canonical <dir)))
    (setf (alist-get $key b:vscode:claude:associations nil nil #'string=) <sessionId)
    $key))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:association/forget" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:association/forget>>  --  -- Drop the association of exactly <dir; non-nil if there was one.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:association/forget (
;;;#+END:
                  <dir)
   " #+begin_org
** DocStr: Drop the association of exactly <dir; non-nil if there was one.
#+end_org "
  (let* (($key (b:vscode:claude:dir/canonical <dir))
         ($had (assoc $key b:vscode:claude:associations)))
    (setq b:vscode:claude:associations (delq $had b:vscode:claude:associations))
    (and $had t)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:association/lookup" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:association/lookup>>  --  -- The (dir . sessionId) association nearest above <dir, or nil.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:association/lookup (
;;;#+END:
                  <dir)
   " #+begin_org
** DocStr: The (dir . sessionId) association nearest above <dir, or nil.
#+end_org "
  (let (($dir (b:vscode:claude:dir/canonical <dir)))
    (car (seq-sort (lambda ($a $b) (> (length (car $a)) (length (car $b))))
                   (seq-filter (lambda ($a) (b:vscode:claude:dir/within? $dir (car $a)))
                               b:vscode:claude:associations)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:session/forDir" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:session/forDir>>  --  -- The sessionId a buffer in <dir prompts, or nil: the latest local session.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:session/forDir (
;;;#+END:
                  <dir)
   " #+begin_org
** DocStr: The sessionId a buffer in <dir prompts, or nil: the latest local session.
The association nearest above <dir, when its session is still running (a dead one is dropped, with
a message); else the session whose cwd covers <dir; else nil.
#+end_org "
  (let* (($sessions (b:vscode:claude:sessions/running))
         ($assoc (b:vscode:claude:association/lookup <dir)))
    (cond
     ((and $assoc (seq-find (lambda ($s) (string= (plist-get $s :sessionId) (cdr $assoc))) $sessions))
      (cdr $assoc))
     (t
      (when $assoc
        (setq b:vscode:claude:associations (delq $assoc b:vscode:claude:associations))
        (message "Session %s of %s is gone: association dropped" (cdr $assoc) (car $assoc)))
      (plist-get (b:vscode:claude:session/covering <dir $sessions) :sessionId)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:session/forBuffer" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:session/forBuffer>>  --  -- The sessionId this buffer prompts: buffer-local, else by its directory.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:session/forBuffer (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The sessionId this buffer prompts: buffer-local, else by its directory.
#+end_org "
  (or b:vscode:claude:session:buffer
      (b:vscode:claude:session/forDir default-directory)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/sessionSelect" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/sessionSelect>>  --  -- Choose the VS Code Claude session this buffer's base dir prompts.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/sessionSelect (
;;;#+END:
                  &optional <bufferOnly)
   " #+begin_org
** DocStr: Choose the VS Code Claude session this buffer's base dir prompts.
A picker over the running sessions (name, status, last active, folder) and a new conversation.
The choice is recorded for the base dir (b:vscode:claude:baseDir: the git repo, or with layer 5
the AI-Activity dir); with C-u (<bufferOnly), for this buffer only. A new conversation applies to
the next prompt only, and drops the base dir's association so that the new session, once it runs,
is found by its folder.
#+end_org "
  (interactive "P")
  (let (($id (b:vscode:claude:session/choose (b:vscode:claude:sessions/running) t
                                             "Claude session for this buffer: ")))
    (cond
     ((equal $id "new")
      (setq b:vscode:claude:session:next "new")
      (if <bufferOnly
          (setq b:vscode:claude:session:buffer nil)
        (b:vscode:claude:association/forget (b:vscode:claude:baseDir)))
      (message "The next prompt starts a new conversation"))
     (<bufferOnly
      (setq b:vscode:claude:session:buffer $id)
      (message "This buffer prompts session %s" $id))
     (t
      (let (($dir (b:vscode:claude:association/set (b:vscode:claude:baseDir) $id)))
        (message "Buffers under %s prompt session %s" (abbreviate-file-name $dir) $id))))
    $id))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/sessionForget" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/sessionForget>>  --  -- Back to the automatic choice of session for this buffer's base dir.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/sessionForget (
;;;#+END:
                  &optional <bufferOnly)
   " #+begin_org
** DocStr: Back to the automatic choice of session for this buffer's base dir.
Drops the base dir's association; with C-u (<bufferOnly), this buffer's own choice instead.
#+end_org "
  (interactive "P")
  (if <bufferOnly
      (progn (setq b:vscode:claude:session:buffer nil)
             (message "This buffer's own session choice is dropped"))
    (let (($dir (b:vscode:claude:baseDir)))
      (message (if (b:vscode:claude:association/forget $dir)
                   "Association of %s dropped: the session is chosen automatically"
                 "%s had no association")
               (abbreviate-file-name $dir)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:session/targetDescribe" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:session/targetDescribe>>  --  -- Where a prompt from this buffer would go, in one line.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:session/targetDescribe (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Where a prompt from this buffer would go, in one line.
#+end_org "
  (condition-case nil
      (cond
       ((equal b:vscode:claude:session:next "new") "next prompt: a new conversation")
       (t (let* (($sessions (b:vscode:claude:sessions/running))
                 ($id (b:vscode:claude:session/forBuffer))
                 ($s (and $id (seq-find (lambda ($x) (string= (plist-get $x :sessionId) $id))
                                        $sessions))))
            (cond ($s (concat "-> " (b:vscode:claude:session/describe $s)))
                  ($sessions (concat "-> latest: " (b:vscode:claude:session/describe (car $sessions))))
                  (t "no running local session")))))
    (error "sessions unknown (vscodeClaude.cs failed)")))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/associationsShow" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/associationsShow>>  --  -- Show the recorded associations: base dir and session.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/associationsShow (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Show the recorded associations: base dir and session.
#+end_org "
  (interactive)
  (with-current-buffer (get-buffer-create "*vscodeClaude associations*")
    (erase-buffer)
    (if (null b:vscode:claude:associations)
        (insert "No associations: b:vscode:claude/sessionSelect (or layer 5's confirmRoot).\n")
      (dolist ($a b:vscode:claude:associations)
        (insert (format "%s\t%s\n" (cdr $a) (car $a)))))
    (display-buffer (current-buffer))))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Prompt In" :extraInfo "A prompt into a local VS Code Claude session"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Prompt In:* |]]  A prompt into a local VS Code Claude session  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:submit/fromPrefix" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:submit/fromPrefix>>  --  -- Whether to submit: b:vscode:claude:submit?, flipped by a prefix <arg.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:submit/fromPrefix (
;;;#+END:
                  <arg)
   " #+begin_org
** DocStr: Whether to submit: b:vscode:claude:submit?, flipped by a prefix <arg.
#+end_org "
  (if <arg (not b:vscode:claude:submit?) b:vscode:claude:submit?))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/submitToggle" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/submitToggle>>  --  -- Toggle b:vscode:claude:submit?: whether prompts are submitted.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/submitToggle (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Toggle b:vscode:claude:submit?: whether prompts are submitted.
#+end_org "
  (interactive)
  (setq b:vscode:claude:submit? (not b:vscode:claude:submit?))
  (message "VS Code Claude prompts are %s" (if b:vscode:claude:submit? "submitted" "left for Enter")))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/atPrompt" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/atPrompt>>  --  -- Put <text in the input box of a local VS Code Claude session.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/atPrompt (
;;;#+END:
                  <text &optional <session (<submit b:vscode:claude:submit?))
   " #+begin_org
** DocStr: Put <text in the input box of a local VS Code Claude session.
<session is a sessionId, \"new\" (a new conversation), or nil: this buffer's session --- the
one-shot b:vscode:claude:session:next, else b:vscode:claude:session/forBuffer, else the latest local
one. With <submit, Enter is pressed too (interactively: C-u flips b:vscode:claude:submit?). A thin
layer over =vscodeClaude.cs -i claudePrompt=, which holds all the logic. DISPLAY is Emacs's.
#+end_org "
  (interactive (list (read-string "Claude prompt: " nil 'b:vscode:claude:history)
                     nil
                     (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let* (($session (or <session
                       (prog1 b:vscode:claude:session:next (setq b:vscode:claude:session:next nil))
                       (b:vscode:claude:session/forBuffer)))
         ($args (append (when $session (list (concat "--session=" $session)))
                        (when <submit (list "--submit=yes"))
                        (list "-i" "claudePrompt" <text))))
    (apply #'b:vscode:program/runOrError b:vscode:claude:program b:vscode:claude:outBuffer $args)
    (message "Claude prompt %s%s: %s" (if <submit "submitted" "sent")
             (if $session (format " (%s)" $session) "") <text)
    $session))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Sends With Context" :extraInfo "@file:line, the region, the file, the error at point"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Sends With Context:* |]]  @file:line, the region, the file, the error at point  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:context/fileRef" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:context/fileRef>>  --  -- The @file:line (or @file:start-end) reference of point or the region.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:context/fileRef (
;;;#+END:
                  &optional <start <end)
   " #+begin_org
** DocStr: The @file:line (or @file:start-end) reference of point or the region.
nil when the buffer has no local file. Claude reads the file itself; as claude-code.el does.
#+end_org "
  (when (and buffer-file-name (not (file-remote-p buffer-file-name)))
    (let (($file (file-truename buffer-file-name))
          ($from (line-number-at-pos (or <start (point)) t))
          ($to (and <end (line-number-at-pos <end t))))
      (if (and $to (/= $to $from))
          (format "@%s:%d-%d" $file $from $to)
        (format "@%s:%d" $file $from)))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/sendWithContext" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/sendWithContext>>  --  -- Read a prompt and send it with the @file:line of point or the region.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/sendWithContext (
;;;#+END:
                  &optional <submit)
   " #+begin_org
** DocStr: Read a prompt and send it with the @file:line of point or the region.
#+end_org "
  (interactive (list (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let (($ref (if (use-region-p)
                  (b:vscode:claude:context/fileRef (region-beginning) (region-end))
                (b:vscode:claude:context/fileRef)))
        ($text (read-string "Claude prompt (with context): " nil 'b:vscode:claude:history)))
    (b:vscode:claude/atPrompt (if $ref (format "%s\n%s" $text $ref) $text) nil <submit)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/sendRegion" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/sendRegion>>  --  -- Send the region: as an @file:start-end reference, or its text when no file.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/sendRegion (
;;;#+END:
                  <start <end &optional <submit)
   " #+begin_org
** DocStr: Send the region: as an @file:start-end reference, or its text when no file.
Asks for an instruction to go with it (empty: none).
#+end_org "
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end)
                         (b:vscode:claude:submit/fromPrefix current-prefix-arg))
                 (user-error "No region")))
  (let (($ref (b:vscode:claude:context/fileRef <start <end))
        ($text (read-string "Instruction for the region (empty: none): " nil 'b:vscode:claude:history)))
    (b:vscode:claude/atPrompt
     (string-join (delq nil (list (unless (string-empty-p $text) $text)
                                  (or $ref (buffer-substring-no-properties <start <end))))
                  "\n")
     nil <submit)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/sendBufferFile" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/sendBufferFile>>  --  -- Send the @file reference of this buffer's file.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/sendBufferFile (
;;;#+END:
                  &optional <submit)
   " #+begin_org
** DocStr: Send the @file reference of this buffer's file.
#+end_org "
  (interactive (list (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (unless (and buffer-file-name (not (file-remote-p buffer-file-name)))
    (user-error "This buffer has no local file"))
  (b:vscode:claude/atPrompt (format "@%s" (file-truename buffer-file-name)) nil <submit))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:context/errorsAtPoint" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:context/errorsAtPoint>>  --  -- The flymake / flycheck messages at point, or nil.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:context/errorsAtPoint (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The flymake / flycheck messages at point, or nil.
#+end_org "
  (let (($msgs
         (append
          (when (and (bound-and-true-p flymake-mode) (fboundp 'flymake-diagnostics))
            (mapcar #'flymake-diagnostic-text (flymake-diagnostics (point))))
          (when (and (bound-and-true-p flycheck-mode) (fboundp 'flycheck-overlay-errors-at))
            (mapcar #'flycheck-error-message (flycheck-overlay-errors-at (point)))))))
    (when $msgs (string-join (delete-dups $msgs) "; "))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/fixErrorAtPoint" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/fixErrorAtPoint>>  --  -- Ask Claude to fix the flymake / flycheck error at point.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/fixErrorAtPoint (
;;;#+END:
                  &optional <submit)
   " #+begin_org
** DocStr: Ask Claude to fix the flymake / flycheck error at point.
#+end_org "
  (interactive (list (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let (($errors (b:vscode:claude:context/errorsAtPoint))
        ($ref (b:vscode:claude:context/fileRef)))
    (unless $errors
      (user-error "No flymake / flycheck error at point"))
    (b:vscode:claude/atPrompt
     (format "Fix this error at %s, using only the context of the message: <%s>"
             (or $ref "point") $errors)
     nil <submit)))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Claude Code Hooks" :extraInfo "Events from vscodeClaude.cs -i hookToEmacs"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Claude Code Hooks:* |]]  Events from vscodeClaude.cs -i hookToEmacs  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/hookHandle" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/hookHandle>>  --  -- Receive a Claude Code hook event (from vscodeClaude.cs -i hookToEmacs).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/hookHandle (
;;;#+END:
                  <type <json)
   " #+begin_org
** DocStr: Receive a Claude Code hook event (from vscodeClaude.cs -i hookToEmacs).
Runs b:vscode:claude:event-hook from a timer, so that emacsclient (and the hook, and the session)
returns at once. Returns \"handled\"; a malformed <json still runs the hook, with :data nil.
#+end_org "
  (let* (($data (ignore-errors (json-parse-string <json :object-type 'alist :null-object nil)))
         ($event (list :type <type
                       :session (alist-get 'session_id $data)
                       :cwd (alist-get 'cwd $data)
                       :data $data)))
    (run-at-time 0 nil
                 (lambda ()
                   (condition-case $err
                       (run-hook-with-args 'b:vscode:claude:event-hook $event)
                     (error (message "b:vscode:claude:event-hook: %s" (error-message-string $err))))))
    "handled"))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:hook/notification" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:hook/notification>>  --  -- On Notification: show Claude's message in Blee.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:hook/notification (
;;;#+END:
                  <event)
   " #+begin_org
** DocStr: On Notification: show Claude's message in Blee.
#+end_org "
  (when (equal (plist-get <event :type) "Notification")
    (message "VS Code Claude (%s): %s"
             (abbreviate-file-name (or (plist-get <event :cwd) "?"))
             (or (alist-get 'message (plist-get <event :data)) "waiting for you"))))

(add-hook 'b:vscode:claude:event-hook #'b:vscode:claude:hook/notification)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Transient" :extraInfo "b:vscode:claude/dispatch --- layer 5 adds its own entry"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Transient:* |]]  b:vscode:claude/dispatch --- layer 5 adds its own entry  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(with-eval-after-load 'transient
  (transient-define-prefix b:vscode:claude/dispatch ()
    "VS Code Claude, from Blee (vscode-claude layer 4). Prompts go to this buffer's session."
    [:description (lambda () (concat "VS Code Claude  " (b:vscode:claude:session/targetDescribe)))
     ["Send"
      ("s" "Prompt" b:vscode:claude/atPrompt)
      ("x" "Prompt with @file:line" b:vscode:claude/sendWithContext)
      ("r" "Region" b:vscode:claude/sendRegion)
      ("o" "This file (@file)" b:vscode:claude/sendBufferFile)
      ("e" "Fix error at point" b:vscode:claude/fixErrorAtPoint)]
     ["Session"
      ("c" "Choose session (C-u: this buffer)" b:vscode:claude/sessionSelect :transient t)
      ("F" "Forget the choice" b:vscode:claude/sessionForget :transient t)
      ("l" "Associations" b:vscode:claude/associationsShow)]
     ["VS Code"
      ("f" "Open this file in VS Code" b:vscode/fileOpen)
      ("p" "Partner: this Emacs (init)" b:vscode/init)
      ("P" "Partner: show" b:vscode/partnerShow)
      ("t" "Topology" b:vscode/topology)]
     ["Options"
      ("S" b:vscode:claude/submitToggle :transient t
       :description (lambda () (format "Submit (%s)" (if b:vscode:claude:submit? "on" "off"))))]]))

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
