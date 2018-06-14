unit normalizacja_nazw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ZDataset;

type

  { TFNormalizacja_nazw }

  TFNormalizacja_nazw = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
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
    filmysubtitles: TStringField;
    filmytytul: TStringField;
    filmytytul_oryg: TStringField;
    filmyzdjecie: TBlobField;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    function normalizuj_nazwe(nazwa: string; algorytm: integer): string;
  public
    out_wykonano: boolean;
  end;

var
  FNormalizacja_nazw: TFNormalizacja_nazw;

implementation

uses
  LazUTF8, datamodule, ecode, functions;

{$R *.lfm}

{ TFNormalizacja_nazw }

procedure TFNormalizacja_nazw.BitBtn2Click(Sender: TObject);
begin
  out_wykonano:=false;
  close;
end;

procedure TFNormalizacja_nazw.BitBtn1Click(Sender: TObject);
var
  s,r: string;
  s1,s2,s3,s11,s22,pom: string;
  r_ext,r1,r11: string;
  sub: boolean;
  nd: boolean;
  o: string;
begin
  filmy.Open;
  dm.tr.StartTransaction;
  while not filmy.EOF do
  begin
    s:=filmyplik.AsString;
    o:=ExtractFilePath(s);
    if trim(s)='' then
    begin
      showmessage('Film o id '+filmyid.AsString+' nie został skojarzony z żadnym plikiem!');
      filmy.Next;
      continue;
    end;
    if filmynowy_zestaw.AsInteger=1 then nd:=true else nd:=false;
    r:=filmysubtitles.AsString;
    if trim(r)='' then sub:=false else sub:=true;
    if nd then s:=DEF_NEW_DIR+_FF+ExtractFilename(s) else s:=MyDir(DEF_DIR)+_FF+s;
    s1:=ExtractFilePath(s);
    s2:=ExtractFilename(s);
    s3:=ExtractFileExt(s);
    s11:=s1;
    s22:=s2;
    if trim(filmyrok_prod.AsString)='' then pom:='' else pom:='.'+filmyrok_prod.AsString;
    s22:=normalizuj_nazwe(filmytytul.AsString+pom+s3,RadioGroup1.ItemIndex);
    o:=o+s22;
    if sub then
    begin
      r_ext:=ExtractFileExt(r);
      r1:=s1+r;
      r11:=normalizuj_nazwe(filmytytul.AsString+pom+r_ext,RadioGroup1.ItemIndex);
    end;
    if s2<>s22 then
    begin
      (* zamieniam nazwy *)
      if FileExists(s) then
      begin
        if RenameFile(s,s11+s22) then
        begin
          filmy.Edit;
          filmyplik.AsString:=o;
          filmy.Post;
        end;
      end;
      if sub then
      begin
        if FileExists(r1) then
        begin
          if RenameFile(r1,s11+r11) then
          begin
            filmy.Edit;
            filmysubtitles.AsString:=r11;
            filmy.Post;
          end;
        end;
      end;
    end;
    filmy.Next;
  end;
  dm.tr.Commit;
  filmy.Close;
  out_wykonano:=true;
  close;
end;

procedure TFNormalizacja_nazw.RadioGroup1Click(Sender: TObject);
begin
  BitBtn1.Enabled:=RadioGroup1.ItemIndex>-1;
end;

function BezPolskichLiter(wej: string): string;
var
  i: integer;
  Bufor,koniec: String;
begin
  koniec:='';
  for i:=1 to Length(wej) do
  begin
    Bufor:=UTF8Copy(wej, i, 1);
    if bufor='ą' then bufor:='a';
    if bufor='Ą' then bufor:='A';
    if bufor='ć' then bufor:='c';
    if bufor='Ć' then bufor:='C';
    if bufor='ę' then bufor:='e';
    if bufor='Ę' then bufor:='E';
    if bufor='ł' then bufor:='l';
    if bufor='Ł' then bufor:='L';
    if bufor='ń' then bufor:='n';
    if bufor='Ń' then bufor:='N';
    if bufor='ó' then bufor:='o';
    if bufor='Ó' then bufor:='O';
    if bufor='ś' then bufor:='s';
    if bufor='Ś' then bufor:='S';
    if bufor='ż' then bufor:='z';
    if bufor='Ż' then bufor:='Z';
    if bufor='ź' then bufor:='z';
    if bufor='Ź' then bufor:='Z';
    koniec:=koniec+bufor;
  end;
  result:=koniec;
end;

function TFNormalizacja_nazw.normalizuj_nazwe(nazwa: string; algorytm: integer
  ): string;
var
  s: string;
begin
  case algorytm of
    0: begin
         s:=nazwa;
         s:=StringReplace(s,':','',[rfReplaceAll]);
         s:=StringReplace(s,'"','',[rfReplaceAll]);
         s:=StringReplace(s,',','',[rfReplaceAll]);
         s:=StringReplace(s,'''','',[rfReplaceAll]);
         s:=StringReplace(s,'`','',[rfReplaceAll]);
         s:=StringReplace(s,' ii',' 2',[rfReplaceAll,rfIgnoreCase]);
         s:=StringReplace(s,' iii',' 3',[rfReplaceAll,rfIgnoreCase]);
         result:=s;
       end;
    1: begin
         s:=LowerCase(BezPolskichLiter(nazwa));
         s:=StringReplace(s,' ','_',[rfReplaceAll]);
         s:=StringReplace(s,':','',[rfReplaceAll]);
         s:=StringReplace(s,'"','',[rfReplaceAll]);
         s:=StringReplace(s,',','',[rfReplaceAll]);
         s:=StringReplace(s,'''','',[rfReplaceAll]);
         s:=StringReplace(s,'`','',[rfReplaceAll]);
         s:=StringReplace(s,'._','.',[rfReplaceAll]);
         s:=StringReplace(s,'_ii','_2',[rfReplaceAll]);
         s:=StringReplace(s,'_iii','_3',[rfReplaceAll]);
         result:=s;
       end;
  end;
end;

end.

