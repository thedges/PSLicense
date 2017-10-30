({
    doInit: function(component, event, helper) {
        console.log('doInit...');
        helper.getLicenseItems(component, component.get("v.licenseType"));
    },
    itemsChange: function(component, event, helper) {
        console.log('itemsChange...');
    },
    handleLicenseSelectEvent: function(component, event, helper) {
        console.log('handleLicenseSelectEvent...');
        var licList = component.get("v.licenseItemList");
        var total = 0;
        for (var i = 0; i < licList.length; i++) {
            if (licList[i].Fee__c != null && licList[i].selected == true) total = total + licList[i].Fee__c;
        }
        component.set("v.total", total);
    },
    handlePaymentEvent: function(component, event, helper) {
        console.log('handlePaymentEvent...');
        var status = event.getParam("status");
        if (status == "Cancel") {
            component.set("v.phase", "selection");
        } else if (status == "Success") {
            console.log("transactionId=" + event.getParam("transactionId"));
            console.log("transactionMsg=" + event.getParam("transactionMsg"));

            var action = component.get("c.storeLicenses");

            /////////////////////////////////////////////////////////////
            // build list of licenses to store the transaction against //
            /////////////////////////////////////////////////////////////
            var licenseStoreList = [];
            var licenseItemList = component.get("v.licenseItemList");
            for (var i=0; i<licenseItemList.length; i++)
            {
               if (licenseItemList[i].Fee__c != null && licenseItemList[i].selected == true) licenseStoreList.push(licenseItemList[i].Id);
            }

            var paramMap = {};
            paramMap['licenseIds'] = JSON.stringify(licenseStoreList);
            paramMap['amount'] = component.get("v.total");;
            paramMap['type'] = "License";
            paramMap['subtype'] = component.get("v.licenseType");
            paramMap['transactionId'] = event.getParam("transactionId");
            paramMap['transactionMsg'] = event.getParam("transactionMsg");
            action.setParams({
                "params": JSON.stringify(paramMap)
            });

            var self = this;
            action.setCallback(this, function(actionResult) {
                console.log("received result...");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": component.get("v.landingPageURL")
                });
                urlEvent.fire();
            });
            $A.enqueueAction(action);
        }
    },
    nextClick: function(component, event, helper) {
        component.set("v.phase", "payment");
    },
    backClick: function(component, event, helper) {
        component.set("v.phase", "selection");
    }
})