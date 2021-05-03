class ChargeVerificationResponse {
  String status;
  String message;
  Data data;

  ChargeVerificationResponse.fromJson(
      Map<String, dynamic> json, bool isFirstQuery) {
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
  String txRef;
  String flwRef;
  String deviceFingerPrint;
  int amount;
  int appFee;
  int chargeAmount;
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
  // Customer customer;
  // Account account;
  // Meta meta;

  Data.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    if (json['response'] != null) {
      json = json['response'].cast<Map<String, dynamic>>();
    }

    txRef = json['tx_ref'];
    flwRef = json['flw_ref'];
    deviceFingerPrint = json['device_fingerprint'];
    amount = json['amount'];
    chargeAmount = json['charged_amount'];
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
    // customer = Customer.fromJson(json['customer']);
    // account = Account.fromJson(json['account']);
    // meta = Meta.fromJson(json['meta']);
  }
  @override
  String toString() {
    return 'Data{ tx_ref: $txRef, flw_ref: $flwRef, device_fingerprint: $deviceFingerPrint, amount: $amount, app_fee: $appFee, merchant_fee: $merchantFee, auth_model: $authModel, currency: $currency, ip: $ip, narration: $narration, status: $status, auth_url: $authUrl, payment_type: $paymentType, fraud_status: $fraudStatus, created_at: $createdAt, account_id: $accountId, charged_amount: $chargeAmount, processor_response: $processorResponse}';
  }
}

class Customer {
  int id;
  String email;

  Customer.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    id = json['id'];
    email = json['email'];
  }

  @override
  String toString() {
    return 'Customer{ id: $id, email: $email}';
  }
}

class Account {
  String accountNumber;
  String bankCode;
  String accountName;

  Account.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    accountNumber = json['account_number'];
    bankCode = json['bank_code'];
    accountName = json['account_name'];
  }

  @override
  String toString() {
    return 'Account{ account_number: $accountNumber, bank_code: $bankCode, account_name: $accountName}';
  }
}

class Meta {
  Authorization authorization;

  Meta.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    authorization = Authorization.fromJson(json['authorization']);
  }

  @override
  String toString() {
    return 'authorization: $authorization';
  }
}

class Authorization {
  String mode;
  String instruction;

  Authorization.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    mode = json['mode'];
    instruction = json['validate_instructions'];
  }
  @override
  String toString() {
    return 'mode: $mode, validate_instructions: $instruction';
  }
}
