param (
    [string]$Mensagem,
    [string]$Token = "8376418691:AAFhuEmFfvilB5Z7zgbzYwBfmtzgvfrPaU8",
    [string]$ChatId = "1784353403"
)

function Send-TelegramMessage {
    param (
        [string]$mensagem,
        [string]$token,
        [string]$chatId
    )

    $url = "https://api.telegram.org/bot$token/sendMessage"

    try {
        Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json" -Body (@{
            chat_id = $chatId
            text    = $mensagem
        } | ConvertTo-Json -Depth 3) | Out-Null
        Write-Host "Mensagem enviada com sucesso."
    } catch {
        Write-Host "Falha ao enviar mensagem para o Telegram: $($_.Exception.Message)"
    }
}

Send-TelegramMessage -mensagem $Mensagem -token $Token -chatId $ChatId
