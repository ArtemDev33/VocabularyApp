//
//  UIKit+Navigation.swift
//  VocabularyApp
//
//  Created by Havrylenko Artem on 17.05.2021.
//

import UIKit

// MARK: -
// MARK: UINavigationController
extension UINavigationController {
    
    func push(controller: UIViewController, animated: Bool) {
        self.pushViewController(controller, animated: animated)
    }
    
    func push(controllers: [UIViewController], animated: Bool) {
        
        guard !controllers.isEmpty else { return }
        
        var viewControllers = self.viewControllers
        viewControllers.append(contentsOf: controllers)
        self.setViewControllers(viewControllers, animated: animated)
    }
    
    func pop(_ viewController: UIViewController, animated: Bool = true) {
        
        let updates = self.controllers(byRemoving: viewController)
        let newControllers = updates.controllers
        print("not popped")
        guard updates.index != nil else { return }
        guard !newControllers.isEmpty else { return }
        print("popped")
        self.setViewControllers(newControllers, animated: animated)
    }
    
    func replace(_ viewController: UIViewController, with controllers: [UIViewController], animated: Bool = true) {
        
        guard !controllers.isEmpty else {
            
            self.pop(viewController, animated: animated)
            return
        }
        
        let updates = self.controllers(byRemoving: viewController)
        
        guard let oldIndex = updates.index else { return }
        
        guard !updates.controllers.isEmpty else {
            
            self.setViewControllers(controllers, animated: animated)
            return
        }
        
        var newControllers = updates.controllers
        newControllers.insert(contentsOf: controllers, at: oldIndex)
        
        self.setViewControllers(newControllers, animated: animated)
    }
}

// MARK: -
// MARK: Private
fileprivate extension UINavigationController {
    
    func controllers(byRemoving viewController: UIViewController) -> (controllers: [UIViewController], index: Int?) {
        
        let reversedControllers = Array(viewControllers.reversed())
        
        guard let reversedIndex = reversedControllers.firstIndex(of: viewController) else {
            return (controllers: viewControllers, index: nil)
        }
        
        let index = (viewControllers.count - 1) - reversedIndex
        
        var newControllers = self.viewControllers
        newControllers.remove(at: index)
        
        return (controllers: newControllers, index: index)
    }
}
