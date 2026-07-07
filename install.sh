#!/data/data/com.termux/files/usr/bin/bash

pkg update
pkg install -y expect curl qemu-utils qemu-common qemu-system-aarch64-headless openssh

if [ ! -f "config.env" ]; then
    cp config.sample config.env
fi
source config.env

echo "[*] Preparando directorio de instalación..."
mkdir -p "$INSTALLATION_DIR"
cp startqemu.sh "$INSTALLATION_DIR/"
cp ssh2qemu.sh "$INSTALLATION_DIR/"

echo "[*] Verificando ISO de Alpine..."
if [ ! -f "$INSTALLATION_DIR/alpine.iso" ]; then
    curl -L -o "$INSTALLATION_DIR/alpine.iso" "$ALPINE_ISO_URL"
fi

echo "[*] Generando llaves SSH para la VM..."
rm -f "$INSTALLATION_DIR/qemukey" "$INSTALLATION_DIR/qemukey.pub"
ssh-keygen -b 2048 -t rsa -N "" -f "$INSTALLATION_DIR/qemukey"

echo "[*] Creando disco duro virtual limpio..."
rm -f "$INSTALLATION_DIR/alpine.img"
qemu-img create -f qcow2 "$INSTALLATION_DIR/alpine.img" "$DISK_SIZE"

echo "[*] Iniciando instalación en QEMU via Expect..."
expect -f installqemu.expect

echo ""
echo "¡Proceso finalizado!"
echo "To start your new vm:"
echo "  cd $INSTALLATION_DIR && ./startqemu.sh"
