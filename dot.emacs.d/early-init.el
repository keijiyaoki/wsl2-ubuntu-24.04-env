;;; early-init.el --- My early-init.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq package-enable-at-startup nil ;; package.elを使用しない
      make-backup-files nil
      auto-save-default nil)

(push '(vertical-scroll-bars) default-frame-alist) ;; スクロールバー非表示
(push '(menu-bar-lines . 0) default-frame-alist) ;; メニューバー非表示
(push '(tool-bar-lines . 0) default-frame-alist) ;; ツールバー非表示

(provide 'eary-init)
;;; early-init.el ends here
