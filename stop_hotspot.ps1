# 檢查是否具有管理員權限
$IsAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$IsAdminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

# 如果沒有管理員權限，重新啟動腳本以管理員身份運行
if (-not ($IsAdmin.IsInRole($IsAdminRole))) {
    Write-Host "沒有管理員權限，正在重新以管理員身份執行..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 無限循環，每秒檢查一次服務狀態
while ($true) {
    # 取得 icssvc 服務的狀態
    $service = Get-Service -Name "icssvc" -ErrorAction SilentlyContinue

    # 確保服務存在，避免報錯
    if ($service -and $service.Status -eq "Running") {
        # 使用 Start-Process 以隱藏方式執行 net stop icssvc，並將輸出重定向
        Start-Process "cmd.exe" -ArgumentList "/c net stop icssvc >nul 2>&1" -WindowStyle Hidden
    }

    # 延遲 1 秒後再檢查
    Start-Sleep -Seconds 1
}
