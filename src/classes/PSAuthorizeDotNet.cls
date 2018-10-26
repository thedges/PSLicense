public class PSAuthorizeDotNet
{
  private static final string login = '7arC6JsW3U';
  private static final string transkey = '2kA9787kP3TV2pL2';

  private string url;
  private boolean isTest;

  public PSAuthorizeDotNet(boolean isTest)
  {
    //For setting sandbox or production
    this.isTest = isTest;
    if (this.isTest)
    {
      //this.url = 'https://test.authorize.net/gateway/transact.dll';
      this.url = 'https://apitest.authorize.net/xml/v1/request.api';
    }
    else
    {
      //this.url = 'https://secure.authorize.net/gateway/transact.dll';
      this.url = 'https://api.authorize.net/xml/v1/request.api';
    }

  }

  //Calls the Authorize.Net service and fetch the response
  public PSTransactionResponse process(PSCreateTransactionRequest req, integer retries)
  {
    System.debug('req=' + req.toJson());
    String resp;

    integer count = 0;
    while (count < retries)
    {
      HttpRequest hReq = new HttpRequest();
      hReq.setEndpoint(this.url);
      hReq.setMethod('POST');
      hReq.setHeader('Content-Type', 'application/json');
      //hReq.setBody(this.fields);
      //hReq.setBody(JSON.serializePretty(req, true));
      hReq.setBody(req.toJson());
      Http con = new Http();
      if (!Test.isRunningTest())
      {
        HttpResponse res = con.send(hReq);
        resp = res.getBody().trim().replace('\uFEFF', '');   // need replace to fix char parse issue
      }
      count++;
    }

    System.debug('http_resp=' + resp);

    if (resp != null)
    {
      PSTransactionResponse tr = (PSTransactionResponse)JSON.deserialize(resp, PSTransactionResponse.class);
      return tr;
    }
    return null;
  }


  public static void testRequest()
  {
    PSCreateTransactionRequest req = new PSCreateTransactionRequest();
    req.createTransactionRequest.refId = '123457';
    req.createTransactionRequest.setTransactionRequest(1, 'PO - 123242');
    req.createTransactionRequest.setBankAccount('checking', '314074269', '12345678' , 'John Doe');
    req.createTransactionRequest.setCustomer('business', '1234343' , 'ckay@gmail.com');
    req.createTransactionRequest.setBillTo('Curtis', 'Kay', 'LoLo\'s Chicken' , '123 Some Street', 'Some City','TX', '77101', '', '', '');
    req.createTransactionRequest.setMerchantAuthentication('68PecFxf5V', '2tRpUP86Xvn94c22');
    //req.customerIP = ApexPages.currentPage().getHeaders().get('X - Salesforce - SIP');

    System.debug('req = ' + req.toJson());

    PSAuthorizeDotNet adn = new PSAuthorizeDotNet(true);
    PSTransactionResponse resp = adn.process(req, 1);

    System.debug('resp=' + JSON.serializePretty(resp));

  }

  public class PSCreateTransactionRequest
  {
    public CreateTransactionRequest createTransactionRequest;

    public PSCreateTransactionRequest()
    {
      createTransactionRequest = new CreateTransactionRequest();
    }

    public String toJson()
    {
      JSONGenerator g = JSON.createGenerator(true);
      g.writeStartObject();
      g.writeFieldName('createTransactionRequest');

      g.writeStartObject();
      g.writeFieldName('merchantAuthentication');
      g.writeStartObject();
      g.writeStringField('name', createTransactionRequest.merchantAuthentication.name);
      g.writeStringField('transactionKey', createTransactionRequest.merchantAuthentication.transactionKey);
      g.writeEndObject();
      g.writeStringField('refId', createTransactionRequest.refId);

      g.writeFieldName('transactionRequest');
      g.writeStartObject();
      g.writeStringField('transactionType', createTransactionRequest.transactionRequest.transactionType);
      g.writeNumberField('amount', createTransactionRequest.transactionRequest.amount);

      g.writeFieldName('payment');
      g.writeStartObject();

      if (createTransactionRequest.transactionRequest.payment.creditCard != null)
      {
        g.writeFieldName('creditCard');
        g.writeStartObject();
        g.writeStringField('cardNumber', createTransactionRequest.transactionRequest.payment.creditCard.cardNumber);
        g.writeStringField('expirationDate', createTransactionRequest.transactionRequest.payment.creditCard.expirationDate);
        g.writeStringField('cardCode', createTransactionRequest.transactionRequest.payment.creditCard.cardCode);
        g.writeEndObject();
      }
      else if (createTransactionRequest.transactionRequest.payment.bankAccount != null)
      {
        g.writeFieldName('bankAccount');
        g.writeStartObject();
        g.writeStringField('accountType', createTransactionRequest.transactionRequest.payment.bankAccount.accountType);
        g.writeStringField('routingNumber', createTransactionRequest.transactionRequest.payment.bankAccount.routingNumber);
        g.writeStringField('accountNumber', createTransactionRequest.transactionRequest.payment.bankAccount.accountNumber);
        g.writeStringField('nameOnAccount', createTransactionRequest.transactionRequest.payment.bankAccount.nameOnAccount);
        g.writeEndObject();
      }

      g.writeEndObject();

      if (createTransactionRequest.transactionRequest.customer != null)
      {
        g.writeFieldName('customer');
        g.writeStartObject();
        g.writeStringField('type', createTransactionRequest.transactionRequest.customer.type);
        g.writeStringField('id', createTransactionRequest.transactionRequest.customer.id);
        g.writeStringField('email', createTransactionRequest.transactionRequest.customer.email);
        g.writeEndObject();

      }

      if (createTransactionRequest.transactionRequest.billTo != null)
      {
        g.writeFieldName('billTo');
        g.writeStartObject();
        g.writeStringField('firstName', createTransactionRequest.transactionRequest.billTo.firstName);
        g.writeStringField('lastName', createTransactionRequest.transactionRequest.billTo.lastName);
        g.writeStringField('company', createTransactionRequest.transactionRequest.billTo.company);
        g.writeStringField('address', createTransactionRequest.transactionRequest.billTo.address);
        g.writeStringField('city', createTransactionRequest.transactionRequest.billTo.city);
        g.writeStringField('state', createTransactionRequest.transactionRequest.billTo.state);
        g.writeStringField('zip', createTransactionRequest.transactionRequest.billTo.zip);
        g.writeStringField('country', createTransactionRequest.transactionRequest.billTo.country);
        g.writeStringField('phoneNumber', createTransactionRequest.transactionRequest.billTo.phoneNumber);
        g.writeStringField('faxNumber', createTransactionRequest.transactionRequest.billTo.faxNumber);
        g.writeEndObject();

      }

      //g.writeStringField('customerIP', createTransactionRequest.transactionRequest.customerIP);
      g.writeEndObject();

      return g.getAsString();
    }

  }

  public static void testParse()
  {
    String tmpStr = '{"transactionResponse":{"responseCode":"3","authCode":"","avsResultCode":"P","cvvResultCode":"","cavvResultCode":"","transId":"0","refTransID":"","transHash":"64657F3CA2D90361FC8D2E11777C6EBC","testRequest":"0","accountNumber":"XXXX5678","accountType":"eCheck","errors":[{"errorCode":"11","errorText":"A duplicate transaction has been submitted."}],"transHashSha2":""},"refId":"123456","messages":{"resultCode":"Error","message":[{"code":"E00027","text":"The transaction was unsuccessful."}]}}';
    PSTransactionResponse tr = (PSTransactionResponse)JSON.deserialize(tmpStr, PSTransactionResponse.class);
    System.debug('tr=' + JSON.serializePretty(tr));
    System.debug('message=' + tr.getMessage());
    System.debug('error=' + tr.getErrorMessage());
  }

  public class CreateTransactionRequest
  {
    public TransactionRequest transactionRequest;
    public String refId;
    public MerchantAuthentication merchantAuthentication;

    public void setMerchantAuthentication(String name, String transactionKey)
    {
      merchantAuthentication = new MerchantAuthentication();
      merchantAuthentication.name = name;
      merchantAuthentication.transactionKey = transactionKey;
    }

    public void setTransactionRequest(Double amount, String poNumber)
    {
      transactionRequest = new TransactionRequest();
      transactionRequest.amount = amount;
      transactionRequest.poNumber = poNumber;
    }

    public void setCreditCard(String cardNumber, String expirationDate, String cardCode)
    {
      CreditCard cc = new CreditCard();
      cc.cardNumber = cardNumber;
      cc.expirationDate = expirationDate;
      cc.cardCode = cardCode;

      Payment p = new Payment();
      p.creditCard = cc;

      transactionRequest.payment = p;
    }

    public void setBankAccount(String accountType, String routingNumber, String accountNumber, String nameOnAccount)
    {
      BankAccount ba = new BankAccount();
      ba.accountType = accountType;
      ba.routingNumber = routingNumber;
      ba.accountNumber = accountNumber;
      ba.nameOnAccount = nameOnAccount;

      Payment p = new Payment();
      p.bankAccount = ba;

      transactionRequest.payment = p;
    }

    public void addLineItem(String itemId, String name, String description, Integer quantity, Double unitPrice)
    {
      LineItem li = new LineItem();
      li.itemId = itemId;
      li.name = name;
      li.description = description;
      li.quantity = quantity;
      li.unitPrice = unitPrice;

      if (transactionRequest.lineItems == null)
      {
        transactionRequest.lineItems = new List<LineItem>();
      }

      transactionRequest.lineItems.add(li);
    }

    public void setTax(Double amount, String name, String description)
    {
      Charge c = new Charge();
      c.amount = amount;
      c.name = name;
      c.description = description;

      transactionRequest.tax = c;
    }

    public void setDuty(Double amount, String name, String description)
    {
      Charge c = new Charge();
      c.amount = amount;
      c.name = name;
      c.description = description;

      transactionRequest.duty = c;
    }

    public void setShipping(Double amount, String name, String description)
    {
      Charge c = new Charge();
      c.amount = amount;
      c.name = name;
      c.description = description;

      transactionRequest.shipping = c;
    }

    public void setBillTo(String firstName, String lastName, String company, String address,
                          String city, String state, String zip, String country, String phoneNumber, String faxNumber)
    {
      Address a = new Address();
      a.firstName = firstName;
      a.lastName = lastName;
      a.company = company;
      a.address = address;
      a.city = city;
      a.state = state;
      a.zip = zip;
      a.country = country;
      a.phoneNumber = phoneNumber;
      a.faxNumber = faxNumber;

      transactionRequest.billTo = a;
    }

    public void setShipTo(String firstName, String lastName, String company, String address,
                          String city, String state, String zip, String country)
    {
      Address a = new Address();
      a.firstName = firstName;
      a.lastName = lastName;
      a.company = company;
      a.address = address;
      a.city = city;
      a.state = state;
      a.zip = zip;
      a.country = country;

      transactionRequest.shipTo = a;
    }

    public void setCustomer(String type, String cId, String email)
    {
      Customer c = new Customer();
      c.type = type;
      c.id = cId;
      c.email = email;
      transactionRequest.customer = c;
    }
  }

  public class MerchantAuthentication
  {
    public String name;
    public String transactionKey;
  }

  public class TransactionRequest
  {
    public String transactionType = 'authCaptureTransaction';
    public Double amount;
    public Payment payment;
    public List<LineItem> lineItems;
    public Charge tax;
    public Charge duty;
    public Charge shipping;
    public String poNumber;
    public Customer customer;
    public Address billTo;
    public Address shipTo;
    public String customerIP;
    public String transactionSettings;
  }

  public class Setting
  {
    public SettingField setting;
  }

  public class SettingField
  {
    public String settingName;
    public String settingValue;
  }

  public class Customer
  {
    public String type;
    public String id;
    public String email;
  }

  public class Payment
  {
    public BankAccount bankAccount;
    public CreditCard creditCard;
  }

  public class BankAccount
  {
    public String accountType;
    public String routingNumber;
    public String accountNumber;
    public String nameOnAccount;
  }

  public class CreditCard
  {
    public String cardNumber;
    public String expirationDate;
    public String cardCode;
  }

  public class LineItem
  {
    public String itemId;
    public String name;
    public String description;
    public Integer quantity;
    public Double unitPrice;
  }

  public class Charge
  {
    public Double amount;
    public String name;
    public String description;
  }

  public class Address
  {
    public String firstName;
    public String lastName;
    public String company;
    public String address;
    public String city;
    public String state;
    public String zip;
    public String country;
    public String phoneNumber;
    public String faxNumber;
  }

  public class PSTransactionResponse
  {
    public TransactionResponse transactionResponse;
    public String refId;
    public Message messages;

    public String getErrorMessage()
    {
      String str = '';

      if (transactionResponse.errors != null)
      {
        for (TransactionError err : transactionResponse.errors)
        {
          if (str.length() == 0)
          {
            str = err.errorCode + ':' + err.errorText;
          }
          else
          {
            str += '  ' + err.errorCode + ':' + err.errorText;
          }
        }
      }
      return str;
    }

    public String getMessage()
    {
      String str = '';

      if (messages != null && messages.message != null)
      {
        for (MessageDetail det : messages.message)
        {
          if (str.length() == 0)
          {
            str = det.code + ':' + det.text;
          }
          else
          {
            str += '  ' + det.code + ':' + det.text;
          }
        }
      }
      return str;
    }
  }

  public class TransactionResponse
  {
    public Integer responseCode;
    public String authCode;
    public String avsResultCode;
    public String cvvResultCode;
    public String cavvResultCode;
    public String transId;
    public String refTransID;
    public String transHash;
    public String testRequest;
    public String accountNumber;
    public String accountType;
    public List<CodeMessage> messages = null;
    public List<NameValueField> userFields = null;
    public List<TransactionError> errors = null;
    public String transHashSha2;
  }

  public class NameValueField
  {
    public String name;
    public String value;
  }

  public class CodeMessage
  {
    public String code;
    public String description;
  }

  public class TransactionError
  {
    public String errorCode;
    public String errorText;
  }

  public class Message
  {
    public String resultCode;
    public List<MessageDetail> message;
  }

  public class MessageDetail
  {
    public String code;
    public String text;
  }

}