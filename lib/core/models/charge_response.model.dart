class ChargeResponse {
  String status;
  String message;
  Data data;

  ChargeResponse({this.status, this.message, this.data});

  ChargeResponse.fromJson(Map<String, dynamic> json) {
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
  double chargedAmount;
  double appFee;
  int merchantFee;
  String processorResponse;
  String authModel;
  String currency;
  String ip;
  String narration;
  String status;
  String authUrl;
  String paymentType;
  String fraudStatus;
  String createdAt;
  int accountId;
  Customer customer;
  Account account;
  Meta meta;

  Data(
      {this.id,
      this.txRef,
      this.flwRef,
      this.deviceFingerprint,
      this.amount,
      this.chargedAmount,
      this.appFee,
      this.merchantFee,
      this.processorResponse,
      this.authModel,
      this.currency,
      this.ip,
      this.narration,
      this.status,
      this.authUrl,
      this.paymentType,
      this.fraudStatus,
      this.createdAt,
      this.accountId,
      this.customer,
      this.account,
      this.meta});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    txRef = json['tx_ref'];
    flwRef = json['flw_ref'];
    deviceFingerprint = json['device_fingerprint'];
    amount = json['amount'];
    chargedAmount = json['charged_amount'];
    appFee = json['app_fee'];
    merchantFee = json['merchant_fee'];
    processorResponse = json['processor_response'];
    authModel = json['auth_model'];
    currency = json['currency'];
    ip = json['ip'];
    narration = json['narration'];
    status = json['status'];
    authUrl = json['auth_url'];
    paymentType = json['payment_type'];
    fraudStatus = json['fraud_status'];
    createdAt = json['created_at'];
    accountId = json['account_id'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    account =
        json['account'] != null ? new Account.fromJson(json['account']) : null;
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tx_ref'] = this.txRef;
    data['flw_ref'] = this.flwRef;
    data['device_fingerprint'] = this.deviceFingerprint;
    data['amount'] = this.amount;
    data['charged_amount'] = this.chargedAmount;
    data['app_fee'] = this.appFee;
    data['merchant_fee'] = this.merchantFee;
    data['processor_response'] = this.processorResponse;
    data['auth_model'] = this.authModel;
    data['currency'] = this.currency;
    data['ip'] = this.ip;
    data['narration'] = this.narration;
    data['status'] = this.status;
    data['auth_url'] = this.authUrl;
    data['payment_type'] = this.paymentType;
    data['fraud_status'] = this.fraudStatus;
    data['created_at'] = this.createdAt;
    data['account_id'] = this.accountId;
    if (this.customer != null) {
      data['customer'] = this.customer.toJson();
    }
    if (this.account != null) {
      data['account'] = this.account.toJson();
    }
    if (this.meta != null) {
      data['meta'] = this.meta.toJson();
    }
    return data;
  }
}

class Customer {
  int id;
  Null phoneNumber;
  String name;
  String email;
  String createdAt;

  Customer({this.id, this.phoneNumber, this.name, this.email, this.createdAt});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phoneNumber = json['phone_number'];
    name = json['name'];
    email = json['email'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['phone_number'] = this.phoneNumber;
    data['name'] = this.name;
    data['email'] = this.email;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Account {
  String accountNumber;
  String bankCode;
  String accountName;

  Account({this.accountNumber, this.bankCode, this.accountName});

  Account.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number'];
    bankCode = json['bank_code'];
    accountName = json['account_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_number'] = this.accountNumber;
    data['bank_code'] = this.bankCode;
    data['account_name'] = this.accountName;
    return data;
  }
}

class Meta {
  Authorization authorization;

  Meta({this.authorization});

  Meta.fromJson(Map<String, dynamic> json) {
    authorization = json['authorization'] != null
        ? new Authorization.fromJson(json['authorization'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.authorization != null) {
      data['authorization'] = this.authorization.toJson();
    }
    return data;
  }
}

class Authorization {
  String mode;
  String validateInstructions;

  Authorization({this.mode, this.validateInstructions});

  Authorization.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    validateInstructions = json['validate_instructions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mode'] = this.mode;
    data['validate_instructions'] = this.validateInstructions;
    return data;
  }
}
