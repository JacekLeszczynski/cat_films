unit datamodule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, db, eventlog, ZTransaction, ExtMessage,
  NetSynHTTP, ZConnection, ZSqlProcessor, ZDataset;

type

  { TElement }

  TElement = class
    link: string;
    tytul,tytul_oryg: string;
    rok_prod: string[4];
    czas: integer;
    inwestycja: currency;
    premiera_swiat,premiera_polska: TDate;
    opis: string;
    rezyseria,scenariusz: string;
    gatunek: TStringList;
    produkcja: string;
    obrazek: TMemoryStream;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

  { Tdm }

  Tdm = class(TDataModule)
    add_gatunek: TZQuery;
    loc_create: TZSQLProcessor;
    db_loc: TZConnection;
    http: TNetSynHTTP;
    SaveDialog1: TSaveDialog;
    tr_loc: TZTransaction;
    vacuum: TZQuery;
    filmy2filename: TStringField;
    filmyfilename: TStringField;
    gatunki2id: TLargeintField;
    gatunki2nazwa: TStringField;
    gatunkiid: TLargeintField;
    gatunkinazwa: TStringField;
    plus_gatunek: TZQuery;
    minus_gatunek: TZQuery;
    show_gatunek: TZQuery;
    cinsert: TZQuery;
    cselectid: TLargeintField;
    cselectwartosc: TStringField;
    cupdate: TZQuery;
    cdelete: TZQuery;
    ds_filmy2: TDataSource;
    db: TZConnection;
    db2: TZConnection;
    db_appends: TZSQLProcessor;
    db_create: TZSQLProcessor;
    ds_filmy: TDataSource;
    ds_gatunki2: TDataSource;
    ds_gatunki: TDataSource;
    EventLog1: TEventLog;
    mess: TExtMessage;
    filmy2boxoffice: TFloatField;
    filmy2dlugosc: TLargeintField;
    filmy2id: TLargeintField;
    filmy2link: TStringField;
    filmy2opis: TMemoField;
    filmy2plik: TStringField;
    filmy2premiera: TDateField;
    filmy2premiera_pl: TDateField;
    filmy2produkcja: TStringField;
    filmy2rezyseria: TStringField;
    filmy2rok_prod: TLargeintField;
    filmy2scenariusz: TStringField;
    filmy2subtitles: TStringField;
    filmy2tytul: TStringField;
    filmy2tytul_oryg: TStringField;
    filmy2zdjecie: TBlobField;
    filmy: TZQuery;
    filmyboxoffice: TFloatField;
    filmydlugosc: TLargeintField;
    filmyid: TLargeintField;
    filmylink: TStringField;
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
    gatunki2: TZQuery;
    gatunki: TZQuery;
    show_gatunekid: TLargeintField;
    show_gatunekid1: TLargeintField;
    tr: TZTransaction;
    cselect: TZQuery;
    filmy2: TZQuery;
    is_dir2: TZQuery;
    procedure filmy2CalcFields(DataSet: TDataSet);
    procedure filmyCalcFields(DataSet: TDataSet);
    procedure _OPEN_CLOSE(DataSet: TDataSet);
    procedure _OPEN_CLOSE_2(DataSet: TDataSet);
  private
  public
    function ReadString(nazwa: string; def_str: string = ''): string;
    procedure WriteString(nazwa: string; wartosc: string = '');
    function ReadBool(nazwa: string; def_bool: boolean = false): boolean;
    procedure WriteBool(nazwa: string; wartosc: boolean = false);
    function nowy_gatunek(gatunek: string): integer;
    procedure skojarz_gatunek(id_filmu,id_kategorii: integer);
    procedure rozkojarz_gatunek(id_filmu,id_kategorii: integer);
    procedure SynchronizujBazeWzgledemInnejBazy(baza: string);
    procedure SynchronizujGatunki;
    function CountZestaw2: integer;
    function FilmwebToFilm(strona: string; element: TElement; z_zapisem_do_pliku: boolean = false): boolean;
  end;

var
  dm: Tdm;

function EscapeHtml(s: string): string;
function usun_wszystko_mmw(s: string): string;

implementation

uses
  ecode;

{$R *.lfm}

