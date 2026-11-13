#!/usr/bin/env bash
# Noctora OS image build script. Runs once inside the Containerfile.
set -euxo pipefail

NOCTORA_VERSION="${NOCTORA_VERSION:-1.0}"
NOCTORA_CODENAME="${NOCTORA_CODENAME:-Afterdark}"

### 1. Packages ##############################################################

# Required: the TV interface itself and the boot-splash base theme.
# If either is missing the build must fail, not silently produce a desktop OS.
dnf5 -y install plasma-bigscreen plymouth-theme-spinner

# Nice-to-have: remote/controller input, on-screen keyboard, HDMI-CEC,
# extra controller udev rules. Skipped quietly if a name isn't in the repos.
dnf5 -y install --skip-unavailable \
    plasma-bigscreen-wayland \
    plasma-remotecontrollers \
    qt6-qtvirtualkeyboard \
    libcec \
    game-devices-udev

### 2. Find the Bigscreen session ###########################################

SESSION_FILE="$(find /usr/share/wayland-sessions -maxdepth 1 -iname '*bigscreen*.desktop' -printf '%f\n' | sort | head -n1)"
if [[ -z "${SESSION_FILE}" ]]; then
    echo "ERROR: no Plasma Bigscreen Wayland session was installed." >&2
    ls -l /usr/share/wayland-sessions >&2 || true
    exit 1
fi
mkdir -p /usr/lib/noctora
echo "${SESSION_FILE}" > /usr/lib/noctora/session
echo "Noctora will boot into session: ${SESSION_FILE}"

### 3. OS identity ###########################################################

# ID stays "fedora" so Fedora tooling and repos keep working.
set_os_release() {
    local key="$1" value="$2" file=/usr/lib/os-release
    if grep -q "^${key}=" "${file}"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "${file}"
    else
        echo "${key}=\"${value}\"" >> "${file}"
    fi
}
set_os_release NAME "Noctora OS"
set_os_release PRETTY_NAME "Noctora OS ${NOCTORA_VERSION} (${NOCTORA_CODENAME})"
set_os_release VERSION_CODENAME "${NOCTORA_CODENAME,,}"
set_os_release VARIANT "Noctora"
set_os_release VARIANT_ID "noctora"
set_os_release LOGO "noctora-logo"
set_os_release HOME_URL "https://github.com/sidewaysgaming89-bit/noctora-os"
set_os_release BUG_REPORT_URL "https://github.com/sidewaysgaming89-bit/noctora-os/issues"

### 4. Boot splash ###########################################################

# Reuse Fedora's spinner animation frames; our own watermark (owl + wordmark)
# is already in the theme folder and is not overwritten.
THEME_DIR=/usr/share/plymouth/themes/noctora
cp -n /usr/share/plymouth/themes/spinner/*.png "${THEME_DIR}/"
plymouth-set-default-theme noctora

# Rebuild the initramfs so the new splash is used from the first frame.
KVER="$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -printf '%f\n' | sort -V | tail -n1)"
dracut --no-hostonly --kver "${KVER}" --reproducible --zstd -v \
    --add ostree -f "/usr/lib/modules/${KVER}/initramfs.img"
chmod 0600 "/usr/lib/modules/${KVER}/initramfs.img"

### 5. Services ##############################################################

chmod 0755 /usr/libexec/noctora/*
systemctl enable noctora-autologin.service
systemctl enable noctora-firstboot-apps.service
systemctl enable noctora-flatpak-update.timer
# Download OS updates in the background; they apply on the next reboot.
systemctl enable rpm-ostreed-automatic.timer || true

### 6. Installer compatibility ################################################

# Fedora 45 keeps its repo files in /usr/share/dnf5/repos.d, but the ISO
# builder (bootc-image-builder) only looks in /etc/yum.repos.d. Link them
# back so the installer ISO can be built. dnf5 treats a same-named /etc file
# as an override of the /usr/share one, so nothing is listed twice.
if [[ -d /usr/share/dnf5/repos.d ]]; then
    mkdir -p /etc/yum.repos.d
    for repo in /usr/share/dnf5/repos.d/*.repo; do
        [[ -e "${repo}" ]] || continue
        name="$(basename "${repo}")"
        [[ -e "/etc/yum.repos.d/${name}" ]] || ln -s "../../usr/share/dnf5/repos.d/${name}" "/etc/yum.repos.d/${name}"
    done
fi
ls -l /etc/yum.repos.d

### 7. Clean up ##############################################################

dnf5 clean all
rm -rf /var/cache/libdnf5 /var/log/dnf5* /tmp/*
