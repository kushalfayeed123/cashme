const String LIVE_CHARGE_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/charge";
const String SANDBOX_CHARGE_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/charge";

// "https://ravesandboxapi.flutterwave.com/flwv3-pug/getpaidx/api/charge";
const String BANKS_ENDPOINT =
    'https://api.ravepay.co/flwv3-pug/getpaidx/api/flwpbf-banks.js?json=1';
const String VALIDATE_CHARGE_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/validatecharge";
const String REQUERY_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/verify";

const String PUBLIC_KEY = 'FLWPUBK-e9c110e3b41801db0a2c19982aad3c5d-X';
// 'FLWPUBK_TEST-1631f51ac197c922a2d41ecca319224d-X';
const String ENCRYPTION_KEY = '2e71fb7432ce972373a0e86e';
// 'FLWSECK_TEST6e609efb0196';

const CURRENCY = 'NGN';
const PAYMENTTYPE = 'account';
const COUNTRY = 'NG';
// const receivingCountry = 'NG';
// const network = 'UGX';
const WEB_HOOK_3DS = 'https://rave-webhook.herokuapp.com/receivepayment';
const MAX_REQUERY_COUNT = 30;