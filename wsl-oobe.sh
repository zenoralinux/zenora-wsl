#!/bin/bash

DEFAULT_GROUPS='adm,wheel,kvm,render,video'
DEFAULT_UID='1000'

echo 'Welcome to Zenora Linux on WSL.'
printf 'This image is built by Zenora Linux Team. Please read README \e[0;31mcarefully\e[0m.\n'
echo ''
echo 'Please create a default UNIX user account. The username does not need to match your Windows username.'
echo 'For more information visit: https://aka.ms/wslusers'

if getent passwd "$DEFAULT_UID" > /dev/null ; then
  echo 'User account already exists, skipping creation'
  exit 0
fi

while true; do
  read -p 'Enter new UNIX username: ' username

  if /usr/sbin/useradd --uid "$DEFAULT_UID" -m "$username"; then
    passwd "$username"
    ret=$?
    if [[ $ret -ne 0 ]]; then
      /usr/sbin/userdel -r "$username"
      continue
    fi

    /usr/sbin/usermod "$username" -aG "$DEFAULT_GROUPS"

    # ZSH default shell
    chsh -s /bin/zsh "$username"

    # Setup .zshrc for first login
    echo '[[ -x $(command -v neofetch) ]] && neofetch' >> /home/$username/.zshrc
    chown "$username:$username" /home/$username/.zshrc

    break
  fi
done

echo ''
echo '[*] Generating locales...'
/usr/bin/locale-gen

echo '[*] Initializing pacman-key...'
pacman-key --init

echo '[*] Populating pacman-key...'
pacman-key --populate

echo '[*] Updating Zenora configuration...'
zenora-conf-update

echo -e '\e[0;92mDone! Your Zenora Linux on WSL installation is ready to use.\e[0m'
