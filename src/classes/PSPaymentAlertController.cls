public class PSPaymentAlertController
{
  public PSPaymentAlertController()
  {

  }

  @AuraEnabled
  public static Map<String, String> getTaxDue()
  {
    System.debug('getTaxDue invoked...');

    Map<String, String> ret = new Map<String, String>();
    ret.put('amount', '0');
    ret.put('dueDate', '');


    User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

    List<Permit__c> pList = [SELECT Id, Permit_Fee__c, Permit_Application_Date__c
                                     FROM Permit__c
                                    WHERE Contact__c = :u.ContactId AND Status__c = 'Approved'
                                    ORDER BY Permit_Application_Date__c ASC];



    if (pList != null && pList.size() > 0)
    {
       Integer amount = 0;
       for (Permit__c p : pList)
       {
          amount += p.Permit_Fee__c.intValue();
       }
       ret.put('amount', '' + amount);
       //ret.put('dueDate', DateTime.newInstance(pList[0].Due_Date__c.year(), pList[0].Due_Date__c.month(), pList[0].Due_Date__c.day()).format('YYYY-MM-dd'));
    }

    return ret;
  }

}