const
  encje_count = 84;
  encje_encoded: array [1..encje_count] of string = ('À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'à', 'á', 'â', 'ã', 'ä', 'å', 'Æ', 'æ', 'ß', 'Ç', 'ç', 'È', 'É', 'Ê', 'Ë', 'è', 'é', 'ê', 'ë', 'ƒ', 'Ì', 'Í', 'Î', 'Ï', 'ì', 'í', 'î', 'ï', 'Ñ', 'ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'ò', 'ó', 'ô', 'õ', 'ö', 'Ø', 'ø', 'Œ', 'œ', 'Š', 'š', 'Ù', 'Ú', 'Û', 'Ü', 'ù', 'ú', 'û', 'ü', 'µ', '×', 'Ý', 'Ÿ', 'ý', 'ÿ', '°', '†', '‡', '<', '>', '±', '«', '»', '¿', '¡', '·', '•', '™', '©', '®', '§', '¶', '…');
  encje_decoded: array [1..encje_count] of string = ('&Agrave;', '&Aacute;', '&Acirc;', '&Atilde;', '&Auml;', '&Aring;', '&agrave;', '&aacute;', '&acirc;', '&atilde;', '&auml;', '&aring;', '&AElig;', '&aelig;', '&szlig;', '&Ccedil;', '&ccedil;', '&Egrave;', '&Eacute;', '&Ecirc;', '&Euml;', '&egrave;', '&eacute;', '&ecirc;', '&euml;', '&#131;', '&Igrave;', '&Iacute;', '&Icirc;', '&Iuml;', '&igrave;', '&iacute;', '&icirc;', '&iuml;', '&Ntilde;', '&ntilde;', '&Ograve;', '&Oacute;', '&Ocirc;', '&Otilde;', '&Ouml;', '&ograve;', '&oacute;', '&ocirc;', '&otilde;', '&ouml;', '&Oslash;', '&oslash;', '&#140;', '&#156;', '&#138;', '&#154;', '&Ugrave;', '&Uacute;', '&Ucirc;', '&Uuml;', '&ugrave;', '&uacute;', '&ucirc;', '&uuml;', '&#181;', '&#215;', '&Yacute;', '&#159;', '&yacute;', '&yuml;', '&#176;', '&#134;', '&#135;', '&lt;', '&gt;', '&#177;', '&#171;', '&#187;', '&#191;', '&#161;', '&#183;', '&#149;', '&#153;', '&copy;', '&reg;', '&#167;', '&#182;', '&hellip;');

function EscapeHtml(s: string): string;
var
  i: integer;
begin
  for i:=1 to encje_count do s:=StringReplace(s,encje_decoded[i],encje_encoded[i],[rfReplaceAll]);
  result:=s;
end;

function usun_wszystko_mmw(s: string): string;
var
  a,b: integer;
begin
  while true do
  begin
    a:=pos('<',s);
    b:=pos('>',s);
    if (a=0) or (b=0) then break;
    delete(s,a,b-a+1);
  end;
  result:=s;
end;

{ TElement }

constructor TElement.Create;
begin
  gatunek:=TStringList.Create;
  obrazek:=TMemoryStream.Create;
end;

destructor TElement.Destroy;
begin
  gatunek.Free;
  obrazek.Free;
  inherited Destroy;
end;

procedure TElement.Clear;
begin
  link:='';
  tytul:='';
  tytul_oryg:='';
  rok_prod:='';
  czas:=0;
  inwestycja:=0;
  opis:='';
  rezyseria:='';
  scenariusz:='';
  gatunek.Clear;
  produkcja:='';
  obrazek.Clear;
end;

{ Tdm }

procedure Tdm._OPEN_CLOSE_2(DataSet: TDataSet);
begin
  gatunki2.Active:=DataSet.Active;
end;

procedure Tdm._OPEN_CLOSE(DataSet: TDataSet);
begin
  gatunki.Active:=DataSet.Active;
end;

procedure Tdm.filmyCalcFields(DataSet: TDataSet);
begin
  filmyfilename.AsString:=ExtractFilename(filmyplik.AsString);
end;

procedure Tdm.filmy2CalcFields(DataSet: TDataSet);
begin
  filmy2filename.AsString:=ExtractFilename(filmy2plik.AsString);
end;

function Tdm.ReadString(nazwa: string; def_str: string): string;
var
  s: string;
begin
  cselect.ParamByName('nazwa').AsString:=nazwa;
  cselect.Open;
  if cselect.IsEmpty then s:=def_str else if cselectwartosc.IsNull then s:=def_str else s:=trim(cselectwartosc.AsString);
  cselect.Close;
  result:=s;
end;

procedure Tdm.WriteString(nazwa: string; wartosc: string);
var
  s: string;
  id: integer;
