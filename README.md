<p align="center">
  <img src="branding/noctora-logo.svg" width="160" alt="Noctora owl logo">
</p>

<h1 align="center">Noctora OS</h1>
<p align="center"><b>Come alive after dark.</b><br>
The living-room operating system, powered by Plasma Bigscreen.</p>

---

Noctora OS turns a mini PC, HTPC or old laptop into a TV box. It boots straight into
[Plasma Bigscreen](https://plasma-bigscreen.org), KDE's 10-foot TV interface. There's no
desktop to deal with, and you control it with a TV remote (HDMI-CEC), a game controller
or a Bluetooth remote.

**First release:** Noctora OS 1.0 "Afterdark"

## What you get

| | |
|---|---|
| **Boots to the TV** | Logs in automatically to Plasma Bigscreen. The regular Plasma desktop is still installed as a fallback. |
| **Media works immediately** | Full codec set and hardware video decoding (from the Universal Blue base image). |
| **Couch control** | HDMI-CEC TV remotes, game controllers, on-screen keyboard. |
| **Streaming tiles** | Netflix (1080p), Crunchyroll, HIDIVE, Pluto TV and Tubi open full screen like TV apps; YouTube via VacuumTube's TV interface. |
| **App bundle** | Chrome, VacuumTube, Jellyfin, Plex HTPC, Steam, RetroArch and Moonlight, installed from Flathub on first boot. |
| **Unbreakable updates** | Fedora Atomic: the OS is read-only, updates download in the background and apply on reboot, and you can always roll back. Apps update daily. |
| **Owl branding** | Boot splash, logo, "Afterdark" wallpaper and OS name. |

## How it's built

```
Containerfile                  ← image recipe (based on ghcr.io/ublue-os/kinoite-main)
build_files/build.sh           ← packages, branding, boot splash, services
system_files/                  ← copied straight into the OS
  usr/libexec/noctora/         ← first-boot scripts (autologin, app install)
  usr/lib/systemd/system/      ← Noctora services and timers
  usr/share/noctora/flatpaks.list  ← the first-boot app bundle (edit me!)
  usr/share/plymouth/themes/noctora/  ← boot splash
  usr/share/wallpapers/Noctora/       ← Afterdark wallpaper
branding/                      ← logo + wordmark sources, wallpaper generator
iso/config.toml                ← installer settings
.github/workflows/             ← automatic image build + ISO build
```

## Getting it running

### 1. Put it on GitHub
1. Create a GitHub repo (e.g. `noctora-os`) and push this folder to it.
2. The **Build Noctora OS image** workflow runs automatically and publishes
   `ghcr.io/<your-github-name>/noctora-os:latest`.
3. On GitHub, open **Your profile → Packages → noctora-os → Package settings** and set the
   visibility to **Public** so installed TVs can download updates.

### 2. Make an installer ISO
1. Go to **Actions → Build Noctora OS installer ISO → Run workflow**.
2. When it finishes, download the ISO from the run's **Artifacts** section.
3. Flash it to a USB stick (Fedora Media Writer, balenaEtcher or Ventoy) and install.
   Create your user account in the installer: Noctora logs that account into the TV
   interface automatically.

### Already running Fedora Kinoite / Bazzite / Aurora?
You can switch an existing atomic install to Noctora:
```bash
sudo bootc switch ghcr.io/<your-github-name>/noctora-os:latest
systemctl reboot
```

### Build locally
```bash
podman build -t noctora-os .
```

## Customizing

- **Change the app bundle:** edit `system_files/usr/share/noctora/flatpaks.list`.
- **Add a streaming tile:** copy one of `system_files/usr/share/applications/noctora-*.desktop`, change the name and URL, and add an icon in `system_files/usr/share/icons/hicolor/scalable/apps/`.
- **Normal login screen instead of auto-boot to TV:** see `/etc/noctora/README` on the installed system.
- **Change the wallpaper:** `python3 branding/make_wallpaper.py system_files/usr/share/wallpapers/Noctora/contents/images`
- **Rename the GitHub links:** `HOME_URL` / `BUG_REPORT_URL` in `build_files/build.sh`.

## Roadmap

- [ ] First-boot setup on the TV (Wi-Fi, remote pairing, choose apps), no keyboard needed
- [ ] Set the Afterdark wallpaper as the Bigscreen default
- [ ] Sign images with cosign
- [ ] NVIDIA variant (`kinoite-nvidia` base)
- [ ] ARM image for Raspberry Pi-class boards
- [ ] Website (noctora.org) and download page

## Credits

Noctora OS is an independent project. It is built on [Fedora](https://fedoraproject.org),
[Universal Blue](https://universal-blue.org) and [KDE Plasma Bigscreen](https://plasma-bigscreen.org).
"KDE" and "Plasma" are trademarks of KDE e.V. Noctora is not affiliated with or endorsed by KDE,
Fedora or Universal Blue.
