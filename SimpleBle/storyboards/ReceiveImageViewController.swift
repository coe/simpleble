//
//  ReceiveImageViewController.swift
//  SimpleBle
//
//  Created by COFFEE on 2018/05/01.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit

class ReceiveImageViewController: UIViewController {
    
    var image:UIImage!

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
