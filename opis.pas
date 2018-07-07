unit opis;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  DBCtrls, StdCtrls, ExtMessage, ECLink,
  uETileImage, db, ZDataset;

type

  { TFOpis }

  TFOpis = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DBImage2: TDBImage;
    DBText1: TDBText;
    DBText2: TDBText;
    DBText3: TDBText;
    DBText4: TDBText;
    DBText5: TDBText;
    DBText6: TDBText;
    DBText8: TDBText;
    DBText9: TDBText;
    ds_film: TDataSource;
    ds_gat: TDataSource;
    ECLink1: TECLink;
    mess: TExtMessage;
    film: TZQuery;
    filmboxoffice: TFloatField;
    filmczas: TTimeField;
    filmdlugosc: TLargeintField;
    filmid: TLargeintField;
    filminwestycja: TStringField;
    filmlink: TStringField;
    filmopis: TMemoField;
    filmplik: TStringField;
    filmpremiera: TDateField;
    filmpremiera_pl: TDateField;
    filmpremiera_str: TStringField;
    filmprodukcja: TStringField;
    filmrezyseria: TStringField;
    filmrok_prod: TLargeintField;
    filmrok_str: TStringField;
    filmrz_premiera: TStringField;
    filmrz_premiera_pl: TStringField;
    filmscenariusz: TStringField;
    filmtytul: TStringField;
    filmtytul_oryg: TStringField;
    filmzdjecie: TBlobField;
    gatnazwa: TStringField;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    shutdown_computer: TCheckBox;
    uETileImage1: TuETileImage;
    gat: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure filmAfterScroll(DataSet: TDataSet);
    procedure filmCalcFields(DataSet: TDataSet);
    procedure filmczasGetText(Sender: TField; var aText: string;
      DisplayText: Boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure _OPEN_CLOSE(DataSet: TDataSet);
  private
    plik,napisy: string;
  public
    in_id: integer;
    in_shutdown: boolean;
    out_play: boolean;
    out_shutdown: boolean;
  end;

var
  FOpis: TFOpis;

implementation

uses
  ecode, datamodule, functions, unit_exit;

{$R *.lfm}

function miesiac2rzymskie(miesiac: integer): string;
begin
  case miesiac of
     1: result:='I';
     2: result:='II';
     3: result:='III';
     4: result:='IV';
     5: result:='V';
     6: result:='VI';
     7: result:='VII';
     8: result:='VIII';
     9: result:='IX';
    10: result:='X';
    11: result:='XI';
    12: result:='XII';
  end;
end;

{ TFOpis }

procedure TFOpis.FormShow(Sender: TObject);
begin
  if not film.Active then
  begin
    film.ParamByName('id').AsInteger:=in_id;
    film.Open;
    shutdown_computer.Checked:=in_shutdown;
  end;
end;

procedure TFOpis._OPEN_CLOSE(DataSet: TDataSet);
begin
  gat.Active:=DataSet.Active;
end;

procedure TFOpis.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  film.Close;
end;

procedure TFOpis.FormCreate(Sender: TObject);
begin
  if (DB_VERSION>1) and (DEF_VIDEO=1) and (not DEF_READWRITE) then
  begin
    dm.id_video1.Open;
    in_id:=dm.id_video1id.AsInteger;
    plik:=MyDir(DEF_DIR+_FF+dm.id_video1film.AsString);
    napisy:=dm.id_video1napisy.AsString;
    dm.id_video1.Close;
  end;
  {$IFDEF MSWINDOWS}
  shutdown_computer.Visible:=false;
  {$ENDIF}
end;

procedure TFOpis.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key=27 then BitBtn1.Click;
end;

procedure TFOpis.filmCalcFields(DataSet: TDataSet);
const
  FORMAT_DAT = 'dd mmmm yyyy';
var
  s: string;
begin
  s:='';
  filmczas.AsDateTime:=IntegerToTime(filmdlugosc.AsInteger);
  if not filmpremiera.IsNull then filmrz_premiera.AsString:=StringReplace(FormatDateTime('d.##.yyyy',filmpremiera.AsDateTime),'##',miesiac2rzymskie(StrToInt(FormatDateTime('m',filmpremiera.AsDateTime))),[]);
  if not filmpremiera_pl.IsNull then filmrz_premiera_pl.AsString:=StringReplace(FormatDateTime('d.##.yyyy',filmpremiera_pl.AsDateTime),'##',miesiac2rzymskie(StrToInt(FormatDateTime('m',filmpremiera_pl.AsDateTime))),[]);
  if not filmboxoffice.IsNull then filminwestycja.AsString:=FormatFloat('### ### ### ### ##0',filmboxoffice.AsCurrency);
  filmrok_str.AsString:='('+filmrok_prod.AsString+')';
  if not filmpremiera_pl.IsNull then s:=FormatDateTime(FORMAT_DAT,filmpremiera_pl.AsDateTime)+' (Polska)';
  if not filmpremiera.IsNull then s:=s+' '+FormatDateTime(FORMAT_DAT,filmpremiera.AsDateTime)+' (Świat)';
  filmpremiera_str.AsString:=trim(s);
end;

procedure TFOpis.filmczasGetText(Sender: TField; var aText: string;
  DisplayText: Boolean);
begin
  aText:=FormatDateTime('hh',Sender.AsDateTime)+' godz. '+FormatDateTime('nn',Sender.AsDateTime)+' min.';
end;

procedure TFOpis.BitBtn1Click(Sender: TObject);
begin
  out_play:=false;
  close;
end;

procedure TFOpis.BitBtn2Click(Sender: TObject);
var
  b: boolean;
begin
  if (DB_VERSION>1) and (DEF_VIDEO=1) and (not DEF_READWRITE) then
  begin
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
    if shutdown_computer.Checked then
    begin
      FHalt:=TFHalt.Create(self);
      try
        FHalt.ShowModal;
        COM_SHUTDOWN:=FHalt.wylaczenie;
      finally
        FHalt.Free;
      end;
      if COM_SHUTDOWN then close else shutdown_computer.Checked:=false;
    end;
  end else begin
    out_play:=true;
    out_shutdown:=shutdown_computer.Checked;
    close;
  end;
end;

procedure TFOpis.filmAfterScroll(DataSet: TDataSet);
var
  s: string;
begin
  (* gatunek *)
  s:='';
  gat.First;
  while not gat.EOF do
  begin
    s:=s+', '+gatnazwa.AsString;
    gat.Next;
  end;
  if length(s)>1 then delete(s,1,2);
  Label7.Caption:=s;
  (* reszta *)
  Label1.Caption:=filmopis.AsString;
  if filmlink.AsString='' then ECLink1.Visible:=false else
  begin
    ECLink1.Visible:=true;
    ECLink1.Link:=filmlink.AsString;
    ECLink1.Caption:=ECLink1.Link;
  end;
end;

end.

