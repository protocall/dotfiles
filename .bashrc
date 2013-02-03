# ~/.bashrc
# customized from gentoo and debian defaults
# PS1 colors matched to Solarized 256 palette, e.g. /W matches dircolors etc.

# check for interactive shell or bail
[ -z "$PS1" ] && return

### general
# prevent duplicates and spaces in history
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and update if needed
shopt -s checkwinsize

# simple window title, no pwd clutter
case ${TERM} in
	xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}\007"'
		;;
	screen)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}\033\\"'
		;;
	*)
    	;;
esac

### colors
# set some standards
wdcolor='\[\033[00;38;5;33m\]' #match DIR value from solarized dircolors 
case ${HOSTNAME} in	#nerdify hostnames for my local vms
	bahamut*) #bahamut is purple when solarized
		hcolor='\[\033[01;35m\]\h\[\033[01;32m\]:Dom0 ' 
		;;
	ifrit*)
		hcolor='\[\033[00;31m\]\h ' #ifrit is red
		;;
	odin*)
		hcolor='\[\033[01;37m\]\h ' #odin is white
		;;
	titan*)
		hcolor='\[\033[00;33m\]\h ' #titan is brown
		;;
	*)
		hcolor='\[\033[00m\]\h '
		;;
esac
# ensure color support, compare TERM to dircolors list
use_color=false
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
# find dircolors file to use or pull defaults
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
# make sure term is color-capable
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true
# pick coolnes if so, prefer user's file
if ${use_color} ; then
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi
	# go go gadget prompt
	if [[ ${EUID} == 0 ]] ; then
		PS1=${hcolor}${wdcolor}'\w \[\033[01;31m\]\$\[\033[00m\] '
	else
		PS1=${hcolor}${wdcolor}'\W \[\033[00m\]\$ '
	fi

	#make life easier and more colorful
	export LS_OPTIONS='--color=auto --group-directories-first'
	alias ls='ls $LS_OPTIONS'
	alias l='ls $LS_OPTIONS -lah'
	alias ll='ls $LS_OPTIONS -lAhSr'	# by size, asc
	alias lt='ls $LS_OPTIONS -lAhtr'	# by date, asc
	alias grep='grep --color=auto'
	
else 		# show root@ when we don't have colors
	if [[ ${EUID} == 0 ]] ; then

		PS1='\u@\h \w \$ '
	else
		PS1='\u@\h \W \$ '
	fi
fi
# clean up env
unset use_color safe_term match_lhs wdcolor hcolor
