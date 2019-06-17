//
//  MZWorkerEditableCell.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 09/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZWorkerEditableCell : MZWorkerCell
{
    
    @IBOutlet weak var triggerImgView: UIImageView?
    @IBOutlet weak var executeButton: UIButton?
    @IBOutlet weak var actionsScrollView: UIScrollView?
    @IBOutlet weak var filtersScrollView: UIScrollView?
    @IBOutlet weak var filterArrowImage: UIImageView!
    @IBOutlet weak var actionsWidth: NSLayoutConstraint!
    @IBOutlet weak var descriptionActionLabel: UILabel?

    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.triggerImgView?.layer.cornerRadius = CORNER_RADIUS
    }

    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.actionsScrollView?.subviews.forEach{ $0.removeFromSuperview() }
        self.filtersScrollView?.subviews.forEach{ $0.removeFromSuperview() }
        self.actionsWidth.constant = 100.0
        self.triggerImgView?.cancelImageDownloadTask()//.cancelImageDownloadTask()
        self.triggerImgView?.image = nil
    }
    
    override func setViewModel (_ viewModel: MZWorkerViewModel)
    {
        super.setViewModel(viewModel)
		
		//dLog(message: viewModel.label)
        
        var visibleCellsCount = 0
        if UIScreen.main.bounds.size.width == 320.0 && viewModel.actionDeviceVMs.count > 3 {
            visibleCellsCount = 3
        } else if (viewModel.actionDeviceVMs.count > 4) {
            visibleCellsCount = 4
        } else {
            visibleCellsCount = viewModel.actionDeviceVMs.count
        }
        self.actionsWidth.constant = 40.0 + 40 * 0.75 * CGFloat(visibleCellsCount - 1)
        
        for index in 0..<visibleCellsCount
        {
            let action = viewModel.actionDeviceVMs[index]
            
            var theView = UIView()
            
            if UIScreen.main.bounds.size.width == 320.0 && index >= 2 && viewModel.actionDeviceVMs.count != visibleCellsCount
            {
                let vTwo: MZWorkerMoreActionView = (Bundle.main.loadNibNamed("MZWorkerMoreActionView", owner: self, options: nil)![0] as? MZWorkerMoreActionView)!
                vTwo.countLabel?.text = "+" + String(viewModel.actionDeviceVMs.count - 2)
                theView = vTwo
            }
            else if index >= 3 && viewModel.actionDeviceVMs.count != visibleCellsCount
            {
                let vTwo: MZWorkerMoreActionView = (Bundle.main.loadNibNamed("MZWorkerMoreActionView", owner: self, options: nil)![0] as? MZWorkerMoreActionView)!
                vTwo.countLabel?.text = "+" + String(viewModel.actionDeviceVMs.count - 3)
                theView = vTwo
            }
            else
            {
                let vOne = (Bundle.main.loadNibNamed("MZWorkerActionView", owner: self, options: nil)![0] as? MZWorkerActionView)!
				let url = action.imageUrlAlt == nil ? URL(string: "") : action.imageUrlAlt!
				vOne.imgView?.setImageWith(url!)
                theView = vOne
            }
			
			let frame = CGRect (x: CGFloat(theView.frame.size.width * CGFloat(0.75)) * CGFloat(index), y: theView.frame.origin.y, width: theView.frame.size.width, height: theView.frame.size.height)
            theView.frame = frame
            
            self.actionsScrollView?.insertSubview(theView, at: 0)
        }
        
        self.filterArrowImage.isHidden = viewModel.stateDeviceVMs.isEmpty
        
        for index in 0 ..< viewModel.stateDeviceVMs.count
        {
            let state = viewModel.stateDeviceVMs[index]
            
            let theView: MZWorkerActionView = (Bundle.main.loadNibNamed("MZWorkerActionView", owner: self, options: nil)![0] as? MZWorkerActionView)!

			let url=state.imageUrlAlt!
			theView.imgView?.setImageWith(url)
			let frame = CGRect(x: CGFloat(theView.frame.size.width * CGFloat(0.75)) * CGFloat(index), y: theView.frame.origin.y, width: theView.frame.size.width, height: theView.frame.size.height)
            theView.frame = frame
            
            self.filtersScrollView?.insertSubview(theView, at: 0)
        }
        
        if viewModel.triggerDeviceVM != nil
        {
			var imageURL = URL(string: "")
            if let url = viewModel.triggerDeviceVM!.imageUrl
            {
                imageURL = url as URL
            }
			
			self.triggerImgView?.isHidden = true
            if(imageURL != nil && !imageURL!.absoluteString.isEmpty)
            {
                let image = UIImage()
        
                self.triggerImgView?.setImageWith(URLRequest(url: imageURL!), placeholderImage: UIImage(), success: { (request, response, image) in
                    
                    self.triggerImgView!.image = UIImage(cgImage:
                        (image.cgImage!.cropping(to: CGRect(
                            x: CGFloat(0.0),
                            y: CGFloat(0.0),
                            width: image.size.height * (self.triggerImgView!.bounds.size.width / self.triggerImgView!.bounds.size.height) * UIScreen.main.scale * 0.8,
                            height: image.size.height * UIScreen.main.scale * 0.8)
                            )!))
                    self.triggerImgView?.isHidden = false
                    
                }, failure: { (request, response, error) in
                })
            }
            
            let workerDeviceTrigger = viewModel.triggerDeviceVM!
            let workerDeviceTriggerItem = workerDeviceTrigger.items[0]
			
			self.descriptionActionLabel?.text = "" 
        }
        else
        {
            self.triggerImgView?.image = nil
            self.descriptionActionLabel?.text = ""
        }
    }
}
