# Mock Federal Access Audit & Inactive Account Finder

A mock access review built in MariaDB, inspired by FICAM principles
(periodic access reviews, removal of inactive accounts, least privilege).
All data is fictional.

## What it detects
1. **Inactive accounts:** employees with no login in 90+ days, including
   accounts that never logged in.
2. **Privilege violations:** employees who accessed data classified
   above their clearance level.
   
## Tech
MariaDB, SQL (multi-table joins, aggregation, date functions, views)

## Schema
- Clearance_Levels (lookup table ranking each clearance level)
- Employees
- Data_Assets
- Access_Logs

## Queries
### Query 1: Inactive accounts
SELECT e.EmployeeID,
       e.Department,
       MAX(l.Last_Login_Date) AS LastLogin,
       DATEDIFF('2026-11-16', MAX(l.Last_Login_Date)) AS DaysInactive
FROM Employees e
LEFT JOIN Access_Logs l ON e.EmployeeID = l.EmployeeID
GROUP BY e.EmployeeID, e.Department
HAVING LastLogin IS NULL OR DaysInactive > 90;

### Query 2: Privilege violations
SELECT l.LogID,
       e.EmployeeID,
       e.ClearanceLevel AS EmployeeClearance,
       d.Data_Accessed,
       d.Classification AS DataClassification
FROM Access_Logs l
JOIN Employees e          ON l.EmployeeID = e.EmployeeID
JOIN Data_Assets d        ON l.Data_Accessed = d.Data_Accessed
JOIN Clearance_Levels ec  ON e.ClearanceLevel = ec.Level_Name
JOIN Clearance_Levels dc  ON d.Classification = dc.Level_Name
WHERE dc.Level_Rank > ec.Level_Rank;

## GRC mapping
These findings are inspired by NIST SP 800-53 controls AC-2 (account
management) and AC-6 (least privilege). This is a mock project, not a
compliant implementation.

## Suggested remediation
Disable inactive accounts, revoke the excess access, and notify the
data owner.

## How to run
Import `federal_audit.sql` through phpMyAdmin's Import tab, or run the
statements in the SQL tab.[federal_audit.sql](https://github.com/user-attachments/files/34944598/federal_audit.sql)

