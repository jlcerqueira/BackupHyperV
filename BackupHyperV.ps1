# Lista todas as VMs
$VMs = Get-VM

# Caminho base do backup
$BackupPath = "C:\BackupVMs"

# Lista para armazenar os resultados
$resultados = @()

foreach ($VM in $VMs) {
    $VMName = $VM.Name

    # Cria subpasta com data e hora para evitar sobrescrever
    $DataHora = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $ExportPath = "$BackupPath\$VMName\$DataHora"

    try {
        Export-VM -Name $VMName -Path $ExportPath -ErrorAction Stop
        $resultados += "$VMName - Backup concluído com sucesso"
    } catch {
        $erroMsg = $_.Exception.Message
        $resultados += "$VMName - Falha no backup: $erroMsg"
    }
}

# Monta a mensagem com data atual
$DataAtual = Get-Date -Format 'dd/MM/yyyy HH:mm'
$Mensagem = "Resultado do Backup das VMs em ${DataAtual}:`r`n" + ($resultados -join "`r`n")

# Remove caracteres não ASCII (opcional)
$Mensagem = -join ($Mensagem.ToCharArray() | Where-Object { [int]$_ -lt 128 })

# Envia mensagem para o Telegram
& "C:\Program Files\Lab\Tasks\Send-TelegramMessage.ps1" -Mensagem $Mensagem
