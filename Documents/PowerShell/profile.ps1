$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$env:DOCUMENTS = [Environment]::GetFolderPath('mydocuments')
$env:EDITOR = 'nvim'

Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord Ctrl+n -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Chord Alt+r -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord Alt+t -Description 'Moves to parent directory' -ScriptBlock {
  Set-Location ../
  [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
Set-PSReadLineKeyHandler -Chord Alt+o -Description 'Moves to previous directory' -ScriptBlock {
  Set-Location -
  [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
Set-PSReadLineKeyHandler -Chord Alt+l -ScriptBlock {
  Get-ChildItem ./ | Out-Default
  [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
Set-PSReadLineKeyHandler -Chord Alt+s -Description 'Changes current command to run in an elevated context' -ScriptBlock {
  # TODO: Parse AST
  $current = $null
  $cursor = 0
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$current, [ref]$cursor)
  if ($current.StartsWith('Invoke-Elevated')) {
    $len = $current.Length - $current.Substring(15).TrimStart().Length
    [Microsoft.PowerShell.PSConsoleReadLine]::Delete(0, $len)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - $len)
  } else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, 0, 'Invoke-Elevated ')
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 16)
  }
}

$ExecutionContext.InvokeCommand.LocationChangedAction += {
  $loc = $_.newPath
  Write-Host -NoNewline "`e]9;9;`"$loc`"`a"
}

$Global:__LastHistoryId = -1
function Global:__Terminal-Get-LastExitCode {
  if ($? -eq $true) {
    return 0
  }
  $LastHistoryEntry = $(Get-History -Count 1)
  $IsPowerShellError = $Error[0].InvocationInfo.HistoryId -eq $LastHistoryEntry.Id
  if ($IsPowerShellError) {
    return -1
  }
  return $LastExitCode
}

function prompt {
  $out = ''

  # Emit mark for the end of the previous command
  $ec = $(__Terminal-Get-LastExitCode);
  $LastHistoryEntry = $(Get-History -Count 1)
  # Skip finishing the command if the first command has not yet started
  if ($Global:__LastHistoryId -ne -1) {
    if ($LastHistoryEntry.Id -eq $Global:__LastHistoryId) {
      # Don't provide a command line or exit code if there was no history entry (eg. ctrl+c, enter on no command)
      $out += "`e]133;D`a"
    } else {
      $out += "`e]133;D;$ec`a"
    }
  }
  $Global:__LastHistoryId = $LastHistoryEntry.Id

  # Prompt started
  $out += "`e]133;A`a"

  $loc = $($ExecutionContext.SessionState.Path.CurrentLocation)
  $out += $("$loc".Replace("$HOME", '~'))

  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
  if ($principal.IsInRole($adminRole)) {
    $out += ' # '
  } else {
    $out += ' $ '
  }
  # Prompt ended, Command started
  $out += "`e]133;B`a"
  return "$out"
}

Set-Alias open Invoke-Item
Set-Alias df Get-Volume
Set-Alias trash Remove-ItemSafely
Set-Alias tracepath Test-NetConnection

function settings {
  Start-Process ms-setttings:
}

function grep {
  $input | Out-String -Stream | Select-String -Raw $args
}

if (Get-Command -ErrorAction SilentlyContinue mise) {
  mise activate pwsh | Out-String | Invoke-Expression
}

# foreach ($cmd in ('kubectl', 'helm', 'helmfile', 'rclone', 'flux', 'cilium')) {
#   if (Get-Command -ErrorAction SilentlyContinue "$cmd") {
#     & $cmd completion powershell | Out-String | Invoke-Expression
#   }
# }
