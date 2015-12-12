unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Menus;

type
  TForm1 = class(TForm)
    hkVolumeUp: THotKey;
    hkVolumeDown: THotKey;
    lblVolumeUp: TLabel;
    lblVolumeDown: TLabel;
    trycn1: TTrayIcon;
    pm1: TPopupMenu;
    S1: TMenuItem;
    E1: TMenuItem;
    hkVolumeMute: THotKey;
    lblVolumeMute: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure E1Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure trycn1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    configUrl: string;
    atomHandle: ATOM;
    atomHotkeyVolumeUp: ATOM;
    atomHotkeyVolumeDown: ATOM;
    atomHotkeyVolumeMute: ATOM;
    // atomHotkeyVolumeUp: ATOM;
    // atomHotkeyVolumeUp: ATOM;
    // atomHotkeyVolumeUp: ATOM;
    hotkeyList: TStrings;
    procedure deleteHotkey(id: ATOM);
    function registerHotkey(hotkey: THotKey; id: ATOM): Boolean;
    procedure hotkeyProcess(var msg: TMessage); message WM_HOTKEY;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure ShortCutToKey(ShortCut: TShortCut; var Key: Word;
  var Shift: TShiftState);
begin
  Key := ShortCut and not(scShift + scCtrl + scAlt);
  Shift := [];
  if ShortCut and scShift <> 0 then
    Include(Shift, ssShift);
  if ShortCut and scCtrl <> 0 then
    Include(Shift, ssCtrl);
  if ShortCut and scAlt <> 0 then
    Include(Shift, ssAlt);
end;

function ShiftStateToWord(TShift: TShiftState): Word;
begin
  Result := 0;
  if ssShift in TShift then
    Result := MOD_SHIFT;
  if ssCtrl in TShift then
    Result := Result or MOD_CONTROL;
  if ssAlt in TShift then
    Result := Result or MOD_ALT;
end;

procedure TForm1.hotkeyProcess(var msg: TMessage);
  function isHotkey(hotkey: THotKey): Boolean;
  var
    T: TShiftState;
    Key: Word;
    Shift: Word;
  begin
    ShortCutToKey(hotkey.hotkey, Key, T);
    Shift := ShiftStateToWord(T);
    Result := (msg.LparamLo = Shift) AND (msg.LParamHi = Key)
  end;

var
  vk: Byte;
begin
  if isHotkey(hkVolumeUp) then
    vk := VK_VOLUME_UP
    // vk := VK_HOME
  else if isHotkey(hkVolumeDown) then
    vk := VK_VOLUME_DOWN
  else if isHotkey(hkVolumeMute) then
    vk := VK_VOLUME_MUTE;

  keybd_event(vk, 0, 0, 0);
  keybd_event(vk, 0, KEYEVENTF_KEYUP, 0);;
end;

procedure TForm1.deleteHotkey(id: Word);
begin
  UnregisterHotKey(Self.Handle, id);
end;

function TForm1.registerHotkey(hotkey: THotKey; id: ATOM): Boolean;
var
  T: TShiftState;
  Key, Shift: Word;
begin
  ShortCutToKey(hotkey.hotkey, Key, T);
  Shift := ShiftStateToWord(T);
  Result := Winapi.Windows.registerHotkey(Self.Handle, id, Shift, Key);
end;

procedure TForm1.E1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
// 提示信息
  procedure hotkeyAlreadyRegister(hotkey: THotKey; var status: Boolean);
  begin
    if hotkey.hotkey <> 0 then
    begin
      status := False;
      Application.MessageBox(PChar(ShortCutToText(hotkey.hotkey) +
        '已经被使用，请重新设置'), '提示', MB_OK + MB_ICONINFORMATION);
    end;
  end;
// 保存按键信息
  procedure saveHotkey(hotkey: THotKey);
  begin
    hotkeyList.Add(hotkey.Name + '=' + IntToStr(hotkey.hotkey))
  end;

var
  okay: Boolean;
begin
  Action := TCloseAction.caNone;
  // 保存快捷键
  // 删除原快捷键
  deleteHotkey(atomHotkeyVolumeUp);
  deleteHotkey(atomHotkeyVolumeDown);
  deleteHotkey(atomHotkeyVolumeMute);
  // 注册新快捷键
  okay := True;
  if not registerHotkey(hkVolumeUp, atomHotkeyVolumeUp) then
    hotkeyAlreadyRegister(hkVolumeUp, okay);

  if not registerHotkey(hkVolumeDown, atomHotkeyVolumeDown) then
    hotkeyAlreadyRegister(hkVolumeDown, okay);

  if not registerHotkey(hkVolumeMute, atomHotkeyVolumeMute) then
    hotkeyAlreadyRegister(hkVolumeMute, okay);

  if okay then
  begin
    hotkeyList.Clear;
    saveHotkey(hkVolumeUp);
    saveHotkey(hkVolumeDown);
    saveHotkey(hkVolumeMute);
    hotkeyList.SaveToFile(configUrl);
    Self.Hide;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  atomString = 'VolumeChanger';
var
  index: Integer;
  i: Integer;
  controlName: string;
  baseUrl: string;
begin
  if FindAtom(atomString) = 0 then
  begin
    atomHandle := GlobalAddAtom(atomString);
    atomHotkeyVolumeUp := GlobalAddAtom('hkVolumeUp') - $C000;
    atomHotkeyVolumeDown := GlobalAddAtom('hkVolumeDown') - $C000;
    atomHotkeyVolumeMute := GlobalAddAtom('hkVolumeMute') - $C000;
    baseUrl := GetEnvironmentVariable('localappdata') + '/VolumeChanger';
    configUrl := baseUrl + '/config.json';

    hotkeyList := TStringList.Create;
    if FileExists(configUrl) then
    begin
      // 加载保存信息
      hotkeyList.LoadFromFile(configUrl);
      for index := 0 to hotkeyList.Count - 1 do
      begin
        controlName := hotkeyList.Names[index];
        for i := 0 to Self.Componentcount - 1 do
        // Self.Componentcount就是TForm1的控件数量
        begin
          if Self.Components[i].Name = controlName then
          begin
            // ShowMessage(Self.Components[i].Name);
            (Self.Components[i] as THotKey).hotkey :=
              StrToInt(hotkeyList.Values[controlName]);
          end;
        end;
      end;

      Application.ShowMainForm := False;
      Self.Close;
    end
    else if not FileExists(baseUrl) then
    begin
      CreateDir(baseUrl);
    end;
    Exit;
  end;
  // 重复运行
  Application.Terminate;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  GlobalDeleteAtom(atomHandle);
  GlobalDeleteAtom(atomHotkeyVolumeUp);
  GlobalDeleteAtom(atomHotkeyVolumeDown);
  GlobalDeleteAtom(atomHotkeyVolumeMute);
end;

procedure TForm1.S1Click(Sender: TObject);
begin
  Self.Show;
end;

procedure TForm1.trycn1DblClick(Sender: TObject);
begin
  Self.Show;
end;

end.
