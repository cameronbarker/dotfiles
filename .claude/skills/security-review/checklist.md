# Security Review Checklist

## Input Validation
- [ ] All user input validated at system boundaries
- [ ] SQL queries use parameterized statements, not string concatenation
- [ ] Shell commands built from user input use argument arrays, not string interpolation
- [ ] File paths sanitized to prevent directory traversal

## Authentication & Authorization
- [ ] Secrets and credentials not hardcoded or logged
- [ ] Auth checks present on all protected routes/endpoints
- [ ] Tokens have appropriate expiry and are stored securely

## Dependency & Supply Chain
- [ ] No known vulnerable dependency versions (check with `npm audit` / `bundle audit` / etc.)
- [ ] No unexpected network calls or data exfiltration

## Output Safety
- [ ] HTML output properly escaped to prevent XSS
- [ ] Error messages don't leak internal paths or stack traces to end users

## Data Handling
- [ ] Sensitive data (PII, credentials) not written to logs
- [ ] Temporary files cleaned up after use
