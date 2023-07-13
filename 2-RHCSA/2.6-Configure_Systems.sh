6-Deploy, configure, and maintain systems
Schedule tasks using at and cron
Start and stop services and configure services to start automatically at boot
Configure systems to boot into a specific target automatically
Configure time service clients
Install and update software packages from Red Hat Network, a remote repository, or from the local file system
Modify the system bootloader


at - one time jobs, scheduled for a certain date & time
cron - recurring jobs, scheduled for a certain frequency
cron file locations:
/etc/crontab - historical location, cron jobs for multiple users
/etc/cron.d/ - directory for packages to add cron entries, same format as above
/var/spool/cron - crontabs created via crontab -e - ONE FILE PER USER
......
.....
QUESTION deny creating cronjob for rupert
vim /etc/cron.deny
#rupert

EXERCISE
root - vi /etc/crontab
* * * * * root tar cvfz /root/var-www-backup.tar.gz /var/www >> /root/
var-www-backup.log 2>&1
touch var-www-backup.log
tail -f var-www-backup.tar.gz
du -sh var-www-backup.tar.gz
cat var-www-backup.log
......
crontab -e -u rupert
crontab -e
* * * * * tar cvfz ~/bash-files-backup.tar.gz ~/.bash* >> ~/bash-files-backup.log 2>&1
touch bash-files-backup.log
tail -f var-www-backup.tar.gz
.....
yum list --installed at
systemctl status atd
at 20:00
> tar cvfz /root/var-www-final-backup.tar.gz /var/www >> /root/var-www-final-backup.log 2>&1
> ctrl+d
now RESCHEDULE
atq
atrm 7
.....
at now + 7 days
> tar cvfz /root/var-www-final-backup.tar.gz /var/www >> /root/var-www-final-backup.log 2>&1
> ctrl+d


SYSTEMd
Anatomy of a Unit File
systemctl enable --now mariadb
systemctl disable --now mariadb
systemctl get-default -> graphical.target
systemctl set-default multi-user -> boot without gui
systemctl isolate multi-user
systemctl list-units --type target --state inactive
systemctl list-units

QUESTION - configure your system so that it is NTP Client of system2.eight.example.com (192.168.55.151)
vim /etc/chrony.conf
server 192.168.55.151 iburst


rhel8 - chronyd replaced ntp
chronyd - user space daemon
chronyc - command line program to monitor & control chronyd
ntpstat - supports chronyd
imp. chrony files
/etc/chrony.conf
/etc/chrony.keys
/usr/share/doc/chrony
.....
yum -y install chrony ntpstat
 chronyc sources
 1017  chronyc sources -v
 1018  chronyc sourcestats
 1019  chronyc serverstats
 1020  vim /etc/chrony.conf
 1021  systemctl restart chronyd
