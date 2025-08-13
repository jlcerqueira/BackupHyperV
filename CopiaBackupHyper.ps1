# Caminhos
$OrigemBase = "C:\BackupVMs"
$DestinoBase = "C:\Users\lab\OneDrive\BackupLab\BackupHyperv"

# Lista para armazenar os resultados
$resultados = @()

# Lista todas as VMs (pastas dentro da origem)
$VMFolders = Get-ChildItem -Path $OrigemBase -Directory

foreach ($VMFolder in $VMFolders) {
    $VMName = $VMFolder.Name
    $BackupSubpastas = Get-ChildItem -Path $VMFolder.FullName -Directory

    foreach ($Subpasta in $BackupSubpastas) {
        $Origem = $Subpasta.FullName
        $Destino = "$DestinoBase\$VMName\$($Subpasta.Name)"

        if (Test-Path -Path $Destino) {
            $resultados += "$VMName - Já existe: $($Subpasta.Name) (não copiado)"
            continue
        }

        try {
            # Cria o diretório de destino
            New-Item -ItemType Directory -Path $Destino | Out-Null

            # Copia os arquivos
            Copy-Item -Path "$Origem\*" -Destination $Destino -Recurse -Force
            $resultados += "$VMName - Copiado: $($Subpasta.Name)"
        } catch {
            $erroMsg = $_.Exception.Message
            $resultados += "$VMName - Falha ao copiar $($Subpasta.Name): $erroMsg"
        }
    }
}

# 🔥 Apagar backups locais com mais de 2 dias
$LimiteDias = (Get-Date).AddDays(-2)
$PastasAntigas = Get-ChildItem -Path $OrigemBase -Recurse -Directory | Where-Object { $_.CreationTime -lt $LimiteDias }

foreach ($pasta in $PastasAntigas) {
    try {
        Remove-Item -Path $pasta.FullName -Recurse -Force
        $resultados += "Removido backup antigo: $($pasta.FullName)"
    } catch {
        $erroMsg = $_.Exception.Message
        $resultados += "Falha ao remover $($pasta.FullName): $erroMsg"
    }
}

# Monta a mensagem com data atual
$DataAtual = Get-Date -Format 'dd/MM/yyyy HH:mm'
$Mensagem = "Resultado da Cópia e Limpeza dos Backups em ${DataAtual}:`r`n" + ($resultados -join "`r`n")

# Remove caracteres não ASCII (opcional)
$Mensagem = -join ($Mensagem.ToCharArray() | Where-Object { [int]$_ -lt 128 })

# Envia mensagem para o Telegram
& "C:\Program Files\Lab\Tasks\Send-TelegramMessage.ps1" -Mensagem $Mensagem
