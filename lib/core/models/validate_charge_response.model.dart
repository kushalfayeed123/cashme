class ValidateChargeResponse {
  String status;
  String message;
  Data data;

  ValidateChargeResponse({this.status, this.message, this.data});

  ValidateChargeResponse.fromJson(Map<String, dynamic> json) {
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
      this.accountId});

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
    return data;
  }
}
