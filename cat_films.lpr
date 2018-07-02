program cat_films;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  Interfaces, Forms,
  main, datamodule, functions, ecode, ExtParams;
  //zcomponent, uecontrols, edit, kolumny, opis,
  //unit_exit, functions, about, normalizacja_nazw, gen_spis, serwis_filmweb
  //{ you can add units after this };

{$R *.res}

type
  { TBluePlayerVideo }

  TBluePlayerVideo = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  private
    PP_EXIT: boolean;
    parameters: TExtParams;
  end;

procedure TBluePlayerVideo.DoRun;
var
  s: string;
  b: boolean;
begin
  SetConfDir('Cat-Films');
  parameters:=TExtParams.Create(self);
  try
    parameters.ParamsForValues.Add('custom-play');
    parameters.ParamsForValues.Add('set-directory');
    parameters.ParamsForValues.Add('force-dir');
    parameters.ParamsForValues.Add('optical-disc');
    parameters.ParamsForValues.Add('UDI');
    parameters.Execute;
    if parameters.IsParam('help') then
    begin
      writeln;
      writeln('Podpowiedzi wywołania programu z parametrami:');
      writeln('  --new                    Założenie czystej bazy danych');
      writeln('  --scan                   Skanuje katalog z plikami i dodaje je do bazy');
      writeln('  --set-directory          Ustawienie alternatywnego katalogu z plikami');
      writeln('  --set-showmenu           Włączenie menu głównego');
      writeln('  --set-hidemenu           Wyłączenie menu głównego');
      writeln('  --set-showfilters        Włączenie opcji filtrowania');
      writeln('  --set-hidefilters        Wyłączenie opcji filtrowania');
      writeln('  --set-readonly           Ustawienie bazy w trybie tylko do odczytu');
      writeln('  --set-readwrite          Ustawienie bazy w trybie także do zapisu');
      writeln('  --edit                   Uruchomienie programu w trybie edycji danych (ignoruje flagę tylko do odczytu)');
      writeln('  --force-dir [patch]      Podmontuj się pod bazę wskazywaną przez podaną ścieżkę');
      writeln('  --optical-disc [device]  Podany z --force-dir informuje o użyciu nośnika optycznego');
      writeln('  --custom-play [command]  Program będzie odtwarzał filmy za pomocą podanej w parametrze komendy');
      writeln;
      PP_EXIT:=true;
    end;
    NEW_CREATE:=parameters.IsParam('new');
    if parameters.IsParam('force-dir') then
    begin
      FORCE_DIR:=parameters.GetValue('force-dir');
      PARAM_1:=parameters.GetValue('_1');
      s:=FORCE_DIR;
    end else s:=PARAM_1;
    FORCE_SCAN:=parameters.IsParam('scan');

    SetDir(s);
    dm.db.Database:=MyDir('base.dat');
    b:=not FileExists(dm.db.Database);
    if (not b) or NEW_CREATE then
    begin
      dm.db.Connect;
      if b then
      begin
        dm.tr.StartTransaction;
        dm.db_create.Execute;
        dm.tr.Commit;
      end;
    end;

    if parameters.IsParam('optical-disc') then OPTICAL_DISC:=parameters.GetValue('optical-disc');
    if parameters.IsParam('custom-play') then CUSTOM_CMD:=parameters.GetValue('custom-play');
    FORCE_EDIT:=parameters.IsParam('edit');

    if dm.db.Connected then
    begin
      if parameters.IsParam('set-directory') then
      begin
        DEF_DIR:=parameters.GetValue('set-directory');
        dm.WriteString('katalog_domyślny',DEF_DIR);
        writeln('Katalog domyślny plików został ustawiony na: '+DEF_DIR);
        PP_EXIT:=true;
      end;
      if parameters.IsParam('set-showmenu') then
      begin
        dm.WriteBool('pokazuj_menu_główne',true);
        writeln('Włączono pokazywanie menu głównego.');
        PP_EXIT:=true;
      end;
      if parameters.IsParam('set-hidemenu') then
      begin
        dm.WriteBool('pokazuj_menu_główne',false);
        writeln('Wyłączono pokazywanie menu głównego.');
        PP_EXIT:=true;
      end;
      if parameters.IsParam('set-showfilters') then
      begin
        dm.WriteBool('pokazuj_filtrowanie',true);
        writeln('Włączono opcję filtrowania.');
        PP_EXIT:=true;
      end;
      if parameters.IsParam('set-hidefilters') then
      begin
        dm.WriteBool('pokazuj_filtrowanie',false);
        writeln('Wyłączono opcję filtrowania.');
        PP_EXIT:=true;
      end;
      if parameters.IsParam('set-readonly') then
      begin
        dm.WriteBool('db_readwrite',false);
        writeln('System został skonfigurowany jako tylko do odczytu.');
        PP_EXIT:=true;
      end;
      if parameters.IsParam('set-readwrite') then
      begin
        dm.WriteBool('db_readwrite',true);
        writeln('System został skonfigurowany w trybie do odczytu jak i do zapisu.');
        PP_EXIT:=true;
      end;
    end;
  finally
    parameters.Free;
  end;

  if PP_EXIT then
  begin
    terminate;
    exit;
  end;

  FMain:=TFMain.Create(Application);
  try
    RequireDerivedFormResource:=True;
    Application.Scaled:=True;
    Application.Initialize;
    Application.CreateForm(TFMain, FMain);
    Application.Run;
  finally
    FMain.Free;
  end;
  Terminate;
end;

constructor TBluePlayerVideo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  PP_EXIT:=false;
  dm:=Tdm.Create(self);
  StopOnException:=True;
end;

destructor TBluePlayerVideo.Destroy;
begin
  if dm.db.Connected then dm.db.Disconnect;
  dm.Free;
  inherited Destroy;
end;

var
  Apps: TBluePlayerVideo;
begin
  Apps:=TBluePlayerVideo.Create(nil);
  Apps.Title:='BluePlayerVideo';
  Apps.Run;
  Apps.Free;
end.
