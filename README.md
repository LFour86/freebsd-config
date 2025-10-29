# FreeBSD Configuration Collection

This repository contains my personal FreeBSD configuration files, scripts, and optimizations.  
The goal is to provide a highly reproducible setup that can be deployed across multiple machines with minimum effort.

---

## 📁 Repository Structure

```text
freebsd-config/
├── etc/
│   ├── rc.conf
│   ├── loader.conf
|   ├── sysctl.conf
│   └── ...
├── boot/
|   ├── loader.conf
│   └── ...
├── usr/local/
│       └── etc/
│           ├── ipfw.rules
│           ├── rc.motd
│           └── ...
├── config/
│
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

5. **Dynamic firewall mode switching**  
   Scripts to detect public vs private network and apply stricter rules when needed.

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

2. **Backup existing configs**  
   E.g.:
   ```sh
   sudo cp /etc/rc.conf /etc/rc.conf.bak
   sudo cp /boot/loader.conf /boot/loader.conf.bak
   sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
   ```

3. **Copy selective files**  
   For example:
   ```sh
   sudo cp etc/rc.conf /etc/rc.conf
   sudo cp etc/loader.conf /boot/loader.conf
   sudo cp etc/sysctl.conf /etc/sysctl.conf
   sudo mkdir -p /usr/local/etc
   sudo cp usr_local/etc/ipfw.rules /usr/local/etc/ipfw.rules
   sudo cp usr_local/etc/ipfw_autoswitch.sh /usr/local/etc/ipfw_autoswitch.sh
   sudo chmod +x /usr/local/etc/ipfw_autoswitch.sh
   ```

4. **Enable firewall & fail2ban in `rc.conf`**  
   Ensure your `/etc/rc.conf` includes:
   ```sh
   firewall_enable="YES"
   firewall_script="/usr/local/etc/ipfw.rules"
   firewall_logging="YES"
   fail2ban_enable="YES"
   ```

5. **Reboot and test**  
   - Run `sudo ipfw list` to see if rules are loaded  
   - Test ping, web, captive portal login (e.g. 192.168.1.1)  
   - Check logs: `/var/log/security` and Fail2ban status  

---


