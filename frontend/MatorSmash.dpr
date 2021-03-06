﻿{*******************************************************************************

     The contents of this file are subject to the Mozilla Public License
     Version 1.1 (the "License"); you may not use this file except in
     compliance with the License. You may obtain a copy of the License at
     http://www.mozilla.org/MPL/

     Software distributed under the License is distributed on an "AS IS"
     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
     License for the specific language governing rights and limitations
     under the License.

*******************************************************************************}

program MatorSmash;

uses
  Forms,
  Dialogs,
  Controls,
  SysUtils,
  mteHelpers,
  RttiIni,
  msConfiguration in 'msConfiguration.pas',
  msCore in 'msCore.pas',
  msLoader in 'msLoader.pas',
  msClient in 'msClient.pas',
  msConflict in 'msConflict.pas',
  msChoicePanel in 'msChoicePanel.pas',
  msSmash in 'msSmash.pas',
  msAlgorithm in 'msAlgorithm.pas',
  msProfileForm in 'msProfileForm.pas' {ProfileForm},
  msProfilePanel in 'msProfilePanel.pas',
  msSmashForm in 'msSmashForm.pas' {SmashForm},
  msThreads in 'msThreads.pas',
  msOptionsForm in 'msOptionsForm.pas' {OptionsForm},
  msSplashForm in 'msSplashForm.pas' {SplashForm},
  msEditForm in 'msEditForm.pas' {EditForm},
  msSettingsManager in 'msSettingsManager.pas' {SettingsManager},
  msPluginSelectionForm in 'msPluginSelectionForm.pas' {MiniPluginSelectionForm},
  msConflictForm in 'msConflictForm.pas' {ConflictForm},
  msTagManager in 'msTagManager.pas' {TagManager},
  msTagHelper in 'msTagHelper.pas' {TagHelper};

{$R *.res}
{$MAXSTACKSIZE 2097152}

const
  IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;


{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

var
  bProfileProvided: boolean;
  sParam, sProfile, sPath: string;
  i: Integer;
  aSettings: TSettings;
begin
  // set important vars
  SysUtils.FormatSettings.DecimalSeparator := '.';
  Application.HintHidePause := 8000;
  //ReportMemoryLeaksOnShutdown := true;
  PathList.Values['ProgramPath'] := ExtractFilePath(ParamStr(0));

  // get current profile if profile switch provided
  for i := 1 to ParamCount do begin
    sParam := ParamStr(i);
    if sParam = '-profile' then
      sProfile := ParamStr(i + 1);
  end;
  bProfileProvided := sProfile <> '';
  sPath := Format('%sprofiles\%s\settings.ini', [ProgramPath, sProfile]);
  if bProfileProvided and FileExists(sPath) then begin
    aSettings := TSettings.Create;
    TRttiIni.Load(sPath, aSettings);
    CurrentProfile := TProfile.Create(aSettings.profile);
    CurrentProfile.gameMode := aSettings.gameMode;
    CurrentProfile.gamePath := aSettings.gamePath;
    aSettings.Free;
  end;

  // initialize application
  Application.Initialize;
  ForceDirectories(PathList.Values['ProgramPath'] + 'profiles');
  LoadSettings;
  LoadStatistics;

  // have user select game mode
  if not bProfileProvided then begin
    ProfileForm := TProfileForm.Create(nil);
    if not (ProfileForm.ShowModal = mrOk) then
      exit;
    ProfileForm.Free;
  end;

  // run main application
  Application.Title := 'Mator Smash';
  Application.CreateForm(TSmashForm, SmashForm);
  Application.CreateForm(TProfileForm, ProfileForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TSplashForm, SplashForm);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TSettingsManager, SettingsManager);
  Application.CreateForm(TMiniPluginSelectionForm, MiniPluginSelectionForm);
  Application.CreateForm(TConflictForm, ConflictForm);
  Application.CreateForm(TTagManager, TagManager);
  Application.CreateForm(TTagHelper, TagHelper);
  Application.Run;
end.
