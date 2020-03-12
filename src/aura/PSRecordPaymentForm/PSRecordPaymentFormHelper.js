({
  getRecordDetails: function (component) {
    var self = this;
    var map = {};

    try {
      map['recordId'] = component.get ('v.recordId');
      map['amountField'] = component.get ('v.amountField');
      map['contactField'] = component.get ('v.contactField');

      console.log ('paramMap=' + JSON.stringify (map));

      var action = component.get ('c.getRecordDetails');
      action.setParams ({
        params: JSON.stringify (map),
      });

      action.setCallback (self, function (a) {
        console.log ('return value=' + a.getReturnValue ());
        var state = a.getState ();
        if (state === 'SUCCESS') {
          var resp = JSON.parse (a.getReturnValue ());
          component.set ('v.contactId', resp.contactId);
          component.set ('v.amount', resp.amount);
        } else {
          self.handleErrors (component, a.getError ());
        }
      });
      // Enqueue the action
      $A.enqueueAction (action);
    } catch (err) {
      self.handleErrors (component, err.message);
    }
  },
  savePayment: function (component, status, transId, transMsg) {
    var self = this;
    var map = {};

    try {
      map['recordId'] = component.get ('v.recordId');
      map['amount'] = component.get ('v.amount');
      map['statusField'] = component.get ('v.statusField');
      map['successValue'] = component.get ('v.successValue');
      map['failValue'] = component.get ('v.failValue');
      map['status'] = status;
      map['transId'] = transId;
      map['transMsg'] = transMsg;
      map['paymentObjectName'] = component.get ('v.paymentObjectName');
      map['paymentParentField'] = component.get ('v.paymentParentField');
      map['paymentStatusField'] = component.get ('v.paymentStatusField');
      map['paymentTransIdField'] = component.get ('v.paymentTransIdField');
      map['paymentTransMsgField'] = component.get ('v.paymentTransMsgField');
      map['paymentAmountField'] = component.get ('v.paymentAmountField');

      console.log ('paramMap=' + JSON.stringify (map));

      var action = component.get ('c.savePayment');
      action.setParams ({
        params: JSON.stringify (map),
      });

      action.setCallback (self, function (a) {
        console.log ('return value=' + a.getReturnValue ());
        console.log ('state=' + a.getState ());
        var state = a.getState ();
        if (state === 'SUCCESS') {
          //var resp = JSON.parse (a.getReturnValue ());


          if (component.get ('v.showFinalMsg') == true) {
            component.set ('v.finalMsgScreen', true);
          } else {
            $A.get ('e.force:closeQuickAction').fire ();
            $A.get ('e.force:refreshView').fire ();
            
            var toastEvent = $A.get ('e.force:showToast');
            toastEvent.setParams ({
              title: 'Success!',
              message: 'Payment of $' +
                component.get ('v.amount') +
                ' has been applied!',
              type: 'success',
            });
            toastEvent.fire ();
          }
        } else {
          self.handleErrors (component, a.getError ());
        }
      });
      // Enqueue the action
      $A.enqueueAction (action);
    } catch (err) {
      self.handleErrors (component, err.message);
    }
  },
  handleErrors: function (component, errors) {
    // Configure error toast
    let toastParams = {
      title: 'Error!',
      message: 'Unknown error', // Default error message
      type: 'error',
      mode: 'sticky',
    };
    // Pass the error message if any
    if (errors && Array.isArray (errors) && errors.length > 0) {
      toastParams.message = errors[0].message;
    } else {
      toastParams.message = errors;
    }
    // Fire error toast
    let toastEvent = $A.get ('e.force:showToast');
    toastEvent.setParams (toastParams);
    toastEvent.fire ();
  },
});