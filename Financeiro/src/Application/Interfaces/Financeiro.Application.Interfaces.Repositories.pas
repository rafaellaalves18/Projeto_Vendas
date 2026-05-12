unit Financeiro.Application.Interfaces.Repositories;

interface

uses
  System.Generics.Collections,
  Shared.Core.Types,
  Financeiro.Core.Entities.ContaReceber;

type
  IContaReceberRepository = interface
    ['{B617DBD2-995A-4A23-8C1A-D45CA5E9C45E}']
    function ObterPorId(const AId: Integer): TContaReceber;
    function ObterPorOrigem(const AOrigem: TOrigemFinanceira;
      const AIdOrigem: Integer): TContaReceber;
    function PesquisarPorCliente(const AIdCliente: Integer;
      const ANomeCliente: string; const AApenasAbertas: Boolean): TObjectList<TContaReceber>;
    procedure Salvar(const AConta: TContaReceber);
  end;

implementation

end.
