({
    doInit: function(component, event, helper) {
        console.log('doInit fired...');
        helper.getPaymentAccounts(component);
    },
    paymentTypeSelect: function(component, event, helper) {
        console.log('paymentTypeSelect fired...');
        var val = component.find("paymentTypeSelect").get("v.value");
        component.set("v.paymentType", val);

        helper.setNicknames(component);
    },
    nicknameSelect: function(component, event, helper) {
        console.log('nicknameSelect fired...');
        var val = component.find("nicknameSelect").get("v.value");
        component.set("v.nickname", val);
        console.log('nickname=' + val);

        helper.setPaymentValues(component);
    },
    btnAccept: function(component, event, helper) {
        console.log('btnAccept fired...');
        var paymentType = component.get("v.paymentType");
        var error = false;

        if (paymentType == "Bank Account") {
            if (component.get("v.acctHolderName") == null || component.get("v.acctHolderName").length == 0 || 
                component.get("v.acctNumber") == null || component.get("v.acctNumber").length == 0 || 
                component.get("v.acctRouting") == null || component.get("v.acctRouting").length == 0) {
                error = true;
            }
        } else if (paymentType == "Credit Card") {
            if (component.get("v.ccNameOnCard") == null || component.get("v.ccNameOnCard").length == 0 || 
                component.get("v.ccNumber") == null || component.get("v.ccNumber").length == 0 || 
                component.get("v.ccExpDate") == null || component.get("v.ccExpDate").length == 0 || 
                component.get("v.ccSecurityCode") == null || component.get("v.ccSecurityCode").length == 0) {
                error = true;
            }
        }

        if (error) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": "Please fill out all required fields.",
                "duration": 2000,
                "type": "warning"
            });
            toastEvent.fire();
        }
        else
        {
            helper.makePayment(component);
        }
    },
    btnCancel: function(component, event, helper) {
        console.log('btnCancel fired...');
        
        var compEvent = component.getEvent("paymentEvent");
        compEvent.setParams({"status" : "Cancel" });
        compEvent.fire();
    }
})