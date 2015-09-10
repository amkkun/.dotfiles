# host local (pre)
host_rc="$HOME/.zsh/$(hostname).pre.zshrc"
if [ -r $host_rc ]; then
    source $host_rc
fi

if [ "$WORKSPACE" '==' "" ]; then
    export WORKSPACE=$HOME/work
fi

# antigen
source ~/.zsh/antigen/antigen.zsh
antigen use oh-my-zsh

antigen_plugins=( \
    git \
    command-not-found \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-completions \
    golang \
    cabal \
    brew \
    brew-cask)
for p in $antigen_plugins; do
    antigen bundle $p
done

antigen apply

# completion
autoload -U compinit promptinit
compinit -u # not secure...
promptinit


# prompt
autoload -Uz colors
colors

ZSH_THEME_GIT_PROMPT_PREFIX="[%F{yellow}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_SUFFIX="%f]"

local prompt_user="%F{green}%n%f%F{white}@%f%F{green}%m%f"

PROMPT="%F{green}%c%f %F{white}%#%f "
RPROMPT='$(git_prompt_info)[$prompt_user]' # XXX: single quote
SPROMPT="%F{yellow}Did you mean%f %B%F{yellow}%r%f%b %F{yellow}? \
[y(yes),n(no),a(abort),e(edit)]%f %F{white}>%f "

setopt transient_rprompt

# source ~/.zsh/prompt.zshrc

# zsh option
bindkey -e

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8

setopt auto_pushd
setopt append_history
setopt auto_menu
setopt auto_param_slash
setopt pushd_ignore_dups
setopt list_packed
setopt hist_ignore_dups
setopt correct
setopt no_correct_all

# appearance
export TERM=xterm-256color

# editor settings
export ALTERNATE_EDITOR="" # for emacs server
export EDITOR="emacsclient -t"
export GIT_EDITOR="emacsclient -t"
export VISUAL="emacsclient -c -a emacs"

alias e="emacsclient -t"
alias v="vim"
alias vi="vim"

# alias
alias la="ls -la"
alias platex="platex -kanji=utf8 -shell-escape"
alias coq_make="coq_makefile -f Make -o Makefile"

# PATH
export PATH=$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:$PATH

# OS
case ${OSTYPE} in
    darwin*)
        alias ls="ls -G"
        ;;
    linux*)
        alias ls="ls --color"
        export LSCOLORS=gxfxcxdxbxegedabagacad
        ;;
esac

# anyenv
if [ -d $HOME/.anyenv ]; then
    export PATH=$HOME/.anyenv/bin:$PATH
    eval "$(anyenv init -)"
fi

# haskell
if [ -d $HOME/.cabal ]; then
    export PATH=$HOME/.cabal/bin:$PATH
fi

# ruby
if [ -d $HOME/.rbenv ]; then
    export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
    eval "$(rbenv init -)"
fi

# ocaml
if [ -d $HOME/.opam ]; then
    eval `opam config env`
    . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
    export OCAMLPARAM="_,bin-annot=1"
    export OPAMKEEPBUILDDIR=1
    # -f-defer-pop
    # opam remote add ocl-opam-repo-dev git://github.com/ocamllabs/opam-repo-dev.git
    # opam switch 4.01.0+clang-fix
fi

# golang
if type go > /dev/null; then
    mkdir -p $WORKSPACE/go
    export GOPATH=$WORKSPACE/go
    export PATH=$GOPATH/bin:$PATH
fi

# python
case ${OSTYPE} in
    darwin*)
        local python_version=`python -c "import sys; print(\"%s.%s\" % sys.version_info[:2])"`
        local python_user_dir=$HOME/Library/Python/$python_version
        export PATH=$python_user_dir/bin:$PATH
        ;;
esac

# direnv
if type direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

# ghq, peco
# http://r7kamura.hatenablog.com/entry/2014/06/28/143954
if hash ghq 2>/dev/null && hash peco 2>/dev/null; then
    while-read() {
        while read LINE; do $@ $LINE; done
    }
    # ghq cd
    c() {
        ghq list -p | peco --query="$*" | while-read cd
        echo -n "pwd: "
        pwd
    }
    # find cd
    fc() {
        find . -type d -name "*${1}*" | peco --query=$1 | while-read cd
    }
    # ghq git cd
    ggc() {
        ggc-internal() {
            for dir in $(ghq list -p); do
                cd $dir
                for d in $(git ls-tree -d -r --name-only HEAD); do
                    echo $dir"/"$d
                done
            done
        }
        dir=$(ggc-internal | peco --query="$*")
        if [ "$dir" != "" ]; then
            cd $dir
            echo -n "pwd: "
            pwd
        fi
        unset d
        unset dir
    }
    # find emacs
    fe() {
        file=$(find . -type f -name "*${1}*" | peco --query="$*")
        if [ "$file" != "" ]; then
            e $file
        fi
    }
    # git emacs
    ge() {
        file=$(git ls-files | peco --query="$*")
        if [ "$file" != "" ]; then
            e $file
        fi
    }
    # ghq git emacs
    gge() {
        gge-internal() {
            for dir in $(ghq list -p); do
                cd $dir
                for file in $(git ls-files); do
                    echo $dir"/"$file;
                done
            done
        }
        file=$(gge-internal | peco --query="$*")
        if [ "$file" != "" ]; then
            e $file
        fi
        unset dir
        unset file
    }
    # process kill
    pk() {
        ps ax -o pid,lstart,command | peco --query="$LBUFFER" | awk '{print $1}' | xargs kill
    }
fi

# os local (post)
case ${OSTYPE} in
    darwin*)
        os_rc="$HOME/.zsh/darwin.post.zshrc"
        if [ -r $os_rc ]; then
            source $os_rc
        fi
        ;;
    linux*)
        os_rc="$HOME/.zsh/linux.post.zshrc"
        if [ -r $os_rc ]; then
            source $os_rc
        fi
        ;;
esac

# host local (post)
host_rc="$HOME/.zsh/$(hostname).post.zshrc"
if [ -r $host_rc ]; then
    source $host_rc
fi

# tmux (create or attach session)
if [ -z "$TMUX" ] && type tmux >/dev/null; then
    if tmux has-session; then
        if type pecoc >/dev/null; then
            local name=$(tmux ls | peco --prompt "TMUX-SESSION>" | awk -F':' '{print $1}')
            if [ -n "$name" ]; then
                tmux a -t $name
            fi
        else
            if read -q "?$(tput setaf 2)[tmux]$(tput sgr0) Is it OK to attach the last session?: (y/N) "; then
                tmux attach
            elif echo "" && read -q "?$(tput setaf 2)[tmux]$(tput sgr0) Is it OK to create new session?: (y/N) "; then
                tmux new
            else
                echo "" && echo 'If you want to attach manually, select session name by `tmux ls` and attach by `tmux a -t {name}`.'
            fi
        fi
    else
        tmux new -s tmux
    fi
fi
