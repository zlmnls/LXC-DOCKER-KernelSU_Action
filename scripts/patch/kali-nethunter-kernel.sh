#!/bin/bash
# Patches source: kalilinux
# Shell author:   5kind <shikabane320@gmail.com>
# 20240310

apply_nethunter_patches_except() {
    for patch in $NETHUNTER_PATCHES/*.patch; do
        case " $@ " in
            *" $(basename $patch) "*)
                continue    ;;
        esac
        patch -p1 < $patch
    done
}

NETHUNTER_PATCHES=$GITHUB_WORKSPACE/patches/kali-nethunter-kernel/4.14
apply_nethunter_patches_except add-rtl8188eus-to-rtl8xxxu-drivers-4.14.patch
