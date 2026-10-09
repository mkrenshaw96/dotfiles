# Adapted from https://github.com/mischavandenburg/dotfiles/blob/b7126e41c4711badb67d8dd80b903086ed8c935f/.zshrc

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob

path=(
    $path                           
    $HOME/bin
    $HOME/.local/bin
    $HOME/.docker/bin
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

# Open a Claude Code worktree in a tmux session: a shell on the left, Claude on the right
cw() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "Usage: cw <worktree-name>"
        return 1
    fi

    local git_common_dir
    git_common_dir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || {
        echo "Not in a git repository"
        return 1
    }

    local repo_root="${git_common_dir:h}"

    local worktree_path="$repo_root/.claude/worktrees/$name"

    # Same name the repo's WorktreeRemove hook kills
    local session="${${name:t}//[.:]/-}"

    # A locked worktree makes the WorktreeRemove hook fail before it kills the session
    local lock_reason="cw: keep on Claude exit"

    if ! tmux has-session -t "=$session" 2>/dev/null; then
        # The Claude pane drops to a shell when Claude exits, so the pane stays open
        if [ -d "$worktree_path" ]; then
            git -C "$repo_root" worktree lock --reason "$lock_reason" "$worktree_path" 2>/dev/null

            tmux new-session -d -s "$session" -c "$worktree_path"

            tmux split-window -h -t "=$session:" -c "$worktree_path" "claude; exec \$SHELL -l"
        else
            # Retries until Claude creates the worktree and git releases its own temporary lock
            tmux new-session -d -s "$session" -c "$repo_root" \
                "until git -C '$repo_root' worktree lock --reason '$lock_reason' '$worktree_path' 2>/dev/null; do sleep 0.5; done; cd '$worktree_path' && exec \$SHELL -l"

            tmux split-window -h -t "=$session:" -c "$repo_root" \
                "claude -w '$name'; cd '$worktree_path' 2>/dev/null || cd '$repo_root'; exec \$SHELL -l"
        fi
    fi

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "=$session"
    else
        tmux attach-session -t "=$session"
    fi
}


# ~~~~~~~~~~~~~~~ Scripts ~~~~~~~~~~~~~~~~~~~~~~~~

