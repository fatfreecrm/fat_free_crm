# Threat Model - Fat Free CRM


## Purpose and Scope
This document is a high level threat model for Fat Free CRM. It is intended to be a starting point for individuals and organizations looking to deploy or extend the base functionality.

### Scope
- **Application**: Fat Free CRM core application logic and features.
- **Data**: Personally Identifiable Information (PII) of contacts and leads, user credentials, business opportunities, accounts, and internal communications.
- **Deployment**: Assumes standard Ruby on Rails deployment (e.g., Linux server, relational database like PostgreSQL/MySQL, web server like Puma).

### Target Audience
- **Developers**: To guide secure coding practices and feature implementation.
- **Security Auditors**: To provide a baseline for security assessments.
- **General Public/Users**: To understand the security posture and risks associated with the platform.

## System Architecture
Fat Free CRM follows a standard Ruby on Rails MVC (Model-View-Controller) architecture.

- **Web Server**: Handles HTTP requests (e.g., Nginx/Apache reverse proxying to Puma/Unicorn).
- **Application Layer**: Ruby on Rails handling business logic, routing, and rendering.
- **Authentication**: Managed via the `Devise` gem, supporting password-based login, registration, and password recovery.
- **Authorization**: Managed via the `CanCanCan` gem, defining permissions in `app/models/users/ability.rb`.
- **Database**: A relational database (PostgreSQL, MySQL, or SQLite) storing all persistent records.
- **Audit Trail**: The `PaperTrail` gem is used to track changes to models.
- **Storage**: `ActiveStorage` or `Paperclip` (legacy) for handling file uploads (avatars, attachments).

## Key Assets
| Asset | Description | Sensitivity |
| :--- | :--- | :--- |
| **User Credentials** | Usernames, hashed passwords, and authentication tokens. | High |
| **Customer PII** | Names, emails, phone numbers, and addresses of Contacts and Leads. | High |
| **Business Intelligence** | Details of Opportunities, Campaigns, and financial projections. | Medium/High |
| **Internal Communications** | Comments, emails, and tasks related to customers. | Medium |
| **System Configuration** | Secret keys, database credentials, and environment variables. | Critical |
| **Audit Logs** | History of changes to records (who changed what and when). | Medium |

## Trust Boundaries
1. **User/Internet <-> Web Application**: The primary boundary where external requests enter the system. This is the largest attack surface.
2. **Application <-> Database**: Boundary where the application persists and retrieves sensitive data. Requires strong authentication and network isolation.
3. **Application <-> External Services**: Interactions with email servers (SMTP), third-party APIs, or external storage (S3).
4. **Internal User Roles**: Boundaries between regular users, managers, and administrators, enforced by CanCan authorization logic.

## Attack Surface

### 1. Web UI / API Endpoints
All controllers and their respective actions (Index, Show, Create, Update, Delete) are entry points. Custom actions like `auto_complete`, `advanced_search`, and `filter` add to the complexity and potential for vulnerabilities like SQL Injection or IDOR.

### 2. Authentication & Session Management
The login, registration, and password recovery pages are prime targets for spoofing and brute-force attacks.