.....
 # timedatectl set-ntp true
 ntpstat
 chronyc tracking
 chronyc makestep (corrections async of systemtime with ntp time) 
 chronyc tracking


 MANAGE PACKAGES
 add a repository
 # vim /etc/yum.repos.d/epel.repo
    [epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$releasever
................
AFTER EDITING A REPO FILE, clear yum cache
# yum clean all
# yum repolist --all
yum list --available youtube-dl
yum install --downloadonly --downloaddir . youtube-dl
yum install ./yout.......
yum list --installed youtube-dl
yum list --installed wget
yum check-update | less
yum -y update



APPLICATION STREAMS
a module is a collection of RPM packages that make up a component & r installed together
each module has a default stream
a profile is a collection of packages to be installed together for a particular use case (e.g. server,client,minimal)

our web team needs newest version of php
yum clean all
yum repolist --all
yum module list php
# [root@x230 ~]# yum module list php
Updating Subscription Management repositories.
Last metadata expiration check: 0:03:14 ago on Fri 26 May 2023 11:56:12 PM PKT.
Red Hat Enterprise Linux 9 for x86_64 - AppStream (RPMs)
Name            Stream           Profiles                             Summary
php             8.1              common [d], devel, minimal           PHP scripting language
........
yum module install php:8.1/devel
yum module list --installed php
HOW to RE-install PREVIOUS VERSION
yum module reset php ; yum module list php
yum module install php:8.0/devel


SYSTEM BOOTLOADER
/etc/default/grub - config file that controls operation of grub2-mkconfig
/etc/grub2/grub.d files generated when grub2-mkconfig is run
/boot/grub2/grub.cfg - final product generated by grub2-mkconfig
this controls behavior of GRUB2 bootloader

sequence
1 bios
2 master boot record MBR
3 GRUB2 bootloader is inside MBR (which loads the kernel)
4 kernel
5 systemd - reads /etc/systemd config files & default.target file
6 default.target - system brought to state as defined by default.target

# EXCERCISE
# WE WANT TO CUSTOMIZE OUR BOOT PROCESS
# we need to increase boot menu timeout, hide the boot menu, show all messages during boot
more /etc/grub2/grub.cfg (for reference) do not edit
ls -al /etc/grub.d/ (do not touch)
more /etc/default/grub to see default grub settings
vim /etc/default/grub
change 5 to 10 in GRUB_TIMEOUT
# GRUB_TIMEOUT_STYLE=hidden to hide boot menu
# remove "rhgb quiet" to view all msgs during boot
Backup files before running mkconfig command
[root@x230 ~]# mv /boot/grub2/grub.cfg /boot/grub2/grub.cfg.original
[root@x230 ~]# mv /boot/grub2/grubenv /boot/grub2/grubenv.original
# grub2-mkconfig -o /boot/grub2/grub.cfg


root@server1: ~ # yum module list php
Last metadata expiration check: 0:14:56 ago on Wed 31 May 2023 05:38:25 PM UTC.
Red Hat Enterprise Linux 8 for x86_64 - AppStream from RHUI (RPMs)
Name            Stream             Profiles                              Summary
php             7.2 [d]            common [d], devel, minimal            PHP scripting language
php             7.3                common [d], devel, minimal            PHP scripting language
php             7.4                common [d], devel, minimal            PHP scripting language
php             8.0                common [d], devel, minimal            PHP scripting language

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
root@server1: ~ # yum module install php:7.3/devel

1014  rpm -q wget (INSTALLED PACKAGE DETAIL)
 1015  yum repolist
 1016  rpm -h
 1017  rpm --help
 1018  rpm -ivh stress-1.0.4-29.el9.x86_64.rpm (INSTALL DOWNLOADED PACKAGE)
 1019  rpm -qi stress (USEFUL INFO)
 1020  rpm -ql stress (PACKAGE FILES LOCATION)
 1021  rpm -ql stress | xargs file
 1022  rpm -ql stress | xargs file | grep ELF
 1023  which stress
 1024  echo $PATH
 1025  rpm -e stress (DELETE)
 1026  which stress
 1027  vim /etc/yum.repos.d/epel.repo
 1028  yum repolist
 1029  yum repolist --all
 1030  yum info youtube-dl
 1031  yum install youtube-dl
 1032  rpm -ql youtube-dl
 1033  repoquery --list youtube-dl (SAME INFO AS RPM -ql)
 1034  repoquery --list youtube-dl | xargs file | grep ELF
 1035  file `which youtube-dl`



GRUB BOOTLOADER
root@server1: ~ # less /boot/grub2/grub.cfg
root@server1: ~ # ls -l /etc/grub.d
total 96
-rwxr-xr-x. 1 root root  8958 Nov  8  2022 00_header
-rwxr-xr-x. 1 root root  1043 Aug 19  2022 00_tuned
-rwxr-xr-x. 1 root root   232 Nov  8  2022 01_users
-rwxr-xr-x. 1 root root   832 Nov  8  2022 08_fallback_counting
-rwxr-xr-x. 1 root root 14088 Nov  8  2022 10_linux
-rwxr-xr-x. 1 root root   830 Nov  8  2022 10_reset_boot_success
-rwxr-xr-x. 1 root root   889 Nov  8  2022 12_menu_auto_hide
-rwxr-xr-x. 1 root root 11696 Nov  8  2022 20_linux_xen
-rwxr-xr-x. 1 root root  2559 Nov  8  2022 20_ppc_terminfo
-rwxr-xr-x. 1 root root 10670 Nov  8  2022 30_os-prober
-rwxr-xr-x. 1 root root  1412 Nov  8  2022 30_uefi-firmware
-rwxr-xr-x. 1 root root   700 Jun 16  2022 35_fwupd
-rwxr-xr-x. 1 root root   214 Nov  8  2022 40_custom
-rwxr-xr-x. 1 root root   216 Nov  8  2022 41_custom
-rw-r--r--. 1 root root   483 Nov  8  2022 README
root@server1: ~ # cat /etc/grub.d/README

All executable files in this directory are processed in shell expansion order.

  00_*: Reserved for 00_header.
  10_*: Native boot entries.
  20_*: Third party apps (e.g. memtest86+).

The number namespace in-between is configurable by system installer and/or
administrator.  For example, you can add an entry to boot another OS as
01_otheros, 11_otheros, etc, depending on the position you want it to occupy in
the menu; and then adjust the default setting via /etc/default/grub.
root@server1: ~ # cat /etc/default/grub
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="console=ttyS0,115200n8 console=tty0 net.ifnames=0 rd.blacklist=nouveau crashkernel=auto"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
root@server1: ~ # vim /etc/default/grub
/etc/default/grub
GRUB_TIMEOUT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_TERMINAL_OUTPUT="serial"
GRUB_SERIAL_COMMAND="serial"
GRUB_CMDLINE_LINUX="console=ttyS0,115200n8 console=tty0 net.ifnames=0 rd.blacklist=nouveau crashkernel=auto"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true

mv /boot/grub2/grub.cfg{,.orig} (backup)
mv /boot/grub2/grubenv{,.orig} (backup)

grub2-mkconfig -o /boot/grub2/grub.cfg
grep -i 'style=hidden' /boot/grub2/grub.cfg
reboot


[rhel-8-baseos-rhui-rpms]
name=RHEL8 BaseOS
mirrorlist=https://rhui3.REGION.aws.ce.redhat.com/pulp/mirror/content/dist/rhel8/rhui/$releasever/$basearch/baseos/os
enabled=1
gpgcheck=1
gpgkey=/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
sslverify=1
sslclientkey=/etc/pki/rhui/content-rhel8.key
sslclientcert=/etc/pki/rhui/product/content-rhel8.crt
sslcacert=/etc/pki/rhui/cdn.redhat.com-chain.crt


[rhel-8-appstream-rhui-rpms]
name=RHEL8 Appstream
mirrorlist=https://rhui3.REGION.aws.ce.redhat.com/pulp/mirror/content/dist/rhel8/rhui/$releasever/$basearch/appstream/os
enabled=1
gpgcheck=1
gpgkey=/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
sslverify=1
sslclientkey=/etc/pki/rhui/content-rhel8.key
sslclientcert=/etc/pki/rhui/product/content-rhel8.crt
sslcacert=/etc/pki/rhui/cdn.redhat.com-chain.crt


[epel]
name=EPEL
baseurl=https://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch
enabled=1
gpgcheck=0


add a repo by url
yum-config-manager --add-repo=http.....