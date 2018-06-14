unit edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, Forms, Controls, Graphics, Dialogs, DBCtrls,
  StdCtrls, DBExtCtrls, ExtCtrls, Buttons, Menus, ExtMessage,
  db;

type

  TElementElementu = (eeAll,eeOpis,eeObrazek);

  { TFEdit }

  TFEdit = class(TForm)
    add_gatunek: TZQuery;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    DBEdit11: TDBEdit;
    DBText1: TDBText;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mess: TExtMessage;
    filmssubtitles: TStringField;
    g_is: TZQuery;
    g_add: TZQuery;
    gatid_kategorii: TLargeintField;
    gatunki: TCheckGroup;
    DBDateEdit1: TDBDateEdit;
    DBDateEdit2: TDBDateEdit;
    DBEdit1: TDBEdit;
    DBEdit10: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    DBEdit7: TDBEdit;
    DBEdit8: TDBEdit;
    DBEdit9: TDBEdit;
    DBImage1: TDBImage;
    DBMemo1: TDBMemo;
    DBNavigator1: TDBNavigator;
    ds_films: TDataSource;
    ds_kats: TDataSource;
    ds_gat: TDataSource;
    films: TZQuery;
    filmsboxoffice: TFloatField;
    filmsdlugosc: TLargeintField;
    filmsid: TLargeintField;
    filmslink: TStringField;
    filmsopis: TMemoField;
    filmsplik: TStringField;
    filmspremiera: TDateField;
    filmspremiera_pl: TDateField;
    filmsprodukcja: TStringField;
    filmsrezyseria: TStringField;
    filmsrok_prod: TLargeintField;
    filmsscenariusz: TStringField;
    filmstytul: TStringField;
    filmstytul_oryg: TStringField;
    filmszdjecie: TBlobField;
    g_del: TZQuery;
    kats: TZQuery;
    gat: TZQuery;
    katsid: TLargeintField;
    katsnazwa: TStringField;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    minus_gatunki: TZQuery;
    OpenDialog1: TOpenDialog;
    OpenFilm: TOpenDialog;
    OpenNapisy: TOpenDialog;
    PopupMenu3: TPopupMenu;
    PopupNapisy: TPopupMenu;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    PopupFilm: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DBImage1DblClick(Sender: TObject);
    procedure filmsAfterPost(DataSet: TDataSet);
    procedure filmsAfterScroll(DataSet: TDataSet);
    procedure filmsBeforeDelete(DataSet: TDataSet);
    procedure filmsdlugoscGetText(Sender: TField; var aText: string;
      DisplayText: Boolean);
    procedure filmsdlugoscSetText(Sender: TField; const aText: string);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure _OPEN_CLOSE(DataSet: TDataSet);
  private
    tab: TStringList;
    procedure init;
    procedure nowy_gatunek(gatunek: string);
    procedure gatunki_read;
    procedure gatunki_write;
    procedure odczytaj_wszystko_z_netu(co: TElementElementu = eeAll; z_zapisem_do_pliku: boolean = false);
  public
    in_id: integer;
    in_tryb: integer;
    out_ok: boolean;
  end;

var
  FEdit: TFEdit;

implementation

uses
  functions, datamodule, ecode, synacode;

{$R *.lfm}

{ TFEdit }

procedure TFEdit.FormShow(Sender: TObject);
begin
  init;
  if in_tryb>0 then DBNavigator1.Visible:=false;
  if in_id>0 then films.Locate('id',in_id,[]);
  case in_tryb of
    1: films.Append;
    2: films.Edit;
  end;
end;

procedure TFEdit.MenuItem2Click(Sender: TObject);
begin
  odczytaj_wszystko_z_netu(eeObrazek);
end;

procedure TFEdit.MenuItem4Click(Sender: TObject);
begin
  odczytaj_wszystko_z_netu;
end;

procedure TFEdit.MenuItem6Click(Sender: TObject);
begin
  if not (films.State in [dsEdit,dsInsert]) then films.Edit;
  filmsplik.Clear;
end;

procedure TFEdit.MenuItem8Click(Sender: TObject);
begin
  if not (films.State in [dsEdit,dsInsert]) then films.Edit;
  filmssubtitles.Clear;
