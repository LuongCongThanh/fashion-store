# Fashion Store

A fashion e-commerce system made of three separately versioned applications that share one API contract.

## Applications

**Backend**:
The application that owns all business data and rules and exposes them through the API Contract.
_Avoid_: be-demo, server, API (when meaning the application)

**CMS**:
The back-office application where staff manage products, orders and content.
_Avoid_: admin, dashboard, backoffice

**Storefront**:
The customer-facing shop where shoppers browse and buy.
_Avoid_: fe, frontend, web, client, nike-style

## Integration

**API Contract**:
The versioned description of every endpoint the Backend offers, which the CMS and Storefront build against.
_Avoid_: schema, swagger, spec

**Contract Version**:
A published, numbered snapshot of the API Contract that the CMS and Storefront pin to.
_Avoid_: API version, openapi tag

**Breaking Change**:
A change to the API Contract that can make an existing CMS or Storefront build fail or misbehave.
_Avoid_: major change
