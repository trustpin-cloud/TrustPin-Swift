# Security Policy

## Reporting Security Vulnerabilities

We take security issues seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report
- **Email**: [security@trustpin.cloud](mailto:security@trustpin.cloud)
- **Subject**: Include "SECURITY" in the subject line
- **Encryption**: Use our PGP key if possible (available on our website)

### What to Include
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Any suggested fixes

### Response Timeline
- **Acknowledgment**: Within 24 hours
- **Initial Assessment**: Within 72 hours
- **Status Updates**: Weekly until resolved
- **Resolution**: Depends on severity (critical: 7 days, high: 30 days)

### Responsible Disclosure
- Allow us reasonable time to fix the issue before public disclosure
- We'll credit you in our security advisories (unless you prefer anonymity)
- We may offer bounties for significant vulnerabilities

## Security Best Practices

When using TrustPin:
- Always use `.strict` mode in production
- Keep your pinning configurations up to date
- Monitor certificate expiration dates
- Use secure channels for configuration delivery
- Implement proper error handling for pinning failures

## Scope

This security policy covers:
- TrustPin iOS SDK source code
- Configuration and setup vulnerabilities
- Certificate validation bypasses
- Authentication and authorization issues

## Out of Scope
- General iOS security issues
- Third-party dependencies (report to respective maintainers)
- Social engineering attacks
- Physical device access scenarios

## Contact

For security-related questions: [security@trustpin.cloud](mailto:security@trustpin.cloud)