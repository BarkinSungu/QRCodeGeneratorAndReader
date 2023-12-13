//
//  TabBarController.swift
//  QRCodeCreaterAndReader
//
//  Created by Barkın Süngü on 13.12.2023.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().barTintColor = .black
        
        // UITabBarItem'ların seçilmemiş (normal) ikon renklerini ayarlayın
        if let items = tabBar.items {
            for item in items {
                // Seçilmemiş ikonun rengini normalIconColor ile ayarlayın
                item.image = item.selectedImage?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage?.withTintColor(.white)
            }
        }

        //Create Generate QR Code View Controller
        let generateQrCodeVC = GenerateQrCodeViewController()
        generateQrCodeVC.tabBarItem = UITabBarItem(title: "Generate", image: UIImage(systemName: "qrcode"), tag: 0)

        //Create Read QR Code View Controller
        let readQrCodeVC = ReadQrCodeViewController()
        readQrCodeVC.tabBarItem = UITabBarItem(title: "Read", image: UIImage(systemName: "qrcode.viewfinder"), tag: 1)

        //Add Views to Tab Bar
        viewControllers = [generateQrCodeVC, readQrCodeVC]
    }


}
