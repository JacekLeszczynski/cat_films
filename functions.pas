unit functions;

{$mode objfpc}{$H+}

interface

const
  CONST_DB_VERSION = 2;

var
  PROG_VERSION: string;
  DB_VERSION: integer = 1;
  NEW_CREATE: boolean = false;
  CUSTOM_CMD: string = '';
  PARAM_1: string = '';
  COM_CLOSE: boolean = false;
  COM_SHUTDOWN: boolean = false;
  DEF_DIR: string = '';
  DEF_READWRITE: boolean = false;
  DEF_MENU: boolean = false;
  DEF_NEW_DIR: string = '';
  FORCE_DIR: string = '';
  FORCE_EDIT: boolean = false;
  FORCE_SCAN: boolean = false;
  OPTICAL_DISC: string = '';
  DEF_FILTERS: boolean = true;
  DEF_VIDEO: integer = 0;
  FORCE_SORT: string = 'tytul';

implementation

end.

