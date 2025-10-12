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

7. **Hyprland desktop environment**  
   Pre-made configs for Hyprland / Wayland sessions.

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

## 🔄 Auto‑Switch Firewall (Public / Private)

In `usr_local/etc/ipfw_autoswitch.sh`, there's a script that:

- Detects the current network (e.g. by gateway IP or SSID or subnet)  
- If in a **trusted private network**, loads a more permissive firewall rule set  
- If in **public Wi-Fi**, applies stricter inbound-deny rules and enhanced logging  

You can integrate it via:
```sh
# e.g. call from /etc/rc.local or via cron @reboot
/usr/local/etc/ipfw_autoswitch.sh
```

---

## 🧮 Customization & Tips

- You might have **dual GPU hardware** (AMD + NVIDIA). Uncomment only one driver stack in `boot/loader.conf` or `rc.conf` (don’t load both).  
- Modify the BBR / TCP settings in `sysctl.conf` to suit your broadband link speed.  
- If you don’t run web server / SSH, you can remove or comment out those open port lines in `ipfw.rules`.  
- Use `ipfw list` and `ipfw show` to monitor rule hits and adjust priorities.  
- If Fail2ban logs start flooding, adjust your `deny log` rules to restrict logging only to sensitive ports or interfaces.

---

## 🧷 Acknowledgements

- Inspiration from various FreeBSD desktop & firewall guides  
- IPFW performance tuning resources & BBR / RACK TCP research  
- Wayland / Hyprland communities for desktop config conventions  

---

## 📬 Contact

If you run into issues, have questions, or ideas, feel free to open an issue or reach out!

Enjoy FreeBSD!  
― LFour86
