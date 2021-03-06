unit FrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XpMan, GeoMovements, Buttons, StdCtrls, ExtCtrls,
  GeoSysUtils, GeoAppUtils, GeoGenerators, ComCtrls, ImgList, ToolWin, FrmIdentifyResults;

type
  
  TFmMain = class(TForm)
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    BtnGenerate: TToolButton;
    BtnCalc: TToolButton;
    StatusBar: TStatusBar;
    Panel: TPanel;
    GroupBox2: TGroupBox;
    EdPointCount: TLabeledEdit;
    EdStdDev: TLabeledEdit;
    ProgressBar: TProgressBar;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    EdRepeatCount: TLabeledEdit;
    Label4: TLabel;
    LblClassicMethod: TLabel;
    LblNewMethod: TLabel;
    EdPointGrCount: TLabeledEdit;
    PageControl1: TPageControl;
    TsClassicMethod: TTabSheet;
    TsNewMethod: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnGenerateClick(Sender: TObject);
    procedure BtnCalcClick(Sender: TObject);
  private
    TickCount: Cardinal;
    Generator: THMovementsGenerator;
    ClassicFixedPoints: TCustomFixedPoints;
    NewFixedPoints: TCustomFixedPoints;
    ClassicIdentifyResults: TFmIdentifyResults;  
    NewIdentifyResults: TFmIdentifyResults;
    procedure GenerateValues;
    procedure CalcGroups;
    procedure DoProgress(Percent: Single);
    procedure StartTicking;
    function StopTicking: Single; // in seconds
    procedure LoadData(Dest: TCustomFixedPoints);
    function IdentifyGroups(FixedPoints: TCustomFixedPoints; RepeatCount: Integer; Info: string): Single;  // Result in seconds
  public
    procedure SetInfo(Info: string);
    procedure SetResults(StdMtdTime, NewMtdTime: Single);
  end;

var
  FmMain: TFmMain;

implementation

uses Math, TestForm;

{$R *.dfm}

{ TFmMain }

procedure TFmMain.FormCreate(Sender: TObject);
begin
  Generator:= THMovementsGenerator.Create;
  Generator.OnProgress:= DoProgress;

  ClassicFixedPoints:= TCustomFixedPoints.Create(Self);
  ClassicFixedPoints.StandartIdentification:= True;
  ClassicFixedPoints.IdentifyTolerance:= 2;
  NewFixedPoints:= TCustomFixedPoints.Create(Self);
  NewFixedPoints.StandartIdentification:= False;
  NewFixedPoints.IdentifyTolerance:= 2;

  EdPointCount.Text:= IntToStr(50);
  EdStdDev.Text:= FormatFloat('0.00', 0.7);
end;

procedure TFmMain.FormDestroy(Sender: TObject);
begin
  Generator.Free;
  ClassicFixedPoints.Free;
  NewFixedPoints.Free;
end;

procedure TFmMain.StartTicking;
begin
  TickCount:= GetTickCount;
end;

function TFmMain.StopTicking: Single;
begin
  Result:= 0.001*(GetTickCount - TickCount);
end;

procedure TFmMain.DoProgress(Percent: Single);
begin
  ProgressBar.Position:= Round(Percent*10);
  Application.ProcessMessages;
end;

procedure TFmMain.SetInfo(Info: string);
begin
  StatusBar.SimpleText:= Info;
  Application.ProcessMessages;
  if Info = '' then begin
    ProgressBar.Position:= 0; 
    Screen.Cursor:= crDefault;
  end
  else begin
    Screen.Cursor:= crHourGlass;
  end;
end;

procedure TFmMain.SetResults(StdMtdTime, NewMtdTime: Single);
const FormatStr = '0.00 s';
begin
  LblClassicMethod.Caption:= FormatFloat(FormatStr, StdMtdTime);
  LblClassicMethod.Show;
  LblNewMethod.Caption:= FormatFloat(FormatStr, NewMtdTime);
  LblNewMethod.Show;
end;

procedure TFmMain.GenerateValues;
begin
  Generator.Clear;
  Generator.FixedPointsGroupsCount:= StrAsInt(EdPointGrCount.Text);
  SetPointNames(Generator.FixedPointNames, 'Rp', StrAsInt(EdPointCount.Text));
  Generator.StandartDeviation:= StrAsFloat(EdStdDev.Text);
  Generator.GenerateMovements;
end;

procedure TFmMain.CalcGroups;
begin
end;

procedure TFmMain.LoadData(Dest: TCustomFixedPoints);
begin
  with Dest do begin
    Points:= Generator.Points;
    SetErrors(Generator.Errors);
    Initialize;
  end;
end;

function TFmMain.IdentifyGroups(FixedPoints: TCustomFixedPoints;
  RepeatCount: Integer; Info: string): Single;
var i: Integer;
begin
  SetInfo(Info);
  StartTicking;
  for i:= 0 to RepeatCount-1 do
    FixedPoints.IdentifyGroups;
  Result:= StopTicking;
end;

procedure TFmMain.BtnGenerateClick(Sender: TObject);
begin        
  LblClassicMethod.Hide;
  LblNewMethod.Hide;
  try
    SetInfo('Generowanie przemieszcze�...');
    GenerateValues;
  finally
    SetInfo('');
  end;
  BtnCalc.Enabled:= True;
  FreeAndNil(NewIdentifyResults);
  FreeAndNil(ClassicIdentifyResults);
end;

procedure TFmMain.BtnCalcClick(Sender: TObject);
var StdMtdTime, NewMtdTime: Single;
    RepCount: Integer;
    StdInfo, NewInfo: string;
begin
  try
    SetInfo('�adowanie danych...');
    LoadData(NewFixedPoints);
    LoadData(ClassicFixedPoints);
    RepCount:= StrAsInt(EdRepeatCount.Text);
    StdInfo:= 'Wyznaczanie grup reper�w sta�ych metod� klasyczn�...';  
    NewInfo:= 'Wyznaczanie grup reper�w sta�ych metod� zmodyfikowan�...';

    StdMtdTime:= IdentifyGroups(ClassicFixedPoints, RepCount, StdInfo);
    NewMtdTime:= IdentifyGroups(NewFixedPoints, RepCount, NewInfo);
    SetResults(StdMtdTime, NewMtdTime);
    ClassicIdentifyResults:= LoadIdentifyResults(TsClassicMethod, ClassicFixedPoints);
    NewIdentifyResults:= LoadIdentifyResults(TsNewMethod, NewFixedPoints);
  finally
    SetInfo('');
  end;
  BtnCalc.Enabled:= False;
end;

end.
