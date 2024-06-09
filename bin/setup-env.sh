#!/usr/bin/env bash

if [ ! -S ${XDG_RUNTIME_DIR}/bus ]; then
    echo -n "waiting for dbus"
    while [ ! -S ${XDG_RUNTIME_DIR}/bus ]; do
        echo -n "."
        sleep 1s
    done
    echo " done"
fi

if [ ! -S /tmp/.X11-unix/X0 ]; then
    ln -s /mnt/wslg/.X11-unix/X0 /tmp/.X11-unix/
fi

if [ ! -S ${XDG_RUNTIME_DIR}/wayland-0 ]; then
    ln -s /mnt/wslg/runtime-dir/wayland-0* ${XDG_RUNTIME_DIR}/
fi

if [ -z "$(pidof fcitx5)" ]; then
    fcitx5 --disable wayland -d > /dev/null 2>&1
    xset -r 49 > /dev/null 2>&1
fi

export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export INPUT_METHOD=fcitx5
export DefaultIMModule=fcitx5

dbus-update-activation-environment --verbose LANG DISPLAY DBUS_SESSION_BUS_ADDRESS
