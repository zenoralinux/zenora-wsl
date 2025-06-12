& "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\MakeAppx.exe" pack /d .\AppxPackage /p \release\app\Zenora_WSL_1.0.0.0_x64.appx


& "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe" sign /fd SHA256 /f certificate.pfx /p zenora1234 \release\app\Zenora_WSL_1.0.0.0_x64.appx
