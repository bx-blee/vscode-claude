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

(defvar b:ai:workflow/driver:newStartPanel
  "/bisos/panels/bisos-core/bisos-pip/bisos.aiActivity/newStart/_nodeBase_"
  "The newStart panel (starting from scratch), opened by the driver's Info row.")

(defvar b:ai:workflow/driver:readmes
  '(("vscode-claude-README" . "/bisos/git/bxRepos/blee/vscode-claude/README.org")
    ("aiActivity-README" . "/bisos/git/bxRepos/bisos-pip/aiActivity/README.org"))
  "The READMEs of the driver's Info row: (label . file), this package's and bisos.aiActivity's.")

(defvar b:ai:workflow/driver:state:placeholder "(Refresh, on the Info line, shows the session)"
  "The text of the driver's State line in the file. Refresh shows the state over it, as an overlay.")

(defvar b:ai:workflow/driver:state:width 90
  "The most characters the state shows after \"State ::\", so the line stays within 105.")

(defvar b:ai:workflow/driver:labelWidth 9
  "The width the row labels are padded to: =newResume=, the longest.")

(defvar b:ai:workflow/driver:outputsRepo "/bxRepos/blee-binders/evolution"
  "The repo of AI-Outputs.org, which holds the pull lists: pulled first by the newResume row.
Under =/bxRepos/=, the same on every BISOS host, as =/bx-git-pull-list-add= writes its paths.")

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
             ;; A /bx- command: "<name>", or ("<name>" . "<label>") when the label says more.
             ($link (lambda (<cmnd &optional <submit)
                      (let (($name (if (consp <cmnd) (car <cmnd) <cmnd))
                            ($label (if (consp <cmnd) (cdr <cmnd) <cmnd)))
                        (format "[[aiActivity:%s%s][%s]]" (if <submit "S=" "") $name $label))))
             ($elisp (lambda (<form <label) (format "[[elisp:%s][%s]]" <form <label)))
             ;; Four kinds of action, each after its marker, always in this order:
             ;; |E| Emacs (elisp, or a shell command run from Blee), |V| VS Code, |P| a /bx- prompt
             ;; you complete and send, |S| the same prompt submitted. Each row:
             ;; (label :e links :v links :p commands :s commands :tail text).
             ;; Session: this session, at its Session-Root; Activity: the AI-Activities it reaches.
             ;; Git commits at any time; Close is the end of a session, in its order.
             ($rows
              `(("Info"
                 :e (,(funcall $elisp "(b:ai:workflow/driver/refresh)" "Refresh")
                     ,(funcall $elisp (format "(blee:bnsm:panel-goto \"%s\")"
                                              b:ai:workflow/driver:newStartPanel)
                               "Panel")
                     ,(funcall $elisp "(b:vscode:claude/dispatch)" "Transient")
                     ,(funcall $elisp "(b:vscode/partnerShow)" "partner-show")
                     ,@(mapcar (lambda (r) (format "[[file:%s][%s]]" (cdr r) (car r)))
                               b:ai:workflow/driver:readmes)))
                ;; Starting from scratch (bisos.aiActivity's newStart panel): setup is
                ;; vscodeClaude's CBM assemble, once per platform and idempotent; partner-init is
                ;; b:vscode/init (layer 3); session-start, in this buffer's home window (layer 5).
                ("newStart"
                 :e ("[[bashRun:vscodeClaude-assemble.cs -i fullCheck][setup-check]]"
                     "[[bashRun:vscodeClaude-assemble.cs -i fullUpdate][setup]]"
                     ,(funcall $elisp "(b:vscode/init)" "partner-init"))
                 :p ("session-start") :s ("session-start"))
                ;; The way back, VS Code to Blee, is a key in VS Code (vscode.cs -i vscodeBleeLinkInstall).
                ("VS Code"
                 :v (,(funcall $elisp "(b:vscode/fileOpen)" "Visit")
                     ,(funcall $elisp "(b:vscode/rootOpen)" "root-window"))
                 :tail "   <- Ctrl+K Ctrl+E: this file in Blee, at its line")
                ("Session"
                 :e (,(funcall $elisp "(b:vscode:claude/sessionSelect)" "select-session"))
                 :p ("session-start" "session-report") :s ("session-start"))
                ("Activity" :p ("activity-reach" "activity-report") :s ("activity-reach"))
                ;; ai-outputs: the ledger's index; as a prompt, with the defect typed after it, a capture.
                ("Read" :p ("status-read" "archive-read" "ai-outputs")
                 :s ("status-read" "archive-read" "ai-outputs"))
                ("Work" :p ("todo-do" "todo-done") :s ("todo-do" "todo-done"))
                ("Record" :p ("status-update" "archive-update" "context-trim")
                 :s ("status-update" "archive-update"))
                ("Git" :p ("git-uncommitted-list" "git-commit-msg")
                 :s ("git-uncommitted-list" "git-commit-msg"))
                ;; In this order: verify and skills-improve may change files, which the walk then
                ;; commits; the pull list needs the commits pushed. git-commit-walk always submits.
                ("Close" :p ("session-verify" "skills-improve")
                 :s ("git-commit-walk" "git-pull-list-add"))
                ;; Close's pull list, on the machine where the work continues (WorkPlan 7.5): the
                ;; repo of the pull lists first, then the latest list, the packages, then Claude's check.
                ("newResume"
                 :e (,(format "[[bashRun:git -C %s pull --rebase][outputs-pull]]"
                              b:ai:workflow/driver:outputsRepo)
                     ,(funcall $elisp "(b:ai:workflow/driver/pullListVisit)" "pull-list")
                     "[[bashRun:pipPkgsStatus.cs -i pkgsStatus][pipPkgsStatus]]")
                 :p ("newResume-confirm") :s ("newResume-confirm")))))
        (when $controls
          (insert (format "%s  [[elisp:(revert-buffer)][revert-buffer]] | " (make-string <outLevel ?*))
                  "[[elisp:(toggle-read-only)][read/wr]] | "
                  "[[elisp:(show-all)][Show-All]]  [[elisp:(org-shifttab)][Overview]]  "
                  "[[elisp:(progn (org-shifttab) (org-content))][Content]] | "
                  "[[elisp:(delete-other-windows)][(1)]] | "
                  "[[elisp:(progn (save-buffer) (kill-buffer))][S&Q]] [[elisp:(save-buffer)][Save]] "
                  "[[elisp:(kill-buffer)][Quit]] [[elisp:(bury-buffer)][Bury]] [[elisp:(magit)][Magit]]\n"))
        (insert (format "%s  [[elisp:(org-cycle)][AI Workflow Driver :: /bx- commands]]  --  %s\n"
                        (make-string <outLevel ?*)
                        "*|E|* Emacs  *|V|* VS Code  *|P|* prompt  *|S|* submitted"))
        ;; What changes from moment to moment is not written into the file: Refresh shows it over
        ;; this line (b:ai:workflow/driver/refresh), so the WorkPlan does not change.
        (insert (format "  %s :: %s\n" (string-pad "State" b:ai:workflow/driver:labelWidth)
                        b:ai:workflow/driver:state:placeholder))
        (dolist ($row $rows)
          (let* (($plist (cdr $row))
                 ($groups
                  (delq nil
                        (list
                         (when-let* (($e (plist-get $plist :e))) (concat "*|E|* " (string-join $e " | ")))
                         (when-let* (($v (plist-get $plist :v))) (concat "*|V|* " (string-join $v " | ")))
                         (when-let* (($p (plist-get $plist :p)))
                           (concat "*|P|* " (mapconcat $link $p " | ")))
                         (when-let* (($s (plist-get $plist :s)))
                           (concat "*|S|* " (mapconcat (lambda (c) (funcall $link c t)) $s " | ")))))))
            (insert (format "  %s :: %s%s\n" (string-pad (car $row) b:ai:workflow/driver:labelWidth)
                            (string-join $groups "  ")
                            (or (plist-get $plist :tail) "")))))))
    (defun outCommentPostContent ())

    (progn  ;; Actual Invocations
      (outCommentPreContent)
      (bx:invoke:withStdArgs$bx:dblock:governor:process)
      (outCommentPostContent)
      )))

;;; The earlier names, in WorkPlans written before Stage 7.
(defalias 'org-dblock-write:b:ai:vscodeClaude/workflow #'org-dblock-write:b:ai:workflow/driver)
(defalias 'org-dblock-write:b:ai:vscodeClaude/workflowDriver #'org-dblock-write:b:ai:workflow/driver)

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:ai:workflow/driver:state/text" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:ai:workflow/driver:state/text>>  --  -- The driver's state, for this buffer, now: the time, the session, the partner.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:ai:workflow/driver:state/text (
;;;#+END:
                  )
   " #+begin_org
** DocStr: The driver's state, for this buffer, now: the time, the session, the partner.
The session is where a prompt from this buffer would go, as the transient's title says it (layer 4,
=b:vscode:claude:session/targetDescribe=); the partner, from the partner file (layer 3), whether it
is this Emacs. Shortened to =b:ai:workflow/driver:state:width=.
#+end_org "
  (let* (($session (if (fboundp 'b:vscode:claude:session/targetDescribe)
                       (b:vscode:claude:session/targetDescribe)
                     "sessions unknown (b:vscode:claude not loaded)"))
         ($pid (and (fboundp 'b:vscode:partner/file)
                    (let (($file (b:vscode:partner/file)))
                      (and (file-exists-p $file)
                           (alist-get 'pid (ignore-errors
                                             (require 'json)
                                             (with-temp-buffer
                                               (insert-file-contents $file)
                                               (json-read))))))))
         ($partner (cond ((null $pid) "no partner")
                         ((eql $pid (emacs-pid)) "partner: this Emacs")
                         (t (format "partner: pid %s" $pid))))
         ($time (format-time-string "%Y-%m-%d %H:%M"))
         ($tail (concat "  --  " $partner)))
    ;; Only the session is shortened, so the time and the partner always show.
    (concat $time "  "
            (truncate-string-to-width
             $session (max 10 (- b:ai:workflow/driver:state:width (length $time) 2 (length $tail)))
             nil nil "…")
            $tail)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:ai:workflow/driver/refresh" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:ai:workflow/driver/refresh>>  --  -- Show the current state over each driver's State line in this buffer.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:ai:workflow/driver/refresh (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Show the current state over each driver's State line in this buffer.
An overlay, not text: its =display= shows the state in place of the placeholder, and the file and the
buffer's text are unchanged (no modification, nothing to save or commit). An earlier one is removed
first; one whose text the dblock rewrote goes by itself (=evaporate=). Returns the state shown, or nil
when the buffer has no State line.
#+end_org "
  (interactive)
  (remove-overlays (point-min) (point-max) 'b:ai:workflow/driver:state t)
  (let (($text (b:ai:workflow/driver:state/text))
        ($found nil))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              (concat "^  State *:: \\(" (regexp-quote b:ai:workflow/driver:state:placeholder) "\\)$")
              nil t)
        (let (($ov (make-overlay (match-beginning 1) (match-end 1) nil t nil)))
          (overlay-put $ov 'b:ai:workflow/driver:state t)
          (overlay-put $ov 'display $text)
          (overlay-put $ov 'help-echo "The state when Refresh was followed; not in the file")
          (overlay-put $ov 'evaporate t)
          (setq $found t))))
    (message (if $found "Driver state: %s" "No driver State line in this buffer") $text)
    (and $found $text)))

;;;#+BEGIN:  b:elisp:defs/cl-defun :defName "b:ai:workflow/driver/pullListVisit" :advice ()
(orgCmntBegin "
*  _[[elisp:(blee:menu-sel:outline:popupMenu)][±]]_ _[[elisp:(blee:menu-sel:navigation:popupMenu)][Ξ]]_ [[elisp:(outline-show-branches+toggle)][|=]] [[elisp:(bx:orgm:indirectBufOther)][|>]] *[[elisp:(blee:ppmm:org-mode-toggle)][|N]]*  cl-defun   [[elisp:(outline-show-subtree+toggle)][||]]  <<b:ai:workflow/driver/pullListVisit>>  --  -- Open AI-Outputs.org at the latest pull list still to pull.  [[elisp:(org-cycle)][| ]]
" orgCmntEnd)
(cl-defun b:ai:workflow/driver/pullListVisit (
;;;#+END:
                  )
   " #+begin_org
** DocStr: Open AI-Outputs.org at the latest pull list still to pull.
The pull lists are the \"Pull on other hosts\" entries that =/bx-git-pull-list-add= writes on Close;
this is the newResume row's =pull-list=. The AI-Outputs.org is this buffer's AI-Activity's (found
upward from its directory), as its true file. Point goes to the last entry still TODO, else to the last
\"Pull On Other Hosts\" section. Returns the file, or signals when there is none.
#+end_org "
  (interactive)
  (let* (($dir (or (locate-dominating-file default-directory "AI-Outputs.org")
                   (user-error "No AI-Outputs.org above %s" default-directory)))
         ($file (file-truename (expand-file-name "AI-Outputs.org" $dir))))
    (find-file $file)
    (widen)
    (goto-char (point-max))
    (cond ((re-search-backward "^\\*\\* TODO Pull on other hosts" nil t)
           (message "The latest pull list still to pull: \"All of them\" pulls them; DONE when pulled"))
          ((re-search-backward "^\\* Pull On Other Hosts" nil t)
           (message "No pull list still to pull; the latest is here"))
          (t (goto-char (point-min))
             (message "No pull list in %s" $file)))
    (when (derived-mode-p 'org-mode) (org-fold-show-context) (org-fold-show-subtree))
    (when (eq (window-buffer) (current-buffer)) (recenter 0))
    $file))


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
