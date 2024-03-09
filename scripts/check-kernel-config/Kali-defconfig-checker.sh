#!/bin/bash

FILE=$1

[ -f "$FILE" ] || {
	echo "Provide a config file as argument"
	exit
}

write=false

if [ "$2" = "-w" ]; then
	write=true
fi

CONFIGS_ON="
CONFIG_IKCONFIG
CONFIG_CPUSETS
CONFIG_AUTOFS4_FS
CONFIG_TMPFS_XATTR
CONFIG_TMPFS_POSIX_ACL
CONFIG_CGROUP_DEVICE
CONFIG_SYSVIPC
CONFIG_CGROUPS
CONFIG_NAMESPACES
CONFIG_UTS_NS
CONFIG_IPC_NS
CONFIG_USER_NS
CONFIG_PID_NS
CONFIG_NET_NS
CONFIG_DEVTMPFS
CONFIG_DEVTMPFS_MOUNT
CONFIG_FSNOTIFY
CONFIG_DNOTIFY
CONFIG_INOTIFY_USER
CONFIG_FANOTIFY
CONFIG_FANOTIFY_ACCESS_PERMISSIONS
CONFIG_BT
CONFIG_BT_RFCOMM
CONFIG_BT_RFCOMM_TTY
CONFIG_BT_BNEP
CONFIG_BT_BNEP_MC_FILTER
CONFIG_BT_BNEP_PROTO_FILTER
CONFIG_BT_HIDP
CONFIG_BT_HCIBTUSB_BCM
CONFIG_BT_HCIBTUSB_RTL
CONFIG_BT_HCIUART
CONFIG_BT_HCIBCM203X
CONFIG_BT_HCIBPA10X
CONFIG_BT_HCIBFUSB
CONFIG_CFG80211_WEXT
CONFIG_MAC80211
CONFIG_MAC80211_MESH
CONFIG_DNS_RESOLVER
CONFIG_FHANDLE
CONFIG_EPOLL
CONFIG_SIGNALFD
CONFIG_TIMERFD
CONFIG_TMPFS_POSIX_ACL
CONFIG_USB_RTL8150
CONFIG_USB_RTL8152
CONFIG_MEDIA_DIGITAL_TV_SUPPORT
CONFIG_MEDIA_SDR_SUPPORT
CONFIG_MEDIA_TUNER_MSI001
CONFIG_USB_AIRSPY
CONFIG_USB_HACKRF
CONFIG_USB_MSI2500
CONFIG_DVB_RTL2830
CONFIG_DVB_RTL2832
CONFIG_DVB_RTL2832_SDR
CONFIG_DVB_SI2168
CONFIG_DVB_ZD1301_DEMOD
CONFIG_USB_ACM
CONFIG_USB_CONFIGFS_SERIAL
CONFIG_USB_CONFIGFS_ACM
CONFIG_USB_CONFIGFS_OBEX
CONFIG_USB_CONFIGFS_NCM
CONFIG_USB_CONFIGFS_ECM
CONFIG_USB_CONFIGFS_ECM_SUBSET
CONFIG_USB_CONFIGFS_RNDIS
CONFIG_USB_CONFIGFS_EEM
CONFIG_USB_CONFIGFS_MASS_STORAGE
CONFIG_USB_LAN78XX
CONFIG_WLAN_VENDOR_ATH
CONFIG_ATH9K_HTC
CONFIG_CARL9170
CONFIG_ATH6KL
CONFIG_ATH6KL_USB
CONFIG_WLAN_VENDOR_MEDIATEK
CONFIG_MT7601U
CONFIG_WLAN_VENDOR_RALINK
CONFIG_RT2X00
CONFIG_RT2500USB
CONFIG_RT73USB
CONFIG_RT2800USB
CONFIG_RT2800USB_RT33XX
CONFIG_RT2800USB_RT35XX
CONFIG_RT2800USB_RT3573
CONFIG_RT2800USB_RT53XX
CONFIG_RT2800USB_RT55XX
CONFIG_RT2800USB_UNKNOWN
CONFIG_WLAN_VENDOR_REALTEK
CONFIG_RTL8187
CONFIG_RTL_CARDS
CONFIG_RTL8192CU
CONFIG_RTL8XXXU_UNTESTED
CONFIG_WLAN_VENDOR_ZYDAS
CONFIG_USB_ZD1201
CONFIG_ZD1211RW
CONFIG_USB_NET_RNDIS_WLAN
CONFIG_BT_HCIVHCI
CONFIG_MACVLAN
CONFIG_CHECKPOINT_RESTORE
CONFIG_UNIX_DIAG
CONFIG_PACKET_DIAG
CONFIG_NETLINK_DIAG
CONFIG_MEDIA_TUNER
"

