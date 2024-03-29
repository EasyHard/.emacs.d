(require-package 'haskell-mode)


;; Use intero for completion and flycheck

(after-load 'haskell-mode
  ;;(intero-global-mode)
  (add-hook 'haskell-mode-hook 'subword-mode)
  (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
  (add-hook 'haskell-mode-hook 'eldoc-mode))
(after-load 'haskell-cabal
  (add-hook 'haskell-cabal-mode 'subword-mode))


(add-auto-mode 'haskell-mode "\\.ghci\\'")
(custom-set-variables '(haskell-tags-on-save t))
(custom-set-variables '(haskell-process-type 'stack-ghci))

(setq haskell-process-args-ghci
      '("-ferror-spans" "-fshow-loaded-modules"))

(setq haskell-process-args-cabal-repl
      '("--ghc-options=-ferror-spans -fshow-loaded-modules"))

(setq haskell-process-args-stack-ghci
      '("--ghci-options=-ferror-spans -fshow-loaded-modules"
        "--no-build" "--no-load"))

(setq haskell-process-args-cabal-new-repl
      '("--ghc-options=-ferror-spans -fshow-loaded-modules"))


;; Indentation
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)



;; Source code helpers

(add-hook 'haskell-mode-hook 'haskell-auto-insert-module-template)

(when (maybe-require-package 'hindent)
  (add-hook 'haskell-mode-hook 'hindent-mode)
  (after-load 'hindent
    (when (require 'nadvice)
      (defun sanityinc/hindent--before-save-wrapper (oldfun &rest args)
        (with-demoted-errors "Error invoking hindent: %s"
          (let ((debug-on-error nil))
            (apply oldfun args))))
      (advice-add 'hindent--before-save :around 'sanityinc/hindent--before-save-wrapper))))

(after-load 'haskell-mode
  (define-key haskell-mode-map (kbd "C-c h") 'hoogle)
  (define-key haskell-mode-map (kbd "C-o") 'open-line))


(after-load 'page-break-lines
  (push 'haskell-mode page-break-lines-modes))



(define-minor-mode stack-exec-path-mode
  "If this is a stack project, set `exec-path' to the path \"stack exec\" would use."
  nil
  :lighter ""
  :global nil
  (if stack-exec-path-mode
      (when (and (executable-find "stack")
                 (locate-dominating-file default-directory "stack.yaml"))
        (setq-local
         exec-path
         (seq-uniq
          (append (list (concat (string-trim-right (shell-command-to-string "stack path --local-install-root")) "/bin"))
                  (parse-colon-path
                   (replace-regexp-in-string "[\r\n]+\\'" ""
                                             (shell-command-to-string "stack path --bin-path"))))
          'string-equal))
                                        ;(add-to-list (make-local-variable 'process-environment) (format "PATH=%s" (string-join exec-path path-separator)))
        )
    (kill-local-variable 'exec-path)))

(add-hook 'haskell-mode-hook 'stack-exec-path-mode)



(when (maybe-require-package 'dhall-mode)
  (add-hook 'dhall-mode-hook 'sanityinc/no-trailing-whitespace)
  (add-hook 'dhall-mode-hook 'stack-exec-path-mode))




(provide 'init-haskell)
