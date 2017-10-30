public without sharing class PSPaymentFormController
{
  public PSPaymentFormController()
  {

  }

  @AuraEnabled
  public static String getUserAccountId()
  {
    System.debug('getUserAccountId invoked...');

    User u = [SELECT Id, Contact.Account.Id FROM User WHERE Id = :UserInfo.getUserId()];

    return u.Contact.Account.Id;
  }

  @AuraEnabled
  public static List<Payment_Account__c> getPaymentAccounts()
  {
    System.debug('getPaymentAccounts invoked...');

    User u = [SELECT Id, ContactId, Contact.Account.Id FROM User WHERE Id = :UserInfo.getUserId()];

    List<Payment_Account__c> l = [SELECT Id, RecordType.Name, Account_Nickname__c, Account_Holder_Name__c, Account_Number__c,
                                  Card_Number__c, Expiration_Date__c, Name_on_Card__c, Routing_Number__c,
                                  Security_Code__c, Type__c
                                  FROM Payment_Account__c
                                  WHERE Contact__c = :u.ContactId];

    return l;
  }

  @AuraEnabled
  public static String makePayment(String params)
  {
    System.debug('makePayment invoked...');
    Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);

    PSResponse resp = new PSResponse();

    try
    {
      ////////////////////////////////
      // update tax payment records //
      ////////////////////////////////
      User u = [SELECT Id, Contact.Id, Contact.Account.Id FROM User WHERE Id = :UserInfo.getUserId()];

      Contact c = [SELECT Id, FirstName, LastName, Phone, MobilePhone, Email, Account.Name, Account.AccountNumber, Account.Phone, Account.Email__c,
                   Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry
                   FROM Contact
                   WHERE Id = :u.Contact.Id];


        PSAuthorizeDotNet.PSCreateTransactionRequest req = new PSAuthorizeDotNet.PSCreateTransactionRequest();
        req.createTransactionRequest.refId = c.Id;
        req.createTransactionRequest.setTransactionRequest(Integer.valueOf(paramMap.get('amount')), '');
        req.createTransactionRequest.setCustomer('business', PSDemoUtils.n2s(c.Account.AccountNumber), PSDemoUtils.n2s(c.email));
        req.createTransactionRequest.setBillTo(PSDemoUtils.n2s(c.FirstName), PSDemoUtils.n2s(c.LastName), PSDemoUtils.n2s(c.Account.Name), PSDemoUtils.n2s(c.Account.BillingStreet), 
                                               PSDemoUtils.n2s(c.Account.BillingCity), PSDemoUtils.n2s(c.Account.BillingState), 
                                               PSDemoUtils.n2s(c.Account.BillingPostalCode), PSDemoUtils.n2s(c.Account.BillingCountry), 
                                               PSDemoUtils.n2s(c.Account.Phone), PSDemoUtils.n2s(c.Account.Email__c));

        AuthorizeDotNet__c cs = AuthorizeDotNet__c.getOrgDefaults();
        req.createTransactionRequest.setMerchantAuthentication(cs.Login__c, cs.Transaction_Key__c);

        String paymentType = paramMap.get('paymentType');
        if (paymentType == 'Bank Account')
        {
          req.createTransactionRequest.setBankAccount('checking', paramMap.get('acctRouting'), paramMap.get('acctNumber'), paramMap.get('acctHolderName'));
        }
        else if (paymentType == 'Credit Card')
        {
          req.createTransactionRequest.setCreditCard(paramMap.get('ccNumber'), paramMap.get('ccExpDate'), paramMap.get('ccSecurityCode'));
        }

        PSAuthorizeDotNet adn = new PSAuthorizeDotNet(true);
        PSAuthorizeDotNet.PSTransactionResponse payResp = adn.process(req, 1);
        if (payResp.transactionResponse.responseCode != 1)
        {
          resp.status = PSResponse.ERROR;
          resp.msg = payResp.getErrorMessage();
        }
        else
        {
            Map<String, Object>respMap = new Map<String, Object>();
            respMap.put('transactionId', payResp.transactionResponse.transId);
            respMap.put('transactionMsg', payResp.getMessage());
            
            resp.data = respMap;
        }
     

    }
    catch (Exception e)
    {
      resp.status = PSResponse.ERROR;
      resp.msg = e.getMessage();
    }

    return  JSON.serialize(resp);
  }
}