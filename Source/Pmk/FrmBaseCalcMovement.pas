unit FrmBaseCalcMovement;

interface

uses
  {Windows,} Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FrmBaseCreatorForm, StdCtrls, ComCtrls, ExtCtrls,
  FrameSelectItems, CheckLst, AppEvnts, GeoMovements, GeoEstimations,
  Series, TeEngine, TeeProcs, Chart, Matrices, Math, FrmIdentifyResults,
  Menus;

type
  TBaseCalcMovement = class(TBaseCreatorForm)
    TsWelcome: TTabSheet;
    TsCycleNames: TTabSheet;
    TsEstimation: TTabSheet;
    TsFixedPointGroup: TTabSheet;
    TsEstType: TTabSheet;
    TsErrors: TTabSheet;
    TsResults: TTabSheet;
    TsCheckData: TTabSheet;
    Label2: TLabel;
    Image1: TImage;
    Label1: TLabel;
    EdCycleNames: TCheckListBox;
    LvErrors: TListView;
    Splitter: TSplitter;
    LvWarnings: TListView;
    Label4: TLabel;
    rbFreeEstimation: TRadioButton;
    rbFixedEstimation: TRadioButton;
    lblCalcInfo: TLabel;
    PbEstimate: TProgressBar;
    TsFixedPoints: TTabSheet;
    SelectItems: TSelectItems;
    LblCheckDataInfo: TLabel;
    PbCheckData: TProgressBar;
    TsCalcFixedPoints: TTabSheet;
    LblCalcFixedPointsInfo: TLabel;
    PbCalcFixedPoints: TProgressBar;
    Label10: TLabel;
    Label8: TLabel;
    lblM0: TLabel;
    lblMm0: TLabel;
    Label13: TLabel;
    ApplicationEvents: TApplicationEvents;
    Timer: TTimer;
    LblEstInfo: TLabel;
    Label3: TLabel;
    mnuCycles: TPopupMenu;
    mnuSetBaseCycle: TMenuItem;
    procedure TsErrorsShow(Sender: TObject);
    procedure TsCycleNamesShow(Sender: TObject);
    procedure TsFixedPointsShow(Sender: TObject);
    procedure TsCheckDataShow(Sender: TObject);
    procedure TsWelcomeShow(Sender: TObject);
    procedure TsCalcFixedPointsShow(Sender: TObject);
    procedure TsFixedPointGroupShow(Sender: TObject);
    procedure TsEstTypeShow(Sender: TObject);
    procedure TsEstimationShow(Sender: TObject);
    procedure TsResultsShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure EdCycleNamesClickCheck(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rbFreeEstimationClick(Sender: TObject);
    procedure TsFixedPointsHide(Sender: TObject);
    procedure mnuSetBaseCycleClick(Sender: TObject);
  private           
  protected
    Movement: TCustomDhMovement;
    FixedPoints: TCustomFixedHPoints;
    GetFixedPointNames: TGetNamesMethod;
    procedure GetSelectedItems(Names: TStrings);

    procedure SetProcessingInfo(ProgressPercent: Double; Info: string);
    procedure LoadDataProgress(Sender: TObject; Percent: Double);
    procedure CheckDataProgress(Sender: TObject; Percent: Double);
    procedure SaveResultsProgress(Sender: TObject; Percent: Double); 
    procedure CalcProgress(Sender: TObject; Percent: Double);
    procedure DoIdentifyResultsChange(Sender: TObject);
  public
    procedure OnGetNextPageIndex(BtnNext: boolean; var NewPageIndex: integer); override;
    procedure AfterShowPage; override;
    procedure AddErrors(Errors: TStrings);
    procedure AddWarnings(Warnings: TStrings);
    procedure AddError(Error: string);
  end;

var
  BaseCalcMovement: TBaseCalcMovement;

implementation

uses
  PmkResStr, BaseUnit, DatMod, GeoFiles, PmkStorage;

{$R *.dfm}

procedure TBaseCalcMovement.AddErrors(Errors: TStrings);
var i: integer;
begin
  for i:= 0 to Errors.Count-1 do
    LvErrors.Items.Add.Caption:= Errors[i];
end;

procedure TBaseCalcMovement.AddWarnings(Warnings: TStrings);
var i: integer;
begin
  for i:= 0 to Warnings.Count-1 do
    LvWarnings.Items.Add.Caption:= Warnings[i];
end;

procedure TBaseCalcMovement.AddError(Error: string);
begin
  LvErrors.Items.Add.Caption:= Error;
end;

procedure TBaseCalcMovement.OnGetNextPageIndex(BtnNext: boolean;
  var NewPageIndex: integer);
var i: integer;
    ErrMsg: string;
begin
  inherited;
  if BtnNext then begin

    if PageControl.ActivePage = TsCycleNames then begin
      for i:= 0 to EdCycleNames.Count-1 do
        if EdCycleNames.Checked[i] and EdCycleNames.ItemEnabled[i] then
          exit;
      NewPageIndex:= PageControl.ActivePageIndex;
      ErrMsg:= emNoCalcCycle;
      if EdCycleNames.Count = 1 then
        ErrMsg:= Format('%s (%s).', [emNoCalcCycle, emCantCalcCycle0]);
      RaiseError(ErrMsg);
    end;

    if PageControl.Pages[NewPageIndex] = TsErrors then begin
      if LvErrors.Items.Count + LvWarnings.Items.Count = 0 then
        Inc(NewPageIndex);
    end;

    if LvErrors.Items.Count > 0 then
      NewPageIndex:= TsErrors.PageIndex;

  end;
end;

procedure TBaseCalcMovement.AfterShowPage;
begin
  inherited;
  with PageControl do
  if  (ActivePage = TsCheckData)
     or (ActivePage = TsEstimation)
     or (ActivePage = TsCalcFixedPoints)  then
    SetNextPage;
end;

//******************************************************************************

procedure TBaseCalcMovement.FormCreate(Sender: TObject);
begin
  inherited;
  with Movement do begin
    with BaseObsSource do begin
      BeginPointField:= 'BeginPoint';
      EndPointField:= 'EndPoint';
      ValueField:= 'Dh';
      ErrorField:= 'N';
    end;
    with ObsSource do begin
      BeginPointField:= 'BeginPoint';
      EndPointField:= 'EndPoint';
      ValueField:= 'Dh';
      ErrorField:= 'N';
    end;
    with DeltaDhSource do begin
      BeginPointField:= 'BeginPoint';
      EndPointField:= 'EndPoint';
      ValueField:= 'Dh';
      ErrorField:= 'DhErr';
    end;
    with DeltaHSource do begin
      ValueField:= 'Delta';
      ErrorField:= 'DeltaErr';
      NameField:= 'Name';
    end;
    with VSource do begin
      BeginPointField:= 'BeginPoint';
      EndPointField:= 'EndPoint';
      ValueField:= 'V';
      ErrorField:= 'VErr';
    end;
    OnLoadData:= LoadDataProgress;
    OnCheckData:= CheckDataProgress;
    OnSaveResults:= SaveResultsProgress;
    OnCalc:= CalcProgress;
  end;
  LvErrors.Clear;
  LvWarnings.Clear;
end;

procedure TBaseCalcMovement.FormDestroy(Sender: TObject);
begin
  inherited;
  //
end;

procedure TBaseCalcMovement.TsWelcomeShow(Sender: TObject);
begin
  inherited;
  LblPageInfo.Caption:= cmMovementInfo;

  if Dm.DhCycles.RecordCount < 2 then
    AddError(emNotEnoughCycles);

  if Dm.DhObs0.RecordCount <= 3 then
    AddError(emNotEnoughObs);

  if Movement is THMovement then
    if Dm.FixedH.IsEmpty then begin
      AddError(emNoFixedPoints);
      AddError(emNoFixedHPoints);
    end;
end; 

procedure TBaseCalcMovement.TsCycleNamesShow(Sender: TObject);
var Indx: integer;
begin
  inherited;
  LblPageInfo.Caption:= cmSelectCycle;
  Dm.GetDhCycleNames(EdCycleNames.Items);
  if EdCycleNames.Count > 1 then begin
    Indx:= EdCycleNames.Items.IndexOf(Dm.BaseCycleName);
    if Indx > -1 then begin
      EdCycleNames.Checked[Indx]:= True;
      EdCycleNames.ItemEnabled[Indx]:= False;
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

procedure TBaseCalcMovement.TsCheckDataShow(Sender: TObject);
var i: integer;
begin
  inherited;
  LblPageInfo.Caption:= cmInitialization;

  BeginProcessing;
  try                
    for i:= 0 to EdCycleNames.Count-1 do
      with EdCycleNames do
        if not ItemEnabled[i]  then begin
          Dm.SetBaseCycleName(EdCycleNames.Items[i]);
          Break;
        end;
    Movement.BaseCycleName:= Dm.BaseCycleName;

    for i:= 0 to EdCycleNames.Count-1 do
      with EdCycleNames do
        if Checked[i] and ItemEnabled[i]  then begin
          Movement.CycleName:= EdCycleNames.Items[i];
          Break;
        end;
    Assert(Dm.DhCyclesLocate(Movement.CycleName));
    Movement.Initialize;
  except
    EndProcessing;
    Close;
    raise;
  end;
  EndProcessing;
  AddWarnings(Movement.Warnings);
  AddErrors(Movement.Errors);
end;

procedure TBaseCalcMovement.TsErrorsShow(Sender: TObject);
begin
  inherited;
  LblPageInfo.Caption:= cmErrors;
  with LvErrors do
    Visible:= Items.Count <> 0;
  with LvWarnings do
    Visible:= Items.Count <> 0;
  Splitter.Visible:= LvErrors.Visible and LvWarnings.Visible;
  if not LvWarnings.Visible then
    LvErrors.Align:= alClient;
  if LvErrors.Visible then begin
    BtnNext.Caption:= 'Zamknij';
    BtnNext.OnClick:= BtnCancel.OnClick;
    BtnCancel.Hide;
  end;
  Assert(LvErrors.Visible or LvWarnings.Visible);
end;

procedure TBaseCalcMovement.TsFixedPointsShow(Sender: TObject);
var SelItems: TStrings;
begin
  inherited;
  LblPageInfo.Caption:= cmSelectFixedPionts;

  Movement.GetAvailableFixedPoints(SelectItems.AllItems);
  if SelectItems.AllItems.Count < 1 then begin
    Close;
    ShowMessage(emNoFixedPoints);
  end
  else
    SelectItems.edAll.ItemIndex:= 0;
  SelectItems.SelectedItems.Clear;
  SelItems:= TStringList.Create;
  try
    GeoIniFile.ReadStrings(Self.Name, 'SelectedItems', SelItems);
    SelectItems.SetSelectedItems(SelItems);
  finally
    SelItems.Free;
  end;
  SelectItems.UpdateButtons;
  // ToDo  SetSelectedItems(LoadFormStorage)
end;    

procedure TBaseCalcMovement.TsFixedPointsHide(Sender: TObject);
begin
  inherited;
  GeoIniFile.WriteStrings(Self.Name, 'SelectedItems', SelectItems.SelectedItems);
end;

procedure TBaseCalcMovement.TsCalcFixedPointsShow(Sender: TObject);
begin
  inherited;
  LblPageInfo.Caption:= cmCalcFixedPionts;

  if Assigned(FixedPoints) then begin
    BeginProcessing;
    try
      Movement.FixedPointNames.Assign(SelectItems.SelectedItems);
      FixedPoints.Initialize;
    except   
      EndProcessing;
      Close;
      raise;
    end;
    EndProcessing;
  end;
end;     

procedure TBaseCalcMovement.DoIdentifyResultsChange(Sender: TObject);
begin
  with FmIdentifyResults do begin
    BtnNext.Default:= not EdMinRepCount.Focused and not EdWspK.Focused;
    BtnNext.Enabled:= FixedCountOK;
  end;
end;

procedure TBaseCalcMovement.TsFixedPointGroupShow(Sender: TObject);
begin
  inherited;
  //ShowMessage(FormatFloat('0.00', Movement.Accuracy.StandartError));
  LblPageInfo.Caption:= cmFixedPointsGroup;
  if Assigned(FixedPoints) then begin
    BeginProcessing;
    try
      FmIdentifyResults:= LoadIdentifyResults(TsFixedPointGroup, FixedPoints);
      FmIdentifyResults.OnChange:= DoIdentifyResultsChange;
      GetFixedPointNames:= FmIdentifyResults.GetSelectedGroup;
    except
      EndProcessing;
      Close;
      raise;
    end;
    EndProcessing;
  end;
end;

procedure TBaseCalcMovement.TsEstTypeShow(Sender: TObject);
begin
  inherited;
  LblPageInfo.Caption:= cmEstimationType;
  rbFreeEstimationClick(Sender);
end;

procedure TBaseCalcMovement.TsEstimationShow(Sender: TObject);
begin
  inherited;
  LblPageInfo.Caption:= cmEstimation;

  BeginProcessing;
  try
    Movement.FreeEstimation:= rbFreeEstimation.Checked;
    GetFixedPointNames(Movement.FixedPointNames);
    Dm.DisableControls;
    Dm.DeltaH.EmptyDataSet;
    Dm.DeltaDh.EmptyDataSet;
    Dm.ResH.EmptyDataSet;
    try
      Movement.Calc;
    finally
      Dm.EnableControls;
      Movement.ClearData;
    end;
  except   
    EndProcessing;
    Close;
    raise;
  end;
  EndProcessing;
end;

procedure TBaseCalcMovement.TsResultsShow(Sender: TObject);
begin
  inherited;
  LblPageInfo.Caption:= cmEnd;

  with Movement do begin
    Dm.SetActiveDhCycleInfo(Accuracy, FreeEstimation, FixedPointNames.Text);
    lblm0.Caption:= 'm0 = '+FormatFloat('0.000', Accuracy.StandartError);
    lblmm0.Caption:= 'mm0 = '+FormatFloat('0.000', Accuracy.StandartErrorErr);
  end;
end;

procedure TBaseCalcMovement.SetProcessingInfo(ProgressPercent: Double; Info: string);
begin
  PbEstimate.Position:= Round(ProgressPercent*10);
  PbCalcFixedPoints.Position:= PbEstimate.Position;
  lblCalcInfo.Caption:= Info;
  LblCalcFixedPointsInfo.Caption:= Info;
  Repaint;
  //Application.ProcessMessages;
end;

procedure TBaseCalcMovement.LoadDataProgress(Sender: TObject;
  Percent: Double);
begin
  SetProcessingInfo(Percent, pmLoadData);
end;    

procedure TBaseCalcMovement.CheckDataProgress(Sender: TObject;
  Percent: Double);
begin
  PbCheckData.Position:= Round(Percent*10);
  LblCheckDataInfo.Caption:= pmCheckData; 
  Repaint;
  //Application.ProcessMessages;
end;

procedure TBaseCalcMovement.SaveResultsProgress(Sender: TObject; Percent: Double);
begin
  SetProcessingInfo(Percent, pmSaveResults);
end;   

procedure TBaseCalcMovement.CalcProgress(Sender: TObject; Percent: Double);
begin
  SetProcessingInfo(Percent, pmCalc);
end;

procedure TBaseCalcMovement.ApplicationEventsIdle(Sender: TObject;
  var Done: Boolean);
begin
  inherited;
  if PageControl.ActivePage = TsFixedPoints then begin
    if TsFixedPointGroup.Tag <> 0 then // Relative movements
      BtnNext.Enabled:= SelectItems.SelectedItems.Count > 0
    else // Absolute movements
      BtnNext.Enabled:= SelectItems.SelectedItems.Count > 1
    // Todo zmienna MovementType
    // �adowa� obrazki z zasob�w
  end;
  mnuSetBaseCycle.Enabled:= EdCycleNames.ItemIndex > -1;
end;

procedure TBaseCalcMovement.GetSelectedItems(Names: TStrings);
begin
  Names.Assign(SelectItems.SelectedItems);
end;

procedure TBaseCalcMovement.EdCycleNamesClickCheck(Sender: TObject);
var i, SelectedIndex: integer;
begin
  inherited;
  with EdCycleNames do begin
    SelectedIndex:= ItemIndex;
    if SelectedIndex > -1 then
      for i:= 0 to Count-1 do
        Checked[i]:= (i=SelectedIndex) or (not ItemEnabled[i]);
  end;
end;

procedure TBaseCalcMovement.FormShow(Sender: TObject);

  procedure ShowFields(Source: TEstimationDataSource);
  begin
    ShowMessage(Source.DataSet.Name+': '#10+Source.DataSet.FieldDefList.Text);
  end;
  
begin
  inherited;
  with Movement do begin
    //ShowFields(Results);
    //ShowFields(DeltaDh);
    //ShowFields(VSource);
    //ShowFields(DeltaDh);
  end;
end;

procedure TBaseCalcMovement.rbFreeEstimationClick(Sender: TObject);
begin
  inherited;
  if rbFreeEstimation.Checked then
    LblEstInfo.Caption:= cmFreeEstInfo
  else  
    LblEstInfo.Caption:= cmFixedEstInfo;

end;

procedure TBaseCalcMovement.mnuSetBaseCycleClick(Sender: TObject);
var i: Integer;
begin
  inherited;
  with EdCycleNames do
    if ItemIndex > -1 then begin
      for i:= 0 to Items.Count-1 do
        ItemEnabled[i]:= True;
      ItemEnabled[ItemIndex]:= False;
      Checked[ItemIndex]:= True;
    end;
end;

end.
