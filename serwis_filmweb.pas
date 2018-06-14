unit serwis_filmweb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  NetSynHTTP, ZDataset;

type

  { TFSerwisFilmWeb }

  TFSerwisFilmWeb = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    czy_jestile: TStringField;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    last_idid: TStringField;
    ListBox1: TListBox;
    http: TNetSynHTTP;
    SpeedButton1: TSpeedButton;
    dodaj: TZQuery;
    czy_jest: TZQuery;
    last_id: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public

  end;

var
  FSerwisFilmWeb: TFSerwisFilmWeb;

implementation

uses
  ecode, datamodule;

var
  V_STOP: boolean = false;

{$R *.lfm}

{ TFSerwisFilmWeb }

procedure TFSerwisFilmWeb.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TFSerwisFilmWeb.SpeedButton1Click(Sender: TObject);
var
  ss: TStringList;
  strona,s,pom,nazwa: string;
  a,b,ile,id,i: integer;
  element: TElement;
  licznik,dodane,wewn: integer;
begin
  V_STOP:=false;
  strona:=Edit1.Text;
  ss:=TStringList.Create;
  element:=TElement.Create;
  licznik:=0;
  dodane:=0;
  wewn:=0;
  dm.tr.StartTransaction;
  try
    while true do
    begin
      if http.execute(strona,ss)=200 then
      begin
        s:=ss.Text;
        while true do
        begin
          a:=pos('filmPreview__link',s);
          b:=pos('pagination__item--next',s);
          if (a=0) or ((b>0) and (b<a)) then
          begin
            (* szukam linku następnej strony *)
            delete(s,1,b+21);
            b:=pos('a href=',s);
            delete(s,1,b+6);
            if b=0 then
            begin
              (* nie znaleziono linku do następnej strony - przerywam *)
              strona:='';
              V_STOP:=true;
            end else
            begin
              a:=pos(' ',s);
              b:=pos('>',s);
              if (a>0) and (a<b) then strona:='http://www.filmweb.pl/films/search'+GetLineToStr(s,1,' ')
                                 else strona:='http://www.filmweb.pl/films/search'+GetLineToStr(s,1,'>');
            end;
            break;
          end;
          delete(s,1,a+16);
          a:=pos('href=',s);
          delete(s,1,a+4);
          pom:=GetLineToStr(s,1,'>');
          if length(pom)>1 then if pom[1]='/' then pom:='http://www.filmweb.pl'+pom;
          if dm.FilmwebToFilm(pom,element) then
          begin
            (* dodanie filmu *)
            inc(licznik);
            czy_jest.ParamByName('tytul').AsString:=element.tytul;
            czy_jest.ParamByName('rok').AsInteger:=StrToInt(element.rok_prod);
            czy_jest.Open;
            ile:=czy_jestile.AsInteger;
            czy_jest.Close;
            if ile=0 then
            begin
              (* dodanie filmu *)
              inc(dodane);
              dodaj.ParamByName('tytul').AsString:=element.tytul;
              dodaj.ParamByName('rok').AsString:=element.rok_prod;
              dodaj.ParamByName('tytul_oryg').AsString:=element.tytul_oryg;
              dodaj.ParamByName('czas').AsInteger:=element.czas;
              dodaj.ParamByName('zdjecie').LoadFromStream(element.obrazek,ftBlob);
              dodaj.ParamByName('opis').AsString:=element.opis;
              dodaj.ParamByName('link').AsString:=pom;
              dodaj.ParamByName('rezyseria').AsString:=element.rezyseria;
              dodaj.ParamByName('scenariusz').AsString:=element.scenariusz;
              dodaj.ParamByName('produkcja').AsString:=element.produkcja;
              dodaj.ParamByName('premiera').AsDate:=element.premiera_swiat;
              dodaj.ParamByName('premiera_pl').AsDate:=element.premiera_polska;
              if element.inwestycja>0 then dodaj.ParamByName('boxoffice').AsCurrency:=element.inwestycja;
              dodaj.ExecSQL;
              last_id.Open;
              id:=last_idid.AsInteger;
              last_id.Close;
              (* dodanie gatunków *)
              for i:=0 to element.gatunek.Count-1 do
              begin
                nazwa:=element.gatunek[i];
                dm.skojarz_gatunek(id,dm.nowy_gatunek(nazwa));
              end;
              inc(wewn);
              if wewn>50 then
              begin
                dm.tr.Commit;
                wewn:=0;
                dm.tr.StartTransaction;
              end;
              ListBox1.Items.Add('[+] '+element.tytul+' ('+element.rok_prod+')');
            end else ListBox1.Items.Add('[-] '+element.tytul+' ('+element.rok_prod+')');
            if ListBox1.Items.Count>10 then ListBox1.Items.Delete(0);
            Label4.Caption:=FormatFloat('00000',licznik)+'/'+FormatFloat('00000',dodane);
          end;
          element.Clear;
          application.ProcessMessages;
          if V_STOP then break;
        end;
      end else begin
        writeln('Błąd odczytu adresu: '+strona);
        break;
      end;
      ss.Clear;
      application.ProcessMessages;
      if V_STOP or (strona='') then break;
    end;
    dm.tr.Commit;
  finally
    ss.Free;
    element.Free;
  end;
end;

procedure TFSerwisFilmWeb.BitBtn1Click(Sender: TObject);
begin
  close;
end;

procedure TFSerwisFilmWeb.BitBtn2Click(Sender: TObject);
begin
  V_STOP:=true;
end;

end.

