program cat_films;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, Interfaces, Forms, ExtParams, Controls,
  main, datamodule, functions, ecode, cverinfo, opis, multi;
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

var
  Apps: TBluePlayerVideo;

procedure TBluePlayerVideo.DoRun;
var
  s1,s2,s3: string;
  s,pom: string;
  b: boolean;
begin
  GetProgramVersion(s1,s2,s3);
  PROG_VERSION:=s1;
  SetConfDir('Cat-Films');
  parameters:=TExtParams.Create(self);
  try
    parameters.ParamsForValues.Add('custom-play');
    parameters.ParamsForValues.Add('set-directory');
    parameters.ParamsForValues.Add('force-dir');
    parameters.ParamsForValues.Add('optical-disc');
    parameters.ParamsForValues.Add('UDI');
    parameters.ParamsForValues.Add('set-video');
    parameters.ParamsForValues.Add('edit');
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
      writeln('  --set-video [nr]         Tryb video, gdzie nr oznacza:');
      writeln('         nr = 0            - tryb domyślny (opcja domyślna, gdy nr nie zostanie podany)');
      writeln('         nr = 1            - tryb pojedyńczego filmu');
      writeln('         nr = 2            - tryb serii (wykorzystuje pole "SORT")');
      writeln('  --edit [sortowanie]      Uruchomienie programu w trybie edycji danych (ignoruje flagę tylko do odczytu)');
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
        dm.WriteInteger('wersja_bazy_danych',CONST_DB_VERSION);
        dm.tr.Commit;
      end;
    end;

    if parameters.IsParam('optical-disc') then OPTICAL_DISC:=parameters.GetValue('optical-disc');
    if parameters.IsParam('custom-play') then CUSTOM_CMD:=parameters.GetValue('custom-play');
    FORCE_EDIT:=parameters.IsParam('edit');
    if FORCE_EDIT then
    begin
      FORCE_SORT:=parameters.GetValue('edit');
      if FORCE_SORT='' then FORCE_SORT:='tytul';
    end;
    if FORCE_DIR<>'' then if (OPTICAL_DISC<>'') and (FileExists(s+_FF+'base.dat')) then dm.zwolnij_naped_optyczny;

    if dm.db.Connected then
    begin
      if parameters.IsParam('vacuum') then
      begin
        try
          dm.vacuum.ExecSQL;
          writeln('Baza danych została zwakumowana.');
        except
        end;
        PP_EXIT:=true;
      end;
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
      if parameters.IsParam('set-video') then
      begin
        pom:=parameters.GetValue('set-video');
        if pom='' then pom:='0';
        try
          DEF_VIDEO:=StrToInt(pom);
        except
          DEF_VIDEO:=0;
        end;
        if (DEF_VIDEO<0) or (DEF_VIDEO>2) then
        begin
          writeln('Info: Parametr --set-video NR został podany poza dopuszczalnym zakresem, ustawiam domyślną wartość...');
          DEF_VIDEO:=0;
        end;
        dm.WriteInteger('tryb_video',DEF_VIDEO);
        writeln('Tryb video został ustawiony na: '+IntToStr(DEF_VIDEO));
        PP_EXIT:=true;
      end;
      DB_VERSION:=dm.ReadInteger('wersja_bazy_danych',1);
      DEF_VIDEO:=dm.ReadInteger('tryb_video',0);
      DEF_DIR:=dm.ReadString('katalog_domyślny','.');
      DEF_MENU:=dm.ReadBool('pokazuj_menu_główne');
      DEF_FILTERS:=dm.ReadBool('pokazuj_filtrowanie',true);
      DEF_READWRITE:=dm.ReadBool('db_readwrite',false);
      DEF_NEW_DIR:=dm.ReadString('katalog_wtórny','');
      {$IFDEF UNIX}
      if FORCE_SCAN then
      begin
        writeln('Skanuję katalog z multimediami: '+MyDir(DEF_DIR));
        dm.tr.StartTransaction;
        dm.search(MyDir(DEF_DIR));
        dm.tr.Commit;
      end;
      {$ENDIF}
    end;
  finally
    parameters.Free;
  end;

  if PP_EXIT then
  begin
    terminate;
    exit;
  end;

  if (DB_VERSION>1) and (DEF_VIDEO=1) and (not DEF_READWRITE) then
  begin
    (* okno z jednym filmem w katalogu (max=1) *)
    FOpis:=TFOpis.Create(Application);
    try
      RequireDerivedFormResource:=True;
      Application.Scaled:=True;
      Application.Initialize;
      Application.CreateForm(TFOpis,FOpis);
      FOpis.BorderStyle:=bsSingle;
      FOpis.Position:=poScreenCenter;
      FOpis.Caption:='Film Video z dysku optycznego (ver. '+PROG_VERSION+')';
      FOpis.in_shutdown:=false;
      Application.Title:=Apps.Title;
      Application.Run;
    finally
      FOpis.Free;
    end;
  end else if (DB_VERSION>1) and (DEF_VIDEO=2) and (not DEF_READWRITE) then
  begin
    (* okno z niewielką ilością filmów w katalogu (max=8) *)
    FMulti:=TFMulti.Create(Application);
    try
      RequireDerivedFormResource:=True;
      Application.Scaled:=True;
      Application.Initialize;
      Application.CreateForm(TFMulti,FMulti);
      FMulti.Caption:='Filmy Video z dysku optycznego (ver. '+PROG_VERSION+')';
      Application.Title:=Apps.Title;
      Application.Run;
    finally
      FOpis.Free;
    end;
  end else begin
    (* okno z wielką ilością filmów w katalogu (max>8) *)
    FMain:=TFMain.Create(Application);
    try
      RequireDerivedFormResource:=True;
      Application.Scaled:=True;
      Application.Initialize;
      Application.CreateForm(TFMain, FMain);
      Application.Title:=Apps.Title;
      Application.Run;
    finally
      FMain.Free;
    end;
  end;

  if COM_SHUTDOWN then dm.zamknij_komputer.execute;
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

begin
  Application.Scaled:=True;
  Apps:=TBluePlayerVideo.Create(nil);
  Apps.Title:='BluePlayerVideo';
  Apps.Run;
  Apps.Free;
end.

