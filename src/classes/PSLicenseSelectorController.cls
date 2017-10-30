public with sharing class PSLicenseSelectorController
{
  public PSLicenseSelectorController()
  {

  }

   @AuraEnabled
  public static List<PSLicenseItem__c> getLicenseItems()
  {
    List<PSLicenseItem__c> itemList = [SELECT Id, Name__c, Description__c, Fee__c, Term__c, UOM__c FROM PSLicenseItem__c  ORDER BY createddate ASC];
    return itemList;
  }

  @AuraEnabled
  public static String storeLicenses(String params)
  {
  	System.debug('storeLicenses invoked...');
    Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);
    PSResponse resp = new PSResponse();

    try
    {
       List<String> licenseIds = (List<String>)JSON.deserialize(paramMap.get('licenseIds'),  List<String>.class);

       User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

       List<PSLicenseItem__c> licItemList = [SELECT Id, Name__c, Fee__c, Term__c, UOM__c FROM PSLicenseItem__c WHERE Id IN :licenseIds];

       Date currDate = Date.today();

       PSPayment__c pmt = new PSPayment__c();
       pmt.Status__c = 'Paid';
       pmt.Amount__c = Decimal.valueOf(paramMap.get('amount'));
       pmt.Type__c = paramMap.get('type');
       pmt.Sub_Type__c = paramMap.get('subtype');
       pmt.Transaction_Date__c = currDate;
       pmt.Transaction_ID__c = paramMap.get('transactionId');
       pmt.Transaction_Message__c = paramMap.get('transactionMsg');
       insert pmt;

       List<PSLicense__c> licList = new List<PSLicense__c>();
       for (PSLicenseItem__c tmpLic : licItemList)
       {
        
         PSLicense__c lic = new PSLicense__c();
         lic.Payment__c = pmt.Id;
         lic.Contact__c = u.ContactId;
         lic.License_Item__c = tmpLic.Id;
         lic.Status__c = 'Valid';

       
         System.debug('UOM=' + tmpLic.UOM__c);
         if (tmpLic.UOM__c == 'Year')
         {
           lic.Expires__c = currDate.addYears((Integer)tmpLic.Term__c);
           System.debug('nextYear=' + lic.Expires__c);
         }
         else if (tmpLic.UOM__c == 'Month')
         {
          lic.Expires__c = currDate.addMonths((Integer)tmpLic.Term__c);
           System.debug('nextMonth=' + lic.Expires__c);
         }
         else {
           lic.Expires__c = currDate.addDays((Integer)tmpLic.Term__c);
           System.debug('nextDay=' + lic.Expires__c);
         }

         licList.add(lic);
         
       }

       if (licList.size() > 0) insert licList;
      
    }
    catch (exception e)
    {
      resp.status = PSResponse.ERROR;
      resp.msg = e.getMessage();
    }
    
    return  JSON.serialize(resp);
  }
}