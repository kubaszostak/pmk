unit FrmBaseDBForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FrmBaseForm, DB, DBClient, BaseUnit, PmkResStr, GeoDlgs;

type
  TBaseDBForm = class(TBaseForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  protected
    DataSet: TDataSet;
    ReadOnly: Boolean;
    procedure InternalCheckBrowseMode(DataSet: TDataSet);
  public
    { Public declarations }
    procedure CheckBrowseMode; virtual; 
    function AddRecordEnabled: Boolean; virtual;
    function DeleteRecordEnabled: Boolean; virtual;
    function EmptyTableEnabled: Boolean; virtual;
    procedure AddRecord; virtual;
    procedure DeleteRecord; virtual;
    procedure EmptyTable; virtual;  
    function PrintEnabled: Boolean; override;
    function PrintPreviewEnabled: Boolean; override;
    procedure Print; override;
    procedure PrintPreview; override;
    procedure ExportToExcel; override;
  end;

var
  BaseDBForm: TBaseDBForm;

procedure CheckDBFormsInBrowseMode;

implementation

uses DatMod, FrmPrintPreview, PmkExpExc;

{$R *.dfm}

procedure CheckDBFormsInBrowseMode;
var i: integer;
begin
  with Application.MainForm do
  for i:=0 to MDIChildCount do
  if MDIChildren[i] is TBaseDBForm then
    TBaseDBForm(MDIChildren[i]).CheckBrowseMode;
end;

{ TBaseDBForm }

function TBaseDBForm.AddRecordEnabled: Boolean;
begin
  Result:= Assigned(DataSet) and not ReadOnly;
end;

function TBaseDBForm.DeleteRecordEnabled: Boolean;
begin
  Result:= Assigned(DataSet) and not DataSet.IsEmpty and not ReadOnly;
end;

function TBaseDBForm.EmptyTableEnabled: Boolean;
begin
  Result:= DeleteRecordEnabled;
end;

procedure TBaseDBForm.CheckBrowseMode;
begin

end;

procedure TBaseDBForm.InternalCheckBrowseMode(DataSet: TDataSet);
begin
  if Assigned(DataSet) and DataSet.Active then
    try
      DataSet.CheckBrowseMode;
    except
      BringToFront;
      raise;
    end;
end;

procedure TBaseDBForm.AddRecord;
begin
  if AddRecordEnabled then
    DataSet.Insert;
end;

procedure TBaseDBForm.DeleteRecord;
begin
  if DeleteRecordEnabled then
    DataSet.Delete;
end;

procedure TBaseDBForm.EmptyTable;
begin
  if EmptyTableEnabled and (ShowDlg(dmEmptyTable) = mrYes) then begin
    // DataSet.EmptyDataSet usuwa wszystko bez wzgl�du na filtry
    DataSet.DisableControls;
    try
      while not DataSet.IsEmpty do
        DataSet.Delete;
    finally
      DataSet.EnableControls;
    end;
  end;
end;

procedure TBaseDBForm.FormCreate(Sender: TObject);
begin
  inherited;
  ReadOnly:= False;
  Dm.SetDefaultDisplayFormat(Self);
end;

procedure TBaseDBForm.Print;
begin
  if PrintEnabled then
    TFmPrintPreview.PrintDataSet(DataSet, Caption);
end;

procedure TBaseDBForm.PrintPreview;
begin
  if PrintEnabled then
    TFmPrintPreview.PreviewDataSet(DataSet, Caption);
end;

procedure TBaseDBForm.ExportToExcel;
begin
  if PrintPreviewEnabled then
    SendToExcel(DataSet);
end;

function TBaseDBForm.PrintEnabled: Boolean;
begin
  Result:= (DataSet <> nil) and not DataSet.IsEmpty;
end;

function TBaseDBForm.PrintPreviewEnabled: Boolean;
begin
  Result:= PrintEnabled;
end;

end.
