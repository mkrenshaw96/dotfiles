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
export GOPATH="$HOME/go/"
export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse --border top --style minimal'
export BAT_THEME="Catppuccin Mocha"
export DISABLE_AUTO_UPDATE="true" # to update run "omz update"

# --- Jellyfish --- #
export SOURCE_CODE_DIR="$HOME/code"
export JF_MANAGED_HOMEBREW="true"
export DIRENV_LOG_FORMAT=''
# --- Jellyfish --- #

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


# --- Jellyfish --- #
alias sso="aws sso logout && aws sso login"
alias p='pdm run'
alias m='p python manage.py'
alias t='p pytest --reuse-db --ds=jellyfish.settings.test'
# --- Jellyfish --- #

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
  compinit
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

# Shell plus
sp() {
    COMPANY_SLUG=$(gum input --header "Enter a company slug..." --value "orthogonal-networks")

    if [ -z "$COMPANY_SLUG" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    cd ~/code/jellyfish && m shell_plus -c "$COMPANY_SLUG"
}

# Switch to a remote database
swdb() {
    CHOICE=$(gum choose --header "Choose a database..." "local" "stg-umibozu" "stg-sandbox-ro-1" "stg-sandbox-2" "stg-sandbox-3" "stg-sandbox-4" "stg-sandbox-5" "stg-sandbox-6" "stg-sandbox-7" "stg-sandbox-8" "stg-looking-glass" "stg-looking-glass-2")

    if [ -z "$CHOICE" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    cd ~/code/jellyfish && scripts/switchdb "$CHOICE"
}

shdb() {
    cd ~/code/jellyfish && scripts/switchdb show
}

# Change PGPASSWORD for connecting to remote dbs
pgp() {
    CHOICE=$(gum choose --header "Choose one..." "local" "remote")

    if [ "$CHOICE" = "local" ]; then
        export PGPASSWORD=jellyfish
    else
        export PGPASSWORD=$(gum spin --spinner dot -- aws secretsmanager get-secret-value --secret-id $DB_CREDS_SECRET_ARN --query SecretString --output text)
    fi
}

# SSH into a staging environment
stg-ssh() {
    CHOICE=$(gum choose --header "Choose an environment..." "stg-umibozu" "stg-sandbox-ro-1" "stg-sandbox-2" "stg-sandbox-3" "stg-sandbox-4" "stg-sandbox-5" "stg-sandbox-6" "stg-sandbox-7" "stg-sandbox-8" "stg-looking-glass" "stg-looking-glass-2")

    if [ -z "$CHOICE" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    cd ~/code/jellyfish && scripts/ssh -e "$CHOICE"
}

# SSH into production
p-ssh() {
    if ! gum confirm "Woahhh there buddy. You chose prd. You sure about that?" --default="No"; then
        echo "Exiting..."
        return 1
    fi

    cd ~/code/jellyfish && scripts/ssh -e prd
}

# Deploy a commit SHA to a staging environment
stg-dp() {
    CHOICE=$(gum choose --header "Choose an environment..." "stg-umibozu" "stg-sandbox-ro-1" "stg-sandbox-2" "stg-sandbox-3" "stg-sandbox-4" "stg-sandbox-5" "stg-sandbox-6" "stg-sandbox-7" "stg-sandbox-8" "stg-looking-glass" "stg-looking-glass-2")

    if [ -z "$CHOICE" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    COMMIT_SHA=$(gum input --header "Enter commit SHA...")

    if [ -z "$COMMIT_SHA" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    cd ~/code/jellyfish && m staging deploy -e "$CHOICE" --deploy-type sha --deploy-value "$COMMIT_SHA"
}

# Deploy a db snapshot tier to a staging database
stg-db() {
    CHOICE=$(gum choose --header "Choose a database..." "stg-umibozu" "stg-sandbox-ro-1" "stg-sandbox-2" "stg-sandbox-3" "stg-sandbox-4" "stg-sandbox-5" "stg-sandbox-6" "stg-sandbox-7" "stg-sandbox-8" "stg-looking-glass" "stg-looking-glass-2")

    if [ -z "$CHOICE" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    TIER_CHOICE=$(gum choose --header "Choose snapshot tier..." "small" "medium" "large" "prd")

    if [ -z "$TIER_CHOICE" ]; then
        echo "Nothing selected. Exiting..."
        return 1
    fi

    if [ "$TIER_CHOICE" = "prd" ]; then
        if ! gum confirm "Woahhh there buddy. You chose prd. You sure about that?" --default="No"; then
            echo "Exiting..."
            return 1
        fi
    fi

    cd ~/code/jellyfish && m staging database -e "$CHOICE" --snapshot-tier "$TIER_CHOICE"
}

spa() {
  cd ~/code/jellyfish && m shell_plus -c None --command "count = JFUser.objects.filter(email='michael.crenshaw@jellyfish.co').update(is_admin=True); print(f'{count} user(s) updated.')"
}

# ~~~~~~~~~~~~~~~ Scripts ~~~~~~~~~~~~~~~~~~~~~~~~

