unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ScrollingText;

type

  { TFAbout }

  TFAbout = class(TForm)
    BitBtn1: TBitBtn;
    ScrollingText1: TScrollingText;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  FAbout: TFAbout;

implementation

{$R *.lfm}

{ TFAbout }

procedure TFAbout.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ScrollingText1.Active:=false;
  CloseAction:=caFree;
end;

procedure TFAbout.FormShow(Sender: TObject);
begin
  ScrollingText1.Active:=true;
end;

procedure TFAbout.BitBtn1Click(Sender: TObject);
begin
  close;
end;

end.

