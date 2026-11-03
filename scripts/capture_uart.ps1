param([string[]]$Ports=@('COM3','COM11'),[int]$Seconds=150,[int]$Baud=115200,[Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference='Stop'
if(Test-Path -LiteralPath $Output){throw 'Use a new output directory'}
New-Item -ItemType Directory -Path $Output | Out-Null
$watch=[System.Diagnostics.Stopwatch]::StartNew()
$opened=@();$writers=@{};$raw=@{};$pending=@{}
try {
 foreach($name in $Ports){
  $port=New-Object System.IO.Ports.SerialPort $name,$Baud,'None',8,'One'
  $port.DtrEnable=$false;$port.RtsEnable=$false;$port.Handshake='None';$port.ReadTimeout=100
  $port.Open();$opened+=,$port
  $writers[$name]=[System.IO.StreamWriter]::new((Join-Path $Output ('serial_'+$name+'.jsonl')),$false,[System.Text.UTF8Encoding]::new($false))
  $raw[$name]=[System.IO.StreamWriter]::new((Join-Path $Output ('serial_'+$name+'.log')),$false,[System.Text.UTF8Encoding]::new($false))
  $writers[$name].AutoFlush=$true;$raw[$name].AutoFlush=$true;$pending[$name]=''
 }
 while($watch.Elapsed.TotalSeconds -lt $Seconds){
  foreach($port in $opened){
   $name=$port.PortName
   if($port.BytesToRead -gt 0){
    $chunk=$port.ReadExisting();$raw[$name].Write($chunk);$pending[$name]+=$chunk
    $lines=$pending[$name] -split "`n";$pending[$name]=$lines[-1]
    for($i=0;$i -lt $lines.Length-1;$i++){
     $entry=@{seconds=$watch.Elapsed.TotalSeconds;utc=[DateTime]::UtcNow.ToString('o');port=$name;text=$lines[$i].TrimEnd("`r")}
     $writers[$name].WriteLine(($entry|ConvertTo-Json -Compress))
    }
   }
  }
  Start-Sleep -Milliseconds 10
 }
} finally {
 foreach($port in $opened){$port.Close();$port.Dispose()}
 foreach($w in $writers.Values){$w.Dispose()};foreach($w in $raw.Values){$w.Dispose()}
 @{ports=$Ports;baud=$Baud;elapsed_seconds=$watch.Elapsed.TotalSeconds;data_written_to_boards=$false;dtr=$false;rts=$false;timestamp='host monotonic receive time; UART buffering and delivery jitter apply'}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $Output 'capture.json') -Encoding UTF8
}
