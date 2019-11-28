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
    
    @Param(completion: .none)
    var productName: String
    
    @Flag("-e", "--exec", description: "Make an executable product")
    var executable: Bool
    
    @Flag("-l", "--lib", description: "Make a library product (default)")
    var library: Bool
    
    @Flag("-s", "--static", description: "Make a static library")
    var staticProduct: Bool
    
    @Flag("-d", "--dynamic", description: "Make a dynamic library")
    var dynamicProduct: Bool

    @Key<String>("-t", "--targets", description: "Creates the new product with the given targets; comma-separated")
    var targets: String?
    
    var optionGroups: [OptionGroup] {
        return [
            .atMostOne($executable, $library),
            .atMostOne($staticProduct, $dynamicProduct, $executable)
        ]
    }
    
    func execute() throws {
        var package = try loadPackage()
        
        if package.getProduct(named: productName) != nil {
            throw IceError(message: "product \(productName) already exists")
        }
        
        let type: Package.Product.ProductType
        if executable {
            type = .executable
        } else if staticProduct {
            type = .library(.static)
        } else if dynamicProduct {
            type = .library(.dynamic)
        } else {
            type = .library(.automatic)
        }
        
        let productTargets = targets?.commaSeparated() ?? []
        package.addProduct(
            name: productName,
            targets: productTargets,
            type: type
        )
        try package.sync()
    }
    
}

private class ProductRemoveCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Remove the given product"
    
    @Param var product: String
    
    func execute() throws {
        var package = try loadPackage()
        
        guard let product = package.getProduct(named: product) else {
            throw IceError(message: "product '\(self.product)' not found")
        }
        
        package.removeProduct(product)
        try package.sync()
    }
    
}

