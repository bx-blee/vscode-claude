;;; b:vscode-claude::pkg.el --- VS Code Claude Blee Package  -*- lexical-binding: t -*-


(require 'b:vscode)
(require 'b:vscode:claude)            ; layer 4
(require 'b:vscode:claude:aiActivity) ; layer 5
(require 'b:vscode:claude:menu)
(require 'dblock-vscode-claude)

(defgroup b:vscode-claude:: nil
  "VS Code Claude Package."
  :group 'convenience
  :prefix "b:vscode:")


(provide 'b:vscode-claude::pkg)
;;; b:vscode-claude::pkg.el ends here
