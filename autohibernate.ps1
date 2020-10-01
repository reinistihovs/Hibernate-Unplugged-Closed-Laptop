##This prevents laptops from overheating in the bag, when disconnectinfg from dcok, while the lid is closed.
## Add this script in task scheduler,
##Command:
##C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
##Arguments:
##-NoProfile -Executionpolicy bypass -file "C:\Scripts\autohibernate.ps1"
##Trigger every 1 minute

#Check if laptop is unplugged
If (((Get-CimInstance win32_battery).BatteryStatus) -ne 2 ) {
  #check if there are any active screens, unfortunatelly its almost impossible to get status of the Lid.
  If (((Get-CimInstance -Namespace root\wmi -ClassName wmiMonitorID).Active) ) {
    exit
  } else {
  #Put laptop into hibernation
  shutdown /h
  }
}
