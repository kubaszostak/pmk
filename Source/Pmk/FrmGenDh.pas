unit FrmGenDh;

interface
                   
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FrmBaseCreatorForm, ComCtrls, StdCtrls, ExtCtrls, Math,
  BaseUnit, PmkResStr, FrameSelectItems, GeoCalcResStr, GeoGenerators, GeoTypes,
  GeoDlgs, CheckLst, PmkStorage;

type
  TFmGenDh = class(TBaseCreatorForm)
    TsWelcome: TTabSheet;
    TsPointCount: TTabSheet;
    TsProgress: TTabSheet;
    TsMovementType: TTabSheet;
    TsCycle: TTabSheet;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    EdFixedPoints: TListBox;
    EdTestPoints: TListBox;
    EdFixedPointCount: TLabeledEdit;
    EdTestPointCount: TLabeledEdit;
    BtnFixedPointOK: TButton;
    BtnTestPointOK: TButton;
    ProgressBar: TProgressBar;
    LblProgressInfo: TLabel;
    rbFuzzyMovements: TRadioButton;
    rbEvidentMovements: TRadioButton;
    chbMultipleFixedPointGroups: TCheckBox;
    edFixedPointGroupCount: TLabeledEdit;
    Bevel2: TBevel;
    Bevel3: TBevel;
    EdCycleNames: TCheckListBox;
    Label3: TLabel;
    procedure BtnFixedPointOKClick(Sender: TObject);
    procedure BtnTestPointOKClick(Sender: TObject);
    procedure chbMultipleFixedPointGroupsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TsPointCountShow(Sender: TObject);
    procedure TsProgressShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EdCycleNamesClickCheck(Sender: TObject);
    procedure TsCycleShow(Sender: TObject);
    procedure TsCycleHide(Sender: TObject);
    procedure TsMovementTypeHide(Sender: TObject);
  private
    FDhObsGen: THMovementsObsGenerator;
    procedure CheckFixedPointCount(Count: Integer);
    procedure CheckTestPointCount(Count: Integer);
    function MinFixedPointCount: Integer;
    procedure CheckMaxPointCount(PointCount: Integer);
  public
    procedure OnGetNextPageIndex(BtnNext: boolean; var NewPageIndex: integer); override;
  end;

var
  FmGenDh: TFmGenDh;


procedure CopyObsToDB(MvmntDhGenerator: THMovementsObsGenerator; ProgrBar: TProgressBar);
procedure CopyFixedPointsToDB(MvmntDhGenerator: THMovementsObsGenerator; ProgrBar: TProgressBar);

implementation

uses DatMod, DB;

{$R *.dfm}

const
  MaxPointCount = 200;



procedure TFmGenDh.OnGetNextPageIndex(BtnNext: boolean;
  var NewPageIndex: integer);
var i: Integer;
begin
  inherited;
  if BtnNext then begin
    if PageControl.ActivePage = TsPointCount then begin
      CheckFixedPointCount(EdFixedPoints.Items.Count);
      CheckTestPointCount(EdTestPoints.Items.Count);
    end;
    if PageControl.ActivePage = TsMovementType then begin
      if chbMultipleFixedPointGroups.Checked then begin
        i:= StrToInt(edFixedPointGroupCount.Text);
        if i<2 then
          RaiseError(emGenLowFixedPointGroupCount);
      end;
    end;
  end;
end;

function TFmGenDh.MinFixedPointCount: Integer;
begin
  if chbMultipleFixedPointGroups.Checked then
    Result:= StrToInt(edFixedPointGroupCount.Text)*3
  else
    Result:= 3 ;
end;

procedure TFmGenDh.CheckFixedPointCount(Count: Integer);
begin
  if chbMultipleFixedPointGroups.Checked then begin
    if Count < MinFixedPointCount then
      RaiseError(emGenFixedPointCount, [MinFixedPointCount]);
  end
  else
    if Count < 3 then
      RaiseError(emGenRepCount);
end;

procedure TFmGenDh.CheckTestPointCount(Count: Integer);
begin
  if Count < 3 then
    RaiseError(emGenRepCount);
end;

