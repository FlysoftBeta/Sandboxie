msbuild /t:build Sandboxie\SandboxDrv.sln /p:Configuration="SbieRelease" /p:Platform=x64 -maxcpucount:8
msbuild /t:build Patch\GdrvLoader\gdrv-loader.sln /p:Configuration="Release" /p:Platform=x64 -maxcpucount:8
for /f "tokens=2,3" %%i in ('findstr /r /c:"#define VERSION_" "SandboxiePlus\version.h"') do (
    set "%%i=%%j"
)
iscc "/DVersion=%VERSION_MJR%.%VERSION_MIN%.%VERSION_REV%.%VERSION_UPD%" /O. /Fsbie-patch-setup Patch\patch.iss