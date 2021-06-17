#!/bin/bash

cmd=$1
amount=$2

current_value=$(brightnessctl get)
max_value=$(brightnessctl max)
min_value=500

case $1 in
	up)
		let "new_value=$current_value + $amount"
		if [ $new_value -gt $max_value ]
		then
			new_value=$max_value
		fi
		brightnessctl set $new_value > /dev/null
		;;
	down)
		let "new_value=$current_value - $amount"
		if [ $new_value -lt $min_value ]
		then
			new_value=$min_value
		fi
		brightnessctl set $new_value > /dev/null
		;;
	get)
		echo $current_value
		;;
	max)
		echo $max_value
		;;
	min)
		echo $min_value
		;;
	*)
		echo Unknown command \'$1\'
		;;
esac
