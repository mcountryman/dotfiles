set PATH /var/lib/snapd/snap/bin $PATH
set PATH $HOME/.cargo/bin $PATH
set XDG_DATA_DIRS /var/lib/snapd/desktop/:$XDG_DATA_DIRS

alias dotfiles "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

if status is-interactive
    set -l onedark_options '-b'

    if set -q VIM
        # Using from vim/neovim.
        set onedark_options "-256"
    else if string match -iq "eterm*" $TERM
        # Using from emacs.
        function fish_title; true; end
        set onedark_options "-256"
    end

    set_onedark $onedark_options
end

