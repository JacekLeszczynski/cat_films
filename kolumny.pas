unit kolumny;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  JSONPropStorage;

type

  { TFKolumny }

  TFKolumny = class(TForm)
    BitBtn1: TBitBtn;
    PropStorage: TJSONPropStorage;
    wybor_kolumn: TCheckGroup;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FKolumny: TFKolumny;

implementation

uses
  ecode;

{$R *.lfm}

{ TFKolumny }

procedure TFKolumny.BitBtn1Click(Sender: TObject);
begin
  close;
end;

procedure TFKolumny.FormCreate(Sender: TObject);
begin
  PropStorage.JSONFileName:=MyConfDir('config.xml');
  PropStorage.Active:=true;
end;

end.

