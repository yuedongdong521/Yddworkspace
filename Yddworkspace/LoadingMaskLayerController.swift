//
//  LoadingMaskLayerController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/11/11.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit


class LoadingMaskLayerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.gray
        // Do any additional setup after loading the view.
        
        let view = LoadingEmpyView.init(frame: self.view.bounds)
        
        self.view.addSubview(view)
        
        view.startMaskLayerAncition()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