end;

procedure TFEdit.MenuItem9Click(Sender: TObject);
var
  s: string;
begin
  s:=InputBox('Dodawanie nowego gatunku','Podaj nazwę nowego gatunku:','');
  if s<>'' then nowy_gatunek(s);
end;

procedure TFEdit.SpeedButton1Click(Sender: TObject);
begin
  odczytaj_wszystko_z_netu;
end;

procedure TFEdit.SpeedButton2Click(Sender: TObject);
var
  a: integer;
  poszukiwane,plik: string;
begin
  OpenFilm.InitialDir:=DEF_DIR;
  if OpenFilm.Execute then
  begin
    poszukiwane:=MyDir(DEF_DIR);
    plik:=OpenFilm.FileName;
    a:=pos(poszukiwane,plik);
    if a=1 then delete(plik,1,length(poszukiwane)+1);
    if not (films.State in [dsEdit,dsInsert]) then films.Edit;
    filmsplik.AsString:=plik;
  end;
end;

procedure TFEdit.SpeedButton3Click(Sender: TObject);
begin
  OpenNapisy.InitialDir:=DEF_DIR;
  if OpenNapisy.Execute then
  begin
    if not (films.State in [dsEdit,dsInsert]) then films.Edit;
    filmssubtitles.AsString:=ExtractFilename(OpenNapisy.FileName);
  end;
end;

procedure TFEdit._OPEN_CLOSE(DataSet: TDataSet);
begin
  gat.Active:=DataSet.Active;
end;

procedure TFEdit.init;
begin
  tab.Clear;
  gatunki.Items.Clear;
  kats.Open;
  while not kats.EOF do
  begin
    tab.Add(katsid.AsString);
    gatunki.Items.Add(katsnazwa.AsString);
    kats.Next;
  end;
  kats.Close;
  films.Open;
end;

procedure TFEdit.nowy_gatunek(gatunek: string);
begin
  dm.nowy_gatunek(gatunek);
  init;
end;

procedure TFEdit.gatunki_read;
var
  i: integer;
  s: string;
begin
  for i:=0 to gatunki.Items.Count-1 do gatunki.Checked[i]:=false;
  gat.First;
  while not gat.EOF do
  begin
    s:=gatid_kategorii.AsString;
    for i:=0 to tab.Count-1 do
    begin
      if tab[i]=s then
      begin
        gatunki.Checked[i]:=true;
        break;
      end;
    end;
    gat.Next;
  end;
end;

procedure TFEdit.gatunki_write;
var
  i: integer;
  jest,mabyc: boolean;
  sprawdzam: integer;
begin
  for i:=0 to gatunki.Items.Count-1 do
  begin
    mabyc:=gatunki.Checked[i];
    sprawdzam:=StrToInt(tab[i]);
    g_is.ParamByName('id_kategorii').AsInteger:=sprawdzam;
    g_is.Open;
    jest:=g_is.Fields[0].AsInteger=1;
    g_is.Close;
    if jest<>mabyc then
    begin
      if mabyc then
      begin
        g_add.ParamByName('id_kategorii').AsInteger:=sprawdzam;
        g_add.ExecSQL;
      end else begin
        g_del.ParamByName('id_kategorii').AsInteger:=sprawdzam;
        g_del.ExecSQL;
      end;
    end;
  end;
end;

procedure TFEdit.odczytaj_wszystko_z_netu(co: TElementElementu;
  z_zapisem_do_pliku: boolean);
var
  element: TElement;
  i,a: integer;
