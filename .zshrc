# Adapted from https://github.com/mischavandenburg/dotfiles/blob/b7126e41c4711badb67d8dd80b903086ed8c935f/.zshrc

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob

path=(
    $path                           
    $HOME/bin
    $HOME/.local/bin
    $HOME/.docker/bin
    $HOME/.config/scripts
)

# Remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))

export PATH

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

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

fpath+=("$(brew --prefix)/share/zsh/site-functions")

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

# Util to change directory when exiting lazygit after changing repos or worktrees
# https://github.com/jesseduffield/lazygit/blob/master/README.md#changing-directory-on-exit
lg() {
    export LAZYGIT_NEW_DIR_FILE="${TMPDIR:-/tmp}/lazygit-newdir"

    lazygit "$@"

    if [ -f "$LAZYGIT_NEW_DIR_FILE" ]; then
        cd "$(cat "$LAZYGIT_NEW_DIR_FILE")"
        rm -f "$LAZYGIT_NEW_DIR_FILE" > /dev/null
    fi
}

# Diff a branch or commit against a base (defaults to the latest origin default branch)
# Uses the three-dot form so it only shows the changes made since the merge base, like a PR
gd() {
    local target="$1"
    local base="$2"
    local ref

    if [ -z "$target" ]; then
        echo "Usage: gd <branch|sha> [base branch|sha]"
        return 1
    fi

    if [ -z "$base" ]; then
        base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD)

        # origin/HEAD is only set on clone, so ask the remote when it is missing
        if [ -z "$base" ]; then
            git remote set-head origin --auto > /dev/null 2>&1

            base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD)
        fi

        if [ -z "$base" ]; then
            echo "Could not detect the default branch for origin. Pass a base branch or commit."
            return 1
        fi

        git fetch --quiet origin "${base#origin/}" || echo "Could not fetch $base. Using the local ref."
    fi

    for ref in "$base" "$target"; do
        if ! git rev-parse --verify --quiet "$ref^{commit}" > /dev/null; then
            echo "Unknown branch or commit: $ref"
            return 1
        fi
    done

    git diff --stat -p "$base...$target" --
}

# ~~~~~~~~~~~~~~~ Scripts ~~~~~~~~~~~~~~~~~~~~~~~~

