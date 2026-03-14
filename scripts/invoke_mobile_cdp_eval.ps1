param(
    [Parameter(Mandatory = $true)]
    [string]$Expression,
    [string]$PageTitle = "Codex Command Center",
    [string]$AdbPath = "C:\Users\Ryzen\AppData\Local\Android\Sdk\platform-tools\adb.exe",
    [string]$DeviceId = "emulator-5554",
    [int]$Port = 9222
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& $AdbPath forward "tcp:$Port" "localabstract:chrome_devtools_remote" | Out-Null

$targets = Invoke-RestMethod -Uri ("http://127.0.0.1:{0}/json" -f $Port)
$page = $targets | Where-Object { $_.title -eq $PageTitle } | Select-Object -First 1
if (-not $page) {
    throw "No page matched title: $PageTitle"
}

$ws = [System.Net.WebSockets.ClientWebSocket]::new()
$uri = [Uri]$page.webSocketDebuggerUrl
$cts = [Threading.CancellationTokenSource]::new()
$cts.CancelAfter(15000)
$ws.ConnectAsync($uri, $cts.Token).GetAwaiter().GetResult()

try {
    $payload = @{
        id = 1
        method = "Runtime.evaluate"
        params = @{
            expression = $Expression
            returnByValue = $true
            awaitPromise = $true
        }
    } | ConvertTo-Json -Compress -Depth 8

    $bytes = [Text.Encoding]::UTF8.GetBytes($payload)
    $segment = [ArraySegment[byte]]::new($bytes)
    $ws.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).GetAwaiter().GetResult()

    $buffer = New-Object byte[] 65536
    $builder = New-Object System.Text.StringBuilder
    do {
        $result = $ws.ReceiveAsync([ArraySegment[byte]]::new($buffer), $cts.Token).GetAwaiter().GetResult()
        $builder.Append([Text.Encoding]::UTF8.GetString($buffer, 0, $result.Count)) | Out-Null
    } while (-not $result.EndOfMessage)

    $builder.ToString()
}
finally {
    if ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $ws.CloseAsync(
            [System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure,
            "done",
            [Threading.CancellationToken]::None
        ).GetAwaiter().GetResult()
    }
    $ws.Dispose()
    $cts.Dispose()
}
