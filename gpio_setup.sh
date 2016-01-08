#!/bin/sh

echo 18 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio18/direction

echo 17 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio17/direction
chmod -R 777 /sys/class/gpio/gpio17
