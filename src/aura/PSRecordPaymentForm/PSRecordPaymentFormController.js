({
    doInit : function(component, event, helper) {
        console.log('doInit fired...');
        helper.getRecordDetails(component);
    },
    handlePaymentEvent: function(component, event, helper) {
        console.log('handlePaymentEvent...');

        var status = event.getParam("status");
        if (status == "Cancel") {
            //component.set("v.phase", "selection");
        } else if (status == "Success") {
            console.log("transactionId=" + event.getParam("transactionId"));
            console.log("transactionMsg=" + event.getParam("transactionMsg"));

            helper.savePayment(component, 'Success', event.getParam("transactionId"), event.getParam("transactionMsg"));
        }
    }
})