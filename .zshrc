# Adapted from https://github.com/mischavandenburg/dotfiles/blob/b7126e41c4711badb67d8dd80b903086ed8c935f/.zshrc

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob

path=(
    $path                           
    $HOME/bin
    $HOME/.local/bin
)

# Remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))

export PATH

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

# export TERM="tmux-256color" -- set by alacritty
export VISUAL="nvim"
export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH="$HOME/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX="true" # see https://github.com/ohmyzsh/ohmyzsh/issues/6835#issuecomment-390216875
export GOBIN="$HOME/.local/bin"
export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse --border top --style minimal'
export BAT_THEME="Catppuccin Mocha"
export DISABLE_AUTO_UPDATE="true" # to update run "omz update"


# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
setopt SHARE_HISTORY      # Share history between sessions

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~

PURE_GIT_PULL=0

if [[ "$OSTYPE" == darwin* ]]; then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
else
  fpath+=($HOME/.zsh/pure)
fi

# change the path color
zstyle :prompt:pure:path color white

# change the color for both `prompt:success` and `prompt:error`
zstyle ':prompt:pure:prompt:*' color red

autoload -U promptinit; promptinit

prompt pure

# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~

alias update="source ~/.zshrc"
alias v="nvim"
alias cd="z"
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias cl="clear"
alias lg="lazygit"


# --- Allera --- #
alias sso="aws sso logout && aws sso login --sso-session allera"
# --- Allera --- #

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~ Completion ~~~~~~~~~~~~~~~~~~~~~~~~

fpath=($fpath "/Users/michael/.zfunctions")

fpath+=~/.zfunc

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# Initialize the completion system
autoload -U +X bashcompinit && bashcompinit
# autoload -Uz compinit && compinit -u # loads the zsh completion initialization module, only
# Only run compinit without -C if it's been 24 hours since the dumpfile was last opened. Source: https://notes.billmill.org/computer_usage/zsh/profiling_zsh_startup.html
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit -u
done
compinit -C

# # Cache completion if nothing changed - faster startup time
# typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
# if [ $(date +'%j') != "$updated_at" ]; then
#     compinit -i -u
# else
#     compinit -C -i -u
# fi

zstyle ':completion:*' menu select

# ~~~~~~~~~~~~~~~ Completion ~~~~~~~~~~~~~~~~~~~~~~~~



# ~~~~~~~~~~~~~~~ Sourcing ~~~~~~~~~~~~~~~~~~~~~~~~

source $ZSH/oh-my-zsh.sh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(mise activate zsh)"

# ~~~~~~~~~~~~~~~ Sourcing ~~~~~~~~~~~~~~~~~~~~~~~~



# ~~~~~~~~~~~~~~~ Scripts ~~~~~~~~~~~~~~~~~~~~~~~~

check-port() {
    if (nc -zv localhost "$1" 2>&1 >/dev/null); then
        echo 'Online'
    else
        echo 'Offline'
    fi
}

kill-port() { (npx kill-port "$1"); }

# Script from rwx.gg
# Mischa's explanation:
# it takes the content of the $PATH environment variable and replaces every : with a newline character.
# the// is actually a syntax for search and replace, similar to s/123/456/g in sed and vim
# https://mischavandenburg.com/zet/slash-syntax-replace/
path() {
    echo -e ${PATH//:/\\n}
}

# Switch to an AWS profile
swp() {
    CHOICE=$(gum choose --header "Choose a profile..." "allera-dev" "allera-deploy")

    if [ -z "$CHOICE" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    export AWS_PROFILE="$CHOICE"
}


# ~~~~~~~~~~~~~~~ Scripts ~~~~~~~~~~~~~~~~~~~~~~~~

