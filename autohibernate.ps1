##This prevents laptops from overheating in the bag, when disconnectinfg from dock, while the lid is closed.
## Add this script in task scheduler,
##Command:
##C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
##Arguments:
##-NoProfile -Executionpolicy bypass -file "C:\Scripts\autohibernate.ps1"
##Trigger every 1 minute

[string]$DriveLetter = "C" # the drive letter to check free space on *** WITHOUT THE SEMICOLON ***
[int64]$ThresholdGB = 20 # how many GB must be free to enable hibernating?
$PowerState = [System.Windows.Forms.PowerState]::Suspend;
$ForceSleep = $true;
$DisableWake = $true;
powercfg -hibernate off #Disable hibernate by default


#Check if laptop is unplugged
If (((Get-CimInstance win32_battery).BatteryStatus) -ne 2 ) {
  #check if there are any active screens, unfortunatelly its almost impossible to get status of the Lid.
  If (((Get-CimInstance -Namespace root\wmi -ClassName wmiMonitorID).Active) ) {
    #Terminate script, if monitor active
    exit
  } else {
    #wait 15 seconds and check again
    Start-Sleep -s 15
    If (((Get-CimInstance win32_battery).BatteryStatus) -ne 2 ) {
      If (((Get-CimInstance -Namespace root\wmi -ClassName wmiMonitorID).Active) ) {
        #Terminate script, if monitor active
        exit
      } else {
        # Get disk info
        $diskInfo = Get-PSDrive $DriveLetter | Select-Object Free
        # Convert to GiB
        [int64]$diskGBFree = $diskInfo.Free
        $diskGbFree = $diskGbFree / 1GB
        #Check if theres enough free space on disk to safely enable hibernation
        If ($diskGBFree -lt $ThresholdGB) {
          #Disable Hibernation and put computer to sleep, prevent wake timers
          powercfg -hibernate off
          [System.Windows.Forms.Application]::SetSuspendState($PowerState, $ForceSleep, $DisableWake);
        } else {
          #Enable hibernation and hibernate computer
          powercfg -hibernate on
          shutdown /h
        }
      }
    } 
  }
}