begin
  s:=trim(wartosc);
  cselect.ParamByName('nazwa').AsString:=nazwa;
  cselect.Open;
  if cselect.IsEmpty then id:=-1 else id:=cselectid.AsInteger;
  cselect.Close;
  if (s='') and (id>-1) then
  begin
    cupdate.ParamByName('id').AsInteger:=id;
    cupdate.ParamByName('wartosc').Clear;
    cupdate.ExecSQL;
    //cdelete.ParamByName('id').AsInteger:=id;
    //cdelete.ExecSQL;
  end else if s<>'' then
  begin
    if id=-1 then
    begin
      cinsert.ParamByName('nazwa').AsString:=nazwa;
      cinsert.ParamByName('wartosc').AsString:=s;
      cinsert.ExecSQL;
    end else begin
      cupdate.ParamByName('id').AsInteger:=id;
      cupdate.ParamByName('wartosc').AsString:=s;
      cupdate.ExecSQL;
    end;
  end;
end;

function Tdm.ReadBool(nazwa: string; def_bool: boolean): boolean;
var
  s: string;
  b: boolean;
begin
  s:=ReadString(nazwa,s);
  if s='0' then b:=false else if s='1' then b:=true else b:=def_bool;
  result:=b;
end;

procedure Tdm.WriteBool(nazwa: string; wartosc: boolean);
var
  s: string;
begin
  if wartosc then s:='1' else s:='0';
  WriteString(nazwa,s);
end;

function Tdm.nowy_gatunek(gatunek: string): integer;
var
  id: integer;
  b: boolean;
begin
  (* sprawdzam czy warunek jest *)
  show_gatunek.ParamByName('nazwa').AsString:=gatunek;
  show_gatunek.Open;
  if show_gatunek.IsEmpty then b:=true else
  begin
    b:=false;
    id:=show_gatunekid.AsInteger;
  end;
  show_gatunek.Close;
  if b then
  begin
    (* dodaję nowy gatunek do bazy *)
    add_gatunek.ParamByName('nazwa').AsString:=gatunek;
    add_gatunek.ExecSQL;
    show_gatunek.ParamByName('nazwa').AsString:=gatunek;
    show_gatunek.Open;
    id:=show_gatunekid.AsInteger;
    show_gatunek.Close;
  end;
  (* zwracam id gatunku *)
  result:=id;
end;

procedure Tdm.skojarz_gatunek(id_filmu, id_kategorii: integer);
begin
  plus_gatunek.ParamByName('id_filmu').AsInteger:=id_filmu;
  plus_gatunek.ParamByName('id_kategorii').AsInteger:=id_kategorii;
  plus_gatunek.ExecSQL;
end;

procedure Tdm.rozkojarz_gatunek(id_filmu, id_kategorii: integer);
begin
  minus_gatunek.ParamByName('id_filmu').AsInteger:=id_filmu;
  minus_gatunek.ParamByName('id_kategorii').AsInteger:=id_kategorii;
  minus_gatunek.ExecSQL;
end;

procedure Tdm.SynchronizujBazeWzgledemInnejBazy(baza: string);
var
  plik: string;
  a,b,i,ile: integer;
begin
  ile:=0;
  db2.Database:=baza;
  db2.Connect;
  filmy.Open;
  filmy2.Open;
  a:=filmy.RecordCount;
  b:=filmy2.RecordCount;
  tr.StartTransaction;
  if a<b then
  begin
    while not filmy.EOF do
    begin
      plik:=filmyfilename.AsString;
      filmy2.First;
      if filmy2.Locate('filename',plik,[]) then
      begin
        filmy.Edit;
        for i:=3 to filmy.Fields.Count-1 do filmy.Fields[i].Assign(filmy2.Fields[i]);
        filmy.Post;
        SynchronizujGatunki;
        inc(ile);
      end;
      filmy.Next;
    end;
  end else begin
    while not filmy2.EOF do
    begin
      plik:=filmy2filename.AsString;
      filmy.First;
      if filmy.Locate('filename',plik,[]) then
      begin
        filmy.Edit;
        for i:=3 to filmy.Fields.Count-1 do filmy.Fields[i].Assign(filmy2.Fields[i]);
        filmy.Post;
        SynchronizujGatunki;
        inc(ile);
      end;
      filmy2.Next;
    end;
  end;
  tr.Commit;
  filmy.Close;
  filmy2.Close;
  db2.Disconnect;
  mess.ShowInformation('Zaktualizowano '+IntToStr(ile)+' rekordów.');
end;

procedure Tdm.SynchronizujGatunki;
var
  i,id: integer;
