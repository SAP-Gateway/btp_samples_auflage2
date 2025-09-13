@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.sapObjectNodeType.name: 'ZCREDIT_BANK'
define root view entity ZC_CREDIT_BANK
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_CREDIT_BANK
{
  key CreditNo,
  StartYear,
  CreditSum,
  MonthlyRepayRate,
  Tribute,
  State,
  @Semantics.currencyCode: true
  CurrencyCode,
  Borrower,
  LocalLastChanged,
  LastChanged,
  CreatedBy,
  ChangedBy
  
}
