({
	getLicenseItems: function(component, licenseType) {
        console.log("getLicenseItems invoked...");
        var action = component.get("c.getLicenseItems");
        action.setParams({
            "licenseType": licenseType
        });

        var self = this;
        action.setCallback(this, function(actionResult) {
            console.log("received result...");
            console.log("result=" + JSON.stringify(actionResult.getReturnValue()));

            // inject a selected attribute in the result
            var licItemList = actionResult.getReturnValue();
            for (var i=0; i<licItemList.length; i++)
            {
               licItemList[i]['selected'] = false;
            }
            console.log("adjusted=" + JSON.stringify(licItemList));
 
            component.set("v.licenseItemList", licItemList);
        });
        $A.enqueueAction(action);
    }
})