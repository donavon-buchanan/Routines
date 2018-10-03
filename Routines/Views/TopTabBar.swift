//
//  MenuBar.swift
//  Routines
//
//  Created by Donavon Buchanan on 10/1/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit

class TopTabBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //Number of tabs in bar
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    //configure collection view cells
    let cellID = "cellID"
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(UICollectionView.self, forCellWithReuseIdentifier: cellID)
        
        addSubview(collectionView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var collectionView: UICollectionView = {
       
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor.red
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
}
