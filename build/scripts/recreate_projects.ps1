param(
    [string]$ToolRoot = 'E:\vivado2026.1\2026.1',
    [string]$OutputRoot = 'F:\fpga_2026_1_build'
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if ($ProjectRoot -match '[^\x00-\x7F]') {
    throw 'Copy the package to an ASCII-only path such as F:\fpga_project before building.'
}
$Vivado = Join-Path $ToolRoot 'Vivado\bin\vivado.bat'
if (-not (Test-Path -LiteralPath $Vivado)) { throw "Vivado not found: $Vivado" }
$NavOut = Join-Path $OutputRoot 'navigator'
$AxOut = Join-Path $OutputRoot 'ax7020'
if ((Test-Path -LiteralPath $NavOut) -or (Test-Path -LiteralPath $AxOut)) {
    throw "Use a new output root: $OutputRoot"
}
& $Vivado -mode batch -nolog -nojournal -notrace -source (Join-Path $ProjectRoot 'src\navigator\hardware\recreate.tcl') -tclargs $NavOut
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $Vivado -mode batch -nolog -nojournal -notrace -source (Join-Path $ProjectRoot 'src\ax7020\hardware\recreate.tcl') -tclargs $AxOut
exit $LASTEXITCODE
