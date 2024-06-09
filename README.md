# wsl2-ubuntu-24.04-env

my environment for Ubuntu 24.04 on WSL2.

## WSL version

in PowerShell

```
> wsl -v
WSL バージョン: 2.1.5.0
カーネル バージョン: 5.15.146.1-2
WSLg バージョン: 1.0.60
MSRDC バージョン: 1.2.5105
Direct3D バージョン: 1.611.1-81528511
DXCore バージョン: 10.0.25131.1002-220531-1700.rs-onecore-base2-hyp
Windows バージョン: 10.0.22631.3672
```

## Install Ubuntu 24.04

in PowerShell (Run as Administrator)

### (1) wsl --install Ubuntu-24.04

```
PS C:\WINDOWS\system32> wsl --install Ubuntu-24.04
インストール中: Ubuntu 24.04 LTS
Ubuntu 24.04 LTS がインストールされました。
Ubuntu 24.04 LTS を起動しています...
Installing, this may take a few minutes...
Please create a default UNIX user account. The username does not need to match your Windows username.
For more information visit: https://aka.ms/wslusers
Enter new UNIX username: XXXXX
New password:
Retype new password:
passwd: password updated successfully
Installation successful!
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

Welcome to Ubuntu 24.04 LTS (GNU/Linux 5.15.146.1-microsoft-standard-WSL2 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun Jun  9 08:54:35 JST 2024

  System load:  0.6                 Processes:             28
  Usage of /:   0.1% of 1006.85GB   Users logged in:       0
  Memory usage: 3%                  IPv4 address for eth0: 172.26.223.103
  Swap usage:   0%


This message is shown once a day. To disable it please create the
/home/XXXXX/.hushlogin file.
XXXXX@YYYYY:~$
```

### (2) git clone https://github.com/keijiyaoki/wsl2-ubuntu-24.04-env

```
XXXXX@YYYYY:~$ git clone https://github.com/keijiyaoki/wsl2-ubuntu-24.04-env
Cloning into 'wsl2-ubuntu-24.04-env'...
remote: Enumerating objects: 10, done.
remote: Counting objects: 100% (10/10), done.
remote: Compressing objects: 100% (10/10), done.
remote: Total 10 (delta 0), reused 10 (delta 0), pack-reused 0
Receiving objects: 100% (10/10), 25.37 KiB | 4.23 MiB/s, done.
done.
```

### (3) ./wsl2-ubuntu-24.04-env/init-env.sh [default_user]

default_user == new UNIX username

```
XXXXX@YYYYY:~$ ./wsl2-ubuntu-24.04-env/init-env.sh XXXXX
￤ 途中省略
swap ubuntu and  uid and gid in /etc/passwd

ubuntu:x:1002:1002:...
XXXXX:x:1000:1001:...

Hit enter:

Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny
  4. /usr/bin/emacs
  5. /bin/ed

Choose 1-5 [1]:
You have modified /etc/passwd.
You may need to modify /etc/shadow for consistency.
Please use the command 'vipw -s' to do so.
swap ubuntu and  gid in /etc/group

ubuntu:x:1002:XXXXX
XXXXX:x:1001:

Hit enter:
You have modified /etc/group.
You may need to modify /etc/gshadow for consistency.
Please use the command 'vigr -s' to do so.
initial setup done !!

exit Ubuntu-24.04 and run terminate distribution in PowerShell

> wsl --terminate Ubuntu-24.04
XXXXX@YYYYY:~$
```

### (4) exit

```
XXXXX@YYYYY:~$ exit
logout
-bash: /home/XXXXX/.bash_logout: Permission denied
この操作を正しく終了しました。
```

### (5) wsl --terminate Ubuntu-24.04

```
PS C:\WINDOWS\system32> wsl --terminate Ubuntu-24.04
この操作を正しく終了しました。
PS C:\WINDOWS\system32>
```

## Uninstall Ubuntu 24.04

### (1) in PowerShell (Run as Administrator)

```
PS C:\WINDOWS\system32> wsl --shutdown
PS C:\WINDOWS\system32> wsl --unregister Ubuntu-24.04
```

### (2) Windows Settings

uninstall Ubuntu-24.04
