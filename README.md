# Bindfs to the User's Home Directory Bash Script

Bash script which allows easy mount of any filesystem directory into the user's home directory with proper permissions, so you can easily edit the files in that directory, without the need to make a mess with the application/service's filesystem permissions. 

Initially I've designed the scrip in order to edit system files with VSC, within a local or remote sessions. Some additional explanations could be found at [this answer of mine](https://askubuntu.com/a/1024308/566421) at [AskUbuntu.com](https://askubuntu.com/users/566421).

## Installation

Place the script [**`bindfs-to-home.sh`**](bindfs-to-home.sh) into `~/bin` or `/usr/local/bin` or elsewhere within your `$PATH` and use it as shell command. You can use the [`install.sh`](install.sh) script - it accept one parameter with default value `$HOME/bin`.

```bash
./install.sh
```

## Usage

The script uses the tool `bindfs` (it must be installed) and you must have *root* privileges. The target (source) directories will be mounted under a directory called `~/bindfs`.

For example, in order to ***m***ount `/var/www/html` use the following syntax:

```bash
$ bindfs-to-home.sh m /var/www/html
```

Now you can see there is a new directory tree under `~/bindfs` owned by the current *user*.

```bash
$ ls -ld ~/bindfs/var/www/html/
drwxr-xr-x 2 user user 4096 Oct 22 10:31 /home/pa4080/bindfs/var/www/html/
```

In contrast the target (source) directory (in the current case) is owned by *root*.

```bash
$ ls -ld /var/www/html
drwxr-xr-x 2 root root 4096 Oct 22 10:31 /var/www/html
```
Now you can edit the files within `~/bindfs/var/www/html` with your *user* and they will be written into `/var/www/html` for *root*. 

**I won't say you must be careful, because you have root privileges and already must know that!** **Please don't use `chown` or `chmod` against the mount point.**

To ***u***nmount the directory use the following syntax.
```bash
$ bindfs-to-home.sh u /var/www/html
```

To unmount ***a***ll previously mounted directories use the following command.
```bash
$ bindfs-to-home.sh a
```

After the above command the directory(ies) will be unmounted but the tree created under `~/bindfs` will stay. This is intentional behavior by the following reasons: 1) reminds you where you have worked last time and 2) do not automatically remove something from your filesystem by an error or a mistake!

In addition you can create an appropriate rule within `/etc/sudoers.d` in order to run the command without the need to enter your password and then you can add `bindfs-to-home.sh a` into your `~/.bash_logout` file or into the user's `crontab` to perform automatic unmount.

## Parameters and options

The script accepts three positional parameters:

* The **first parameter** behaves as option(s). They must be written in little bit strange way and this is because I decided to keep is simple as possible. 

* The **second parameter** is the target (source) directory that should be mounted. The default value is `/var/www`.

* The **third parameter** is the owner of the files that will be created within the source directory. By default the script will find who is the owner of that directory and will use it, so you do not need to use this parameter in the most cases.

* The (destination) directory `~/bindfs` is hardcoded. And will be automatically created in case it doesn't exist. 

    *Probably in the further versions of the script it will become a parameter - also the destination use could be a parameter...*

The options could be entered with uppercase or lowercase. They should be written without leading dash. Also you can use words instead of letters, for example `mount` instead `m` or `all` instead of `a`, just the the first letter make sense. The available options are:

* `m` mount the directory, provided by the second positional parameter or mount `/var/www` if it is not.

* `m-v` mount the directory and print the variables in use.

* `u` unmount the directory, provided by the second positional parameter or unmount `/var/www` if it is not provided.

* `a` unmount all mounted directories.

* `l` list all mounted directories.

* `-v` print the variables in use. It could be combined with any other option or used alone, but in this case the leading dash is mandatory.

* `-h` print help message. It could be combined with any other option or used alone, but in this case the leading dash is mandatory.

* **`l-v-h`** is the default options combination.
