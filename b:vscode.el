;;; b:vscode.el --- Blee and VS Code: the vscode layer  -*- lexical-binding: t; -*-

(orgCmntBegin "
* Summary: Blee to VS Code, independent of Claude --- thin over vscode.cs.
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
The vscode layer: what Blee does with VS Code whether or not Claude is involved
(a running VS Code, its =code= CLI, its URIs). The logic lives in Python, in =vscode.cs=
(bisos.vscodeClaude, =vscode_csu=); this file only wraps it.
The Claude layer is b:vscode:claude.el, over =vscodeClaude.cs=, which builds on this one.
The partnership: b:vscode/init declares this Emacs the partner of the local VS Code (one to one) by
writing /bisos/var/blee/vscode/partner-<user>.json, read by vscode.cs (bleeOpenFile: VS Code to Emacs)
and vscodeClaude.cs (hookToEmacs: Claude Code hooks). Optional: VS Code alone needs none of it.
* Relevant Panels:
** [[file:./Emacs+VS-Code+Claude.org]] --- the design.
* Planned Improvements:
** TODO Menu entries for the vscode layer (WorkPlan 10.11).
" orgCmntEnd)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 0 :title "REQUIRES" :extraInfo "Imports"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*     [[elisp:(outline-show-subtree+toggle)][| _REQUIRES_: |]]  Imports  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(require 'blee-libs)
(require 'json)
(require 'seq)
(require 'subr-x)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Variables And Constants" :extraInfo "defvar, defcustom"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Variables And Constants:* |]]  defvar, defcustom  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(defvar b:vscode:program "vscode.cs"
  "The CLI (bisos.vscodeClaude) of the vscode layer: VS Code itself, and the partner Emacs.")

(defvar b:vscode:outBuffer "*vscode*"
  "Buffer holding the last b:vscode:program run's output.")

(defvar b:vscode:partner:dir "/bisos/var/blee/vscode"
  "Where b:vscode/init writes the partner file, partner-<user>.json (read by vscode_csu.partnerRead).")

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:program/run" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:program/run>>  --  -- Run <program with <args, output in <outBuffer; non-nil when it succeeded.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:program/run (
;;;#+END:
                              <program <outBuffer &rest <args)
   " #+begin_org
** DocStr: Run <program with <args, output in <outBuffer; non-nil when it succeeded.
Run locally from ~/ (also from a TRAMP buffer). A refused PyCS Cmnd still exits 0: its usage error
(EH_Problem) in the output counts as a failure. The runner of b:vscode.el and b:vscode:claude.el.
#+end_org "
  (let ((default-directory (expand-file-name "~/"))
        $status)
    (with-current-buffer (get-buffer-create <outBuffer)
      (erase-buffer))
    (setq $status (apply #'call-process <program nil <outBuffer nil <args))
    (and (eql $status 0)
         (not (with-current-buffer <outBuffer
                (save-excursion (goto-char (point-min)) (search-forward "EH_Problem" nil t)))))))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:program/runOrError" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:program/runOrError>>  --  -- Run <program as b:vscode:program/run; on failure show <outBuffer and signal.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:program/runOrError (
;;;#+END:
                                     <program <outBuffer &rest <args)
   " #+begin_org
** DocStr: Run <program as b:vscode:program/run; on failure show <outBuffer and signal a user-error.
Returns the output, without the framework's ALERT lines.
#+end_org "
  (unless (apply #'b:vscode:program/run <program <outBuffer <args)
    (display-buffer <outBuffer)
    (user-error "%s %s failed (see %s)" <program (string-join <args " ") <outBuffer))
  (with-current-buffer <outBuffer
    (string-join (seq-remove (lambda (l) (string-prefix-p "ALERT:" l))
                             (split-string (buffer-string) "\n" t))
                 "\n")))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Open In VS Code" :extraInfo "Files and folders, through vscode.cs"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Open In VS Code:* |]]  Files and folders, through vscode.cs  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode/fileOpen" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode/fileOpen>>  --  -- Open the current file in the local VS Code at point's line and column.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode/fileOpen (
;;;#+END:
                           )
   " #+begin_org
** DocStr: Open the current file in the local VS Code at point's line and column (vscodeOpenFile).
In dired, the file at point; in a buffer without a file, its directory as a folder (vscodeOpenFolder).
Remote (TRAMP) files are refused: VS Code here sees local paths only. Linux only, as Blee.
Symlinks are resolved (file-truename): VS Code's watcher reports changes by the real path, so a
tab opened through a link (/bxRepos/...) would not reload when Emacs saves the file.
Was xah-open-in-vscode (WorkPlan 10.2, 10.12).
#+end_org "
  (interactive)
  (let* (($file (cond (buffer-file-name buffer-file-name)
                      ((derived-mode-p 'dired-mode) (dired-get-file-for-visit))))
         ($target (or $file default-directory)))
    (when (file-remote-p $target)
      (user-error "Remote file: VS Code here opens local paths only (%s)" $target))
    (if (and $file (not (file-directory-p $file)))
        (b:vscode:program/runOrError
         b:vscode:program b:vscode:outBuffer "-i" "vscodeOpenFile" (file-truename $file)
         (number-to-string (line-number-at-pos nil t))
         (number-to-string (1+ (current-column))))
      (b:vscode:program/runOrError
       b:vscode:program b:vscode:outBuffer "-i" "vscodeOpenFolder" (file-truename $target)))
    (message "Opened in VS Code: %s" $target)))

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "The Partnership" :extraInfo "One Emacs, one VS Code: the partner file"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *The Partnership:* |]]  One Emacs, one VS Code: the partner file  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:partner/file" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:partner/file>>  --  -- The partner file of this user.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:partner/file (
;;;#+END:
                               )
   " #+begin_org
** DocStr: The partner file of this user: <b:vscode:partner:dir>/partner-<user>.json.
#+end_org "
  (expand-file-name (format "partner-%s.json" (user-login-name)) b:vscode:partner:dir))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:partner/socket" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:partner/socket>>  --  -- This Emacs's server socket, starting the server if needed.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:partner/socket (
