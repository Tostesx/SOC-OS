#!/usr/bin/env bash
set -euo pipefail

echo "=== PREFLIGHT ==="
if [ ! -d /sys/firmware/efi ]; then
    echo "ERRO: O sistema não está em modo UEFI. Habilite o EFI no VirtualBox."
    exit 1
fi
ping -c 1 archlinux.org >/dev/null 2>&1 || { echo "ERRO: Sem internet."; exit 1; }
echo "UEFI e Internet: OK"

echo "=== SELECIONANDO DISCO ==="
lsblk
echo -n "Digite o disco alvo (ex: /dev/sda): "
read -r DISK
echo -n "ATENÇÃO: O disco $DISK será APAGADO. Digite 'SIM' para continuar: "
read -r CONFIRM
if [ "$CONFIRM" != "SIM" ]; then echo "Abortado."; exit 1; fi

echo "=== PARTICIONANDO $DISK ==="
umount -R /mnt 2>/dev/null || true
sgdisk --zap-all "$DISK"
sgdisk -n 1:0:+512M -t 1:ef00 "$DISK"
sgdisk -n 2:0:0      -t 2:8300 "$DISK"
partprobe "$DISK"
sleep 2

if [[ "$DISK" == *"nvme"* ]]; then
    PART_EFI="${DISK}p1"; PART_ROOT="${DISK}p2"
else
    PART_EFI="${DISK}1"; PART_ROOT="${DISK}2"
fi

echo "=== FORMATANDO ==="
mkfs.fat -F32 "$PART_EFI"
mkfs.ext4 -F "$PART_ROOT"

echo "=== MONTANDO ==="
mount "$PART_ROOT" /mnt
mount --mkdir "$PART_EFI" /mnt/boot

echo "=== PACSTRAP (INSTALANDO ARCH) ==="
pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode \
    vim tmux networkmanager sudo git curl efibootmgr

echo "=== GERANDO FSTAB ==="
genfstab -U /mnt >> /mnt/etc/fstab

echo "=== CONFIGURANDO O SISTEMA (CHROOT) ==="
cat > /mnt/setup_soc.sh <<'CHROOT_EOF'
#!/usr/bin/env bash
set -euo pipefail

echo ">>> Configurando timezone, locale e teclado..."
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

echo ">>> Configurando hostname..."
echo "soc-01" > /etc/hostname
cat > /etc/hosts <<HOSTS
127.0.0.1 localhost
::1 localhost
127.0.1.1 soc-01.localdomain soc-01
HOSTS

echo ">>> Adicionando repositorio [soc] (via HTTP do host)..."
cat >> /etc/pacman.conf <<PACMAN

[soc]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/Tostesx/SOC-OS/main/packages/repo
PACMAN

echo ">>> Criando usuario soc..."
useradd -m -G wheel -s /bin/bash soc
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
passwd soc

echo ">>> Instalando soc-base (menu, autologin)..."
pacman -Sy --noconfirm --overwrite '/etc/skel/.bash_profile' soc-base

echo ">>> Configurando systemd-boot..."
bootctl install
cat > /boot/loader/loader.conf <<LOADER
default arch.conf
timeout 3
editor no
LOADER

cat > /boot/loader/entries/arch.conf <<ENTRY
title   SOC (Arch Linux)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value $(findmnt -n -o SOURCE /)) rw quiet
ENTRY

echo ">>> Gerando initramfs..."
mkinitcpio -P

echo ">>> Habilitando servicos..."
systemctl enable NetworkManager
systemctl enable avahi-daemon

echo ">>> Instalacao do SOC finalizada no chroot."
CHROOT_EOF

chmod +x /mnt/setup_soc.sh
arch-chroot /mnt /setup_soc.sh

echo "=== FINALIZANDO ==="
umount -R /mnt
echo "Instalacao concluida. Voce pode reiniciar (remova a ISO e reinicie)."
