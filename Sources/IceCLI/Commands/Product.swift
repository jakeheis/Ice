//
//  Product.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/24/17.
//

import IceKit
import SwiftCLI

class ProductGroup: IceObject, CommandGroup {
    let name = "product"
    let shortDescription = "Manage the package products"
    lazy var children: [Routable] = [
        ProductAddCommand(ice: ice),
        ProductRemoveCommand(ice: ice)
    ]
}

private class ProductAddCommand: IceObject, Command {
    
    let name = "add"
    let shortDescription = "Add a new product"
    
    let productName = Parameter(completion: .none)
    
    let executable = Flag("-e", "--exec", description: "Make an executable product")
    let library = Flag("-l", "--lib", description: "Make a library product (default)")
    
    let staticProduct = Flag("-s", "--static", description: "Make a static library")
    let dynamicProduct = Flag("-d", "--dynamic", description: "Make a dynamic library")

    let targets = Key<String>("-t", "--targets", description: "Creates the new product with the given targets; comma-separated")
    
    var optionGroups: [OptionGroup] {
        return [
            .atMostOne(executable, library),
            .atMostOne(staticProduct, dynamicProduct, executable)
        ]
    }
    
    func execute() throws {
        var package = try loadPackage()
        
        if package.getProduct(named: productName.value) != nil {
            throw IceError(message: "product \(productName.value) already exists")
        }
        
        let type: Package.Product.ProductType
        if executable.value {
            type = .executable
        } else if staticProduct.value {
            type = .library(.static)
        } else if dynamicProduct.value {
            type = .library(.dynamic)
        } else {
            type = .library(.automatic)
        }
        
        let productTargets = targets.value?.commaSeparated() ?? []
        package.addProduct(
            name: productName.value,
            targets: productTargets,
            type: type
        )
        try package.sync()
    }
    
}

private class ProductRemoveCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Remove the given product"
    
    let product = Parameter()
    
    func execute() throws {
        var package = try loadPackage()
        
        guard let product = package.getProduct(named: product.value) else {
            throw IceError(message: "product '\(self.product.value)' not found")
        }
        
        package.removeProduct(product)
        try package.sync()
    }
    
}

