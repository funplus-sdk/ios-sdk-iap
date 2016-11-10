# FunPlus Apple IAB

## Introduction

## Integration

## Usage

### Query Products

```swift
FunPlusAppleIAP.queryProducts(["com.funplus.testprod"]) { result in
    switch result {
    case .Success(let products, let invalidProductIdentifiers):
        // do something
    case .Failed(let error):
        // error handling
    }
}
```

### Check Payment Permission

```swift
let flag = FunPlusAppleIAP.canMakePayments()
```

### Purchase a Product

```swift
FunPlusAppleIAP.purchaseProduct("com.funplus.testprod") { result in
    switch result {
    case .Success(let transaction):
        // do something
    case .Failed(let error):
        // error handling
    }
}
```

### Restore Completed Purchases

```swift
FunPlusAppleIAP.restoreCompletedTransactions() { result in
    switch result {
    case .Success(let transactions):
        // do something
    case .Failed(let error):
        // error handling
    }
}
```

### Finish a Transaction

```swift
FunPlusAppleIAP.finishTransaction(transaction)
```

### Verify Receipt

```swift
FunPlusAppleIAP.verifyReceipt() { result in
  switch result {
    case .Success(let receipt):
        // do something
    case .Failed(let error):
        // error handling
    }
}
```

### Verify Purchase

```swift
FunPlusAppleIAP.verifyReceipt() { result in
  switch result {
    case .Success(let receipt):
        let purchaseResult = FunPlusAppleIAP.verifyPurchase(
            productIdentifier: "com.funplus.testprod",
            inReceipt: receipt
        )
        
        switch purchaseResult {
            case .Purchased:
                // do something
            case .NotPurchased:
                // do something
        }
    case .Failed(let error):
        // error handling
    }
}
```