procedure TFmGenDh.BtnFixedPointOKClick(Sender: TObject);
var PointCount: Integer;
begin
  inherited;
  PointCount:= StrToInt(EdFixedPointCount.Text);
  CheckMaxPointCount(PointCount);
  CheckFixedPointCount(PointCount);
  SetPointNames(EdFixedPoints.Items, 'Rp', PointCount);
end;

procedure TFmGenDh.BtnTestPointOKClick(Sender: TObject); 
var PointCount: Integer;
begin
  inherited;
  PointCount:= StrToInt(EdTestPointCount.Text); 
  CheckMaxPointCount(PointCount);
  CheckTestPointCount(PointCount);
  SetPointNames(EdTestPoints.Items, '', PointCount);
end;

procedure TFmGenDh.chbMultipleFixedPointGroupsClick(Sender: TObject);
begin
  inherited;
  edFixedPointGroupCount.Enabled:= chbMultipleFixedPointGroups.Checked;
end;

procedure TFmGenDh.FormCreate(Sender: TObject);
var PointCount: Integer;
begin
  inherited;
  FDhObsGen:= THMovementsObsGenerator.Create;
  GeoIniFile.ReadProperty(chbMultipleFixedPointGroups, 'Checked');
  GeoIniFile.ReadProperty(edFixedPointGroupCount, 'Text');

  // Najpierw Repery badane
  BtnTestPointOKClick(Sender);
  BtnFixedPointOKClick(Sender);
end;

procedure TFmGenDh.FormDestroy(Sender: TObject);
begin
  inherited;
  FDhObsGen.Free;
  GeoIniFile.WriteProperty(chbMultipleFixedPointGroups, 'Checked');
  GeoIniFile.WriteProperty(edFixedPointGroupCount, 'Text');
  GeoIniFile.WriteProperty(EdFixedPointCount, 'Text');
  GeoIniFile.WriteProperty(EdTestPointCount, 'Text');
end;

procedure TFmGenDh.TsPointCountShow(Sender: TObject);
begin
  inherited;
  if StrToInt(EdFixedPointCount.Text) < MinFixedPointCount then begin
    EdFixedPointCount.Text:= IntToStr(MinFixedPointCount);
    BtnFixedPointOKClick(Sender);
  end;
end;

procedure TFmGenDh.TsProgressShow(Sender: TObject);

  procedure SetInfo(Info: string);
  begin
    LblProgressInfo.Caption:= Info;
    Application.ProcessMessages;
  end;

begin
  inherited;
  BeginProcessing;
  try
    SetInfo(pmLoadData); // tak naprawd� to tutaj s� generowane obserwacjie
    FDhObsGen.FixedPointNames.Assign(EdFixedPoints.Items);
    FDhObsGen.TestPointNames.Assign(EdTestPoints.Items);
    FDhObsGen.GenerateDhObservations( (EdFixedPoints.Count + EdTestPoints.Count)*2 );
                                
    SetInfo(pmGenerateObservations); // Ta informacja to lipa, ale �adniej wygl�da
    CopyObsToDB(FDhObsGen, ProgressBar);

    SetInfo(pmSaveResults);
    CopyFixedPointsToDB(FDhObsGen, ProgressBar);

    ProgressBar.Position:= 0;
    SetInfo('Zako�czono obliczenia.');
  except
    EndProcessing;
    Close;
    raise;
  end;
  EndProcessing;
end;

procedure CopyFixedPointsToDB(MvmntDhGenerator: THMovementsObsGenerator; ProgrBar: TProgressBar);

  procedure AddFixedPoint(const FixedPoint: TGeoCycleNamedValue);
  begin
    with Dm.FixedH, FixedPoint do begin
      Append;
      FieldByName(fnName).AsString:= Name;
      FieldByName(fnH).AsFloat:= BaseCycle.Value;
      Post;
    end;
    if Assigned(ProgrBar) then
      ProgrBar.StepIt;
  end;

var i: Integer;
begin
  with Dm.FixedH, MvmntDhGenerator do begin
    if Assigned(ProgrBar) then
      ProgrBar.Max:= Length(FixedPointValues);
    DisableControls;
    try
      for i:= 0 to Length(FixedPointValues)-1 do
        AddFixedPoint(FixedPointValues[i]);
    finally
      EnableControls;
    end;
  end;   
end;

