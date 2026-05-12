unit Financeiro.Core.Exceptions;

interface

uses
  System.SysUtils;

type
  EFinanceiroCoreException = class(Exception);
  EFinanceiroValidationException = class(EFinanceiroCoreException);

implementation

end.
