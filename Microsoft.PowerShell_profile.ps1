oh-my-posh init pwsh --config ~/.oh-my-posh/php.omp.json | Invoke-Expression

fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression

Invoke-Expression (& { (zoxide init powershell | Out-String) })