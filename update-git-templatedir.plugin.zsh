#!/usr/bin/env zsh
# Cancel upgrade if git is unavailable on the system
whence git >/dev/null || return 0
templatedir=`git config --global init.templatedir`
# Cancel upgrade if no templatedir
if [[ -z "$templatedir" ]]; then
  return 0
fi
expand_tilde() {
    tilde_less="${1#\~/}"
    [ "$1" != "$tilde_less" ] && tilde_less="$HOME/$tilde_less"
    printf "$tilde_less"
}
templatedir=$(expand_tilde $templatedir)

pushd $(dirname "${0}") > /dev/null
basedir=$(pwd -L)
# Use "pwd -P" for the path without links. man bash for more info.
popd > /dev/null

zmodload zsh/datetime

function _current_epoch() {
  echo $(( $EPOCHSECONDS / 60 / 60 / 24 ))
}

function _update_templatedir_update() {
  echo "LAST_EPOCH=$(_current_epoch)" >! ~/.templatedir-update
}

function _upgrade_templatedir() {
  env TEMPLATEDIR=$templatedir sh $basedir/upgrade.sh
  # update the templatedir file
  _update_templatedir_update
}

epoch_target=$UPDATE_TEMPLATEDIR_DAYS
if [[ -z "$epoch_target" ]]; then
  # Default to old behavior
  epoch_target=13
fi

if mkdir $basedir/log/update.lock 2>/dev/null; then
  if [ -f ~/.templatedir-update ]; then
    . ~/.templatedir-update

    if [[ -z "$LAST_EPOCH" ]]; then
      _update_templatedir_update && return 0;
    fi

    epoch_diff=$(($(_current_epoch) - $LAST_EPOCH))
    if [ $epoch_diff -gt $epoch_target ]; then
        echo "[Git templatedir] Would you like to check for updates? [Y/n]: \c"
        read line
        if [[ "$line" == Y* ]] || [[ "$line" == y* ]] || [ -z "$line" ]; then
          _upgrade_templatedir
        else
          _update_templatedir_update
        fi
    fi
  else
    # create the templatedir file
    _update_templatedir_update
  fi

  rmdir $basedir/log/update.lock
fi
