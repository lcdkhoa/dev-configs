oh-my-posh init pwsh --config "D:/local_repo/charlie-custom-config.omp.json" | Invoke-Expression
if (-Not (Get-Module -Name PSReadLine -ListAvailable)) {
    Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
}

function k8s-proxy {
    $Services = @{
        "1" = @{ Name = "Ingress"; NS = "ingress-nginx"; Cmd = "kubectl port-forward deployments/nginx-ingress-ingress-nginx-controller 80:80 443:443 8443:8443 -n ingress-nginx" }
        "2" = @{ Name = "ClickHouse"; NS = "360f-core"; Cmd = "kubectl port-forward service/svc-clickhouse 8123:8123 -n 360f-core" }
        "3" = @{ Name = "RabbitMQ"; NS = "rabbitmq"; Cmd = "Dynamic" }
        "4" = @{ Name = "Redis"; NS = "foresightpro-backend-dev"; Cmd = "kubectl port-forward deployments/foresightpro-redis-server-side 6379:6380 -n foresightpro-backend-dev --address 127.0.0.1" }
    }

    Write-Host "`n--- K8S PROXY MANAGER ---" -ForegroundColor Cyan
    Write-Host "1. Change Context | 2. Start Services | 3. Exit"
    $mode = Read-Host "Select"

    if ($mode -eq "1") {
        $ctxs = kubectl config get-contexts -o name
        for ($i=0; $i -lt $ctxs.Count; $i++) { Write-Host "$($i+1). $($ctxs[$i])" }
        $idx = [int](Read-Host "Number") - 1
        if ($idx -ge 0 -and $idx -lt $ctxs.Count) { kubectl config use-context $ctxs[$idx] }
    }
    elseif ($mode -eq "2") {
        Write-Host "`nSelect (space separated, e.g: 1 2):" -ForegroundColor Green
        Write-Host "1:Ingress  2:ClickHouse  3:RabbitMQ  4:Redis"
        $picks = (Read-Host "Choices").Split(" ")
        foreach ($p in $picks) {
            if ($Services.ContainsKey($p)) {
                $s = $Services[$p]
                $finalCmd = $s.Cmd
                
                # Xử lý lấy Pod động cho RabbitMQ
                if ($p -eq "3") { 
                    $pod = kubectl get pods -n rabbitmq -l app.kubernetes.io/name=rabbitmq -o jsonpath='{.items[0].metadata.name}'
                    $finalCmd = "kubectl port-forward pod/$pod 15672:15672 -n rabbitmq"
                }
                
                # Mở cửa sổ mới chạy Port-forward
                Start-Process powershell -ArgumentList "-NoExit", "-Command", "
                    `$Host.UI.RawUI.WindowTitle = 'PF-$($s.Name)';
                    Write-Host 'Starting $($s.Name)...' -ForegroundColor Green;
                    for (`$i=1; `$i -le 3; `$i++) {
                        Invoke-Expression '$finalCmd';
                        Write-Host 'Connection lost. Retry `$i/3 in 5s...' -ForegroundColor Yellow; 
                        Start-Sleep 5
                    }
                    Read-Host 'Press Enter to exit...'"
            }
        }
    }
}

# Add auto complete (requires PSReadline 2.2.0-beta1+ prerelease)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# Shows navigable menu of all options when hitting Tab
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Autocompleteion for Arrow keys
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineOption -PredictionSource History

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
