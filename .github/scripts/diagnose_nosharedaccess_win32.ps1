$ErrorActionPreference = 'Stop'

$root = $env:GITHUB_WORKSPACE
$druntime = Join-Path $root 'druntime'
$diagnostics = Join-Path $root 'diagnostics/nosharedaccess-win32'
$compiler = Join-Path $root 'generated/windows/release/32/dmd.exe'
New-Item -ItemType Directory -Force -Path $diagnostics | Out-Null
Set-Location $druntime

$info = Join-Path $diagnostics 'environment.txt'
"commit=$(& git -C $root rev-parse HEAD)" | Set-Content $info
"host_dmd=$env:DMD" | Add-Content $info
"model=32" | Add-Content $info
$versionLog = Join-Path $diagnostics 'compiler-version.log'
& $compiler --version *> $versionLog
Get-Content $versionLog | Add-Content $info

# Mirror the MSVC preprocessing arguments assembled by compiler/src/dmd/link.d.
$preprocessed = Join-Path $diagnostics 'errno.preprocessed.i'
$preprocessLog = Join-Path $diagnostics 'preprocess.log'
$preprocessArgs = @(
    '/std:c11', '/P', '/Zc:preprocessor', '/PD', '/nologo', '/utf-8',
    'src/core/stdc/errno.c',
    "/FI$(Join-Path $druntime 'src/importc.h')",
    "/Fi$preprocessed",
    "/I$(Join-Path $druntime 'src/include')",
    '/I.'
)
"cl.exe $($preprocessArgs -join ' ')" | Set-Content $preprocessLog
$preprocessStdout = Join-Path $diagnostics 'preprocess.stdout'
$preprocessStderr = Join-Path $diagnostics 'preprocess.stderr'
$preprocessProcess = Start-Process -FilePath 'cl.exe' -ArgumentList $preprocessArgs `
    -WorkingDirectory $druntime -Wait -PassThru -NoNewWindow `
    -RedirectStandardOutput $preprocessStdout -RedirectStandardError $preprocessStderr
Get-Content $preprocessStdout, $preprocessStderr | Add-Content $preprocessLog
$preprocessExit = $preprocessProcess.ExitCode
"preprocess_exit_code=$preprocessExit" | Add-Content $info

function Invoke-ErrnoCompile([string] $name, [string[]] $extraFlags) {
    $log = Join-Path $diagnostics "$name.log"
    $stdout = Join-Path $diagnostics "$name.stdout"
    $stderr = Join-Path $diagnostics "$name.stderr"
    $object = "../diagnostics/nosharedaccess-win32/errno_$name.obj"
    $arguments = @(
        '-c', '-conf=', '-Isrc', '-Iimport', '-w', '-de', '-preview=dip1000'
    ) + $extraFlags + @(
        '-preview=fieldwise', '-m32', '-preview=dtorfields', '-O', '-release',
        '-inline', '-I.', '-P=-I.', 'src/core/stdc/errno.c', "-of$object"
    )
    "compiler=$compiler" | Set-Content $log
    "arguments=$($arguments -join ' ')" | Add-Content $log
    $process = Start-Process -FilePath $compiler -ArgumentList $arguments `
        -WorkingDirectory $druntime -Wait -PassThru -NoNewWindow `
        -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    Get-Content $stdout, $stderr | Add-Content $log
    $exitCode = $process.ExitCode
    "exit_code=$exitCode" | Add-Content $log
    return $exitCode
}

$onExit = Invoke-ErrnoCompile 'preview-on' @('-preview=nosharedaccess')
$offExit = Invoke-ErrnoCompile 'preview-off' ([string[]]@())
"preview_on_exit_code=$onExit" | Add-Content $info
"preview_off_exit_code=$offExit" | Add-Content $info
if (Test-Path $preprocessed) {
    "preprocessed_sha256=$((Get-FileHash $preprocessed -Algorithm SHA256).Hash)" | Add-Content $info
}
Get-Content $info | Write-Host
