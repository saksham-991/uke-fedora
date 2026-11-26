# postmarketOS CI/CD for Xiaomi Pad 7 (uke)

**Fully automated GitHub Actions workflow that builds pmOS with KDE Plasma Mobile from your uke-fedora kernel.**

---

## 🎯 What This Produces

| Artifact | Purpose |
|----------|---------|
| `boot.img` | Kernel + initramfs + DTB (Android v4 format, flash to `boot_a` + `boot_b`) |
| `userdata.img` | Full pmOS rootfs with KDE Plasma Mobile (flash to `userdata`) |
| `vmlinuz-linux-xiaomi-uke` | Kernel image (for debugging) |
| `initramfs-*` | Initramfs (for debugging) |

---

## 🚀 Quick Start (While You Sleep)

### 1. Fork & Enable Actions
```bash
# Fork your uke-fedora repo to GitHub (if not already)
# Go to Settings → Actions → General → Enable "Allow all actions"
```

### 2. Extract Firmware (ON YOUR TABLET, ONE TIME)
```bash
# On your rooted tablet:
adb push scripts/extract-firmware.sh /tmp/
adb shell "chmod +x /tmp/extract-firmware.sh && /tmp/extract-firmware.sh"

# This creates /tmp/uke-firmware.tar.gz on tablet
# Pull it:
adb pull /tmp/uke-firmware.tar.gz ./uke-firmware.tar.gz

# Upload to GitHub Release (or any file host), get direct download URL
gh release create firmware-v1 ./uke-firmware.tar.gz --title "Firmware for uke pmOS"
# Copy the download URL from the release
```

### 3. Trigger Build
```bash
# Go to your fork's Actions tab → "Build postmarketOS for Xiaomi Pad 7 (uke)" → Run workflow
# Paste the firmware tarball URL
# Click "Run workflow"
```

### 4. Sleep 😴
**Build takes ~45-90 minutes on GitHub Actions (free).**

### 5. Wake Up → Download Artifacts
```bash
# Go to Actions → Latest run → Artifacts → "pmos-uke-images"
# Download boot.img + userdata.img
```

### 6. Flash (from your CMF 2 Pro via OTG)
```bash
# Tablet in fastboot mode
fastboot flash boot_a boot.img
fastboot flash boot_b boot.img
fastboot flash userdata userdata.img
fastboot set_active a
fastboot reboot
```

### 7. Boot into KDE Plasma Mobile 🎉
```
Login: user
Password: 147147
```

---

## 🔧 How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions (ubuntu-24.04)            │
├─────────────────────────────────────────────────────────────┤
│  1. Checkout uke-fedora (with submodules)                   │
│  2. Download firmware tarball (from your tablet)            │
│  3. Install pmbootstrap + dependencies                      │
│  4. Build linux-xiaomi-uke (your senemos kernel + pmOS cfg) │
│  5. Build device-xiaomi-uke (DTBs, firmware, udev rules)    │
│  6. Build firmware-qcom-sm7675                              │
│  7. pmbootstrap install → rootfs with KDE Plasma Mobile     │
│  8. pmbootstrap export → boot.img + userdata.img            │
│  9. Upload artifacts                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 What's Included (from your uke-fedora)

| Component | Source | Status |
|-----------|--------|--------|
| **Kernel** | `senemos-uke-kernel-mainline` (your tree) | ✅ Freedreno GPU, touch, WiFi, BT, audio, USB, display |
| **DTBs** | Your kernel tree | ✅ SM7675 cliffs panel, touch, UFS, etc. |
| **Firmware** | Extracted from your tablet | ✅ GPU, touch, audio, WiFi, BT, sensors |
| **Display** | 30-144Hz, VRR | ✅ |
| **Touch** | NT36532 10-pt | ✅ |
| **GPU** | Freedreno (OpenGL/Vulkan) | ✅ |
| **WiFi** | WCN6750 (ath11k) | ✅ |
| **Bluetooth** | WCN6750 | ✅ |
| **Audio** | 4 speakers + mics | ✅ |
| **USB-C** | Host/OTG | ✅ |
| **Rotation** | Auto-rotate | ✅ |
| **Sleep** | Suspend | ✅ |
| **Keyboard** | Magnetic Focus WN8030 | ✅ |

---

## 🛠 Customization

### Change Kernel Commit
```bash
# In workflow dispatch: kernel_commit = "your-commit-hash"
```

### Change UI (Plasma Mobile → Phosh/Sxmo/GNOME)
```yaml
# In pmos-build.yml env:
PMOS_UI: phosh  # or sxmo, gnome-mobile
```

### Change Password
```yaml
# In pmos-build.yml env:
PMOS_PASSWORD: your-password
```

### Add More Packages
```yaml
# In pmbootstrap/config/pmos-uke.yaml:
packages="
  ...
  your-package
  "
```

---

## 📋 Requirements

| Requirement | Details |
|-------------|---------|
| **GitHub Account** | For Actions (free, public repo = unlimited minutes) |
| **Rooted uke tablet** | To extract firmware (one-time) |
| **CMF 2 Pro + OTG** | To flash (or any Linux/Windows host with fastboot) |
| **GitHub Release** | To host firmware tarball (or use any direct-download URL) |

---

## 🐛 Troubleshooting

| Issue | Fix |
|-------|-----|
| Build fails on kernel | Check kernel commit exists in senemos-uke-kernel-mainline |
| Firmware missing | Re-run extract-firmware.sh, ensure all files copied |
| boot.img too large | Remove unused DTBs in device APKBUILD |
| userdata.img too large | Reduce packages in pmos-uke.yaml |
| Flash fails | Verify partition names: `fastboot getvar partition-size:userdata` |
| No display | Check DTB matches your panel (CSOT vs Tianma) |

---

## 📚 References

- Your uke-fedora: https://github.com/saksham-991/uke-fedora
- Kernel tree: https://github.com/saksham-991/senemos-uke-kernel-mainline
- pmbootstrap docs: https://wiki.postmarketos.org/wiki/Pmbootstrap
- Device porting guide: https://wiki.postmarketos.org/wiki/Porting_to_a_new_device

---

## 🎉 You Did the Hard Part

**This CI just packages your work.** The kernel bring-up, driver integration, hardware support matrix — that was all you (537 commits).

**Now let GitHub Actions do the repetitive build work while you sleep.**

---

*Generated for saksham-991/uke-fedora → postmarketOS port*