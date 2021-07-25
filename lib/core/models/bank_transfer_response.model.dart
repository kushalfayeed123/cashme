class BankTransferResponse {
  String status;
  String message;
  Meta meta;

  BankTransferResponse({this.status, this.message, this.meta});

  BankTransferResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.meta != null) {
      data['meta'] = this.meta.toJson();
    }
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
  String transferReference;
  String transferAccount;
  String transferBank;
  String accountExpiration;
  String transferNote;
  int transferAmount;
  String mode;

  Authorization(
      {this.transferReference,
      this.transferAccount,
      this.transferBank,
      this.accountExpiration,
      this.transferNote,
      this.transferAmount,
      this.mode});

  Authorization.fromJson(Map<String, dynamic> json) {
    transferReference = json['transfer_reference'];
    transferAccount = json['transfer_account'];
    transferBank = json['transfer_bank'];
    accountExpiration = json['account_expiration'];
    transferNote = json['transfer_note'];
    transferAmount = json['transfer_amount'];
    mode = json['mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transfer_reference'] = this.transferReference;
    data['transfer_account'] = this.transferAccount;
    data['transfer_bank'] = this.transferBank;
    data['account_expiration'] = this.accountExpiration;
    data['transfer_note'] = this.transferNote;
    data['transfer_amount'] = this.transferAmount;
    data['mode'] = this.mode;
    return data;
  }
}
