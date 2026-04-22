#!/bin/sh
# launch.sh - Bastille jail making wrapper
#
#   a bastillefile is great, but needs a little more to full automate.
#   that's this script (i hope).
#
#   this script only does basic sanity checks so make sure you confs
#   are good (no bad paths or typos).

. "$(dirname "$0")/launch.conf"

if [ ! -d "$BASTILLE_ROOT" ]; then
    echo "Error: Bastille root not a directory -> ${BASTILLE_ROOT}"
    exit 1
elif [ ! -d "${BASTILLE_ROOT}/templates/${TEMPLATE}" ]; then
    echo "Error: Template ${TEMPLATE} not found -> ${BASTILLE_ROOT}/templates/${TEMPLATE}"
    exit 1
elif [ ! -d "${BASTILLE_ROOT}/releases/${RELEASE}" ]; then
    echo "Error: Release ${RELEASE} not found -> ${BASTILLE_ROOT}/releases/${RELEASE}"
    exit 1
elif ! ifconfig "$IF" >/dev/null 2>&1; then
    echo "Error: Interface $IF does not exist"
    exit 1
fi

BOOT='--no-boot'
JNAME=''
IP=''
MOUNTS=''
JSETTINGS=''
RCCONF=''
F_BRIDGE=''
F_VNET=''
F_MAC=''
F_DUAL=''
F_FORCE=''
F_TMPFS=''
F_RESTART=''

destroy_jail() {
    if [ -n "$F_FORCE" ] && [ -n "$JNAME" ]; then
        echo "Critical error occurred. Force-cleaning jail $JNAME..."
        bastille destroy -f "$JNAME" >/dev/null 2>&1 || true
    fi
    exit 1
}

usage() {
    echo "Usage: $0 -n name -i ip [options]"
    echo "Options:"
    echo "  -n NAME      Jail name (required)"
    echo "  -i IP        Jail IP (required. can also be DHCP)"
    echo "  -I IF        Interface (default: em0)"
    echo "  -R RELEASE   FreeBSD release (default: 14.3-RELEASE)"
    echo "  -T TEMPLATE  Bastille template (default: user/skeljail)"
    echo "  -C FILE      Mounts configuration file"
    echo "  -S FILE      Jail settings to change"
    echo "  -r FILE      Settings to add to rc.conf"
    echo "  -b           Enable boot"
    echo "  -B           Bridge mode (ensure IF is a bridge)"
    echo "  -D           Enable IPv4 & IPv6"
    echo "  -M           Assign static mac address"
    echo "  -V           VNET mode"
    echo "  -F           Force clean (destroy jail on failure)"
    echo "  -t           Create a tmpfs at /tmp"
    echo "  -x           Restart jail after creation"
    exit 1
}

while getopts "n:i:I:R:T:C:S:r:bBDMVFtx" opt; do
    case "$opt" in
        n) JNAME=$OPTARG ;;
        i) IP=$OPTARG ;;
        I) IF=$OPTARG ;;
        R) RELEASE=$OPTARG ;;
        T) TEMPLATE=$OPTARG ;;
        C) MOUNTS=$OPTARG ;;
        S) JSETTINGS=$OPTARG ;;
        r) RCCONF=$OPTARG ;;
        b) BOOT='' ;;
        B) F_BRIDGE='-B' ;;
        D) F_DUAL='-D' ;;
        M) F_MAC='-M' ;;
        V) F_VNET='-V' ;;
        F) F_FORCE='1' ;;
        t) F_TMPFS='1' ;;
        x) F_RESTART='1' ;;
        *) usage ;;
    esac
done


for f in "$RCCONF" "$JSETTINGS" "$MOUNTS"; do
    if [ -n "$f" ] && [ ! -f "$f" ]; then
        echo "Error: Configuration file $f not found."
        exit 1
    fi
done

if [ -z "$JNAME" ] || [ -z "$IP" ]; then
    echo "Error: Name (-n) and IP (-i) are required."
    usage
fi

if [ -n "$F_BRIDGE" ] && [ -n "$F_VNET" ]; then
    echo "Error: Cannot use Bridge mode (-B) and VNET mode (-V) simultaneously."
    exit 1
fi

if [ -n "$F_BRIDGE" ]; then
    if ! ifconfig "$IF" 2>/dev/null | grep -q "groups: bridge"; then
        echo "Error: Interface $IF is not a bridge, but Bridge mode (-B) was specified."
        exit 1
    fi
fi

echo "Creating jail: $JNAME..."
if ! bastille create $F_BRIDGE $F_VNET $F_MAC $F_DUAL $BOOT "$JNAME" "$RELEASE" "$IP" "$IF"; then
    destroy_jail
fi

if [ -n "$F_TMPFS" ]; then
    echo "Setting up tmpfs mount..."
    if ! bastille mount "$JNAME" tmpfs tmp tmpfs rw,nosuid,mode=01777 0 0; then
        destroy_jail
    fi
fi

if [ -f "$MOUNTS" ]; then
    echo "Applying custom mounts from $MOUNTS..."
    while read -r line; do
        # Skip empty lines and comments
        [ -z "$line" ] || [ "${line#\#}" != "$line" ] && continue
        
        # Parse: "host_dir" "jail_dir" [setting]
        # (Using eval to handle quoted strings in the line)
        eval set -- "$line"
        HOST_DIR=$1
        JAIL_DIR=$2
        SETTING=${3:-rw}
        
        if [ ! -d "$HOST_DIR" ] && [ ! -f "$HOST_DIR" ]; then
            echo "Error: Host path $HOST_DIR does not exist."
            destroy_jail
        fi
        
        echo "Mounting $HOST_DIR -> $JAIL_DIR ($SETTING)"
        if ! bastille mount "$JNAME" "$HOST_DIR" "$JAIL_DIR" nullfs "$SETTING" 0 0; then
            destroy_jail
        fi
    done < "$MOUNTS"
fi

if [ -f "$JSETTINGS" ]; then
    echo "Applying jail settings from $JSETTINGS..."
    while read -r line; do
        [ -z "$line" ] || [ "${line#\#}" != "$line" ] && continue
        
        # Parse: setting_name value1 value2 etc
        set -- $line
        SETTING=$1
        shift
        VALUE="$*"
        
        echo "Setting $SETTING $VALUE"
        bastille config "$JNAME" set "$SETTING" "$VALUE"
    done < "$JSETTINGS"
fi

if [ -f "$RCCONF" ]; then
    echo "Appending to rc.conf from $RCCONF..."
    cat "$RCCONF" >> "${BASTILLE_ROOT}/jails/${JNAME}/root/etc/rc.conf"
fi

if [ -n "$TEMPLATE" ]; then
    echo "Applying template: $TEMPLATE..."
    if ! bastille template "$JNAME" "$TEMPLATE"; then
        destroy_jail
    fi
fi

if [ -n "$F_RESTART" ]; then
    echo "Restarting jail $JNAME..."
    if ! bastille restart "$JNAME"; then
        destroy_jail
    fi
fi
