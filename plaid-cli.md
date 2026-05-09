Plaid CLI 
==========

#### Install and use the Plaid CLI to access your financial data from the terminal 

The Plaid CLI is a command-line interface for the [Plaid API](https://plaid.com/docs/api/index.html.md) . Install once and start making API calls — no client libraries to import, no request objects to construct, no response types to parse.

The CLI works for both developers and AI agents:

*   **For developers:** readable table output in the terminal, with commands that mirror the API structure
*   **For agents:** structured JSON output via `--json`, clean separation of data on stdout and diagnostics on stderr, and predictable exit codes

The CLI currently supports [Balance](https://plaid.com/docs/balance/index.html.md) , [Transactions](https://plaid.com/docs/transactions/index.html.md) , [Investments](https://plaid.com/docs/investments/index.html.md) , and [Liabilities](https://plaid.com/docs/liabilities/index.html.md) . Use it to link a financial institution, check balances, pull transactions, view holdings, and more, all without writing any code.

The Plaid CLI is an experimental tool; you may encounter rough edges. Use `plaid feedback` to report issues or suggest improvements.

The interface to the Plaid CLI may change (including breaking changes) without advance notice.

#### Installing the CLI 

The CLI is distributed via [Homebrew](https://brew.sh/) .

Install via Homebrew

```bash
brew install plaid/plaid-cli/plaid
```

Update to the latest version

```bash
brew update && brew upgrade plaid
```

Verify the installation

```bash
plaid --version
```

#### Getting started 

##### Creating an account 

If you don't have a Plaid account yet, sign up directly from the CLI:

Sign up for a Plaid account

```bash
plaid register
```

This opens the [Dashboard](https://dashboard.plaid.com/) signup page in your browser. After creating and verifying your account, log in:

Log in to the Dashboard

```bash
plaid login
```

This opens a browser for you to authenticate with the Dashboard. Once complete, the CLI stores your tokens locally and fetches your API keys automatically. Tokens are refreshed automatically by subsequent commands.

##### Signing up for the Trial plan 

By default, new accounts have access to the [Sandbox environment](https://plaid.com/docs/sandbox/index.html.md) . To connect to real financial institutions, apply for a [Trial plan](https://plaid.com/docs/account/billing/index.html.md#trial-plans) :

Open the Trial plan application

```bash
plaid trial
```

This opens the Trial plan application form in your browser. Once your application is approved, refresh your locally stored API keys to start using Production:

Refresh API keys after Trial plan approval

```bash
plaid keys fetch
```

#### Linking an Item 

The CLI is organized around [Items](https://plaid.com/docs/quickstart/glossary/index.html.md#item) , which represent logins at financial institutions. Product commands read data from one Item (`--item`) or all linked Items (`--all`).

To connect a real institution, use Hosted Link in your browser:

Open Link to create an Item

```bash
plaid link
```

This opens [Plaid Link](https://plaid.com/docs/link/index.html.md) in your browser. Search for your financial institution, log in with your credentials, and select the accounts you want to connect. When the flow completes, the CLI automatically saves the access token and Item ID to your config so you can query product data immediately.

`plaid link` accepts a `--products` flag to choose the product set for the linked Item:

Link an Item for Transactions and Liabilities use cases

```bash
plaid link --products transactions,liabilities
```

`plaid item link` is an equivalent namespace form when you want to stay inside the `item` command tree.

To see which Items you have linked:

List linked Items in the current environment

```bash
plaid item list
```

#### Creating a Sandbox Item 

The [Sandbox environment](https://plaid.com/docs/sandbox/index.html.md) allows you to test without connecting a real financial institution.

Create a Sandbox Item directly

```bash
plaid config set --env sandbox
plaid sandbox link
```

You can choose a Sandbox product scenario without opening Link:

Create Sandbox Items for specific product scenarios

```bash
plaid sandbox link --products balance
plaid sandbox link --products transactions,liabilities
plaid sandbox link --products investments
```

#### Querying PFM product data 

With one linked Item stored locally, the product commands use it by default. When you have multiple linked Items, pass `--item <item-id-or-alias>` for one Item or `--all` to view every linked Item.

Once you have linked an Item, the main product commands are:

Check account balances

```bash
plaid balance
```

Sample output

```text
ACCOUNT                            AVAILABLE  CURRENT   CURRENCY
Plaid Checking (0000)              100.00     110.00    USD
```

List recent transactions

```bash
plaid transactions list --count 5
```

Sample output

```text
DATE        MERCHANT                   AMOUNT   CATEGORY                                  ACCOUNT
2026-04-24  Tectra Inc                 500.00   Food and Drink > Restaurants              Plaid Credit Card (3333)
2026-04-23  AUTOMATIC PAYMENT - THANK  2078.50  Payment                                   Plaid Credit Card (3333)
2026-04-23  KFC                        500.00   Food and Drink > Restaurants > Fast Food  Plaid Credit Card (3333)
2026-04-23  Madison Bicycle Shop       500.00   Shops > Sporting Goods                    Plaid Credit Card (3333)
2026-04-14  Uber                       5.40     Travel > Taxi                             Plaid Checking (0000)
```

Sync transactions incrementally

```bash
plaid transactions sync
```

Sample output

```text
Synced: 4 added, 0 modified, 0 removed

New transactions:
DATE        MERCHANT         AMOUNT
2026-04-14  Uber             5.40
2026-04-12  United Airlines  -500.00
2026-04-11  McDonald's       12.00
2026-04-11  Starbucks        4.33
```

Get investment holdings

```bash
plaid investments holdings
```

Sample output

```text
ACCOUNT            SECURITY                        TICKER               QUANTITY    PRICE     VALUE
Plaid 401k (6666)  Achillion Pharmaceuticals Inc.  ACHN                 1           2.11      2.11
Plaid IRA (5555)   Nflx Feb 01'18 $355 Call        NFLX180201C00355000  10000       0.01      110.00
```

Get investment transactions

```bash
plaid investments transactions --start-date 2026-04-23
```

Sample output

```text
DATE        NAME                                TICKER               TYPE  QUANTITY           AMOUNT    ACCOUNT
2026-04-24  BUY Achillion Pharmaceuticals Inc.  ACHN                 buy   0.520877874205698  1.10      Plaid 401k (6666)
2026-04-23  BUY NFLX DERIVATIVE                 NFLX180201C00355000  buy   4211.152345617756  46.32     Plaid IRA (5555)
```

Get liabilities

```bash
plaid liabilities
```

Sample output

```text
Credit
ACCOUNT                   CURRENT  LIMIT    MIN PAYMENT  NEXT DUE    LAST STATEMENT  OVERDUE
Plaid Credit Card (3333)  410.00   2000.00  20.00        2020-05-28  1708.77         no

Student
ACCOUNT                    CURRENT   MIN PAYMENT  NEXT DUE    RATE   EXPECTED PAYOFF
Plaid Student Loan (7777)  65262.00  25.00        2019-05-28  5.25%  2032-07-28

Mortgage
ACCOUNT                CURRENT   NEXT PAYMENT  NEXT DUE    RATE   TERM
Plaid Mortgage (8888)  56302.06  3141.54       2019-11-15  3.99%  30 year
```

#### JSON output for agents and scripts 

All commands support the `--json` flag for structured, machine-readable output. This makes the CLI a natural fit for AI agents and shell scripts.

In `--json` mode:

*   `stdout` contains the primary JSON result
*   `stderr` contains diagnostics
*   browser-based commands still open the browser when required

Get balances as JSON

```bash
plaid balance --json
```

Sample output

```json
{
  "accounts": [
    {
      "account_id": "zNGwXw3...",
      "name": "Plaid Checking",
      "official_name": "Plaid Gold Standard 0% Interest Checking",
      "type": "depository",
      "subtype": "checking",
      "mask": "0000",
      "balances": {
        "available": 100,
        "current": 110,
        "limit": null,
        "iso_currency_code": "USD"
      }
    },
    {
      "account_id": "BpMKbK7...",
      "name": "Plaid Saving",
      "official_name": "Plaid Silver Standard 0.1% Interest Saving",
      "type": "depository",
      "subtype": "savings",
      "mask": "1111",
      "balances": {
        "available": 200,
        "current": 210,
        "limit": null,
        "iso_currency_code": "USD"
      }
    }
  ],
  "item": {
    "item_id": "...",
    "institution_id": "ins_56"
  }
}
```

Pipe JSON output to other tools

```bash
plaid balance --json | jq '.accounts[0].name'
"Plaid Checking"
```

#### Command guide 

Run `plaid --help` for the full command tree, or `plaid <command> --help` for details on a specific command.

##### Access 

| Command | Description |
| --- | --- |
| `plaid register` | Register an account in the Dashboard |
| `plaid login` | Log in to the Dashboard |
| `plaid trial` | Start the Trial plan onboarding in the Dashboard |
| `plaid logout` | Remove stored Dashboard credentials |

##### Products 

| Command | Description |
| --- | --- |
| `plaid link` | Open Link to create an Item |
| `plaid item list` | List linked Items in the current environment |
| `plaid item get` | Show an Item and the accounts it contains |
| `plaid item remove` | Remove a linked Item |
| `plaid balance` | Get balance data |
| `plaid transactions list` | List transactions |
| `plaid transactions sync` | Sync transactions incrementally |
| `plaid investments holdings` | Get investments holdings |
| `plaid investments transactions` | Get investments transactions |
| `plaid liabilities` | Get liabilities |
| `plaid sandbox link` | Create a Sandbox Item |

##### Configuration 

| Command | Description |
| --- | --- |
| `plaid config` | Show Plaid CLI config status |
| `plaid config set` | Manually modify config |
| `plaid teams list` | List available Dashboard teams |
| `plaid teams choose` | Interactively choose the active team |
| `plaid keys fetch` | Fetch API keys from the Dashboard |

##### Utilities 

| Command | Description |
| --- | --- |
| `plaid feedback` | Submit feedback about the CLI |
| `plaid help` | Help about any command |

#### Configuration 

Credentials are read with this precedence: **flags > environment variables > config file**.

Each environment (Sandbox, Production) stores its own credentials separately. Switching environments preserves all stored data.

Managing credentials

```bash
# Set credentials (secret is prompted interactively)
plaid config set --client-id <your-client-id> --env sandbox

# Switch to production
plaid config set --env production

# View current config (secrets are masked)
plaid config
```

##### Environment variables 

For scripted and automated usage, credentials can be set via environment variables:

| Variable | Description |
| --- | --- |
| `PLAID_CLIENT_ID` | Plaid client ID |
| `PLAID_SECRET` | Plaid secret |
| `PLAID_ENV` | Environment (`sandbox` or `production`) |
| `PLAID_ACCESS_TOKEN` | Access token |

#### Feedback 

Submit feedback, bug reports, or feature requests

```bash
plaid feedback "The transactions list command is great!"
```

You can also run `plaid feedback` without a message to enter feedback interactively.