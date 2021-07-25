class VerifyChargeResponse {
  String status;
  String message;
  Data data;

  VerifyChargeResponse({this.status, this.message, this.data});

  VerifyChargeResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  int id;
  String txRef;
  String flwRef;
  String deviceFingerprint;
  int amount;
  String currency;
  double chargedAmount;
  double appFee;
  int merchantFee;
  String processorResponse;
  String authModel;
  String ip;
  String narration;
  String status;
  String paymentType;
  String createdAt;
  int accountId;
  Account account;
  Null meta;
  int amountSettled;
  Customer customer;

  Data(
      {this.id,
      this.txRef,
      this.flwRef,
      this.deviceFingerprint,
      this.amount,
      this.currency,
      this.chargedAmount,
      this.appFee,
      this.merchantFee,
      this.processorResponse,
      this.authModel,
      this.ip,
      this.narration,
      this.status,
      this.paymentType,
      this.createdAt,
      this.accountId,
      this.account,
      this.meta,
      this.amountSettled,
      this.customer});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    txRef = json['tx_ref'];
    flwRef = json['flw_ref'];
    deviceFingerprint = json['device_fingerprint'];
    amount = json['amount'];
    currency = json['currency'];
    chargedAmount = json['charged_amount'];
    appFee = json['app_fee'];
    merchantFee = json['merchant_fee'];
    processorResponse = json['processor_response'];
    authModel = json['auth_model'];
    ip = json['ip'];
    narration = json['narration'];
    status = json['status'];
    paymentType = json['payment_type'];
    createdAt = json['created_at'];
    accountId = json['account_id'];
    account =
        json['account'] != null ? new Account.fromJson(json['account']) : null;
    meta = json['meta'];
    amountSettled = json['amount_settled'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tx_ref'] = this.txRef;
    data['flw_ref'] = this.flwRef;
    data['device_fingerprint'] = this.deviceFingerprint;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['charged_amount'] = this.chargedAmount;
    data['app_fee'] = this.appFee;
    data['merchant_fee'] = this.merchantFee;
    data['processor_response'] = this.processorResponse;
    data['auth_model'] = this.authModel;
    data['ip'] = this.ip;
    data['narration'] = this.narration;
    data['status'] = this.status;
    data['payment_type'] = this.paymentType;
    data['created_at'] = this.createdAt;
    data['account_id'] = this.accountId;
    if (this.account != null) {
      data['account'] = this.account.toJson();
    }
    data['meta'] = this.meta;
    data['amount_settled'] = this.amountSettled;
    if (this.customer != null) {
      data['customer'] = this.customer.toJson();
    }
    return data;
  }
}

class Account {
  String accountNumber;
  String bankCode;
  String accountToken;
  String accountName;

  Account(
      {this.accountNumber, this.bankCode, this.accountToken, this.accountName});

  Account.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number'];
    bankCode = json['bank_code'];
    accountToken = json['account_token'];
    accountName = json['account_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_number'] = this.accountNumber;
    data['bank_code'] = this.bankCode;
    data['account_token'] = this.accountToken;
    data['account_name'] = this.accountName;
    return data;
  }
}

class Customer {
  int id;
  String name;
  String phoneNumber;
  String email;
  String createdAt;

  Customer({this.id, this.name, this.phoneNumber, this.email, this.createdAt});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['created_at'] = this.createdAt;
    return data;
  }
}