begin
  (* szukam do usunięcia *)
  gatunki.First;
  while not gatunki.EOF do
  begin
    gatunki2.First;
    if not gatunki2.Locate('nazwa',gatunkinazwa.AsString,[]) then rozkojarz_gatunek(filmyid.AsInteger,gatunkiid.AsInteger);
    gatunki.Next;
  end;
  gatunki.Refresh;
  (* szukam do dodania *)
  gatunki2.First;
  while not gatunki2.EOF do
  begin
    gatunki.First;
    if not gatunki.Locate('nazwa',gatunki2nazwa.AsString,[]) then
    begin
      id:=nowy_gatunek(gatunki2nazwa.AsString);
      skojarz_gatunek(filmyid.AsInteger,id);
    end;
    gatunki2.Next;
  end;
end;

function Tdm.CountZestaw2: integer;
var
  a: integer;
begin
  is_dir2.Open;
  a:=is_dir2.Fields[0].AsInteger;
  is_dir2.Close;
  result:=a;
end;

function Tdm.FilmwebToFilm(strona: string; element: TElement;
  z_zapisem_do_pliku: boolean): boolean;
var
  s,ss,pom,s1,pamiec: string;
  a,aa,b,c,i: integer;
  FS: TFormatSettings;
  godzin,minut: integer;
  obr: TMemoryStream;
  tt: TStringList;
  err: integer;
  pliczek: TStringList;
  bb,bb_zapis_do_pliku: boolean;
