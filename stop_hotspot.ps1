# 檢查腳本是否以管理員身份運行
$IsAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$IsAdminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

# 如果沒有管理員權限，重新啟動腳本以管理員身份運行
if (-not ($IsAdmin.IsInRole($IsAdminRole))) {
    Write-Host "沒有管理員權限，正在重新以管理員身份執行..."
    Start-Process powershell -ArgumentList " -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}

# 如果是管理員，繼續執行腳本
Write-Host "腳本正在以管理員身份運行。"

# 無限循環，每秒檢查一次服務狀態
while ($true) {
    # 取得 icssvc 服務的狀態
    $service = Get-Service -Name "icssvc"

    # 根據服務的狀態執行不同操作
    if ($service.Status -eq "Running") {
        # 如果服務正在運行，嘗試停止服務
        Write-Host "服務正在運行，正在嘗試停止服務..."
        
        # 使用 CMD 執行 net stop icssvc 並將輸出重定向
        Start-Process cmd.exe -ArgumentList "/c net stop icssvc >nul 2>&1"
        
        # 等待一會兒，避免過度執行
        Start-Sleep -Seconds 1
    } elseif ($service.Status -eq "Stopped") {
        # 如果服務已停止，顯示服務已停止
        Write-Host "服務已停止，無需停止。"
    } elseif ($service.Status -eq "Paused") {
        # 如果服務是暫停狀態，顯示暫停訊息
        Write-Host "服務處於暫停狀態。"
    } else {
        # 如果服務處於其他狀態，顯示當前服務狀態
        Write-Host "服務處於其他狀態: $($service.Status)"
    }

    # 延遲 1 秒後再重複執行
    Start-Sleep -Seconds 1
}