;;;#+END:
                                 )
   " #+begin_org
** DocStr: This Emacs's server socket, starting the server if needed (Blee's naming, bf:server/ensure).
#+end_org "
  (require 'server)
  (unless (server-running-p)
    (if (fboundp 'bf:server/ensure) (bf:server/ensure) (server-start)))
  (expand-file-name server-name server-socket-dir))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode/init" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode/init>>  --  -- Declare this Emacs the partner of the local VS Code: write the partner file.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode/init (
;;;#+END:
                       )
   " #+begin_org
** DocStr: Declare this Emacs the partner of the local VS Code: write the partner file.
Its socket, pid, DISPLAY, time and Emacs version, for vscode.cs (bleeOpenFile, VS Code to Emacs) and
vscodeClaude.cs (hookToEmacs, Claude Code hooks). A partner Emacs already there is replaced: one to
one. Removed when this Emacs exits. Claude itself does not read it: a prompt names its Emacs.
#+end_org "
  (interactive)
  (let (($socket (b:vscode:partner/socket))
        ($file (b:vscode:partner/file)))
    (make-directory b:vscode:partner:dir t)
    (with-temp-file $file
      (insert (json-encode `((socket . ,$socket)
                             (pid . ,(emacs-pid))
                             (display . ,(or (getenv "DISPLAY") ""))
                             (time . ,(format-time-string "%FT%T%z"))
                             (emacsVersion . ,emacs-version))))
      (insert "\n"))
    (add-hook 'kill-emacs-hook #'b:vscode:partner/remove)
    (message "This Emacs is the VS Code partner: %s" $file)
    $file))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode:partner/remove" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode:partner/remove>>  --  -- Remove the partner file, if it is still this Emacs's.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode:partner/remove (
;;;#+END:
                                 )
   " #+begin_org
** DocStr: Remove the partner file, if it is still this Emacs's (on kill-emacs-hook).
#+end_org "
  (interactive)
  (let (($file (b:vscode:partner/file)))
    (when (and (file-exists-p $file)
               (eql (alist-get 'pid (ignore-errors
                                      (with-temp-buffer
                                        (insert-file-contents $file)
                                        (json-read))))
                    (emacs-pid)))
      (delete-file $file)
      t)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode/partnerShow" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode/partnerShow>>  --  -- Show the live partner Emacs, as vscode.cs sees it.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode/partnerShow (
;;;#+END:
                              )
   " #+begin_org
** DocStr: Show the live partner Emacs, as vscode.cs -i vscodePartner sees it.
#+end_org "
  (interactive)
  (message "%s" (b:vscode:program/runOrError b:vscode:program b:vscode:outBuffer "-i" "vscodePartner")))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:vscode/topology" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:vscode/topology>>  --  -- Can this Emacs reach a desktop VS Code? vscode.cs -i vscodeTopology.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:vscode/topology (
;;;#+END:
                           )
   " #+begin_org
** DocStr: Can this Emacs reach a desktop VS Code? Shows vscode.cs -i vscodeTopology's verdict.
#+end_org "
  (interactive)
  (b:vscode:program/runOrError b:vscode:program b:vscode:outBuffer "-i" "vscodeTopology")
  (display-buffer b:vscode:outBuffer))


;;;#+BEGIN: b:elisp:file/provide :modName nil
(provide 'b:vscode)
;;;#+END:

;;;#+BEGIN: b:elisp:file/endOf :outLevel 1
(orgCmntBegin "
* [[elisp:(show-all)][(>]] ~END-OF-FILE~  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;; local variables:
;;; no-byte-compile: t
;;; end:
;;;#+END:
