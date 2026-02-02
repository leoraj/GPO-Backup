# GPO-Backup  
![GPO Backup Banner](assets/banner.png)
Enterprise‑Grade Group Policy Backup Automation Script

This repository contains a production‑ready PowerShell automation script designed for Windows Server environments that require reliable, auditable, and SOX‑aligned Group Policy Object (GPO) backups.

The script supports:
- Timestamped backup folders (Daily, Weekly, Monthly)
- Automatic retention cleanup
- Centralized logging
- Full GPO backup using `Backup-GPO`
- Enterprise folder structure for long‑term archival
- Easy integration with Task Scheduler

---

## 📁 Folder Structure
C:\Project_Folder\GPO
├── Scripts
│     └── GPO-Backup.ps1 ├── Logs
└── README.md

---

## 🚀 Features
- **Daily, Weekly, Monthly backup logic**  
- **Retention cleanup** (14/90/365 days by default)  
- **Centralized logging** for audit trails  
- **SOX‑ready workflow**  
- **Safe to run on Domain Controllers or management servers**

---

## 🛠️ How to Use

### 1. Edit the script (optional)
Update backup paths or retention values inside `GPO-Backup.ps1`.

### 2. Create a Scheduled Task
Use Task Scheduler:

**Program/script**
powershell.exe


**Arguments**
-ExecutionPolicy Bypass -File "C:\Project_Folder\GPO\Scripts\GPO-Backup.ps1"


### 3. Verify Backups
Check:
- Backup folders  
- Log file  
- Task Scheduler history  

---

## 🧪 Restore Instructions
Use GPMC:

**Group Policy Management → Group Policy Objects → Manage Backups → Restore**

Or PowerShell:

```powershell
Restore-GPO -Name "<GPO Name>" -Path "<BackupFolder>"
