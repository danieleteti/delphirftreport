unit RTFReportEngine;

interface

uses
  System.Generics.Collections,
  Classes,
  SysUtils, Data.DB;

type
  EParserException = class(Exception)

  end;

  TRTFLoopControl = record
    Identifier: String;
    SymbolToConsumeAtEachIteration: String;
    class function Create(aIdentifier, aSymbolToConsumeAtEachIteration: String)
      : TRTFLoopControl; static;
  end;

  TRTFReportEngine = class
  strict private
    FOutput: string;
    FVariables: TDictionary<string, string>;
    function MatchStartTag: Boolean;
    function MatchEndTag: Boolean;
    function MatchIdentifier(var aIdentifier: String): Boolean;
    function MatchReset(var aDataSet: String): Boolean;
    function MatchField(var aDataSet: String; var aFieldName: String): Boolean;
    function MatchSymbol(const Symbol: String): Boolean;
  private
    FInputString: string;
    FCharIndex: Int64;
    FCurrentLine: Integer;
    FCurrentColumn: Integer;
    FLoopStack: TStack<Integer>;
    FLoopIdentStack: TStack<TRTFLoopControl>;
    FDatasets: TArray<TDataSet>;
    FCurrentDataset: TDataSet;
    procedure Error(const Message: String);
    function ExecuteFunction(AFunctionName, AValue: String): String;
    function SetDataSetByName(const Name: String): Boolean;
    function GetFieldText(const FieldName: String): String;
  public
    procedure Parse(const InputString: string; const Data: TArray<TDataSet>);
    procedure AppendOutput(const AValue: string);
    constructor Create;
    destructor Destroy; override;
    procedure SetVar(const AName: string; AValue: string);
    function GetVar(const AName: string): string;
    procedure ClearVariables;
    function GetOutput: string;
  end;

implementation

const
  IdenfierAllowedFirstChars = ['a' .. 'z', 'A' .. 'Z', '_'];
  IdenfierAllowedChars = IdenfierAllowedFirstChars + ['0' .. '9'];

  { TParser }

procedure TRTFReportEngine.AppendOutput(const AValue: string);
begin
  FOutput := FOutput + AValue;
end;

procedure TRTFReportEngine.ClearVariables;
begin
  FVariables.Clear;
end;

constructor TRTFReportEngine.Create;
begin
  inherited;
  FOutput := '';
  FVariables := TDictionary<string, string>.Create;
  FLoopStack := TStack<Integer>.Create;
  FLoopIdentStack := TStack<TRTFLoopControl>.Create;
end;

destructor TRTFReportEngine.Destroy;
begin
  FLoopIdentStack.Free;
  FLoopStack.Free;
  FVariables.Free;
  inherited;
end;

function TRTFReportEngine.SetDataSetByName(const Name: String): Boolean;
var
  ds: TDataSet;
begin
  Result := False;
  for ds in FDatasets do
  begin
    if SameText(ds.Name, Name) then
    begin
      FCurrentDataset := ds;
      Result := True;
      Break;
    end;
  end;
end;

function TRTFReportEngine.GetFieldText(const FieldName: String): String;
var
  lField: TField;
begin
  if not Assigned(FCurrentDataset) then
    Error('Current dataset not set');
  lField := FCurrentDataset.FieldByName(FieldName);
  if not Assigned(lField) then
    Error(Format('Fieldname not found: "%s.%s"',
      [FCurrentDataset.Name, FieldName]));
  Result := lField.AsWideString;
end;

function TRTFReportEngine.GetOutput: string;
begin
  Result := FOutput;
end;

function TRTFReportEngine.GetVar(const AName: string): string;
begin
  if not FVariables.TryGetValue(AName, Result) then
    Result := '';
end;