CONFIGS_OFF="
"
CONFIGS_EQ="
"

ered() {
	echo -e "\033[31m" $@
}

egreen() {
	echo -e "\033[32m" $@
}

ewhite() {
	echo -e "\033[37m" $@
}

echo -e "\n\nChecking config file for kali specific config options.\n\n"

errors=0
fixes=0

for c in $CONFIGS_ON $CONFIGS_OFF;do
	cnt=`grep -w -c $c $FILE`
	if [ $cnt -gt 1 ];then
		ered "$c appears more than once in the config file, fix this"
		errors=$((errors+1))
	fi

	if [ $cnt -eq 0 ];then
		if $write ; then
			ewhite "Creating $c"
			echo "# $c is not set" >> "$FILE"
			fixes=$((fixes+1))
		else
			ered "$c is neither enabled nor disabled in the config file"
			errors=$((errors+1))
		fi
	fi
done

for c in $CONFIGS_ON;do
	if grep "$c=y\|$c=m" "$FILE" >/dev/null;then
		egreen "$c is already set"
	else
		if $write ; then
			ewhite "Setting $c"
			sed  -i "s,# $c is not set,$c=y," "$FILE"
			fixes=$((fixes+1))
		else
			ered "$c is not set, set it"
			errors=$((errors+1))
		fi
	fi
done

for c in $CONFIGS_EQ;do
	lhs=$(awk -F= '{ print $1 }' <(echo $c))
	rhs=$(awk -F= '{ print $2 }' <(echo $c))
	if grep "^$c" "$FILE" >/dev/null;then
		egreen "$c is already set correctly."
		continue
	elif grep "^$lhs" "$FILE" >/dev/null;then
		cur=$(awk -F= '{ print $2 }' <(grep "^$lhs=" "$FILE"))
		ered "$lhs is set, but to $cur not $rhs."
		if $write ; then
			egreen "Setting $c correctly"
			sed -i 's,^'"$lhs"'.*,# '"$lhs"' was '"$cur"'\n'"$c"',' "$FILE"
			fixes=$((fixes+1))
		fi
	else
		if $write ; then
			ewhite "Setting $c"
			echo  "$c" >> "$FILE"
			fixes=$((fixes+1))
		else
			ered "$c is not set"
			errors=$((errors+1))
		fi
	fi
done

for c in $CONFIGS_OFF;do
	if grep "$c=y\|$c=m" "$FILE" >/dev/null;then
		if $write ; then
			ewhite "Unsetting $c"
			sed  -i "s,$c=.*,# $c is not set," $FILE
			fixes=$((fixes+1))
		else
			ered "$c is set, unset it"
			errors=$((errors+1))
		fi
	else
		egreen "$c is already unset"
	fi
done

if [ $errors -eq 0 ];then
	egreen "\n\nConfig file checked, found no errors.\n\n"
else
	ered "\n\nConfig file checked, found $errors errors that I did not fix.\n\n"
fi

if [ $fixes -gt 0 ];then
	egreen "Made $fixes fixes.\n\n"
fi

ewhite " "