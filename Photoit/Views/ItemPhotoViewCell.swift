//
//  ItemPhotoViewCell.swift
//  Remember Remember
//
//  Created by Roman Barzyczak on 24.02.2015.
//  Copyright (c) 2015 Remember Remember. All rights reserved.
//

import UIKit

class ItemPhotoViewCell: UITableViewCell
{

    @IBOutlet weak var itemPhoto: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                itemPhoto.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                itemPhoto.addConstraint(aspectConstraint!)
            }
        }
    }


    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
}
