program cat_films;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  Interfaces, Forms,
  main, datamodule;
  //zcomponent, uecontrols, edit, kolumny, opis,
  //unit_exit, functions, about, normalizacja_nazw, gen_spis, serwis_filmweb
  //{ you can add units after this };

//,
//  Interfaces, // this includes the LCL widgetset
//  Forms, main, zcomponent, uecontrols, edit, datamodule, kolumny, opis,
//  unit_exit, functions, about, normalizacja_nazw, gen_spis, serwis_filmweb
//  { you can add units after this };

{$R *.res}

type
  { TBluePlayerVideo }

  TBluePlayerVideo = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

procedure TBluePlayerVideo.DoRun;
var
  ErrorMsg: String;
begin
  //inherited DoRun;
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
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

  // stop program loop
  Terminate;
end;

constructor TBluePlayerVideo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  dm:=Tdm.Create(self);
  StopOnException:=True;
end;

destructor TBluePlayerVideo.Destroy;
begin
  dm.Free;
  inherited Destroy;
end;

procedure TBluePlayerVideo.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Apps: TBluePlayerVideo;
begin
  Application.Scaled:=True;
  {
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TFMain, FMain);
  Application.Run;
  }

  Apps:=TBluePlayerVideo.Create(nil);
  Apps.Title:='BluePlayerVideo';
  Apps.Run;
  Apps.Free;
end.

