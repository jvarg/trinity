#!/bin/bash
#
# This is a useful test to run occasionally, to see which syscalls are
# causing trinity to segfault.

TRINITY_PATH=${TRINITY_PATH:-.}

check_tainted()
{
    if [ "$(cat /proc/sys/kernel/tainted)" != $TAINT ]; then
      echo ERROR: Taint flag changed $(cat /proc/sys/kernel/tainted)
      exit
    fi
}

if [ ! -d tmp ]; then
  mkdir tmp
fi

TAINT=$(cat /proc/sys/kernel/tainted)

while [ 1 ]
do
for syscall in $($TRINITY_PATH/trinity -L | grep entrypoint | grep -v AVOID | awk '{ print $4 }' | sort -u)
do
	chmod 755 tmp
	pushd tmp

	if [ ! -f $TRINITY_PATH/trinity ]; then
		echo lost!
		pwd
		exit
	fi

	MALLOC_CHECK_=2 $TRINITY_PATH/trinity -q -c $syscall -N 99999 -l off -C 64
	popd

	check_tainted
	echo
	echo
done
check_tainted
done
