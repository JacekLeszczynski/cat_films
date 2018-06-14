unit unit_exit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uETilePanel, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls;

type

  { TFHalt }

  TFHalt = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    autorun: TTimer;
    stat: TProgressBar;
    uETilePanel1: TuETilePanel;
    procedure autorunTimer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    wylaczenie: boolean;
  end;

var
  FHalt: TFHalt;

implementation

{$R *.lfm}

{ TFHalt }

procedure TFHalt.FormCreate(Sender: TObject);
begin
  wylaczenie:=true;
end;

procedure TFHalt.autorunTimer(Sender: TObject);
begin
  stat.StepIt;
  if stat.Position=stat.Max then
  begin
    enabled:=false;
    close;
  end;
end;

procedure TFHalt.BitBtn1Click(Sender: TObject);
begin
  close;
end;

procedure TFHalt.BitBtn2Click(Sender: TObject);
begin
  wylaczenie:=false;
  close;
end;

procedure TFHalt.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  autorun.Enabled:=false;
end;

procedure TFHalt.FormShow(Sender: TObject);
begin
  autorun.Enabled:=true;
end;

end.

