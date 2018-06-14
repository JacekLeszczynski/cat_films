unit gen_spis;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, DBSourceCopyToExcel, ZDataset;

type

  { TFGenSpis }

  TFGenSpis = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    ds_gen: TDataSource;
    gatunek: TZQuery;
    gatuneknazwa: TStringField;
    gen: TZQuery;
    genboxoffice: TFloatField;
    gendlugosc: TLargeintField;
    genid: TLargeintField;
    genlink: TStringField;
    gennowy_zestaw: TLargeintField;
    genopis: TMemoField;
    genplik: TStringField;
    genpremiera: TDateField;
    genpremiera_pl: TDateField;
    genprodukcja: TStringField;
    genrezyseria: TStringField;
    genrok_prod: TLargeintField;
    genscenariusz: TStringField;
    gensubtitles: TStringField;
    gentytul: TStringField;
    gentytul_oryg: TStringField;
    genzdjecie: TBlobField;
    Label3: TLabel;
    Memo2: TMemo;
    SaveDialog1: TSaveDialog;
    wzor: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure genBeforeOpen(DataSet: TDataSet);
    procedure _OPEN_CLOSE(DataSet: TDataSet);
  private
    function read_gatunek: string;
  public

  end;

var
  FGenSpis: TFGenSpis;

implementation

{$R *.lfm}

{ TFGenSpis }

procedure TFGenSpis.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TFGenSpis.genBeforeOpen(DataSet: TDataSet);
begin
  gen.SQL.Clear;
  gen.SQL.Add('select * from multimedia');
  if RadioGroup1.ItemIndex=1 then gen.SQL.Add('where nowy_zestaw=1');
  gen.SQL.Add('order by tytul');
end;

procedure TFGenSpis._OPEN_CLOSE(DataSet: TDataSet);
begin
  gatunek.Active:=DataSet.Active;
end;

function TFGenSpis.read_gatunek: string;
var
  s: string;
begin
  gatunek.First;
  while not gatunek.EOF do
  begin
    s:=s+', '+gatuneknazwa.AsString;
    gatunek.Next;
  end;
  if length(s)>1 then delete(s,1,2);
  result:=s;
end;

procedure TFGenSpis.BitBtn1Click(Sender: TObject);
begin
  close;
end;

procedure TFGenSpis.BitBtn2Click(Sender: TObject);
var
  licznik: integer;
  s: string;
begin
  Memo2.Clear;
  licznik:=1;
  gen.Open;
  while not gen.EOF do
  begin
    s:=wzor.Text;
    s:=StringReplace(s,'%c',IntToStr(licznik),[rfReplaceAll]);
    s:=StringReplace(s,'%t',gentytul.AsString,[rfReplaceAll]);
    s:=StringReplace(s,'%o',gentytul_oryg.AsString,[rfReplaceAll]);
    s:=StringReplace(s,'%g',read_gatunek,[rfReplaceAll]);
    s:=StringReplace(s,'%p',genprodukcja.AsString,[rfReplaceAll]);
    Memo2.Lines.Add(s);
    gen.Next;
    inc(licznik);
  end;
  gen.Close;
end;

procedure TFGenSpis.BitBtn3Click(Sender: TObject);
begin
  if SaveDialog1.Execute then Memo2.Lines.SaveToFile(SaveDialog1.FileName);
end;

end.

