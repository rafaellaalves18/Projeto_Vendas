unit Vendas.Core.Exceptions;

interface

uses
  System.SysUtils;

type
  EVendasCoreException = class(Exception);
  EVendasValidationException = class(EVendasCoreException);

implementation

end.
