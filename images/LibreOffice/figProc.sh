#!/bin/bash

# typeset RcsId="$Id: figProc.sh,v 1.12 2018-12-09 07:34:54 lsipusr Exp $"

# if [ "${loadFiles}X" == "X" ] ; then
#   seedFigProc.sh -l $0 "$@"
#   exit $?
# fi

currentBase=`pwd`

####+BEGIN: bx:bisos:bash:seed-spec :types "/bisos/core/lcnt/bin/seedFigProc.sh"
SEED="
*  /[dblock]/ /Seed/ :: [[file:/bisos/core/lcnt/bin/seedFigProc.sh]] | 
"
FILE="
*  /This File/ :: /bxRepos/blee/vscode-claude/images/LibreOffice/figProc.sh 
"
if [ "${loadFiles}" == "" ] ; then
    /bisos/core/lcnt/bin/seedFigProc.sh -l $0 "$@" 
    exit $?
fi
####+END:


#  NOTYET  bx:dblock:lcnt:bash:figsList should have an :exclusionList

###+BEGIN: bx:dblock:lcnt:bash:figsList :types "odg"
filesList="
blee-aiActivity-layers.odg
"
####+END:

figsList="${filesList}"

FullfigsList="
${figsList}
"

####+BEGIN: bx:dblock:bash:end-of-file :types ""
_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  Common        ::  /[dblock] -- End-Of-File Controls/ [[elisp:(org-cycle)][| ]]
_CommentEnd_
#+STARTUP: showall
#local variables:
#major-mode: sh-mode
#fill-column: 90
# end:
####+END:
