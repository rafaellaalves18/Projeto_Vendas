object frmCadastroProduto: TfrmCadastroProduto
  Left = 0
  Top = 0
  Caption = 'Cadastro de Produtos'
  ClientHeight = 340
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 20
      Width = 180
      Height = 21
      Caption = 'Cadastro de Produtos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlCampos: TPanel
    Left = 0
    Top = 64
    Width = 720
    Height = 212
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object lblCodigo: TLabel
      Left = 24
      Top = 20
      Width = 42
      Height = 15
      Caption = 'Codigo'
    end
    object lblDescricao: TLabel
      Left = 144
      Top = 20
      Width = 55
      Height = 15
      Caption = 'Descricao'
    end
    object lblPrecoVenda: TLabel
      Left = 24
      Top = 78
      Width = 78
      Height = 15
      Caption = 'Preco Venda'
    end
    object edtCodigo: TEdit
      Left = 24
      Top = 40
      Width = 96
      Height = 23
      TabOrder = 0
      OnExit = edtCodigoExit
      OnKeyPress = edtCodigoKeyPress
    end
    object edtDescricao: TEdit
      Left = 144
      Top = 40
      Width = 536
      Height = 23
      TabOrder = 1
    end
    object edtPrecoVenda: TEdit
      Left = 24
      Top = 98
      Width = 160
      Height = 23
      TabOrder = 2
      OnExit = edtPrecoVendaExit
      OnKeyPress = edtPrecoVendaKeyPress
    end
    object chkAtivo: TCheckBox
      Left = 208
      Top = 101
      Width = 97
      Height = 17
      Caption = 'Ativo'
      TabOrder = 3
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 276
    Width = 720
    Height = 64
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnNovo: TButton
      Left = 272
      Top = 16
      Width = 96
      Height = 30
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 376
      Top = 16
      Width = 96
      Height = 30
      Caption = 'Salvar'
      Default = True
      TabOrder = 1
      OnClick = btnSalvarClick
    end
    object btnExcluir: TButton
      Left = 480
      Top = 16
      Width = 96
      Height = 30
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnSair: TButton
      Left = 584
      Top = 16
      Width = 96
      Height = 30
      Cancel = True
      Caption = 'Sair'
      TabOrder = 3
      OnClick = btnSairClick
    end
  end
end