procedure CopyObsToDB(MvmntDhGenerator: THMovementsObsGenerator; ProgrBar: TProgressBar);

  procedure AddDhObs(const Observation: TGeoCycleBeginEndValue; IsBaseCycle: Boolean);
  begin
    with Dm.DhObs, Observation do begin
      Append;
      FieldByName(fnBeginPoint).AsString:= BeginName;
      FieldByName(fnEndPoint).AsString:= EndName;
      if IsBaseCycle then begin
        FieldByName(fnDh).AsFloat:= BaseCycle.Value;
        FieldByName(fnN).AsInteger:= Round(BaseCycle.Error);
      end
      else begin
        FieldByName(fnDh).AsFloat:= ActiveCycle.Value;
        FieldByName(fnN).AsInteger:= Round(ActiveCycle.Error);
      end;
      Post;
    end;
    if Assigned(ProgrBar) then
      ProgrBar.StepIt;
  end;

  procedure SetCycleName(CycleName: string);
  begin
    Assert(dm.DhCyclesLocate(CycleName));
    if dm.DhObs.RecordCount > 0 then
      case ShowDlg(dmDeleteObs, [CycleName]) of
        mrYes: Dm.DeleteDhObs(CycleName);
        mrNo:; // nic nie r�b
        mrCancel: Exit;
      end;
  end;

var i: Integer;
begin
  with Dm.DhObs, MvmntDhGenerator do begin
    if Assigned(ProgrBar) then
      ProgrBar.Max:= 2*Length(Observations);
    DisableControls;
    try
      SetCycleName(BaseCycleName);
      for i:= 0 to Length(Observations)-1 do
        AddDhObs(Observations[i], True);

      SetCycleName(ActiveCycleName);
      for i:= 0 to Length(Observations)-1 do
        AddDhObs(Observations[i], False);
    finally
      EnableControls;
    end;
  end;
end;

procedure TFmGenDh.EdCycleNamesClickCheck(Sender: TObject);
var i, SelectedIndex: integer;
begin
  inherited;
  with EdCycleNames do begin
    SelectedIndex:= ItemIndex;
    if SelectedIndex > -1 then
      for i:= 0 to Count-1 do
        if Checked[i] and (i<>SelectedIndex) then
          Checked[i]:= False;
  end;
end;

procedure TFmGenDh.TsCycleShow(Sender: TObject);
var Indx: integer;
begin
  inherited;
  LblPageInfo.Caption:= cmSelectCycle;
  if Dm.DhCycles.RecordCount < 2 then
    Dm.AddDhCycle;

  Dm.GetDhCycleNames(EdCycleNames.Items);
  if EdCycleNames.Count > 1 then begin
    Indx:= EdCycleNames.Items.IndexOf(Dm.BaseCycleName);
    if Indx > -1 then begin
      EdCycleNames.ItemEnabled[Indx]:= False;
      EdCycleNames.Checked[Indx]:= True;
    end;
    // Ustaw ostatni cykl jako aktywny
    Indx:= EdCycleNames.Count-1;
    if not EdCycleNames.ItemEnabled[Indx] then
      Dec(Indx);
    EdCycleNames.Checked[Indx]:= Indx>-1;
  end
  else begin
    Close;
    RaiseError(emNotEnoughCycles);
  end;

end;

procedure TFmGenDh.TsCycleHide(Sender: TObject);
var i: Integer;
begin
  inherited;
  with EdCycleNames do
  for i:= 0 to Count-1 do
    if Checked[i] then begin
      if ItemEnabled[i] then
        FDhObsGen.ActiveCycleName:= Items[i]
      else
        FDhObsGen.BaseCycleName:= Items[i];
    end;
end;

procedure TFmGenDh.CheckMaxPointCount(PointCount: Integer);
begin
  if PointCount > MaxPointCount then
    RaiseError(emMaxPointCount, [MaxPointCount]);
end;

procedure TFmGenDh.TsMovementTypeHide(Sender: TObject);
begin
  inherited;
  FDhObsGen.FuzzyMovements:= rbFuzzyMovements.Checked;
  if chbMultipleFixedPointGroups.Checked then
    FDhObsGen.FixedPointsGroupsCount:= StrToInt(edFixedPointGroupCount.Text)
  else
    FDhObsGen.FixedPointsGroupsCount:= 1;
end;

end.
