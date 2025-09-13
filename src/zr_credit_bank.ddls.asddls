@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@ObjectModel.sapObjectNodeType.name: 'ZCREDIT_BANK'
define root view entity ZR_CREDIT_BANK
  as select from ZCREDIT_BANK
{
  key credit_no as CreditNo,
  start_year as StartYear,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  credit_sum as CreditSum,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  monthly_repay_rate as MonthlyRepayRate,
  tribute as Tribute,
  state as State,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency_code as CurrencyCode,
  borrower as Borrower,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.user.lastChangedBy: true
  changed_by as ChangedBy
  
}
