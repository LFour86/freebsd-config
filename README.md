# FreeBSD Configuration Collection

This repository contains my personal FreeBSD configuration files, scripts, and optimizations.  
The goal is to provide a highly reproducible setup that can be deployed across multiple machines with minimum effort.

---

## 📁 Repository Structure

```text
freebsd-config/
├── etc/
|   ├── devfs.rules
|   ├── fstab
|   ├── make.conf
|   ├── motd.template
│   ├── rc.conf
│   └── sysctl.conf
|
├── boot/
|   ├── device.hints
│   └── loader.conf
|
├── usr/local/
│       └── etc/
│           ├── ipfw.rules
│           └── rc.motd
|
├── config/
|      ├── fastfetch/
|      └── wofi/
|
├── desktop/
│
└── README.md
```

Each folder is logically separated:

- `etc/` — core system configuration files
- `boot/` — bootloader or module-loading adjustments  
- `usr/local/etc/` — user`s script and rules
- `config/` — user-level application configuration  
- `desktop/` — desktop apps configs  

---

## ✨ Features & Highlights

This configuration aims to deliver:

1. **NVIDIA / Wayland support**  
   Preconfigured GPU modules for NVIDIA and Wayland-friendly settings.

2. **Optimized network stack & IPFW firewall**  
   Use modern TCP (BBR / RACK), efficient IPFW rules, captive portal support, and dynamic switching.

3. **Battery / performance tuning for laptops**  
   Powerd and ACPI tweaks, SSD alignment, etc.

4. **Linuxulator & application compatibility**  
   Preconfigured linux compatibility layer with common software support.

5. **Better firewall mode**  
   Use scientific and strict ipfw rules to ensure security while not affecting normal internet access.

6. **Stylish TTY / console boot**  
   Enhanced console visuals and cleaner boot output.

---

## 🛠️ Usage Instructions

Here’s how to apply this configuration on a new FreeBSD machine:

1. **Clone this repo**  
   ```sh
   git clone https://github.com/LFour86/freebsd-config.git
   cd freebsd-config
   ```
2. override your config
   E.g.
   ```sh
   sudo mv /etc/rc.conf /etc/rc.conf.bak
   sudo cp -r etc/rc.conf rc.conf
   ```
   Or just select the required configuration to add to your file
   
4. **Reboot and test**
   - Run `sudo reboot` to update your config
   - Run `sudo ipfw list` to see if rules are loaded  
   - Test ping, web, captive portal login (e.g. 192.168.1.1)  
   - Check logs: `/var/log/security` and Fail2ban status  

---


