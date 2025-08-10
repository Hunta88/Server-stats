#!/bin/bash
# server-stats.sh
# Displays basic server performance statistics in a clean report format

# -------------------------
# HEADER
# -------------------------
echo "======================================"
echo " Server Performance Report"
echo " Generated: $(date +"%Y-%m-%d %H:%M:%S")"
echo "======================================"
echo ""
# -------------------------
# CPU USAGE
# -------------------------

#Refernce
# %Cpu(s):  3.2 us,  0.5 sy,  0.0 ni, 96.0 id,  0.2 wa,  0.0 hi,  0.1 si,  0.0 st

# 1. Use 'top' to get a snapshot of CPU stats (-b for batch mode, -n1 for one iteration)
# 2. Use 'sed' to extract the idle CPU percentage (value before "id")
# 3. Subtract idle percentage from 100 to get usage
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]\+\)%* id.*/\1/")
CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)
echo "CPU Usage: $CPU_USAGE%"


# -------------------------
# MEMORY USAGE
# -------------------------
#Refernce
#              total        used        free      shared  buff/cache   available
#Mem:           7972        1834        4356          98        1781        5702
#Swap:          2047           0        2047

# 1. Use 'free -m' to get memory stats in MB
# 2. Extract total memory (column 2) and used memory (column 3) from the 'Mem:' row
# 3. Calculate usage percentage
USED=$(free -m | awk '/Mem:/ {print $3}')
TOTAL=$(free -m | awk '/Mem:/ {print $2}')
PERCENT=$(echo "scale=2; $USED/$TOTAL*100" | bc)
echo "Memory Usage: $USED MB / $TOTAL MB ($PERCENT%)"


# -------------------------
# DISK USAGE
# -------------------------
#Refernce
# total        470G  183G  263G  42%   -

# 1. Use 'df -h --total' to get total disk usage in human-readable format
# 2. Filter the line with 'total' to sum all mounted filesystems
# 3. Extract total size, used space, free space, and percentage used
DISK_TOTAL=$(df -h --total | grep total | awk '{print $2}')
DISK_USED=$(df -h --total | grep total | awk '{print $3}')
DISK_FREE=$(df -h --total | grep total | awk '{print $4}')
DISK_PERCENT=$(df -h --total | grep total | awk '{print $5}')
echo "Disk Usage: $DISK_USED / $DISK_TOTAL ($DISK_PERCENT used, $DISK_FREE free)"


# -------------------------
# TOP 5 PROCESSES BY CPU
# -------------------------
# 1. Use 'ps aux' to list all processes with CPU usage
# 2. Sort by the %CPU column (column 3 in ps aux output) in descending order
# 3. Display the top 5 processes
echo "Top 5 Processes by CPU Usage:"
ps aux --sort=-%cpu | head -n 6


# -------------------------
# TOP 5 PROCESSES BY MEMORY USAGE
# -------------------------
# 1. 'ps aux' lists all processes with CPU and memory usage stats
# 2. '--sort=-%mem' sorts them by memory usage in descending order
# 3. 'head -n 6' keeps the header plus the top 5 processes
echo "Top 5 Processes by Memory Usage:"
ps aux --sort=-%mem | head -n 6
echo ""

# -------------------------
# FOOTER
# -------------------------
echo "======================================"
echo " End of Report"
echo "======================================"