[Setup]
AppId={{D306063F-23BF-44DE-9376-9E564ACF3BD4}
AppName=Sandboxie Patch
AppVersion={#Version}
AppPublisher=Flysoft
DefaultDirName={code:GetSbieInstallation}
DefaultGroupName=Sandboxie Patch
DisableProgramGroupPage=yes
AllowCancelDuringInstall=no
AlwaysRestart=yes
LicenseFile=..\LICENSE.Patch
InfoBeforeFile=..\IMPORTANT
Compression=none
WizardStyle=modern
DirExistsWarning=no
ArchitecturesAllowed=x64os
ArchitecturesInstallIn64BitMode=x64os

[Files]
Source: "GdrvLoader\bin\x64\Release\driver_loader.exe"; DestDir: "{app}"
Source: "gdrv.sys"; DestDir: "{app}"
Source: "..\Sandboxie\Bin\x64\SbieRelease\SbieDrv.sys"; DestDir: "{app}"
Source: "Certificate.dat"; DestDir: "{app}"

[Registry]
Root: HKLM; Subkey: "System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"; ValueType: dword; ValueName: "Enabled"; ValueData: 0
Root: HKLM; Subkey: "System\CurrentControlSet\Control\CI\Config"; ValueType: dword; ValueName: "VulnerableDriverBlocklistEnable"; ValueData: 0

[Run]
Filename: "{sys}\schtasks.exe"; BeforeInstall: CreateTaskXML; Parameters: "/Create /TN ""SbieMaintainence"" /XML ""{tmp}\SbieMaintainence.xml"" /F"; Flags: runhidden

[UninstallRun]
Filename: "{sys}\schtasks.exe"; Parameters: "/Delete /TN ""SbieMaintainence"" /F"; Flags: runhidden; RunOnceId: "RmSchTasks"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Code]
function GetSbieInstallation(Param: String): String;
var
  Path: String;
begin
  if RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\Sandboxie-Plus_is1', 'Inno Setup: App Path', Path) then
    Result := Path
  else
    Result := ExpandConstant('{pf}\Sandboxie-Plus');
end;
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if not FileExists(ExpandConstant('{app}\SbieMsg.dll')) then
    begin
      MsgBox(
        'You must select a directory containing a valid Sandboxie installation to continue.' + #13#10 +
        'The patch needs to be installed in the same directory of Sandboxie in order to work.',
        mbError, MB_OK);
      Result := False;
    end;
  end;
end;
function XmlEscape(const S: String): String;
begin
  Result := S
  StringChangeEx(Result, '&', '&amp;', True);
  StringChangeEx(Result, '<', '&lt;', True);
  StringChangeEx(Result, '>', '&gt;', True);
  StringChangeEx(Result, '"', '&quot;', True);
  StringChangeEx(Result, '''', '&apos;', True);
end;
procedure CreateTaskXML;
var
  TaskXMLFile: string;
  TaskXMLContent: AnsiString;
begin
  TaskXMLFile := ExpandConstant('{tmp}\SbieMaintainence.xml');
  TaskXMLContent :=
    '<?xml version="1.0" encoding="UTF-16"?>' + #13#10 +
    '<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">' + #13#10 +
    '  <Triggers>' + #13#10 +
    '    <BootTrigger>' + #13#10 +
    '      <Enabled>true</Enabled>' + #13#10 +
    '    </BootTrigger>' + #13#10 +
    '  </Triggers>' + #13#10 +
    '  <Principals>' + #13#10 +
    '    <Principal id="Author">' + #13#10 +
    '      <UserId>S-1-5-18</UserId>' + #13#10 +
    '      <RunLevel>HighestAvailable</RunLevel>' + #13#10 +
    '    </Principal>' + #13#10 +
    '  </Principals>' + #13#10 +
    '  <Settings>' + #13#10 +
    '    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>' + #13#10 +
    '    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>' + #13#10 +
    '    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>' + #13#10 +
    '    <AllowHardTerminate>false</AllowHardTerminate>' + #13#10 +
    '    <StartWhenAvailable>false</StartWhenAvailable>' + #13#10 +
    '    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>' + #13#10 +
    '    <IdleSettings>' + #13#10 +
    '      <StopOnIdleEnd>false</StopOnIdleEnd>' + #13#10 +
    '      <RestartOnIdle>false</RestartOnIdle>' + #13#10 +
    '    </IdleSettings>' + #13#10 +
    '    <AllowStartOnDemand>true</AllowStartOnDemand>' + #13#10 +
    '    <Enabled>true</Enabled>' + #13#10 +
    '    <Hidden>false</Hidden>' + #13#10 +
    '    <RunOnlyIfIdle>false</RunOnlyIfIdle>' + #13#10 +
    '    <WakeToRun>false</WakeToRun>' + #13#10 +
    '    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>' + #13#10 +
    '    <Priority>7</Priority>' + #13#10 +
    '  </Settings>' + #13#10 +
    '  <Actions Context="Author">' + #13#10 +
    '    <Exec>' + #13#10 +
    '      <Command>' + XmlEscape(ExpandConstant('{app}\driver_loader.exe')) + '</Command>' + #13#10 +
    '      <Arguments>"' + XmlEscape(ExpandConstant('{app}\gdrv.sys')) + '" "' + XmlEscape(ExpandConstant('{app}\SbieDrv.sys')) + '"</Arguments>' + #13#10 +
    '    </Exec>' + #13#10 +
    '  </Actions>' + #13#10 +
    '</Task>';

  SaveStringToFile(TaskXMLFile, TaskXMLContent, False);
end;
