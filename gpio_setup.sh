#!/bin/sh

echo 18 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio18/direction
