public class PSRecordPaymentFormController {
    @AuraEnabled
    public static String getRecordDetails(String params)
    {
        Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);
        String recId = paramMap.get('recordId');
        String amountField = paramMap.get('amountField');
        String contactField = paramMap.get('contactField');

        try
        {
            Id myId = Id.valueOf(recId);
            String sObjName = myId.getSObjectType().getDescribe().getName();
            String soql = 'SELECT ' + amountField + ',' + contactField + ' FROM ' + sObjName + ' WHERE ID = \'' + recId + '\'';

            List<sObject> sobjList = Database.query(soql);
            
            if (sobjList != null && sobjList.size() == 1)
            {
                Map<String, Object> returnMap = new Map<String, Object>();
                returnMap.put('amount', sobjList[0].get(amountField));
                returnMap.put('contactId', sobjList[0].get(contactField));
                return JSON.serializePretty(returnMap);
            }
            else {
                return null;
            }
        }
        catch (Exception e)
        {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }

    }

     @AuraEnabled
    public static void savePayment(String params)
    {
        Map<String, String> paramMap = (Map<String, String>)JSON.deserialize(params,   Map<String, String>.class);
        String recId = paramMap.get('recordId');

/*
{
   "recordId":"a0K46000001qbesEAA",
   "amount":33,
   "statusField":"PaymentStatus__c",
   "successValue":"Accepted",
   "failValue":"Rejected",
   "status":"Success",
   "transId":"123456",
   "transMsg":"All good",
   "paymentObjectName":"Payment__c",
   "paymentParentField":"TestParent__c",
   "paymentStatusField":"Status__c",
   "paymentTransIdField":"Transaction_ID__c",
   "paymentTransMsgField":"Transaction_Msg__c"
}
*/
        try
        {
           String status = paramMap.get('status');

           Id myId = Id.valueOf(recId);
           String recObjName = myId.getSObjectType().getDescribe().getName();
           sObject rec = Schema.getGlobalDescribe().get(recObjName).newSObject();
           rec.Id = recId;

           if (status == 'Success')
           {
             rec.put(paramMap.get('statusField'), paramMap.get('successValue'));
           }
           else {
             rec.put(paramMap.get('statusField'), paramMap.get('failValue'));
           }
           update rec;

           // create payment object
           sObject payment = Schema.getGlobalDescribe().get(paramMap.get('paymentObjectName')).newSObject();
           payment.put(paramMap.get('paymentParentField'), recId);
           payment.put(paramMap.get('paymentStatusField'), paramMap.get('status'));
           payment.put(paramMap.get('paymentTransIdField'), paramMap.get('transId'));
           payment.put(paramMap.get('paymentTransMsgField'), paramMap.get('transMsg'));
           payment.put(paramMap.get('paymentAmountField'), Decimal.valueOf(paramMap.get('amount')));
           insert payment;
        }
        catch (Exception e)
        {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

}