# Georg's zshrc

# always include the general profile
source /etc/profile


# -- load interesting modules --------------------------------------------------

#unalias run-help
autoload run-help

fpath=(~/.zsh/functions $fpath)

autoload -U compinit
compinit

autoload zargs
autoload zed
autoload zmv

zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile


# -- shell options -------------------------------------------------------------

setopt append_history        # append to history file
setopt inc_append_history    # incrementally
setopt extended_history      # save beginning and duration of commands
#setopt hist_ignore_all_dups # remove dups from history
setopt hist_ignore_space     # do not enter in history if beginning with space
setopt auto_cd               # automatically cd into directory given as command
setopt extended_glob         # activate extended glob operators
setopt long_list_jobs        # list PID with jobs
setopt notify                # report status of background jobs immediately
setopt hash_list_all         # make sure completion gets new commands
setopt complete_in_word      # complete in the middle of words
#setopt no_hup               # don't SIGHUP jobs when exiting
setopt auto_pushd            # cd pushes onto directory stack
setopt pushd_ignore_dups     # don't push the same dir twice
setopt pushd_minus           # exchange + and - for pushd
setopt nomatch               # complain about empty glob match
setopt nobeep                # do not beep
setopt no_glob_dots          # do not match dotfiles when globbing
setopt correct               # enable command typo correction
setopt no_correct_all        # but don't correct the whole command line
setopt no_clobber            # don't allow to clobber files by default
setopt equals                # allow = expansion
setopt always_to_end         # jump to end after completion
setopt interactive_comments  # comments allowed on command line
setopt promptsubst           # substitute in prompt string
setopt transient_rprompt     # remove right prompt on time
unsetopt bgnice

ttyctl -f                    # lock tty settings against changes by programs

# -- set up often used aliases and functions -----------------------------------

# the usual "ls" and "cd" aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

export CLICOLOR=1
if ls --color &>/dev/null; then export LS_OPTIONS="--color=auto"; fi
alias ls="/bin/ls ${LS_OPTIONS}"
alias l="ls -l"
alias la="ls -a"
alias ll="ls -la"
# list by size
alias lsize="ls -lSrah"
# list only directories and symbolic links that point to directories
alias lsd="ls -ld *(-/DN)"
# list only files beginning with "."
alias lsh="ls -ld .*"

alias o="less"
alias mv="nocorrect /bin/mv"  # no spelling correction on mv
alias cp="nocorrect cp"       # no spelling correction on cp
alias mkdir="nocorrect mkdir" # no spelling correction on mkdir
alias md="mkdir -p"
alias grep=egrep
alias help=run-help
alias da="du -sh"
alias ren="noglob zmv -W"
alias findn="noglob find -iname"
alias ssize='du -c * | sort -n'
alias gdbrun="gdb -ex run --args"

function rgrep {
    find . -name .svn -prune -o -type f -print0 | \
        xargs -0 grep --color=auto --binary-files=without-match -nH "$@"
}

function tgrep {
    grep --color=auto -nH "$2" $(eval echo '**/*.'"$1")
}

alias rigrep="rgrep -i"