begin
  if http.execute(strona,s)<>200 then exit;
  pamiec:=s;
  bb_zapis_do_pliku:=z_zapisem_do_pliku;

  try
    err:=1;
    a:=pos('</header>',s);
    if a>0 then delete(s,1,a);

    err:=2;
    a:=pos(',title:',s);
    if a>0 then
    begin
      delete(s,1,a+6);
      element.tytul:=EscapeHtml(GetLineToStr(s,1,','));
    end;

    err:=3;
    a:=pos('originalTitle:',s);
    if a>0 then
    begin
      delete(s,1,a+13);
      element.tytul_oryg:=EscapeHtml(GetLineToStr(s,1,','));
    end;

    err:=4;
    a:=pos('year:',s);
    if a>0 then
    begin
      delete(s,1,a+4);
      element.rok_prod:=GetLineToStr(s,1,',');
    end;
    FS.DateSeparator:='-';
    FS.ShortDateFormat:='y/m/d';

    err:=5;
    a:=pos('firstLaunched:',s);
    if a>0 then
    begin
      delete(s,1,a+13);
      try
        element.premiera_swiat:=StrToDate(GetLineToStr(s,1,','),FS);
      except
      end;
    end;

    err:=6;
    a:=pos('premiereCountry:',s);
    if a>0 then
    begin
      delete(s,1,a+15);
      try
        element.premiera_polska:=StrToDate(GetLineToStr(s,1,','),FS);
      except
      end;
    end;

    err:=7;
    a:=pos('"duration" datetime=',s);
    if a>0 then
    begin
      delete(s,1,a+19);
      pom:=GetLineToStr(s,1,'>'); //"PT118M"
      delete(pom,1,2);
      minut:=StrToL(pom,s1,10);
      godzin:=minut div 60;
      minut:=minut mod 60;
      element.czas:=TimeToInteger(EncodeTime(godzin,minut,0,0));
    end;

    err:=8;
    a:=pos('<p class="text">',s);
    if a>0 then
    begin
      delete(s,1,a+15);
      a:=pos('</p>',s);
      pom:=EscapeHtml(copy(s,1,a-1));
      pom:=trim(StringReplace(pom,'<br/>','',[]));
      pom:=usun_wszystko_mmw(pom);
      element.opis:=pom;
      b:=pos('<a href=',s);
      if (b=0) or (b<a) then
      begin
        (* jest więcej opisu - ściągam *)
        delete(s,1,b+7);
        pom:='http://www.filmweb.pl'+GetLineToStr(s,1,'>');
        if http.execute(pom,ss)=200 then
        begin
          a:=pos('<p class="text">',ss);
          if a>0 then
          begin
            pamiec:=ss;
            delete(ss,1,a+15);
            aa:=pos('</p>',ss);
            pom:=EscapeHtml(copy(ss,1,aa-1));
            pom:=trim(StringReplace(pom,'<br/>','',[]));
            pom:=usun_wszystko_mmw(pom);
            element.opis:=pom;
          end;
        end;
      end;
    end;

    err:=9;
    a:=pos('reżyseria:',s);
    TextSeparator:=#9;
    if a>0 then
    begin
      pom:='';
      delete(s,1,a+10);
      while true do
      begin
        a:=pos('title=',s);
        b:=pos('</td>',s);
        if ((a>0) and (b>0) and (b<a)) or (a=0) then break;
        delete(s,1,a+5);
        pom:=pom+', '+GetLineToStr(s,2,'"');
      end;
      if (length(pom)>1) then delete(pom,1,2);
      element.rezyseria:=EscapeHtml(pom);
    end;

    err:=10;
    a:=pos('scenariusz:',s);
    if a>0 then
    begin
      pom:='';
      delete(s,1,a+10);
      while true do
      begin
        a:=pos('title=',s);
        b:=pos('</td>',s);
        if ((a>0) and (b>0) and (b<a)) or (a=0) then break;
        delete(s,1,a+5);
        pom:=pom+', '+GetLineToStr(s,2,'"');
      end;
      if (length(pom)>1) then delete(pom,1,2);
      element.scenariusz:=EscapeHtml(pom);
    end;
    TextSeparator:='"';

    err:=11;
    a:=pos('gatunek:',s);
    if a>0 then
    begin
      pom:='';
      delete(s,1,a+10);
      while true do
      begin
        a:=pos('genres=',s);
        b:=pos('</td>',s);
        if ((a>0) and (b>0) and (b<a)) or (a=0) then break;
        delete(s,1,a+6);
        a:=pos('>',s);
        delete(s,1,a);
        pom:=GetLineToStr(s,1,'<');
        (* wyjątki *)
        if pom='Komedia obycz.' then pom:='Komedia';
        if pom='Komedia kryminalna' then pom:='Komedia';
        if pom='Musical' then pom:='Muzyczny';
        if pom='Dramat historyczny' then
        begin
          element.gatunek.Add('Dramat');
          element.gatunek.Add('Historyczny');
          continue;
        end;
        (* zaznaczam/dodaję gatunek *)
        element.gatunek.Add(pom);
      end;
    end;

    err:=12;
    a:=pos('produkcja:',s);
    if a>0 then
    begin
      pom:='';
      delete(s,1,a+9);
      while true do
      begin
        a:=pos('countries=',s);
        b:=pos('</td>',s);
        if ((a>0) and (b>0) and (b<a)) or (a=0) then break;
        delete(s,1,a+9);
        a:=pos('>',s);
        delete(s,1,a);
        pom:=pom+', '+GetLineToStr(s,1,'<');
      end;
      if (length(pom)>1) then delete(pom,1,2);
      element.produkcja:=pom;
    end;

    err:=13;
    a:=pos('boxoffice:',s);
    if a>0 then
    begin
      delete(s,1,a+9);
      a:=pos('</th><td>$',s);
      b:=pos('"boxoffice">$',s);
      c:=pos('$',s);
      bb:=true;
      if a>0 then delete(s,1,a+9) else
      if b>0 then delete(s,1,b+12) else
      if c>0 then delete(s,1,c)
      else bb:=false;
      if bb then
      begin
        pom:=StringReplace(GetLineToStr(s,1,'<'),' ','',[rfReplaceAll]);
        if length(pom)>0 then if pom[1]='$' then delete(pom,1,1);
        a:=StrToL(pom,s1,10);
        element.inwestycja:=a;
      end;
    end;

    //obrazek
    err:=14;
    a:=pos('"posterLightbox"',s);
    if a=0 then
    begin
      http.execute(strona,s);
      a:=pos('"posterLightbox"',s);
    end;
    TextSeparator:=#9;
    if a>0 then
    begin
      delete(s,1,a+15);
      a:=pos('<img src=',s);
      delete(s,1,a+8);
      pom:=GetLineToStr(s,2,'"');
      obr:=TMemoryStream.Create;
      try
        http.execute(pom,obr);
        element.obrazek.LoadFromStream(obr);
      finally
        obr.Free;
      end;
    end;
    TextSeparator:='"';
    result:=true;
  except
    on E: Exception do
    begin
      s:=E.Message;
      if s='' then mess.ShowError('Wystąpił nieznany błąd w linii nr '+IntToStr(err)+'.^^Zmiany zostały cofnięte.^Dostaniesz możliwość zapisania ściągniętego dokumentu na dysk.')
      else mess.ShowError('Wystąpił błąd '+IntToStr(E.HelpContext)+' w linii nr '+IntToStr(err)+':^^'+E.Message+'^^Zmiany zostały cofnięte.^Dostaniesz możliwość zapisania ściągniętego dokumentu na dysk.');
      bb_zapis_do_pliku:=true;
      result:=false;
    end;
  end;
  TextSeparator:='"';
  (* zapis do pliku jeśli zażądano *)
  if bb_zapis_do_pliku then if SaveDialog1.Execute then
  begin
    pliczek:=TStringList.Create;
    try
      pliczek.Add(pamiec);
      pliczek.SaveToFile(SaveDialog1.FileName);
    finally
      pliczek.Free;
    end;
  end;
end;

end.

