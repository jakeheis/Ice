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
        try package.sync()
    }
    
}

private class ProductRemoveCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Remove the given product"
    
    let product = Parameter()
    
    func execute() throws {
        var project = try loadPackage()
        try project.removeProduct(name: product.value)
        try project.sync()
    }
    
}

