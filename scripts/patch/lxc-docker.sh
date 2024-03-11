#!/bin/bash
# Patches source:
# - cgroup.patch:            wu17481748
# - xt_qtaguid.patch:        FreddieOliveira
# - mm.patch & cpuset.patch: xy815661276 <815661276@qq.com>
# Shell author:              5kind <shikabane320@gmail.com>
# 20240310

apply_patch() {
  local patch_file=$1
  local target_file=$2

  if [ ! -f "$target_file" ]; then
    echo "Warning: Target file '$target_file' does not exist."
  fi

  if [ ! -f "$patch_file" ]; then
    echo "Warning: Patch file '$patch_file' does not exist."
  fi

  patch -p1 < "$patch_file"

  if [ $? -eq 0 ]; then
    echo "Patch applied successfully."
  else
    echo "Warning: Failed to apply patch."
  fi
}

## Source: https://github.com/wu17481748/android-lxc-docker
# apply_patch $LXC_PATCHES/cgroup.patch kernel/cgroup.c
apply_patch $LXC_PATCHES/cgroup.patch kernel/cgroup/cgroup.c

## Source: https://gist.github.com/FreddieOliveira/efe850df7ff3951cb62d74bd770dce27#41-kernel-patches
apply_patch $LXC_PATCHES/xt_qtaguid.patch net/netfilter/xt_qtaguid.c

## Source: https://github.com/CGCL-codes/Android-Container
# apply_patch $LXC_PATCHES/mm.patch include/linux/mm.h
# apply_patch $LXC_PATCHES/cpuset.patch kernel/cgroup/cpuset.c
