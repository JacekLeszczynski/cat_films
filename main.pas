unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZSqlUpdate, JDBGridControl, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, JSONPropStorage, Menus, ExtMessage,
  ColorProgress, db, DBGrids, StdCtrls, Buttons,
  ComCtrls, Grids, DBCtrls;

type

  { TFMain }

  TFMain = class(TForm)
    BitBtn4: TBitBtn;
    ds_historia: TDataSource;
    filmytyt: TStringField;
    filmywidziany: TLargeintField;
    historiaid: TLargeintField;
    historiarok_prod: TLargeintField;
    historiatyt: TStringField;
    historiatytul: TStringField;
    historiawidziany: TLargeintField;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    pile2: TLabel;
    pile: TColorProgress;
    ComboBox1: TComboBox;
    DBCheckBox1: TDBCheckBox;
    filmyfileexist: TBooleanField;
    filmynowy_zestaw: TLargeintField;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    minus_gatunki: TZQuery;
    NowyKatalog: TSelectDirectoryDialog;
    pinfo: TPanel;
    usun: TBitBtn;
    edytuj: TBitBtn;
    ds_sort1: TDataSource;
    dodaj: TBitBtn;
    gatunkiid: TLargeintField;
    gatunkinazwa: TStringField;
    MainMenu1: TMainMenu;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    OpenSynchroDB: TOpenDialog;
    shutdown_computer: TCheckBox;
    mess: TExtMessage;
    filmysubtitles: TStringField;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    filmyczas: TTimeField;
    filmyinwestycja: TStringField;
    filmyrok_str: TStringField;
    filmyrz_premiera: TStringField;
    filmyrz_premiera_pl: TStringField;
    f_gatunki: TCheckGroup;
    ds_filmy: TDataSource;
    ds_kats: TDataSource;
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
    filmytytul: TStringField;
    filmytytul_oryg: TStringField;
    filmyzdjecie: TBlobField;
    gatunki: TZQuery;
    JDBGridControl1: TJDBGridControl;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    PropStorage: TJSONPropStorage;
    sort1: TZQuery;
    upd_filmy: TZUpdateSQL;
    historia: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure DBCheckBox1Change(Sender: TObject);
    procedure dodajClick(Sender: TObject);
    procedure ds_filmyDataChange(Sender: TObject; Field: TField);
    procedure edytujClick(Sender: TObject);
    procedure filmyBeforeOpen(DataSet: TDataSet);
    procedure filmyCalcFields(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure f_gatunkiItemClick(Sender: TObject; Index: integer);
    procedure f_trybClick(Sender: TObject);
    procedure JDBGridControl1DblClick(Sender: TObject);
    procedure JDBGridControl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure JDBGridControl1TitleClick(Column: TColumn);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem22Click(Sender: TObject);
    procedure MenuItem23Click(Sender: TObject);
    procedure MenuItem25Click(Sender: TObject);
    procedure MenuItem27Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure minus_gatunkiBeforeDelete(DataSet: TDataSet);
    procedure PropStorageSavingProperties(Sender: TObject);
    procedure usunClick(Sender: TObject);
    procedure _OPEN_CLOSE(DataSet: TDataSet);
  private
    tab,gatunki_ids: TStringList;
    zaznaczone_gatunki_count: integer;
    procedure gatunki_read;
    procedure restore_gatunki;
    procedure reopen;
    function GetZaznaczoneGatunki(ciapki: boolean = false): string;
    function GetZaznaczoneGatunkiIds(ciapki: boolean = false): string;
    procedure pinfo_oblicz;
    procedure przenies_film;
  public

  end;

var
  FMain: TFMain;

implementation

uses
  {$IFDEF MSWINDOWS}
  windows,
  {$ENDIF}
  LCLType, ZAbstractRODataset, Process, datamodule,
  functions, ecode, edit, kolumny, opis, unit_exit, about, normalizacja_nazw,
  gen_spis, serwis_filmweb;

{$R *.lfm}

var
  customCmd: string = '';

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

{ TFMain }

procedure TFMain.FormCreate(Sender: TObject);
begin
  Caption:='Katalog zawartości płyty (ver. '+PROG_VERSION+')';
  {$IFDEF MSWINDOWS}
  shutdown_computer.Visible:=false;
  {$ENDIF}
  tab:=TStringList.Create;
  gatunki_ids:=TStringList.Create;
  customCmd:=CUSTOM_CMD;
  PropStorage.JSONFileName:=MyConfDir('config.xml');

  (* baza lokalna *)
  dm.db_loc.Database:=MyConfDir('config.dat');
  if not FileExists(dm.db_loc.Database) then
  begin
    dm.db_loc.Connect;
    dm.loc_create.Execute;
  end else dm.db_loc.Connect;

  if dm.db.Connected then
  begin
    DBCheckBox1.Visible:=false;
    if DEF_MENU and (DEF_NEW_DIR<>'') then if DirectoryExists(DEF_NEW_DIR) then
    begin
      DBCheckBox1.Visible:=true;
      pinfo.Visible:=true;
    end;
    Panel1.Visible:=DEF_FILTERS;
  end;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  tab.Free;
  gatunki_ids.Free;
end;

procedure TFMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if (Key=VK_ESCAPE) or (Key=VK_Q) then close;
end;

procedure TFMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  filmy.Close;
end;

procedure TFMain.filmyCalcFields(DataSet: TDataSet);
begin
  filmyczas.AsDateTime:=IntegerToTime(filmydlugosc.AsInteger);
  filmyrz_premiera.AsString:=StringReplace(FormatDateTime('d.##.yyyy',filmypremiera.AsDateTime),'##',miesiac2rzymskie(StrToInt(FormatDateTime('m',filmypremiera.AsDateTime))),[]);
  filmyrz_premiera_pl.AsString:=StringReplace(FormatDateTime('d.##.yyyy',filmypremiera_pl.AsDateTime),'##',miesiac2rzymskie(StrToInt(FormatDateTime('m',filmypremiera_pl.AsDateTime))),[]);
  filmyinwestycja.AsString:=FormatFloat('### ### ### ### ##0',filmyboxoffice.AsCurrency);
  filmyrok_str.AsString:=filmyrok_prod.AsString;
  filmyfileexist.AsBoolean:=FileExists(MyDir(DEF_DIR)+_FF+filmyplik.AsString);
end;

procedure TFMain.filmyBeforeOpen(DataSet: TDataSet);
var
  s: string;
  b: boolean;
begin
  s:=GetZaznaczoneGatunkiIds(false);
  b:=not f_gatunki.Checked[0];
  filmy.SQL.Clear;
  filmy.SQL.Add('');
  filmy.SQL.Add('select');
  filmy.SQL.Add('  *,');
  filmy.SQL.Add('  case when tytul_oryg is null or tytul_oryg='''' then rok_prod||tytul else rok_prod||tytul_oryg end as tyt');
  filmy.SQL.Add('from multimedia');
  if b then
  begin
    if MenuItem2.Checked then
    begin
      filmy.SQL.Add('where id in (');
      filmy.SQL.Add('  select id from (');
      filmy.SQL.Add('    select m.id, count(m.id) from multimedia m');
      filmy.SQL.Add('    join gatunek g on g.id_filmu=m.id');
      filmy.SQL.Add('    join kategorie k on k.id=g.id_kategorii');
      filmy.SQL.Add('    where k.id in ('+s+')');
      filmy.SQL.Add('    group by m.id');
      filmy.SQL.Add('    having count(m.id)='+IntToStr(zaznaczone_gatunki_count));
      filmy.SQL.Add('  )');
      filmy.SQL.Add(')');
    end else begin
      filmy.SQL.Add('where id in (');
      filmy.SQL.Add('  select distinct id_filmu from gatunek');
      filmy.SQL.Add('  where id_kategorii in ('+s+')');
      filmy.SQL.Add(')');
    end;
  end;
  filmy.SQL.Add('order by tytul');
end;

procedure TFMain.BitBtn1Click(Sender: TObject);
begin
  close;
end;

procedure TFMain.BitBtn2Click(Sender: TObject);
var
  play: boolean;
begin
  FOpis:=TFOpis.Create(self);
  try
    FOpis.in_id:=filmyid.AsInteger;
    FOpis.in_shutdown:=shutdown_computer.Checked;
    FOpis.ShowModal;
    play:=FOpis.out_play;
    if play then shutdown_computer.Checked:=FOpis.out_shutdown;
  finally
    FOpis.Free;
  end;
  if play then BitBtn3.Click;
end;

procedure TFMain.BitBtn3Click(Sender: TObject);
var
  plik,napisy: string;
begin
  if filmyplik.IsNull then exit;
  if filmyplik.AsString='' then exit;
  if filmynowy_zestaw.AsInteger=0 then plik:=MyDir(DEF_DIR+_FF+filmyplik.AsString)
                                  else plik:=DEF_NEW_DIR+_FF+ExtractFilename(filmyplik.AsString);
  napisy:=filmysubtitles.AsString;
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
end;

procedure TFMain.BitBtn4Click(Sender: TObject);
begin
  FAbout:=TFAbout.Create(self);
  FAbout.ShowModal;
end;

procedure TFMain.ComboBox1Change(Sender: TObject);
begin
  pinfo_oblicz;
end;

procedure TFMain.DBCheckBox1Change(Sender: TObject);
begin
  if not DBCheckBox1.Visible then exit;
  przenies_film;
  if filmy.State in [dsEdit,dsInsert] then filmy.Post;
  pinfo_oblicz;
end;

procedure TFMain.dodajClick(Sender: TObject);
var
  t: TBookmark;
begin
  FEdit:=TFEdit.Create(self);
  FEdit.in_tryb:=1;
  FEdit.ShowModal;
  gatunki_read;
  restore_gatunki;
  t:=filmy.GetBookmark;
  filmy.Refresh;
  filmy.GotoBookmark(t);
end;

procedure TFMain.ds_filmyDataChange(Sender: TObject; Field: TField);
var
  stat: boolean;
begin
  stat:=filmy.State in [dsEdit,dsInsert];
  dodaj.Enabled:=filmy.Active and (not stat);
  edytuj.Enabled:=filmy.Active and (not stat) and (not filmy.IsEmpty);
  usun.Enabled:=edytuj.Enabled;
end;

procedure TFMain.edytujClick(Sender: TObject);
var
  t: TBookmark;
begin
  FEdit:=TFEdit.Create(self);
  try
    FEdit.in_tryb:=2;
    FEdit.in_id:=filmyid.AsInteger;
    FEdit.ShowModal;
    gatunki_read;
    restore_gatunki;
    t:=filmy.GetBookmark;
    filmy.Refresh;
    filmy.GotoBookmark(t);
  finally
    FEdit.Free;
  end;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  if COM_CLOSE then
  begin
    close;
    exit;
  end;
  if not dm.db.Connected then
  begin
    showmessage('Brak nośnika z danymi filmowymi.'+#13#10+'Czy nośnik został zamontowany prawidłowo i czy to jest nośnik multimedialny?'+#13#10#13#10+'Wychodzę.');
    close;
    exit;
  end;
  PropStorage.Active:=true;
  PropStorage.Restore;
  FMain.Position:=poDesigned;
  MenuItem15.Visible:=DEF_MENU;
  MenuItem26.Visible:=DEF_MENU;
  MenuItem14.Visible:=DEF_READWRITE;
  dodaj.Visible:=DEF_READWRITE;
  edytuj.Visible:=DEF_READWRITE;
  usun.Visible:=DEF_READWRITE;
  if DEF_MENU and (DEF_NEW_DIR<>'') then if DirectoryExists(DEF_NEW_DIR) then pinfo_oblicz;
  (* edycja katalogu filmów *)
  if FORCE_EDIT then
  begin
    FEdit:=TFEdit.Create(self);
    try
      FEdit.in_tryb:=0;
      FEdit.ShowModal;
    finally
      FEdit.Free;
    end;
    close;
  end;
  (* reszta *)
  if not filmy.Active then
  begin
    gatunki_read;
    restore_gatunki;
    filmy.Open;
  end;
end;

procedure TFMain.f_gatunkiItemClick(Sender: TObject; Index: integer);
var
  i: integer;
  cos: boolean;
begin
  if MenuItem13.Checked then
  begin
    for i:=0 to tab.Count-1 do if i<>Index then f_gatunki.Checked[i]:=false;
    if not f_gatunki.Checked[Index] then f_gatunki.Checked[0]:=true;
    reopen;
    exit;
  end;
  cos:=false;
  for i:=1 to tab.Count-1 do
  begin
    if f_gatunki.Checked[i] then
    begin
      cos:=true;
      break;
    end;
  end;
  if (index=0) and cos then for i:=1 to tab.Count-1 do f_gatunki.Checked[i]:=false;
  if (index=0) and (not cos) then f_gatunki.Checked[0]:=true;
  if index>0 then f_gatunki.Checked[0]:=(index>0) and (not cos);
  reopen;
end;

procedure TFMain.f_trybClick(Sender: TObject);
begin
  reopen;
end;

procedure TFMain.JDBGridControl1DblClick(Sender: TObject);
begin
  if MenuItem4.Checked then BitBtn2.Click else BitBtn3.Click;
end;

procedure TFMain.JDBGridControl1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  JDBGridControl1.Canvas.Font.Style:=[];
  JDBGridControl1.Canvas.Font.Color:=clBlack;
  if filmynowy_zestaw.AsInteger=1 then JDBGridControl1.Canvas.Font.Color:=clGreen else
  if (not filmyfileexist.AsBoolean) or filmyplik.IsNull or (filmyplik.AsString='') then JDBGridControl1.Canvas.Font.Color:=clRed;
  if filmywidziany.AsInteger=0 then JDBGridControl1.Canvas.Font.Style:=[fsBold];
  JDBGridControl1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
end;

procedure TFMain.JDBGridControl1TitleClick(Column: TColumn);
const
  SORT_ASC = '▼';
  SORT_DESC = '▲';
var
  i: integer;
  s: string;
begin
  (* sortowanie *) //↑↓▲▼
  if Column.Title.Font.Style=[fsBold] then
  begin
    s:=Column.Title.Caption;
    s:=StringReplace(s,SORT_ASC,'',[]);
    s:=StringReplace(s,SORT_DESC,'',[]);
    s:=trim(s);
    if filmy.SortType=stAscending then filmy.SortType:=stDescending else filmy.SortType:=stAscending;
    case filmy.SortType of
      stAscending: s:=s+' '+SORT_ASC;
      stDescending: s:=s+' '+SORT_DESC;
    end;
    Column.Title.Caption:=s;
    exit;
  end;
  for i:=0 to JDBGridControl1.Columns.Count-1 do
  begin
    JDBGridControl1.Columns[i].Title.Font.Style:=[];
    s:=JDBGridControl1.Columns[i].Title.Caption;
    if (pos(SORT_ASC,s)>0) or (pos(SORT_DESC,s)>0) then
    begin
      s:=StringReplace(s,SORT_ASC,'',[]);
      s:=StringReplace(s,SORT_DESC,'',[]);
      s:=trim(s);
      JDBGridControl1.Columns[i].Title.Caption:=s;
    end;
  end;
  filmy.SortedFields:=Column.FieldName;
  filmy.SortType:=stAscending;
  Column.Title.Font.Style:=[fsBold];
  Column.Title.Caption:=Column.Title.Caption+' '+SORT_ASC;
end;

procedure TFMain.MenuItem10Click(Sender: TObject);
begin
  MenuItem9.Checked:=false;
  MenuItem10.Checked:=true;
  MenuItem11.Checked:=false;
end;

procedure TFMain.MenuItem11Click(Sender: TObject);
begin
  MenuItem9.Checked:=false;
  MenuItem10.Checked:=false;
  MenuItem11.Checked:=true;
end;

procedure TFMain.MenuItem12Click(Sender: TObject);
begin
  MenuItem13.Checked:=false;
  MenuItem2.Checked:=false;
  MenuItem12.Checked:=true;
end;

procedure TFMain.MenuItem13Click(Sender: TObject);
begin
  MenuItem13.Checked:=true;
  MenuItem2.Checked:=false;
  MenuItem12.Checked:=false;
end;

procedure TFMain.MenuItem14Click(Sender: TObject);
begin
  edytuj.Click;
end;

procedure TFMain.MenuItem16Click(Sender: TObject);
begin
  if OpenSynchroDB.Execute then
  begin
    dm.SynchronizujBazeWzgledemInnejBazy(OpenSynchroDB.FileName);
    gatunki_read;
    restore_gatunki;
    filmy.Refresh;
  end;
end;

procedure TFMain.MenuItem17Click(Sender: TObject);
begin
  FNormalizacja_nazw:=TFNormalizacja_nazw.Create(self);
  try
    FNormalizacja_nazw.ShowModal;
    if FNormalizacja_nazw.out_wykonano then filmy.Refresh;
  finally
    FNormalizacja_nazw.Free;
  end;
end;

procedure TFMain.MenuItem19Click(Sender: TObject);
begin
  if NowyKatalog.Execute then
  begin
    DEF_NEW_DIR:=NowyKatalog.FileName;
    dm.WriteString('katalog_wtórny',DEF_NEW_DIR);
    DBCheckBox1.Visible:=true;
    pinfo.Visible:=true;
    pinfo_oblicz;
  end;
end;

procedure TFMain.MenuItem1Click(Sender: TObject);
var
  i,a: integer;
begin
  FKolumny:=TFKolumny.Create(self);
  try
    (* wczytanie kolumn *)
    for i:=0 to JDBGridControl1.Columns.Count-1 do if JDBGridControl1.Columns[i].Tag=1 then
    begin
      a:=FKolumny.wybor_kolumn.Items.Add(JDBGridControl1.Columns[i].Title.Caption);
      FKolumny.wybor_kolumn.Checked[a]:=JDBGridControl1.Columns[i].Visible;
    end;
    FKolumny.ShowModal;
    (* zapisanie kolumn *)
    for i:=0 to JDBGridControl1.Columns.Count-1 do if JDBGridControl1.Columns[i].Tag=1 then
    begin
      a:=ecode.StringToItemIndex(FKolumny.wybor_kolumn.Items,JDBGridControl1.Columns[i].Title.Caption);
      JDBGridControl1.Columns[i].Visible:=FKolumny.wybor_kolumn.Checked[a];
    end;
  finally
    FKolumny.Free;
  end;
  JDBGridControl1.Columns[11].Alignment:=taRightJustify;
  JDBGridControl1.Columns[12].Alignment:=taRightJustify;
end;

procedure TFMain.MenuItem20Click(Sender: TObject);
begin
  if dm.CountZestaw2=0 then
  begin
    DEF_NEW_DIR:='';
    dm.WriteString('katalog_wtórny',DEF_NEW_DIR);
    DBCheckBox1.Visible:=false;
    pinfo.Visible:=false;
    pinfo_oblicz;
  end else showmessage('Katalog nie jest pusty, przerwano.');
end;

procedure TFMain.MenuItem22Click(Sender: TObject);
begin
  dm.vacuum.ExecSQL;
end;

procedure TFMain.MenuItem23Click(Sender: TObject);
begin
  FGenSpis:=TFGenSpis.Create(self);
  FGenSpis.ShowModal;
end;

procedure TFMain.MenuItem25Click(Sender: TObject);
var
  t: TBookmark;
  b: boolean;
begin
  historia.First;
  if historia.Locate('tyt',filmytyt.AsString,[]) then
  begin
    historia.Edit;
    b:=false;
  end else begin
    historia.Append;
    b:=true;
  end;
  if filmytytul_oryg.IsNull or (filmytytul_oryg.AsString='') then
    historiatytul.AsString:=filmytytul.AsString else historiatytul.AsString:=filmytytul_oryg.AsString;
  if not filmyrok_prod.IsNull then historiarok_prod.AsInteger:=filmyrok_prod.AsInteger;
  if b then historiawidziany.AsInteger:=1 else
  begin
    if historiawidziany.AsInteger=0 then historiawidziany.AsInteger:=1 else historiawidziany.AsInteger:=0;
  end;
  historia.Post;
  historia.Refresh;
  t:=filmy.GetBookmark;
  filmy.Refresh;
  filmy.GotoBookmark(t);
end;

procedure TFMain.MenuItem27Click(Sender: TObject);
begin
  FSerwisFilmWeb:=TFSerwisFilmWeb.Create(self);
  FSerwisFilmWeb.ShowModal;
end;

procedure TFMain.MenuItem2Click(Sender: TObject);
begin
  MenuItem13.Checked:=false;
  MenuItem2.Checked:=true;
  MenuItem12.Checked:=false;
end;

procedure TFMain.MenuItem4Click(Sender: TObject);
begin
  MenuItem4.Checked:=true;
  MenuItem6.Checked:=false;
end;

procedure TFMain.MenuItem6Click(Sender: TObject);
begin
  MenuItem4.Checked:=false;
  MenuItem6.Checked:=true;
end;

procedure TFMain.MenuItem9Click(Sender: TObject);
begin
  MenuItem9.Checked:=true;
  MenuItem10.Checked:=false;
  MenuItem11.Checked:=false;
end;

procedure TFMain.minus_gatunkiBeforeDelete(DataSet: TDataSet);
begin
  minus_gatunki.ExecSQL;
end;

procedure TFMain.PropStorageSavingProperties(Sender: TObject);
begin
  PropStorage.StoredValues[0].Value:=GetZaznaczoneGatunki;
end;

procedure TFMain.usunClick(Sender: TObject);
var
  s1,s2: string;
begin
  if filmynowy_zestaw.AsInteger=0 then
  begin
    s1:=MyDir(DEF_DIR+_FF+filmyplik.AsString);
    s2:=MyDir(DEF_DIR+_FF+filmysubtitles.AsString);
  end else begin
    s1:=DEF_NEW_DIR+_FF+ExtractFilename(filmyplik.AsString);
    s2:=DEF_NEW_DIR+_FF+ExtractFilename(filmysubtitles.AsString);
  end;
  if mess.ShowConfirmationYesNo('Czy na pewno usunąć wskazany film?') then
  begin
    if mess.ShowConfirmationYesNo('Czy usunąć film z dysku?') then
    begin
      {$IFDEF UNIX}
      if FileExists(s1) then DeleteFile(s1);
      if FileExists(s2) then DeleteFile(s2);
      {$ELSE}
      if FileExists(s1) then DeleteFile(pchar(s1));
      if FileExists(s2) then DeleteFile(pchar(s2));
      {$ENDIF}
    end;
    filmy.Delete;
  end;
end;

procedure TFMain._OPEN_CLOSE(DataSet: TDataSet);
begin
  historia.Active:=DataSet.Active;
end;

procedure TFMain.gatunki_read;
begin
  tab.Clear;
  f_gatunki.Items.Clear;
  gatunki_ids.Clear;
  tab.Add('1');
  f_gatunki.Items.Add('Wszystkie');
  gatunki_ids.Add('0');
  gatunki.Open;
  while not gatunki.EOF do
  begin
    tab.Add('0');
    f_gatunki.Items.Add(gatunkinazwa.AsString);
    gatunki_ids.Add(gatunkiid.AsString);
    gatunki.Next;
  end;
  gatunki.Close;
  f_gatunki.Checked[0]:=true;
end;

procedure TFMain.restore_gatunki;
var
  i,a: integer;
  s,pom: string;
begin
  s:=PropStorage.StoredValues[0].Value;
  i:=1;
  while true do
  begin
    pom:=GetLineToStr(s,i,',');
    if pom='' then break;
    a:=StringToItemIndex(f_gatunki.Items,pom);
    if a>-1 then f_gatunki.Checked[a]:=true;
    inc(i);
  end;
  for i:=1 to f_gatunki.Items.Count-1 do if f_gatunki.Checked[i] then
  begin
    f_gatunki.Checked[0]:=false;
    break;
  end;
end;

procedure TFMain.reopen;
begin
  filmy.DisableControls;
  filmy.Close;
  filmy.Open;
  filmy.EnableControls;
end;

function TFMain.GetZaznaczoneGatunki(ciapki: boolean): string;
var
  i: integer;
  s: string;
begin
  zaznaczone_gatunki_count:=0;
  for i:=0 to f_gatunki.Items.Count-1 do if f_gatunki.Checked[i] then
  begin
    if ciapki then s:=s+','''+f_gatunki.Items[i]+''''
              else s:=s+','+f_gatunki.Items[i];
    inc(zaznaczone_gatunki_count);
  end;
  if length(s)>0 then delete(s,1,1);
  result:=s;
end;

function TFMain.GetZaznaczoneGatunkiIds(ciapki: boolean): string;
var
  i: integer;
  s: string;
begin
  zaznaczone_gatunki_count:=0;
  for i:=0 to f_gatunki.Items.Count-1 do if f_gatunki.Checked[i] then
  begin
    if ciapki then s:=s+','''+gatunki_ids[i]+''''
              else s:=s+','+gatunki_ids[i];
    inc(zaznaczone_gatunki_count);
  end;
  if length(s)>0 then delete(s,1,1);
  result:=s;
end;

procedure TFMain.pinfo_oblicz;
var
  a,b,c: int64;
begin
  {$IFDEF UNIX}
  case ComboBox1.ItemIndex of
    0: a:=650*1024*1024;
    1: a:=700*1024*1024;
    2: a:=880*1024*1024;
    3: a:=4724464025;
    4: a:=8*1024*1024*1024;
    5: a:=25*1024*1024*1024;
    6: a:=50*1024*1024*1024;
    7: a:=Round((100-6.8)*1024*1024*1024);
  end;
  b:=dm.SearchSize(DEF_NEW_DIR);
  pile.MaxValue:=round(a/1024/1024);
  pile.Progress:=round(b/1024/1024);
  if b<=a then pile2.Caption:='Zajęte: '+FormatFloat('0.0',b/1024/1024/1024)+'GB  Wolne: '+FormatFloat('0.0',(a-b)/1024/1024/1024)+'GB'
          else pile2.Caption:='Zajęte: '+FormatFloat('0.0',b/1024/1024/1024)+'GB  Przekroczone: '+FormatFloat('0.0',(b-a)/1024/1024/1024)+'GB';
  application.ProcessMessages;
  {$ENDIF}
end;

procedure TFMain.przenies_film;
var
  s1,s2,s3: string;
begin
  if DBCheckBox1.Checked then
  begin
    (* przenoszę film do nowego katalogu *)
    s1:=MyDir(DEF_DIR)+_FF+filmyplik.AsString;
    s2:=DEF_NEW_DIR+_FF+ExtractFilename(filmyplik.AsString);
    if FileExists(s1) then RenameFile(s1,s2);
    if trim(filmysubtitles.AsString)<>'' then
    begin
      s3:=ExtractFilePath(s1);
      if s3[length(s3)]=_FF then delete(s3,length(s3),1);
      s1:=s3+_FF+filmysubtitles.AsString;
      s2:=DEF_NEW_DIR+_FF+filmysubtitles.AsString;
      if FileExists(s1) then RenameFile(s1,s2);
    end;
  end else begin
    (* przenoszę film do domyślnego katalogu *)
    s1:=MyDir(DEF_DIR)+_FF+filmyplik.AsString;
    s2:=DEF_NEW_DIR+_FF+ExtractFilename(filmyplik.AsString);
    if FileExists(s2) then RenameFile(s2,s1);
    if trim(filmysubtitles.AsString)<>'' then
    begin
      s3:=ExtractFilePath(s1);
      if s3[length(s3)]=_FF then delete(s3,length(s3),1);
      s1:=s3+_FF+filmysubtitles.AsString;
      s2:=DEF_NEW_DIR+_FF+filmysubtitles.AsString;
      if FileExists(s2) then RenameFile(s2,s1);
    end;
  end;
end;

end.

