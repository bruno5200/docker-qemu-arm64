#!/data/data/com.termux/files/usr/bin/bash

pkg update -y
pkg upgrade -y
pkg install -y expect curl qemu-utils qemu-common qemu-system-x86_64-headless openssh


if [ ! -f "config.env" ]; then
    # get the default config file
    cp config.sample config.env
fi

source config.env

echo "[*] Prepare installation directory..."
mkdir -p "$env(INSTALLATION_DIR)"
cp startqemu.sh "$INSTALLATION_DIR/"
cp ssh2qemu.sh "$INSTALLATION_DIR/"

echo "[*] alpine ISO Verification..."
if [ ! -f "$INSTALLATION_DIR/alpine.iso" ]; then
    curl -L -o "$INSTALLATION_DIR/alpine.iso" "$ALPINE_ISO_URL"
fi

echo "[*] Generate SSH Keys for the VM..."
rm -f "$INSTALLATION_DIR/qemukey" "$INSTALLATION_DIR/qemukey.pub"
ssh-keygen -b 2048 -t rsa -N "" -f "$INSTALLATION_DIR/qemukey"

echo "[*] Create a clean virtual disk..."
rm -f "$env(INSTALLATION_DIR)/alpine.img"
qemu-img create -f qcow2 "$env(INSTALLATION_DIR)/alpine.img" "$DISK_SIZE"

expect -f installqemu.expect

echo ""
echo "Process finish!"
echo "To start your new vm:"
echo "  cd $INSTALLATION_DIR && ./startqemu.sh"