Fat Free CRM uses [devise](https://github.com/heartcombo/devise) and [devise-security](https://github.com/devise-security/devise-security) out of the box.


### 3. File Uploads
Avatars and attachments can be used for DoS attacks or to upload malicious files (e.g., shells if not properly validated and stored).

Fat Free CRM does not specify any specific file size limits, we recommend you configure this at the [webserver level](https://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size). All other defaults follow Rail's ActiveStorage norms.

### 4. Search and Filtering
The `ransack` gem and custom search logic are used extensively. If not correctly configured, they could be exploited for information disclosure or DoS.

### 5. Administration Interface
The `admin/` namespace provides capabilities for managing users, groups, and settings. Fat Free CRM defaults to a very open model for data access, compromise of an administrative account offers limited access over and above application defaults - lock out of users, wide access to records including those marked Private.

Ensure your system administrators [utilise strong credentials](https://www.cyber.gov.au/protect-yourself/securing-your-accounts/passphrases/creating-strong-passphrases), or that you have extended the core authentication layer to your organisation's requirements (for example, extending the application and setting [strong minimums](https://github.com/fatfreecrm/fat_free_crm/blob/master/config/initializers/devise.rb#L170) with devise or utilising an MFA friendly layer).

## Threat Analysis (STRIDE)

### 1. Spoofing
*   **External Attacker**: Attempts to gain access by spoofing a user session or credentials. This can lead to **Identity Theft**.
    *   **Threat**: Session hijacking through insecure cookies or XSS.
    *   **Threat**: Brute-force attacks on the login page or password recovery mechanism.
*   **Internal Attacker**:
    *   **Threat**: An employee spoofing an administrator to gain elevated privileges for fraud.

### 2. Tampering
*   **External Attacker**:
    *   **Threat**: Modifying request parameters (Mass Assignment) to change record ownership or sensitive fields (e.g., `rating`, `amount`).
    *   **Threat**: SQL Injection to modify database records directly.
*   **Internal Attacker**:
    *   **Threat**: Maliciously altering Opportunity stages or Lead assignments to commit **Fraud**.
    *   **Threat**: Deleting audit logs (`versions` table) to hide unauthorized changes.

### 3. Repudiation
*   **Threat**: A user performs a sensitive action (e.g., exporting the entire contact list) and denies doing so.
*   **Risk**: If `PaperTrail` or system logging is disabled or bypassed, actions cannot be attributed to specific users, facilitating internal theft.

### 4. Information Disclosure
*   **External Attacker**:
    *   **Threat**: **Mass Theft of PII** via insecure direct object references (IDOR) or unauthenticated API endpoints.
    *   **Threat**: Sensitive data leakage in error messages or logs.
*   **Internal Attacker**:
    *   **Threat**: Unauthorized export of the entire database or large segments of customer data for competitors or **Blackmail**.

### 5. Denial of Service (DoS)
*   **External Attacker**:
    *   **Threat**: Resource exhaustion through large file uploads or complex database queries.
    *   **Threat**: **Ransomware style attack** by encrypting the database or deleting critical application files.
*   **Internal Attacker**:
    *   **Threat**: Intentional disruption of service by deleting critical records or misconfiguring the application.

### 6. Elevation of Privilege
*   **Internal Attacker**:
    *   **Threat**: Exploiting flaws in `Ability.rb` logic to gain administrative access.
    *   **Threat**: Manipulating the `admin` flag on the `User` model through Mass Assignment vulnerabilities.

## Mitigation Strategies & Recommendations

### General Security

- **Update Dependencies**: Regularly update gems (especially `rails`, `devise`, `cancan`) to patch known vulnerabilities. The core team utilises dependabot and similar services to adopt updates, trailing the latest releases slightly to reduce the chance of supply chain attacks.
- **HTTPS**: Enforce HTTPS for all traffic to reduce the chance of session hijacking and credential sniffing. Consider strongly your deployment model and network access.

### 1. Countering Spoofing & Identity Theft
- **Multi-Factor Authentication (MFA)**: Implement MFA for all users, or at least for administrators.
- **Strong Password Policy**: Enforce minimum password complexity and length requirements via Devise.
- **Rate Limiting**: Implement rate limiting on login and password recovery attempts (e.g., using `rack-attack`).

### 2. Countering Tampering & Fraud
- **Strong Parameters**: Rigorously use Rails' Strong Parameters to prevent Mass Assignment vulnerabilities.
- **Input Validation**: Validate all user input at the model level to ensure data integrity.
- **CSRF Protection**: Ensure Rails' built-in CSRF protection is active and correctly configured for all state-changing requests.

### 3. Countering Information Disclosure & PII Theft
- **Attribute-Level Authorization**: Ensure that users can only see the fields they are authorized to view, especially in search results and exports.
- **Secure File Storage**: Store uploaded files in a secure, non-public directory and serve them through an authenticated controller.
- **Data Encryption at Rest**: Encrypt sensitive database columns (e.g., using `lockbox` or Rails' built-in encryption in newer versions).

### 4. Countering Denial of Service & Ransomware
- **Backup Strategy**: Implement a robust, off-site, and automated backup strategy for the database and uploaded files.
- **Database Query Optimization**: Monitor and optimize slow-running queries to prevent resource exhaustion.
- **Web Application Firewall (WAF)**: Deploy a WAF to filter out common attack patterns and mitigate DoS attempts.

### 5. Countering Elevation of Privilege
- **Principle of Least Privilege**: Regularly review and tighten the permissions defined in `Ability.rb`.
- **Admin Isolation**: Consider isolating administrative functionality to a separate network or requiring a VPN for access.
- **Regular Auditing**: Periodically review audit logs for any suspicious changes to user roles or permissions.
