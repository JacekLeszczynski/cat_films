unit multi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls,
  DBCtrls, StdCtrls, ExtMessage, JButton, ZDataset;

type

  { TFMulti }

  TFMulti = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn4: TBitBtn;
    ds_filmy: TDataSource;
    DBImage1: TDBImage;
    film1: TJButton;
    film2: TJButton;
    film3: TJButton;
    film4: TJButton;
    film5: TJButton;
    film6: TJButton;
    film7: TJButton;
    film8: TJButton;
    filmy: TZQuery;
    filmyboxoffice: TFloatField;
    filmydlugosc: TLargeintField;
    filmyid: TLargeintField;
    filmylink: TStringField;
    filmynowy_zestaw: TLargeintField;
    filmyopis: TMemoField;
    filmyplik: TStringField;
    filmypremiera: TDateField;
    filmypremiera_pl: TDateField;
    filmyprodukcja: TStringField;
    filmyrezyseria: TStringField;
    filmyrok_prod: TLargeintField;
    filmyscenariusz: TStringField;
    filmysort: TLargeintField;
    filmysubtitles: TStringField;
    filmytyt: TStringField;
    filmytytul: TStringField;
    filmytytul_oryg: TStringField;
    filmyzdjecie: TBlobField;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    mess: TExtMessage;
    Panel1: TPanel;
    Panel2: TPanel;
    PPPP: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SHOW_OPIS(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    procedure wczytaj_dane;
    procedure uzupelnij(lp: integer);
  public

  end;

var
  FMulti: TFMulti;

implementation

uses
  ecode, functions, about, opis, datamodule, unit_exit;

{$R *.lfm}

function optymalizuj(lp,max: integer): integer;
var
  a: integer;
begin
  case max of
    5: if lp<=3 then a:=lp else a:=lp+1;
    6: if lp<=3 then a:=lp else a:=lp+1;
    else a:=lp;
  end;
  result:=a;
end;

{ TFMulti }

procedure TFMulti.BitBtn1Click(Sender: TObject);
begin
  close;
end;

procedure TFMulti.BitBtn4Click(Sender: TObject);
begin
  FAbout:=TFAbout.Create(self);
  FAbout.ShowModal;
end;

procedure TFMulti.FormShow(Sender: TObject);
begin
  label1.AutoSize:=false;
  if label1.Height<label2.Height then label1.Height:=label2.Height;
  if label1.Height<label3.Height then label1.Height:=label3.Height;
  if label1.Height<label4.Height then label1.Height:=label4.Height;
  Left:=Round((screen.Width/2)-(Width/2));
  Top:=Round((screen.Height/2)-(Height/2));
end;

procedure TFMulti.SHOW_OPIS(Sender: TObject);
var
  id: integer;
  play,shutdown: boolean;
  plik,napisy: string;
begin
  (* pokaz opis *)
  id:=TJButton(Sender).Tag;
  if id=0 then exit;
  shutdown:=false;
  FOpis:=TFOpis.Create(self);
  try
    filmy.Open;
    filmy.Locate('id',id,[]);
    FOpis.in_id:=id;
    plik:=MyDir(DEF_DIR+_FF+filmyplik.AsString);
    napisy:=filmysubtitles.AsString;
    filmy.Close;
    FOpis.in_shutdown:=false;
    FOpis.ShowModal;
    play:=FOpis.out_play;
    if play then shutdown:=FOpis.out_shutdown;
  finally
    FOpis.Free;
  end;
  if play then
  begin
    if not FileExists(plik) then
    begin
      showmessage('Nie znaleziono pliku filmowego.');
      exit;
    end;
    mess.ShowInfo('Uruchamiam odtwarzanie filmu...');
    application.ProcessMessages;
    try
      dm.odtworz_film_teraz(handle,plik,napisy);
    finally
      application.ProcessMessages;
      sleep(2000);
      mess.HideInfo;
    end;
    while dm.player.Active do
    begin
      application.ProcessMessages;
      sleep(500);
    end;
    application.ProcessMessages;
    if shutdown then
    begin
      FHalt:=TFHalt.Create(self);
      try
        FHalt.ShowModal;
        COM_SHUTDOWN:=FHalt.wylaczenie;
      finally
        FHalt.Free;
      end;
      if COM_SHUTDOWN then close;
    end;
  end;
end;

procedure TFMulti.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TFMulti.FormCreate(Sender: TObject);
begin
  wczytaj_dane;
end;

procedure TFMulti.wczytaj_dane;
var
  max: integer;
begin
  filmy.Open;
  max:=filmy.RecordCount;
  while not filmy.EOF do
  begin
    uzupelnij(optymalizuj(filmysort.AsInteger,max));
    filmy.Next;
  end;
  filmy.Close;
  PPPP.Visible:=(max=5) or (max=7);
end;

procedure TFMulti.uzupelnij(lp: integer);
begin
  case lp of
    1: film1.Image.Picture.Assign(DBImage1.Picture);
    2: film2.Image.Picture.Assign(DBImage1.Picture);
    3: film3.Image.Picture.Assign(DBImage1.Picture);
    4: film4.Image.Picture.Assign(DBImage1.Picture);
    5: film5.Image.Picture.Assign(DBImage1.Picture);
    6: film6.Image.Picture.Assign(DBImage1.Picture);
    7: film7.Image.Picture.Assign(DBImage1.Picture);
    8: film8.Image.Picture.Assign(DBImage1.Picture);
  end;
  case lp of
    1: film1.Tag:=filmyid.AsInteger;
    2: film2.Tag:=filmyid.AsInteger;
    3: film3.Tag:=filmyid.AsInteger;
    4: film4.Tag:=filmyid.AsInteger;
    5: film5.Tag:=filmyid.AsInteger;
    6: film6.Tag:=filmyid.AsInteger;
    7: film7.Tag:=filmyid.AsInteger;
    8: film8.Tag:=filmyid.AsInteger;
  end;
  case lp of
    1: film1.Visible:=true;
    2: film2.Visible:=true;
    3: film3.Visible:=true;
    4: film4.Visible:=true;
    5: film5.Visible:=true;
    6: film6.Visible:=true;
    7: film7.Visible:=true;
    8: film8.Visible:=true;
  end;
  case lp of
    1: label1.Caption:=filmytytul.AsString;
    2: label2.Caption:=filmytytul.AsString;
    3: label3.Caption:=filmytytul.AsString;
    4: label4.Caption:=filmytytul.AsString;
    5: label5.Caption:=filmytytul.AsString;
    6: label6.Caption:=filmytytul.AsString;
    7: label7.Caption:=filmytytul.AsString;
    8: label8.Caption:=filmytytul.AsString;
  end;
  case lp of
    1: label1.Visible:=true;
    2: label2.Visible:=true;
    3: label3.Visible:=true;
    4: label4.Visible:=true;
    5: label5.Visible:=true;
    6: label6.Visible:=true;
    7: label7.Visible:=true;
    8: label8.Visible:=true;
  end;
end;

end.

