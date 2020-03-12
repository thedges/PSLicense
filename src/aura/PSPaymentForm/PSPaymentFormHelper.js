({
    getPaymentAccounts: function(component) {
        console.log('getPaymentAccounts started...');
        var action = component.get("c.getPaymentAccounts");
        action.setParams({
            "contactId": component.get('v.contactId')
        });
        var self = this;
        action.setCallback(this, function(a) {
            console.log('query callback!');
            console.log('paymentAccounts=' + JSON.stringify(a.getReturnValue()));
            component.set("v.acctPaymentList", a.getReturnValue());
            self.setNicknames(component);
        });
        $A.enqueueAction(action);
    },
    setNicknames: function(component) {
        console.log('setNicknames started...');
        var apList = component.get("v.acctPaymentList");
        var paymentType = component.get("v.paymentType");
        component.set('v.acctHolderName', '');
        component.set('v.acctNumber', '');
        component.set('v.acctRouting', '');
        component.set('v.ccNameOnCard', '');
        component.set('v.ccNumber', '');
        component.set('v.ccExpDate', '');
        component.set('v.ccSecurityCode', '');
        console.log('apList=' + JSON.stringify(apList));
        var nnArr = [];
        nnArr.push('');
        var i;
        for (i = 0; i < apList.length; i++) {
            console.log('item=' + JSON.stringify(apList[i]));
            if (paymentType == 'Bank Account' && apList[i].RecordType.Name == 'Bank Account') {
                nnArr.push(apList[i].Account_Nickname__c);
            } else if (paymentType == 'Credit Card' && apList[i].RecordType.Name == 'Credit Card') {
                nnArr.push(apList[i].Account_Nickname__c);
            }
        }
        console.log(JSON.stringify(nnArr));
        component.set("v.nicknameList", nnArr);
    },
    setPaymentValues: function(component) {
        console.log('setPaymentValues started...');
        var apList = component.get("v.acctPaymentList");
        var paymentType = component.get("v.paymentType");
        var nickname = component.get("v.nickname");
        for (var i = 0; i < apList.length; i++) {
            if (paymentType == 'Bank Account' && apList[i].RecordType.Name == 'Bank Account' && nickname == apList[i].Account_Nickname__c) {
                component.set('v.acctHolderName', apList[i].Account_Holder_Name__c);
                component.set('v.acctNumber', apList[i].Account_Number__c);
                component.set('v.acctRouting', apList[i].Routing_Number__c);
                break;
            } else if (paymentType == 'Credit Card' && apList[i].RecordType.Name == 'Credit Card' && nickname == apList[i].Account_Nickname__c) {
                console.log('inside credit card logic...');
                console.log('setting Name_on_Card__c=' + apList[i].Name_on_Card__c);
                component.set('v.ccNameOnCard', apList[i].Name_on_Card__c);
                console.log('ccNameOnCard.1=' + component.get('v.ccNameOnCard'));
                component.set('v.ccNumber', apList[i].Card_Number__c);
                component.set('v.ccExpDate', apList[i].Expiration_Date__c);
                component.set('v.ccSecurityCode', apList[i].Security_Code__c);
                break;
            } else {
                console.log('inside clear values...');
                component.set('v.acctHolderName', '');
                component.set('v.acctNumber', '');
                component.set('v.acctRouting', '');
                component.set('v.ccNameOnCard', '');
                component.set('v.ccNumber', '');
                component.set('v.ccExpDate', '');
                component.set('v.ccSecurityCode', '');
            }
        }
        console.log('ccNameOnCard.2=' + component.get('v.ccNameOnCard'));
    },
    makePayment: function(component) {
        var self = this;
        console.log('makePayment invoked...');

        var paramMap = {};
        var paymentType = component.get('v.paymentType');
        paramMap['paymentType'] = paymentType;
        paramMap['amount'] = component.get('v.amount');
        paramMap['mockPayment'] = component.get('v.mockPayment');

        if (paymentType == 'Bank Account') {
            paramMap['acctHolderName'] = component.get('v.acctHolderName');
            paramMap['acctNumber'] = component.get('v.acctNumber');
            paramMap['acctRouting'] = component.get('v.acctRouting');
        } else if (paymentType == 'Credit Card') {
            paramMap['ccNameOnCard'] = component.get('v.ccNameOnCard');
            paramMap['ccNumber'] = component.get('v.ccNumber');
            paramMap['ccExpDate'] = component.get('v.ccExpDate');
            paramMap['ccSecurityCode'] = component.get('v.ccSecurityCode');
        }
        console.log('makePayment params = ' + JSON.stringify(paramMap));
        var action = component.get("c.makePayment");
        action.setParams({
            "params": JSON.stringify(paramMap)
        });
        action.setCallback(self, function(a) {
            console.log(a.getReturnValue());
            var resp = JSON.parse(a.getReturnValue());
            if (resp.status === 'ERROR') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resp.msg,
                    "mode": "sticky",
                    "type": "error"
                });
                toastEvent.fire();
            } else {
                //$A.get('e.force:refreshView').fire();
                var compEvent = component.getEvent("paymentEvent");
                compEvent.setParams({ "status": "Success", "transactionId": resp.data.transactionId, "transactionMsg": resp.data.transactionMsg });
                compEvent.fire();
            }
        });
        // Enqueue the action
        $A.enqueueAction(action);
    }
})