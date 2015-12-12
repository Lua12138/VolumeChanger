object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 102
  ClientWidth = 251
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblVolumeUp: TLabel
    Left = 36
    Top = 14
    Width = 38
    Height = 13
    Caption = #38899#37327' + '
  end
  object lblVolumeDown: TLabel
    Left = 36
    Top = 39
    Width = 34
    Height = 13
    Caption = #38899#37327' - '
  end
  object lblVolumeMute: TLabel
    Left = 36
    Top = 64
    Width = 24
    Height = 13
    Caption = #38745#38899
  end
  object hkVolumeUp: THotKey
    Left = 80
    Top = 8
    Width = 121
    Height = 19
    HotKey = 0
    Modifiers = []
    TabOrder = 0
  end
  object hkVolumeDown: THotKey
    Left = 80
    Top = 33
    Width = 121
    Height = 19
    HotKey = 0
    Modifiers = []
    TabOrder = 1
  end
  object hkVolumeMute: THotKey
    Left = 80
    Top = 58
    Width = 121
    Height = 19
    HotKey = 0
    Modifiers = []
    TabOrder = 2
  end
  object trycn1: TTrayIcon
    PopupMenu = pm1
    Visible = True
    OnDblClick = trycn1DblClick
    Left = 168
    Top = 24
  end
  object pm1: TPopupMenu
    Left = 120
    Top = 48
    object S1: TMenuItem
      Caption = #26174#31034'(&S)'
      OnClick = S1Click
    end
    object E1: TMenuItem
      Caption = #36864#20986'(&E)'
      OnClick = E1Click
    end
  end
end