# if changing directory to a file, change to the directory it is in
cd () {
    if (( $# != 1 )); then
        builtin cd "$@"
        return
    fi
  
    if [[ -f "$1" ]]; then
        builtin cd "$1:h"
    else
        builtin cd "$1"
    fi
}


# -- set up the prompt ---------------------------------------------------------

EXITCODE="%(?..%?%1v )"

if (( EUID == 0 )); then
    PS1="%B%F{red}%U${USER}%u@%m %F{blue}%~%F{none}%b\${vcs_info_msg_0_} %F{blue}#%F{none} "
else
    PS1="%F{green}%U${USER}%u@%F{blue}%m %F{none}%B%~%b\${vcs_info_msg_0_}>%F{none} "
    if [ "x$showSHLVL" '!=' "x" ]; then
	PS1="[%L] $PS1"
    fi
fi
RPROMPT="$EXITCODE"

autoload -Uz vcs_info

# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stagedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository
# %s - vcs name
FMT_BRANCH=" %F{3}[%F{5}%b%c%u%F{3}]%f"
FMT_ACTION=" %F{3}[%F{5}%b%F{3}//%F{blue}%a%F{3}]%f"
FMT_UNSTAGED="%F{red} @%f"
FMT_STAGED="%F{green} @%f"

zstyle ':vcs_info:*' disable cdv cvs mtn p4 svk tla bzr

zstyle ':vcs_info:*' unstagedstr   "${FMT_UNSTAGED}"
zstyle ':vcs_info:*' stagedstr     "${FMT_STAGED}"
zstyle ':vcs_info:*' actionformats "${FMT_ACTION}"
zstyle ':vcs_info:*' formats       "${FMT_BRANCH}"
zstyle ':vcs_info:*' nvcsformats   ""
zstyle ':vcs_info:*' check-for-changes true

#zstyle ':vcs_info:*' actionformats '%s%F{3}-[%F{5}%b%F{3}|%F{1}%a%F{3}]%f '
#zstyle ':vcs_info:*' formats       '%s%F{3}-[%F{5}%b%F{3}]%f '

precmd() {
    vcs_info
}

case $TERM in
    xterm*|rxvt)
        precmd() {
            vcs_info
            print -Pn "\e]0;%m [%n] %~\a"
        } ;;
esac

PS2='\`%_> '
PS3='?# '
PS4='+%N:%i:%_> '


# -- shell environment ---------------------------------------------------------

# for csh compatibility
setenv() {
    typeset -x "${1}${1:+=}${(@)argv[2,$#]}"
}

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

# Some environment variables
export GREP_COLOR='04'
export LESS='-crx3Mi'
export HELPPAGEROPTS='-E~'
export SHELL=/bin/zsh
export PAGER=less

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

HISTSIZE=20000
HISTFILE=~/.zshhistory
SAVEHIST=20000
DIRSTACKSIZE=20

# automatically go to interested dirs
hash -d doc=/usr/share/doc
hash -d linux=/lib/modules/$(command uname -r)/build/
hash -d log=/var/log
hash -d src=/usr/src


# -- ZLE and key bindings ------------------------------------------------------

# load emacs key bindings
bindkey -e

# no slash as wordchar
WORDCHARS=${WORDCHARS:s_/__}

insert-datestamp() {
    LBUFFER+=${(%):-'%D{%Y-%m-%d}'};
}
zle -N insert-datestamp
bindkey "^Xd" insert-datestamp

sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
}
zle -N sudo-command-line
bindkey "^Xo" sudo-command-line

