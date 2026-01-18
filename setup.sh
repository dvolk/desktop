set -x
set -e

#                   _
#  _ __   __ _  ___| | ____ _  __ _  ___  ___
# | '_ \ / _` |/ __| |/ / _` |/ _` |/ _ \/ __|
# | |_) | (_| | (__|   < (_| | (_| |  __/\__ \
# | .__/ \__,_|\___|_|\_\__,_|\__, |\___||___/
# |_|                         |___/
#

DEBIAN_FRONTEND=readline
export DEBIAN_FRONTEND

sudo apt update
sudo apt -y upgrade

sudo snap refresh

sudo apt -y install etckeeper
sudo etckeeper commit || true

# dev packages
sudo apt -y install build-essential autoconf automake g++ oathtool valgrind cloc cmake cmake-curses-gui strace pkg-config nodejs npm

# container packages
sudo apt -y install docker.io docker-compose libvirt-daemon-system

# image processing packages
sudo apt -y install imagemagick

# archive packages
sudo apt -y install p7zip unace unar unrar unzip zip xz-utils arj lzip lzop rar rzip unalz p7zip-rar

# misc packages
sudo apt -y install jq rsync git tmux htop iotop bmon powertop lsof ncdu aria2 bzip2 fzf parallel rdate sqlite3 tig tshark apt-file autojump bc curl dict-gcide dictd ranger smartmontools lshw m4 pwgen sshfs tree ufw w3m lynx wget whois ngrep rtorrent ncompress rpm2cpio ncal expect figlet screenfetch mutt bear

# python dev packages
sudo apt -y install python-is-python3 build-essential python3-pip python3-virtualenv python3-watchdog mypy python3-pylsp python3-pylsp-black python3-pylsp-jsonrpc black python3-pylsp-black python3-isort mypy python3-mypy python3-mypy-extensions python3-flake8 python3-rope python3-tqdm python3-tabulate

# desktop packages
sudo apt -y install gimp emacs osmo kiwix blender rawtherapee feh mpv fbreader zathura zathura-djvu obs-studio virt-manager transmission gthumb gnome-weather gnome-tweaks foliate gnome-epub-thumbnailer dosbox ffmpegthumbnailer innoextract obs-studio

# deps for cataclysmdda
sudo apt -y install libsdl2-gfx-1.0-0 libsdl2-image-2.0-0 libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0

# obsolete packages
# sudo apt install syncthing cpufrequtils transmission-daemon lnav clamav mutt openvpn tinc xdg-user-dirs screenfetch net-tools aptitude tlp apparmor apparmor-utils apparmor-profiles apparmor-profiles-extra snapd zenity auditd

#                   __ _                       _   _
#   ___ ___  _ __  / _(_) __ _ _   _ _ __ __ _| |_(_) ___  _ __
#  / __/ _ \| '_ \| |_| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \
# | (_| (_) | | | |  _| | (_| | |_| | | | (_| | |_| | (_) | | | |
#  \___\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|
#                        |___/

# bashrc
cat<<'EOF' > .bashrc
[[ $- != *i* ]] && return

export PROMPT_COMMAND='if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/stuff/logs/bash-history-$(date "+%Y-%m-%d").log; fi;'

if [ -f /usr/share/autojump/autojump.bash ]; then source /usr/share/autojump/autojump.bash; fi
if [ -f /etc/profile.d/autojump.bash ]; then source /etc/profile.d/autojump.bash; fi

alias h='cat ~/stuff/logs/*-history-* | grep -a'

bind 'set completion-ignore-case on'

alias dev='echo -e "\033]11;#000000\007"' # black term background
alias prod='echo -e "\033]11;#660000\007"' # red term background
alias git2ssh='git remote set-url origin "$(git remote get-url origin | sed -E "s#https?://([^/]+)/#git@\1:#")"' # convert github https remote to ssh

