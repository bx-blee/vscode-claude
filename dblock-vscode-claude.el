;;; dblock-vscode-claude.el --- Dblocks of the vscode-claude Blee package  -*- lexical-binding: t; -*-

(orgCmntBegin "
* Summary: Dblocks of the vscode-claude Blee package --- b:ai:workflow/driver.
" orgCmntEnd)

;;;#+BEGIN: b:prog:file/proclamations :copyLeft "libreHalaal"
(orgCmntBegin "
* *[[elisp:(org-cycle)][| Proclamations |]]* :: Libre-Halaal Software --- Part Of Blee ---  Poly-COMEEGA Format.
** This is Libre-Halaal Software. © Libre-Halaal Foundation. Subject to AGPL.
** It is not part of Emacs. It is part of Blee.
** Best read and edited  with Poly-COMEEGA (Polymode Colaborative Org-Mode Enhance Emacs Generalized Authorship)
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN: b:prog:file/particulars :authors ("./inserts/authors-mb.org")
(orgCmntBegin "
* *[[elisp:(org-cycle)][| Particulars |]]* :: This File, Authors, version
** This File: /bxRepos/blee/vscode-claude/dblock-vscode-claude.el
** File True Name: /bisos/git/auth/bxRepos/blee/vscode-claude/dblock-vscode-claude.el
** Authors: Mohsen BANAN, http://mohsen.banan.1.byname.net/contact
" orgCmntEnd)
;;;#+END:

(orgCmntBegin "
* /[[elisp:(org-cycle)][| Description |]]/ :: [[file:/bisos/git/auth/bxRepos/blee-binders/bisos-core/COMEEGA/_nodeBase_/fullUsagePanel-en.org][BISOS COMEEGA Panel]]
Dblocks for AI-WorkPlan.org and other AI-Activity files: b:ai:workflow/driver, rows of
aiActivity: links that send /bx- commands to VS Code Claude (WorkPlan Stage 7).
** Relevant Panels:
** Status: In use with blee3
** /[[elisp:(org-cycle)][| Planned Improvements |]]/ :
" orgCmntEnd)

;;;#+BEGIN: b:prog:file/orgTopControls :outLevel 1
(orgCmntBegin "
* [[elisp:(org-cycle)][| Controls |]] :: [[elisp:(delete-other-windows)][(1)]] | [[elisp:(show-all)][Show-All]]  [[elisp:(org-shifttab)][Overview]]  [[elisp:(progn (org-shifttab) (org-content))][Content]] | [[file:Panel.org][Panel]] | [[elisp:(blee:ppmm:org-mode-toggle)][Nat]] | [[elisp:(bx:org:run-me)][Run]] | [[elisp:(bx:org:run-me-eml)][RunEml]] | [[elisp:(progn (save-buffer) (kill-buffer))][S&Q]]  [[elisp:(save-buffer)][Save]]  [[elisp:(kill-buffer)][Quit]] [[elisp:(org-cycle)][| ]]
** /Version Control/ ::  [[elisp:(call-interactively (quote cvs-update))][cvs-update]]  [[elisp:(vc-update)][vc-update]] | [[elisp:(bx:org:agenda:this-file-otherWin)][Agenda-List]]  [[elisp:(bx:org:todo:this-file-otherWin)][ToDo-List]]

" orgCmntEnd)
;;;#+END:

;;;#+BEGIN: b:elisp:file/workbench :outLevel 1
(orgCmntBegin "
* [[elisp:(org-cycle)][| Workbench |]] :: [[elisp:(setq debug t)][debug-on-err]]  [[elisp:(setq  debug nil)][dont debug-on-err]] [[elisp:(org-cycle)][| ]]
** /Version Control/ ::  [[elisp:(call-interactively (quote cvs-update))][cvs-update]]  [[elisp:(vc-update)][vc-update]] | [[elisp:(bx:org:agenda:this-file-otherWin)][Agenda-List]]  [[elisp:(bx:org:todo:this-file-otherWin)][ToDo-List]]
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 0 :title "REQUIRES" :extraInfo "Imports"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*     [[elisp:(outline-show-subtree+toggle)][| _REQUIRES_: |]]  Imports  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

(require 'dblock-comeega-elisp)

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 1 :title "Variables And Constants" :extraInfo "defvar, defcustom"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*       [[elisp:(outline-show-subtree+toggle)][| *Variables And Constants:* |]]  defvar, defcustom  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN: blee:bxPanel:foldingSection :outLevel 0 :title "Dblock Functions" :extraInfo "org-dblock-write:"
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*     [[elisp:(outline-show-subtree+toggle)][| _Dblock Functions_: |]]  org-dblock-write:  [[elisp:(org-shifttab)][<)]] E|
" orgCmntEnd)
;;;#+END:

;;;#+BEGIN:  b:elisp:defs/dblockDefun :defName "org-dblock-write:b:ai:workflow/driver" :advice ("bx:dblock:control|wrapper")
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  dblockDfn  [[elisp:(outline-show-subtree+toggle)][||]]  <<org-dblock-write:b:ai:workflow/driver>> ~(bx:dblock:control|wrapper)~ --  --   [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(advice-add 'org-dblock-write:b:ai:workflow/driver :around #'bx:dblock:control|wrapper)
(defun org-dblock-write:b:ai:workflow/driver (<params)
;;;#+END:
   " #+begin_org
** [[elisp:(org-cycle)][| DocStr |]] The workflow driver of an AI-WorkPlan.org: rows of aiActivity: links.
Each link sends a /bx- command to this activity's VS Code Claude session (layer 5,
b:vscode:claude:aiActivity:link/follow); C-u C-c C-o on one flips submit. The seed WorkPlan
(aiTemplates-workFlow) carries the empty dblock; without Blee it stays inert.
#+end_org "
  (let* (
         (<governor (letGet$governor)) (<extGov (letGet$extGov))
         (<outLevel (letGet$outLevel 1)) (<model (letGet$model))
         (<style (letGet$style "openBlank" "closeBlank"))
         )
    (bxPanel:params$effective)

    (defun helpLine () ":controls nil (no control line)" )
    (defun outCommentPreContent ())
    (defun bodyContentPlus ())
    (defun bodyContent ()
      (let* (($controls (if (plist-member <params :controls) (plist-get <params :controls) t))
             ($link (lambda (<cmnd &optional <submit)
                      (format "[[aiActivity:%s%s][%s]]" (if <submit "S=" "") <cmnd <cmnd)))
             ;; Each row: its label, the commands, and those also offered submitted (after |S|).
             ($rows '(("Session" ("confirm-root" "confirm-here") ("confirm-root" "confirm-here"))
                      ("Read" ("status-read" "archive-read" "ai-outputs")
                       ("status-read" "archive-read" "ai-outputs"))
                      ("Work" ("todo-do" "todo-done") ("todo-do" "todo-done"))
                      ("Record" ("status-update" "archive-update") ("status-update" "archive-update"))
                      ;; git-commit-walk always submits.
                      ("Git" ("git-commit-msg" "git-commit-walk") ("git-commit-msg"))
                      ("Close" ("git-uncommitted-list" "session-verify")
                       ("git-uncommitted-list" "session-verify")))))
        (when $controls
          (insert (format "%s  [[elisp:(revert-buffer)][revert-buffer]] | " (make-string <outLevel ?*))
                  "[[elisp:(toggle-read-only)][read/wr]] | "
                  "[[elisp:(show-all)][Show-All]]  [[elisp:(org-shifttab)][Overview]]  "
                  "[[elisp:(progn (org-shifttab) (org-content))][Content]] | "
                  "[[elisp:(delete-other-windows)][(1)]] | "
                  "[[elisp:(progn (save-buffer) (kill-buffer))][S&Q]] [[elisp:(save-buffer)][Save]] "
                  "[[elisp:(kill-buffer)][Quit]] [[elisp:(bury-buffer)][Bury]] [[elisp:(magit)][Magit]]\n"))
        (insert (format "%s  [[elisp:(org-cycle)][AI Workflow Driver :: /bx- commands]]    *After |S|: submitted*\n"
                        (make-string <outLevel ?*)))
        (insert (format "  %-7s :: %s | %s\n" "VS Code"
                        "[[elisp:(b:vscode/fileOpen)][Visit]]"
                        "[[elisp:(b:vscode:claude/dispatch)][Transient]]"))
        (dolist ($row $rows)
          (let (($session (equal (car $row) "Session")))
            (insert (format "  %-7s :: %s%s%s\n" (car $row)
                            (if $session
                                "[[elisp:(b:vscode:claude/sessionSelect)][select-session]] | " "")
                            (mapconcat $link (nth 1 $row) " | ")
                            (if (nth 2 $row)
                                (concat "  *|S|*  "
                                        (mapconcat (lambda (c) (funcall $link c t)) (nth 2 $row) " | "))
                              "")))))))
    (defun outCommentPostContent ())

    (progn  ;; Actual Invocations
      (outCommentPreContent)
      (bx:invoke:withStdArgs$bx:dblock:governor:process)
      (outCommentPostContent)
      )))

;;; The earlier names, in WorkPlans written before Stage 7.
(defalias 'org-dblock-write:b:ai:vscodeClaude/workflow #'org-dblock-write:b:ai:workflow/driver)
(defalias 'org-dblock-write:b:ai:vscodeClaude/workflowDriver #'org-dblock-write:b:ai:workflow/driver)


;;;#+BEGIN: b:elisp:file/provide :modName nil
(provide 'dblock-vscode-claude)
;;;#+END:


;;;#+BEGINNOT: b:prog:file/endOfFile :extraParams nil
(orgCmntBegin "
* *[[elisp:(org-cycle)][| END-OF-FILE |]]* :: emacs and org variables and control parameters
" orgCmntEnd)
;;; local variables:
;;; no-byte-compile: t
;;; end:
;;;#+END:
