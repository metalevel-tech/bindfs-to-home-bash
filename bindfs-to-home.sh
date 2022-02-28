#!/bin/bash

# @author       Spas Z. Spasov <spas.z.spasov@gmail.com>
# @license      https://www.gnu.org/licenses/gpl-3.0.html GNU General Public License, version 3
# @home         https://github.com/metalevel-tech/bindfs-to-home-bash
#
# @name         bindfs-to-home.sh

[[ -z ${1+x} ]] && DO_ACTION="L-V-H"     || DO_ACTION="$1"   # Default action LIST MOUNTED, VERBOSE OUTPUT
[[ -z ${2+x} ]] && SOURCE_DIR="/var/www" || SOURCE_DIR="$2"  # Default target directory '/var/www'
[[ -z ${3+x} ]] && SOURCE_USR="AUTO"     || SOURCE_USR="$3"  # Default source user is the user owned the target dir

RELAT_PATH="${HOME}/bindfs"
TARGET_DIR="${RELAT_PATH}${SOURCE_DIR}"

function list_all_mounted_in_relative_path() {
        printf "List of the directories mounted under '%s':\n\033[1;33m%s\n" \
            "${RELAT_PATH}" \
            "$(findmnt -nrt fuse -o TARGET | grep "$RELAT_PATH" || echo 'No mounted directories!')"
        printf '\033[0m'
}

function target_dir_unmount() {
    sudo fusermount -u "$TARGET_DIR" 2>/dev/null
}

function unmount_all_in_relative_path() {
    echo ''
    for DIR in $(findmnt -nrt fuse -o TARGET | grep "$RELAT_PATH")
    do
        if [[ $DIR == '' ]]
        then
            return false
        else
            sudo fusermount -u "$DIR"

            if [[ $? -eq 0 ]]
            then
                printf '\033[1;33m%s\033[0m is unmounted.\n' "$DIR"
            else
                printf '\033[1;33mSomething went wrong!\033[0m\n' "$DIR"
            fi
        fi
    done
}

function target_dir_create() {
    mkdir -p "$TARGET_DIR"
}

function target_dir_mount() {
    sudo bindfs -u "$TGT_USR_UID" -g "$TGT_USR_GID" \
                --create-for-user="$SRC_USR_UID" \
                --create-for-group="$SRC_USR_GID" \
                "$SOURCE_DIR" "$TARGET_DIR"
}

function get_users() {
    if [[ ${SOURCE_USR^^} == 'AUTO' ]]
    then
        SRC_USR_UID=$(stat -c '%u' "${SOURCE_DIR}")
        SRC_USR_GID=$(stat -c '%g' "${SOURCE_DIR}")
    else
        SRC_USR_UID=$(id "$SOURCE_USR" -u)
        SRC_USR_GID=$(id "$SOURCE_USR" -g)
    fi

    TGT_USR_UID=$(id -u)
    TGT_USR_GID=$(id -g)
}

function print_vars() {
    echo -e "Variables:\n"
    echo -e "\tSOURCE_DIR: $SOURCE_DIR"
    echo -e "\tSOURCE_USR: $SOURCE_USR\n"
    echo -e "\tRELAT_PATH: $RELAT_PATH"
    echo -e "\tTARGET_DIR: $TARGET_DIR\n"
    echo -e "\tSRC_USR_UID: $SRC_USR_UID"
    echo -e "\tSRC_USR_GID: $SRC_USR_GID\n"
    echo -e "\tTGT_USR_UID: $TGT_USR_UID"
    echo -e "\tTGT_USR_GID: $TGT_USR_GID\n"
    echo -e "\tDO_ACTION: ${DO_ACTION^^}\n"
}

function get_help() {
    echo -e "Syntax:"
    echo -e "\t$(basename ${0}) (M|U|A|L)[-V][-H] /target/dir user-owned-the-target-dir\n"
    echo -e "Examples:"
    echo -e "\t$(basename ${0}) -V"
    echo -e "\t$(basename ${0}) -H"
    echo -e "\t$(basename ${0}) M-V [/target/dir] [user]"
    echo -e "\t$(basename ${0}) U-V [/target/dir]"
    echo -e "\t$(basename ${0}) L"
    echo -e "\t$(basename ${0}) Mount [/target/dir] [user]"
    echo -e "\n\t m: mount\n\t u: un mount\n\t a: un mount all [default]\n\t l: list all mounted directories"
    echo -e "\n\t-v: print the variables\n\t-h: print the help\n"
}

function do_action() {
    # Pseudo options process ---
    if [[ ${DO_ACTION^^} =~ ^(\-\-|\-)H ]]
    then
        [[ ${DO_ACTION^^} =~ (\-\-|\-)V ]] && print_vars
        get_help
        exit
    fi

    if [[ ${DO_ACTION^^} =~ ^(\-\-|\-)V ]]
    then
        print_vars
        [[ ${DO_ACTION^^} =~ (\-\-|\-)H ]] && get_help
        exit
    elif [[ ${DO_ACTION^^} =~ (\-\-|\-)V ]]
    then
        print_vars
        [[ ${DO_ACTION^^} =~ (\-\-|\-)H ]] && get_help
    fi
    # ---

    if [[ ${DO_ACTION^^} =~ M ]]
    then
        target_dir_unmount # try to unmount target dir just in case
        target_dir_create  # try to make the target dir just in case
        target_dir_mount   # finally do the bindfs mount
    elif [[ ${DO_ACTION^^} =~ U ]]
    then
        if target_dir_unmount
        then
            printf '\033[1;33m%s\033[0m is unmounted.\n' "$TARGET_DIR"
        else
            printf '\033[1;33m%s\033[0m was not mounted.\n' "$TARGET_DIR"
        fi
    elif [[ ${DO_ACTION^^} =~ L ]]
    then
        list_all_mounted_in_relative_path
    else
        list_all_mounted_in_relative_path

        # We do not need [[ ${DO_ACTION^^} =~ A ]]
        # because will fall here if it is not M|U|L
        if ! unmount_all_in_relative_path
        then
            list_all_mounted_in_relative_path
        fi
    fi
}

# Do the actions
get_users
do_action
