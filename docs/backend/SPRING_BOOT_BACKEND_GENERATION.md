# Phase 3: Spring Boot Backend Generation

## 1. Project Structure

```text
pom.xml
src/main/java/com/eprocurement/erp/
├── EProcurementApplication.java
├── config/
│   ├── AuditingConfig.java
│   └── OpenApiConfig.java
├── controller/
│   ├── AuthController.java
│   ├── InvoiceController.java
│   ├── PlatformController.java
│   ├── PurchaseOrderController.java
│   ├── PurchaseRequisitionController.java
│   └── VendorController.java
├── domain/
│   ├── entity/
│   │   ├── AuditLog.java
│   │   ├── BaseAuditableEntity.java
│   │   ├── Invoice.java
│   │   ├── Item.java
│   │   ├── PermissionEntity.java
│   │   ├── PurchaseOrder.java
│   │   ├── PurchaseRequisition.java
│   │   ├── PurchaseRequisitionLine.java
│   │   ├── RoleEntity.java
│   │   ├── UserEntity.java
│   │   └── Vendor.java
│   └── enums/
├── dto/
├── exception/
├── repository/
├── security/
└── service/
src/main/resources/application.yml
src/test/java/com/eprocurement/erp/service/
```

## 2. Architecture and SOLID Boundaries

- **Controllers** expose HTTP resources only; they validate request DTOs and delegate to use-case services.
- **Services** implement transactional business use cases such as vendor onboarding, PR creation/submission, PO reads, invoice reads, authentication, and audit recording.
- **Repositories** are Spring Data interfaces responsible for persistence access only.
- **Entities** map the PostgreSQL schema and contain minimal domain behavior, such as adding PR lines.
- **DTOs** isolate API contracts from JPA entities.
- **Security** is centralized in JWT and Spring Security configuration.
- **Exceptions** are translated consistently by a global exception handler.

## 3. Generated Backend Capabilities

| Requirement | Implementation |
| --- | --- |
| Java 21 | Maven compiler property in `pom.xml` |
| Spring Boot | Spring Boot parent and starters |
| Spring Security JWT | Stateless security filter chain, JWT service, authentication filter, login endpoint |
| JPA/Hibernate | Entity mappings and Spring Data repositories |
| PostgreSQL | PostgreSQL runtime driver and `eproc` schema mapping |
| Swagger | Springdoc OpenAPI and bearer security scheme |
| Global exception handling | `@RestControllerAdvice` with consistent error response |
| Validation | Jakarta validation annotations on request DTOs |
| Logging | SLF4J logging in services and JWT filter |
| Audit | JPA auditing fields and explicit immutable `audit_logs` writes |
| Unit tests | Mockito tests for vendor and PR use cases; JWT unit test |

## 4. API Documentation

Swagger UI is available at:

```text
/swagger-ui.html
```

OpenAPI JSON is available at:

```text
/v3/api-docs
```

## 5. Initial REST Resources

- `POST /api/v1/auth/login`
- `POST /api/v1/vendors`
- `GET /api/v1/vendors`
- `GET /api/v1/vendors/{id}`
- `POST /api/v1/purchase-requisitions`
- `POST /api/v1/purchase-requisitions/{id}/submit`
- `GET /api/v1/purchase-requisitions`
- `GET /api/v1/purchase-requisitions/{id}`
- `GET /api/v1/purchase-orders`
- `GET /api/v1/purchase-orders/{id}`
- `GET /api/v1/invoices`
- `GET /api/v1/invoices/{id}`
- `GET /api/v1/platform/structure`
