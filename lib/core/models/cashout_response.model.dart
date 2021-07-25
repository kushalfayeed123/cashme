class CashoutResponse {
  String status;
  String message;
  Data data;

  CashoutResponse({this.status, this.message, this.data});

  CashoutResponse.fromJson(Map<String, dynamic> json) {
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
  String accountNumber;
  String bankCode;
  String fullName;
  String createdAt;
  String currency;
  String debitCurrency;
  int amount;
  double fee;
  String status;
  String reference;
  Null meta;
  String narration;
  String completeMessage;
  int requiresApproval;
  int isApproved;
  String bankName;

  Data(
      {this.id,
      this.accountNumber,
      this.bankCode,
      this.fullName,
      this.createdAt,
      this.currency,
      this.debitCurrency,
      this.amount,
      this.fee,
      this.status,
      this.reference,
      this.meta,
      this.narration,
      this.completeMessage,
      this.requiresApproval,
      this.isApproved,
      this.bankName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountNumber = json['account_number'];
    bankCode = json['bank_code'];
    fullName = json['full_name'];
    createdAt = json['created_at'];
    currency = json['currency'];
    debitCurrency = json['debit_currency'];
    amount = json['amount'];
    fee = json['fee'];
    status = json['status'];
    reference = json['reference'];
    meta = json['meta'];
    narration = json['narration'];
    completeMessage = json['complete_message'];
    requiresApproval = json['requires_approval'];
    isApproved = json['is_approved'];
    bankName = json['bank_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['account_number'] = this.accountNumber;
    data['bank_code'] = this.bankCode;
    data['full_name'] = this.fullName;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['debit_currency'] = this.debitCurrency;
    data['amount'] = this.amount;
    data['fee'] = this.fee;
    data['status'] = this.status;
    data['reference'] = this.reference;
    data['meta'] = this.meta;
    data['narration'] = this.narration;
    data['complete_message'] = this.completeMessage;
    data['requires_approval'] = this.requiresApproval;
    data['is_approved'] = this.isApproved;
    data['bank_name'] = this.bankName;
    return data;
  }
}
