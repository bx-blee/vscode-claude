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
The vscodeClaude layer, on top of b:vscode.el. The design is README.org; in short:
- Prompt in: b:vscode:claude/atPrompt puts a prompt (normally a /bx- command) in the input box of a
  local VS Code Claude session. The user presses Enter, unless submit is asked for
  (b:vscode:claude:submit?, C-u flips it; magit x x submits, x c does not).
- Which session: the one associated with the buffer's activity dir (walk-up), recorded by
  confirmRoot (and Claude's rootRegister callback) and confirmHere; else the one whose cwd covers the
  buffer; else the latest local one.
- Results back by file (.git/CLAUDE_COMMIT_MSG, offered in magit), by call (Claude runs emacsclient),
  and by Claude Code hooks (vscodeClaude.cs -i hookToEmacs calls b:vscode:claude/hookHandle, which runs
  b:vscode:claude:event-hook; the model is claude-code.el's claude-code-handle-hook).
All the logic that can be is in Python (bisos.aiActivity vscodeClaude.cs); elisp stays thin. The Emacs
layer is optional: VS Code alone is a complete AI-Activity.
* Relevant Panels:
** [[file:./README.org]] --- the design and documentation.
* Planned Improvements:
** TODO Stage 7: org command links in the b:ai:vscodeClaude/workflow dblock.
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
  "The CLI (bisos.aiActivity) that finds the local VS Code Claude sessions and prompts them.")

(defvar b:vscode:claude:outBuffer "*vscodeClaude*"
  "Buffer holding the last b:vscode:claude:program run's output (the commands it ran are on its stderr).")

(defvar b:vscode:claude:history nil
  "Minibuffer history of the prompts sent to VS Code Claude.")

(defvar b:vscode:claude:submit? nil
  "Non-nil: prompts are submitted (Enter pressed in VS Code). A C-u prefix flips it for one send.")

(defvar b:vscode:claude:associations nil
  "Alist of (activity dir . sessionId): which session a buffer under that dir prompts.
Recorded by confirmRoot / rootRegister and confirmHere. Dirs are true names ending in /.")

(defvar b:vscode:claude:commitMsg:requests nil
  "Alist of (repo . time) of /bx-git-commit-msg requests not yet seen fulfilled (by the Stop hook).")

(defvar b:vscode:claude:magit:commitMsg:pending nil
  "Path of the CLAUDE_COMMIT_MSG inserted into the commit buffer being edited, or nil.")

(defvar b:vscode:claude:event-hook nil
  "Abnormal hook run, from a timer, on each Claude Code hook event hookHandle receives.
Each function gets one plist: :type (\"Stop\", \"Notification\", ...), :session, :cwd, :data (the
event's JSON as an alist). Its return value is ignored.")

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Sessions And Associations" :extraInfo "Which session a buffer prompts"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Sessions And Associations:* |]]  Which session a buffer prompts  [[elisp:(org-shifttab)][<)]] E|
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
  (let* (($dir (b:vscode:claude:dir/canonical <dir))
         ($covering (seq-filter
                     (lambda ($s) (b:vscode:claude:dir/within?
                                   $dir (b:vscode:claude:dir/canonical (plist-get $s :cwd))))
                     (or <sessions (b:vscode:claude:sessions/running)))))
    ;; sessions/running is newest first and seq-sort is stable: deepest cwd, then newest.
    (car (seq-sort (lambda ($a $b) (> (length (plist-get $a :cwd)) (length (plist-get $b :cwd))))
                   $covering))))

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

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/associationsShow" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/associationsShow>>  --  -- Show the recorded associations: activity dir and session.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/associationsShow (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Show the recorded associations: activity dir and session.
#+end_org "
  (interactive)
  (with-current-buffer (get-buffer-create "*vscodeClaude associations*")
    (erase-buffer)
    (if (null b:vscode:claude:associations)
        (insert "No associations: b:vscode:claude/confirmRoot, then confirmHere.\n")
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
<session is a sessionId, \"new\" (a new conversation), or nil: the session of this buffer
(b:vscode:claude:session/forDir), else the latest local one. With <submit, Enter is pressed too
(interactively: C-u flips b:vscode:claude:submit?). A thin layer over =vscodeClaude.cs -i claudePrompt=,
which holds all the logic: a running session is brought to the front and the text pasted (xclip,
xdotool). DISPLAY is Emacs's.
#+end_org "
  (interactive (list (read-string "Claude prompt: " nil 'b:vscode:claude:history)
                     nil
                     (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let* (($session (or <session (b:vscode:claude:session/forDir default-directory)))
         ($args (append (when $session (list (concat "--session=" $session)))
                        (when <submit (list "--submit=yes"))
                        (list "-i" "claudePrompt" <text))))
    (apply #'b:vscode:program/runOrError b:vscode:claude:program b:vscode:claude:outBuffer $args)
    (message "Claude prompt %s%s: %s" (if <submit "submitted" "sent")
             (if $session (format " (%s)" $session) "") <text)
    $session))

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

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/bxSend" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/bxSend>>  --  -- Send the /bx-<name> command, with optional <args.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/bxSend (
;;;#+END:
                  <name &optional <args <submit)
   " #+begin_org
** DocStr: Send the /bx-<name> command, with optional <args.
#+end_org "
  (b:vscode:claude/atPrompt (string-join (delq nil (list (concat "/bx-" <name) <args)) " ") nil <submit))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Root And Here" :extraInfo "Confirming a session's AI-Activities, from Blee"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Root And Here:* |]]  Confirming a session's AI-Activities, from Blee  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/confirmRoot" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/confirmRoot>>  --  -- Confirm the root AI-Activity of the session covering this buffer.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/confirmRoot (
;;;#+END:
                  &optional <submit)
   " #+begin_org
** DocStr: Confirm the root AI-Activity of the session covering this buffer.
Sends /bx-confirm-root dir=<root> emacs=<socket> callback=yes to the session whose cwd covers this
buffer (the VS Code window's folder: the root). Claude checks it can reach this Emacs and calls back
b:vscode:claude/rootRegister with its session id; the association is recorded now too.
#+end_org "
  (interactive (list (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let* (($session (or (b:vscode:claude:session/covering default-directory)
                       (user-error "No running session has %s in its folder: open its root in VS Code"
                                   default-directory)))
         ($root (directory-file-name (b:vscode:claude:dir/canonical (plist-get $session :cwd))))
         ($id (plist-get $session :sessionId)))
    (b:vscode:claude:association/set $root $id)
    (b:vscode:claude/atPrompt
     (format "/bx-confirm-root dir=%s emacs=%s callback=yes" $root (b:vscode:partner/socket))
     $id <submit)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/rootRegister" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/rootRegister>>  --  -- Claude's callback of /bx-confirm-root: record <rootDir -> <sessionId.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/rootRegister (
;;;#+END:
                  <rootDir <sessionId)
   " #+begin_org
** DocStr: Claude's callback of /bx-confirm-root: record <rootDir -> <sessionId.
Called by Claude through emacsclient; returns a short confirmation string for it to report.
#+end_org "
  (b:vscode:claude:association/set <rootDir <sessionId)
  (message "VS Code Claude session %s registered for %s" <sessionId <rootDir)
  (format "registered %s %s" <rootDir <sessionId))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude/confirmHere" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude/confirmHere>>  --  -- Join this buffer's AI-Activity to its session: /bx-confirm-here <dir>.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude/confirmHere (
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
                  (user-error "No session for %s: b:vscode:claude/confirmRoot in a buffer of its root" $dir))))
    (b:vscode:claude:association/set $dir $id)
    (b:vscode:claude/atPrompt (format "/bx-confirm-here %s" $dir) $id <submit)))

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

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:magit:commitMsg/file" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:magit:commitMsg/file>>  --  -- The CLAUDE_COMMIT_MSG of <repo (in its git dir).  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:magit:commitMsg/file (
;;;#+END:
                  <repo)
   " #+begin_org
** DocStr: The CLAUDE_COMMIT_MSG of <repo (in its git dir).
#+end_org "
  (let ((default-directory (file-name-as-directory <repo)))
    (expand-file-name "CLAUDE_COMMIT_MSG"
                      (if (fboundp 'magit-gitdir) (magit-gitdir) (expand-file-name ".git")))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:hook/commitMsgReady" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:hook/commitMsgReady>>  --  -- On Stop: a requested commit message is written: raise magit there.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:hook/commitMsgReady (
;;;#+END:
                  <event)
   " #+begin_org
** DocStr: On Stop: a requested commit message is written: raise magit there.
For each /bx-git-commit-msg request (x c, x x) whose CLAUDE_COMMIT_MSG is newer than the request:
forget the request, show that repo's magit status in a raised frame, and say so.
#+end_org "
  (when (equal (plist-get <event :type) "Stop")
    (dolist ($req b:vscode:claude:commitMsg:requests)
      (let (($file (ignore-errors (b:vscode:claude:magit:commitMsg/file (car $req)))))
        (when (and $file (file-exists-p $file)
                   (time-less-p (cdr $req) (file-attribute-modification-time (file-attributes $file))))
          (setq b:vscode:claude:commitMsg:requests (delq $req b:vscode:claude:commitMsg:requests))
          (when (fboundp 'magit-status-setup-buffer)
            (magit-status-setup-buffer (car $req)))
          (let (($frame (selected-frame)))
            (raise-frame $frame)
            (select-frame-set-input-focus $frame))
          (message "Claude's commit message for %s is ready: c c" (car $req)))))))

(add-hook 'b:vscode:claude:event-hook #'b:vscode:claude:hook/notification)
(add-hook 'b:vscode:claude:event-hook #'b:vscode:claude:hook/commitMsgReady)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Magit: Claude's Commit Message" :extraInfo "x c asks Claude, x x also submits; c c offers .git/CLAUDE_COMMIT_MSG"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Magit: Claude's Commit Message:* |]]  x c asks Claude, x x also submits; c c offers .git/CLAUDE_COMMIT_MSG  [[elisp:(org-shifttab)][<)]] E|
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
x c: not submitted (press Enter in VS Code); x x: submitted. Then Claude writes the message; when the
Claude Code hooks are installed, its Stop raises magit here. c c, and
b:vscode:claude:magit:commitMsg/offer offers it. The repo is given as a path, so the session need not
be working in it.
#+end_org "
  (interactive (list (b:vscode:claude:submit/fromPrefix current-prefix-arg)))
  (let (($repo (magit-toplevel)))
    (unless $repo
      (user-error "Not in a git repository"))
    (unless (magit-anything-staged-p)
      (user-error "Nothing staged in %s" $repo))
    (setq $repo (directory-file-name $repo))
    (setf (alist-get $repo b:vscode:claude:commitMsg:requests nil nil #'string=) (current-time))
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

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Transients" :extraInfo "b:vscode:claude/dispatch, the magit x menu"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Transients:* |]]  b:vscode:claude/dispatch, the magit x menu  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(with-eval-after-load 'transient
  (transient-define-prefix b:vscode:claude:bx/dispatch ()
    "/bx- commands into this buffer's VS Code Claude session."
    [["Session"
      ("r" "/bx-confirm-root (+ register)" b:vscode:claude/confirmRoot)
      ("h" "/bx-confirm-here this activity" b:vscode:claude/confirmHere)
      ("s" "/bx-status-read" (lambda () (interactive) (b:vscode:claude/bxSend "status-read")))
      ("v" "/bx-session-verify" (lambda () (interactive) (b:vscode:claude/bxSend "session-verify")))]
     ["Record"
      ("u" "/bx-status-update" (lambda () (interactive) (b:vscode:claude/bxSend "status-update")))
      ("a" "/bx-archive-read" (lambda () (interactive) (b:vscode:claude/bxSend "archive-read")))
      ("A" "/bx-archive-update" (lambda () (interactive) (b:vscode:claude/bxSend "archive-update")))
      ("o" "/bx-ai-outputs" (lambda () (interactive) (b:vscode:claude/bxSend "ai-outputs")))]
     ["Git"
      ("g" "/bx-git-uncommitted-list" (lambda () (interactive) (b:vscode:claude/bxSend "git-uncommitted-list")))]])

  (transient-define-prefix b:vscode:claude/dispatch ()
    "VS Code Claude, from Blee (vscode-claude). Prompts go to this buffer's session."
    [["Send"
      ("s" "Prompt" b:vscode:claude/atPrompt)
      ("x" "Prompt with @file:line" b:vscode:claude/sendWithContext)
      ("r" "Region" b:vscode:claude/sendRegion)
      ("o" "This file (@file)" b:vscode:claude/sendBufferFile)
      ("e" "Fix error at point" b:vscode:claude/fixErrorAtPoint)
      ("/" "/bx- commands" b:vscode:claude:bx/dispatch)]
     ["Session"
      ("R" "Confirm root (register)" b:vscode:claude/confirmRoot)
      ("H" "Confirm here" b:vscode:claude/confirmHere)
      ("l" "Associations" b:vscode:claude/associationsShow)]
     ["VS Code"
      ("f" "Open this file in VS Code" b:vscode/fileOpen)
      ("p" "Partner: this Emacs (init)" b:vscode/init)
      ("P" "Partner: show" b:vscode/partnerShow)
      ("t" "Topology" b:vscode/topology)]
     ["Options"
      ("S" b:vscode:claude/submitToggle :transient t
       :description (lambda () (format "Submit (%s)" (if b:vscode:claude:submit? "on" "off"))))]]))

(with-eval-after-load 'magit
  (transient-define-prefix b:vscode:claude:magit/dispatch ()
    "Claude, in the local VS Code (vscodeClaude.cs)."
    ["Claude (this repo's VS Code session)"
     ("c" "Commit message for the staged changes (/bx-git-commit-msg)"
      b:vscode:claude:aiActivity/commitMsgGenerate)
     ("x" "Commit message, submitted"
      b:vscode:claude:aiActivity/commitMsgGenerateSubmit)
     ("d" "VS Code Claude menu" b:vscode:claude/dispatch)]))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:claude:magit|config" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:claude:magit|config>>  --  -- Hook Claude's commit message into magit: the commit hooks, x c and x x.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:claude:magit|config (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Hook Claude's commit message into magit: the commit hooks, x c and x x.
Run after magit is loaded (b:npa:vscode-claude:config|main does so).
#+end_org "
  ;;; Offer Claude's .git/CLAUDE_COMMIT_MSG (written by /bx-git-commit-msg) in an empty commit buffer.
  (add-hook 'git-commit-setup-hook #'b:vscode:claude:magit:commitMsg/offer t)
  (add-hook 'git-commit-post-finish-hook #'b:vscode:claude:magit:commitMsg/markUsed)
  ;;; x c / x x: ask this repo's VS Code Claude session for that message. x was magit-reset-quickly,
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
