# get-currency-rate
Get currency rate from National Bank of Ukraine official site for supported currencies. Dates are supported.

## Usage:

```shell
rate [-h | --help] [-l | --list] [DATE] [CURRENCY_CODE]
  -l | --list - List available NBU currencies
  -h | --help - view this help
```

Default currency is USD.

Default date is current.

Use `rate` to get USD rate to UAH on a current date,

  - or use `rate YYYYmmdd` to get USD rate to UAH on a exact date,
  
  - or use `rate CURRENCY_CODE` to get a rate for an exact currency on a current date,  
  
  - or `rate YYYYmmdd CURRENCY_CODE` to get a rate for exact currency on exact date (CURRENCY_CODE is case insensitive and 3 letters long).    

See https://en.wikipedia.org/wiki/ISO_4217 (Not all of a codes are supported.)
