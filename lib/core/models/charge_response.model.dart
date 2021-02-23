class ChargeResponse {
  String status;
  String message;
  Data data;

  ChargeResponse.fromJson(Map<String, dynamic> json, bool isFirstQuery) {
    if (json == null) {
      return;
    }
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  @override
  String toString() {
    return 'status: $status, message: $message, data: $data';
  }
}

class Data {
  int id;
  int orderRef;
  int appFee;
  int amount;
  int chargedAmount;
  int settlementToken;
  int merchantfee;
  int merchantbearsfee;
  int acctvalrespmsg;
  int retryAttempt;
  int getpaidBatchId;
  int customerId;
  int accountId;
  int paymentPage;

  String chargeResponseCode;
  String flwRef;
  String txRef;
  String chargeResponseMessage;
  String authurl;
  String authModelUsed;
  String iP;
  String narration;
  String currency;
  String redirectUrl;
  String status;
  String deviceFingerprint;
  String vbvrespmessage;
  String accountname;
  String vbvrespcode;
  String cycle;
  String acctvalrespcode;
  String paymentType;
  String paymentPlan;
  String paymentId;
  String fraudStatus;
  String chargeType;
  String isLive;
  String raveRef;
  String modalauditid;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;

  //For timeout
  String pingUrl;
  int wait;

  Data.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    if (json['response'] != null) {
      json = json['response'].cast<Map<String, dynamic>>();
    }

    txRef = json['txRef'];
    orderRef = json['orderRef'];
    flwRef = json['flwRef'];
    redirectUrl = json['redirectUrl'];
    deviceFingerprint = json['device_fingerprint'];
    settlementToken = json['settlement_token'];
    cycle = json['cycle'];
    amount = json['amount'];
    chargedAmount = json['charged_amount'];
    appFee = json['appfee'];
    merchantfee = json['merchantfee'];
    chargeResponseCode = json['chargeResponseCode'];
    chargeResponseMessage = json['chargeResponseMessage'];
    merchantbearsfee = json['merchantbearsfee'];
    raveRef = json['raveRef'];
    authModelUsed = json['authModelUsed'];
    currency = json['currency'];
    iP = json['IP'];
    narration = json['narration'];
    modalauditid = json['modalauditid'];
    vbvrespmessage = json['vbvrespmessage'];
    vbvrespcode = json['vbvrespcode'];
    acctvalrespmsg = json['acctvalrespmsg'];
    acctvalrespcode = json['acctvalrespcode'];
    paymentType = json['paymentType'];
    paymentPlan = json['paymentPlan'];
    paymentPage = json['paymentPage'];
    paymentId = json['paymentId'];
    fraudStatus = json['fraud_status'];
    chargeType = json['charge_type'];
    isLive = json['is_live'];
    retryAttempt = json['retry_attempt'];
    getpaidBatchId = json['getpaidBatchId'];
    // createdAt = json['createdAt'].toDate();
    // updatedAt = json['updatedAt'].toDate();
    // deletedAt = json['deletedAt'].toDate();
    customerId = json['customerId'];
    accountId = json['AccountId'];
    accountname = json['accountname'];

    pingUrl = json['ping_url'];
    wait = json['wait'];
    status = json['status'];
    authurl = json['authurl'];
  }
  @override
  String toString() {
    return 'Data{ chargeResponseCode: $chargeResponseCode, accountname: $accountname, orderRef: $orderRef, device_fingerprint: $deviceFingerprint, settlement_token: $settlementToken, cycle: $cycle, charged_amount: $chargedAmount, merchantfee: $merchantfee, merchantbearsfee: $merchantbearsfee, raveRef: $raveRef, IP: $iP, narration: $narration, modalauditid: $modalauditid, vbvrespmessage: $vbvrespmessage, vbvrespcode: $vbvrespcode, acctvalrespmsg: $acctvalrespmsg, acctvalrespcode: $acctvalrespcode, paymentType: $paymentType, paymentPlan: $paymentPlan, paymentPage: $paymentPage, paymentId: $paymentId, fraud_status: $fraudStatus, charge_type: $chargeType, is_live: $isLive, retry_attempt: $retryAttempt, getpaidBatchId: $getpaidBatchId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, customerId: $customerId, AccountId: $accountId, authModelUsed: $authModelUsed, flwRef: $flwRef, txRef: $txRef, chargeResponseMessage: $chargeResponseMessage, authurl: $authurl, appFee: $appFee, currency: $currency, charged_amount: $chargedAmount,  redirectUrl: $redirectUrl,  amount: $amount, status: $status, ping_url: $pingUrl, wait: $wait}';
  }
}
