program cat_films;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, zcomponent, uecontrols, edit, datamodule, kolumny, opis,
  unit_exit, functions, about, normalizacja_nazw, gen_spis, serwis_filmweb
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.