begin
  begin
    element:=TElement.Create;
    try
      if dm.FilmwebToFilm(DBEdit5.Text,element,z_zapisem_do_pliku) then
      begin
        (* wczytanie danych z elementu *)
        if not (films.State in [dsEdit,dsInsert]) then films.Edit;
        if co=eeAll then filmstytul.AsString:=element.tytul;
        if co=eeAll then filmstytul_oryg.AsString:=element.tytul_oryg;
        if co=eeAll then filmsrok_prod.AsString:=element.rok_prod;
        if co=eeAll then filmspremiera.AsDateTime:=element.premiera_swiat;
        if co=eeAll then filmspremiera_pl.AsDateTime:=element.premiera_polska;
        if co=eeAll then filmsdlugosc.AsInteger:=element.czas;
        if (co=eeAll) or (co=eeOpis) then filmsopis.AsString:=element.opis;
        if co=eeAll then filmsrezyseria.AsString:=element.rezyseria;
        if co=eeAll then filmsscenariusz.AsString:=element.scenariusz;
        if co=eeAll then
        begin
          for i:=0 to element.gatunek.Count-1 do
          begin
            a:=StringToItemIndex(gatunki.Items,element.gatunek[i]);
            if a=-1 then nowy_gatunek(element.gatunek[i]);
          end;
          for i:=0 to element.gatunek.Count-1 do gatunki.Checked[StringToItemIndex(gatunki.Items,element.gatunek[i])]:=true;
        end;
        if co=eeAll then filmsprodukcja.AsString:=element.produkcja;
        if co=eeAll then filmsboxoffice.AsCurrency:=element.inwestycja;
        if (co=eeAll) or (co=eeObrazek) then filmszdjecie.LoadFromStream(element.obrazek);
      end;
    finally
      element.Free;
    end;
  end;
end;

procedure TFEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (in_tryb>0) and (films.State in [dsEdit,dsInsert]) then
  begin
    CloseAction:=caNone;
    exit;
  end;
  films.Close;
end;

procedure TFEdit.FormCreate(Sender: TObject);
begin
  tab:=TStringList.Create;
  in_id:=0;
end;

procedure TFEdit.FormDestroy(Sender: TObject);
begin
  tab.Free;
end;

procedure TFEdit.DBImage1DblClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    if not (films.State in [dsEdit,dsInsert]) then films.Edit;
    DBImage1.Picture.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TFEdit.Button1Click(Sender: TObject);
var
  a,b: TStringList;
  i: integer;
  s,kod: string;
begin
  a:=TStringList.Create;
  b:=TStringList.Create;
  try
    a.LoadFromFile('/home/tao/Projekty/encje.txt');
    kod:='const encje_encoded: array [1..'+IntToStr(a.Count)+'] of string = (';
    for i:=0 to a.Count-1 do
    begin
      s:=a[i];
      if i=0 then kod:=kod+''''+trim(GetLineToStr(s,1,'='))+'''' else kod:=kod+', '''+trim(GetLineToStr(s,1,'='))+'''';
    end;
    kod:=kod+');';
    b.Add(kod);
    kod:='const encje_decoded: array [1..'+IntToStr(a.Count)+'] of string = (';
    for i:=0 to a.Count-1 do
    begin
      s:=a[i];
      if i=0 then kod:=kod+''''+trim(GetLineToStr(s,2,'='))+'''' else kod:=kod+', '''+trim(GetLineToStr(s,2,'='))+'''';
    end;
    kod:=kod+');';
    b.Add(kod);
    b.SaveToFile('/home/tao/Projekty/encje_lazarus.txt');
  finally
    a.Free;
    b.Free;
  end;
end;

procedure TFEdit.BitBtn1Click(Sender: TObject);
begin
  films.Cancel;
  out_ok:=false;
  close;
end;

procedure TFEdit.BitBtn2Click(Sender: TObject);
begin
  films.Post;
  out_ok:=true;
  close;
end;

procedure TFEdit.filmsAfterPost(DataSet: TDataSet);
begin
  gatunki_write;
end;

procedure TFEdit.filmsAfterScroll(DataSet: TDataSet);
begin
  gatunki_read;
end;

procedure TFEdit.filmsBeforeDelete(DataSet: TDataSet);
begin
  minus_gatunki.ExecSQL;
end;

procedure TFEdit.filmsdlugoscGetText(Sender: TField; var aText: string;
  DisplayText: Boolean);
begin
  aText:=FormatDateTime('hh:nn:ss',IntegerToTime(Sender.AsInteger));
  DBEdit4.Color:=clWhite;
end;

procedure TFEdit.filmsdlugoscSetText(Sender: TField; const aText: string);
begin
  try
    Sender.AsInteger:=TimeToInteger(StrToTime(aText));
    DBEdit4.Color:=clWhite;
  except
    DBEdit4.Color:=clRed;
  end;
end;

end.