function TRTFReportEngine.MatchEndTag: Boolean;
begin
  Result := (FInputString.Chars[FCharIndex] = '\') and (FInputString.Chars[FCharIndex + 1] = '\');
  if Result then
    Inc(FCharIndex, 2);
end;

function TRTFReportEngine.MatchField(var aDataSet: String; var aFieldName: String): Boolean;
begin
  Result := False;
  if not MatchSymbol(':') then
    Exit;
  if not MatchIdentifier(aDataSet) then
    Error('Expected dataset name');
  if not MatchSymbol('.') then
    Error('Expected "."');
  if not MatchIdentifier(aFieldName) then
    Error('Expected field name');
  Result := True;
end;

function TRTFReportEngine.MatchIdentifier(var aIdentifier: String): Boolean;
begin
  aIdentifier := '';
  Result := False;
  if CharInSet(FInputString.Chars[FCharIndex], IdenfierAllowedFirstChars) then
  begin
    while CharInSet(FInputString.Chars[FCharIndex], IdenfierAllowedChars) do
    begin
      aIdentifier := aIdentifier + FInputString.Chars[FCharIndex];
      Inc(FCharIndex);
    end;
    Result := True;
  end
end;

function TRTFReportEngine.MatchReset(var aDataSet: String): Boolean;
begin
  if not MatchSymbol('reset') then
    Exit(False);
  Result := MatchSymbol('(') and MatchIdentifier(aDataSet) and MatchSymbol(')');
end;

function TRTFReportEngine.MatchStartTag: Boolean;
begin
  Result := (FInputString.Chars[FCharIndex] = '\') and (FInputString.Chars[FCharIndex + 1] = '\');
  if Result then
    Inc(FCharIndex, 2);
end;

function TRTFReportEngine.MatchSymbol(const Symbol: String): Boolean;
var
  lSymbolIndex: Integer;
  lSavedCharIndex: Int64;
begin
  if Symbol.IsEmpty then
    Exit(True);
  lSavedCharIndex := FCharIndex;
  lSymbolIndex := 0;
  // lChar := FInputString.Chars[FCharIndex];
  while FInputString.Chars[FCharIndex] = Symbol.Chars[lSymbolIndex] do
  begin
    Inc(FCharIndex);
    Inc(lSymbolIndex);
    // lChar := FInputString.Chars[FCharIndex]
  end;
  Result := (lSymbolIndex > 0) and (lSymbolIndex = Length(Symbol));
  if not Result then
    FCharIndex := lSavedCharIndex;
end;

procedure TRTFReportEngine.Parse(const InputString: string; const Data: TArray<TDataSet>);
var
  lChar: Char;
  lVarName: string;
  lFuncName: String;
  lIdentifier: String;
  lDataSet: string;
  lFieldName: string;
  lIgnoreOutput: Boolean;
begin
  lIgnoreOutput := False;
  FDatasets := Data;
  FLoopStack.Clear;
  FLoopIdentStack.Clear;
  FOutput := '';
  FCharIndex := 0;
  FCurrentLine := 1;
  FCurrentColumn := 1;
  FInputString := InputString;
  while FCharIndex < InputString.Length do
  begin
    lChar := InputString.Chars[FCharIndex];
    if lChar = #13 then
    begin
      Inc(FCurrentLine);
      FCurrentColumn := 1;
    end;
    Inc(FCurrentColumn);

    if MatchStartTag then
    begin
      if not lIgnoreOutput and MatchSymbol('loop') then
      begin
        if not MatchSymbol('(') then
          Error('Expected "("');
        if not MatchIdentifier(lIdentifier) then
          Error('Expected identifier after "loop("');
        if not MatchSymbol(')') then
          Error('Expected ")" after "' + lIdentifier + '"');
        if not MatchEndTag then
          Error('Expected closing tag for "loop(' + lIdentifier + ')"');
        if not SetDataSetByName(lIdentifier) then
          Error('Unknown dataset: ' + lIdentifier);
        FLoopStack.Push(FCharIndex);
        // lChar := FInputString.Chars[FCharIndex];
        if MatchSymbol('}'#13#10'\par ') then
        begin
          FLoopIdentStack.Push(TRTFLoopControl.Create(lIdentifier, '}'#13#10'\par '));
          AppendOutput('}'#13#10' ');
        end
        else
        begin
          FLoopIdentStack.Push(TRTFLoopControl.Create(lIdentifier, ''));
        end;
        lIgnoreOutput := FCurrentDataset.Eof;
        Continue;
      end;

      if MatchSymbol('endloop') then
      begin
        if not MatchEndTag then
          Error('Expected closing tag');
        lIdentifier := FLoopIdentStack.Peek.Identifier;
        if not SetDataSetByName(lIdentifier) then
          Error('Invalid dataset name: ' + lIdentifier);

        FCurrentDataset.Next;
        if FCurrentDataset.Eof then
        begin
          FLoopIdentStack.Pop;
          FLoopStack.Pop;
          if lIgnoreOutput then
            MatchSymbol('}'); // otherwhise the rtf structure is open
          lIgnoreOutput := False;
        end
        else
        begin
          FCharIndex := FLoopStack.Peek;
          MatchSymbol(FLoopIdentStack.Peek.SymbolToConsumeAtEachIteration);
          AppendOutput('}'#13#10' ');
        end;
        Continue;
      end;

      if not lIgnoreOutput and MatchField(lDataSet, lFieldName) then
      begin
        if not SetDataSetByName(lDataSet) then
          Error('Unknown dataset: ' + lDataSet);
        AppendOutput(GetFieldText(lFieldName));
        Continue;
      end;

      if not lIgnoreOutput and MatchReset(lDataSet) then
      begin
        SetDataSetByName(lDataSet);
        FCurrentDataset.First;
        Continue;
      end;

      if not lIgnoreOutput and MatchIdentifier(lVarName) then
      begin
        if MatchSymbol(':') then
        begin
          if lVarName.IsEmpty then
            Error('Invalid variable name');
          if not MatchIdentifier(lFuncName) then
            Error('Invalid function name');
          if not MatchEndTag then
            Error('Expected end tag');
          AppendOutput(ExecuteFunction(lFuncName, GetVar(lVarName)));
        end
        else
        begin
          if not MatchEndTag then
            Error('Expected end tag');
          AppendOutput(GetVar(lVarName));
        end;
      end;
    end
    else
    begin
      // output verbatim
      if not lIgnoreOutput then
        AppendOutput(lChar);
      Inc(FCharIndex);
    end;
  end;
end;

procedure TRTFReportEngine.SetVar(const AName: string; AValue: string);
begin
  FVariables.AddOrSetValue(AName, AValue);
end;

function CapitalizeString(const s: string;
  const CapitalizeFirst: Boolean): string;
const
  ALLOWEDCHARS = ['a' .. 'z', '_'];
var
  Index: Integer;
  bCapitalizeNext: Boolean;
begin
  bCapitalizeNext := CapitalizeFirst;
  Result := lowercase(s);
  if Result <> EmptyStr then
    for Index := 1 to Length(Result) do
      if bCapitalizeNext then
      begin
        Result[Index] := UpCase(Result[Index]);
        bCapitalizeNext := False;
      end
      else
        if NOT CharInSet(Result[Index], ALLOWEDCHARS) then
        bCapitalizeNext := True;
end;

procedure TRTFReportEngine.Error(const Message: String);
begin
  raise EParserException.CreateFmt('%s - at line %d col %d',
    [Message, FCurrentLine, FCurrentColumn]);
end;

function TRTFReportEngine.ExecuteFunction(AFunctionName, AValue: String): String;
begin
  AFunctionName := lowercase(AFunctionName);
  if AFunctionName = 'upper' then
    Exit(UpperCase(AValue));
  if AFunctionName = 'lower' then
    Exit(lowercase(AValue));
  if AFunctionName = 'capitalize' then
    Exit(CapitalizeString(AValue, True));
  raise EParserException.CreateFmt('Unknown function [%s]', [AFunctionName]);
end;

{ TRTFLoopControl }

class function TRTFLoopControl.Create(aIdentifier, aSymbolToConsumeAtEachIteration: String)
  : TRTFLoopControl;
begin
  Result.Identifier := aIdentifier;
  Result.SymbolToConsumeAtEachIteration := aSymbolToConsumeAtEachIteration;
end;

end.
