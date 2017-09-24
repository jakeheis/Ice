//
//  Product.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/24/17.
//

import SwiftCLI
import Core
import FileKit

class ProductGroup: CommandGroup {
    let name = "product"
    let shortDescription = "Manage the package products"
    let children: [Routable] = [
        ProductAddCommand(),
        ProductRemoveCommand()
    ]
}

private class ProductAddCommand: Command {
    
    let name = "add"
    let shortDescription = "Add a new product"
    
    let productName = Parameter()
    
    let executable = Flag("-e", "--exec", description: "Make an executable product")
    let library = Flag("-l", "--lib", description: "Make a library product (default)")
    
    let staticProduct = Flag("-s", "--static", description: "Make a static library")
    let dynamicProduct = Flag("-d", "--dynamic", description: "Make a dynamic library")

    let targets = Key<String>("-t", "--targets", description: "Creates the new product with the given targets; comma-separated")
    
    var optionGroups: [OptionGroup] {
        return [
            OptionGroup(options: [executable, library], restriction: .atMostOne),
            OptionGroup(options: [staticProduct, dynamicProduct, executable], restriction: .atMostOne),
        ]
    }
    
    func execute() throws {
        var package = try Package.load(directory: ".")
        
        if package.products.contains(where: { $0.name == productName.value }) {
            throw IceError(message: "product \(productName.value) already exists")
        }
        
        let type: Package.ProductType
        if executable.value {
            type = .executable
        } else if staticProduct.value {
            type = .staticLibrary
        } else if dynamicProduct.value {
            type = .dynamicLibrary
        } else {
            type = .library
        }
        let productTargets = targets.value?.commaSeparated() ?? []
        package.addProduct(
            name: productName.value,
            type: type,
            targets: productTargets
        )
        try package.write()
    }
    
}

private class ProductRemoveCommand: Command {
    
    let name = "remove"
    
    let product = Parameter()
    
    func execute() throws {
        var project = try Package.load(directory: ".")
        try project.removeProduct(name: product.value)
        try project.write()
    }
    
}

