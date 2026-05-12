unit Vendas.Application.Interfaces.Repositories;

interface

uses
  Vendas.Core.Entities.Cliente,
  Vendas.Core.Entities.Produto,
  Vendas.Core.Entities.PedidoVenda;

type
  IClienteRepository = interface
    ['{E918406C-4A42-43FA-9AD2-960E2338111D}']
    function ObterPorId(const AId: Integer): TCliente;
    function ProximoCodigo: Integer;
    procedure Excluir(const AId: Integer);
    procedure Salvar(const ACliente: TCliente);
  end;

  IProdutoRepository = interface
    ['{58C81B4C-D8D0-488E-8B80-340613842F0B}']
    function ObterPorId(const AId: Integer): TProduto;
    function ProximoCodigo: Integer;
    procedure Excluir(const AId: Integer);
    procedure Salvar(const AProduto: TProduto);
  end;

  IPedidoVendaRepository = interface
    ['{1282F1B2-23D7-40BA-B38C-C33C266FEF07}']
    function ObterPorId(const AId: Integer): TPedidoVenda;
    function ProximoCodigo: Integer;
    procedure Excluir(const AId: Integer);
    procedure Salvar(const APedido: TPedidoVenda);
  end;

implementation

end.
