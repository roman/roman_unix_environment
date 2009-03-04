#==============================================================================
# BASH RC
#   This file is run once for every bash shell.
#   It should be used to define all bash aliases, functions, settings and local variables
#
#   Environment variables that are global and never change can be defined in bash_profile
#
#   This file might be executed without calling bash_profile first. In most cases it's OK,
#   since the execution happens in an environment that already has all global variables
#   from a previous profile, such as when calling a bash script.
#
#   However, ssh command executions (not ssh logins) and scp connections, for example
#   invoke bashrc without bash_profile
#

if [ -r /etc/bashrc ]; then
  source /etc/bashrc
fi

#==============================================================================
#-- ALIASES -------------------------------------------------------------------
alias e="$EDITOR"

alias ll="ls -lh"
alias la="ls -lha"
alias psg="ps ax|grep -i"
alias ducks="du -cks * |sort -rn |head -11"
if [ "$ENVIRONMENT" = "Linux" ]; then
  alias ls="ls --color=tty -ACFh"
elif [ "$ENVIRONMENT" = "OSX" ]; then
  alias ls="ls -CGh -w"
elif [ "$ENVIRONMENT" = "Solaris" ]; then
  alias psg="ps -ef | grep -i"
fi

alias r="rake"
alias t="tail -f $1 | more"

function utf {
  export LANG="en_US.UTF-8"
  export LC_ALL="en_US.UTF-8"
}

function iso {
  export LANG="en_US.ISO-8859-1"
  export LC_ALL="en_US.ISO-8859-1"
}

utf

#==============================================================================
# from http://www.ncb.ernet.in/~nihar/utilLinks.php#bw-util
alias bw="/sbin/ifconfig eth0 | awk '/RX bytes/{print \$2 > \"/tmp/bytes\"}' FS=\"[:(]\" ;\
    sleep 10; # Wait for 2 seconds, and then take the second reading..
    /sbin/ifconfig eth0 | awk 'BEGIN{getline earlier < \"/tmp/bytes\"}\
    /RX bytes/{bw=(\$2-earlier); \
              if ((bw*4) < 102400) system (\"echo -ne \${ANSIRED}\");\
         else if ((bw*4) > 2621440) system (\"echo -ne \${ANSIBOLD}\"); \
         else if ((bw*4) > 2097152) system (\"echo -ne \${ANSIYELLOW}\"); \
         else if ((bw*4) > 1048576) system (\"echo -ne \${ANSIGREEN}\"); \
         else system (\"echo -ne \${ANSIRESET}\"); \
         print \"BW: \"bw/(1024*10)\" KB/s, \"(bw*8)/(1024*1024*10)\" Mb/s \"\
    strftime(\"%H:%M:%S [%d/%m/%y]\"); }' \
    FS=\"[:(]\""
          
#==============================================================================
#-- SUDO ----------------------------------------------------------------------
function subash {
  if [ "$ENVIRONMENT" = "Linux" ]; then
    su -c "bash --init-file $ORIGINALHOME/.bashrc" $1
  elif [ "$ENVIRONMENT" = "OSX" ]; then
    su $1 -m -c "/bin/bash --init-file $ORIGINALHOME/.bashrc"
  elif [ "$ENVIRONMENT" = "Solaris" ]; then
    su $1 -c "bash --init-file $ORIGINALHOME/.bashrc"
  else
    echo subash not suported in environment '$ENVIRONMENT'
  fi
}
alias suroot="subash root"

function sudobash {
  if [ "$ENVIRONMENT" = "Linux" ]; then
    sudo -u $1 bash --init-file $ORIGINALHOME/.bashrc
  elif [ "$ENVIRONMENT" = "OSX" ]; then
    sudo -u $1 /bin/bash --init-file $ORIGINALHOME/.bashrc
  else
    echo subash not suported in environment '$ENVIRONMENT'
  fi
}
alias sudoroot="sudobash root"

#==============================================================================
#-- ANSI Codes ----------------------------------------------------------------
ANSIBLACK="\033[0;30m"
ANSIGRAY="\033[1;30m"
ANSIRED="\033[0;31m"
ANSILRED="\033[1;31m"
ANSIGREEN="\033[0;32m"
ANSILGREEN="\033[1;32m"
ANSIBROWN="\033[0;33m"
ANSIYELLOW="\033[1;33m"
ANSIBLUE="\033[0;34m"
ANSILBLUE="\033[1;34m"
ANSIPURPLE="\033[0;35m"
ANSILPURPLE="\033[1;35m"
ANSICYAN="\033[0;36m"
ANSILCYAN="\033[1;36m"
ANSIGRAY="\033[0;37m"
ANSIWHITE="\033[1;37m"

ANSIBACKBLACK="\033[40m"
ANSIBACKRED="\033[41m"
ANSIBACKGREEN="\033[42m"
ANSIBACKBROWN="\033[43m"
ANSIBACKBLUE="\033[44m"
ANSIBACKPURPLE="\033[45m"
ANSIBACKCYAN="\033[46m"
ANSIBACKGRAY="\033[47m"

ANSIRESET="\033[0m"
ANSIBOLD="\033[1m"
ANSIUNDERSCORE="\033[4m"
ANSIBLINK="\033[5m"
ANSIREVERSE="\033[7m"
ANSICONCEALED="\033[8m"

XTERM_SET_TITLE="\033]2;"
XTERM_END="\007"
ITERM_SET_TAB="\033]1;"
ITERM_END="\007"
SCREEN_SET_STATUS="\033]0;"
SCREEN_END="\007"
SCREEN_SET_TITLE="\033k"
SCREEN_END_TITLE="\033\0134"

#==============================================================================
#-- Prompt --------------------------------------------------------------------
if [ "$UID" = "$ORIGINALUID" ]; then
  CWD_COLOR=$ANSIGREEN$ANSIREVERSE
  PROMPT_COLOR=$ANSILGREEN
elif [ "$UID" = "0" ]; then
  CWD_COLOR=$ANSIBACKRED$ANSIYELLOW
  PROMPT_COLOR=$ANSILRED
else 
  CWD_COLOR=$ANSIYELLOW$ANSIREVERSE
  PROMPT_COLOR=$ANSIYELLOW
fi

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function promptcommand {
  LAST_ERROR=$?
  PROMPT_MSG=""
  if [ "$LAST_ERROR" != "0" ]; then
    export PROMPT_MSG="<$LAST_ERROR>"
  fi

  XTERM_TITLE="`whoami`@`hostname -s` : `pwd`"
  echo -ne "${XTERM_SET_TITLE}${XTERM_TITLE}${XTERM_END}"

#	if [ "$UID" = "$ORIGINALUID" ]; then
#    TAB_TITLE="`hostname -s`"
#  else
    TAB_TITLE="`whoami`@`hostname -s`"
#  fi
  echo -ne "${ITERM_SET_TAB}${TAB_TITLE}${ITERM_END}"

  if [ "$TERM" == "screen" ]; then
    echo -ne "${SCREEN_SET_STATUS}${TAB_TITLE}${SCREEN_END}"
    echo -ne "${SCREEN_SET_TITLE}${TAB_TITLE}${SCREEN_END_TITLE}"
  fi
}

PROMPT_COMMAND="promptcommand"

export PS1="\[${ANSIRESET}\]\[${CWD_COLOR}\]\t  \u @ \h [\w\$(parse_git_branch)]\[${ANSIRESET}\]  \[${ANSIRED}\]\${PROMPT_MSG}\]${ANSIRESET}\]\n\[${PROMPT_COLOR}\]${WINDOW_MSG}\! \$\[${ANSIRESET}\] "

