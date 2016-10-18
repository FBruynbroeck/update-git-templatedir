
# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  BLUE="$(tput setaf 4)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  BLUE=""
  NORMAL=""
fi

printf "${BLUE}%s${NORMAL}\n" "Updating Git templatedir"
cd "$TEMPLATEDIR"
if git pull --rebase --stat origin master
then
  printf "${BLUE}%s\n" "Hooray! Git templatedir has been updated and/or is at the current version."
else
  printf "${RED}%s${NORMAL}\n" 'There was an error updating. Try again later?'
fi
