(when (maybe-require-package 'projectile)
  (add-hook 'after-init-hook 'projectile-mode)

  (after-load 'projectile
    (setq projectile-indexing-method 'alien)
    (setq projectile-tags-command "c:/ctags/ctags.exe -Re -f \"%s\" %s")
    (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map)

    ;; Shorter modeline
    (setq-default
     projectile-mode-line
     '(:eval
       (if (file-remote-p default-directory)
           " Proj"
         (format " Proj[%s]" (projectile-project-name)))))))


(provide 'init-projectile)
