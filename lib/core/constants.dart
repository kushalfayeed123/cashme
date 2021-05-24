const String LIVE_CHARGE_ENDPOINT =
    "https://api.flutterwave.com/v3/charges?type=debit_ng_account";
const String SANDBOX_CHARGE_ENDPOINT =
    "https://api.flutterwave.com/v3/charges?type=debit_ng_account";
const String BANKS_ENDPOINT = 'https://api.flutterwave.com/v3/banks/NG';
const String VALIDATE_CHARGE_ENDPOINT =
    "https://api.flutterwave.com/v3/validate-charge";
const String REQUERY_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/verify";
const String BANK_TRANSFER_ENDPOINT =
    "https://api.flutterwave.com/v3/charges?type=bank_transfer";
const String CASHOUT_ENDPOINT = "https://api.flutterwave.com/v3/transfers";

const String ACCOUNT_VERIFICATION_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/resolve_account";
const String PUBLIC_KEY = 'FLWPUBK-e9c110e3b41801db0a2c19982aad3c5d-X';
// 'FLWPUBK_TEST-1631f51ac197c922a2d41ecca319224d-X';
const String ENCRYPTION_KEY =
// '2e71fb7432ce972373a0e86e';
    'FLWSECK_TEST6e609efb0196';

const CURRENCY = 'NGN';
const PAYMENTTYPE = 'account';
const COUNTRY = 'NG';
const WEB_HOOK_3DS = 'https://rave-webhook.herokuapp.com/receivepayment';
const MAX_REQUERY_COUNT = 30;

const DEBIT = 'Debit';
const CREDIT = 'Credit';

const QR_TRANSFER = 'QR Transfer';
const USERNAME_TRANSFER = 'User Transfer';
const WALLET_LOAD = 'Wallet Load';
const CASHOUT = 'Cash Out';
