# IT Support Panel

🌐 [Português (BR)](README.md) | **English**

An interactive **Batch (.bat)** menu that lets IT teams run common maintenance, network, printing, diagnostics and driver tasks on Windows computers without having to memorize commands.

![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-0078D6)
![Language](https://img.shields.io/badge/language-Batch-4D4D4D)
![Requires](https://img.shields.io/badge/requires-Administrator%20(critical%20functions)-red)

---

## Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Usage](#usage)
- [Permission control (administrator)](#permission-control-administrator)
- [Action log](#action-log)
- [Function details](#function-details)
- [Repository structure](#repository-structure)
- [Customization](#customization)
- [Important notices](#important-notices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

> **Note:** the menu itself is displayed in Brazilian Portuguese (without accents, for CMD compatibility).

---

## Features

| # | Function | Category | Requires admin |
|---|----------|----------|:--------------:|
| 1 | Clean temporary files | System maintenance | Yes |
| 2 | Advanced disk cleanup | System maintenance | Yes |
| 3 | Check and repair Windows files (SFC) | System maintenance | Yes |
| 4 | Repair the Windows image (DISM) | System maintenance | Yes |
| 5 | Check disk C: (CHKDSK) | System maintenance | Yes |
| 6 | Disk health (HDD/SSD) | System maintenance | No |
| 7 | Network reset (IP, Winsock and DNS) | Network and Internet | Yes |
| 8 | Network information | Network and Internet | No |
| 9 | Connectivity tests | Network and Internet | No |
| 10 | Flush DNS cache | Network and Internet | Yes |
| 11 | Open Network Connections | Network and Internet | No |
| 12 | Clear stuck print queue | Printing | Yes |
| 13 | List printers | Printing | No |
| 14 | System information | Diagnostics | No |
| 15 | Resource monitor and processes | Diagnostics | No |
| 16 | Devices with errors | Drivers and Updates | No |
| 17 | Update drivers (Windows Update) | Drivers and Updates | Yes |
| 18 | Back up drivers | Drivers and Updates | Yes |
| 19 | Check for Windows updates | Drivers and Updates | Yes |
| 20 | View this PC's action log | IT | No |
| A | Reopen the panel as Administrator | — | — |
| 0 | Exit | — | — |

---

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 (built into Windows) — used by functions 6, 13, 15 and 16
- Administrator privileges for the functions marked in the table above
- Internet access for functions 4 (DISM RestoreHealth), 9, 17 and 19

---

## Usage

1. Download `Painel_Suporte_TI.bat` (or clone the repository):
   ```bash
   git clone https://github.com/leoazevdo/it-support-panel.git
   ```
2. **Right-click** the file and choose **Run as administrator**.
3. Type the number of the option you want and press **Enter**.
4. Type `0` to exit.

> If the panel is opened without administrator privileges, the read-only functions still work. Use option **[A]** to reopen it elevated.

---

## Permission control (administrator)

On startup, the script checks whether it is running as administrator (`net session`) and shows the result in the header:

- `Permissao: ADMINISTRADOR` — all functions available.
- `Permissao: USUARIO COMUM` — critical functions are blocked.

When a critical function is selected without privileges, the panel shows an **access denied** message, logs the attempt and returns to the menu without running anything.

---

## Action log

Every action performed (and every blocked attempt) is written to:

```
C:\ProgramData\Painel_Suporte_TI\registro_acoes.log
```

If the folder cannot be created, the log is written to `%TEMP%`.

Line format:

```
[date time] PC_NAME / user - action description
```

The log can be viewed with menu option **[20]**.

---

## Function details

### System maintenance

- **[1] Temporary files** — cleans `%TEMP%`, `C:\Windows\Temp` and `C:\Windows\Prefetch`. Files in use are skipped.
- **[2] Advanced disk cleanup** — opens the `cleanmgr` configuration (`/sageset`) so you can pick items, then runs the cleanup (`/sagerun`).
- **[3] SFC** — runs `sfc /scannow`.
- **[4] DISM** — runs `CheckHealth`, `ScanHealth` and `RestoreHealth`.
- **[5] CHKDSK** — runs `chkdsk C: /scan` (online) and offers to schedule `/f /r` for the next boot.
- **[6] Disk health** — lists physical disks (model, type, health) and volumes (free/total space).

### Network and Internet

- **[7] Network reset** — `netsh winsock reset`, `netsh int ip reset`, `ipconfig /release`, `/renew`, `/flushdns` and `/registerdns`. Asks for confirmation; restart the PC afterwards.
- **[8] Network information** — `ipconfig /all`.
- **[9] Connectivity** — tests loopback, default gateway, internet by IP (8.8.8.8) and name resolution (google.com).
- **[10] DNS cache** — `ipconfig /flushdns`.
- **[11] Network connections** — opens `ncpa.cpl`.

### Printing

- **[12] Stuck queue** — stops the *Spooler* service, deletes `C:\Windows\System32\spool\PRINTERS\*` and restarts the service.
- **[13] Printers** — lists name, driver, port and status.

### Diagnostics

- **[14] System information** — `systeminfo`.
- **[15] Resources and processes** — opens Resource Monitor and lists the 15 processes using the most memory.

### Drivers and updates

- **[16] Devices with errors** — lists PnP devices whose status is not `OK`.
- **[17] Update drivers** — `pnputil /scan-devices` and opens Windows Update optional updates.
- **[18] Driver backup** — exports with `DISM /Export-Driver` to `C:\Backup_Drivers\PCNAME_YYYYMMDD_HHMMSS`.
- **[19] Windows updates** — `usoclient StartScan` and opens Windows Update.

---

## Repository structure

```
.
├── Painel_Suporte_TI.bat   # main script
├── README.md               # documentation (Portuguese - BR)
├── README.en.md            # documentation (English)
└── LICENSE                 # MIT license
```

---

## Customization

- **Header name:** the window title and menu header show `********` as a placeholder; replace it with whatever name you prefer (`title` and the header line).
- **Log location:** edit the `LOGDIR` variable at the top of the script.
- **Driver backup folder:** edit the `DEST` variable in the `:OPT18` section.
- **Critical functions:** to require or lift the admin check for an option, add or remove these two lines at the start of the option block:
  ```bat
  call :RequireAdmin
  if errorlevel 1 goto MENU
  ```
- **New function:** create a new `:OPTxx` label, add `if "%OPC%"=="xx" goto OPTxx` and the matching menu line.

---

## Important notices

- The script runs commands that change the system (file cleanup, network reset, disk repair). **Test on a non-production computer before using it in production.**
- **Network reset (7)** temporarily drops the connection and should be followed by a restart.
- **CHKDSK with `/f /r`** can take a long time on the next boot, depending on the size and condition of the disk.
- **Back up** important data before disk or Windows image repairs.
- Use at your own risk. The project is provided "as is", without warranty.

---

## Troubleshooting

| Problem | Possible cause / fix |
|---------|----------------------|
| "Acesso negado" (access denied) when choosing an option | The panel is not elevated. Use **[A]** or run as administrator. |
| Strange characters in the menu | The file was saved with a different encoding. Keep the script in ANSI/ASCII with CRLF line endings. |
| Options 6, 13, 15 or 16 return nothing | Check that PowerShell is not blocked by group policy. |
| Option 4 (DISM) fails | Check the internet connection and access to Windows Update. |
| The log is not created | Run as administrator or check permissions on `C:\ProgramData`. |

---

## Contributing

1. Fork the repository.
2. Create a branch: `git checkout -b my-improvement`.
3. Commit your changes: `git commit -m "Describe the improvement"`.
4. Push: `git push origin my-improvement`.
5. Open a Pull Request.

> When editing the `.bat`, keep **CRLF** line endings and avoid accented characters in the menu text to prevent garbled output in CMD.

---

## License

Distributed under the **MIT** license. See the [LICENSE](LICENSE) file for details.

---

**Author:** Leonardo Azevedo