be() {
  pod=$(kubectl get pods --no-headers -o custom-columns=:metadata.name | fzf)
  container=$(kubectl get pod "$pod" -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n' | fzf)
  kubectl exec -it "$pod" -c "$container" -- bash
}
kn() {
  ns=$(kubectl get ns --no-headers -o custom-columns=:metadata.name | fzf)
  kubectl config set-context --current --namespace="$ns"
}

# add git info to prompt
source /usr/lib/git-core/git-sh-prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;33m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
EOF

# ssh config
mkdir -p .ssh
cat<<'EOF' > .ssh/config
Host *
    ControlMaster auto
    ControlPersist 1000h
    ControlPath ~/.ssh/%r@%h:%p

Host eclipse
    Hostname eclipse.oxfordfun.com
    Port 44444
    User ubuntu
    DynamicForward 3128
EOF

# git config
mkdir -p .git
cat<<'EOF' > ~/.git/config
[user]
    email = denis.volk@gmail.com
    name = Denis Volk
[credential]
    helper = store
EOF

# flake8 config
cat<<'EOF' > .config/flake8
[flake8]
max-line-length = 90
max-complexity = 10
EOF

# emacs config
mkdir -p .emacs.d
cat<<'EOF' > .emacs.d/init.el
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(setq package-selected-packages '(lsp-mode yasnippet yasnippet-snippets tree-sitter tree-sitter-langs lsp-treemacs helm-lsp magit diff-hl python-black projectile hydra flycheck company company-quickhelp which-key helm-xref rainbow-delimiters dap-mode yaml-mode json-mode jinja2-mode web-mode nim-mode color-identifiers-mode zoom-window astyle howm))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

(require 'tree-sitter)
(require 'tree-sitter-langs)

(menu-bar-mode 0)
(tool-bar-mode 0)
(tab-bar-mode 0)
(scroll-bar-mode 0)

(helm-mode)
(which-key-mode)
;;(global-visual-line-mode)
(xterm-mouse-mode)
(show-paren-mode)
(xterm-mouse-mode t)

(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-headerline-breadcrumb-enable t)

(windmove-default-keybindings)
(setq mouse-autoselect-window t)

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (yas-global-mode))

(global-set-key (kbd "C-d") 'avy-goto-char-timer)

;;(setq pos-tip-background-color "#000")

(global-set-key [mouse-4] (lambda () (interactive) (scroll-down 10)))
(global-set-key [mouse-5] (lambda () (interactive) (scroll-up 10)))
;;(global-set-key [mouse-8] (lambda () (interactive) (previous-buffer)))
;;(global-set-key [mouse-9] (lambda () (interactive) (next-buffer)))

(add-to-list 'auto-mode-alist '("\\.nf\\'" . groovy-mode))
(add-to-list 'auto-mode-alist '("\\.template\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.j2\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jinja2\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))

;;(setq pixel-scxroll-precision-large-scroll-height 40.0)
;;(setq pixel-scroll-precision-interpolation-factor 30)

;; Disable lockfiles.
(setq create-lockfiles nil)


(setq-default show-trailing-whitespace nil)
(setq-default indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'left)

;; Consider a period followed by a single space to be end of sentence.
(setq sentence-end-double-space nil)

;; Use spaces, not tabs, for indentation

(setq-default indent-tabs-mode nil)

;; Display the distance between two tab stops as 4 characters wide.
(setq-default tab-width 4)


;; Indentation setting for various languages.
(setq c-basic-offset 4)
(setq js-indent-level 2)
(setq css-indent-offset 2)

;; Highlight matching pairs of parentheses.
(setq show-paren-delay 0)


(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/.saves/"))    ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 31
 kept-old-versions 7
 version-control t)       ; use versioned backups

(defun my-before-save-hook ()
  (progn (if (not (string-match ".*makefile.*" (message "%s" major-mode)))
             (untabify (point-min) (point-max)))
         (delete-trailing-whitespace)))
(add-hook 'before-save-hook 'my-before-save-hook)

(setq rust-format-on-save t)

;; Go - lsp-mode
;; Set up before-save hooks to format buffer and add/delete imports.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)
;; Start LSP Mode and YASnippet mode
(add-hook 'go-mode-hook #'lsp-deferred)

(add-hook 'go-mode-hook #'yas-minor-mode)
(add-hook 'org-mode-hook #'flyspell-mode)

;; prog mode minor modes
(add-hook 'prog-mode-hook #'yas-minor-mode)
(add-hook 'prog-mode-hook #'lsp-deferred)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'diff-hl-mode)
(add-hook 'prog-mode-hook #'diff-hl-margin-mode)
(add-hook 'prog-mode-hook #'diff-hl-flydiff-mode)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook #'company-mode)
(add-hook 'prog-mode-hook #'company-quickhelp-mode)

(setq tool-bar-style 'image)

;; prog mode lang specific
(add-hook 'python-mode-hook #'python-black-on-save-mode)
(add-hook 'python-mode-hook #'tree-sitter-mode)

(add-hook 'nim-mode-hook 'nimsuggest-mode)

(add-hook 'yaml-mode-hook #'display-line-numbers-mode)
(add-hook 'yaml-mode-hook #'diff-hl-mode)
(add-hook 'yaml-mode-hook #'diff-hl-margin-mode)
(add-hook 'yaml-mode-hook #'diff-hl-flydiff-mode)
;;(add-hook 'org-mode-hook #'display-line-numbers-mode)
(add-hook 'org-mode-hook #'diff-hl-mode)
(add-hook 'org-mode-hook #'diff-hl-margin-mode)
(add-hook 'org-mode-hook #'diff-hl-flydiff-mode)


(setq rust-language-server 'rust-analyzer)
;; (setq browse-url-browser-function 'eww-browse-url)
(autoload 'ispell-get-word "ispell")

(global-set-key [f2] 'tab-previous)
(global-set-key [f3] 'tab-next)
(global-set-key [f4] 'switch-to-buffer)
(global-set-key [f5] 'treemacs)
(global-set-key [f7] 'treemacs)
(global-set-key [f6] 'magit)
(global-set-key [f9] 'lsp-find-definition)
(global-set-key [f12] 'color-identifiers-mode)
(global-set-key [(shift f5)] 'elfeed)
(global-set-key [(shift f9)] 'elfeed-update)
(global-set-key [(shift f12)] 'hide-mode-line-mode)
(global-set-key [(shift meta w)] 'delete-region)

(treemacs)
(global-visual-line-mode)
;;(lsp-treemacs-symbols)
;;(lsp-treemacs-errors-list)

;; (setq split-height-threshold nil)
;; (setq split-width-threshold 160)

(setq redisplay-dont-pause t)

;; Miscellaneous options
;(setq major-mode (lambda () ; guess major mode from file name
;                   (unless buffer-file-name
;                     (let ((buffer-file-name (buffer-name)))
;                       (set-auto-mode)))))


(setq inhibit-startup-screen t)
; (setq confirm-kill-emacs #'yes-or-no-p)
(setq window-resize-pixelwise t)
(setq frame-resize-pixelwise t)

(save-place-mode t)
(savehist-mode t)
(recentf-mode t)

(setq custom-file "~/.emacs.d/custom.el")
(load-file custom-file)

(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

(require 'zoom-window)
(global-set-key (kbd "C-x C-z") 'zoom-window-zoom)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

(add-hook 'c++-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'artistic-style-buffer nil 'local)))

;; remove lsp headerline/breadcrumbs
(setq lsp-headerline-breadcrumb-enable nil)
(remove-hook 'lsp-configure-hook 'lsp-headerline-breadcrumb-mode)

(desktop-save-mode 1)

(setq-default indicate-buffer-boundaries nil)

(set-fringe-mode 0)

;; todo add copilot.el

;; Configure howm mode
(require 'howm)
(setq howm-directory "~/stuff/howm/")
(setq howm-menu-lang 'en)
(global-set-key (kbd "C-c , ,") 'howm-menu)
EOF
touch .emacs.d/custom.el

# mpv config
mkdir -p .config
mkdir -p .config/mpv
cat<<'EOF' > .config/mpv/mpv.conf
screenshot-format=png
screenshot-directory="~/stuff/mpv-screenshots"
screenshot-template="%f_%P"
pulse-latency-hacks=yes
fs=yes
cache=yes

sub-auto=all
slang=en
alang=en,eng,ja,jp,jpn

gamma=10
#panscan=1
profile=high-quality

hr-seek=yes
#af=lavfi=[dynaudnorm=f=75:g=25:p=0.55]

af=lavfi="pan=stereo|c0=FC+LFE+FL+BL+SL|c1=FC+LFE+FR+BR+SR,loudnorm=I=-14:LRA=1:tp=-1:linear=false:dual_mono=true"
EOF

cat<<'EOF' > .config/mpv/input.conf
WHEEL_DOWN    seek -10         # seek 10 seconds backward
WHEEL_UP   seek 10          # seek 10 seconds forward
EOF

# ranger config (disable preview pane)

mkdir -p .config/ranger
cat<<'EOF' > .config/ranger/rc.conf
set column_ratios 2,1,10
set preview_directories false
set preview_files false
set preview_images false
set collapse_preview true
set padding_right false

set sort mtime
set sort_reverse false
EOF

#  _               _
# | |__   ___  ___| |_ ___
# | '_ \ / _ \/ __| __/ __|
# | | | | (_) \__ \ |_\__ \
# |_| |_|\___/|___/\__|___/
#
curl -o /tmp/hosts https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
#curl -o /tmp/hosts https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts
curl -o /tmp/mozilla-hosts https://raw.githubusercontent.com/MrRawes/firefox-hosts/firefox-hosts/hosts
curl -o /tmp/crypto-hosts https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt
curl -o /tmp/fedi.json https://nodes.fediverse.party/nodes.json
for fedi_node in $(cat /tmp/fedi.json | jq -r .[]); do echo 0.0.0.0 $fedi_node; done > /tmp/fedi.txt
# merge the bad hosts
{
    echo "# matomo web analytics"
    echo "0.0.0.0 cdn.matomo.cloud"
    echo "# block mozilla telemetry"
    cat /tmp/mozilla-hosts
    echo "# block crypto hosts"
    cat /tmp/crypto-hosts
    echo "# add localhost"
    echo "127.0.1.1 $(hostname)"
    echo "# fedi hosts"
    cat /tmp/fedi.txt
} >> /tmp/hosts

sed -i '/0.0.0.0 addons.mozilla.org/d' /tmp/hosts

sudo cp /tmp/hosts /etc/hosts

#            _
#  _ __ ___ (_)___  ___
# | '_ ` _ \| / __|/ __|
# | | | | | | \__ \ (__
# |_| |_| |_|_|___/\___|
#

# stuff/ hierarchy
mkdir -p stuff/code
mkdir -p stuff/mpv-screenshots
mkdir -p stuff/backups
mkdir -p stuff/logs
mkdir -p stuff/torrents
mkdir -p stuff/mongodb
mkdir -p stuff/images
mkdir -p stuff/org
mkdir -p stuff/howm

# file manager shortcuts
mkdir -p .config/gtk-3.0
cat <<EOF > .config/gtk-3.0/bookmarks
file:///home/ubuntu/Downloads
file:///home/ubuntu/Documents
file:///home/ubuntu/Pictures
file:///home/ubuntu/stuff
file:///home/ubuntu/stuff/code
file:///home/ubuntu/stuff/mpv-screenshots
file:///home/ubuntu/stuff/backups
file:///home/ubuntu/stuff/logs
file:///home/ubuntu/stuff/torrents
file:///home/ubuntu/stuff/mongodb
file:///home/ubuntu/stuff/images
file:///home/ubuntu/stuff/org
EOF

# add user to additional groups
{
    sudo adduser ubuntu docker
    sudo adduser ubuntu lxd
    sudo adduser ubuntu libvirt
} || true

#   __ _                        _ _
#  / _(_)_ __ _____      ____ _| | |
# | |_| | '__/ _ \ \ /\ / / _` | | |
# |  _| | | |  __/\ V  V / (_| | | |
# |_| |_|_|  \___| \_/\_/ \__,_|_|_|
#

sudo ufw default deny incoming
sudo ufw --force enable

sudo ufw logging on
sudo ufw allow in on lxdbr0
sudo ufw route allow in on lxdbr0
sudo ufw route allow out on lxdbr0

#   __ _           __
#  / _(_)_ __ ___ / _| _____  __
# | |_| | '__/ _ \ |_ / _ \ \/ /
# |  _| | | |  __/  _| (_) >  <
# |_| |_|_|  \___|_|  \___/_/\_\
#
#

mkdir -p .mozilla
mkdir -p .cache/mozilla

cat <<EOF > /tmp/home-ubuntu-.mozilla.mount
[Unit]
Description=Mount tmpfs on /home/ubuntu/.mozilla
DefaultDependencies=no
Requires=-.mount
After=-.mount

[Mount]
What=tmpfs
Where=/home/ubuntu/.mozilla
Type=tmpfs
Options=defaults,noatime,lazytime,nosuid,nodev,noexec,rw,size=256M

[Install]
WantedBy=local-fs.target
EOF

cat <<EOF > /tmp/home-ubuntu-.cache-mozilla.mount
[Unit]
Description=Mount tmpfs on /home/ubuntu/.cache/mozilla
DefaultDependencies=no
Requires=-.mount
After=-.mount

[Mount]
What=tmpfs
Where=/home/ubuntu/.cache/mozilla
Type=tmpfs
Options=defaults,noatime,lazytime,nosuid,nodev,noexec,rw,size=256M

[Install]
WantedBy=local-fs.target
EOF

sudo mv /tmp/home-ubuntu-.mozilla.mount /etc/systemd/system/home-ubuntu-.mozilla.mount
sudo mv /tmp/home-ubuntu-.cache-mozilla.mount /etc/systemd/system/home-ubuntu-.cache-mozilla.mount


# enable on >8gb ram systems
MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if [ "$MEM_KB" -ge 9000000 ]; then
    sudo systemctl daemon-reload
    sudo systemctl enable home-ubuntu-.mozilla.mount
    sudo systemctl enable home-ubuntu-.cache-mozilla.mount
    sudo systemctl start home-ubuntu-.mozilla.mount
    sudo systemctl start home-ubuntu-.cache-mozilla.mount
fi

cat <<EOF > /tmp/policies.json
{
    "policies": {
        "CaptivePortal": false,
        "DisableBuiltinPDFViewer": true,
        "DisableFirefoxAccounts": true,
        "DisableFirefoxStudies": true,
        "DisablePocket": true,
        "DisableProfileRefresh": true,
        "DisableTelemetry": true,
        "DisplayBookmarksToolbar": "never",
        "DontCheckDefaultBrowser": true,
        "DisableFeedbackCommands": true,
        "DisableFirefoxScreenshots": true,
        "FirefoxSuggest": {
            "WebSuggestions": false,
            "SponsoredSuggestions": false,
            "ImproveSuggest": false,
            "Locked": true
        },
        "FirefoxHome": {
            "Search": false,
            "TopSites": false,
            "SponsoredTopSites": false,
            "Highlights": false,
            "Pocket": false,
            "SponsoredPocket": false,
            "Snippets": false,
            "Locked": true
        },
        "DNSOverHTTPS": {
            "Enabled": true,
            "Locked": true,
            "Fallback": false
        },
        "Homepage": {
            "URL": "about:blank",
            "Locked": true,
            "StartPage": "none"
        },
        "NewTabPage": false,
        "NoDefaultBookmarks": true,
        "SearchSuggestEnabled": false,
        "ShowHomeButton": false,
        "UserMessaging": {
            "WhatsNew": false,
            "ExtensionRecommendations": false,
            "FeatureRecommendations": false,
            "UrlbarInterventions": false,
            "SkipOnboarding": true,
            "MoreFromMozilla": false
        },
        "OverrideFirstRunPage": "about:blank",
        "OverridePostUpdatePage": "about:blank",
        "ExtensionSettings": {
            "uBlock0@raymondhill.net": {
                "installation_mode": "force_installed",
                "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
                "default_area": "navbar",
                "private_browsing": true
            },
            "@testpilot-containers": {
                "installation_mode": "force_installed",
                "install_url": "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi",
                "default_area": "navbar"
            }
        },
        "Cookies": {
            "Behavior": "reject-tracker-and-partition-foreign"
        },
        "HttpsOnlyMode": "force_enabled",
        "AutofillAddressEnabled": false,
        "AutofillCreditCardEnabled": false,
        "DisableSetDesktopBackground": true,
        "DownloadDirectory": "${home}/Downloads",
        "PromptForDownloadLocation": false,
        "NoDefaultBookmarks": true,
         "Preferences":
         {
             "general.smoothScroll": { "Value": false, "Status": "locked" },
             "browser.altClickSave": { "Value": true, "Status": "locked" },
             "ui.key.menuAccessKeyFocuses": { "Value": false, "Status": "locked" },
             "dom.security.https_only_mode_ever_enabled": { "Value": true, "Status": "locked" },

             "toolkit.legacyUserProfileCustomizations.stylesheets": { "Value": true, "Status": "locked" },
             "layout.css.has-selector.enabled": { "Value": true, "Status": "locked" },

             "keyword.enabled": { "Value": false, "Status": "locked" },
             "browser.fixup.alternate.enabled": { "Value": false, "Status": "locked" },
             "browser.urlbar.suggest.searches": { "Value": false, "Status": "locked" },

             "browser.sessionstore.interval": { "Value": 3600000, "Status": "locked" },

             "privacy.globalprivacycontrol.enabled": { "Value": true, "Status": "locked" },
             "privacy.donottrackheader.enabled": { "Value": true, "Status": "locked" },

             "network.dns.native_https_query": { "Value": true, "Status": "locked" },

             "widget.non-native-theme.scrollbar.size.override": { "Value": 30, "Status": "locked" }
         },
         "Bookmarks": [
             {"Title": "Archwiki: Window manager", "URL": "https://wiki.archlinux.org/title/Window_manager", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "List of Window Managers", "URL": "https://www.gilesorr.com/wm/table.html", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "i3", "URL": "https://i3wm.org/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "ratposion", "URL": "https://ratpoison.nongnu.org/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "XFCE", "URL": "https://xfce.org/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "fvwm", "URL": "https://www.fvwm.org/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "IceWM", "URL": "https://ice-wm.org/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "wm2", "URL": "https://www.all-day-breakfast.com/wm2/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "bspwm", "URL": "https://github.com/baskerville/bspwm", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "stumpwm", "URL": "https://stumpwm.github.io/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "exwm", "URL": "https://github.com/emacs-exwm/exwm", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "rio", "URL": "https://9fans.github.io/plan9port/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "treewm", "URL": "https://treewm.sourceforge.net/", "Placement": "menu", "Folder": "X11 Window managers/desktops"},
             {"Title": "Archwiki: Wayland", "URL": "https://wiki.archlinux.org/title/Wayland", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "gnome", "URL": "https://www.gnome.org/", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "KDE", "URL": "https://kde.org/", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "swaywm", "URL": "https://swaywm.org/", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "swayfx", "URL": "https://github.com/WillPower3309/swayfx", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "sxmo", "URL": "https://sxmo.org/", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "niri", "URL": "https://github.com/YaLTeR/niri/", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "cagebreak", "URL": "https://github.com/project-repo/cagebreak", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "wio", "URL": "https://gitlab.com/Rubo/wio", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "hyprland", "URL": "https://github.com/hyprwm/hyprland", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "hy3", "URL": "https://github.com/outfoxxed/hy3", "Placement": "menu", "Folder": "Wayland window managers/desktops"},
             {"Title": "bazzite", "URL": "https://github.com/ublue-os/bazzite", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "yay", "URL": "https://github.com/Jguer/yay", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Visidata", "URL": "https://www.visidata.org/docs/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Emacs", "URL": "https://www.gnu.org/software/emacs/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Git", "URL": "https://git-scm.com/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Rawtherappe", "URL": "https://www.rawtherapee.com/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "OBS", "URL": "https://obsproject.com/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Nodejs", "URL": "https://nodejs.org/en/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Chromium policies", "URL": "https://chromium.googlesource.com/chromium/chromium/+/master/chrome/app/policy/policy_templates.json", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Firefox policies", "URL": "https://mozilla.github.io/policy-templates/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Nim watchdog", "URL": "https://github.com/zendbit/nim.nwatchdog", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "sysz", "URL": "https://github.com/joehillen/sysz", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Zenity", "URL": "https://help.gnome.org/users/zenity/stable/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Virtualbox", "URL": "https://www.virtualbox.org/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Kitty terminal", "URL": "https://github.com/kovidgoyal/kitty", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "List of OSS software", "URL": "https://en.wikipedia.org/wiki/List_of_free_and_open-source_software_packages", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Calibre", "URL": "https://calibre-ebook.com/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Koreader", "URL": "https://koreader.rocks/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "sqlite-utils", "URL": "https://sqlite-utils.datasette.io/en/stable/index.html", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Nyxt browser", "URL": "https://nyxt.atlas.engineer/download", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "LibreWolf browser", "URL": "https://librewolf.net/installation/linux/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Godot", "URL": "https://godotengine.org/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "osquery", "URL": "https://osquery.io/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "List of open source games", "URL": "https://trilarion.github.io/opensourcegames/index.html", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "TMSU", "URL": "https://github.com/oniony/TMSU", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Manuskript", "URL": "https://www.theologeek.ch/manuskript/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "ladybird browser", "URL": "https://github.com/SerenityOS/serenity/blob/master/Documentation/BuildInstructionsLadybird.md", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "Chicago95", "URL": "https://github.com/grassmunk/Chicago95", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "yt-ldp", "URL": "https://github.com/yt-dlp/yt-dlp", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "OpenCodeInterpreter", "URL": "https://github.com/OpenCodeInterpreter/OpenCodeInterpreter", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "rlwrap", "URL": "https://github.com/hanslub42/rlwrap", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "firefox docs", "URL": "https://firefox-source-docs.mozilla.org/browser/urlbar/nontechnical-overview.html", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "flatpak docs", "URL": "https://docs.flatpak.org", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "snap docs", "URL": "https://snapcraft.io/docs", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "jq docs", "URL": "https://jqlang.github.io/jq/", "Placement": "menu", "Folder": "Desktop Software"},
             {"Title": "O'Reilly", "URL": "https://www.oreilly.com/products/books-videos.html", "Placement": "menu", "Folder": "Publishers"},
             {"Title": "Springer Science and Fiction", "URL": "https://www.springer.com/series/11657", "Placement": "menu", "Folder": "Publishers"},
             {"Title": "DuckDB", "URL": "https://duckdb.org", "Placement": "menu", "Folder": "Databases"},
             {"Title": "SQLite", "URL": "https://sqlite.org", "Placement": "menu", "Folder": "Databases"},
             {"Title": "MongoDB", "URL": "https://mongodb.com", "Placement": "menu", "Folder": "Databases"},
             {"Title": "MySQL", "URL": "https://www.mysql.com", "Placement": "menu", "Folder": "Databases"},
             {"Title": "PostgreSQL", "URL": "https://postgresql.org", "Placement": "menu", "Folder": "Databases"},
             {"Title": "Gitea", "URL": "https://gitea.io/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Mongo", "URL": "https://www.mongodb.com/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Focal board", "URL": "https://www.focalboard.com/download/personal-edition/ubuntu/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Filebrowser", "URL": "https://filebrowser.org/features", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Fossil", "URL": "https://fossil-scm.org/home/doc/trunk/www/index.wiki", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Jupyter book", "URL": "https://github.com/executablebooks/jupyter-book", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "FreshRSS", "URL": "https://github.com/FreshRSS/FreshRSS", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "The Lounge", "URL": "https://thelounge.chat/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Nimforum", "URL": "https://github.com/nim-lang/nimforum", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Cockpit project", "URL": "https://cockpit-project.org/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Cockpit localhost", "URL": "http://localhost:9090/system", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Portainer", "URL": "https://docs.portainer.io/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Docker swarm", "URL": "https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Loqseq", "URL": "https://github.com/logseq/logseq", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Authentik", "URL": "https://goauthentik.io/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "noVNC", "URL": "https://github.com/novnc/noVNC", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "virtualGL", "URL": "https://www.virtualgl.org/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "TigerVNC", "URL": "https://tigervnc.org/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "TurboVNC", "URL": "https://turbovnc.org/DeveloperInfo/CodeAccess", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Caddy", "URL": "https://caddyserver.com/docs/", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "x2go", "URL": "https://wiki.x2go.org/doku.php/start", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "Nextcloud", "URL": "https://docs.nextcloud.com/server/latest/admin_manual/contents.html#", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "graphic-walker", "URL": "https://github.com/Kanaries/graphic-walker", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "sr.ht", "URL": "https://sr.ht", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "sentry.io", "URL": "https://sentry.io", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "goatcounter", "URL": "https://github.com/arp242/goatcounter", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "gotty", "URL": "https://github.com/yudai/gotty", "Placement": "menu", "Folder": "Self-hosted server software"},
             {"Title": "i3 configurator", "URL": "https://thomashunter.name/i3-configurator/", "Placement": "menu", "Folder": "Free SaaS"},
             {"Title": "nominatim", "URL": "https://nominatim.org/", "Placement": "menu", "Folder": "Free SaaS"},
             {"Title": "elisp basics", "URL": "http://xahlee.info/emacs/emacs/elisp_basics.html", "Placement": "menu", "Folder": "Emacs"},
             {"Title": "elisp guide", "URL": "https://github.com/chrisdone-archive/elisp-guide?tab=readme-ov-file", "Placement": "menu", "Folder": "Emacs"},
             {"Title": "An Introduction to Programming in Emacs Lisp", "URL": "https://www.gnu.org/software/emacs/manual/html_node/eintr/", "Placement": "menu", "Folder": "Emacs"},
             {"Title": "Emacs: modern minibuffer packages", "URL": "https://protesilaos.com/codelog/2024-02-17-emacs-modern-minibuffer-packages/", "Placement": "menu", "Folder": "Emacs"},
             {"Title": "The Emacs window management almanac", "URL": "https://karthinks.com/software/emacs-window-management-almanac/", "Placement": "menu", "Folder": "Emacs"},
             {"Title": "Nov", "URL": "https://depp.brause.cc/nov.el/", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "avy", "URL": "https://github.com/abo-abo/avy", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "company", "URL": "http://company-mode.github.io/", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "company quickhelp", "URL": "https://www.github.com/expez/company-quickhelp", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "diff-hl", "URL": "https://github.com/dgutov/diff-hl", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "elfeed ", "URL": "https://github.com/skeeto/elfeed", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "flycheck", "URL": "http://www.flycheck.org", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "focus-mode", "URL": "https://github.com/larstvei/Focus", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "magit", "URL": "https://github.com/magit/magit", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "projectile", "URL": "https://github.com/bbatsov/projectile", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "twilight-bright-theme", "URL": "https://github.com/jimeh/twilight-bright-theme.el", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "twilight-anti-bright-theme", "URL": "https://github.com/jimeh/twilight-anti-bright-theme.el", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "web-mode", "URL": "https://web-mode.org", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "osm", "URL": "https://github.com/minad/osm", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "treemacs", "URL": "https://github.com/Alexander-Miller/treemacs", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "org-mode", "URL": "https://orgmode.org/", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "org-present", "URL": "https://github.com/rlister/org-present", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "emacs themes", "URL": "https://emacsthemes.com/", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "workgroups2", "URL": "https://github.com/pashinin/workgroups2", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "ef-themes", "URL": "https://github.com/protesilaos/ef-themes", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "exotica theme", "URL": "https://github.com/zenobht/exotica-theme", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "catppuccin theme", "URL": "https://github.com/catppuccin/emacs", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "tree-sitter", "URL": "https://emacs-tree-sitter.github.io/installation/", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "color-identifiers-mode", "URL": "https://github.com/ankurdave/color-identifiers-mode", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "howm", "URL": "https://kaorahi.github.io/howm/", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "denote", "URL": "https://protesilaos.com/emacs/denote", "Placement": "menu", "Folder": "Emacs packages"},
             {"Title": "neovim", "URL": "https://neovim.io/", "Placement": "menu", "Folder": "Other editors"},
             {"Title": "lunarvim", "URL": "https://www.lunarvim.org/", "Placement": "menu", "Folder": "Other editors"},
             {"Title": "VSCodium", "URL": "https://vscodium.com/", "Placement": "menu", "Folder": "Other editors"},
             {"Title": "Github", "URL": "https://github.com/", "Placement": "menu", "Folder": "Software hosting"},
             {"Title": "Gitlab", "URL": "https://about.gitlab.com/", "Placement": "menu", "Folder": "Software hosting"},
             {"Title": "Gitee", "URL": "https://gitee.com/", "Placement": "menu", "Folder": "Software hosting"},
             {"Title": "GNOME gitlab", "URL": "https://gitlab.gnome.org/", "Placement": "menu", "Folder": "Software hosting"},
             {"Title": "MELPA", "URL": "https://github.com/melpa/melpa", "Placement": "menu", "Folder": "Software hosting"},
             {"Title": "ELPA", "URL": "https://elpa.gnu.org/", "Placement": "menu", "Folder": "Software hosting"},
             {"Title": "UPBGE", "URL": "https://upbge.org", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "GodotOS", "URL": "https://github.com/popcar2/GodotOS", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "COGITO", "URL": "https://github.com/Phazorknight/Cogito", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "Nico", "URL": "https://github.com/ftsf/nico", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "nimgame2", "URL": "https://github.com/Vladar4/nimgame2", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "tecs", "URL": "https://github.com/Timofffee/tecs.nim", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "SDL scancodes", "URL": "https://wiki.libsdl.org/SDL2/SDL_Scancode", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "bullet3", "URL": "https://github.com/bulletphysics/bullet3", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "glm", "URL": "https://github.com/g-truc/glm", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "imgui", "URL": "https://github.com/ocornut/imgui", "Placement": "menu", "Folder": "Game dev"},
             {"Title": "zxcvbn-python", "URL": "https://github.com/dwolfhub/zxcvbn-python", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "pygame", "URL": "https://www.pygame.org", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "pathlib", "URL": "https://docs.python.org/3/library/pathlib.html", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "SUDS (SOAP)", "URL": "https://github.com/suds-community/suds", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Flask", "URL": "https://flask.palletsprojects.com/en/2.1.x/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "BeautifulSoup", "URL": "https://www.crummy.com/software/BeautifulSoup/bs4/doc/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Selenium", "URL": "https://selenium-python.readthedocs.io/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Redmail", "URL": "https://pypi.org/project/redmail/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Matlab", "URL": "https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Pydantic", "URL": "https://pydantic-docs.helpmanual.io/usage/models/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Eel", "URL": "https://github.com/ChrisKnott/Eel", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Watchdog", "URL": "https://github.com/gorakhargosh/watchdog", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Qiskit", "URL": "https://qiskit.org/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Celery (with filesystem)", "URL": "https://www.distributedpython.com/2018/07/03/simple-celery-setup/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "psycopg-binary", "URL": "https://pypi.org/project/psycopg2-binary/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "pykube", "URL": "https://pykube.readthedocs.io/en/latest/index.html", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "minikube", "URL": "https://minikube.sigs.k8s.io/docs/start/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Django docs", "URL": "https://docs.djangoproject.com/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "pyotp", "URL": "https://pyauth.github.io/pyotp/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "python-control", "URL": "https://python-control.readthedocs.io/en/0.9.3.post2/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "itsdangerous", "URL": "https://itsdangerous.palletsprojects.com/", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "prettymaps", "URL": "https://github.com/marceloprates/prettymaps", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "pygis", "URL": "https://pygis.io/docs/a_intro.html", "Placement": "menu", "Folder": "Python libraries"},
             {"Title": "Carbon", "URL": "https://github.com/carbon-language/carbon-lang", "Placement": "menu", "Folder": "Programming languages"},
             {"Title": "scientifica", "URL": "https://github.com/nerdypepper/scientifica", "Placement": "menu", "Folder": "Fonts"},
             {"Title": "Roboto", "URL": "https://fonts.google.com/specimen/Roboto", "Placement": "menu", "Folder": "Fonts"},
             {"Title": "Nim for Python Programmers", "URL": "https://github.com/nim-lang/Nim/wiki/Nim-for-Python-Programmers", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "Print", "URL": "https://github.com/treeform/print", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "Neel", "URL": "https://github.com/Niminem/Neel", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "nimdow", "URL": "https://github.com/avahe-kellenberger/nimdow", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "moe", "URL": "https://github.com/fox0430/moe", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "Curated packages", "URL": "https://github.com/nim-lang/Nim/wiki/Curated-Packages", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "prologue", "URL": "https://github.com/planety/prologue", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "nimpylib", "URL": "https://github.com/Yardanico/nimpylib", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "Arraymancer", "URL": "https://github.com/mratsim/Arraymancer", "Placement": "menu", "Folder": "Nim libraries"},
             {"Title": "Standard library", "URL": "https://doc.rust-lang.org/nightly/std/index.html", "Placement": "menu", "Folder": "Rust libraries"},
             {"Title": "Bevy", "URL": "https://github.com/bevyengine/bevy", "Placement": "menu", "Folder": "Rust libraries"},
             {"Title": "Go standard library", "URL": "https://pkg.go.dev/std", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go by example", "URL": "https://gobyexample.com/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go web examples", "URL": "https://gowebexamples.com/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go web middleware", "URL": "https://gowebexamples.com/advanced-middleware/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go slices", "URL": "https://go.dev/blog/slices-intro", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go interfaces", "URL": "https://jordanorelli.com/post/32665860244/how-to-use-interfaces-in-go", "Placement": "menu", "Folder": "Golang"},
             {"Title": "How to use interfaces in Go", "URL": "https://jordanorelli.com/post/32665860244/how-to-use-interfaces-in-go", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go style guide", "URL": "https://google.github.io/styleguide/go/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Google open source - go", "URL": "https://cs.opensource.google/go", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go table-driven tests", "URL": "https://go.dev/wiki/TableDrivenTests", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Effective Go", "URL": "https://go.dev/doc/effective_go", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Best go books", "URL": "https://www.reddit.com/r/golang/comments/11hd310/what_would_be_the_best_golang_book_to_read_in/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go spec", "URL": "https://go.dev/ref/spec", "Placement": "menu", "Folder": "Golang"},
             {"Title": "learnxinyminutes go", "URL": "https://learnxinyminutes.com/docs/go/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Tour of Go", "URL": "https://go.dev/tour", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go blog", "URL": "https://go.dev/blog/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go sql drivers", "URL": "https://go.dev/wiki/SQLDrivers", "Placement": "menu", "Folder": "Golang"},
             {"Title": "gopherconAU", "URL": "https://www.youtube.com/@gopherconau/videos", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Go download", "URL": "https://go.dev/dl/", "Placement": "menu", "Folder": "Golang"},
             {"Title": "gopls", "URL": "https://github.com/golang/tools/blob/master/gopls/README.md", "Placement": "menu", "Folder": "Golang"},
             {"Title": "Awesome Go", "URL": "https://github.com/avelino/awesome-go", "Placement": "menu", "Folder": "Golang libraries"},
             {"Title": "GORM", "URL": "https://gorm.io/index.html", "Placement": "menu", "Folder": "Golang libraries"},
             {"Title": "Ent", "URL": "https://entgo.io/docs/getting-started/", "Placement": "menu", "Folder": "Golang libraries"},
             {"Title": "Pagoda", "URL": "https://github.com/mikestefanello/pagoda", "Placement": "menu", "Folder": "Golang libraries"},
             {"Title": "Chi", "URL": "https://github.com/go-chi/chi", "Placement": "menu", "Folder": "Golang libraries"},
             {"Title": "LOVE", "URL": "https://love2d.org/", "Placement": "menu", "Folder": "Lua libraries"},
             {"Title": "desktop", "URL": "https://github.com/dvolk/desktop", "Placement": "menu", "Folder": "Mine common software"},
             {"Title": "bunk", "URL": "https://github.com/dvolk/bunk", "Placement": "menu", "Folder": "Mine common software"},
             {"Title": "ada2025", "URL": "https://github.com/dvolk/ada2025", "Placement": "menu", "Folder": "Mine common software"},
             {"Title": "sp3", "URL": "https://github.com/dvolk/sp3", "Placement": "menu", "Folder": "Mine common software"},
             {"Title": "shawl5", "URL": "https://github.com/dvolk/shawl5", "Placement": "menu", "Folder": "Mine common software"},
             {"Title": "oolook", "URL": "https://github.com/dvolk/oolook", "Placement": "menu", "Folder": "Mine common software"},
             {"Title": "catboard", "URL": "https://github.com/dvolk/catboard", "Placement": "menu", "Folder": "Mine common software"},
             {"Title": "MATLAB", "URL": "https://en.wikipedia.org/wiki/MATLAB", "Placement": "menu", "Folder": "Work common software"},
             {"Title": "Nextflow", "URL": "https://nextflow.io/", "Placement": "menu", "Folder": "Work common software"},
             {"Title": "Spack", "URL": "https://spack.io/", "Placement": "menu", "Folder": "Work common software"},
             {"Title": "goaccess", "URL": "https://goaccess.io/get-started", "Placement": "menu", "Folder": "Work common software"},
             {"Title": "nginx", "URL": "https://nginx.org/", "Placement": "menu", "Folder": "Work common software"},
             {"Title": "W3.CSS", "URL": "https://www.w3schools.com/w3css/default.asp", "Placement": "menu", "Folder": "CSS"},
             {"Title": "Spectre CSS", "URL": "https://picturepan2.github.io/spectre/index.html", "Placement": "menu", "Folder": "CSS"},
             {"Title": "Marx CSS", "URL": "https://github.com/mblode/marx", "Placement": "menu", "Folder": "CSS"},
             {"Title": "Water.css", "URL": "https://watercss.kognise.dev/", "Placement": "menu", "Folder": "CSS"},
             {"Title": "CSS brightness", "URL": "https://developer.mozilla.org/en-US/docs/Web/CSS/filter-function/brightness", "Placement": "menu", "Folder": "CSS"},
             {"Title": "Bulma", "URL": "https://bulma.io/", "Placement": "menu", "Folder": "CSS"},
             {"Title": "Puppertino", "URL": "https://codedgar.github.io/Puppertino/", "Placement": "menu", "Folder": "CSS"},
             {"Title": "sakura css", "URL": "https://oxal.org/projects/sakura/demo/", "Placement": "menu", "Folder": "CSS"},
             {"Title": "tacit css", "URL": "https://yegor256.github.io/tacit/", "Placement": "menu", "Folder": "CSS"},
             {"Title": "tufte css", "URL": "https://edwardtufte.github.io/tufte-css/", "Placement": "menu", "Folder": "CSS"},
             {"Title": "writ css", "URL": "https://writ.cmcenroe.me/reference.html", "Placement": "menu", "Folder": "CSS"},
             {"Title": "Fontawesome4", "URL": "https://fontawesome.com/v4/icons/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "X11 color names", "URL": "https://en.wikipedia.org/wiki/X11_color_names", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "gruvbox", "URL": "https://github.com/morhetz/gruvbox", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Colorsafe", "URL": "http://colorsafe.co/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Color extract", "URL": "http://www.coolphptools.com/color_extract", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Angular", "URL": "https://angular.io/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "React", "URL": "https://reactjs.org/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Jquery", "URL": "https://www.syncfusion.com/succinctly-free-ebooks/jquery/core-jquery", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Alpinejs", "URL": "https://alpinejs.dev/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "jquery ajax", "URL": "https://api.jquery.com/jquery.ajax/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Svelte", "URL": "https://svelte.dev/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Pantone", "URL": "https://en.wikipedia.org/wiki/Pantone", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Material design icons", "URL": "https://materialdesignicons.com/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "HTMx", "URL": "https://htmx.org/reference/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Petite Vue", "URL": "https://github.com/vuejs/petite-vue", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "HTML symbols", "URL": "https://www.toptal.com/designers/htmlarrows/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "OpenSSL commands", "URL": "https://pleasantpasswords.com/info/pleasant-password-server/b-server-configuration/3-installing-a-3rd-party-certificate/openssl-commands", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Google HTML/CSS Style Guide", "URL": "https://google.github.io/styleguide/htmlcssguide.html", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "classless css list", "URL": "https://github.com/dbohdan/classless-css", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "mermaid.js", "URL": "https://mermaid-js.github.io/mermaid/#/./flowchart?id=flowcharts-basic-syntax", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "JS APIs", "URL": "https://www.w3schools.com/js/js_api_intro.asp", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "How to create a more effective homepage", "URL": "https://mkt1.substack.com/p/homepage-copy", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Just Use Postgres for Everything", "URL": "https://www.amazingcto.com/postgres-for-everything/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Visual design rules", "URL": "https://anthonyhobday.com/sideprojects/saferules/", "Placement": "menu", "Folder": "Web dev"},
             {"Title": "Python", "URL": "https://docs.python.org/3/", "Placement": "menu", "Folder": "Programming language docs"},
             {"Title": "Nim", "URL": "https://nim-lang.org/documentation.html", "Placement": "menu", "Folder": "Programming language docs"},
             {"Title": "C++ guidelines", "URL": "https://github.com/isocpp/CppCoreGuidelines/blob/master/CppCoreGuidelines.md", "Placement": "menu", "Folder": "Programming language docs"},
             {"Title": "Go", "URL": "https://go.dev/learn/", "Placement": "menu", "Folder": "Programming language docs"},
             {"Title": "Tour of Go", "URL": "https://go.dev/tour/welcome/1", "Placement": "menu", "Folder": "Programming language docs"},
             {"Title": "Control + arrow keys", "URL": "https://apple.stackexchange.com/questions/18043/how-can-i-make-ctrlright-left-arrow-stop-changing-desktops-in-lion", "Placement": "menu", "Folder": "Mac stuff"},
             {"Title": "gitlab-runner", "URL": "https://docs.gitlab.com/runner/install/linux-manually.html", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Ansible", "URL": "https://docs.ansible.com/ansible/latest/collections/index.html", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Ansible built-in", "URL": "https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html#plugin-index", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Ansible semaphore", "URL": "https://ansible-semaphore.com/", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Ansible ad-hoc", "URL": "https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Ansible Git", "URL": "https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Systemd by example", "URL": "https://seb.jambor.dev/posts/systemd-by-example-part-1-minimization/", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Podman", "URL": "https://podman.io/getting-started/", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Portainer", "URL": "https://www.portainer.io/?hsLang=en", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Hashicorp nomad", "URL": "https://learn.hashicorp.com/nomad", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Container journal", "URL": "https://containerjournal.com/", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "systemd nspawn", "URL": "https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "jvns containers", "URL": "https://jvns.ca/#kubernetes---containers", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "osquery", "URL": "https://github.com/fleetdm/fleet", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "judo", "URL": "https://github.com/rollcat/judo", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "lazydocker", "URL": "https://github.com/jesseduffield/lazydocker", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Podman systemd", "URL": "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/running_containers_as_systemd_services_with_podman", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Terraform", "URL": "https://www.terraform.io/", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Terraform best practices", "URL": "https://www.terraform-best-practices.com/key-concepts", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Goog terraform best practices", "URL": "https://cloud.google.com/docs/terraform/best-practices-for-terraform", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "Pet to cattle", "URL": "https://pet2cattle.com/", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "100 Days of \"dev ops\"", "URL": "https://github.com/AdminTurnedDevOps/100DaysOfContainersAndOrchestration", "Placement": "menu", "Folder": "\"Dev-ops\""},
             {"Title": "kubespec", "URL": "https://kubespec.dev/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "knative serve", "URL": "https://knative.dev/docs/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "argocd", "URL": "https://argo-cd.readthedocs.io/en/stable/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "argo workflows", "URL": "https://argoproj.github.io/workflows/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "argo projects", "URL": "https://argoproj.github.io/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "kind", "URL": "https://kind.sigs.k8s.io/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "k3s", "URL": "https://k3s.io/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "kompose", "URL": "https://kompose.io/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "stern", "URL": "https://github.com/stern/stern", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "Helm", "URL": "https://helm.sh/docs/chart_template_guide/getting_started/", "Placement": "menu", "Folder": "Kubernetes ecosystem"},
             {"Title": "k3s docs", "URL": "https://docs.k3s.io/", "Placement": "menu", "Folder": "Kubernetes"},
             {"Title": "k8s yaml", "URL": "https://k8syaml.com/", "Placement": "menu", "Folder": "Kubernetes"},
             {"Title": "Kubebuilder book", "URL": "https://book.kubebuilder.io/", "Placement": "menu", "Folder": "Kubernetes"},
             {"Title": "Kubernetes concepts", "URL": "https://kubernetes.io/docs/concepts/", "Placement": "menu", "Folder": "Kubernetes"},
             {"Title": "k9s kubernetes tui", "URL": "https://k9scli.io/topics/install/", "Placement": "menu", "Folder": "Kubernetes"},
             {"Title": "What is a kubelet", "URL": "https://kamalmarhubi.com/blog/2015/08/27/what-even-is-a-kubelet/", "Placement": "menu", "Folder": "Kubernetes"},
             {"Title": "kubernetes examples", "URL": "https://github.com/kubernetes/examples", "Placement": "menu", "Folder": "Kubernetes"},
             {"Title": "Kubernetes stories", "URL": "https://hn.algolia.com/?q=kubernetes", "Placement": "menu", "Folder": "Kubernetes shitposts"},
             {"Title": "Kubernetes stories", "URL": "https://hn.algolia.com/?q=k8s", "Placement": "menu", "Folder": "Kubernetes shitposts"},
             {"Title": "Debian", "URL": "https://www.debian.org/", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "Ubuntu", "URL": "https://ubuntu.com/", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "Ubuntu daily image", "URL": "https://cdimage.ubuntu.com/daily-live/current/", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "NixOS", "URL": "https://nixos.org/", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "Nix packages", "URL": "https://search.nixos.org/packages?query=", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "Qubes OS", "URL": "https://www.qubes-os.org/", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "Alpinelinux", "URL": "https://alpinelinux.org/", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "SerenityOS", "URL": "https://serenityos.org/", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "C functions", "URL": "https://www.ibm.com/docs/en/i/7.3?topic=extensions-standard-c-library-functions-table-by-name", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "POSIX functions", "URL": "https://www.mkompf.com/cplus/posixlist.html", "Placement": "menu", "Folder": "Operating systems"},
             {"Title": "William Shakespeare", "URL": "https://www.goodreads.com/author/show/947.William_Shakespeare", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Marcel Proust", "URL": "https://www.goodreads.com/author/show/233619.Marcel_Proust", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Homer", "URL": "https://www.goodreads.com/author/show/903.Homer", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Leo Tolstoy", "URL": "https://www.goodreads.com/author/show/128382.Leo_Tolstoy", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Fyodor Dostoevsky", "URL": "https://www.goodreads.com/author/show/3137322.Fyodor_Dostoevsky", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Virgil", "URL": "https://www.goodreads.com/author/show/919.Virgil", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Dante Alighieri", "URL": "https://www.goodreads.com/author/show/5031312.Dante_Alighieri", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Augustine of Hippo", "URL": "https://www.goodreads.com/author/show/6819578.Augustine_of_Hippo", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Petrarch", "URL": "https://www.goodreads.com/author/show/72460.Francesco_Petrarca", "Placement": "menu", "Folder": "Fiction/Books - classics"},
             {"Title": "Anders Lustgarten", "URL": "https://en.wikipedia.org/wiki/Anders_Lustgarten", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Springer science and fiction", "URL": "https://www.springer.com/series/11657/books", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "goodreads.com hard-sicnce-fiction", "URL": "https://www.goodreads.com/shelf/show/hard-science-fiction", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "List of literary awards", "URL": "https://en.wikipedia.org/wiki/List_of_literary_awards", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Greg Egan", "URL": "https://www.gregegan.net/", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Ted Chiang", "URL": "https://www.goodreads.com/author/show/130698.Ted_Chiang", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Peter Watts", "URL": "https://www.rifters.com/", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Stephen Baxter", "URL": "https://www.stephen-baxter.com/", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Yahtzee Croshaw", "URL": "https://www.goodreads.com/author/show/3443203.Yahtzee_Croshaw", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Andy Weir", "URL": "https://www.goodreads.com/author/show/6540057.Andy_Weir", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Vernor Vinge", "URL": "https://www.goodreads.com/author/show/44037.Vernor_Vinge", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "David Brin", "URL": "https://www.goodreads.com/author/show/14078.David_Brin", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Iain Banks", "URL": "https://www.goodreads.com/author/show/5807106.Iain_M_Banks", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Roger Zelazny", "URL": "https://www.goodreads.com/author/show/3619.Roger_Zelazny", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Peter Hamilton", "URL": "https://www.goodreads.com/author/show/25375.Peter_F_Hamilton", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Dan Simmons", "URL": "https://www.goodreads.com/author/show/2687.Dan_Simmons", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Xiran Zhao", "URL": "https://xiranjayzhao.com/", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Arthur Clarke", "URL": "https://www.goodreads.com/author/show/7779.Arthur_C_Clarke", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Alice Munro", "URL": "https://www.goodreads.com/author/show/6410.Alice_Munro", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Iris Murdoch", "URL": "https://www.goodreads.com/author/show/7287.Iris_Murdoch", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Ma Yan", "URL": "https://www.goodreads.com/author/show/121407.Mo_Yan", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Liu Cixin", "URL": "https://www.goodreads.com/author/show/5780686.Liu_Cixin", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Jorge Luis Borges", "URL": "https://www.goodreads.com/author/show/500.Jorge_Luis_Borges", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "qntm", "URL": "https://www.goodreads.com/author/show/8352974.qntm", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "qntm", "URL": "https://qntm.org/", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "exubr1a", "URL": "https://www.goodreads.com/author/show/15241440.Exurb1a", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Neal Stephenson", "URL": "https://www.goodreads.com/author/show/545.Neal_Stephenson", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Kazuo Ishiguro", "URL": "https://www.goodreads.com/author/show/4280.Kazuo_Ishiguro", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "William Gibson", "URL": "https://www.goodreads.com/author/show/9226.William_Gibson", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Mingwei Song", "URL": "https://www.goodreads.com/author/show/14261954.Mingwei_Song", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Dennis Taylor", "URL": "https://www.goodreads.com/author/show/12130438.Dennis_E_Taylor", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Ken Liu", "URL": "https://www.goodreads.com/author/show/2917920.Ken_Liu", "Placement": "menu", "Folder": "Fiction/Books - modern"},
             {"Title": "Clarkesworld", "URL": "https://clarkesworldmagazine.com/", "Placement": "menu", "Folder": "Fiction magazines"},
             {"Title": "Lightspeed", "URL": "https://www.lightspeedmagazine.com/", "Placement": "menu", "Folder": "Fiction magazines"},
             {"Title": "copenhagen book", "URL": "https://thecopenhagenbook.com", "Placement": "menu", "Folder": "Guides"},
             {"Title": "Little OS book", "URL": "http://littleosbook.github.io/", "Placement": "menu", "Folder": "Guides"},
             {"Title": "Linux ACL permissions", "URL": "https://tylersguides.com/guides/linux-acl-permissions-tutorial/", "Placement": "menu", "Folder": "Guides"},
             {"Title": "XFCE custom actions", "URL": "https://docs.xfce.org/xfce/thunar/custom-actions", "Placement": "menu", "Folder": "Guides"},
             {"Title": "Desktop entries", "URL": "https://wiki.archlinux.org/title/desktop_entries", "Placement": "menu", "Folder": "Guides"},
             {"Title": "Diataxis", "URL": "https://diataxis.fr/", "Placement": "menu", "Folder": "Guides"},
             {"Title": "nand2tetris", "URL": "https://www.nand2tetris.org/", "Placement": "menu", "Folder": "Guides"},
             {"Title": "The Snowflake Method For Designing A Novel", "URL": "https://www.advancedfictionwriting.com/articles/snowflake-method/", "Placement": "menu", "Folder": "Guides"},
             {"Title": "Local-first software", "URL": "https://www.inkandswitch.com/local-first/", "Placement": "menu", "Folder": "Guides"},
             {"Title": "make as a Static Site Generator", "URL": "https://www.karl.berlin/static-site.html", "Placement": "menu", "Folder": "Guides"},
             {"Title": "USCNPM", "URL": "https://uscnpm.org/", "Placement": "menu", "Folder": "News"},
             {"Title": "Tom's hardware", "URL": "https://www.tomshardware.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "semianalysis", "URL": "https://semianalysis.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "The New Humanitarian", "URL": "https://www.thenewhumanitarian.org/", "Placement": "menu", "Folder": "News"},
             {"Title": "9to5linux", "URL": "https://9to5linux.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Planet GNOME", "URL": "https://planet.gnome.org/", "Placement": "menu", "Folder": "News"},
             {"Title": "Unlimited Hangout podcast", "URL": "https://unlimitedhangout.com/ulh-podcast/", "Placement": "menu", "Folder": "News"},
             {"Title": "DeclassifiedUK youtube", "URL": "https://www.youtube.com/@DeclassifiedUK/videos", "Placement": "menu", "Folder": "News"},
             {"Title": "Owen Jones Talks", "URL": "https://www.youtube.com/@OwenJonesTalks", "Placement": "menu", "Folder": "News"},
             {"Title": "BreakThrough News", "URL": "https://www.youtube.com/@BreakThroughNews/videos", "Placement": "menu", "Folder": "News"},
             {"Title": "Pekingology", "URL": "https://www.pekingnology.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Multipolar magazin", "URL": "https://multipolar-magazin.de/", "Placement": "menu", "Folder": "News"},
             {"Title": "Sixth tone", "URL": "https://www.sixthtone.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "The Luddite", "URL": "https://theluddite.org", "Placement": "menu", "Folder": "News"},
             {"Title": "Dissident Voice", "URL": "https://dissidentvoice.org/", "Placement": "menu", "Folder": "News"},
             {"Title": "shine.cn", "URL": "https://www.shine.cn/", "Placement": "menu", "Folder": "News"},
             {"Title": "declassifieduk", "URL": "https://www.declassifieduk.org/", "Placement": "menu", "Folder": "News"},
             {"Title": "MotherJones", "URL": "https://www.motherjones.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "People's dispatch", "URL": "https://peoplesdispatch.org/", "Placement": "menu", "Folder": "News"},
             {"Title": "SCMP", "URL": "https://www.scmp.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "People's daily", "URL": "http://en.people.cn/index.html", "Placement": "menu", "Folder": "News"},
             {"Title": "chosun", "URL": "https://english.chosun.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "thegrayzone", "URL": "https://thegrayzone.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "China Daily", "URL": "https://global.chinadaily.com.cn/", "Placement": "menu", "Folder": "News"},
             {"Title": "Jimmy Dore", "URL": "https://www.youtube.com/@thejimmydoreshow/videos", "Placement": "menu", "Folder": "News"},
             {"Title": "Geopolitical Economy Report", "URL": "https://www.youtube.com/@GeopoliticalEconomyReport/videos", "Placement": "menu", "Folder": "News"},
             {"Title": "Korean Central News Agency", "URL": "http://www.kcna.kp/en", "Placement": "menu", "Folder": "News"},
             {"Title": "UN security council PR", "URL": "https://press.un.org/en/content/security-council/press-release", "Placement": "menu", "Folder": "News"},
             {"Title": "France24", "URL": "https://www.france24.com/en/", "Placement": "menu", "Folder": "News"},
             {"Title": "Tehran Times", "URL": "https://www.tehrantimes.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Xinhuanet", "URL": "https://english.news.cn/home.htm", "Placement": "menu", "Folder": "News"},
             {"Title": "geopoliticaleconomy.com", "URL": "https://geopoliticaleconomy.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Asia times", "URL": "https://asiatimes.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "ECNS", "URL": "http://www.ecns.cn/", "Placement": "menu", "Folder": "News"},
             {"Title": "Pravda", "URL": "https://english.pravda.ru/", "Placement": "menu", "Folder": "News"},
             {"Title": "NL times", "URL": "https://nltimes.nl/", "Placement": "menu", "Folder": "News"},
             {"Title": "Aljazeera", "URL": "https://www.aljazeera.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "LWN", "URL": "https://lwn.net/", "Placement": "menu", "Folder": "News"},
             {"Title": "Container News", "URL": "https://container-news.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Phoronix", "URL": "https://www.phoronix.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Liliputing", "URL": "https://liliputing.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Tom's hardware", "URL": "https://www.tomshardware.com/", "Placement": "menu", "Folder": "News"},
             {"Title": "Hacker News", "URL": "https://news.ycombinator.com/", "Placement": "menu", "Folder": "User-submitted news sites"},
             {"Title": "Metafilter", "URL": "https://www.metafilter.com/", "Placement": "menu", "Folder": "User-submitted news sites"},
             {"Title": "Planet Debian", "URL": "https://planet.debian.org/", "Placement": "menu", "Folder": "User-submitted news sites"},
             {"Title": "Wikinews", "URL": "https://en.wikinews.org/wiki/Main_Page", "Placement": "menu", "Folder": "User-submitted news sites"},
             {"Title": "Planet Emacs", "URL": "https://planet.emacslife.com/", "Placement": "menu", "Folder": "User-submitted news sites"},
             {"Title": "silly v0.2", "URL": "https://huggingface.co/wave-on-discord/silly-v0.2", "Placement": "menu", "Folder": "Local chatbots"},
             {"Title": "ollama", "URL": "https://ollama.ai/", "Placement": "menu", "Folder": "Local chatbots"},
             {"Title": "ollama docker", "URL": "https://hub.docker.com/r/ollama/ollama", "Placement": "menu", "Folder": "Local chatbots"},
             {"Title": "llamafile", "URL": "https://github.com/Mozilla-Ocho/llamafile", "Placement": "menu", "Folder": "Local chatbots"},
             {"Title": "llama.cpp", "URL": "https://github.com/ggerganov/llama.cpp", "Placement": "menu", "Folder": "Local chatbots"},
             {"Title": "Mixtral-8x7B-Instruct-v0.1", "URL": "https://huggingface.co/mistralai/Mixtral-8x7B-Instruct-v0.1", "Placement": "menu", "Folder": "Local chatbots"},
             {"Title": "llava-v1.5-7b", "URL": "https://huggingface.co/liuhaotian/llava-v1.5-7b", "Placement": "menu", "Folder": "Local chatbots"},
             {"Title": "ERNIE", "URL": "https://ernie.baidu.com/", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "kimi", "URL": "https://www.kimi.com", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "qwen", "URL": "https://chat.qwen.ai/", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "DeepSeek", "URL": "https://chat.deepseek.com", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "GLM z.ai", "URL": "https://chat.z.ai/", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "Gemini", "URL": "https://gemini.google.com", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "qwq", "URL": "https://qwenlm.github.io/blog/qwq-32b-preview/", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "ChatGPT", "URL": "https://chat.openai.com/", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "Claude 2", "URL": "https://www.anthropic.com/index/claude-2", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "Poe", "URL": "https://poe.com/", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "Bard", "URL": "https://bard.google.com/?hl=en", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "Character.ai", "URL": "https://beta.character.ai/chats", "Placement": "menu", "Folder": "SAAS chatbots"},
             {"Title": "ComfyUI", "URL": "https://github.com/Comfy-Org/ComfyUI", "Placement": "menu", "Folder": "image gen"},
             {"Title": "How to Run Qwen-Image-2512 Locally in ComfyUI", "URL": "https://unsloth.ai/docs/models/qwen-image-2512", "Placement": "menu", "Folder": "image gen"},
             {"Title": "lemdro.id", "URL": "https://lemdro.id/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "sopuli.xyz", "URL": "https://sopuli.xyz", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "feddit.uk", "URL": "https://feddit.uk/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "lemmy.blahaj.zone", "URL": "https://lemmy.blahaj.zone/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "lemmy.zip", "URL": "https://lemmy.zip", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "slrpnk.net", "URL": "https://slrpnk.net/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "Lemmy.ml", "URL": "https://lemmy.ml/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "lemmy.world", "URL": "https://lemmy.world/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "lemmygrad.ml", "URL": "https://lemmygrad.ml/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "oldbytes.space", "URL": "https://oldbytes.space/public/local", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "wefwef.app", "URL": "https://wefwef.app/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "hexbear", "URL": "https://www.hexbear.net/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "sh.itjust.works", "URL": "https://sh.itjust.works/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "programming.dev", "URL": "https://programming.dev/", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "mastodon.social", "URL": "https://mastodon.social/explore", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "peoplemaking.games", "URL": "https://peoplemaking.games/public/local", "Placement": "menu", "Folder": "Fedi"},
             {"Title": "Wikimedia commons", "URL": "https://commons.wikimedia.org/wiki/Main_Page", "Placement": "menu", "Folder": "Reference"},
             {"Title": "EN Wiktionary", "URL": "https://en.wiktionary.org/wiki/Wiktionary:Main_Page", "Placement": "menu", "Folder": "Reference"},
             {"Title": "EN wikisource", "URL": "https://en.wikisource.org/wiki/Main_Page", "Placement": "menu", "Folder": "Reference"},
             {"Title": "Wikipedia", "URL": "https://en.wikipedia.org/", "Placement": "menu", "Folder": "Reference"},
             {"Title": "Wikihow", "URL": "https://www.wikihow.com/Main-Page", "Placement": "menu", "Folder": "Reference"},
             {"Title": "Wikiquote", "URL": "https://en.wikiquote.org", "Placement": "menu", "Folder": "Reference"},
             {"Title": "CGTN TV", "URL": "https://www.cgtn.com/tv", "Placement": "menu", "Folder": "Radio/TV"},
             {"Title": "CGTN radio", "URL": "https://radio.cgtn.com/", "Placement": "menu", "Folder": "Radio/TV"},
             {"Title": "Aljazeera", "URL": "https://aljazeera.com/live", "Placement": "menu", "Folder": "Radio/TV"},
             {"Title": "Radio Monocle", "URL": "https://monocle.com/radio/", "Placement": "menu", "Folder": "Radio/TV"},
             {"Title": "BBC Radio 4", "URL": "https://www.radio-uk.co.uk/bbc-radio-4", "Placement": "menu", "Folder": "Radio/TV"},
             {"Title": "archive.org book search", "URL": "https://archive.org/search?query=%28guide+illustrated%29+AND+mediatype%3A%28texts%29+AND+-access-restricted-item%3A%28true%29", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "draw city roads", "URL": "https://anvaka.github.io/city-roads", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "asterisk mag", "URL": "https://asteriskmag.com/issues", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "yt factorio challenge", "URL": "https://www.youtube.com/results?search_query=factorio+challenge", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "yt timberborn challenge", "URL": "https://www.youtube.com/results?search_query=timberborn+challenge", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Anthropology review", "URL": "https://anthropologyreview.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "socialism faq", "URL": "https://dessalines.github.io/essays/socialism_faq.html#kamala-harris", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "crash course socialism", "URL": "https://github.com/dessalines/essays/blob/main/crash_course_socialism.md", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "transhumans.xyz", "URL": "https://www.transhumans.xyz/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Manifold (prediction market)", "URL": "https://manifold.markets/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "leetcode patterns", "URL": "https://seanprashad.com/leetcode-patterns/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Against the current", "URL": "https://againstthecurrent.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Split keyboards", "URL": "https://aposymbiont.github.io/split-keyboards", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Open library", "URL": "https://openlibrary.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Internet archive", "URL": "https://archive.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "omg.lol", "URL": "https://home.omg.lol/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "BG2 gamefaqs", "URL": "https://gamefaqs.gamespot.com/mac/581309-baldurs-gate-ii-shadows-of-amn/faqs", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Amn", "URL": "https://forgottenrealms.fandom.com/wiki/Amn", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Qiao Collective", "URL": "https://www.qiaocollective.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "RedSails", "URL": "https://redsails.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Random site", "URL": "https://wiby.me/surprise/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Marginalia", "URL": "https://search.marginalia.nu/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Factories in Space", "URL": "https://www.factoriesinspace.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "One day you'll find yourself", "URL": "https://www.onedayyoullfindyourself.com/table-of-contents.html", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "itch.io", "URL": "https://itch.io/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "itch.io forums", "URL": "https://itch.io/community", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "wallpaper abyss", "URL": "https://wall.alphacoders.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Stackoverflow", "URL": "https://stackoverflow.com/questions", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Worldbuilding stackoverflow", "URL": "https://worldbuilding.stackexchange.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Steam", "URL": "https://store.steampowered.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "No Tech Magazine", "URL": "https://www.notechmagazine.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "DatoRSS", "URL": "https://datorss.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "crownview", "URL": "https://crowdview.ai/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "ISO 27001", "URL": "https://www.iso.org/isoiec-27001-information-security.html", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Typelit", "URL": "https://www.typelit.io/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "GOG", "URL": "https://www.gog.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Instructables", "URL": "https://www.instructables.com/Duck-Tape-Book-Binding-Cheepo-Delux/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Wizard Zines", "URL": "https://questions.wizardzines.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Random streetview", "URL": "https://randomstreetview.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Geoguessr", "URL": "https://www.geoguessr.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Brilliant", "URL": "https://brilliant.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Hackaday", "URL": "https://hackaday.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "512kb club", "URL": "https://512kb.club/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "are.na", "URL": "https://www.are.na/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Academia stackexchange", "URL": "https://academia.stackexchange.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Ask HN: How do you find the weird parts of the web?", "URL": "https://news.ycombinator.com/item?id=32804832", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Autosummarized HN", "URL": "https://danieljanus.pl/autosummarized-hn/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Gwern", "URL": "https://gwern.net", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "danluu", "URL": "https://danluu.com", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "RMS", "URL": "https://stallman.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "ISFDB", "URL": "https://www.isfdb.org/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Wonders of streetview", "URL": "https://neal.fun/wonders-of-street-view/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Same energy", "URL": "https://same.energy/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "Babylon bee", "URL": "https://babylonbee.com/", "Placement": "menu", "Folder": "Wasting time"},
             {"Title": "The Jewel of Seven Stars", "URL": "https://en.wikipedia.org/wiki/The_Jewel_of_Seven_Stars", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Gallery of sovereign state flags", "URL": "https://en.wikipedia.org/wiki/Gallery_of_sovereign_state_flags", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Siphonaptera (poem)", "URL": "https://en.wikipedia.org/wiki/Siphonaptera_(poem)", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Mechanized Assault & Exploration", "URL": "https://en.wikipedia.org/wiki/Mechanized_Assault_%26_Exploration", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Communist Party of China", "URL": "https://en.wikipedia.org/wiki/Chinese_Communist_Party", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Chinese science fiction", "URL": "https://en.wikipedia.org/wiki/Chinese_science_fiction", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Intertextuality", "URL": "https://en.wikipedia.org/wiki/Intertextuality", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "World-system", "URL": "https://en.wikipedia.org/wiki/World-system", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Dependency theory", "URL": "https://en.wikipedia.org/wiki/Dependency_theory", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Theories of imperialism", "URL": "https://en.wikipedia.org/wiki/Theories_of_imperialism", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Integrated information theory", "URL": "https://en.wikipedia.org/wiki/Integrated_information_theory", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Lyndon LaRouche", "URL": "https://en.wikipedia.org/wiki/Lyndon_LaRouche", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Fred Hampton", "URL": "https://en.wikipedia.org/wiki/Fred_Hampton", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Embrace, extend, extinguish", "URL": "https://en.m.wikipedia.org/wiki/Embrace,_extend,_and_extinguish", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Intuitionism", "URL": "https://en.wikipedia.org/wiki/Intuitionism", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "Palantir Technologies", "URL": "https://en.wikipedia.org/wiki/Palantir_Technologies", "Placement": "menu", "Folder": "Wikipedia"},
             {"Title": "sipeed lichee", "URL": "https://sipeed.com/licheepi4a", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Alldocube", "URL": "https://www.alldocube.com/en/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Powkiddy", "URL": "https://powkiddy.com/en-uk", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Huawei", "URL": "https://www.huawei.com/uk/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Chuwi", "URL": "https://www.chuwi.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Kuu", "URL": "https://kuu-tech.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "GPD", "URL": "https://gpd.hk/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "GPD indiegogo", "URL": "https://www.indiegogo.com/individuals/13166053/campaigns", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "AYA Neo", "URL": "https://www.ayaneo.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "AYA Neo indiegogo", "URL": "https://www.indiegogo.com/individuals/25072953/campaigns", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "AOKZOE", "URL": "https://aokzoestore.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "ASUS ROG", "URL": "https://rog.asus.com/uk/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "ZTE UK", "URL": "https://ztedevices.com/en-uk/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Red magic UK", "URL": "https://uk.redmagic.gg/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Lenovo", "URL": "https://www.lenovo.com/gb/en/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Dell", "URL": "https://www.dell.com/en-uk", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Framework laptop", "URL": "https://frame.work/gb/en", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Ploopy", "URL": "https://ploopy.co/mouse/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Pine64", "URL": "https://www.pine64.org/pinephone/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Jumper shenzhen", "URL": "http://www.en.jumper.com.cn/en/index.html", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Teclast", "URL": "https://en.teclast.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Ebay thinkpad newest", "URL": "https://www.ebay.co.uk/sch/i.html?_nkw=thinkpad&_sop=10&_oac=1", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Ebay gpd win newest", "URL": "https://www.ebay.co.uk/sch/i.html?_nkw=gpd win&_sop=10&_oac=1", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Ebay vaio pcg-u newest", "URL": "https://www.ebay.co.uk/sch/i.html?_nkw=vaio pcg-u&_sop=10&_oac=1", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "hardkernel", "URL": "https://www.hardkernel.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Asrock industrial", "URL": "https://www.asrockind.com/en-gb/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Minisforum", "URL": "https://store.minisforum.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "Onexplayer", "URL": "https://onexplayerstore.com/", "Placement": "menu", "Folder": "Hardware"},
             {"Title": "RAND Corporation", "URL": "https://www.rand.org/", "Placement": "menu", "Folder": "US think tanks (war)"},
             {"Title": "Brookings Institution", "URL": "https://www.brookings.edu/", "Placement": "menu", "Folder": "US think tanks (war)"},
             {"Title": "Center for Strategic and International Studies (CSIS)", "URL": "https://www.csis.org/", "Placement": "menu", "Folder": "US think tanks (war)"},
             {"Title": "The Heritage Foundation", "URL": "https://www.heritage.org/", "Placement": "menu", "Folder": "US think tanks (war)"},
             {"Title": "Atlantic Council", "URL": "https://www.atlanticcouncil.org/", "Placement": "menu", "Folder": "US think tanks (war)"},
             {"Title": "Aerospace Industries Association (AIA)", "URL": "https://www.aia-aerospace.org/", "Placement": "menu", "Folder": "US Lobbying (war)"},
             {"Title": "National Defense Industrial Association (NDIA)", "URL": "https://www.ndia.org/", "Placement": "menu", "Folder": "US Lobbying (war)"},
             {"Title": "Electronic Frontier Foundation (EFF)", "URL": "https://www.eff.org/", "Placement": "menu", "Folder": "US Lobbying (war)"},
             {"Title": "Royal United Services Institute (RUSI)", "URL": "https://www.rusi.org/", "Placement": "menu", "Folder": "UK Think tanks (war)"},
             {"Title": "International Institute for Strategic Studies (IISS)", "URL": "https://www.iiss.org/", "Placement": "menu", "Folder": "UK Think tanks (war)"},
             {"Title": "ADS group", "URL": "https://www.adsgroup.org.uk/", "Placement": "menu", "Folder": "UK Lobbying (war)"},
             {"Title": "Security Institute", "URL": "https://security-institute.org/", "Placement": "menu", "Folder": "UK Lobbying (war)"},
             {"Title": "Institute for Fiscal Studies (IFS)", "URL": "https://ifs.org.uk/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "Chatham House (The Royal Institute of International Affairs)", "URL": "https://www.chathamhouse.org/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "Policy Exchange", "URL": "https://policyexchange.org.uk/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "Fabian Society", "URL": "https://fabians.org.uk/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "Resolution Foundation", "URL": "https://www.resolutionfoundation.org/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "The Adam Smith Institute", "URL": "https://www.adamsmith.org/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "Nuffield Trust", "URL": "https://www.nuffieldtrust.org.uk/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "Centre for European Reform", "URL": "https://www.cer.eu/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "King's Fund", "URL": "https://www.kingsfund.org.uk/", "Placement": "menu", "Folder": "UK Think tanks (other)"},
             {"Title": "CBI (Confederation of British Industry)", "URL": "https://www.cbi.org.uk/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "TheCityUK", "URL": "https://www.thecityuk.com/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "Trade Union Congress (TUC)", "URL": "https://www.tuc.org.uk/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "The Institute of Directors (IoD)", "URL": "https://www.iod.com/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "NFU (National Farmers' Union)", "URL": "https://www.nfuonline.com/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "Federation of Small Businesses", "URL": "https://www.fsb.org.uk/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "The Royal Society for the Protection of Birds (RSPB)", "URL": "https://www.rspb.org.uk/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "TechUK", "URL": "https://www.techuk.org/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "British Medical Association (BMA)", "URL": "https://www.bma.org.uk/", "Placement": "menu", "Folder": "UK Lobbying (other)"},
             {"Title": "Predictive History", "URL": "https://www.youtube.com/@PredictiveHistory/videos", "Placement": "menu", "Folder": "Video"},
             {"Title": "GeoWizard", "URL": "https://www.youtube.com/@GeoWizard/playlists", "Placement": "menu", "Folder": "Video"},
             {"Title": "CrashCourse", "URL": "https://www.youtube.com/@crashcourse/videos", "Placement": "menu", "Folder": "Video"},
             {"Title": "Kurzgesagt \u2013 In a Nutshell", "URL": "https://www.youtube.com/@kurzgesagt", "Placement": "menu", "Folder": "Video"},
             {"Title": "ThePrimeTime", "URL": "https://www.youtube.com/@ThePrimeTimeagen", "Placement": "menu", "Folder": "Video"},
             {"Title": "Hakim", "URL": "https://www.youtube.com/@YaBoiHakim/videos", "Placement": "menu", "Folder": "Video"},
             {"Title": "1905 movies", "URL": "https://www.youtube.com/@1905-English/videos", "Placement": "menu", "Folder": "Video"},
             {"Title": "Fridayeveryday", "URL": "https://www.youtube.com/@Fridayeverydaycom", "Placement": "menu", "Folder": "Video"},
             {"Title": "Never Work in Theory", "URL": "https://www.youtube.com/@ItWillNeverWorkinTheory-dl8go/videos", "Placement": "menu", "Folder": "Video"},
             {"Title": "China Street", "URL": "https://www.youtube.com/@chinavlog520/videos", "Placement": "menu", "Folder": "Video"},
             {"Title": "Geopolitical Economy Report", "URL": "https://www.youtube.com/@GeopoliticalEconomyReport", "Placement": "menu", "Folder": "Video"},
             {"Title": "Dialogue Works", "URL": "https://www.youtube.com/@dialogueworks01", "Placement": "menu", "Folder": "Video"},
             {"Title": "Little Chinese Everywhere", "URL": "https://www.youtube.com/channel/UC1UNB6Gy11umcbEj_hqIwhw", "Placement": "menu", "Folder": "Video"},
             {"Title": "Katherine's Journey to the East", "URL": "https://www.youtube.com/@kats_journey_east/videos", "Placement": "menu", "Folder": "Video"},
             {"Title": "longsoon", "URL": "https://www.youtube.com/results?search_query=longsoon", "Placement": "menu", "Folder": "Video"},
             {"Title": "3blue1brown", "URL": "https://www.youtube.com/@3blue1brown", "Placement": "menu", "Folder": "Video"},
             {"Title": "PracticalEngineeringChannel", "URL": "https://www.youtube.com/@PracticalEngineeringChannel", "Placement": "menu", "Folder": "Video"},
             {"Title": "energyskeptic.com", "URL": "https://energyskeptic.com/", "Placement": "menu", "Folder": "blogs"},
             {"Title": "GSMarena", "URL": "https://www.gsmarena.com/", "Placement": "menu", "Folder": "Hardware reviews"},
             {"Title": "Notebookcheck", "URL": "https://www.notebookcheck.net/", "Placement": "menu", "Folder": "Hardware reviews"},
             {"Title": "Laptop magazine", "URL": "https://www.laptopmag.com/uk", "Placement": "menu", "Folder": "Hardware reviews"},
             {"Title": "CataclysmDDA", "URL": "https://github.com/CleverRaven/Cataclysm-DDA", "Placement": "menu", "Folder": "Games"},
             {"Title": "OpenMW", "URL": "https://github.com/OpenMW/openmw", "Placement": "menu", "Folder": "Games"},
             {"Title": "Daggerfall Unity", "URL": "https://www.dfworkshop.net/", "Placement": "menu", "Folder": "Games"},
             {"Title": "UESP Daggerfall", "URL": "https://en.uesp.net/wiki/Daggerfall:Daggerfall", "Placement": "menu", "Folder": "Games"},
             {"Title": "Ashfall", "URL": "https://www.nexusmods.com/morrowind/mods/49057", "Placement": "menu", "Folder": "Games"},
             {"Title": "Zachtronics", "URL": "https://www.zachtronics.com/", "Placement": "menu", "Folder": "Games"},
             {"Title": "Tomorrow Corporation", "URL": "https://tomorrowcorporation.com/", "Placement": "menu", "Folder": "Games"},
             {"Title": "Shapez.io", "URL": "https://shapez.io/", "Placement": "menu", "Folder": "Games"},
             {"Title": "Mindustry", "URL": "https://mindustrygame.github.io/", "Placement": "menu", "Folder": "Games"},
             {"Title": "OS games clones", "URL": "https://osgameclones.com/", "Placement": "menu", "Folder": "Games"},
             {"Title": "List of games on github", "URL": "https://github.com/leereilly/games", "Placement": "menu", "Folder": "Games"},
             {"Title": "Gaming on linux", "URL": "https://www.gamingonlinux.com/", "Placement": "menu", "Folder": "Games"},
             {"Title": "nexusmods starfield", "URL": "https://www.nexusmods.com/games/starfield", "Placement": "menu", "Folder": "Games"},
             {"Title": "Vinted uk", "URL": "https://www.vinted.co.uk", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Overclockers", "URL": "https://www.overclockers.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "pcspecialist", "URL": "https://www.pcspecialist.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Pcpartpicker UK", "URL": "https://uk.pcpartpicker.com/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "IKEA", "URL": "https://www.ikea.com/gb/en/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Oxford council", "URL": "https://www.oxford.gov.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Amazon UK", "URL": "https://www.amazon.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Ebay UK", "URL": "https://www.ebay.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Giztop", "URL": "https://www.giztop.com/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Wondamobile", "URL": "https://www.wondamobile.com/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Currys", "URL": "https://www.currys.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Jobs.ac.uk", "URL": "https://www.jobs.ac.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "US RSE", "URL": "https://us-rse.org/jobs/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Rightmove", "URL": "https://www.rightmove.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Scan", "URL": "https://www.scan.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Counties of England", "URL": "https://en.wikipedia.org/wiki/Counties_of_England", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Oxford mail", "URL": "https://www.oxfordmail.co.uk/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Aliexpress", "URL": "https://www.aliexpress.com/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Gearbest", "URL": "https://www.gearbest.com/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Taobao", "URL": "https://world.taobao.com/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Ebuyer", "URL": "https://www.ebuyer.com/", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "datablocks.dev", "URL": "https://datablocks.dev", "Placement": "menu", "Folder": "Oxford life"},
             {"Title": "Oxford Key", "URL": "https://www.oxfordkey.co.uk/smart-card/", "Placement": "menu", "Folder": "Oxford travel"},
             {"Title": "ST1 bus", "URL": "https://www.oxfordbus.co.uk/services/THTR/ST1", "Placement": "menu", "Folder": "Oxford travel"},
             {"Title": "X32 bus", "URL": "https://www.oxfordbus.co.uk/services/THTR/X32", "Placement": "menu", "Folder": "Oxford travel"},
             {"Title": "Oxford Openstreetmap", "URL": "https://www.openstreetmap.org/#map=13/51.7543/-1.2293", "Placement": "menu", "Folder": "Oxford travel"},
             {"Title": "Oxford Google Maps", "URL": "https://www.google.com/maps/@51.7538573,-1.2259815,13z", "Placement": "menu", "Folder": "Oxford travel"},
             {"Title": "The Last Ringbearer", "URL": "https://en.wikipedia.org/wiki/The_Last_Ringbearer", "Placement": "menu", "Folder": "Memes"},
             {"Title": "BoyBoy", "URL": "https://www.youtube.com/@Boy_Boy/videos", "Placement": "menu", "Folder": "Memes"},
             {"Title": "Postgres is enough", "URL": "https://gist.github.com/cpursley/c8fb81fe8a7e5df038158bdfe0f06dbb", "Placement": "menu", "Folder": "Memes"},
             {"Title": "Germany's autobahn bridges falling apart", "URL": "https://www.dw.com/en/germanys-autobahn-bridges-falling-apart/a-69439952", "Placement": "menu", "Folder": "Memes"},
             {"Title": "libyear", "URL": "https://github.com/nasirhjafri/libyear", "Placement": "menu", "Folder": "Memes"},
             {"Title": "Killed by Google", "URL": "https://killedbygoogle.com/", "Placement": "menu", "Folder": "Memes"},
             {"Title": "wtfpython", "URL": "https://github.com/satwikkansal/wtfpython", "Placement": "menu", "Folder": "Memes"},
             {"Title": "gnome shell issues", "URL": "https://gitlab.gnome.org/GNOME/gnome-shell/-/issues", "Placement": "menu", "Folder": "Memes"},
             {"Title": "Building and testing C extensions for SQLite with ChatGPT Code Interpreter", "URL": "https://simonwillison.net/2024/Mar/23/building-c-extensions-for-sqlite-with-chatgpt-code-interpreter/", "Placement": "menu", "Folder": "Essays"},
             {"Title": "Hyper-Imperialism", "URL": "https://thetricontinental.org/studies-on-contemporary-dilemmas-4-hyper-imperialism/", "Placement": "menu", "Folder": "Essays"},
             {"Title": "Taiwan: An Anti-Imperialist Resource", "URL": "https://www.qiaocollective.com/education/taiwan", "Placement": "menu", "Folder": "Essays"},
             {"Title": "A Brief History of the Corporation: 1600 to 2100", "URL": "https://www.ribbonfarm.com/2011/06/08/a-brief-history-of-the-corporation-1600-to-2100/", "Placement": "menu", "Folder": "Essays"},
             {"Title": "Why Match School And Student Rank?", "URL": "https://astralcodexten.substack.com/p/why-match-school-and-student-rank", "Placement": "menu", "Folder": "Essays"},
             {"Title": "Why don\u2019t software development methodologies work?", "URL": "https://typicalprogrammer.com/why-dont-software-development-methodologies-work", "Placement": "menu", "Folder": "Essays"},
             {"Title": "The blueprint of regime change operations", "URL": "https://criticalresist.substack.com/p/the-blueprint-of-regime-change-operations", "Placement": "menu", "Folder": "Essays"},
             {"Title": "Baidu map", "URL": "https://map.baidu.com/@11590057.96,4489812.75,4z", "Placement": "menu", "Folder": "Chinese"},
             {"Title": "Douyin", "URL": "https://www.douyin.com/", "Placement": "menu", "Folder": "Chinese"},
             {"Title": "Xiaohongshu", "URL": "https://www.xiaohongshu.com/explore", "Placement": "menu", "Folder": "Chinese"},
             {"Title": "gitee", "URL": "https://gitee.com/", "Placement": "menu", "Folder": "Chinese"},
             {"Title": "Taobao", "URL": "https://world.taobao.com/", "Placement": "menu", "Folder": "Chinese"},
             {"Title": "Kerbal Space Program", "URL": "https://forum.kerbalspaceprogram.com/", "Placement": "menu", "Folder": "Forums"},
             {"Title": "Kerbal Space Program", "URL": "https://wiki.kerbalspaceprogram.com/", "Placement": "menu", "Folder": "Wikis"},
             {"Title": "chat", "URL": "https://chat.oxfordfun.com", "Placement": "menu", "Folder": "Hosted SAAS"},
             {"Title": "catboard", "URL": "https://catboard.oxfordfun.com/", "Placement": "menu", "Folder": "Hosted SAAS"},
             {"Title": "catreads", "URL": "https://catreads.oxfordfun.com/", "Placement": "menu", "Folder": "Hosted SAAS"}
         ]
    }
}
EOF
sudo mkdir -p /etc/firefox/policies
jq . /tmp/policies.json # validate the json
sudo mv /tmp/policies.json /etc/firefox/policies

# snap
for profile_dir in $(find snap/firefox/common/.mozilla/firefox/ -name '*.default*'); do
    echo "profile_dir: $profile_dir"
    mkdir -p "$profile_dir/chrome"
    echo "#TabsToolbar { visibility: collapse; }" > "$profile_dir/chrome/userChrome.css"
done

# other
for profile_dir in $(find .mozilla/firefox/ -name '*.default*'); do
    echo "profile_dir: $profile_dir"
    mkdir -p "$profile_dir/chrome"
    echo "#TabsToolbar { visibility: collapse; }" > "$profile_dir/chrome/userChrome.css"
done

#
#   __ _ _ __   ___  _ __ ___   ___
#  / _` | '_ \ / _ \| '_ ` _ \ / _ \
# | (_| | | | | (_) | | | | | |  __/
#  \__, |_| |_|\___/|_| |_| |_|\___|
#  |___/
#

# no thanks
{
    systemctl --user stop tracker-miner-fs-3.service
    systemctl --user mask tracker-miner-fs-3.service
    rm -rf .cache/tracker3
} || true
# disable extensions
{
    gnome-extensions disable ding@rastersoft.com
    gnome-extensions disable tiling-assistant@ubuntu.com
    gnome-extensions disable ubuntu-appindicators@ubuntu.com
    gnome-extensions disable ubuntu-dock@ubuntu.com
} || true
dconf write /org/gnome/shell/enabled-extensions "@as []"
dconf write /org/gnome/shell/disable-user-extensions true
# lock screen after 10 minutes
dconf write /org/gnome/desktop/session/idle-delay 600
# disable edge tiling
dconf write /org/gnome/mutter/edge-tiling false
# set number of workspaces to 12
dconf write /org/gnome/mutter/dynamic-workspaces false
dconf write /org/gnome/desktop/wm/preferences/num-workspaces 12
# turn on dnd
dconf write  /org/gnome/desktop/notifications/show-banners false
# turn off login screen notifications
dconf write /org/gnome/desktop/notifications/show-in-lock-screen false
# disable indexing and searching
dconf write /org/gnome/desktop/search-providers/disabled "['org.gnome.Terminal.desktop', 'org.gnome.seahorse.Application.desktop', 'org.gnome.Settings.desktop', 'org.gnome.clocks.desktop', 'org.gnome.Characters.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Nautilus.desktop']"
dconf write /org/freedesktop/tracker/miner/files/index-single-directories "@as []"
dconf write /org/freedesktop/tracker/miner/files/index-recursive-directories "@as []"
dconf write /org/gnome/desktop/search-providers/disable-external true
dconf write /org/gnome/desktop/privacy/remove-old-temp-files true
dconf write /org/gnome/desktop/privacy/remove-old-trash-files true
dconf write /org/gnome/desktop/privacy/remember-recent-files false
# reset theme to adwaita
dconf write /org/gnome/desktop/interface/cursor-theme "'Adwaita'"
dconf write /org/gnome/desktop/interface/icon-theme "'Adwaita'"
dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
dconf write /org/gnome/desktop/sound/theme-name "'freedesktop'"
# add some keybindings
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:super']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-center "['<Super>F2']"
# setup gnome weather
dconf write /org/gnome/GWeather4/temperature-unit "'centigrade'"
dconf write /org/gnome/Weather/locations "[<(uint32 2, <('Oxford', 'EGTK', true, [(0.90465476585696891, -0.022965042297741389)], [(0.90324279449210554, -0.021951006002332681)])>)>]"
dconf write /org/gnome/shell/weather/locations "[<(uint32 2, <('Oxford', 'EGTK', true, [(0.90465476585696891, -0.022965042297741389)], [(0.90324279449210554, -0.021951006002332681)])>)>]"
# dash apps
dconf write /org/gnome/shell/favorite-apps "['firefox_firefox.desktop', 'emacs.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'transmission-gtk.desktop', 'virt-manager.desktop', 'com.obsproject.Studio.desktop', 'org.gnome.gThumb.desktop', 'org.gnome.SystemMonitor.desktop', 'org.gnome.Settings.desktop']"
# gnome world clocks
dconf write /org/gnome/shell/world-clocks/locations "[<(uint32 2, <('Beijing', 'ZBAA', true, [(0.69696814214530467, 2.0295270260429752)], [(0.69689057971334611, 2.0313596217575696)])>)>, <(uint32 2, <('New York', 'KNYC', true, [(0.71180344078725644, -1.2909618758762367)], [(0.71059804659265924, -1.2916478949920254)])>)>, <(uint32 2, <('Dallas', 'KDAL', true, [(0.57338429251143708, -1.690448351049749)], [(0.57217226606568217, -1.6895950770317414)])>)>]"
# nautilus
dconf write /org/gnome/nautilus/icon-view/default-zoom-level "'large'"
dconf write /org/gnome/nautilus/preferences/recursive-search "'never'"
dconf write /org/gnome/nautilus/preferences/default-sort-order "'mtime'"
dconf write /org/gnome/nautilus/preferences/default-sort-in-reverse-order true
dconf write /org/gnome/nautilus/icon-view/captions "['detailed_type', 'date_modified', 'size']"
dconf write /org/gnome/nautilus/preferences/show-delete-permanently true
dconf write /org/gnome/nautilus/preferences/show-create-link true
dconf write /org/gnome/nautilus/preferences/show-directory-item-counts "'never'"
# set power profile
dconf write /org/gnome/shell/last-selected-power-profile "'performance'"

#  _          _                          _
# | | ___   _| |__   ___ _ __ _ __   ___| |_ ___  ___
# | |/ / | | | '_ \ / _ \ '__| '_ \ / _ \ __/ _ \/ __|
# |   <| |_| | |_) |  __/ |  | | | |  __/ ||  __/\__ \
# |_|\_\\__,_|_.__/ \___|_|  |_| |_|\___|\__\___||___/
#
#

if [ ! -f "/usr/local/bin/kubectl" ]; then
    # check https://dl.k8s.io/release/stable.txt for latest
    curl -LO "https://dl.k8s.io/release/v1.33.1/bin/linux/amd64/kubectl"
    echo "5de4e9f2266738fd112b721265a0c1cd7f4e5208b670f811861f699474a100a3  kubectl" | sha256sum -c -
    chmod a+x kubectl
    sudo mv kubectl /usr/local/bin/kubectl
fi

if [ ! -f "/usr/local/bin/kind" ]; then
    # https://github.com/kubernetes-sigs/kind/releases
    curl -LO https://github.com/kubernetes-sigs/kind/releases/download/v0.29.0/kind-linux-amd64
    echo "c72eda46430f065fb45c5f70e7c957cc9209402ef309294821978677c8fb3284  kind-linux-amd64" | sha256sum -c -
    chmod +x kind-linux-amd64
    sudo mv kind-linux-amd64 /usr/local/bin/kind
fi

#                 _
#   ___ _   _ ___| |_ ___  _ __ ___
#  / __| | | / __| __/ _ \| '_ ` _ \
# | (__| |_| \__ \ || (_) | | | | | |
#  \___|\__,_|___/\__\___/|_| |_| |_|
#
#

# tablets
if [ `hostnamectl chassis` == "tablet" ]; then
    # suspend on power button press
    dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'suspend'"
    # don't lock on suspend
    dconf write /org/gnome/desktop/screensaver/ubuntu-lock-on-suspend false
    # turn on on-screen keyboard
    dconf write /org/gnome/desktop/interface/toolkit-accessibility true
    dconf write /org/gnome/desktop/a11y/applications/screen-keyboard-enabled true
    # set power saving profile
    dconf write /org/gnome/shell/last-selected-power-profile "'power-saver'"
    # reset to dynamic workspaces
    dconf write /org/gnome/mutter/dynamic-workspaces true

    # on tablets we don't want to hide the tab bar
    # snap
    for profile_dir in $(find snap/firefox/common/.mozilla/firefox/ -name '*.default*'); do
        rm "$profile_dir/chrome/userChrome.css"
    done

    # other
    for profile_dir in $(find .mozilla/firefox/ -name '*.default*'); do
        rm "$profile_dir/chrome/userChrome.css"
    done
fi

if [ `hostnamectl chassis` == "vm" ]; then
    # don't lock the screen in virtual machines
    dconf write /org/gnome/desktop/screensaver/lock-enabled false
fi

#   __             _
#  / _| ___  _ __ | |_ ___
# | |_ / _ \| '_ \| __/ __|
# |  _| (_) | | | | |_\__ \
# |_|  \___/|_| |_|\__|___/
#

mkdir -p .fonts
cd .fonts

# Download Iosevka
wget -nc https://github.com/be5invis/Iosevka/releases/download/v33.2.3/PkgTTC-Iosevka-33.2.3.zip
echo "ba2cb426b9d21d7c1a6a54efe63461cb1c166081d4aacf8467f8f672e0491caa  PkgTTC-Iosevka-33.2.3.zip" | sha256sum -c -
unzip PkgTTC-Iosevka-33.2.3.zip
# Download scientifica
wget -nc https://github.com/oppiliappan/scientifica/releases/download/v2.3/scientifica.tar
echo "f0857869a0e846c6f175dcb853dd1f119ea17a75218e63b7f0736d5a8e1e8a7f  scientifica.tar" | sha256sum -c -
tar xf scientifica.tar
# Download JetBrains Mono
wget -nc https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
echo "6f6376c6ed2960ea8a963cd7387ec9d76e3f629125bc33d1fdcd7eb7012f7bbf  JetBrainsMono-2.304.zip" | sha256sum -c -
unzip JetBrainsMono-2.304.zip
# Copy scientifica config (90 - fixed width font)
cat <<EOF > /tmp/91-scientifica.conf
<match target="scan">
    <test name="family">
        <string>scientifica</string>
    </test>
    <edit name="spacing">
        <int>90</int>
    </edit>
</match>
EOF
sudo cp /tmp/91-scientifica.conf /etc/fonts/conf.d/91-scientifica.conf

cd ..
