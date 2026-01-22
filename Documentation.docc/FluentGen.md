# FluentGen

A Swift macro that automatically generates Fluent ORM model classes from simple domain model structs.

## Overview

FluentGen eliminates boilerplate by automatically generating Fluent database models from your domain structs:

- **Automatic Model Generation**: Convert structs to Fluent models
- **Type Safety**: Leverage Swift's type system
- **Reduced Boilerplate**: No manual model definitions needed
- **Migration Support**: Automatic schema generation

## Getting Started

See the ``GettingStarted`` tutorial to use FluentGen in your project.

## Usage

Apply the `@FluentModel` macro to your structs:

```swift
@FluentModel
struct User {
    var id: UUID?
    var name: String
    var email: String
}
```

FluentGen automatically generates the corresponding Fluent model with all necessary methods.