# to insert additional options (if not supported after args)
function jump_after_first_word() {
    local words
    words=(${(z)BUFFER})

    if (( ${#words} <= 1 )) ; then
        CURSOR=${#BUFFER}
    else
        CURSOR=${#${words[1]}}
    fi
}
zle -N jump_after_first_word
bindkey '^X1' jump_after_first_word

bindkey " "     magic-space    # also do history expansion on space
bindkey "\e[4~" end-of-line
bindkey "\e[F"  end-of-line
bindkey "\e[8~" end-of-line
bindkey "\e[1~" beginning-of-line
bindkey "\e[H"  beginning-of-line
bindkey "\e[7~" beginning-of-line
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[5~" history-beginning-search-backward
bindkey "\e[6~" history-beginning-search-forward
# bind some keycode variations for different terminals
bindkey "\e[5C" forward-word
bindkey "\e[5D" backward-word
bindkey "\e[1;3C" forward-word
bindkey "\e[1;3D" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e."   insert-last-word
bindkey "^I"    expand-or-complete
bindkey "^r"    history-incremental-pattern-search-backward
bindkey "^s"    history-incremental-pattern-search-forward
# xterm
bindkey "ÿ"	backward-kill-word
bindkey "®"	insert-last-word

bindkey -s "^x^f" $'emacsclient -t '

# when inserting URLs, automatically quote active characters
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# call run-help for the 1st word on the command line
alias run-help >&/dev/null && unalias run-help
for rh in run-help{,-git}; do
    autoload -U $rh
done; unset rh


# -- completion control --------------------------------------------------------

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

#zstyle ':completion:*' completer _complete _correct _approximate _prefix
zstyle ':completion:*' completer _complete _prefix
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:predict:*' completer _complete

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache/$HOST

# Expand partial paths
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' squeeze-slashes 'yes'
# Don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# Separate matches into groups
zstyle ':completion:*:matches' group 'yes'

# Describe each match group
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

# Automatically complete 'cd -<tab>' and 'cd -<ctrl-d>' with menu
#zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

# Messages/warnings format
zstyle ':completion:*:messages' format '%B%U%d%u%b' 
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'
 
# Describe options in full
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# kill
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# menu for kill
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# kill menu extension!
zstyle ':completion:*:processes' command 'ps --forest -U $(whoami) | sed "/ps/d"'
#zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes' insert-ids menu yes select

# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

# remove uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
    adm alias apache at bin cron cyrus daemon ftp games gdm guest \
    haldaemon halt mail man messagebus mysql named news nobody nut \
    lp operator portage postfix postgres postmaster qmaild qmaill \
    qmailp qmailq qmailr qmails shutdown smmsp squid sshd sync \
    uucp vpopmail xfs

# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:' max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

# complete manual by their section
zstyle ':completion:*:manuals' separate-sections true
#zstyle ':completion:*:manuals.*' insert-sections true
#zstyle ':completion:*:man:*' menu yes select

for compcom in cp df feh head hnb mv pal stow tail uname; do
    [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
done; unset compcom


# -- more helper functions -----------------------------------------------------

ansi-colors() {
    typeset esc="\033[" line1 line2
    echo " _ _ _40 _ _ _41_ _ _ _42 _ _ 43_ _ _ 44_ _ _45 _ _ _ 46_ _ _ 47_ _ _ 49_ _"
    for fore in 30 31 32 33 34 35 36 37; do
        line1="$fore "
        line2="   "
        for back in 40 41 42 43 44 45 46 47 49; do
            line1="${line1}${esc}${back};${fore}m Normal ${esc}0m"
            line2="${line2}${esc}${back};${fore};1m Bold   ${esc}0m"
        done
        echo -e "$line1\n$line2"
    done

    echo
    for i in `seq 16 6 250`; do
        for j in `seq $i $(( i+5 ))`; do
            printf "\x1b[48;5;%sm%3d\e[0m " "$j" "$j"
	done
	printf "    "
        for j in `seq $i $(( i+5 ))`; do
            printf "\x1b[38;5;%sm%3d\e[0m " "$j" "$j"
	done
	printf "    "
        for j in `seq $i $(( i+5 ))`; do
            printf "\x1b[1;38;5;%sm%3d\e[0m " "$j" "$j"
	done
	printf "\n"
    done
}

any() {
    emulate -L zsh
    if [[ -z "$1" ]] ; then
        echo "any - grep for process(es) by keyword" >&2
        echo "Usage: any <keyword>" >&2 ; return 1
    else
        local STRING=$1
        local LENGTH=$(expr length $STRING)
        local FIRSCHAR=$(echo $(expr substr $STRING 1 1))
        local REST=$(echo $(expr substr $STRING 2 $LENGTH))
        ps xauwww| grep "[$FIRSCHAR]$REST"
    fi
}

bk() {
    emulate -L zsh
    cp -b $1 $1_`date --iso-8601=m`
}

new() {
    emulate -L zsh
    # files modified in the last $1 days
    ls -ld *(md-${1:=1})
}

vim() {
    VIM_PLEASE_SET_TITLE='yes' command vim ${VIM_OPTIONS} "$@"
}

# find history events by search pattern and list them by date
whatwhen()  {
    emulate -L zsh
    local usage help ident format_l format_s first_char remain first last
    usage='USAGE: whatwhen [options] <searchstring> <search range>'
    help='Use `whatwhen -h'"' for further explanations."
    ident=${(l,${#${:-Usage: }},, ,)}
    format_l="${ident}%s\t\t\t%s\n"
    format_s="${format_l//(\\t)##/\\t}"
    # Make the first char of the word to search for case
    # insensitive; e.g. [aA]
    first_char=[${(L)1[1]}${(U)1[1]}]
    remain=${1[2,-1]}
    # Default search range is `-100'.
    first=${2:-\-100}
    # Optional, just used for `<first> <last>' given.
    last=$3
    case $1 in
        ("")
            printf '%s\n\n' 'ERROR: No search string specified. Aborting.'
            printf '%s\n%s\n\n' ${usage} ${help} && return 1
        ;;
        (-h)
            printf '%s\n\n' ${usage}
            print 'OPTIONS:'
            printf $format_l '-h' 'show help text'
            print '\f'
            print 'SEARCH RANGE:'
            printf $format_l "'0'" 'the whole history,'
            printf $format_l '-<n>' 'offset to the current history number; (default: -100)'
            printf $format_s '<[-]first> [<last>]' 'just searching within a give range'
            printf '\n%s\n' 'EXAMPLES:'
            printf ${format_l/(\\t)/} 'whatwhen grml' '# Range is set to -100 by default.'
            printf $format_l 'whatwhen zsh -250'
            printf $format_l 'whatwhen foo 1 99'
        ;;
        (\?)
            printf '%s\n%s\n\n' ${usage} ${help} && return 1
        ;;
        (*)
            # -l list results on stout rather than invoking $EDITOR.
            # -i Print dates as in YYYY-MM-DD.
            # -m Search for a - quoted - pattern within the history.
            fc -li -m "*${first_char}${remain}*" $first $last
        ;;
    esac
}


# -- near-global aliases from grml config --------------------------------------

# just type the abbreviation key and afterwards ',.' to expand it
declare -A abk
abk=(
    '...'  '../..'
    '....' '../../..'
    'BG'   '& exit'
    'C'    '| wc -l'
    'G'    '|& grep --color=auto '
    'H'    '| head'
    'Hl'   ' --help |& less -r'    #d (Display help in pager)
    'L'    '| less'
    'LL'   '|& less -r'
    'N'    '&>/dev/null'           #d (No Output)
    'R'    '| tr A-z N-za-m'       #d (ROT13)
    'SL'   '| sort | less'
    'S'    '| sort -u'
    'T'    '| tail'
    'V'    '|& vim -'
    'co'   './configure && make && sudo make install'
)

globalias() {
    emulate -L zsh
    setopt extendedglob
    local MATCH

    if (( NOABBREVIATION > 0 )) ; then
        LBUFFER="${LBUFFER},."
        return 0
    fi

    matched_chars='[.-|_a-zA-Z0-9]#'
    LBUFFER=${LBUFFER%%(#m)[.-|_a-zA-Z0-9]#}
    LBUFFER+=${abk[$MATCH]:-$MATCH}
}

zle -N globalias
bindkey ",." globalias


# -- highlighting and suggestions ---------------------------------------------

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[command]='bold'
ZSH_HIGHLIGHT_STYLES[alias]='bold'
ZSH_HIGHLIGHT_STYLES[function]='bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=126,bold,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=126,bold'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=126,bold,underline'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=31'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=22'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=22'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=88'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='underline'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='underline'
ZSH_HIGHLIGHT_STYLES[assign]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=240'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=240'

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

ZSH_HIGHLIGHT_FILES=(
    /usr/share/zsh/site-contrib/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
)
for f in $ZSH_HIGHLIGHT_FILES; do
    if [ -f $f ]; then source $f; break; fi
done

ZSH_HIGHLIGHT_PATTERNS+=('rm ' 'fg=red,bold')

ZSH_SUGGESTIONS_FILE=$HOME/devel/ext/zsh-autosuggestions/zsh-autosuggestions.zsh
if [ -f $ZSH_SUGGESTIONS_FILE ]; then
    source  $ZSH_SUGGESTIONS_FILE
fi

[ -r /usr/share/z/z.sh ] && source /usr/share/z/z.sh


# -- directory up -------------------------------------------------------------

bd () {
  (($#<1)) && {
    print -- "usage: $0 <name-of-any-parent-directory>"
    print -- "       $0 <number-of-folders>"
    return 1
  } >&2
  # example:
  #   $PWD == /home/arash/abc ==> $num_folders_we_are_in == 3
  local num_folders_we_are_in=${#${(ps:/:)${PWD}}}
  local dest="./"

  # First try to find a folder with matching name (could potentially be a number)
  # Get parents (in reverse order)
  local parents
  local i
  for i in {$((num_folders_we_are_in+1))..2}
  do
    parents=($parents "$(echo $PWD | cut -d'/' -f$i)")
  done
  parents=($parents "/")
  # Build dest and 'cd' to it
  local parent
  foreach parent (${parents})
  do
    if [[ $1 == $parent ]]
    then
      cd $dest
      return 0
    fi
    dest+="../"
  done

  # If the user provided an integer, go up as many times as asked
  dest="./"
  if [[ "$1" = <-> ]]
  then
    if [[ $1 -gt $num_folders_we_are_in ]]
    then
      print -- "bd: Error: Can not go up $1 times (not enough parent directories)"
      return 1
    fi
    for i in {1..$1}
    do
      dest+="../"
    done
    cd $dest
    return 0
  fi

  # If the above methods fail
  print -- "bd: Error: No parent directory named '$1'"
  return 1
}
_bd () {
  # Get parents (in reverse order)
  local num_folders_we_are_in=${#${(ps:/:)${PWD}}}
  local i
  for i in {$((num_folders_we_are_in+1))..2}
  do
    reply=($reply "`echo $PWD | cut -d'/' -f$i`")
  done
  reply=($reply "/")
}
compctl -V directories -K _bd bd


# -- local overrides ----------------------------------------------------------

if [ -f /etc/zsh/zshrc.local ]; then
    source /etc/zsh/zshrc.local
fi

